# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[=================================================================================[.rst:
FindCrowdin
-----------

Try to find Crowdin CLI client.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Crowdin::Crowdin``
  The ``crowdin`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Crowdin_FOUND``
  System has Crowdin. True if Crowdin has been found.

``Crowdin_EXECUTABLE``
  The full path to the ``crowdin`` executable.

``Crowdin_VERSION``
  The version of Crowdin found.

``Crowdin_VERSION_MAJOR``
  The major version of Crowdin found.

``Crowdin_VERSION_MINOR``
  The minor version of Crowdin found.

``Crowdin_VERSION_PATCH``
  The patch version of Crowdin found.

Hints
^^^^^

``Crowdin_ROOT_DIR``, ``ENV{Crowdin_ROOT_DIR}``
  Define the root directory of a Crowdin installation.

#]=================================================================================]

if(CMAKE_HOST_WIN32)
    set(_CROWDIN_NAME "crowdin.exe;crowdin.bat;crowdin.cmd")
else()
    set(_CROWDIN_NAME "crowdin")
endif()

set(_Crowdin_SEARCH_HINTS
    ${Crowdin_ROOT_DIR}
    ENV Crowdin_ROOT_DIR
    ENV CROWDIN_HOME)

set(_Crowdin_SEARCH_PATHS)

set(_Crowdin_FAILURE_REASON)

find_program(Crowdin_EXECUTABLE
    NAMES ${_CROWDIN_NAME}
    HINTS ${_Crowdin_SEARCH_HINTS}
    PATHS ${_Crowdin_SEARCH_PATHS}
    DOC "The full path to the crowdin executable.")

if(WIN32)
    # It is required to set CROWDIN_HOME env on Windows platform.
    # Based on: https://github.com/crowdin/crowdin-cli/issues/607
    if(Crowdin_ROOT_DIR)
        # If Crowdin_ROOT_DIR is specified, then assign it to ENV{CROWDIN_HOME}.
        set(ENV{CROWDIN_HOME} "${Crowdin_ROOT_DIR}")
    else()
        # If ENV{Crowdin_ROOT_DIR} is specified, then assign it to ENV{CROWDIN_HOME}.
        set(_ENV_Crowdin_ROOT_DIR "$ENV{Crowdin_ROOT_DIR}")
        if(_ENV_Crowdin_ROOT_DIR)
            set(ENV{CROWDIN_HOME} "${_ENV_Crowdin_ROOT_DIR}")
        endif()
        unset(_ENV_Crowdin_ROOT_DIR)
    endif()
endif()

if(Crowdin_EXECUTABLE)
    execute_process(
        COMMAND ${Crowdin_EXECUTABLE} --version
        RESULT_VARIABLE _Crowdin_VERSION_RESULT
        OUTPUT_VARIABLE _Crowdin_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Crowdin_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Crowdin_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" Crowdin_VERSION ${_Crowdin_VERSION_OUTPUT})
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" _ ${Crowdin_VERSION})
        set(Crowdin_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Crowdin_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Crowdin_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        # Set Crowdin_FOUND to FALSE when 'crowdin --version' is broken.
        set(Crowdin_FOUND FALSE)
        string(APPEND _Crowdin_FAILURE_REASON
        "The command\n\n"
        "      \"${Crowdin_EXECUTABLE}\" --version\n\n"
        "    failed with fatal errors.\n\n"
        "    result:\n\n${_Crowdin_VERSION_RESULT}\n\n"
        "    stdout:\n\n${_Crowdin_VERSION_OUTPUT}\n\n"
        "    stderr:\n\n${_Crowdin_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Crowdin_FOUND to true if Crowdin_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Crowdin
    REQUIRED_VARS
        Crowdin_EXECUTABLE
    VERSION_VAR
        Crowdin_VERSION
    FOUND_VAR
        Crowdin_FOUND
    FAIL_MESSAGE
        "${_Crowdin_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if(Crowdin_FOUND)
    get_property(_Crowdin_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if(_Crowdin_CMAKE_ROLE STREQUAL "PROJECT")
        if(NOT TARGET Crowdin::Crowdin)
            add_executable(Crowdin::Crowdin IMPORTED)
            set_target_properties(Crowdin::Crowdin PROPERTIES
                IMPORTED_LOCATION
                    "${Crowdin_EXECUTABLE}")
        endif()
    endif()
    unset(_Crowdin_CMAKE_ROLE)
endif()

unset(_Crowdin_SEARCH_HINTS)
unset(_Crowdin_SEARCH_PATHS)
