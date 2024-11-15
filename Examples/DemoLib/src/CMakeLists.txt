cmt_add_library(Hello SHARED HelloImpl.cpp)

cmt_target_headers(Hello
  PUBLIC
  BASE_DIRS ${PROJECT_SOURCE_DIR}/include
  FILES ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/Hello.h)


cmt_add_executable(EXESubtarget hello.cpp)
target_link_libraries(${CMT_LAST_TARGET} PRIVATE DemoLib::Hello)

cmt_install_target(Hello SUBTARGET ${CMT_LAST_TARGET})

# exe separate install target:
cmt_add_executable(EXE hello.cpp NAMESPACED NO_COVERAGE)
target_link_libraries(${CMT_LAST_TARGET} PRIVATE DemoLib::Hello)
cmt_install_target(${CMT_LAST_TARGET})

cmt_install_cmake_config(Hello)

cmt_package_target(Hello)