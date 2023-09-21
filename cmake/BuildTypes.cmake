# A helper library creating additional build types:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
# - Coverage
# - SanitizeAddress
# - SanitizeThread
# - SanitizeMemory
# - SanitizeUndefined

cmake_minimum_required(VERSION 3.24)

macro(cmt_default_build_types)
    # add a coverage build type:
    list(APPEND allowedBuildTypes Coverage)
    set(CMAKE_C_FLAGS_COVERAGE "${CMAKE_C_FLAGS_DEBUG} " CACHE STRING "")
    set(CMAKE_CXX_FLAGS_COVERAGE "${CMAKE_CXX_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE "${CMAKE_EXE_LINKER_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_STATIC_LINKER_FLAGS_COVERAGE "${CMAKE_STATIC_LINKER_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_MODULE_LINKER_FLAGS_COVERAGE "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}" CACHE STRING "")
endmacro()

macro(cmt_configure_build_types)
    # set the allowed build types, if not set:
    set(defaultBuildTypes Debug Release RelWithDebInfo MinSizeRel)

    foreach(buildType IN LISTS defaultBuildTypes)
        if(NOT "${buildType}" IN_LIST allowedBuildTypes)
            list(APPEND allowedBuildTypes "${buildType}")
            message(STATUS "Adding build type: ${buildType}")
        endif()
    endforeach()

    unset(defaultBuildTypes)

    cmt_default_build_types()

    # error if we are not the base dir:
    if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        message(FATAL_ERROR "cmt_configure_build_types() must be called from the base directory")
    endif()

    get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(isMultiConfig)
        # iterate through allowed build types and add them to the configuration types:
        foreach(buildType IN LISTS allowedBuildTypes)
            if(NOT "${buildType}" IN_LIST CMAKE_CONFIGURATION_TYPES)
                list(APPEND CMAKE_CONFIGURATION_TYPES "${buildType}")
            endif()
        endforeach()
    else()
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY
            STRINGS "${allowedBuildTypes}"
        )

        if(NOT CMAKE_BUILD_TYPE)
            set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
        elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
            message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}, allowed build types are: ${allowedBuildTypes}")
        endif()
    endif()
endmacro()