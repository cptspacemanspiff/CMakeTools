# Helper scripts to automatically download hugging face models:

function(cmt_resource_download_hf OUTPUT_DIRECTORY)
    cmake_parse_arguments("CMTFCN"
        ""
        "REPOSITORY"
        "FILES"
        "${ARGN}")

    if(NOT DEFINED CMTFCN_REPOSITORY)
        message(FATAL_ERROR "cmt_resource_download_hf requires a REPOSITORY")
    endif()

    find_program(HUGGINGFACE_CLI huggingface-cli REQUIRED)

    set(${OUTPUT_DIRECTORY} "${CMAKE_BINARY_DIR}/_resources/huggingface/${CMTFCN_REPOSITORY}")
    set(${OUTPUT_DIRECTORY} ${${OUTPUT_DIRECTORY}} PARENT_SCOPE)

    # for the test programs download hugging face models and tokenizers:
    execute_process(
        COMMAND ${HUGGINGFACE_CLI} download ${CMTFCN_REPOSITORY} ${CMTFCN_FILES}
        COMMAND ${HUGGINGFACE_CLI} download ${CMTFCN_REPOSITORY} ${CMTFCN_FILES} --local-dir ${${OUTPUT_DIRECTORY}}
        COMMAND_ECHO STDOUT
        COMMAND_ERROR_IS_FATAL ANY
    )

    message("Downloaded huggingface file to: ${${OUTPUT_DIRECTORY}}")
endfunction()