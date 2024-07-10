cmt_add_library(Hello SHARED HelloImpl.cpp)

cmt_target_headers(Hello
  PUBLIC
  BASE_DIRS ${PROJECT_SOURCE_DIR}/include
  FILES ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/Hello.h)

cmt_install_target(Hello)

# exe target:
cmt_add_executable(EXE hello.cpp NAMESPACED NO_COVERAGE)
target_link_libraries(${CMT_LAST_TARGET} PRIVATE Hello)
cmt_install_target(${CMT_LAST_TARGET})

cmt_install_cmake_config(Hello)