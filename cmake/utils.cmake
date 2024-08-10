include_guard()

# # configures private headers to only be used internally (mainly by test files that need access to resources) the include paths are relative to this location.
# function(cmt_target_configure_headers target)
# endfunction()
function(cmt_append_target_property target)
    # parse args:
    cmake_parse_arguments(CMTFCN "" "PROPERTY" "" ${ARGN})

    # PROPERTY is required:
    if(NOT CMTFCN_PROPERTY)
        message(FATAL_ERROR "cmt_append_target_property: PROPERTY is required")
    endif()

    # iterate through args passed in:
    foreach(item ${CMTFCN_UNPARSED_ARGUMENTS})
        # append arg to target property:
        get_target_property(TMP_TARGET_PROPERTY ${target} ${CMTFCN_PROPERTY})

        if(TMP_TARGET_PROPERTY)
            list(APPEND TMP_TARGET_PROPERTY "${item}")
            set_target_properties(${target} PROPERTIES ${CMTFCN_PROPERTY} "${TMP_TARGET_PROPERTY}")
            message(DEBUG "cmt_append_target_property: ${target} ${CMTFCN_PROPERTY} += ${item}")
        else()
            set_target_properties(${target} PROPERTIES ${CMTFCN_PROPERTY} "${item}")
            message(DEBUG "cmt_append_target_property: ${target} ${CMTFCN_PROPERTY} = ${item}")
        endif()
    endforeach()

    # confirm that it worked:
    get_target_property(TMP_TARGET_PROPERTY ${target} ${CMTFCN_PROPERTY})
    message(DEBUG "cmt_append_target_property: ${target} ${CMTFCN_PROPERTY} = ${TMP_TARGET_PROPERTY}")
endfunction()

# by dafault target sources property gives relative paths, this helper returns the absolute paths.
function(cmt_get_target_sources_realpath varname)
    cmake_parse_arguments(CMTFCN "" "TARGET" "" ${ARGN})

    message(DEBUG "cmt_get_target_sources: TARGET = ${CMTFCN_TARGET}")

    if(NOT TARGET ${CMTFCN_TARGET})
        message(FATAL_ERROR "cmt_get_target_sources: TARGET is required")
    endif()

    get_target_property(TMP_TARGET_SOURCES ${CMTFCN_TARGET} SOURCES)
    get_target_property(TMP_TARGET_SOURCE_DIR ${CMTFCN_TARGET} SOURCE_DIR)

    if(NOT TMP_TARGET_SOURCES)
        set(${varname} "${TMP_TARGET_SOURCES}" PARENT_SCOPE)
    else()
        foreach(src ${TMP_TARGET_SOURCES})
            FILE(REAL_PATH "${src}" TARGET_SOURCE_REALPATH BASE_DIRECTORY ${TMP_TARGET_SOURCE_DIR} EXPAND_TILDE)
            list(APPEND TMP_REALPATHS "${TARGET_SOURCE_REALPATH}")
        endforeach()

        set(${varname} "${TMP_REALPATHS}" PARENT_SCOPE)
    endif()
endfunction()

# push variable onto a local variable stack, where stackname is based on varname,
# probably gets screwed up by lists.
#
function(cmt_stack_push varname)
    list(LENGTH ${varname} length)

    if(${length} GREATER 1)
        message(FATAL_ERROR "cmt_stack_push does not support pushing lists. You tried to push: \"${${varname}}\"")
    endif()

    list(APPEND CMT_STACK_${varname} ${${varname}})
    message(DEBUG "cmt_stack_push pushed ${varname} = ${${varname}}")
    message(DEBUG "cmt_stack_push CMT_STACK_${varname} = ${CMT_STACK_${varname}}")
    set(CMT_STACK_${varname} ${CMT_STACK_${varname}} PARENT_SCOPE)
endfunction()

function(cmt_stack_push_set varname)
    cmake_parse_arguments(CMTFCN "" "" "" ${ARGN})
    cmt_stack_push(${varname})
    message(DEBUG "cmt_stack_push_set set ${varname} = ${CMTFCN_UNPARSED_ARGUMENTS}")
    set(${varname} ${CMTFCN_UNPARSED_ARGUMENTS} PARENT_SCOPE)
    set(CMT_STACK_${varname} ${CMT_STACK_${varname}} PARENT_SCOPE)
endfunction()

function(cmt_stack_pop varname)
    list(POP_BACK CMT_STACK_${varname} ${varname})
    message(DEBUG "cmt_stack_pop popped ${varname} = ${${varname}}")
    message(DEBUG "cmt_stack_pop CMT_STACK_${varname} = ${CMT_STACK_${varname}}")
    set(${varname} ${${varname}} PARENT_SCOPE)
    set(CMT_STACK_${varname} ${CMT_STACK_${varname}} PARENT_SCOPE)
endfunction()

# Function that acts like a map, (by making a ton of variables...)
function(cmt_map_set mapname)
    cmake_parse_arguments(CMTFCN "GLOBAL" "KEY;VALUE" "" ${ARGN})

    message(STATUS "cmt_map_set: Map: ${mapname}, Key: ${CMTFCN_KEY}, value: ${CMTFCN_VALUE}")

    if((NOT DEFINED CMTFCN_KEY) OR (NOT DEFINED CMTFCN_VALUE))
        message(FATAL_ERROR "cmt_map_set(mapname KEY key VALUE value) requires both key and value positional args.")
    endif()

    if(CMTFCN_GLOBAL)
        set(MapVarName "CMT_GLOBALVALUES_MAP_${mapname}_${CMTFCN_KEY}")
    else()
        set(MapVarName "CMT_LOCAL_MAP_${mapname}_${CMTFCN_KEY}")
    endif()

    message(STATUS "cmt_map_set: MapVarName: ${MapVarName} = \'${${MapVarName}}\'")
    message(STATUS "cmt_map_set: Current: \'${${MapVarName}}\' new: \'${CMTFCN_VALUE}\'")
    if(DEFINED ${MapVarName} AND NOT ("${${MapVarName}}" STREQUAL "${CMTFCN_VALUE}"))
        message(FATAL_ERROR "trying to modify map value, this is not supported")
    endif()

    if(CMTFCN_GLOBAL)
        set(${MapVarName} "${CMTFCN_VALUE}" CACHE INTERNAL "global map value for cmt ${mapname} map.")
    else()
        set(${MapVarName} "${CMTFCN_VALUE}" PARENT_SCOPE)
    endif()
endfunction()