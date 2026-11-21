# hwloc as a static library.
#
# With MSVC by the CMake build that hwloc has for Windows, without its tools and tests: hwloc.lib, with
# the static C runtime and its debug information in hwloc.pdb, as libuv.
#
# Elsewhere with the options of XMRig's scripts/build.hwloc.sh. Built in its source directory: an
# out-of-tree build would put a path with a drive letter in make's VPATH. The timestamps of the archive
# are kept so that make doesn't try to run autotools again. CFLAGS leaves out the -g of autotools and
# takes the build directory out of __FILE__, for the library not to record where it was built.

string(REGEX MATCH "^[0-9]+\\.[0-9]+" hwloc_series ${HWLOC_VERSION})

set(hwloc_source
    URL                 https://download.open-mpi.org/release/hwloc/v${hwloc_series}/hwloc-${HWLOC_VERSION}.tar.gz
    URL_HASH            SHA256=${HWLOC_SHA256}
    DOWNLOAD_DIR        ${XMRIG_DEPS_DOWNLOADS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    DOWNLOAD_NO_PROGRESS ON
    PREFIX              ${CMAKE_BINARY_DIR}/hwloc
    LOG_CONFIGURE       ON
    LOG_BUILD           ON
    LOG_INSTALL         ON
    LOG_OUTPUT_ON_FAILURE ON
)

if (MSVC)
    ExternalProject_Add(hwloc ${hwloc_source}
        SOURCE_SUBDIR       contrib/windows-cmake
        CMAKE_ARGS          -DCMAKE_BUILD_TYPE=Release
                            -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                            -DCMAKE_INSTALL_PREFIX=${stage}
                            -DCMAKE_INSTALL_LIBDIR=lib
                            -DBUILD_SHARED_LIBS=OFF
                            -DHWLOC_ENABLE_TESTING=OFF
                            -DHWLOC_SKIP_TOOLS=ON
                            -DHWLOC_SKIP_LSTOPO=ON
                            ${msvc_args}
                            -DCMAKE_PROJECT_hwloc_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/msvc_pdb.cmake
                            -DXMRIG_PDB_TARGET=hwloc
                            -DXMRIG_PDB_NAME=hwloc
    )
else()
    find_program(XMRIG_SH NAMES sh REQUIRED)
    find_program(XMRIG_MAKE NAMES make REQUIRED)

    # On macOS also the architecture and the oldest release to run on; configure finds the machine it
    # builds on itself, as the Mac may be of the other architecture.
    set(hwloc_cflags "-O2 -ffile-prefix-map=<SOURCE_DIR>=.")

    if (APPLE)
        string(APPEND hwloc_cflags " -arch ${apple_arch} -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
        set(hwloc_machine --host=${hwloc_triplet})
    else()
        set(hwloc_machine --build=${hwloc_triplet} --host=${hwloc_triplet})
    endif()

    ExternalProject_Add(hwloc ${hwloc_source}
        BUILD_IN_SOURCE     ON
        CONFIGURE_COMMAND   ${XMRIG_SH} ./configure --prefix=${stage} ${hwloc_machine}
                            --disable-shared --enable-static --disable-io --disable-libudev --disable-libxml2
                            CC=${CMAKE_C_COMPILER} "CFLAGS=${hwloc_cflags}"
        BUILD_COMMAND       ${XMRIG_MAKE} -j${jobs} -C hwloc
        INSTALL_COMMAND     ${XMRIG_MAKE} -C include install
        COMMAND             ${XMRIG_MAKE} -C hwloc install
    )
endif()
