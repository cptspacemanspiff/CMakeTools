# This file sets up and runs the code coverage. Code coverage targets are 
# instrumented on a target by target basis. The coverage analysis is then done
# on a file-by-file basis (or via specified directories).
# there end up being 2 lists: 
# 1. targets that get coverage ran against them.
# 2. unit tests executed for the coverage target.
#
# a global coverage target is then created, which runs all the unit tests, and
# then runs the coverage analysis. the combined output from all the unit tests 
# creates the report.
#
#
# rerunning clears the coverage analyis.
# The top level CMakeLists file determines what output format is used/created.
# default/only is html, and xml for github.
#
# It is separated into 3 steps:
# 1. Setup the build flags for coverage (--coverage in gcc)
# This is special cased for the Coverage build type. This is done in the
# CMTUtils.cmake file in the cmt_setup_target function.
# 2. Add coverage directories to the target.

function(cmt_coverage_setup_target target_name)
    # Parse the arguments:
    cmake_parse_arguments("CMTFCN"
        ""
        ""
        ""
        "${ARGN}")

    # by default coverage is ran on the header and source directory filesets.
    # parse the header and 

    # get the sources of the target.
    get_target_property(target_sources ${target_name} SOURCES)

    message(STATUS "target_sources: ${target_sources}")

    # get the filesets of the target.
    get_target_property(target_filesets ${target_name} HEADER_SET)

    message(STATUS "target_filesets: ${target_filesets}")
    # get the base dirs of the target headers:
    get_target_property(target_header_base_dirs ${target_name} HEADER_DIRS)

    message(STATUS "target_header_base_dirs: ${target_header_base_dirs}")

    # create a cache variable for the coverage variables:
    list(APPEND CMT_COVERAGE_TARGETS ${target_name})
    


endfunction()

function(cmt_coverage_tests)
    # check if we are using gcc:
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        message("Using gcc trying coverage:")
        find_program(GCOV_PATH gcovr)

        if(NOT GCOV_PATH)
            message(FATAL_ERROR "gcov not found,")
        endif()

        # set(Coverage_NAME "coverage_test")

        # set(GCOVR_HTML_EXEC_TESTS_CMD
        #     ctest ${Coverage_EXECUTABLE_ARGS}
        # )

        # # Create folder
        # set(GCOVR_HTML_FOLDER_CMD
        #     ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/${Coverage_NAME}
        # )

        # # Running gcovr
        # set(GCOVR_HTML_CMD
        #     gcovr
        #     --html ${PROJECT_BINARY_DIR}/${Coverage_NAME}/index.html --html-details
        #     -r ${PROJECT_SOURCE_DIR}
        #     ${GCOVR_ADDITIONAL_ARGS}
        #     ${GCOVR_EXCLUDE_ARGS}
        #     -o ${PROJECT_BINARY_DIR}/gcovr
        # )

        # add_custom_target("haddsfjf"
        #     COMMAND ${GCOVR_HTML_FOLDER_CMD}
        #     COMMAND ${GCOVR_HTML_EXEC_TESTS_CMD}
        #     COMMAND ${GCOVR_HTML_CMD}
        #     DEPENDS EEPUnitTests)
    endif()
endfunction()