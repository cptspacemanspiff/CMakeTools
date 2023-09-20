include_guard()

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