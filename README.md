# XMRig dependencies
[![Github All Releases](https://img.shields.io/github/downloads/xmrig/xmrig-deps/total.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub release](https://img.shields.io/github/release/xmrig/xmrig-deps/all.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date-pre/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub license](https://img.shields.io/github/license/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/network)

This repository only contains a binary build of XMRig dependencies. 

* [libuv](https://github.com/libuv/libuv) 1.49.2
* [OpenSSL](https://www.openssl.org) 3.0.15
* [hwloc](https://www.open-mpi.org/projects/hwloc) 2.11.2

## Usage
### Microsoft Visual Studio 2022
- x64 `cmake .. -G "Visual Studio 17 2022" -A x64 -DXMRIG_DEPS=c:\xmrig-deps\msvc2019\x64`

### Microsoft Visual Studio 2019
- x64 `cmake .. -G "Visual Studio 16 2019" -A x64 -DXMRIG_DEPS=c:\xmrig-deps\msvc2019\x64`

### MSYS2

- x64 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x64`
- x86 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x86`
