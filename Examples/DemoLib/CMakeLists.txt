cmake_minimum_required(VERSION 3.24)
include(../../CMTUtils.cmake)

project(DemoLib VERSION 1.0.0)

cmt_project_setup()

cmt_add_library(hello SHARED src/hello.cpp)

add_subdirectory(src)