cmt_add_library(fileset INTERFACE)
target_sources(fileset
    PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_LIST_DIR}/include
    FILES
    ${CMAKE_CURRENT_LIST_DIR}/include/fileset.h
)

cmt_install_target(fileset)

