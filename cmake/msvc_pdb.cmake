# Included into the project of a dependency that CMake builds with MSVC (CMAKE_PROJECT_<name>_INCLUDE):
# the PDB that the compiler writes for the library XMRIG_PDB_TARGET goes next to the installed library,
# named XMRIG_PDB_NAME with the prefix of the target. The objects record the name of their PDB, so the
# file must have this name when it is compiled, not only when it is copied.

cmake_language(DEFER CALL set_target_properties ${XMRIG_PDB_TARGET} PROPERTIES
    COMPILE_PDB_NAME ${XMRIG_PDB_NAME}
    COMPILE_PDB_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib
)
