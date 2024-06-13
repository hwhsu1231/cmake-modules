
cmake_minimum_required(VERSION 3.23)

message(STATUS "")
message(STATUS "---------- TestFindSphinx ----------")
message(STATUS "")

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/..")


# find_package(Sphinx)
# message(STATUS "Sphinx_FOUND                  = ${Sphinx_FOUND}")
# message(STATUS "Sphinx_Build_FOUND            = ${Sphinx_Build_FOUND}")
# message(STATUS "Sphinx_Apidoc_FOUND           = ${Sphinx_Apidoc_FOUND}")
# message(STATUS "Sphinx_Autogen_FOUND          = ${Sphinx_Autogen_FOUND}")
# message(STATUS "Sphinx_Quickstart_FOUND       = ${Sphinx_Quickstart_FOUND}")
# message(STATUS "Sphinx_BUILD_EXECUTABLE       = ${Sphinx_BUILD_EXECUTABLE}")
# message(STATUS "Sphinx_APIDOC_EXECUTABLE      = ${Sphinx_APIDOC_EXECUTABLE}")
# message(STATUS "Sphinx_AUTOGEN_EXECUTABLE     = ${Sphinx_AUTOGEN_EXECUTABLE}")
# message(STATUS "Sphinx_QUICKSTART_EXECUTABLE  = ${Sphinx_QUICKSTART_EXECUTABLE}")


find_package(Python)
execute_process(
    COMMAND ${Python_EXECUTABLE} -m venv .venv
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
unset(Python_EXECUTABLE)
set(Python_ROOT_DIR ${CMAKE_CURRENT_BINARY_DIR}/.venv)
find_package(Python)
execute_process(
    COMMAND ${Python_EXECUTABLE} -m pip install sphinx
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR
    ERROR_VARIABLE  ERR_VAR)
# message(STATUS "Python_EXECUTABLE = ${Python_EXECUTABLE}")

unset(Sphinx_FOUND CACHE)
unset(Sphinx_Build_FOUND CACHE)
unset(Sphinx_Apidoc_FOUND CACHE)
unset(Sphinx_Autogen_FOUND CACHE)
unset(Sphinx_Quickstart_FOUND CACHE)
unset(Sphinx_BUILD_EXECUTABLE CACHE)
unset(Sphinx_APIDOC_EXECUTABLE CACHE)
unset(Sphinx_AUTOGEN_EXECUTABLE CACHE)
unset(Sphinx_QUICKSTART_EXECUTABLE CACHE)
set(Sphinx_ROOT_DIR ${CMAKE_CURRENT_BINARY_DIR}/.venv)
find_package(Sphinx)
message(STATUS "Sphinx_FOUND                  = ${Sphinx_FOUND}")
message(STATUS "Sphinx_Build_FOUND            = ${Sphinx_Build_FOUND}")
message(STATUS "Sphinx_Apidoc_FOUND           = ${Sphinx_Apidoc_FOUND}")
message(STATUS "Sphinx_Autogen_FOUND          = ${Sphinx_Autogen_FOUND}")
message(STATUS "Sphinx_Quickstart_FOUND       = ${Sphinx_Quickstart_FOUND}")
message(STATUS "Sphinx_BUILD_EXECUTABLE       = ${Sphinx_BUILD_EXECUTABLE}")
message(STATUS "Sphinx_APIDOC_EXECUTABLE      = ${Sphinx_APIDOC_EXECUTABLE}")
message(STATUS "Sphinx_AUTOGEN_EXECUTABLE     = ${Sphinx_AUTOGEN_EXECUTABLE}")
message(STATUS "Sphinx_QUICKSTART_EXECUTABLE  = ${Sphinx_QUICKSTART_EXECUTABLE}")

string(FIND "${Sphinx_BUILD_EXECUTABLE}" "${Sphinx_ROOT_DIR}" FOUND_INDEX)
if(NOT FOUND_INDEX EQUAL -1)
    message(STATUS "Found ${Sphinx_ROOT_DIR} in ${Sphinx_BUILD_EXECUTABLE}")
else()
    message(STATUS "${Sphinx_ROOT_DIR} not found in ${Sphinx_BUILD_EXECUTABLE}")
endif()

string(FIND "${Sphinx_APIDOC_EXECUTABLE}" "${Sphinx_ROOT_DIR}" FOUND_INDEX)
if(NOT FOUND_INDEX EQUAL -1)
    message(STATUS "Found ${Sphinx_ROOT_DIR} in ${Sphinx_APIDOC_EXECUTABLE}")
else()
    message(STATUS "${Sphinx_ROOT_DIR} not found in ${Sphinx_APIDOC_EXECUTABLE}")
endif()
