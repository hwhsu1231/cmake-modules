
cmake_minimum_required(VERSION 3.23)
message(STATUS "")
message(STATUS "---------- TestFindCrowdin ----------")
message(STATUS "")

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/..")

find_package(Crowdin)
message(STATUS "Crowdin_FOUND = ${Crowdin_FOUND}")
message(STATUS "Crowdin_EXECUTABLE = ${Crowdin_EXECUTABLE}")
