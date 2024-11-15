include_guard()

# this is  the helper file to generate deb/rpm/msi installable artifacts from cmake projects.
cmake_minimum_required(VERSION 3.24)

# packaging is annoyingly complex, The idea of this is to do a standard "good enough" packaging for most usecases.
# there are two ways to handle this:
# Target level packaging - each target and component type goes to a separate package
# Project level packaging - all targets go to a separate package.
# This tries to be somewhat flexible. As an example, the overall packaging command
# is run once at the package level. This builds all package artifacts from the project.
# For example, DemoLib has 4 components:
# DemoLib_EXE_Runtime;
# DemoLib_Hello_Development;
# DemoLib_Hello_Runtime;
# DemoLib_documentation_doxygen

# 3 of these are target level artifacts, on linux
# DemoLib_EXE_Runtime -> demolib-exe
# DemoLib_Hello_Runtime -> Demolib-hello
# DemoLib_Hello_Development -> Demolib-hello-devel
# The 4th is a project level artifact:
# DemoLib_documentation_doxygen -> demolib-doc

# if the user wanted demolib-exe and demolib-hello to be in a single package,
# then in the cmt_install_target() has a subtarget option, which places the
# subtarget in the same package as the target (it uses the same component name).
function(cmt_pkg_get_dependencies target)
    get_target_property(var ${target} LINK_LIBRARIES)
    message(STATUS "${target} link-libraries: ${var}")
endfunction()

set(CMT_COMPONENT_TYPES "Runtime;Development;Documentation")

# get the expected package name of the target/component, (used for dependency resolution on linux).
function(cmt_get_target_pkg_name varname)
    cmake_parse_arguments("CMTFCN" "" "TARGET;COMPONENT_TYPE" "" "${ARGN}")

    # require that all args are set:
    if(NOT DEFINED CMTFCN_TARGET)
        message(FATAL_ERROR "cmt_target_setup requires a namespace")
    endif()

    if(NOT DEFINED CMTFCN_COMPONENT_TYPE)
        message(FATAL_ERROR "cmt_target_setup requires a component type")
    endif()

    # Based on the OS/Packaging system we will have different component names.
    # If we are on linux, for each component type we need to specify the name:
    if(NOT("${CMTFCN_COMPONENT_TYPE}" IN_LIST CMT_COMPONENT_TYPES))
        message(FATAL_ERROR "cmt_get_target_pkg_name unknown component type: 
        ${CMTFCN_COMPONENT_TYPE},
        must be one of ${CMT_COMPONENT_TYPES}")
    endif()

    get_target_property(CMT_TARGET_EXPORT_NAME ${target_name} CMT_EXPORT_NAME)
    get_target_property(CMT_TARGET_NAMESPACE ${target_name} CMT_NAMESPACE)
    get_target_property(CMT_TARGET_STANDARD_NAME ${target_name} CMT_STANDARD_NAME)

    set(PACKAGE_NAME "INVALID_PACKAGE_NAME")

    if(WIN32)
        message(FATAL_ERROR "Todo, figure out windows package names")
    elseif(APPLE)
        message(FATAL_ERROR "Todo, figure out apple package names")

    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        find_program(LSB_RELEASE_EXEC lsb_release REQUIRED)
        execute_process(COMMAND ${LSB_RELEASE_EXEC} -is
            OUTPUT_VARIABLE LSB_RELEASE_ID_SHORT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(${LSB_RELEASE_ID_SHORT} STREQUAL "Ubuntu")
            set(UBUNTU_DEVELOPMENT_POSTFIX "dev")

            set(UBUNTU_RUNTIME_POSTFIX "")

            if(${COMPONENT_TYPE} STREQUAL "Runtime")
            elseif(${COMPONENT_TYPE} STREQUAL "Development")
            elseif(${COMPONENT_TYPE} STREQUAL "Documentation")
            endif()

        else()
            message(FATAL_ERROR "Unknown linux type (Please add to CMakeTools)")
        endif()
    else()
        set(CPACK_GENERATOR TGZ)
    endif()
endfunction()

# this expects a cmt formatted target ():
function(cmt_package_target target_name)
    if(NOT BUILD_PACKAGING)
        # do not build packaging, exit early.
        return()
    endif()

    cmake_parse_arguments("CMTFCN" "" "" "" "${ARGN}")

    # If we are on linux:
    if(WIN32)
        set(CPACK_GENERATOR ZIP WIX)
    elseif(APPLE)
        set(CPACK_GENERATOR TGZ productbuild)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        find_program(LSB_RELEASE_EXEC lsb_release REQUIRED)
        execute_process(COMMAND ${LSB_RELEASE_EXEC} -is
            OUTPUT_VARIABLE LSB_RELEASE_ID_SHORT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(${LSB_RELEASE_ID_SHORT} STREQUAL "Ubuntu")
            message(STATUS "Packaging for Ubuntu.")

        # set(CPACK_GENERATOR TGZ)
        else()
            message(FATAL_ERROR "Unknown linux type (Please add to CMakeTools)")
        endif()
    else()
        set(CPACK_GENERATOR TGZ)
    endif()

    message(STATUS "Packaging with ${CPACK_GENERATOR}")

    get_target_property(CMT_TARGET_EXPORT_NAME ${target_name} CMT_EXPORT_NAME)
    get_target_property(CMT_TARGET_NAMESPACE ${target_name} CMT_NAMESPACE)
    get_target_property(CMT_TARGET_STANDARD_NAME ${target_name} CMT_STANDARD_NAME)

    cmt_pkg_get_dependencies(${target_name})

    cmt_get_target_pkg_name(avername TARGET ${target_name} COMPONENT_TYPE "Runtime")

    # we require that namespace, exportname and standardname are defined:
    # get sarget property fails if it does not exist.
    # set(CPACK_PACKAGE_NAME "CoolStuff")
    # SET(CPACK_INSTALL_CMAKE_PROJECTS  "SubProject;MySub;ALL;/")
    set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP)

    set(CMT_CPACK_PACKAGING_ROOT "${CMAKE_BINARY_DIR}/Packaging/")
    set(CPACK_DEB_COMPONENT_INSTALL YES)

    # set output directories for cpack:
    set(CPACK_PACKAGE_DIRECTORY ${CMT_CPACK_PACKAGING_ROOT}/output)

    set(COMPNAME "Runtime")
    set(COMPONENT_TYPES "Runtime")

    set(CPACK_OUTPUT_CONFIG_FILE ${CMT_CPACK_PACKAGING_ROOT}/CPackConfig/CPackConfig_${CMT_TARGET_STANDARD_NAME}_${COMPNAME}.cmake)

    set(CPACK_SOURCE_OUTPUT_CONFIG_FILE ${CMT_CPACK_PACKAGING_ROOT}/CPackConfig/CPackSourceConfig_${CMT_TARGET_STANDARD_NAME}.cmake)

    # list of components:
    # set(CMT_COMPONENT_LIST "Development;Runtime;")
    message(STATUS "Project Binary dir: ${PROJECT_BINARY_DIR} <namepace>-dir ${${CMT_TARGET_NAMESPACE}_BINARY_DIR}")
    set(CPACK_COMPONENTS_ALL "${CMT_TARGET_STANDARD_NAME}_Runtime")

    set(CPACK_INSTALL_CMAKE_PROJECTS
        "${PROJECT_BINARY_DIR};${PROJECT_NAME};${CMT_TARGET_STANDARD_NAME}_Runtime;/"
    )

    # set(CPACK_INSTALL_CMAKE_PROJECTS "${PROJECT_BINARY_DIR};${PROJECT_NAME};ALL;/")

    # foreach(COMPNAME ${COMPONENT_TYPES})

    # endforeach()
    get_cmake_property(CMT_CPACK_COMPONENTS_ALL COMPONENTS)
    message(STATUS "Components: ${CMT_CPACK_COMPONENTS_ALL}")
    include(CPack)

    # add touchfiles dir if it does not exist:
    set(CMT_TOUCHFILE_DIR ${CMT_CPACK_PACKAGING_ROOT}/touchfiles)
    set(CMT_TOUCHFILE ${CMT_TOUCHFILE_DIR}/touch_${CMT_TARGET_STANDARD_NAME}_${COMPNAME})
    file(MAKE_DIRECTORY ${CMT_TOUCHFILE_DIR})

    message(STATUS "Adding cpack packaging target: ${CPACK_OUTPUT_CONFIG_FILE}")
    set(CMT_CPACK_EXECUTABLE "cpack")
    add_custom_command(POST_BUILD OUTPUT "${CMT_TOUCHFILE}"
        COMMAND ${CMT_CPACK_EXECUTABLE} --config ${CPACK_OUTPUT_CONFIG_FILE} --debug
        COMMAND touch "${CMT_TOUCHFILE}"
        WORKING_DIRECTORY ${CMT_CPACK_PACKAGING_ROOT}
        COMMENT "Generating CPack"

        # DEPENDS ${CMT_TARGET_NAMESPACE}::${CMT_TARGET_EXPORT_NAME}
        VERBATIM
    )

    add_custom_target(${CMT_TARGET_STANDARD_NAME}_Packaging DEPENDS "${CMT_TOUCHFILE}")
endfunction()