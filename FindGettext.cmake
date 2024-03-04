#[=======================================================================[.rst:
FindGettext
-----------

Find the Gettext toolkit.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Gettext::Xgettext``
  The Gettext ``xgettext`` executable, if found.

``Gettext::Msgattrib``
  The Gettext ``msgattrib`` executable, if found.

``Gettext::Msgcat``
  The Gettext ``msgcat`` executable, if found.

``Gettext::Msgcmp``
  The Gettext ``msgcmp`` executable, if found.

``Gettext::Msgcomm``
  The Gettext ``msgcomm`` executable, if found.

``Gettext::Msgconv``
  The Gettext ``msgconv`` executable, if found.

``Gettext::Msgen``
  The Gettext ``msgen`` executable, if found.

``Gettext::Msgexec``
  The Gettext ``msgexec`` executable, if found.

``Gettext::Msgfilter``
  The Gettext ``msgfilter`` executable, if found.

``Gettext::Msgfmt``
  The Gettext ``msgfmt`` executable, if found.

``Gettext::Msggrep``
  The Gettext ``msggrep`` executable, if found.

``Gettext::Msginit``
  The Gettext ``msginit`` executable, if found.

``Gettext::Msgmerge``
  The Gettext ``msgmerge`` executable, if found.

``Gettext::Msguniq``
  The Gettext ``msguniq`` executable, if found.

``Gettext::Msgunfmt``
  The Gettext ``msgunfmt`` executable, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``Gettext_FOUND``
  System has the Gettext. TRUE if Gettext has been found.

``Gettext_XGETTEXT_EXECUTABLE``
  The full path to the Gettext ``xgettext`` executable.

``Gettext_MSGATTRIB_EXECUTABLE``
  The full path to the Gettext ``msgattrib`` executable.

``Gettext_MSGCAT_EXECUTABLE``
  The full path to the Gettext ``msgcat`` executable.

``Gettext_MSGCMP_EXECUTABLE``
  The full path to the Gettext ``msgcmp`` executable.

``Gettext_MSGCOMM_EXECUTABLE``
  The full path to the Gettext ``msgcomm`` executable.

``Gettext_MSGCONV_EXECUTABLE``
  The full path to the Gettext ``msgconv`` executable.

``Gettext_MSGEN_EXECUTABLE``
  The full path to the Gettext ``msgen`` executable.

``Gettext_MSGEXEC_EXECUTABLE``
  The full path to the Gettext ``msgexec`` executable.

``Gettext_MSGFILTER_EXECUTABLE``
  The full path to the Gettext ``msgfilter`` executable.

``Gettext_MSGFMT_EXECUTABLE``
  The full path to the Gettext ``msgfmt`` executable.

``Gettext_MSGGREP_EXECUTABLE``
  The full path to the Gettext ``msggrep`` executable.

``Gettext_MSGINIT_EXECUTABLE``
  The full path to the Gettext ``msginit`` executable.

``Gettext_MSGMERGE_EXECUTABLE``
  The full path to the Gettext ``msgmerge`` executable.

``Gettext_MSGUNIQ_EXECUTABLE``
  The full path to the Gettext ``msguniq`` executable.

``Gettext_MSGUNFMT_EXECUTABLE``
  The full path to the Gettext ``msgunfmt`` executable.

``Gettext_VERSION``
  The version of Gettext found.

``Gettext_VERSION_MAJOR``
  The major version of the Gettext found.

``Gettext_VERSION_MINOR``
  The minor version of the Gettext found.

Hints
^^^^^

``Gettext_ROOT_DIR``, ``ENV{Gettext_ROOT_DIR}``
  Define the root directory of a Gettext installation.

#]=======================================================================]

set(_MODULE "${CMAKE_FIND_PACKAGE_NAME}")

# message("_MODULE = Gettext")
# message("Gettext_FIND_COMPONENTS         = ${Gettext_FIND_COMPONENTS}")
# message("Gettext_FIND_QUIETLY            = ${Gettext_FIND_QUIETLY}")
# message("Gettext_FIND_REQUIRED           = ${Gettext_FIND_REQUIRED}")
# message("Gettext_FIND_REQUIRED_Xgettext  = ${Gettext_FIND_REQUIRED_Xgettext}")
# message("Gettext_FIND_REQUIRED_Msgfmt    = ${Gettext_FIND_REQUIRED_Msgfmt}")
# foreach(_COMP IN LISTS Gettext_FIND_COMPONENTS)
#     message("Gettext_FIND_REQUIRED_${_COMP} = ${Gettext_FIND_REQUIRED_${_COMP}}")
# endforeach()
# unset(_COMP)

set(_Gettext_KNOWN_COMPONENTS
    Xgettext
    Msgattrib
    Msgcat
    Msgcmp
    Msgcomm
    Msgconv
    Msgen
    Msgexec
    Msgfilter
    Msgfmt
    Msggrep
    Msginit
    Msgmerge
    Msguniq
    Msgunfmt)

# if(NOT Gettext_FIND_COMPONENTS)
#     set(Gettext_FIND_COMPONENTS Xgettext)
#     set(Gettext_FIND_REQUIRED_Xgettext TRUE)
# endif()
if(NOT Gettext_FIND_COMPONENTS)
    set(Gettext_FIND_COMPONENTS ${_Gettext_KNOWN_COMPONENTS})
    foreach(_COMP ${_Gettext_KNOWN_COMPONENTS})
        set(Gettext_FIND_REQUIRED_${_COMP} TRUE)
    endforeach()
    unset(_COMP)
endif()

set(_Gettext_SEARCH_HINTS 
    ${Gettext_ROOT_DIR} 
    ENV Gettext_ROOT_DIR)

set(_Gettext_SEARCH_PATHS 
    "$ENV{ProgramFiles}\\gettext-iconv\\bin"
    "$ENV{ProgramFiles}\\Git\\usr\\bin")

foreach(_COMP ${_Gettext_KNOWN_COMPONENTS})
    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "${_COMP_LOWER}")
    find_program(Gettext_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        # NO_PACKAGE_ROOT_PATH            # 1st: paths in <PackageName>_ROOT cache/environment variables.
        # NO_CMAKE_PATH                   # 2nd: paths in cmake-specific cache variables.
        # NO_CMAKE_ENVIRONMENT_PATH       # 3rd: paths in cmake-specific environment variables.
        HINTS ${_Gettext_SEARCH_HINTS}    # 4th: paths in HINTS option.
        # NO_SYSTEM_ENVIRONMENT_PATH      # 5th: paths in standard system environment variables (PATH env).
        # NO_CMAKE_SYSTEM_PATH            # 6th: paths in cmake variables defined in Platform files.
        PATHS ${_Gettext_SEARCH_PATHS}    # 7th: paths in PATHS option.
        DOC "The full path to the ${_TOOL} executable.")
    if(Gettext_${_COMP_UPPER}_EXECUTABLE)
        set(Gettext_${_COMP}_FOUND TRUE)
    endif()
endforeach()
unset(_COMP)

foreach(_COMP IN LISTS Gettext_FIND_COMPONENTS)
    string(TOUPPER "${_COMP}" _COMP_UPPER)
    if(EXISTS "${Gettext_${_COMP_UPPER}_EXECUTABLE}")
        set(Gettext_${_COMP}_FOUND TRUE)
    else()
        set(Gettext_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

if(Gettext_XGETTEXT_EXECUTABLE)
    execute_process(
        COMMAND "${Gettext_XGETTEXT_EXECUTABLE}" --version
        OUTPUT_VARIABLE _XGETTEXT_VERSION_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    string(REGEX MATCH "([0-9]+\\.[0-9]+)"
        Gettext_VERSION ${_XGETTEXT_VERSION_OUTPUT})

    string(REGEX MATCH "([0-9]+)\\.([0-9]+)" _ ${Gettext_VERSION})
    set(Gettext_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set(Gettext_VERSION_MINOR "${CMAKE_MATCH_2}")
endif()

# Handle REQUIRED and QUIET arguments
# this will also set SPHINX_FOUND to true if Gettext_XGETTEXT_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Gettext
    REQUIRED_VARS
        Gettext_XGETTEXT_EXECUTABLE
    VERSION_VAR
        Gettext_VERSION
    FOUND_VAR
        Gettext_FOUND
    FAIL_MESSAGE
        "Failed to find Gettext toolkit"
    HANDLE_COMPONENTS)

if(Gettext_FOUND)
    get_property(_Gettext_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if(_Gettext_CMAKE_ROLE STREQUAL "PROJECT")
        #
        # add_executable is not scriptable
        #
        foreach(_COMP ${Gettext_FIND_COMPONENTS})
            string(TOUPPER ${_COMP} _COMP_UPPER)
            if (NOT TARGET Gettext::${_COMP}
                AND Gettext_${_COMP}_FOUND)
                add_executable(Gettext::${_COMP} IMPORTED)
                set_target_properties(Gettext::${_COMP} PROPERTIES
                    IMPORTED_LOCATION 
                        "${Gettext_${_COMP_UPPER}_EXECUTABLE}")
            endif()
        endforeach()
    endif()
endif()
