# Included into libuv's own project. The objects record the name of their PDB, so the file must have
# this name when it is compiled, not only when it is copied: libuv.pdb, as the "lib" prefix that libuv
# sets on the target applies to it as well.

cmake_language(DEFER CALL set_target_properties uv_a PROPERTIES
    COMPILE_PDB_NAME uv
    COMPILE_PDB_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib
)
