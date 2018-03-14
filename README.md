# XMRig dependencies
This repository only contains a binary build of XMRig dependencies. 

* [libuv](https://github.com/libuv/libuv) 1.19.2
* [libuv](https://github.com/libuv/libuv) 1.15.0 (gcc/x86) for Windows XP/2003.
* [libmicrohttpd](https://www.gnu.org/software/libmicrohttpd) 0.9.58

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
