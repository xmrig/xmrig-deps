# Builds the dependencies of each target with its toolchain and updates its directory:
#
#   cmake -P cmake/update.cmake
#   cmake "-DTARGETS=gcc/x64;msvc2026/x64" -P cmake/update.cmake
#
# Without TARGETS it builds every target whose toolchain is on this machine and skips the others; a
# target named in TARGETS must have one. find_msys2() below says how MSYS2 is found. Each target starts
# from a clean directory under build/, only the downloads are kept.

cmake_minimum_required(VERSION 3.25)

get_filename_component(repo ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)

set(all_targets clang/arm64 gcc/x64 msvc2026/arm64 msvc2026/x64)

if (DEFINED TARGETS)
    set(targets_required ON)
else()
    set(targets_required OFF)
    set(TARGETS ${all_targets})
endif()

foreach (target IN LISTS TARGETS)
    if (NOT target IN_LIST all_targets)
        message(FATAL_ERROR "Unknown target ${target}; the targets are: ${all_targets}")
    endif()
endforeach()

# The directory of MSYS2, wherever it is installed: MSYS2_ROOT when given, with -D or in the environment;
# otherwise the one of pacman when that is on PATH, as in a shell of MSYS2; otherwise where the installer
# of MSYS2 recorded it.
function(find_msys2)
    if (NOT MSYS2_ROOT AND DEFINED ENV{MSYS2_ROOT})
        set(MSYS2_ROOT "$ENV{MSYS2_ROOT}")
    endif()

    if (MSYS2_ROOT)
        file(TO_CMAKE_PATH "${MSYS2_ROOT}" root)
        set(MSYS2_ROOT "${root}" PARENT_SCOPE)
        return()
    endif()

    find_program(pacman NAMES pacman NO_CACHE)
    set(candidates "${pacman}/../../..")

    foreach (hive IN ITEMS HKCU HKLM)
        set(uninstall "${hive}/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall")
        cmake_host_system_information(RESULT keys QUERY WINDOWS_REGISTRY "${uninstall}" SUBKEYS ERROR_VARIABLE ignored)

        foreach (key IN LISTS keys)
            cmake_host_system_information(RESULT name QUERY WINDOWS_REGISTRY "${uninstall}/${key}" VALUE DisplayName ERROR_VARIABLE ignored)

            if (name MATCHES "^MSYS2")
                cmake_host_system_information(RESULT location QUERY WINDOWS_REGISTRY "${uninstall}/${key}" VALUE InstallLocation ERROR_VARIABLE ignored)
                list(APPEND candidates "${location}")
            endif()
        endforeach()
    endforeach()

    # What pacman is on PATH may be a shim, and an uninstall entry may be left over from a removed MSYS2.
    foreach (candidate IN LISTS candidates)
        file(TO_CMAKE_PATH "${candidate}" candidate)
        get_filename_component(candidate "${candidate}" ABSOLUTE)

        if (EXISTS "${candidate}/msys2_shell.cmd")
            set(MSYS2_ROOT "${candidate}" PARENT_SCOPE)
            return()
        endif()
    endforeach()
endfunction()

find_msys2()

set(built)
set(skipped)

macro(toolchain_missing target reason)
    if (targets_required)
        message(FATAL_ERROR "${target}: ${reason}")
    endif()

    message(STATUS "${target}: skipped, ${reason}")
    list(APPEND skipped ${target})
endmacro()

# The arguments of the two cmake commands that build a target from a clean directory. build_root is
# build/ of the repository, or a drive letter mapped to it.
macro(prepare_target target compiler build_root)
    file(REMOVE_RECURSE ${repo}/build/${target})
    file(MAKE_DIRECTORY ${repo}/build)

    set(build_dir ${build_root}/${target})
    set(configure_args -S ${repo} -B ${build_dir} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=${compiler}
        -DXMRIG_DEPS_TARGET=${target} -DXMRIG_DEPS_DOWNLOADS=${build_root}/downloads)
    set(build_args --build ${build_dir})

    message(STATUS "${target}: building")
endmacro()

# A target of MSYS2, in the environment that its ucrt64.exe or clangarm64.exe gives a shell. Only that
# environment is on PATH, for another GCC, Perl or Ninja on the machine not to be found first.
function(build_msys2 target environment subdir compiler)
    if (NOT MSYS2_ROOT)
        toolchain_missing(${target} "MSYS2 not found, set MSYS2_ROOT")
        set(skipped ${skipped} PARENT_SCOPE)
        return()
    endif()

    if (NOT EXISTS ${MSYS2_ROOT}/${subdir}/bin/${compiler}.exe)
        toolchain_missing(${target} "${MSYS2_ROOT}/${subdir}/bin/${compiler}.exe not found")
        set(skipped ${skipped} PARENT_SCOPE)
        return()
    endif()

    prepare_target(${target} ${MSYS2_ROOT}/${subdir}/bin/${compiler}.exe ${repo}/build)

    file(TO_NATIVE_PATH "${MSYS2_ROOT}/${subdir}/bin" bin_dir)
    file(TO_NATIVE_PATH "${MSYS2_ROOT}/usr/bin" usr_dir)
    set(env ${CMAKE_COMMAND} -E env "PATH=${bin_dir}\;${usr_dir}\;$ENV{SystemRoot}\\System32" MSYSTEM=${environment})

    execute_process(COMMAND ${env} ${CMAKE_COMMAND} ${configure_args} COMMAND_ERROR_IS_FATAL ANY)
    execute_process(COMMAND ${env} ${CMAKE_COMMAND} ${build_args} COMMAND_ERROR_IS_FATAL ANY)

    set(built ${built} ${target} PARENT_SCOPE)
endfunction()

# A drive letter that is not in use.
function(find_free_drive result)
    foreach (letter IN ITEMS B Z Y X W V U T S R Q P O N M L K J I H G F E D)
        if (NOT EXISTS "${letter}:/")
            set(${result} "${letter}:" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    message(FATAL_ERROR "No free drive letter for the MSVC builds")
endfunction()

# A target of Visual Studio, in the environment of its vcvarsall.bat.
function(build_msvc target vs_range arch component)
    set(program_files "ProgramFiles(x86)")
    set(vswhere "$ENV{${program_files}}/Microsoft Visual Studio/Installer/vswhere.exe")
    set(vs_dir)

    if (EXISTS "${vswhere}")
        execute_process(
            COMMAND "${vswhere}" -version ${vs_range} -products * -latest -requires ${component} -property installationPath
            OUTPUT_VARIABLE vs_dir
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()

    if (NOT vs_dir)
        toolchain_missing(${target} "no Visual Studio ${vs_range} with ${component}")
        set(skipped ${skipped} PARENT_SCOPE)
        return()
    endif()

    if ("$ENV{PROCESSOR_ARCHITECTURE}" STREQUAL "ARM64")
        set(host arm64)
    else()
        set(host amd64)
    endif()

    if (host STREQUAL arch)
        set(vcvars_arch ${arch})
    else()
        set(vcvars_arch ${host}_${arch})
    endif()

    # MSVC records the directories of a build in its libraries: in each object, in __FILE__ of the headers
    # and in the debug information. Built through a drive letter of their own, they tell nothing.
    find_free_drive(drive)
    prepare_target(${target} cl ${drive})

    # A batch file: the environment vcvarsall.bat sets exists only inside the cmd that ran it.
    file(TO_NATIVE_PATH "${vs_dir}/VC/Auxiliary/Build/vcvarsall.bat" vcvarsall)
    file(TO_NATIVE_PATH "${CMAKE_COMMAND}" cmake_exe)
    file(TO_NATIVE_PATH "${repo}/build" mapped_dir)
    list(JOIN configure_args "\" \"" configure_line)
    list(JOIN build_args "\" \"" build_line)

    # The build in a subroutine, for the drive letter to go also when it fails.
    set(script ${repo}/build/${target}.bat)
    file(WRITE ${script}
        "@echo off\n"
        "subst ${drive} \"${mapped_dir}\" || exit /b 1\n"
        "call :build\n"
        "set result=%errorlevel%\n"
        "subst ${drive} /d\n"
        "exit /b %result%\n"
        "\n"
        ":build\n"
        "call \"${vcvarsall}\" ${vcvars_arch} || exit /b 1\n"
        "\"${cmake_exe}\" \"${configure_line}\" || exit /b 1\n"
        "\"${cmake_exe}\" \"${build_line}\" || exit /b 1\n"
        "exit /b 0\n"
    )

    file(TO_NATIVE_PATH ${script} bat)
    execute_process(COMMAND cmd /c ${bat} COMMAND_ERROR_IS_FATAL ANY)

    set(built ${built} ${target} PARENT_SCOPE)
endfunction()

foreach (target IN LISTS TARGETS)
    if (target STREQUAL "clang/arm64")
        build_msys2(${target} CLANGARM64 clangarm64 clang)
    elseif (target STREQUAL "gcc/x64")
        build_msys2(${target} UCRT64 ucrt64 gcc)
    elseif (target STREQUAL "msvc2026/arm64")
        build_msvc(${target} "[18.0,19.0)" arm64 Microsoft.VisualStudio.Component.VC.Tools.ARM64)
    elseif (target STREQUAL "msvc2026/x64")
        build_msvc(${target} "[18.0,19.0)" amd64 Microsoft.VisualStudio.Component.VC.Tools.x86.x64)
    endif()
endforeach()

message(STATUS "Updated: ${built}")

if (skipped)
    message(STATUS "Skipped: ${skipped}")
endif()
