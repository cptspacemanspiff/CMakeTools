include_guard()

# this is  the helper file to generate deb/rpm/msi installable artifacts from cmake projects.
cmake_minimum_required(VERSION 3.24)

# this expects a cmt formatted target ():
function(cmt_package_target target_name)
    if(NOT BUILD_PACKAGING)
        # do not build packaging, exit early.
        return()
    endif()

    cmake_parse_arguments("CMTFCN" "" "" "" "${ARGN}")

    get_target_property(CMT_TARGET_EXPORT_NAME ${target_name} CMT_EXPORT_NAME)
    get_target_property(CMT_TARGET_NAMESPACE ${target_name} CMT_NAMESPACE)
    get_target_property(CMT_TARGET_STANDARD_NAME ${target_name} CMT_STANDARD_NAME)



    # we require that namespace, exportname and standardname are defined:
    # get sarget property fails if it does not exist.
    # set(CPACK_PACKAGE_NAME "CoolStuff")
    # SET(CPACK_INSTALL_CMAKE_PROJECTS  "SubProject;MySub;ALL;/")
    set(CMT_CPACK_PACKAGING_ROOT "${CMAKE_BINARY_DIR}/Packaging/")

    # set output directories for cpack:
    set(CPACK_PACKAGE_DIRECTORY ${CMT_CPACK_PACKAGING_ROOT}/output)

    set(CPACK_OUTPUT_CONFIG_FILE ${CMT_CPACK_PACKAGING_ROOT}/CPackConfig/CPackConfig_${CMT_TARGET_STANDARD_NAME}_${COMPNAME}.cmake)

    # set(CPACK_SOURCE_OUTPUT_CONFIG_FILE ${CMT_CPACK_PACKAGING_ROOT}/CPackConfig/CPackSourceConfig_${CMT_TARGET_STANDARD_NAME}.cmake)
    # list of components:
    set(CMT_COMPONENT_LIST "Development;Runtime;")

    foreach(COMPNAME ${CMT_COMPONENT_LIST})
        # cpack_add_component()

    endforeach()

    # add touchfiles dir if it does not exist:
    set(CMT_TOUCHFILE_DIR ${CMT_CPACK_PACKAGING_ROOT}/touchfiles)
    set(CMT_TOUCHFILE ${CMT_TOUCHFILE_DIR}/touch_${CMT_TARGET_STANDARD_NAME}_${COMPNAME})
    file(MAKE_DIRECTORY ${CMT_TOUCHFILE_DIR})

    message(STATUS "Adding cpack packaging target: ${CPACK_OUTPUT_CONFIG_FILE}")
    set(CMT_CPACK_EXECUTABLE "cpack")
    add_custom_command(POST_BUILD OUTPUT "${CMT_TOUCHFILE}"
        COMMAND echo ${CMT_CPACK_EXECUTABLE} --config ${CPACK_OUTPUT_CONFIG_FILE}
        COMMAND touch "${CMT_TOUCHFILE}"
        WORKING_DIRECTORY ${CMT_CPACK_PACKAGING_ROOT}
        COMMENT "Generating CPack"
        DEPENDS ${CMT_TARGET_NAMESPACE}::${CMT_TARGET_EXPORT_NAME}
        VERBATIM
    )

    add_custom_target(${CMT_TARGET_STANDARD_NAME}_Packaging ALL DEPENDS "${CMT_TOUCHFILE}")

    get_cmake_property(CPACK_COMPONENTS_ALL COMPONENTS)
    message(STATUS "Components: ${CPACK_COMPONENTS_ALL}")
    include(CPack)
endfunction()