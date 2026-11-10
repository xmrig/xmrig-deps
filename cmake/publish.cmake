# Replaces DEST/include and DEST/lib with what was built into STAGE. Only the headers and the
# libraries with their PDBs, not the pkg-config and CMake files that the builds also install.

file(GLOB libs ${STAGE}/lib/*.a ${STAGE}/lib/*.lib ${STAGE}/lib/*.pdb)

file(REMOVE_RECURSE ${DEST}/include ${DEST}/lib)
file(MAKE_DIRECTORY ${DEST}/lib)
file(COPY ${STAGE}/include DESTINATION ${DEST})
file(COPY ${libs} DESTINATION ${DEST}/lib)

message(STATUS "Updated ${DEST}")
