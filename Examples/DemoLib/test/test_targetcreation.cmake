# create a non-namespaced library:
message(STATUS "Testing library target creation")
cmt_add_library(NotNamespaced hello.cpp)

message(DEBUG "CMT_LAST_TARGET: ${CMT_LAST_TARGET}")

cmt_install_target(${CMT_LAST_TARGET})

cmt_add_library(Namespaced NAMESPACED hello.cpp)
cmt_install_target(${CMT_LAST_TARGET})

cmt_add_library(${PROJECT_NAME} NAMESPACED hello.cpp)
cmt_install_target(${CMT_LAST_TARGET})

message(STATUS "Testing executable target creation")
cmt_add_executable(NotNamespacedEXE hello.cpp)
cmt_install_target(${CMT_LAST_TARGET})

cmt_add_executable(NamespacedEXE NAMESPACED hello.cpp)
cmt_install_target(${CMT_LAST_TARGET})

# cmt_add_executable(${PROJECT_NAME} src/hello.cpp)
# cmt_install_target(${PROJECT_NAME})
message(STATUS "Testing target creation with subtargets")

cmt_add_library(BaseTarget hello.cpp)
cmt_add_library(SubTarget1 hello.cpp)
cmt_add_library(SubTarget2 hello.cpp)
cmt_add_library(SubTarget3 hello.cpp)

cmt_install_target(BaseTarget SUBTARGETS SubTarget1 SubTarget2 SubTarget3)