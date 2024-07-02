cmt_add_library(Hello SHARED HelloImpl.cpp)

target_sources(
  Hello
  PUBLIC FILE_SET
  cmt_public_headers
  TYPE
  HEADERS
  BASE_DIRS
  ${PROJECT_SOURCE_DIR}/include
  FILES
  ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/Hello.h)

target_sources(
  Hello
  PUBLIC FILE_SET
  cmt_public_headers
  TYPE
  HEADERS
  BASE_DIRS
  ${PROJECT_SOURCE_DIR}/include
  FILES
  ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/Hello.h)

target_sources(
  Hello
  PRIVATE FILE_SET
  cmt_private_headers
  TYPE
  HEADERS
  BASE_DIRS
  ${PROJECT_SOURCE_DIR}/src
  FILES
  ${PROJECT_SOURCE_DIR}/src/HelloImpl.h)

cmt_install_target(Hello)

# exe target:
cmt_add_executable(EXE hello.cpp NAMESPACED NO_COVERAGE)
# target_link_libraries(EXE PRIVATE Hello)
# cmt_install_target(EXE NOEXPORT)
