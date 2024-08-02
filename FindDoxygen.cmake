# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[=======================================================================[.rst:
FindDoxygen
-----------

Try to find Doxygen documentation generator's command-line tool.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Doxygen::Doxygen``
  The ``doxygen`` executable.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``Doxygen_FOUND``
  System has the Doxygen. ``TRUE`` if Doxygen has been found.

``Doxygen_EXECUTABLE``
  The full path to the ``doxygen`` executable.

``Doxygen_VERSION``
  The version of Doxygen found (outputs of ``doxygen --version``).

``Doxygen_VERSION_MAJOR``
  The major version of Doxygen found.

``Doxygen_VERSION_MINOR``
  The minor version of Doxygen found.

``Doxygen_VERSION_PATCH``
  The patch version of Doxygen found.

Hints
^^^^^

``Doxygen_ROOT_DIR``, ``ENV{Doxygen_ROOT_DIR}``
  Define the root directory of a Doxygen installation.

#]=======================================================================]

set(_Doxygen_SEARCH_HINTS 
    ${Doxygen_ROOT_DIR} 
    ENV Doxygen_ROOT_DIR)

set(_Doxygen_SEARCH_PATHS "")

set(_Doxygen_FAILURE_REASON "")

find_program(Doxygen_EXECUTABLE
    NAMES doxygen
    PATH_SUFFIXES bin
    HINTS ${_Doxygen_SEARCH_HINTS}
    PATHS ${_Doxygen_SEARCH_PATHS}
    DOC "The full path to the doxygen executable.")
if(Doxygen_EXECUTABLE)
    set(Doxygen_FOUND TRUE)
endif()

if(Doxygen_EXECUTABLE)
    execute_process(
        COMMAND "${Doxygen_EXECUTABLE}" --version
        RESULT_VARIABLE _Doxygen_VERSION_RESULT
        OUTPUT_VARIABLE _Doxygen_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Doxygen_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Doxygen_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" Doxygen_VERSION ${_Doxygen_VERSION_OUTPUT})
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" _ ${Doxygen_VERSION})
        set(Doxygen_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Doxygen_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Doxygen_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        # Set Doxygen_FOUND to FALSE when 'doxygen --version' is broken.
        set(Doxygen_FOUND FALSE)
        string(APPEND _Doxygen_FAILURE_REASON
        "The command\n"
        "      \"${Doxygen_EXECUTABLE}\" --version\n"
        "    failed with result: \n${_Doxygen_VERSION_RESULT}\n"
        "    stdout:\n${_Doxygen_VERSION_OUTPUT}\n"
        "    stderr:\n${_Doxygen_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Doxygen_FOUND to true if Doxygen_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Doxygen
    REQUIRED_VARS
        Doxygen_EXECUTABLE
    VERSION_VAR
        Doxygen_VERSION
    FOUND_VAR
        Doxygen_FOUND
    REASON_FAILURE_MESSAGE
        "${_Doxygen_FAILURE_REASON}"
    HANDLE_RANGE)

if(Doxygen_FOUND)
    get_property(_Doxygen_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if(_Doxygen_CMAKE_ROLE STREQUAL "PROJECT")
        if(NOT TARGET Doxygen::Doxygen)
            add_executable(Doxygen::Doxygen IMPORTED)
            set_target_properties(Doxygen::Doxygen PROPERTIES
                IMPORTED_LOCATION "${Doxygen_EXECUTABLE}")
        endif()
    endif()
    unset(_Doxygen_CMAKE_ROLE)
endif()

unset(_Doxygen_SEARCH_HINTS)
unset(_Doxygen_SEARCH_PATHS)
