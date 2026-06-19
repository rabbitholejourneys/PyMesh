#!/bin/bash
# Build PyMesh wheel for Python 3.11 + NumPy 2.
# Usage:
#   ./build.sh           # Build with all available cores
#   ./build.sh 4         # Build with 4 cores
#   ./build.sh --no-cache  # Force a clean rebuild

set -e

CORES=${1:-$(nproc)}
NO_CACHE_FLAG=""
if [[ "$1" == "--no-cache" ]]; then
    NO_CACHE_FLAG="--no-cache"
    CORES=$(nproc)
fi

IMAGE="pymesh-builder"
# Resolve the repo root (the directory containing this script and Dockerfile)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$REPO_ROOT/dist"
mkdir -p "$DIST_DIR"

echo "==> Building Docker image (cores=$CORES)..."
docker build \
    $NO_CACHE_FLAG \
    --build-arg NUM_CORES="$CORES" \
    -t "$IMAGE" \
    --target builder \
    -f "$REPO_ROOT/Dockerfile" \
    "$REPO_ROOT"

echo "==> Extracting wheel..."
CONTAINER=$(docker create "$IMAGE")
docker cp "$CONTAINER":/pymesh/dist/manylinux/. "$DIST_DIR/"
docker rm "$CONTAINER"

WHEEL=$(ls "$DIST_DIR"/pymesh2-*manylinux*.whl 2>/dev/null | tail -1)
if [[ -z "$WHEEL" ]]; then
    echo "ERROR: No wheel found in $DIST_DIR" >&2
    exit 1
fi

echo "==> Wheel built: $WHEEL"
echo ""
echo "Install with:"
echo "  pip install $WHEEL"
echo ""
echo "Quick smoke test:"
echo "  python -c \"import pymesh; m=pymesh.generate_box_mesh([0,0,0],[1,1,1]); print('vertices:', m.num_vertices)\""
