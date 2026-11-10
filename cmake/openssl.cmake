# OpenSSL as static libraries, built by its own Configure (Perl) and make.
#
# The build needs:
# - Perl; with MSVC a native Windows one, such as Strawberry Perl, not the Perl of MSYS2 or Git;
# - make, or with MSVC nmake, or jom when found, which builds in parallel;
# - NASM with MSVC on x64, for the assembler code.
#
# Only the libraries are built: no programs, tests, documentation, engines, loadable modules or legacy
# provider. The deprecated API stays, as XMRig uses it (TlsContext, TlsGen), and so does QUIC. With MSVC
# OpenSSL compiles its static libraries with /MT /Zl, without a reference to a C runtime, so one build
# serves the Debug and Release configurations and either runtime.

find_program(XMRIG_PERL NAMES perl REQUIRED)

# With MSVC OpenSSL doesn't work with the Perl of MSYS2 or Git.
if (MSVC)
    execute_process(COMMAND ${XMRIG_PERL} -e "print $^O" OUTPUT_VARIABLE perl_os ERROR_QUIET)
    if (NOT perl_os STREQUAL "MSWin32")
        message(FATAL_ERROR "xmrig-deps: OpenSSL's MSVC build needs a native Windows Perl such as Strawberry Perl, not ${XMRIG_PERL} (${perl_os})")
    endif()
endif()

set(openssl_options
    no-shared no-module no-dso no-pinshared no-apps no-tests no-docs no-makedepend
    no-legacy no-engine no-autoload-config no-ssl3 no-dtls no-srp no-comp
)

# What TLS doesn't use, for a smaller program, as OpenSSL's default provider links every algorithm it
# has: ciphers and hashes that TLS 1.2 and 1.3 don't negotiate, binary curves, DSA, the post-quantum
# signatures ML-DSA and SLH-DSA, and the parts for CMS, timestamps, certificate transparency, CMP,
# SRTP, RFC 3779, OpenSSL's HTTP client and console prompts. ML-KEM stays: the post-quantum key
# exchange that browsers and large servers negotiate. Without DES, keys and PKCS#12 files encrypted
# with 3DES can't be read.
list(APPEND openssl_options
    no-aria no-bf no-blake2 no-camellia no-cast no-des no-idea no-md4 no-mdc2 no-ocb no-rc2 no-rc4
    no-rmd160 no-seed no-siv no-sm2 no-sm3 no-sm4 no-whirlpool no-argon2 no-scrypt no-ec2m no-dsa
    no-gost no-ml-dsa no-slh-dsa no-cms no-ts no-ct no-cmp no-srtp no-rfc3779 no-http no-ui-console
    no-integrity-only-ciphers no-tls-deprecated-ec no-multiblock
)

if (openssl_target STREQUAL "mingwarm64")
    list(APPEND openssl_options --config=${CMAKE_CURRENT_LIST_DIR}/openssl_mingwarm64.conf)
endif()

# Each function in a section of its own, for the link to drop those that aren't used; MSVC's /Gy does so.
# Smaller code than OpenSSL's own optimization, the last flag of the compiler line being the one that
# counts; AES-GCM and ChaCha20-Poly1305, which run in assembler code, stay as fast.
if (MSVC)
    # Every file writes its debug information into one ossl_static.pdb, which jom does in parallel:
    # /FS lets cl share it.
    list(APPEND openssl_options /O1 /FS)
else()
    list(APPEND openssl_options -ffunction-sections -fdata-sections -O2)
endif()

# The compiler and archiver by name, all on PATH: OpenSSL records its compiler line in the library, where
# a full path would tell where the tools are installed. With MSVC cl is on PATH too, and a path with
# spaces breaks OpenSSL's makefile.
if (NOT MSVC)
    get_filename_component(openssl_compiler ${CMAKE_C_COMPILER} NAME_WE)
    get_filename_component(openssl_ar ${CMAKE_AR} NAME_WE)
    get_filename_component(openssl_ranlib ${CMAKE_RANLIB} NAME_WE)
    set(openssl_cc CC=${openssl_compiler} AR=${openssl_ar} RANLIB=${openssl_ranlib})
endif()

# Commands run with this: the build date that OpenSSL records in the library is a fixed one, and NASM is
# put on PATH for Configure, which looks for it there.
set(openssl_env ${CMAKE_COMMAND} -E env SOURCE_DATE_EPOCH=0)

if (openssl_target STREQUAL "VC-WIN64A")
    find_program(XMRIG_NASM NAMES nasm HINTS "$ENV{ProgramFiles}/NASM" "$ENV{LOCALAPPDATA}/bin/NASM" REQUIRED)
    get_filename_component(nasm_dir ${XMRIG_NASM} DIRECTORY)
    list(APPEND openssl_env --modify PATH=path_list_prepend:${nasm_dir})
endif()

if (MSVC)
    find_program(XMRIG_JOM NAMES jom)

    if (XMRIG_JOM)
        set(openssl_make ${XMRIG_JOM} /J ${jobs})
    else()
        set(openssl_make nmake)
    endif()
else()
    find_program(XMRIG_MAKE NAMES make REQUIRED)
    set(openssl_make ${XMRIG_MAKE} -j${jobs})
endif()

# Where OpenSSL looks for its configuration and, by default, for CA certificates: a place that users
# can't create at random, as an OpenSSL elsewhere would take what it finds there. The prefix too: the
# library records the directories of engines and modules under it, so only the install step names the
# real directory.
ExternalProject_Add(openssl
    URL                 https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz
    URL_HASH            SHA256=${OPENSSL_SHA256}
    DOWNLOAD_DIR        ${XMRIG_DEPS_DOWNLOADS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    DOWNLOAD_NO_PROGRESS ON
    PREFIX              ${CMAKE_BINARY_DIR}/openssl
    CONFIGURE_COMMAND   ${openssl_env} ${XMRIG_PERL} <SOURCE_DIR>/Configure ${openssl_target} ${openssl_options}
                        --prefix=C:/Windows/System32/OpenSSL --openssldir=C:/Windows/System32/OpenSSL --libdir=lib ${openssl_cc}
    BUILD_COMMAND       ${openssl_env} ${openssl_make} build_libs
    INSTALL_COMMAND     ${openssl_env} ${openssl_make} install_dev INSTALLTOP=${stage}
    LOG_CONFIGURE       ON
    LOG_BUILD           ON
    LOG_INSTALL         ON
    LOG_OUTPUT_ON_FAILURE ON
)
