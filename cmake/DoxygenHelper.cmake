# sets up the doxygen documentation build.
function(cmt_doxygen_helper)
    cmake_parse_arguments("CMTFCN"
        ""
        "PROJECT_BRIEF"
        "DIRECTORIES;TARGETS"
        "${ARGN}")

    find_package(Doxygen COMPONENTS dot)

    # We need to get passed in a list of directories to add:
    if(NOT CMTFCN_DIRECTORIES AND NOT CMTFCN_TARGETS)
        message(FATAL_ERROR "cmt_doxygen_helper requires a list of directories and/or targets to add")
    endif()

    # generate a list of files from targets to add to build sources:
    foreach(TARGET ${CMTFCN_TARGETS})
        if(NOT TARGET ${TARGET})
            message(FATAL_ERROR "Target ${TARGET} does not exist")
        endif()

        cmt_get_target_sources_realpath(target_sources TARGET ${TARGET})
        message(DEBUG "target_sources: ${target_sources}")

        # get the public filesets of the target.
        get_target_property(target_public_filesets ${TARGET} HEADER_SET_cmt_public_headers)
        message(DEBUG "target_public_filesets: ${target_public_filesets}")

        get_target_property(target_interface_filesets ${TARGET} HEADER_SET_cmt_interface_headers)
        message(DEBUG "target_interface_filesets: ${target_interface_filesets}")

        # get the private filesets of the target.
        get_target_property(target_private_filesets ${TARGET} HEADER_SET_cmt_private_headers)
        message(DEBUG "target_private_filesets: ${target_private_filesets}")

        # # combine files and sources into a single list:
        if(target_sources)
            list(APPEND TARGET_DEPENDENCY_LIST ${target_sources})
        endif()

        if(target_public_filesets)
            list(APPEND TARGET_DEPENDENCY_LIST ${target_public_filesets})
        endif()

        if(target_interface_filesets)
            list(APPEND TARGET_DEPENDENCY_LIST ${target_interface_filesets})
        endif()

        if(target_private_filesets)
            list(APPEND TARGET_DEPENDENCY_LIST ${target_private_filesets})
        endif()
    endforeach()

    if(DOXYGEN_FOUND AND TARGET Doxygen::dot)
        set(DOXYGEN_AWESOME_CSS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/doxygen-awesome-css)
        set(USE_AWESOME_DOXYGEN_THEME ON)

        if(USE_AWESOME_DOXYGEN_THEME)
            set(DOXYGEN_HTML_HEADER ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-custom/header.html)
            set(DOXYGEN_HTML_EXTRA_STYLESHEET
                "${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome.css \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-sidebar-only.css \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css ") # \\

            # ${DOXYGEN_AWESOME_CSS_DIR}/custom-alternative.css")
            set(DOXYGEN_HTML_EXTRA_FILES
                "${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-darkmode-toggle.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-fragment-copy-button.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-paragraph-link.js \\    
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-interactive-toc.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-tabs.js")
        endif()

        # get the dogygen dot path:
        get_target_property(DOXYGEN_DOT_EXECUTABLE Doxygen::dot IMPORTED_LOCATION)
        message(DEBUG "DOXYGEN_DOT_EXECUTABLE: ${DOXYGEN_DOT_EXECUTABLE}")

        # see if we have plantuml jar, if plantuml jar is found, set the jar path in doxygen file:
        find_program(PLANTUML plantuml)

        if(NOT ${PLANTUML} STREQUAL "PLANTUML-NOTFOUND")
            set(DOXYGEN_PLANTUML_EXE_PATH ${PLANTUML})
            message(DEBUG "Plantuml found: ${DOXYGEN_PLANTUML_EXE_PATH}")
            
            # Check if linux:
            if(UNIX AND NOT APPLE)
                execute_process(COMMAND "bash" "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/get_plantuml_jar_path.sh" "${DOXYGEN_PLANTUML_EXE_PATH}"
                    OUTPUT_VARIABLE DOXYGEN_PLANTUML_JAR_PATH
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    COMMAND_ECHO NONE)
                message(STATUS "Plantumljar found: ${DOXYGEN_PLANTUML_JAR_PATH}")
            else()
                message(WARNING "Plantuml found, but do not currently know how to parse out the jar path on non unix systems.")
            endif()

            # parse the file to find the plantuml jar path:
        endif()

        set(DOXYGEN_PROJECT_BRIEF "${CMTFCN_PROJECT_BRIEF}")

        # replace semicolon in list with new line:
        string(REPLACE ";" " " DOXYGEN_SOURCES "${TARGET_DEPENDENCY_LIST};${CMTFCN_DIRECTORIES}")

        # set the output directory:
        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doc/${PROJECT_NAME}")

        # create the directory if it does not exist:
        file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY})

        set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
        set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

        configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

        set(DIRECTORY_DEPENDENCY_LIST "")

        foreach(PATH ${CMTFCN_DIRECTORIES})
            # if it is a directory, glob it and add all files to dependency list:
            if(IS_DIRECTORY ${PATH})
                file(GLOB_RECURSE TMP_PATHS CONFIGURE_DEPENDS ${PATH}/*)
            endif()

            list(APPEND DIRECTORY_DEPENDENCY_LIST ${TMP_PATHS})
        endforeach()

        message(DEBUG "Target Dependency List: ${TARGET_DEPENDENCY_LIST}")
        message(DEBUG "Directory Dependency List: ${CMTFCN_DIRECTORIES}")

        add_custom_command(OUTPUT "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html"
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen"
            DEPENDS
            "${TARGET_DEPENDENCY_LIST}"
            "${DIRECTORY_DEPENDENCY_LIST}"
            "${CMAKE_CURRENT_FUNCTION_LIST_FILE}"
            "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile"
            VERBATIM
        )

        add_custom_target(${PROJECT_NAME}_doc_doxygen ALL SOURCES "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")

    # install(DIRECTORY ${CMTFCN_DIRECTORIES} DESTINATION doc)
    else()
        message(WARNING "Doxygen need to be installed to generate the doxygen documentation")
    endif()
endfunction()
