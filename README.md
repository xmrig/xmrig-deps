# XMRig dependencies
[![Github All Releases](https://img.shields.io/github/downloads/xmrig/xmrig-deps/total.svg)](../../releases)
[![GitHub release](https://img.shields.io/github/release/xmrig/xmrig-deps/all.svg)](../../releases/latest)
[![GitHub Release Date](https://img.shields.io/github/release-date-pre/xmrig/xmrig-deps.svg)](../../releases/latest)
[![GitHub license](https://img.shields.io/github/license/xmrig/xmrig-deps.svg)](./LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/xmrig/xmrig-deps.svg)](../../stargazers)
[![GitHub forks](https://img.shields.io/github/forks/xmrig/xmrig-deps.svg)](../../network)

This repository only contains a binary build of [XMRig](../../../xmrig) dependencies. 

* [libuv](https://github.com/libuv/libuv) 1.42.0
* [OpenSSL](https://www.openssl.org) 1.1.1l
* [hwloc](https://www.open-mpi.org/projects/hwloc) 2.5.0

Only **gcc/x86** with older lib versions supports Windows XP/2003.

## Usage
### Microsoft Visual Studio 2019
- x64 `cmake .. -G "Visual Studio 16 2019" -A x64 -DXMRIG_DEPS=c:\xmrig-deps\msvc2019\x64`

### Microsoft Visual Studio 2017

- x64 `cmake .. -G "Visual Studio 15 2017 Win64" -DXMRIG_DEPS=c:\xmrig-deps\msvc2017\x64`
- x86 `cmake .. -G "Visual Studio 15 2017" -DXMRIG_DEPS=c:\xmrig-deps\msvc2017\x86`

### Microsoft Visual Studio 2015

- x64 `cmake .. -G "Visual Studio 14 2015 Win64" -DXMRIG_DEPS=c:\xmrig-deps\msvc2015\x64`
- x86 `cmake .. -G "Visual Studio 14 2015" -DXMRIG_DEPS=c:\xmrig-deps\msvc2015\x86`

### MSYS2

- x64 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x64`
- x86 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x86`
