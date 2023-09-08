# sets up the doxygen documentation build.
function(cmt_doxygen_helper)
    cmake_parse_arguments("CMTFCN"
        ""
        "PROJECT_BRIEF"
        "DIRECTORIES"
        "${ARGN}")

    find_package(Doxygen)

    # We need to get passed in a list of directories to add:
    if(NOT CMTFCN_DIRECTORIES)
        message(FATAL_ERROR "cmt_doxygen_helper requires a list of directories to add")
    endif()

    if(DOXYGEN_FOUND)
        set(DOXYGEN_AWESOME_CSS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/doxygen-awesome-css)
        set(USE_AWESOME_DOXYGEN_THEME ON)

        if(USE_AWESOME_DOXYGEN_THEME)
            set(DOXYGEN_HTML_HEADER ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-custom/header.html)
            set(DOXYGEN_HTML_EXTRA_STYLESHEET
                "${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome.css \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-sidebar-only.css \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css \\
            ${DOXYGEN_AWESOME_CSS_DIR}/custom-alternative.css")

            set(DOXYGEN_HTML_EXTRA_FILES
                "${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-darkmode-toggle.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-fragment-copy-button.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-paragraph-link.js \\    
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-interactive-toc.js \\
            ${DOXYGEN_AWESOME_CSS_DIR}/doxygen-awesome-tabs.js")
        endif()

        # see if we have plantuml jar, if plantuml jar is found, set the jar path in doxygen file:
        find_program(PLANTUML plantuml)

        if(NOT ${PLANTUML} STREQUAL "PLANTUML-NOTFOUND")
            set(DOXYGEN_PLANTUML_EXE_PATH ${PLANTUML})

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
        string(REPLACE ";" " " DOXYGEN_SOURCES "${CMTFCN_DIRECTORIES}")

        # set the output directory:
        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doc/${PROJECT_NAME}")

        # create the directory if it does not exist:
        file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY})

        set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
        set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

        configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

        add_custom_target(${PROJECT_NAME}_doc_doxygen ALL
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM)

    # install(DIRECTORY ${CMTFCN_DIRECTORIES} DESTINATION doc)
    else()
        message(WARNING "Doxygen need to be installed to generate the doxygen documentation")
    endif()
endfunction()
