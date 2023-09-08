# sets up the doxygen documentation build.
function(cmt_doxygen_helper)
    cmake_parse_arguments("CMTFCN"
        ""
        "PROJECT_BRIEF"
        "DIRECTORIES"
        "${ARGN}")

    find_package(Doxygen)

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
endfunction()
