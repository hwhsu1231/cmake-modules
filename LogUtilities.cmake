

# macro(remove_cmake_message_indent)
#     execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 2.0)
#     set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
#     set(CMAKE_MESSAGE_INDENT "")        
# endmacro()

# macro(restore_cmake_message_indent)
#     set(CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT_BACKUP}")
#     set(CMAKE_MESSAGE_INDENT_BACKUP "")
#     execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 2.0)
# endmacro()

macro(remove_cmake_message_indent)
    if(DEFINED REMOVE_CMAKE_MESSAGE_INDENT_CALLED)
        message(FATAL_ERROR "remove_cmake_message_indent() has already been called without calling restore_cmake_message_indent().")
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 2.0)
    set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
    set(CMAKE_MESSAGE_INDENT "")        
    set(REMOVE_CMAKE_MESSAGE_INDENT_CALLED TRUE) # Set the flag
endmacro()

macro(restore_cmake_message_indent)
    if(NOT DEFINED REMOVE_CMAKE_MESSAGE_INDENT_CALLED)
        message(FATAL_ERROR "remove_cmake_message_indent() must be called before calling restore_cmake_message_indent().")
    endif()

    set(CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT_BACKUP}")
    set(CMAKE_MESSAGE_INDENT_BACKUP "")
    execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 2.0)
    unset(REMOVE_CMAKE_MESSAGE_INDENT_CALLED) # Clear the flag
endmacro()