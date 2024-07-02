cmake_minimum_required(VERSION 3.24)
include(CMTUtils.cmake)
cmt_external_version_file()
#Move version to external file:
Project(CMakeTools VERSION ${CMT_ExternalVersion_VER})


cmt_project_setup()

# cmt_add_examples_subdirectory(Examples/DemoLib)

cmt_add_test_subdirectory(tests)