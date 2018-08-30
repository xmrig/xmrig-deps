# XMRig dependencies
[![Github All Releases](https://img.shields.io/github/downloads/xmrig/xmrig-deps/total.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub release](https://img.shields.io/github/release/xmrig/xmrig-deps/all.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date-pre/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/releases)
[![GitHub license](https://img.shields.io/github/license/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/xmrig/xmrig-deps.svg)](https://github.com/xmrig/xmrig-deps/network)

This repository only contains a binary build of XMRig dependencies. 

* [libuv](https://github.com/libuv/libuv) 1.23.0
* [libmicrohttpd](https://www.gnu.org/software/libmicrohttpd) 0.9.59

Only **gcc/x86** with older lib versions supports Windows XP/2003.

## Usage
### Microsoft Visual Studio 2017

- x64 `cmake .. -G "Visual Studio 15 2017 Win64" -DXMRIG_DEPS=c:\xmrig-deps\msvc2017\x64`
- x86 `cmake .. -G "Visual Studio 15 2017" -DXMRIG_DEPS=c:\xmrig-deps\msvc2017\x86`

### Microsoft Visual Studio 2015

- x64 `cmake .. -G "Visual Studio 14 2015 Win64" -DXMRIG_DEPS=c:\xmrig-deps\msvc2015\x64`
- x86 `cmake .. -G "Visual Studio 14 2015" -DXMRIG_DEPS=c:\xmrig-deps\msvc2015\x86`

### MSYS2

- x64 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x64`
- x86 `"c:\Program Files\CMake\bin\cmake.exe" .. -G "Unix Makefiles" -DXMRIG_DEPS=c:/xmrig-deps/gcc/x86`
