# this provides utilities to build external projects, either non-cmake or cmake
# that cannot be included via add subdirectory.

# This is mostly centered around FetchContent, but the actual builds are run and
# installed at compile time. This allows the cmake project to call find-package
# to include them as normal. It also allows full control over the build pipeline
# and artifacts.

# build and compile
function(cmt_externalbuild_cmake NAME)
    include(ProcessorCount)

    set(multiValueArgs CONFIGURATION_ARGS)
    cmake_parse_arguments("CMTFCN"
        ""
        ""
        "${multiValueArgs}"
        ${ARGN})

    message(DEBUG "cmt_externalbuild cmake build with config args: [${CMTFCN_CONFIGURATION_ARGS}]")

    string(TOLOWER ${NAME} NAME_LOWERCASE)
    FetchContent_Populate(${NAME})

    if(${NAME_LOWERCASE}_POPULATED)
        message(DEBUG "cmt_externalbuild of $NAME cmake build with config args: [${CMTFCN_CONFIGURATION_ARGS}]")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -S ${${NAME_LOWERCASE}_SOURCE_DIR} -B ${${NAME_LOWERCASE}_BINARY_DIR} ${CMTFCN_CONFIGURATION_ARGS}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        ProcessorCount(NCores)
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build ${${NAME_LOWERCASE}_BINARY_DIR} -j ${NCores}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} --install ${${NAME_LOWERCASE}_BINARY_DIR}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
    else()
        message(FATAL_ERROR "The external build ${NAME} Is not populated.")
    endif()
endfunction()
