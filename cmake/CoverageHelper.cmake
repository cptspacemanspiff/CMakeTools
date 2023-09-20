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

function(cmt_build_coverage_setup)
    option(CMT_COVERAGE_LCOV "Generate gcovr coverage reports" ON)
    option(CMT_COVERAGE_GCOVR "Generate lcov coverage reports" ON)
endfunction()

function(cmt_coverage_setup_target target_name)
    # Parse the arguments:
    if(NOT BUILD_TESTS)
        message(DEBUG "Not building tests, not adding coverage to target: ${target_name}")
    else()
        cmake_parse_arguments("CMTFCN"
            ""
            ""
            ""
            "${ARGN}")

        # coverage can only be built by clang and gcc (currently).
        if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        else()
            message(FATAL_ERROR "Coverage report is not supported for compiler: ${CMAKE_CXX_COMPILER_ID}")
        endif()

        # there is a global coverage target that runs all the unit tests, and then generates the coverage report. We are appending our info to it.
        if(NOT TARGET CMT_CoverageTarget)
            message(DEBUG "Creating CMT_CoverageTarget")

            # set the output directory:
            set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/coverage")
            add_custom_target(CMT_CoverageTarget)
            set_target_properties(CMT_CoverageTarget
                PROPERTIES
                CMT_COVERAGE_SOURCES ""
                CMT_COVERAGE_FILESETS "")

            # wif we compiled with LLVM we need to use llvm-cov instead of gcov:
            if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                find_program(LLVM_COV_PATH llvm-cov)
                set(GCOVR_LLVM_ADDITIONAL_ARGS "--gcov-executable" "${LLVM_COV_PATH} gcov")

                # set(LCOV_LLVM_ADDITIONAL_ARGS "--gcov-tool" "${LLVM_COV_PATH} gcov")
                # above does not work, create a symbolic link to llvm-cov named gcov:
                # file(CREATE_LINK <original> <linkname> [RESULT <result>] [COPY_ON_ERROR] [SYMBOLIC])
                file(CREATE_LINK "${LLVM_COV_PATH}" "${CMAKE_BINARY_DIR}/coverage/gcov" SYMBOLIC)
                set(LCOV_LLVM_ADDITIONAL_ARGS "--gcov-tool" "${CMAKE_BINARY_DIR}/coverage/gcov")
            endif()

            # common commands:
            set(TEST_COMMAND "ctest" "-C" "$<CONFIG>" "--output-on-failure")

            find_program(GCOVR_PATH gcovr)

            if(CMT_COVERAGE_GCOVR)
                if(NOT GCOVR_PATH)
                    message(WARNING "gcovr not found, lcov coverage report will not be generated.")
                else()
                    # setup gcovr:
                    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                        find_program(LLVM_COV_PATH llvm-cov)
                        set(GCOVR_LLVM_ADDITIONAL_ARGS "--gcov-executable" "${LLVM_COV_PATH} gcov")
                    else()
                        set(GCOVR_LLVM_ADDITIONAL_ARGS "")
                    endif()

                    set(GCROVR_OUTPUT_DIR "${OUTPUT_DIR}/gcovr")
                    file(MAKE_DIRECTORY ${GCROVR_OUTPUT_DIR})
                    set(GCOVR_COMMAND "${GCOVR_PATH}"
                        "${GCOVR_LLVM_ADDITIONAL_ARGS}"
                        "-r" "${CMAKE_SOURCE_DIR}"
                        "-x" "${GCROVR_OUTPUT_DIR}/coverage.xml" # produce xml for github
                        "-s" # produce commandline string for user:
                        "--html-details" "${GCROVR_OUTPUT_DIR}/" # produce text for user
                        "-f;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_SOURCES>,;-f;>"
                        "-f;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_FILESETS>,;-f;>")

                    set(COVERAGE_TRUE_MSG "Building Coverage Report with \\n ${GCOVR_COMMAND}")
                    set(COVERAGE_FALSE_MSG "WARNING: Configuration is $<CONFIG> not Coverage - GCOVR The Coverage report not generated.")

                    add_custom_command(OUTPUT ${GCROVR_OUTPUT_DIR}/coverage.xml
                        POST_BUILD
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                        COMMAND echo "$<IF:$<CONFIG:Coverage>,'${COVERAGE_TRUE_MSG}',${COVERAGE_FALSE_MSG}>"
                        COMMAND "$<$<CONFIG:Coverage>:${TEST_COMMAND}>"
                        COMMAND "$<$<CONFIG:Coverage>:${GCOVR_COMMAND}>"
                        COMMAND_EXPAND_LISTS
                        VERBATIM)
                    target_sources(CMT_CoverageTarget PRIVATE ${GCROVR_OUTPUT_DIR}/coverage.xml)
                endif()
            endif()

            find_program(LCOV_PATH lcov)
            find_program(GENHTML_PATH genhtml)

            if(LCOV_PATH)
                # if(FALSE)
                if(NOT(LCOV_PATH AND GENHTML_PATH))
                    message(WARNING "lcov not found, lcov coverage report will not be generated.")
                else()
                    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                        find_program(LLVM_COV_PATH llvm-cov)
                        # set(LCOV_LLVM_ADDITIONAL_ARGS "--gcov-tool" "${LLVM_COV_PATH} gcov")
                        # above does not work, create a symbolic link to llvm-cov named gcov:
                        # file(CREATE_LINK <original> <linkname> [RESULT <result>] [COPY_ON_ERROR] [SYMBOLIC])
                        file(CREATE_LINK "${LLVM_COV_PATH}" "${CMAKE_BINARY_DIR}/coverage/gcov" SYMBOLIC)
                        set(LCOV_LLVM_ADDITIONAL_ARGS "--gcov-tool" "${CMAKE_BINARY_DIR}/coverage/gcov")
                    else()
                        set(GCOVR_LLVM_ADDITIONAL_ARGS "")
                    endif()

                    # setup and run lcov:
                    set(LCOV_OUTPUT_DIR "${OUTPUT_DIR}/lcov")
                    file(MAKE_DIRECTORY ${LCOV_OUTPUT_DIR})
                    set(LCOV_COMMAND "${LCOV_PATH}"
                        "${LCOV_LLVM_ADDITIONAL_ARGS}"
                        "--capture"
                        "--directory" "${CMAKE_BINARY_DIR}"
                        "--output-file" "${LCOV_OUTPUT_DIR}/coverage.info"
                        "--include;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_SOURCES>,;--include;>"
                        "--include;$<JOIN:$<TARGET_PROPERTY:CMT_CoverageTarget,CMT_COVERAGE_FILESETS>,;--include;>")
                    set(LCOV_GENHTML_COMMAND "${GENHTML_PATH}" "${LCOV_OUTPUT_DIR}/coverage.info" "--output-directory" "${LCOV_OUTPUT_DIR}/html")

                    set(COVERAGE_TRUE_MSG "Building Coverage Report with \\n ${LCOV_COMMAND}")
                    set(COVERAGE_FALSE_MSG "WARNING: Configuration is $<CONFIG> not Coverage - The LCOV Coverage report not generated.")

                    add_custom_command(OUTPUT ${LCOV_OUTPUT_DIR}/coverage.info
                        POST_BUILD
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                        COMMAND echo "$<IF:$<CONFIG:Coverage>,'${COVERAGE_TRUE_MSG}',${COVERAGE_FALSE_MSG}>"
                        COMMAND "$<$<CONFIG:Coverage>:${TEST_COMMAND}>"
                        COMMAND "$<$<CONFIG:Coverage>:${LCOV_COMMAND}>"
                        COMMAND "$<$<CONFIG:Coverage>:${LCOV_GENHTML_COMMAND}>"
                        COMMAND_EXPAND_LISTS
                        VERBATIM)

                    target_sources(CMT_CoverageTarget PRIVATE ${LCOV_OUTPUT_DIR}/coverage.info)
                endif()
            endif()

        else()
            message(DEBUG "CMT_CoverageTarget already exists")
        endif()

        # add dependnecies to coverage target:
        add_dependencies(CMT_CoverageTarget ${target_name})

        # By default coverage is ran on the header and source directory filesets.
        # get the sources of the target helper provides absolute paths.
        cmt_get_target_sources_realpath(target_sources TARGET ${target_name})
        message(DEBUG "target_sources: ${target_sources}")

        # get the public filesets of the target.
        get_target_property(target_public_filesets ${target_name} HEADER_SET_cmt_public_headers)
        message(DEBUG "target_public_filesets: ${target_public_filesets}")

        # get the interface filesets of the target.
        get_target_property(target_interface_filesets ${target_name} HEADER_SET_cmt_interface_headers)
        message(DEBUG "target_interface_filesets: ${target_interface_filesets}")

        # get the private filesets of the target.
        get_target_property(target_private_filesets ${target_name} HEADER_SET_cmt_private_headers)
        message(DEBUG "target_private_filesets: ${target_private_filesets}")

        # add properies to the target, these get read via generator expression at build time:
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