# Top level CMake helper file that provides a single include option.

# Top level project command that passes standard arguements to config, and does basic setup.
cmake_minimum_required(VERSION 3.24)

macro(cmt_project_setup)
    cmake_parse_arguments("CMT_PROJECT_SETUP" "" "" "" "${ARGN}")

    message(DEBUG "Configuring project ${CMT_PROJECT_UNPARSED_ARGUMENTS}")

    # see profesional CMake 15th edition, page 578: https://crascit.com/professional-cmake/
    set(stageDir ${CMAKE_BINARY_DIR}/stage)
    include(GNUInstallDirs)

    if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_BINDIR})
    endif()

    if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
    endif()

    if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
    endif()
endmacro()

function(cmt_target_setup target_name)
    cmake_parse_arguments("CMTFCN" "" "NAMESPACE;EXPORT_NAME" "" "${ARGN}")

    if(NOT DEFINED CMTFCN_NAMESPACE)
        message(FATAL_ERROR "cmt_target_setup requires a namespace")
    endif()

    if(NOT DEFINED CMTFCN_EXPORT_NAME)
        message(FATAL_ERROR "cmt_target_setup requires an export name")
    endif()

    # setup common library tasks: soname,
    set_target_properties(${target_name} PROPERTIES
        EXPORT_NAME ${CMTFCN_EXPORT_NAME}
        CMT_NAMESPACE ${CMTFCN_NAMESPACE}
    )
endfunction()

function(cmt_add_library target_name)
    cmake_parse_arguments("CMTFCN" "NAMESPACED" "EXPORT_NAME" "" "${ARGN}")

    set(CMT_NAMESPACE ${PROJECT_NAME})

    if(DEFINED CMTFCN_EXPORT_NAME)
        set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
    else()
        set(CMT_TARGET_EXPORT_NAME ${target_name})
    endif()

    if(${CMTFCN_NAMESPACED})
        set(CMT_TARGET_NAME "${CMT_NAMESPACE}_${target_name}")
        message(DEBUG "Creating namespaced executable: ${CMT_TARGET_NAME}")
    else()
        set(CMT_TARGET_NAME "${target_name}")
        message(DEBUG "Creating non-namespaced executable: ${CMT_TARGET_NAME}")
    endif()

    message(DEBUG "Adding executable '${CMT_TARGET_NAME}' with args ${CMTFCN_UNPARSED_ARGUMENTS}")
    add_library(${CMT_TARGET_NAME} ${CMTFCN_UNPARSED_ARGUMENTS})
    add_library(${CMT_NAMESPACE}::${CMT_TARGET_EXPORT_NAME} ALIAS ${CMT_TARGET_NAME})

    set_target_properties(${CMT_TARGET_NAME} PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR})

    cmt_target_setup(${CMT_TARGET_NAME}
        NAMESPACE ${CMT_NAMESPACE}
        EXPORT_NAME ${CMT_TARGET_NAME})
endfunction()

function(cmt_add_executable target_name)
    cmake_parse_arguments("CMTFCN" "NAMESPACED" "EXPORT_NAME" "" "${ARGN}")

    set(CMT_NAMESPACE ${PROJECT_NAME})

    if(DEFINED CMTFCN_EXPORT_NAME)
        set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
    else()
        set(CMT_TARGET_EXPORT_NAME ${target_name})
    endif()

    if(${CMTFCN_NAMESPACED})
        set(CMT_TARGET_NAME "${CMT_NAMESPACE}_${target_name}")
        message(DEBUG "Creating namespaced executable: ${CMT_TARGET_NAME}")
    else()
        set(CMT_TARGET_NAME "${target_name}")
        message(DEBUG "Creating non-namespaced executable: ${CMT_TARGET_NAME}")
    endif()

    message(DEBUG "Adding executable '${CMT_TARGET_NAME}' with args ${CMTFCN_UNPARSED_ARGUMENTS}")
    add_executable(${CMT_TARGET_NAME} ${CMTFCN_UNPARSED_ARGUMENTS})
    add_executable(${CMT_NAMESPACE}::${CMT_TARGET_EXPORT_NAME} ALIAS ${CMT_TARGET_NAME})

    cmt_target_setup(${CMT_TARGET_NAME}
        NAMESPACE ${CMT_NAMESPACE}
        EXPORT_NAME ${CMT_TARGET_NAME})
endfunction()