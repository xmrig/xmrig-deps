# Builds the dependencies of one directory of this repository, with the toolchain of the environment
# it runs in, and replaces the include and lib directories there once all of them are built. Normally
# run through cmake/update.cmake, which sets that environment up for each target.

cmake_minimum_required(VERSION 3.25)

project(xmrig-deps LANGUAGES C)

set(XMRIG_DEPS_TARGET "" CACHE STRING "The directory of this repository to update, e.g. msvc2026/x64")
set(XMRIG_DEPS_DOWNLOADS ${CMAKE_BINARY_DIR}/downloads CACHE PATH "Where the source archives are kept")

# The Configure target of OpenSSL and, for hwloc, the triplet of each directory.
if (XMRIG_DEPS_TARGET MATCHES "^msvc[0-9]+/x64$")
    set(openssl_target VC-WIN64A)
elseif (XMRIG_DEPS_TARGET MATCHES "^msvc[0-9]+/arm64$")
    set(openssl_target VC-WIN64-ARM)
elseif (XMRIG_DEPS_TARGET STREQUAL "gcc/x64")
    set(openssl_target mingw64)
    set(hwloc_triplet x86_64-w64-mingw32)
elseif (XMRIG_DEPS_TARGET STREQUAL "clang/arm64")
    set(openssl_target mingwarm64)
    set(hwloc_triplet aarch64-w64-mingw32)
else()
    message(FATAL_ERROR "xmrig-deps: unknown XMRIG_DEPS_TARGET '${XMRIG_DEPS_TARGET}'; use cmake/update.cmake to run this")
endif()

include(ExternalProject)
include(cmake/versions.cmake)

set(stage ${CMAKE_BINARY_DIR}/stage)
file(MAKE_DIRECTORY ${XMRIG_DEPS_DOWNLOADS} ${stage}/include ${stage}/lib)
cmake_host_system_information(RESULT jobs QUERY NUMBER_OF_LOGICAL_CORES)

include(cmake/libuv.cmake)
include(cmake/openssl.cmake)
set(deps libuv openssl)

# The MSVC directories have no hwloc: XMRig builds its own bundled copy there.
if (NOT MSVC)
    include(cmake/hwloc.cmake)
    list(APPEND deps hwloc)
endif()

add_custom_target(publish ALL
    COMMAND ${CMAKE_COMMAND} -DSTAGE=${stage} -DDEST=${CMAKE_CURRENT_SOURCE_DIR}/${XMRIG_DEPS_TARGET} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/publish.cmake
    DEPENDS ${deps}
    VERBATIM
)
