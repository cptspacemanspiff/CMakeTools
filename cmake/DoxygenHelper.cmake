# sets up the doxygen documentation build.
function(doxygen_helper)
    cmake_parse_arguments("CMTFCN"
        ""
        "PROJECT_NAME"
        "DIRECTORIES"
        "${ARGN}")

    find_package(Doxygen)

    if(DOXYGEN_FOUND)
        set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
        set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

        configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

        message("Doxygen build started")

        add_custom_target(${CMTFCN_PROJECT_NAME}_doc_doxygen ALL
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM)

        # install(DIRECTORY ${CMTFCN_DIRECTORIES} DESTINATION doc)
    else()
        message(WARNING "Doxygen need to be installed to generate the doxygen documentation")
    endif()
endfunction(doxygen_helper)
