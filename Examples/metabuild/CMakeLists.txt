

# This is a build that builds other cmake projects:
cmake_minimum_required(VERSION 3.24)
project(MetaBuild VERSION 1.0.0)

include(../../CMTUtils.cmake)

include(FetchContent)

FetchContent_Declare(
    DemoLib
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../DemoLib
    OVERRIDE_FIND_PACKAGE 
)

FetchContent_Declare(
    foo
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../foo
    OVERRIDE_FIND_PACKAGE 
)

FetchContent_MakeAvailable(Demolib foo)