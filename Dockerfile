# Pin to bookworm (Debian 12, glibc 2.36) to keep the manylinux tag low.
# "python:3.11" has drifted to Debian trixie (glibc 2.41), producing a
# manylinux_2_39 wheel that doesn't install on Ubuntu 22.04 (glibc 2.35).
FROM python:3.11-bookworm AS builder

ARG NUM_CORES=4
ENV NUM_CORES=${NUM_CORES}
ENV DEBIAN_FRONTEND=noninteractive

# System build tools and library deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    git \
    ninja-build \
    gcc \
    g++ \
    patchelf \
    zip \
    unzip \
    # GMP / MPFR (needed by CGAL)
    libgmp-dev \
    libmpfr-dev \
    libgmpxx4ldbl \
    # Boost (needed by CGAL 5.x; header-only plus thread/system)
    libboost-dev \
    libboost-thread-dev \
    libboost-system-dev \
    libboost-date-time-dev \
    libboost-chrono-dev \
    libboost-atomic-dev \
    # oneTBB (replaces old vendored Intel TBB 2019 which doesn't build on GCC 13)
    libtbb-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /pymesh

# Copy entire repo (build context is the repo root)
COPY . /pymesh

# ---- 1. Replace vendored pybind11 2.4.3 with 2.13.6 ----
# pybind11 2.4.3 does not support Python 3.11+ or NumPy 2.x
RUN rm -rf /pymesh/third_party/pybind11 && \
    git clone --branch v2.13.6 --depth=1 \
        https://github.com/pybind/pybind11.git \
        /pymesh/third_party/pybind11

# ---- 2. Install Python deps ----
RUN pip install --no-cache-dir \
    "numpy>=2.0" \
    "scipy>=1.10" \
    "wheel" \
    "setuptools>=68" \
    "auditwheel"

# ---- 3. Build vendored third-party libs (except TBB — we use system oneTBB) ----
# CGAL, triangle, tetgen, clipper, qhull, cork, draco, mmg, json
RUN cd /pymesh && \
    python third_party/build.py cgal    && \
    python third_party/build.py eigen   && \
    python third_party/build.py triangle && \
    python third_party/build.py tetgen  && \
    python third_party/build.py clipper && \
    python third_party/build.py qhull   && \
    python third_party/build.py cork    && \
    python third_party/build.py draco   && \
    python third_party/build.py mmg     && \
    python third_party/build.py json

# ---- 4. Build PyMesh itself ----
RUN cd /pymesh && python setup.py bdist_wheel

# ---- 5. Strip build-only third_party artifacts from wheel ----
# pymesh/third_party/ contains headers and static libs used at link time; the
# runtime .so files are in pymesh/lib/ and will be bundled by auditwheel below.
RUN python - <<'PYEOF'
import zipfile, os, shutil, tempfile, glob

wheels = glob.glob("/pymesh/dist/pymesh2-*.whl")
assert wheels, "No wheel found in /pymesh/dist/"
wheel_path = wheels[0]
tmp = tempfile.mkdtemp()

with zipfile.ZipFile(wheel_path, "r") as z:
    z.extractall(tmp)

third_party = os.path.join(tmp, "pymesh", "third_party")
if os.path.isdir(third_party):
    shutil.rmtree(third_party)
    print("Removed pymesh/third_party from wheel")

os.replace(wheel_path, wheel_path + ".pre-audit")
with zipfile.ZipFile(wheel_path, "w", zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(tmp):
        for f in files:
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, tmp))
shutil.rmtree(tmp)
print(f"Repacked: {wheel_path}")
PYEOF

# ---- 6. auditwheel repair: bundle remaining external .so deps, tag as manylinux ----
RUN auditwheel repair /pymesh/dist/pymesh2-*.whl -w /pymesh/dist/manylinux/

# Show the result
RUN echo "=== Built wheels ===" && ls -lh /pymesh/dist/manylinux/

# ---- Export stage ----
FROM scratch AS export
COPY --from=builder /pymesh/dist/manylinux/*.whl /
