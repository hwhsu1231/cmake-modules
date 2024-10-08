# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[=================================================================================[.rst:
FindConda
-----------

Try to find Conda executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Conda::Conda``
  The ``conda`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Conda_FOUND``
  System has Conda. True if Conda has been found.

``Conda_EXECUTABLE``
  The full path to the ``conda`` executable.

``Conda_VERSION``
  The version of Conda found.

``Conda_VERSION_MAJOR``
  The major version of Conda found.

``Conda_VERSION_MINOR``
  The minor version of Conda found.

``Conda_VERSION_PATCH``
  The patch version of Conda found.

Hints
^^^^^

``Conda_ROOT_DIR``, ``ENV{Conda_ROOT_DIR}``
  Define the root directory of a Conda installation.

#]=================================================================================]

if(CMAKE_HOST_WIN32)
    set(_CONDA_NAME "conda.bat;conda.exe")
else()
    set(_CONDA_NAME "conda")
endif()

set(_Conda_SEARCH_HINTS
    ${Conda_ROOT_DIR}
    ENV Conda_ROOT_DIR
    ENV CONDA_PREFIX)

set(_Conda_SEARCH_PATHS "")

set(_Conda_FAILURE_REASON "")

find_program(Conda_EXECUTABLE
    NAMES ${_CONDA_NAME}
    HINTS ${_Conda_SEARCH_HINTS}
    PATHS ${_Conda_SEARCH_PATHS}
    DOC "The full path to the conda executable.")

if(Conda_EXECUTABLE)
    execute_process(
        COMMAND ${Conda_EXECUTABLE} --version
        RESULT_VARIABLE _Conda_VERSION_RESULT
        OUTPUT_VARIABLE _Conda_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Conda_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Conda_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" Conda_VERSION ${_Conda_VERSION_OUTPUT})
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" _ ${Conda_VERSION})
        set(Conda_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Conda_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Conda_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        # Set Conda_FOUND to FALSE when 'conda --version' is broken.
        set(Conda_FOUND FALSE)
        string(APPEND _Conda_FAILURE_REASON
        "The command\n\n"
        "      \"${Conda_EXECUTABLE}\" --version\n\n"
        "    failed with fatal errors.\n\n"
        "    result:\n\n${_Conda_VERSION_RESULT}\n\n"
        "    stdout:\n\n${_Conda_VERSION_OUTPUT}\n\n"
        "    stderr:\n\n${_Conda_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Conda_FOUND to true if Conda_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Conda
    REQUIRED_VARS
        Conda_EXECUTABLE
    VERSION_VAR
        Conda_VERSION
    FOUND_VAR
        Conda_FOUND
    FAIL_MESSAGE
        "${_Conda_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if(Conda_FOUND)
    get_property(_Conda_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if(_Conda_CMAKE_ROLE STREQUAL "PROJECT")
        if(NOT TARGET Conda::Conda)
            add_executable(Conda::Conda IMPORTED)
            set_target_properties(Conda::Conda PROPERTIES
                IMPORTED_LOCATION
                    "${Conda_EXECUTABLE}")
        endif()
    endif()
    unset(_Conda_CMAKE_ROLE)
endif()

unset(_Conda_SEARCH_HINTS)
unset(_Conda_SEARCH_PATHS)
