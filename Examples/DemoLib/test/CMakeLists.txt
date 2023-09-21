# build tests to verify cmake behavior:
include(test_targetcreation.cmake)
include(test_installfilesets.cmake)

# uunit test example:
cmt_add_executable(UnitTests NAMESPACED test_hello.cpp)
target_link_libraries(${CMT_LAST_TARGET} PRIVATE DemoLib::Hello)