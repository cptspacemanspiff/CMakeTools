cmt_add_library(LIB SHARED HelloImpl.cpp)
target_sources(LIB
    PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${PROJECT_SOURCE_DIR}/include
    FILES
    ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/Hello.h
)
cmt_install_target(LIB)

# cmt_add_executable(EXE hello.cpp)
# cmt_install_target(EXE)