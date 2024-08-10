cmake_minimum_required(VERSION 3.24)
project(CMakeToolsTests VERSION 0.0.0)

if(UNIX)
    include(${CMAKE_CURRENT_LIST_DIR}/../CMTUtils.cmake)

    cmt_project_setup()

    # probably dont need python, but it is easier than bash
    find_package(Python3 REQUIRED)

    include(CTest)
    # ## Test cmt_add_library
    include(test_cmt_add_target.cmake)
    include(test_cmt_utils_stack.cmake)
else()
    message(WARNING "CMakeTools tests are only defined on linux os (we basically just check against build artifacts.)")
endif(UNIX)
