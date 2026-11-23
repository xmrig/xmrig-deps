# The releases to build. To update a dependency, change its version and SHA256 here, then run
# cmake/update.cmake.

# From 1.53.0, programs on Windows also link the system library "synchronization".
set(LIBUV_VERSION 1.53.0)
set(LIBUV_SHA256 cb0d6dd2128d5a95bd242c6cc982a24fe608fa93da57b6b4ec763b0018c53e64)

# The 3.5 LTS line.
set(OPENSSL_VERSION 3.5.9)
set(OPENSSL_SHA256 603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a)

set(HWLOC_VERSION 2.15.0)
set(HWLOC_SHA256 f54bbdfc9f8015308c2e7bbab3e7789e47436a4a016689e5749a0c35d6877619)
