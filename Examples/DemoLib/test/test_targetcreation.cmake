# create a non-namespaced library:
message(STATUS "Testing library target creation")
cmt_add_library(NotNamespaced src/hello.cpp)
cmt_install_target(NotNamespaced)

cmt_add_library(Namespaced NAMESPACED src/hello.cpp)

cmt_add_library(${PROJECT_NAME} NAMESPACED src/hello.cpp)
cmt_install_target(DemoLib)

message(STATUS "Testing executable target creation")
cmt_add_executable(NotNamespacedEXE src/hello.cpp)
cmt_install_target(NotNamespacedEXE)

cmt_add_executable(NamespacedEXE NAMESPACED src/hello.cpp)
cmt_install_target(NotNamespacedEXE)

cmt_add_executable(${PROJECT_NAME}EXE src/hello.cpp)
cmt_install_target(${PROJECT_NAME}EXE)