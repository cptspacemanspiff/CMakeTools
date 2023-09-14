# Top level CMake helper file that provides a single include option.

# Top level project command that passes standard arguements to config, and does basic setup.
cmake_minimum_required(VERSION 3.24)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/BuildTypes.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/CoverageHelper.cmake)

macro(cmt_project_setup)
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

    # Explicitly set DOCDIR location each time, see profesional CMake 15th edition, page 411:
    set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME})

    if("${PROJECT_NAME}" STREQUAL "${CMAKE_PROJECT_NAME}")
        set(CMAKE_COLOR_DIAGNOSTICS ON CACHE BOOL "Use color in compiler diagnostics")

        cmt_configure_build_types()

        # set option to build documentation.
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

        option(BUILD_DOCUMENTATION "Build documentation" ON)
        option(BUILD_TESTS "Build tests" ON)

        if(${BUILD_TESTS})
            enable_testing()
        endif()

        option(BUILD_EXAMPLES "Build examples" ON)
    endif()

    if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/src)
        add_subdirectory(src)
    endif()

    if(BUILD_DOCUMENTATION AND EXISTS ${CMAKE_CURRENT_LIST_DIR}/doc)
        # Any dependecies are found in the actual documentation cmake file.
        add_subdirectory(doc)
    endif()

    if(BUILD_TESTS AND EXISTS ${CMAKE_CURRENT_LIST_DIR}/test)
        add_subdirectory(test)
    endif()

    if(BUILD_EXAMPLES AND EXISTS ${CMAKE_CURRENT_LIST_DIR}/examples)
        add_subdirectory(examples)
    endif()
endmacro()

function(cmt_target_setup target_name)
    cmake_parse_arguments("CMTFCN"
        ""
        "NAMESPACE;EXPORT_NAME;NO_COVERAGE"
        ""
        "${ARGN}")

    if(NOT DEFINED CMTFCN_NAMESPACE)
        message(FATAL_ERROR "cmt_target_setup requires a namespace")
    endif()

    if(NOT DEFINED CMTFCN_EXPORT_NAME)
        message(FATAL_ERROR "cmt_target_setup requires an export name")
    endif()

    # setup common library tasks: soname,
    set_target_properties(${target_name} PROPERTIES
        CMT_EXPORT_NAME ${CMTFCN_EXPORT_NAME}
        CMT_NAMESPACE ${CMTFCN_NAMESPACE}
        CMT_STANDARD_NAME "${CMTFCN_NAMESPACE}::${CMTFCN_EXPORT_NAME}"
    )

    # if this is the first namespace of this name, create a header file:
    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmake/version.h.in
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMTFCN_NAMESPACE}/${CMTFCN_NAMESPACE}_version.h
        @ONLY)

    # have to do this in 2 stages because of the way cmake replaces @ONLY variables:
    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmake/version.cpp.in
        ${PROJECT_BINARY_DIR}/tmp/${CMAKE_INSTALL_INCLUDEDIR}/${CMTFCN_NAMESPACE}/${CMTFCN_NAMESPACE}_version.cpp.in
        @ONLY)
    configure_file(
        ${PROJECT_BINARY_DIR}/tmp/${CMAKE_INSTALL_INCLUDEDIR}/${CMTFCN_NAMESPACE}/${CMTFCN_NAMESPACE}_version.cpp.in
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMTFCN_NAMESPACE}/${CMTFCN_NAMESPACE}_version.cpp
        @ONLY)

    # enable verbose warnings on targets
    target_compile_options(${target_name} PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic>
        $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wpedantic>
        $<$<CXX_COMPILER_ID:MSVC>:/W4>
    )

    if(NOT CMTFCN_NO_COVERAGE)
        # only add the coverage options on Coverage build type:
        target_compile_options(${target_name} PRIVATE
            $<$<CONFIG:Coverage>:
            $<$<CXX_COMPILER_ID:GNU>:--coverage>
            $<$<CXX_COMPILER_ID:Clang>:--coverage>
            $<$<CXX_COMPILER_ID:MSVC>:/PROFILE>
            >
        )

        target_link_options(${target_name} PRIVATE
            $<$<CONFIG:Coverage>:
            $<$<CXX_COMPILER_ID:GNU>:--coverage>
            $<$<CXX_COMPILER_ID:Clang>:--coverage>
            $<$<CXX_COMPILER_ID:MSVC>:/PROFILE>
            >
        )
    endif()
endfunction()

function(cmt_add_library target_name)
    cmake_parse_arguments("CMTFCN"
        "NAMESPACED;VISABLE_SYMBOLS;NO_COVERAGE"
        "EXPORT_NAME"
        ""
        "${ARGN}")

    set(CMT_NAMESPACE ${PROJECT_NAME})

    if(DEFINED CMTFCN_EXPORT_NAME)
        set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
    else()
        set(CMT_TARGET_EXPORT_NAME ${target_name})
    endif()

    if(NOT "${CMT_NAMESPACE}" STREQUAL "${target_name}")
        set(CMT_DEDUPED_NAMESPACED_NAME "${CMT_NAMESPACE}${target_name}")
    else()
        set(CMT_DEDUPED_NAMESPACED_NAME "${target_name}")
    endif()

    if(${CMTFCN_NAMESPACED})
        set(CMT_TARGET_NAME "${CMT_DEDUPED_NAMESPACED_NAME}")
        message(DEBUG "Creating namespaced library: ${CMT_TARGET_NAME}")
    else()
        set(CMT_TARGET_NAME "${target_name}")
        message(DEBUG "Creating non-namespaced library: ${CMT_TARGET_NAME}")
    endif()

    message(DEBUG "Adding library '${CMT_TARGET_NAME}' with args ${CMTFCN_UNPARSED_ARGUMENTS}")
    add_library(${CMT_TARGET_NAME} ${CMTFCN_UNPARSED_ARGUMENTS})
    add_library(${CMT_NAMESPACE}::${CMT_TARGET_EXPORT_NAME} ALIAS ${CMT_TARGET_NAME})

    set_target_properties(${CMT_TARGET_NAME} PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR})

    # check if target is not a header only library:
    get_target_property(CMT_TARGET_TYPE ${CMT_TARGET_NAME} TYPE)

    if(NOT ${CMT_TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
        include(GenerateExportHeader)

        if(NOT CMTFCN_VISABLE_SYMBOLS)
            set_target_properties(${CMT_TARGET_NAME} PROPERTIES
                CXX_VISIBILITY_PRESET hidden
                VISIBILITY_INLINES_HIDDEN 1)
        endif()

        generate_export_header(${CMT_TARGET_NAME}
            EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_TARGET_NAME}_export.h
            EXPORT_MACRO_NAME ${CMT_DEDUPED_NAMESPACED_NAME}_EXPORT
        )

        target_sources(${CMT_TARGET_NAME}
            PUBLIC
            FILE_SET HEADERS
            TYPE HEADERS
            BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}
            FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_TARGET_NAME}_export.h)
    endif()

    cmt_target_setup(${CMT_TARGET_NAME}
        NAMESPACE ${CMT_NAMESPACE}
        EXPORT_NAME ${CMT_TARGET_NAME})
    set(CMT_LAST_TARGET ${CMT_TARGET_NAME} PARENT_SCOPE)
endfunction()

function(cmt_add_executable target_name)
    cmake_parse_arguments("CMTFCN"
        "NAMESPACED;NO_COVERAGE"
        "EXPORT_NAME"
        "" "${ARGN}")

    set(CMT_NAMESPACE ${PROJECT_NAME})

    if(DEFINED CMTFCN_EXPORT_NAME)
        set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
    else()
        set(CMT_TARGET_EXPORT_NAME ${target_name})
    endif()

    if(${CMTFCN_NAMESPACED})
        # check if target_name is equal to namespace, if so, don't add namespace twice.
        if(NOT "${CMT_NAMESPACE}" STREQUAL "${target_name}")
            set(CMT_TARGET_NAME "${CMT_NAMESPACE}${target_name}")
        else()
            set(CMT_TARGET_NAME "${target_name}")
        endif()

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

    set(CMT_LAST_TARGET ${CMT_TARGET_NAME} PARENT_SCOPE)
endfunction()

function(cmt_install_target target_name)
    cmake_parse_arguments("CMTFCN" "" "" "SUBTARGETS" "${ARGN}")

    get_target_property(CMT_TARGET_EXPORT_NAME ${target_name} CMT_EXPORT_NAME)
    get_target_property(CMT_TARGET_NAMESPACE ${target_name} CMT_NAMESPACE)
    get_target_property(CMT_TARGET_STANDARD_NAME ${target_name} CMT_STANDARD_NAME)

    message(DEBUG "Installing target: ${target_name}\n"
        "      Export name: ${CMT_TARGET_EXPORT_NAME}\n"
        "      Namespace: ${CMT_TARGET_NAMESPACE}\n"
        "      Standard name: ${CMT_TARGET_STANDARD_NAME}")

    set_target_properties(
        ${target_name}
        PROPERTIES
        EXPORT_NAME ${CMT_TARGET_EXPORT_NAME}
        OUTPUT_NAME ${target_name}
    )

    set(EXPORT_SET ${CMT_TARGET_NAMESPACE}${CMT_TARGET_EXPORT_NAME}Targets)

    install(TARGETS ${target_name}
        EXPORT ${EXPORT_SET}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
        NAMELINK_COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        FILE_SET HEADERS
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILE_SET generatedheaders
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    if(CMTFCN_SUBTARGETS)
        foreach(subtarget ${CMTFCN_SUBTARGETS})
            install(TARGETS ${subtarget}
                EXPORT ${EXPORT_SET}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
                NAMELINK_COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
                COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
                FILE_SET HEADERS
                COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
                INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
                FILE_SET generatedheaders
                COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
                INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
            )
        endforeach()
    endif()

    install(
        EXPORT ${EXPORT_SET}
        NAMESPACE ${CMT_TARGET_NAMESPACE}::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
    )
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/cmake/DoxygenHelper.cmake)