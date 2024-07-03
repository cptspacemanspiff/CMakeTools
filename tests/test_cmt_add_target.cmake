#
# test adding a cmt target:
#

function(cmt_test_checkExists target)
    cmake_parse_arguments("CMTFCN" "" "EXPECTED_NAME;")

    if(NOT DEFINED CMTFCN_EXPECTED_NAME)
        message(FATAL_ERROR "check exists requires an expected name")
    endif()
endfunction()

# First test if cmt_target_setup works:

# setup with:
# NAMESPACE=CMAKETOOLS_TESTS
# EXPORTNAME=Testlib_NoSOVersion
# NO_SOVERSION -> True
# NO_COVERAGE -> True  # not sure how to test?
add_library(CMakeTools_Testlib_NoSOVersion SHARED dummylib.cpp)
cmt_target_setup(CMakeTools_Testlib_NoSOVersion
    NO_SOVERSION
    NAMESPACE CMakeTools_Tests
    EXPORT_NAME Testlib_NoSOVersion)
add_test(NAME "CMakeTools_Testlib_NoSOVersion" COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/scripts/checkExists.py
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libCMakeTools_Testlib_NoSOVersion.so
    --exists)

# setup with:
# NAMESPACE=CMAKETOOLS_TESTS
# EXPORTNAME=Testlib_WithSOVersion
# NO_SOVERSION -> True
# NO_COVERAGE -> True  # not sure how to test?
add_library(CMakeTools_Testlib_WithSOVersion SHARED dummylib.cpp)
cmt_target_setup(CMakeTools_Testlib_WithSOVersion
    NAMESPACE CMakeTools_Tests
    EXPORT_NAME Testlib_WithSOVersion)
add_test(NAME "CMakeTools_Testlib_WithSOVersion" COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/scripts/checkExists.py
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libCMakeTools_Testlib_WithSOVersion.so
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libCMakeTools_Testlib_WithSOVersion.so.${PROJECT_VERSION_MAJOR}
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libCMakeTools_Testlib_WithSOVersion.so.${PROJECT_VERSION}
    --exists)

# Same for EXEs
add_executable(CMakeTools_TestExe_NoSOVersion dummyexe.cpp)
cmt_target_setup(CMakeTools_TestExe_NoSOVersion
    NO_SOVERSION
    NAMESPACE CMakeTools_Tests
    EXPORT_NAME TestExe_NoSOVersion)
add_test(NAME "CMakeTools_TestExe_NoSOVersion" COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/scripts/checkExists.py
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/CMakeTools_TestExe_NoSOVersion
    --exists)

add_executable(CMakeTools_TestExe_WithSOVersion dummyexe.cpp)
cmt_target_setup(CMakeTools_TestExe_WithSOVersion
    NAMESPACE CMakeTools_Tests
    EXPORT_NAME TestExe_WithSOVersion)
add_test(NAME "CMakeTools_TestExe_WithSOVersion" COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/scripts/checkExists.py
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/CMakeTools_TestExe_WithSOVersion
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/CMakeTools_TestExe_WithSOVersion-${PROJECT_VERSION}
    --exists)
