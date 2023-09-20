# This file sets up and runs the code coverage. Code coverage targets are
# instrumented on a target by target basis. The coverage analysis is then done
# on a file-by-file basis (or via specified directories).
# there end up being 2 lists:
# 1. targets that get coverage ran against them.
# 2. unit tests executed for the coverage target.
# 3. coverage is unified across all projects.
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

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

function(cmt_coverage_setup_target target_name)
    # Parse the arguments:
    if(NOT BUILD_TESTS)
        message(DEBUG "Not building tests, not adding coverage to target: ${target_name}")
    else()
        cmake_parse_arguments("CMTFCN"
            ""
            ""
            "EXCLUDE;EXTRA_INCLUDES;EXTRA_BASEDIRS"
            "${ARGN}")

        # by default coverage is ran on the header and source directory filesets.
        # parse the header.

        # get the sources of the target.
        cmt_get_target_sources_realpath(target_sources TARGET ${target_name})
        message(DEBUG "target_sources: ${target_sources}")

        # get the public filesets of the target.
        get_target_property(target_public_filesets ${target_name} HEADER_SET_cmt_public_headers)
        message(DEBUG "target_public_filesets: ${target_public_filesets}")

        get_target_property(target_interface_filesets ${target_name} HEADER_SET_cmt_interface_headers)
        message(DEBUG "target_interface_filesets: ${target_interface_filesets}")

        # get the private filesets of the target.
        get_target_property(target_private_filesets ${target_name} HEADER_SET_cmt_private_headers)
        message(DEBUG "target_private_filesets: ${target_private_filesets}")

        # there is a global coverage target that runs all the unit tests, and then generates the coverage report. We are appending our info to it.
        if(NOT TARGET CMT_CoverageTarget)
            message(DEBUG "Creating CMT_CoverageTarget")

            # set the output directory:
            set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/coverage")

            add_custom_target(CMT_CoverageTarget SOURCES "${OUTPUT_DIR}/coverage.xml")

            # add the properies with default empty values:
            set_target_properties(CMT_CoverageTarget
                PROPERTIES
                CMT_COVERAGE_SOURCES ""
                CMT_COVERAGE_FILESETS "")

            get_cmake_property(CMT_COVERAGE_EXCLUDES GLOBAL PROPERTY CMT_COVERAGE_EXCLUDES)

            find_program(GCOVR_PATH gcovr)

            if(GCOVR_PATH)
            else()
                message(WARNING "gcov not found, coverage report will not be generated.")
            endif()


            #create the dir if it doesn't exist:
            file(MAKE_DIRECTORY ${OUTPUT_DIR})

            set(CCOVR_COMMAND "${GCOVR_PATH}"
                "-r" "${CMAKE_SOURCE_DIR}"
                "-x" "${OUTPUT_DIR}/coverage.xml" # produce xml for github
                "-s" # produce commandline string for user:
                "--html-details" "${OUTPUT_DIR}/" # produce text for user
                "-f;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_SOURCES>,;-f;>"
                "-f;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_FILESETS>,;-f;>")

            set(CCOVR_TEST_COMMAND "ctest" "-C" "$<CONFIG>" "--output-on-failure")

            # add custom commands to be ran by this target later:
            # this command should only run in coverage mode.
            set(COVERAGE_TRUE_MSG "Building Coverage Report with \\n ${CCOVR_COMMAND}")
            set(COVERAGE_FALSE_MSG "WARNING: Configuration is $<CONFIG> not Coverage - The Coverage report not generated.")
            add_custom_command(OUTPUT ${OUTPUT_DIR}/coverage.xml
                POST_BUILD
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                # COMMAND echo "kdjfsakf"
                COMMAND echo "$<IF:$<CONFIG:Coverage>,'${COVERAGE_TRUE_MSG}',${COVERAGE_FALSE_MSG}>"
                COMMAND "$<$<CONFIG:Coverage>:${CCOVR_TEST_COMMAND}>"
                COMMAND "$<$<CONFIG:Coverage>:${CCOVR_COMMAND}>"
                COMMAND_EXPAND_LISTS
                VERBATIM)
        else()
            message(DEBUG "CMT_CoverageTarget already exists")
        endif()

        # add dependnecies to coverage target:
        add_dependencies(CMT_CoverageTarget ${target_name})

        # add properies to the target:
        if(target_sources)
            cmt_append_target_property(CMT_CoverageTarget PROPERTY "CMT_COVERAGE_SOURCES" "${target_sources}")
        endif()

        if(target_public_filesets)
            cmt_append_target_property(CMT_CoverageTarget PROPERTY "CMT_COVERAGE_FILESETS" "${target_public_filesets}")
        endif()

        if(target_interface_filesets)
            cmt_append_target_property(CMT_CoverageTarget PROPERTY "CMT_COVERAGE_FILESETS" "${target_interface_filesets}")
        endif()

        if(target_private_filesets)
            cmt_append_target_property(CMT_CoverageTarget PROPERTY "CMT_COVERAGE_FILESETS" "${target_private_filesets}")
        endif()
    endif()
endfunction()