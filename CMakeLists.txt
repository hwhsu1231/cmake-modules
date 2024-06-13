cmake_minimum_required(VERSION 3.23)
project(lcm)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
set(GIT_REQUIRED_VERSION "EXACT;2.32")
find_package(Git MODULE ${GIT_REQUIRED_VERSION})
# find_package(Git      MODULE)
find_package(Python   MODULE 3.8...3.11)
find_package(Gettext  MODULE 0.20...0.22)
find_package(Crowdin  MODULE)
# find_package(Sphinx   MODULE QUIET EXACT 7.1 REQUIRED)
# find_package(Sphinx   MODULE QUIET EXACT 7.2 REQUIRED)
# find_package(Sphinx   MODULE QUIET 7.1...7.3 REQUIRED)
# find_package(Sphinx   MODULE QUIET 7.1 REQUIRED)
find_package(Sphinx   MODULE QUIET)

# message(STATUS "Git_FOUND                   = ${Git_FOUND}")
# message(STATUS "Git_VERSION                 = ${Git_VERSION}")
# message(STATUS "Git_EXECUTABLE              = ${Git_EXECUTABLE}")
# message(STATUS "Python_FOUND                = ${Python_FOUND}")
# message(STATUS "Python_VERSION              = ${Python_VERSION}")
# message(STATUS "Python_EXECUTABLE           = ${Python_EXECUTABLE}")
# message(STATUS "Gettext_FOUND               = ${Gettext_FOUND}")
# message(STATUS "Gettext_VERSION             = ${Gettext_VERSION}")
# message(STATUS "Gettext_Xgettext_FOUND      = ${Gettext_Xgettext_FOUND}")
# message(STATUS "Gettext_Msgmerge_FOUND      = ${Gettext_Msgmerge_FOUND}")
# message(STATUS "Gettext_Msgcat_FOUND        = ${Gettext_Msgcat_FOUND}")
# message(STATUS "Gettext_XGETTEXT_EXECUTABLE = ${Gettext_XGETTEXT_EXECUTABLE}")
# message(STATUS "Gettext_MSGMERGE_EXECUTABLE = ${Gettext_MSGMERGE_EXECUTABLE}")
# message(STATUS "Gettext_MSGCAT_EXECUTABLE   = ${Gettext_MSGCAT_EXECUTABLE}")
# message(STATUS "Crowdin_FOUND               = ${Crowdin_FOUND}")
# message(STATUS "Crowdin_VERSION             = ${Crowdin_VERSION}")
# message(STATUS "Crowdin_EXECUTABLE          = ${Crowdin_EXECUTABLE}")
# message(STATUS "Sphinx_FOUND                = ${Sphinx_FOUND}")
# message(STATUS "Sphinx_VERSION              = ${Sphinx_VERSION}")
# message(STATUS "Sphinx_BUILD_EXECUTABLE     = ${Sphinx_BUILD_EXECUTABLE}")
# message(STATUS "Sphinx_APIDOC_EXECUTABLE    = ${Sphinx_APIDOC_EXECUTABLE}")

add_custom_target(test_FindCrwodin ALL
    COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/tests/TestFindCrowdin.cmake
    USES_TERMINAL)

add_custom_target(test_JsonUtils ALL
    COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/tests/TestJsonUtils.cmake
    USES_TERMINAL)

add_custom_target(test_FindSphinx ALL
    COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/tests/TestFindSphinx.cmake
    USES_TERMINAL)

message(STATUS "ENV{BASH_VERSION} = $ENV{BASH_VERSION}")
message(STATUS "ENV{PATH}         = $ENV{PATH}")
if(EXISTS "$ENV{HOME}/.bashrc")
    message(STATUS "File \"$ENV{HOME}/.bashrc\" exists.")
endif()
