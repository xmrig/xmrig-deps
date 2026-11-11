# libuv as a static library. With MSVC it uses the static C runtime, as XMRig's release build does,
# and has its debug information in libuv.pdb next to the library.

set(libuv_args
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_INSTALL_PREFIX=${stage}
    -DCMAKE_INSTALL_LIBDIR=lib
    -DLIBUV_BUILD_SHARED=OFF
    -DLIBUV_BUILD_TESTS=OFF
    -DLIBUV_BUILD_BENCH=OFF
)

if (MSVC)
    # libuv.pdb: the target is uv_a, and its "lib" prefix applies to the PDB as well.
    list(APPEND libuv_args ${msvc_args}
        -DCMAKE_PROJECT_libuv_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/msvc_pdb.cmake
        -DXMRIG_PDB_TARGET=uv_a
        -DXMRIG_PDB_NAME=uv
    )
endif()

ExternalProject_Add(libuv
    URL                 https://dist.libuv.org/dist/v${LIBUV_VERSION}/libuv-v${LIBUV_VERSION}.tar.gz
    URL_HASH            SHA256=${LIBUV_SHA256}
    DOWNLOAD_DIR        ${XMRIG_DEPS_DOWNLOADS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    DOWNLOAD_NO_PROGRESS ON
    PREFIX              ${CMAKE_BINARY_DIR}/libuv
    CMAKE_ARGS          ${libuv_args}
    LOG_CONFIGURE       ON
    LOG_BUILD           ON
    LOG_INSTALL         ON
    LOG_OUTPUT_ON_FAILURE ON
)
