cmake_minimum_required(VERSION 3.24)
include(CMTUtils.cmake)

# Move version to external file:
cmt_external_version_file()
Project(CMakeTools VERSION ${CMT_ExternalVersion_VER})

if(NOT "${CMAKE_PROJECT_NAME}"  STREQUAL "${PROJECT_NAME}")
    message(STATUS "CMakeTools not top level project, skipping cmaketools setup")
else()
    message(STATUS "CMakeProjectName: ${CMAKE_PROJECT_NAME}")
    message(STATUS "ProjectName: ${PROJECT_NAME}")

    cmt_project_setup()

    # cmt_add_examples_subdirectory(Examples/DemoLib)
    cmt_add_test_subdirectory(tests)
endif()