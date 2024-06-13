# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[=======================================================================[.rst:
FindSphinx
----------

Try to find Sphinx documentation generator's command-line tools.

This is a component-based find module, which makes use of the COMPONENTS and OPTIONAL_COMPONENTS arguments to find_module. The following components are available::

  Build Quickstart Apidoc Autogen 

If no components are specified, this module will act as though all components were passed to ``OPTIONAL_COMPONENTS``.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Sphinx::Build``
  The ``sphinx-build`` executable.

``Sphinx::Quickstart``
  The ``sphinx-quickstart`` executable.

``Sphinx::Apidoc``
  The ``sphinx-apidoc`` executable.

``Sphinx::Autogen``
  The ``sphinx-autogen`` executable.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``Sphinx_FOUND``
  System has the Sphinx. ``TRUE`` if Sphinx has been found.

``Sphinx_BUILD_EXECUTABLE``
  The full path to the ``sphinx-build`` executable.

``Sphinx_APIDOC_EXECUTABLE``
  The full path to the ``sphinx-apidoc`` executable.

``Sphinx_AUTOGEN_EXECUTABLE``
  The full path to the ``sphinx-autogen`` executable.

``Sphinx_QUICKSTART_EXECUTABLE``
  The full path to the ``sphinx-quickstart`` executable.

``Sphinx_VERSION``
  The version of Sphinx found (outputs of ``sphinx-build --version``).

``Sphinx_VERSION_MAJOR``
  The major version of Sphinx found.

``Sphinx_VERSION_MINOR``
  The minor version of Sphinx found.

``Sphinx_VERSION_PATCH``
  The patch version of Sphinx found.

Hints
^^^^^

``Sphinx_ROOT_DIR``, ``ENV{Sphinx_ROOT_DIR}``
  Define the root directory of a Sphinx installation.

``ENV{VIRTUAL_ENV}``

#]=======================================================================]

if(CMAKE_HOST_WIN32)
    set(_Sphinx_PATH_SUFFIXES Scripts)
else()
    set(_Sphinx_PATH_SUFFIXES bin)
endif()

set(_Sphinx_KNOWN_COMPONENTS
    Build
    Apidoc
    Autogen
    Quickstart)

if(NOT Sphinx_FIND_COMPONENTS)
    set(Sphinx_FIND_COMPONENTS Build Apidoc Autogen Quickstart)
    foreach(_COMP ${Sphinx_FIND_COMPONENTS})
        set(Sphinx_FIND_REQUIRED_${_COMP} TRUE)
    endforeach()
    unset(_COMP)
endif()

set(_Sphinx_SEARCH_HINTS 
    ${Sphinx_ROOT_DIR} 
    ENV Sphinx_ROOT_DIR
    ENV VIRTUAL_ENV)

set(_Sphinx_SEARCH_PATHS)

set(_Sphinx_FAILURE_REASON)

foreach(_COMP ${_Sphinx_KNOWN_COMPONENTS})
    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "sphinx-${_COMP_LOWER}")
    find_program(Sphinx_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        NAMES_PER_DIR
        PATH_SUFFIXES ${_Sphinx_PATH_SUFFIXES}
        HINTS ${_Sphinx_SEARCH_HINTS}
        PATHS ${_Sphinx_SEARCH_PATHS}
        DOC "The full path to the '${_TOOL}' executable.")
    if(Sphinx_${_COMP_UPPER}_EXECUTABLE)
        set(Sphinx_${_COMP}_FOUND TRUE)
    else()
        set(Sphinx_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

foreach(_COMP IN LISTS Sphinx_FIND_COMPONENTS)
    string(TOUPPER "${_COMP}" _COMP_UPPER)
    if(Sphinx_${_COMP_UPPER}_EXECUTABLE)
        set(Sphinx_${_COMP}_FOUND TRUE)
    else()
        set(Sphinx_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

if(Sphinx_BUILD_EXECUTABLE)
    execute_process(
        COMMAND ${Sphinx_BUILD_EXECUTABLE} --version
        OUTPUT_VARIABLE _Sphinx_VERSION_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" 
        Sphinx_VERSION ${_Sphinx_VERSION_OUTPUT})
    unset(_Sphinx_VERSION_OUTPUT)

    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" _ ${Sphinx_VERSION})
    set(Sphinx_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set(Sphinx_VERSION_MINOR "${CMAKE_MATCH_2}")
    set(Sphinx_VERSION_PATCH "${CMAKE_MATCH_3}")
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Sphinx_FOUND to true if Sphinx_BUILD_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sphinx
    REQUIRED_VARS
        Sphinx_BUILD_EXECUTABLE
    HANDLE_COMPONENTS
    # REASON_FAILURE_MESSAGE
    #     "${_Sphinx_FAILURE_REASON}"
    VERSION_VAR
        Sphinx_VERSION
    FOUND_VAR
        Sphinx_FOUND)

if(Sphinx_FOUND)
    get_property(_Sphinx_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if(_Sphinx_CMAKE_ROLE STREQUAL "PROJECT")
        #
        # add_executable is not scriptable.
        #
        foreach(_COMP ${Sphinx_FIND_COMPONENTS})
            string(TOUPPER ${_COMP} _COMP_UPPER)
            if (NOT TARGET Sphinx::${_COMP}
                AND Sphinx_${_COMP}_FOUND)
                add_executable(Sphinx::${_COMP} IMPORTED)
                set_target_properties(Sphinx::${_COMP} PROPERTIES
                    IMPORTED_LOCATION 
                        "${Sphinx_${_COMP_UPPER}_EXECUTABLE}")
            endif()
        endforeach()
    endif()
    unset(_Sphinx_CMAKE_ROLE)
endif()

unset(_Sphinx_PATH_SUFFIXES)
unset(_Sphinx_KNOWN_COMPONENTS)
unset(_Sphinx_SEARCH_HINTS)
unset(_Sphinx_SEARCH_PATHS)
unset(_Sphinx_FAILURE_REASON)
