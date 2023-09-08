# create a list of directories to add:
set(DOC_SOURCES
    "${PROJECT_SOURCE_DIR}/include"
    "${PROJECT_SOURCE_DIR}/README.md")

message(STATUS "DOC_SOURCES: ${DOC_SOURCES}")

cmt_doxygen_helper(
    PROJECT_BRIEF "A demo project using CMakeTools"
    DIRECTORIES
    "${PROJECT_SOURCE_DIR}/include"
    "${PROJECT_SOURCE_DIR}/README.md"
)