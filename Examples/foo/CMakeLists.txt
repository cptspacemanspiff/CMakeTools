cmake_minimum_required(VERSION 3.24)

include(../../CMTUtils.cmake)

Project(foo VERSION 1.0.0)
set(CMAKE_CXX_STANDARD 20)

cmt_project_setup()
cmt_add_src_subdirectory(src)