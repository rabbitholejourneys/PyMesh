[![Documentation Status](https://readthedocs.org/projects/pymesh/badge/?version=latest)](https://pymesh.readthedocs.io/en/latest/?badge=latest)

> **This is a community fork** of [PyMesh/PyMesh](https://github.com/PyMesh/PyMesh) updated to
> build against Python 3.11, NumPy ≥ 2, and a modern Linux toolchain (GCC 13, C++17).
> The original project appears unmaintained. See [What changed](#what-changed) for details.

---

### About PyMesh ###

**PyMesh** is a rapid prototyping platform for geometry processing, written in C++ and Python.
Computationally intensive operations are implemented in C++; Python provides the high-level API.

![PyMesh][teaser]
(Model source: [Bust of Sappho](https://www.thingiverse.com/thing:14565))

---

### Quick start (Docker) ###

Build the wheel locally and drop it in `dist/`:

```bash
git clone https://github.com/rabbitholejourneys/PyMesh.git
cd PyMesh
./build.sh          # uses all available cores
# or: ./build.sh 4  # use 4 cores
```

Then install:

```bash
pip install dist/pymesh2-*-manylinux_2_34_x86_64.whl
python -c "import pymesh; m = pymesh.generate_box_mesh([0,0,0],[1,1,1]); print('vertices:', m.num_vertices)"
```

Requirements: Docker with BuildKit, Python 3.11, pip. No other local dependencies needed.

The produced wheel is tagged `manylinux_2_34_x86_64` and installs on any Linux with glibc ≥ 2.34
(Ubuntu 22.04+, Debian 12+, RHEL 9+).

---

### What changed ###

The upstream repository targets Python 3.6 and libraries from circa 2017–2019. This fork makes it
build and run correctly with a modern stack:

| Area | Change |
|---|---|
| **Python** | 3.11 (was 3.6) |
| **NumPy** | ≥ 2.0 (was ≤ 1.x) |
| **C++ standard** | C++17 (was C++14) |
| **pybind11** | 2.13.6 (was vendored 2.4.3 — did not support Python 3.11+) |
| **TBB** | system oneTBB 2021 via `libtbb-dev` (old vendored TBB 2019 fails on GCC 13) |
| **Draco** | GCC 13 missing-include fixes (`<cstddef>`, `<limits>`) applied via `patches/draco/` |
| **MMG** | built with `-fcommon` (GCC 10+ multiple-definition linker fix) |
| **pybind11 API** | `py::module` → `py::module_` in all 28 binding files |
| **C++17 removals** | `throw()` → `noexcept`; `std::ptr_fun` → lambda |
| **NumPy 2 API** | removed `numpy.testing.Tester` usage |
| **Wheel** | `manylinux_2_34_x86_64` via auditwheel repair (was unportable `linux_x86_64`) |

All original backends remain functional, including the IGL boolean backend
(`igl::copyleft::cgal::mesh_boolean` — libigl + CGAL exact arithmetic).

---

### Dependencies ###

**Python runtime:**
- Python 3.11
- NumPy ≥ 2.0
- SciPy ≥ 1.10

**Bundled in the wheel** (no separate install needed):
- CGAL 5.0 (exact-arithmetic mesh booleans)
- libigl (IGL boolean backend)
- Cork, Tetgen, Triangle, Qhull, Clipper, MMG, Draco, libjson

**System libraries (resolved by the manylinux wheel):**
- GMP / MPFR (via `libgmp10`, `libmpfr6`)
- Boost.Thread / Boost.System
- oneTBB 2021

---

### Build from source (without Docker) ###

If you want to build outside Docker, you need on Debian/Ubuntu:

```bash
apt-get install cmake git ninja-build gcc g++ patchelf \
    libgmp-dev libmpfr-dev libgmpxx4ldbl \
    libboost-dev libboost-thread-dev libboost-system-dev \
    libboost-date-time-dev libboost-chrono-dev libboost-atomic-dev \
    libtbb-dev
pip install "numpy>=2.0" "scipy>=1.10" wheel setuptools auditwheel
```

Then:

```bash
git clone https://github.com/rabbitholejourneys/PyMesh.git
cd PyMesh
git submodule update --init
pip install -e .      # or: python setup.py bdist_wheel
```

Note: pybind11 2.13.6 is cloned by the Dockerfile. For a local build, run:

```bash
rm -rf third_party/pybind11
git clone --branch v2.13.6 --depth=1 https://github.com/pybind/pybind11.git third_party/pybind11
```

---

### Documentation ###

Original documentation: [pymesh.readthedocs.io](https://pymesh.readthedocs.io/en/latest/)

---

### License ###

See [LICENSE](LICENSE). Original work by Qingnan Zhou (NYU).

[teaser]: docs/_static/pymesh_teaser.jpg
