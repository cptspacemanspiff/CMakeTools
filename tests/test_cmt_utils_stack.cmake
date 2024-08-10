include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/utils.cmake)

# test the stack implementation (no lists):
set(cmt_stack_testfile "${CMAKE_CURRENT_BINARY_DIR}/cmt_stack_testfile")
set(testvar "_")
# message(STATUS "${testvar}")
file(WRITE ${cmt_stack_testfile} "${testvar}-")
foreach(i RANGE 3)
    cmt_stack_push_set(testvar "${i}")
    # message(STATUS "${testvar}")
    file(APPEND ${cmt_stack_testfile} "${testvar}-")
endforeach()

foreach(i RANGE 4)
    cmt_stack_pop(testvar)
    # message(STATUS "${testvar}")
    file(APPEND ${cmt_stack_testfile} "${testvar}-")
endforeach()

add_test(NAME "CMakeTools_TestStack" COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/scripts/checkExists.py
    ${cmt_stack_testfile}
    --equals "_-0-1-2-3-2-1-0-_--"
    --exists)

# test the map implementation:

cmt_map_set(testmap KEY "key1" VALUE "value1")
cmt_map_set(testmap KEY "key1" VALUE "value1")
cmt_map_set(testmap GLOBAL KEY "globalkey1" VALUE "value3")
