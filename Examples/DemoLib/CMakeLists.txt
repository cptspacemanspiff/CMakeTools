cmake_minimum_required(VERSION 3.24)
include(../../CMTUtils.cmake)

project(DemoLib VERSION 0.0.1)

set(CMAKE_CXX_STANDARD 20)

cmt_project_setup()

cmt_add_src_subdirectory(src)
cmt_add_doc_subdirectory(doc)

