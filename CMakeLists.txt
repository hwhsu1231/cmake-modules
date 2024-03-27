cmake_minimum_required(VERSION 3.23)
project(lcm)

add_custom_target(test-modules
    COMMAND ${CMAKE_COMMAND} -P "${PROJECT_SOURCE_DIR}/tests/JsonUtilsTest.cmake")
