# Top level CMake helper file that provides a single include option.

# Top level project command that passes standard arguements to config, and does basic setup.
macro(cmt_project)
    cmake_parse_arguments("CMT_PROJECT" "" "" "" ${ARGN})

    message(DEBUG "Configuring project ${CMT_PROJECT_UNPARSED_ARGUMENTS}")
endmacro()