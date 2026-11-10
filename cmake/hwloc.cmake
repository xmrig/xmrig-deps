# hwloc as a static library, with the options of XMRig's scripts/build.hwloc.sh. Built in its source
# directory: an out-of-tree build would put a path with a drive letter in make's VPATH. The timestamps
# of the archive are kept so that make doesn't try to run autotools again. CFLAGS leaves out the -g of
# autotools and takes the build directory out of __FILE__, for the library not to record where it was built.

find_program(XMRIG_SH NAMES sh REQUIRED)
find_program(XMRIG_MAKE NAMES make REQUIRED)

string(REGEX MATCH "^[0-9]+\\.[0-9]+" hwloc_series ${HWLOC_VERSION})

ExternalProject_Add(hwloc
    URL                 https://download.open-mpi.org/release/hwloc/v${hwloc_series}/hwloc-${HWLOC_VERSION}.tar.gz
    URL_HASH            SHA256=${HWLOC_SHA256}
    DOWNLOAD_DIR        ${XMRIG_DEPS_DOWNLOADS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    DOWNLOAD_NO_PROGRESS ON
    PREFIX              ${CMAKE_BINARY_DIR}/hwloc
    BUILD_IN_SOURCE     ON
    CONFIGURE_COMMAND   ${XMRIG_SH} ./configure --prefix=${stage} --build=${hwloc_triplet} --host=${hwloc_triplet}
                        --disable-shared --enable-static --disable-io --disable-libudev --disable-libxml2
                        CC=${CMAKE_C_COMPILER} "CFLAGS=-O2 -ffile-prefix-map=<SOURCE_DIR>=."
    BUILD_COMMAND       ${XMRIG_MAKE} -j${jobs} -C hwloc
    INSTALL_COMMAND     ${XMRIG_MAKE} -C include install
    COMMAND             ${XMRIG_MAKE} -C hwloc install
    LOG_CONFIGURE       ON
    LOG_BUILD           ON
    LOG_INSTALL         ON
    LOG_OUTPUT_ON_FAILURE ON
)
