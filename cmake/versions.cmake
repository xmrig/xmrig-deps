# The releases to build. To update a dependency, change its version and SHA256 here, then run
# cmake/update.cmake.

# Not 1.53.0 yet: on Windows it needs the system library "synchronization", which XMRig doesn't link
# (EXTRA_LIBS in its CMakeLists.txt).
set(LIBUV_VERSION 1.52.1)
set(LIBUV_SHA256 66d511b9e6e334c0e62279eb234fbfb2b3110b1479c09b95b44c7afca8cff9e7)

# The 3.5 LTS line.
set(OPENSSL_VERSION 3.5.9)
set(OPENSSL_SHA256 603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a)

set(HWLOC_VERSION 2.15.0)
set(HWLOC_SHA256 f54bbdfc9f8015308c2e7bbab3e7789e47436a4a016689e5749a0c35d6877619)
