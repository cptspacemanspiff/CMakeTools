
if(UNIX)
    # probably dont need python, but it is easier than bash
    find_package(Python3 REQUIRED)

    # ## Test cmt_add_library
    include(test_cmt_add_target.cmake)
else()
    message(WARNING "CMakeTools tests are only defined on linux os (we basically just check against build artifacts.)")
endif(UNIX)
