find_package(DemoLib REQUIRED)

cmt_add_executable(foo foo.cpp)
target_link_libraries(foo PRIVATE DemoLib::Hello)

cmt_install_target(foo)

cmt_install_cmake_config(foo)