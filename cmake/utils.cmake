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

        # convert the item to absolute path:
        get_filename_component(item "${item}" REALPATH)

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