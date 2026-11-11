# XMRig dependencies
[![Github All Releases](https://img.shields.io/github/downloads/xmrig/xmrig-deps/total.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub release](https://img.shields.io/github/release/xmrig/xmrig-deps/all.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date-pre/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub license](https://img.shields.io/github/license/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/network)

This repository only contains a binary build of XMRig dependencies. 

* [libuv](https://libuv.org/) 1.53.0
* [OpenSSL](https://openssl-library.org/) 3.5.9
* [hwloc](https://www.open-mpi.org/projects/hwloc) 2.15.0

These are the versions in `clang/arm64`, `gcc/x64` and `msvc2026/*`.
The other directories have older versions and are no longer supported.

Programs that link this libuv on Windows also need the system library `synchronization`.

## Usage
### Microsoft Visual Studio 2026
- x64 `cmake .. -G "Visual Studio 18 2026" -A x64 -DXMRIG_DEPS=c:\xmrig-deps\msvc2026\x64`
- arm64 `cmake .. -G "Visual Studio 18 2026" -A ARM64 -DXMRIG_DEPS=c:\xmrig-deps\msvc2026\arm64`, and on an x64 machine also `-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_SYSTEM_PROCESSOR=ARM64`

### MSYS2

- x64 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x64`
- x86 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x86`

## Updating

The versions are pinned with their SHA256 in `cmake/versions.cmake`. After changing them, or to rebuild, run this from any shell:

```
cmake -P cmake/update.cmake
```

It downloads the sources, builds them from a clean directory under `build/` and replaces `include` and `lib` of `clang/arm64`, `gcc/x64`, `msvc2026/arm64` and `msvc2026/x64`. A target whose toolchain isn't on the machine is skipped. To build only some of them, and fail if one can't be built:

```
cmake "-DTARGETS=gcc/x64;msvc2026/x64" -P cmake/update.cmake
```

It needs CMake 3.25 or newer, and for each target:

| Target           | Toolchain                                                                                                          |
|------------------|--------------------------------------------------------------------------------------------------------------------|
| `msvc2026/x64`   | Visual Studio 2026 with the x64 C++ tools; Ninja, a native Perl such as Strawberry Perl and NASM on `PATH`         |
| `msvc2026/arm64` | The same with the ARM64 C++ tools, no NASM                                                                         |
| `gcc/x64`        | MSYS2 with `make`, `perl`, `mingw-w64-ucrt-x86_64-gcc` and `mingw-w64-ucrt-x86_64-ninja`                           |
| `clang/arm64`    | MSYS2 on Windows on ARM64 with `make`, `perl`, `mingw-w64-clang-aarch64-clang` and `mingw-w64-clang-aarch64-ninja` |

MSYS2 is found from `pacman` on `PATH`, otherwise from the location its installer recorded in the registry. For an install the installer didn't make, such as one unpacked from an archive, set the `MSYS2_ROOT` environment variable or add `-DMSYS2_ROOT=<path>` before `-P`. With [jom](https://github.com/qt-labs/jom) on `PATH` OpenSSL's MSVC builds run in parallel.
