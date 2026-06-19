# FindTBB.cmake
# Supports both oneTBB 2021+ (via its CMake config file) and legacy Intel TBB.
# Sets: TBB_FOUND, TBB_INCLUDE_DIRS, TBB_LIBRARIES

# --- 1. Try config-file mode (oneTBB 2021+ ships TBBConfig.cmake) ---
if (NOT TBB_FOUND)
    find_package(TBB CONFIG QUIET)
    if (TBB_FOUND AND TARGET TBB::tbb)
        # Wrap in PyMesh's expected variable names
        set(TBB_INCLUDE_DIRS "")   # propagated transitively via TBB::tbb
        set(TBB_LIBRARIES TBB::tbb)
        if (TARGET TBB::tbbmalloc)
            list(APPEND TBB_LIBRARIES TBB::tbbmalloc)
        endif()
        message(STATUS "Found oneTBB via config file (${TBB_VERSION})")
        set(TBB_FOUND TRUE)
        return()
    endif()
    set(TBB_FOUND FALSE)
endif()

# --- 2. Legacy module-mode search (old Intel TBB, e.g. vendored 2019) ---
if (NOT TBB_ROOT)
    set(TBB_ROOT $ENV{TBB_ROOT})
endif()
if (NOT TBB_ROOT)
    set(TBB_ROOT $ENV{TBBROOT})
endif()

if (NOT WIN32)
    find_path(EMBREE_TBB_ROOT include/tbb/tbb.h
        DOC "Root of TBB installation"
        HINTS ${TBB_ROOT}
        PATHS
            ${PROJECT_SOURCE_DIR}/tbb
            /opt/intel/composerxe/tbb
            /opt/intel/tbb
        NO_DEFAULT_PATH
    )

    if (NOT EMBREE_TBB_ROOT)
        # No explicit root — search standard system paths
        # Use tbb.h since task_scheduler_init.h was removed in oneTBB (already
        # handled above via config mode; this branch is old TBB only)
        find_path(TBB_INCLUDE_DIR tbb/tbb.h)
        find_library(TBB_LIBRARY tbb)
        find_library(TBB_LIBRARY_MALLOC tbbmalloc)
    else()
        set(TBB_INCLUDE_DIR TBB_INCLUDE_DIR-NOTFOUND)
        set(TBB_LIBRARY TBB_LIBRARY-NOTFOUND)
        set(TBB_LIBRARY_MALLOC TBB_LIBRARY_MALLOC-NOTFOUND)
        find_path(TBB_INCLUDE_DIR tbb/tbb.h
            PATHS ${EMBREE_TBB_ROOT}/include NO_DEFAULT_PATH)
        set(_TBB_HINTS HINTS
            ${EMBREE_TBB_ROOT}/lib/intel64/gcc4.4
            ${EMBREE_TBB_ROOT}/lib
            ${EMBREE_TBB_ROOT}/lib64)
        find_library(TBB_LIBRARY tbb ${_TBB_HINTS})
        find_library(TBB_LIBRARY_MALLOC tbbmalloc ${_TBB_HINTS})
    endif()
else()
    # Windows — minimal support
    find_path(TBB_INCLUDE_DIR tbb/tbb.h HINTS ${TBB_ROOT}/include)
    find_library(TBB_LIBRARY tbb HINTS ${TBB_ROOT}/lib)
    find_library(TBB_LIBRARY_MALLOC tbbmalloc HINTS ${TBB_ROOT}/lib)
endif()

# tbbmalloc is optional in oneTBB and vendored TBB; don't require it
if (NOT TBB_LIBRARY_MALLOC)
    set(TBB_LIBRARY_MALLOC "")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TBB DEFAULT_MSG TBB_INCLUDE_DIR TBB_LIBRARY)

if (TBB_FOUND)
    set(TBB_INCLUDE_DIRS ${TBB_INCLUDE_DIR})
    set(TBB_LIBRARIES ${TBB_LIBRARY})
    if (TBB_LIBRARY_MALLOC)
        list(APPEND TBB_LIBRARIES ${TBB_LIBRARY_MALLOC})
    endif()
endif()

mark_as_advanced(TBB_INCLUDE_DIR TBB_LIBRARY TBB_LIBRARY_MALLOC)
