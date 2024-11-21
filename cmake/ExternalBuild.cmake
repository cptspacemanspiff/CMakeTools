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
        "BUILD_CONFIG"
        "${multiValueArgs}"
        ${ARGN})

    message(DEBUG "cmt_externalbuild ${NAME}: CMAKE build with config args: [${CMTFCN_CONFIGURATION_ARGS}]")

    string(TOLOWER ${NAME} NAME_LOWERCASE)
    FetchContent_Populate(${NAME}) #Deprecated....
    # FetchContent_MakeAvailable(${NAME}) # cannot use because it automatically adds the subdirectory to the project...

    if(NOT DEFINED CMTFCN_BUILD_CONFIG)
        set(CMTFCN_BUILD_CONFIG "Release")
    endif()

    set(CMTFCN_EXTRA_CONFIGURE_ARGS "")
    set(CMTFCN_EXTRA_BUILD_ARGS "")
    set(CMTFCN_EXTRA_INSTALL_ARGS "")

    get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(NOT ${IS_MULTI_CONFIG})
        message(DEBUG "cmt_externalbuild ${NAME}: Not using MultiConfig Generator")
        set(CMTFCN_EXTRA_CONFIGURE_ARGS "-DCMAKE_BUILD_TYPE=${CMTFCN_BUILD_CONFIG}")
    else()
        message(DEBUG "cmt_externalbuild ${NAME}: Using MultiConfig Generator")
        set(CMTFCN_EXTRA_BUILD_ARGS "--config;${CMTFCN_BUILD_CONFIG}")
        set(CMTFCN_EXTRA_INSTALL_ARGS "--config;${CMTFCN_BUILD_CONFIG}")
    endif()

    if(${NAME_LOWERCASE}_POPULATED)
        message(DEBUG "cmt_externalbuild of $NAME cmake build with config args: [${CMTFCN_CONFIGURATION_ARGS}]")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
            -S ${${NAME_LOWERCASE}_SOURCE_DIR}
            -B ${${NAME_LOWERCASE}_BINARY_DIR}
            -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
            ${CMTFCN_EXTRA_CONFIGURE_ARGS}
            ${CMTFCN_CONFIGURATION_ARGS}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        ProcessorCount(NCores)
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build ${${NAME_LOWERCASE}_BINARY_DIR} 
            -j ${NCores} 
            ${CMTFCN_EXTRA_BUILD_ARGS}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} --install ${${NAME_LOWERCASE}_BINARY_DIR}
            ${CMTFCN_EXTRA_INSTALL_ARGS}
            WORKING_DIRECTORY ${${NAME_LOWERCASE}_BINARY_DIR}
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
    else()
        message(FATAL_ERROR "The external build ${NAME} Is not populated.")
    endif()
endfunction()
