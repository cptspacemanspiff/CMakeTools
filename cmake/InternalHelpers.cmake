# Internal CMake helper functions for CMakeTools.
# 
# All functions start with _CMT and are not meant to be public facing, and 
# therefore can change at any time.

function(_cmt_directory_exists directory)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/${directory})
      message(
        FATAL_ERROR
        "The location ${CMAKE_CURRENT_LIST_DIR}/${directory} does not exist.")
    endif()
  endfunction()