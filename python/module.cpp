#include <memory>

#include <pybind11/pybind11.h>
#include <pybind11/eigen.h>
#include <pybind11/stl.h>

namespace py = pybind11;

void init_Mesh(py::module_&);
void init_MeshFactory(py::module_&);
void init_MeshWriter(py::module_&);
void init_MeshUtils(py::module_&);
void init_predicates(py::module_&);
void init_ConvexHull(py::module_&);
void init_Boolean(py::module_&);
void init_SelfIntersectionResolver(py::module_&);
void init_Tetrahedralization(py::module_&);
void init_OuterHull(py::module_&);
void init_WindingNumber(py::module_&);
void init_DMAT(py::module_&);
void init_MinkowskiSum(py::module_&);
void init_CellPartition(py::module_&);
void init_Triangulation(py::module_&);
void init_CGAL(py::module_&);
void init_AABB(py::module_&);
void init_Wires(py::module_&);
void init_VoxelGrid(py::module_&);
void init_TriangleWrapper(py::module_&);
void init_FEM(py::module_&);
void init_TetgenWrapper(py::module_&);
void init_IGL(py::module_&);
void init_SparseSolver(py::module_&);
void init_HashGrid(py::module_&);
void init_BVH(py::module_&);
void init_Geogram(py::module_&);
void init_Compression(py::module_&);

PYBIND11_MODULE(PyMesh, m) {
    m.doc() = "Geometry Processing for Python.";

    init_Mesh(m);
    init_MeshFactory(m);
    init_MeshWriter(m);

    init_MeshUtils(m);
    init_predicates(m);
    init_ConvexHull(m);
    init_Boolean(m);
    init_SelfIntersectionResolver(m);
    init_Tetrahedralization(m);
    init_OuterHull(m);
    init_WindingNumber(m);
    init_DMAT(m);
    init_MinkowskiSum(m);
    init_CellPartition(m);
    init_Triangulation(m);
    init_CGAL(m);
    init_AABB(m);
    init_Wires(m);
    init_VoxelGrid(m);
    init_TriangleWrapper(m);
    init_FEM(m);
    init_TetgenWrapper(m);
    init_IGL(m);
    init_SparseSolver(m);
    init_HashGrid(m);
    init_BVH(m);
    init_Geogram(m);
    init_Compression(m);
}
