# This gets the version of the current project and generates a version file that
# can be compiled inside the c++ code. It also compiles in the current git hash
# so that we can track down the exact version of the code that was used to
# generate the data.

function(cmt_target_set_version target)
    find_package(Git)

    # only works in git repo:
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE TMP_GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Failed to get git hash: ${result}")
    endif()

    # Get the version from the project:\
    set(TMP_VERSION "${PROJECT_VERSION}")
    set(TMP_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
    set(TMP_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
    set(TMP_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
    set(TMP_VERSION_TWEAK "${PROJECT_VERSION_TWEAK}")

    # check if file separate version file exists:
    if(EXISTS ${PROJECT_SOURCE_DIR}/projectVersionDetails.cmake)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-list -1 HEAD ${PROJECT_SOURCE_DIR}/projectVersionDetails.cmake
            RESULT_VARIABLE result
            OUTPUT_VARIABLE lastChangeHash
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(result)
            message(FATAL_ERROR "Failed to get hash of last change: ${result}")
        endif()

        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-list ${lastChangeHash}..HEAD
            RESULT_VARIABLE result
            OUTPUT_VARIABLE hashList
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(result)
            message(FATAL_ERROR "Failed to get list of git hashes: ${result}")
        endif()

        string(REGEX REPLACE "[\n\r]+" ";" hashList "${hashList}")
        list(LENGTH hashList TMP_COMMITS_SINCE_VERSION_CHANGE)
    else()
        set(TMP_COMMITS_SINCE_VERSION_CHANGE "-1")
    endif()

    message(DEBUG "${PROJECT_NAME} VERSION: ${TMP_VERSION}")
    message(DEBUG "${PROJECT_NAME} VERSION_MAJOR: ${TMP_VERSION_MAJOR}")
    message(DEBUG "${PROJECT_NAME} VERSION_MINOR: ${TMP_VERSION_MINOR}")
    message(DEBUG "${PROJECT_NAME} VERSION_PATCH: ${TMP_VERSION_PATCH}")
    message(DEBUG "${PROJECT_NAME} VERSION_TWEAK: ${TMP_VERSION_TWEAK}")
    message(DEBUG "${PROJECT_NAME} GIT_HASH: ${TMP_GIT_HASH}")
    message(DEBUG "${PROJECT_NAME} COMMITS_SINCE_VERSION_CHANGE: ${TMP_COMMITS_SINCE_VERSION_CHANGE}")

    # If the tweak version is not set, set it to 0:
    if(NOT TMP_VERSION_TWEAK)
        set(TMP_VERSION_TWEAK "0")
    endif()

    # Add these version info to the target:
    set_target_properties(${target} PROPERTIES
        VERSION ${TMP_VERSION}
        CMT_VERSION_MAJOR ${TMP_VERSION_MAJOR}
        CMT_VERSION_MINOR ${TMP_VERSION_MINOR}
        CMT_VERSION_PATCH ${TMP_VERSION_PATCH}
        CMT_VERSION_TWEAK ${TMP_VERSION_TWEAK}
        CMT_GIT_HASH ${TMP_GIT_HASH}
        CMT_COMMITS_SINCE_VERSION_CHANGE ${TMP_COMMITS_SINCE_VERSION_CHANGE}
    )
endfunction()

function(cmt_generate_version_api target)
    cmake_parse_arguments("CMTFCN"
        ""
        "NAMESPACE_NAME;FUNCTION_PREFIX;CXX_NAMESPACE"
        ""
        "${ARGN}")

    if(NOT CMTFCN_NAMESPACE_NAME)
        get_target_property(CMT_NAMESPACE ${target} CMT_NAMESPACE)
        message(DEBUG "No namespace name given, using target namespace name: ${VERSIONFILE_NAMESPACE_NAME}")
    else()
        set(CMT_NAMESPACE ${CMTFCN_NAMESPACE_NAME})
    endif()

    if(NOT CMTFCN_FUNCTION_PREFIX)
        get_target_property(CMT_EXPORT_NAME ${target} CMT_EXPORT_NAME)
        message(DEBUG "No function prefix given, using target export_name: ${VERSIONFILE_FUNCTION_PREFIX}")
    else()
        set(CMT_EXPORT_NAME ${CMTFCN_FUNCTION_PREFIX})
    endif()

    if(NOT CMTFCN_CXX_NAMESPACE)
        set(CMT_CXX_NAMESPACE ${CMT_NAMESPACE})
    else()
        set(CMT_CXX_NAMESPACE ${CMTFCN_CXX_NAMESPACE})
    endif()
    
    # get version info from target:
    get_target_property(CMT_VERSION ${target} VERSION)
    get_target_property(CMT_VERSION_MAJOR ${target} CMT_VERSION_MAJOR)
    get_target_property(CMT_VERSION_MINOR ${target} CMT_VERSION_MINOR)
    get_target_property(CMT_VERSION_PATCH ${target} CMT_VERSION_PATCH)
    get_target_property(CMT_VERSION_TWEAK ${target} CMT_VERSION_TWEAK)
    get_target_property(CMT_GIT_HASH ${target} CMT_GIT_HASH)
    get_target_property(CMT_COMMITS_SINCE_VERSION_CHANGE ${target} CMT_COMMITS_SINCE_VERSION_CHANGE)


    # if this is the first namespace of this name, create a header file:
    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/version.h.in
        ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_NAMESPACE}${CMT_EXPORT_NAME}_version.h
        @ONLY)

    # have to do this in 2 stages because of the way cmake replaces @ONLY variables:
    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/version.cpp.in
        ${CMAKE_CURRENT_BINARY_DIR}/tmp/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_NAMESPACE}${CMT_EXPORT_NAME}_version.cpp.in
        @ONLY)
    configure_file(
        ${CMAKE_CURRENT_BINARY_DIR}/tmp/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_NAMESPACE}${CMT_EXPORT_NAME}_version.cpp.in
        ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_NAMESPACE}${CMT_EXPORT_NAME}_version.cpp
        @ONLY)
endfunction()