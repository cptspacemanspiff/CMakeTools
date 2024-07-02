#
# test adding a cmt target:
#

# First test if cmt_target_setup works:

add_library(CMakeTools_TestBase dummylib.cpp)

# setup with:
# NAMESPACE=CMAKETOOLS_TESTS
# EXPORTNAME=CMAKETESTS
# NO_SOVERSION -> True
# NO_COVERAGE -> True  # not sure how to test?
cmt_target_setup(CMakeTools_TestBase 
                NO_SOVERSION 
                NAMESPACE CMakeTools_Tests
                EXPORT_NAME CMAKETESTS)