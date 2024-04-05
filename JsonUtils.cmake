# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[============================================================[.rst
JsonUtils
---------

Initialize a reference.json file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: init_reference_json_file

  Initialize a `reference.json` file of `branch` type:

  .. code-block:: cmake

    init_reference_json_file(
        IN_FILEPATH  "${CMAKE_CURRENT_LIST_DIR}/reference.json"
        IN_LANGUAGES "zh_CN;zh_TW"
        IN_TYPE      "branch"
        IN_VERSION   "master")

  Initialize a `reference.json` file of `tag` type:

  .. code-block:: cmake

    init_reference_json_file(
        IN_FILEPATH  "${CMAKE_CURRENT_LIST_DIR}/reference.json"
        IN_LANGUAGES "zh_CN;zh_TW"
        IN_TYPE      "tag"
        IN_VERSION   "master")

Get Members of Json Object
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: get_members_of_json_object

  .. code-block:: cmake

    get_members_of_json_object(
        IN_JSON_OBJECT      "${JSON_CNT}"
        OUT_MEMBER_NAMES    MEMBER_NAMES
        OUT_MEMBER_VALUES   MEMBER_VALUES
        OUT_MEMBER_NUMBER   MEMBER_NUMBER)

Set Members of Json Object for language and commit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: set_members_of_language_json_object

  .. code-block:: cmake

    set_members_of_language_json_object(
        IN_TYPE           "tag"
        IN_MEMBER_TAG     "\"${repo_latest_tag}\""
        OUT_JSON_OBJECT   LANGUAGE_CNT)

  .. code-block:: cmake

    set_members_of_language_json_object(
        IN_TYPE           "branch"
        IN_MEMBER_BRANCH  "\"${IN_VERSION}\""
        IN_MEMBER_COMMIT  "${COMMIT_CNT}"
        OUT_JSON_OBJECT   LANGUAGE_CNT)

.. command:: set_members_of_commit_json_object

  .. code-block:: cmake

    set_members_of_commit_json_object(
        IN_MEMBER_DATE    "\"2023-07-19 14:40:53 -0400\""
        IN_MEMBER_HASH    "\"0baa8af568bcb0b0caadb7cedcb21353396cae7b\""
        IN_MEMBER_TITLE   "\"Merge branch 'release-3.27'\""
        OUT_JSON_OBJECT   COMMIT_CNT)

Dot Notation Setter/Getter
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: set_json_value_by_dot_notation

  .. code-block:: cmake

    set_json_value_by_dot_notation(
        IN_JSON_OBJECT    "${JSON_CNT}"
        IN_DOT_NOTATION   "po.zh_TW"
        IN_VALUE          "${poLocaleValue}"
        OUT_JSON_OBJECT   JSON_CNT)

.. command:: get_json_value_by_dot_notation

  .. code-block:: cmake

    get_json_value_by_dot_notation(
        IN_JSON_OBJECT    "${JSON_CNT}"
        IN_DOT_NOTATION   "pot"
        OUT_VALUE         potValue)

#]============================================================]

#
# Initialize a reference.json file
#
function(init_reference_json_file)
    #
    # Parse arguments.
    #
    set(VERSION_OPTIONS)
    set(VERSION_ONE_VALUE_ARGS    IN_TYPE 
                                  IN_FILEPATH 
                                  IN_VERSION)
    set(VERSION_MULTI_VALUE_ARGS  IN_LANGUAGES)
    cmake_parse_arguments(ARGS 
        "${VERSION_OPTIONS}" 
        "${VERSION_ONE_VALUE_ARGS}" 
        "${VERSION_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    # (IN_TYPE, IN_FILEPATH, IN_VERSION)
    #
    foreach(_ARG ${VERSION_ONE_VALUE_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Initialize or create the JSON file at specified ${ARGS_IN_FILEPATH}.
    #
    set(_FILEPATH "${ARGS_IN_FILEPATH}")
    if(NOT EXISTS "${_FILEPATH}")
        get_filename_component(_FILEPATH_DIR "${_FILEPATH}" DIRECTORY)
        file(MAKE_DIRECTORY "${_FILEPATH_DIR}")
        file(TOUCH "${_FILEPATH}")
    endif()
    file(READ "${_FILEPATH}" JSON_CNT)
    if(NOT JSON_CNT)
        set(JSON_CNT "{}")
    endif()
    #
    # Initialize 'version' property based on ${ARGS_IN_VERSION}.
    #
    string(JSON JSON_CNT SET ${JSON_CNT} "version" "\"${ARGS_IN_VERSION}\"")
    #
    # Initialize 'type' property based on ${ARGS_IN_TYPE}.
    #
    string(JSON JSON_CNT SET ${JSON_CNT} "type" "\"${ARGS_IN_TYPE}\"")
    #
    # Initialize 'pot' and 'po' properties based on ${ARGS_IN_TYPE}.
    #
    if(ARGS_IN_TYPE STREQUAL "tag")
        #
        # For 'tag' type:
        # (1)   Initialize 'pot' property as empty if missing.
        # (1.1) Initialize 'pot.${LANGUAGE_PROP_NAME}' property as empty if missing.
        # (2)   Initialize 'po' property as empty if missing.
        # (2.1) Initialize 'po.${_LANGUAGE}' objects as empty if missing.
        # (2.2) Initialize 'po.${_LANGUAGE}.${LANGUAGE_PROP_NAME}' property as empty if missing.
        #
        set(LANGUAGE_LIST ${ARGS_IN_LANGUAGES})
        set(LANGUAGE_PROP_NAME_LIST tag)
        set(LANGUAGE_PROP_TYPE_LIST STRING)
        #
        # (1) Initialize 'pot' property as empty if missing.
        #
        string(JSON pot_CNT ERROR_VARIABLE pot_ERR GET ${JSON_CNT} "pot")
        if(NOT pot_ERR STREQUAL "NOTFOUND")
            set(pot_CNT "{}")
            string(JSON JSON_CNT SET ${JSON_CNT} "pot" "${pot_CNT}")
        endif()
        list(LENGTH LANGUAGE_PROP_NAME_LIST LANGUAGE_PROP_NUM)
        math(EXPR LANGUAGE_PROP_MAX_ID "${LANGUAGE_PROP_NUM} - 1")
        foreach(_ID RANGE ${LANGUAGE_PROP_MAX_ID})
            #
            # (1.1) Initialize 'pot.${LANGUAGE_PROP_NAME}' property as empty if missing.
            #
            list(GET LANGUAGE_PROP_NAME_LIST ${_ID} LANGUAGE_PROP_NAME)
            list(GET LANGUAGE_PROP_TYPE_LIST ${_ID} LANGUAGE_PROP_TYPE)
            string(JSON ${LANGUAGE_PROP_NAME}_CNT 
                ERROR_VARIABLE ${LANGUAGE_PROP_NAME}_ERR 
                GET ${pot_CNT} "${LANGUAGE_PROP_NAME}")
            if(NOT ${LANGUAGE_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (LANGUAGE_PROP_TYPE STREQUAL "STRING")
                    set(${LANGUAGE_PROP_NAME}_CNT "\"\"")
                endif()
                string(JSON pot_CNT SET ${pot_CNT} 
                    "${LANGUAGE_PROP_NAME}" "${${LANGUAGE_PROP_NAME}_CNT}")
            endif()
        endforeach()
        unset(_ID)
        string(JSON JSON_CNT SET ${JSON_CNT} "pot" "${pot_CNT}")
        #
        # (2) Initialize 'po' property as empty if missing.
        #
        string(JSON po_CNT ERROR_VARIABLE po_ERR GET ${JSON_CNT} "po")
        if(NOT po_ERR STREQUAL "NOTFOUND")
            set(po_CNT "{}")
            string(JSON JSON_CNT SET ${JSON_CNT} "po" "${po_CNT}")
        endif()
        foreach(_LANGUAGE ${LANGUAGE_LIST})
            #
            # (2.1) Initialize 'po.${_LANGUAGE}' objects as empty if missing.
            #
            string(JSON LANGUAGE_CNT ERROR_VARIABLE LANGUAGE_ERR GET ${po_CNT} "${_LANGUAGE}")
            if(NOT LANGUAGE_ERR STREQUAL "NOTFOUND")
                set(LANGUAGE_CNT "{}")
                string(JSON po_CNT SET ${po_CNT} "${_LANGUAGE}" "${LANGUAGE_CNT}")
            endif()
            list(LENGTH LANGUAGE_PROP_NAME_LIST LANGUAGE_PROP_NUM)
            math(EXPR LANGUAGE_PROP_MAX_ID "${LANGUAGE_PROP_NUM} - 1")
            foreach(_ID RANGE ${LANGUAGE_PROP_MAX_ID})
                #
                # (2.2) Initialize 'po.${_LANGUAGE}.${LANGUAGE_PROP_NAME}' property as empty if missing.
                #
                list(GET LANGUAGE_PROP_NAME_LIST ${_ID} LANGUAGE_PROP_NAME)
                list(GET LANGUAGE_PROP_TYPE_LIST ${_ID} LANGUAGE_PROP_TYPE)
                string(JSON ${LANGUAGE_PROP_NAME}_CNT 
                    ERROR_VARIABLE ${LANGUAGE_PROP_NAME}_ERR 
                    GET ${LANGUAGE_CNT} "${LANGUAGE_PROP_NAME}")
                if(NOT ${LANGUAGE_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                    if (LANGUAGE_PROP_TYPE STREQUAL "STRING")
                        set(${LANGUAGE_PROP_NAME}_CNT "\"\"")
                    endif()
                    string(JSON LANGUAGE_CNT SET ${LANGUAGE_CNT} "${LANGUAGE_PROP_NAME}" "${${LANGUAGE_PROP_NAME}_CNT}")
                endif()
            endforeach()
            unset(_ID)
            string(JSON po_CNT SET ${po_CNT} "${_LANGUAGE}" "${LANGUAGE_CNT}")
        endforeach()
        unset(_LANGUAGE)
        string(JSON JSON_CNT SET ${JSON_CNT} "po" "${po_CNT}")
    elseif(ARGS_IN_TYPE STREQUAL "branch")
        #
        # For 'branch' type:
        # (1)   Initialize 'pot' property as empty if missing.
        # (1.1) Initialize 'pot.${LANGUAGE_PROP_NAME}' property as empty if missing.
        # (1.2) Initialize 'pot.commit.${COMMIT_PROP_NAME}' property as empty if missing.
        # (2)   Initialize 'po' property as empty if missing.
        # (2.1) Initialize 'po.${_LANGUAGE}' objects as empty if missing.
        # (2.2) Initialize 'po.${_LANGUAGE}.${LANGUAGE_PROP_NAME}' property as empty if missing.
        # (2.3) Initialize 'po.${_LANGUAGE}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
        #
        set(LANGUAGE_LIST ${ARGS_IN_LANGUAGES})
        set(LANGUAGE_PROP_NAME_LIST branch commit)
        set(LANGUAGE_PROP_TYPE_LIST STRING OBJECT)
        set(COMMIT_PROP_NAME_LIST date hash title)
        set(COMMIT_PROP_TYPE_LIST STRING STRING STRING)
        #
        # (1) Initialize 'pot' property as empty if missing.
        #
        string(JSON pot_CNT ERROR_VARIABLE pot_ERR GET ${JSON_CNT} "pot")
        if(NOT pot_ERR STREQUAL "NOTFOUND")
            set(pot_CNT "{}")
            string(JSON JSON_CNT SET ${JSON_CNT} "pot" "${pot_CNT}")
        endif()
        list(LENGTH LANGUAGE_PROP_NAME_LIST LANGUAGE_PROP_NUM)
        math(EXPR LANGUAGE_PROP_MAX_ID "${LANGUAGE_PROP_NUM} - 1")
        foreach(LANGUAGE_PROP_ID RANGE ${LANGUAGE_PROP_MAX_ID})
            #
            # (1.1) Initialize 'pot.${LANGUAGE_PROP_NAME}' property as empty if missing.
            #
            list(GET LANGUAGE_PROP_NAME_LIST ${LANGUAGE_PROP_ID} LANGUAGE_PROP_NAME)
            list(GET LANGUAGE_PROP_TYPE_LIST ${LANGUAGE_PROP_ID} LANGUAGE_PROP_TYPE)
            string(JSON ${LANGUAGE_PROP_NAME}_CNT 
                ERROR_VARIABLE ${LANGUAGE_PROP_NAME}_ERR 
                GET ${pot_CNT} "${LANGUAGE_PROP_NAME}")
            if(NOT ${LANGUAGE_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (LANGUAGE_PROP_TYPE STREQUAL "STRING")
                    set(${LANGUAGE_PROP_NAME}_CNT "\"\"")
                elseif (LANGUAGE_PROP_TYPE STREQUAL "OBJECT")
                    set(${LANGUAGE_PROP_NAME}_CNT "{}")
                endif()
                string(JSON pot_CNT SET ${pot_CNT} "${LANGUAGE_PROP_NAME}" "${${LANGUAGE_PROP_NAME}_CNT}")
            endif()
            if(LANGUAGE_PROP_NAME STREQUAL "commit")
                #
                # (1.2) Initialize 'pot.commit.${COMMIT_PROP_NAME}' property as empty if missing.
                #
                list(LENGTH COMMIT_PROP_NAME_LIST COMMIT_PROP_NUM)
                math(EXPR COMMIT_PROP_MAX_ID "${COMMIT_PROP_NUM} - 1")
                foreach(COMMIT_PROP_ID RANGE ${COMMIT_PROP_MAX_ID})
                    list(GET COMMIT_PROP_NAME_LIST ${COMMIT_PROP_ID} COMMIT_PROP_NAME)
                    list(GET COMMIT_PROP_TYPE_LIST ${COMMIT_PROP_ID} COMMIT_PROP_TYPE)
                    string(JSON ${COMMIT_PROP_NAME}_CNT 
                        ERROR_VARIABLE ${COMMIT_PROP_NAME}_ERR 
                        GET ${commit_CNT} "${COMMIT_PROP_NAME}")
                    if(NOT ${COMMIT_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                        if (COMMIT_PROP_TYPE STREQUAL "STRING")
                            set(${COMMIT_PROP_NAME}_CNT "\"\"")
                        elseif (COMMIT_PROP_TYPE STREQUAL "OBJECT")
                            set(${COMMIT_PROP_NAME}_CNT "{}")
                        endif()
                        string(JSON commit_CNT SET ${commit_CNT} 
                            "${COMMIT_PROP_NAME}" "${${COMMIT_PROP_NAME}_CNT}")
                    endif()
                endforeach()
                string(JSON pot_CNT SET ${pot_CNT} "commit" "${commit_CNT}")
            endif()
        endforeach()
        unset(LANGUAGE_PROP_ID)
        string(JSON JSON_CNT SET ${JSON_CNT} "pot" "${pot_CNT}")
        #
        # (2) Initialize 'po' property as empty if missing.
        #
        string(JSON po_CNT ERROR_VARIABLE po_ERR GET ${JSON_CNT} "po")
        if(NOT po_ERR STREQUAL "NOTFOUND")
            set(po_CNT "{}")
            string(JSON JSON_CNT SET ${JSON_CNT} "po" "${po_CNT}")
        endif()
        foreach(_LANGUAGE ${LANGUAGE_LIST})
            #
            # (2.1) Initialize 'po.${_LANGUAGE}' objects as empty if missing.
            #
            string(JSON LANGUAGE_CNT ERROR_VARIABLE LANGUAGE_ERR GET ${po_CNT} "${_LANGUAGE}")
            if(NOT LANGUAGE_ERR STREQUAL "NOTFOUND")
                set(LANGUAGE_CNT "{}")
                string(JSON po_CNT SET ${po_CNT} "${_LANGUAGE}" "${LANGUAGE_CNT}")
            endif()
            list(LENGTH LANGUAGE_PROP_NAME_LIST LANGUAGE_PROP_NUM)
            math(EXPR LANGUAGE_PROP_MAX_ID "${LANGUAGE_PROP_NUM} - 1")
            foreach(LANGUAGE_PROP_ID RANGE ${LANGUAGE_PROP_MAX_ID})
                #
                # (2.2) Initialize 'po.${_LANGUAGE}.${LANGUAGE_PROP_NAME}' property as empty if missing.
                #
                list(GET LANGUAGE_PROP_NAME_LIST ${LANGUAGE_PROP_ID} LANGUAGE_PROP_NAME)
                list(GET LANGUAGE_PROP_TYPE_LIST ${LANGUAGE_PROP_ID} LANGUAGE_PROP_TYPE)
                string(JSON ${LANGUAGE_PROP_NAME}_CNT 
                    ERROR_VARIABLE ${LANGUAGE_PROP_NAME}_ERR 
                    GET ${LANGUAGE_CNT} "${LANGUAGE_PROP_NAME}")
                if(NOT ${LANGUAGE_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                    if (LANGUAGE_PROP_TYPE STREQUAL "STRING")
                        set(${LANGUAGE_PROP_NAME}_CNT "\"\"")
                    elseif (LANGUAGE_PROP_TYPE STREQUAL "OBJECT")
                        set(${LANGUAGE_PROP_NAME}_CNT "{}")
                    endif()
                    string(JSON LANGUAGE_CNT SET ${LANGUAGE_CNT} 
                        "${LANGUAGE_PROP_NAME}" "${${LANGUAGE_PROP_NAME}_CNT}")
                endif()
                if(LANGUAGE_PROP_NAME STREQUAL "commit")
                    list(LENGTH COMMIT_PROP_NAME_LIST COMMIT_PROP_NUM)
                    math(EXPR COMMIT_PROP_MAX_ID "${COMMIT_PROP_NUM} - 1")
                    foreach(COMMIT_PROP_ID RANGE ${COMMIT_PROP_MAX_ID})
                        #
                        # (2.3) Initialize 'po.${_LANGUAGE}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
                        #
                        list(GET COMMIT_PROP_NAME_LIST ${COMMIT_PROP_ID} COMMIT_PROP_NAME)
                        list(GET COMMIT_PROP_TYPE_LIST ${COMMIT_PROP_ID} COMMIT_PROP_TYPE)
                        string(JSON ${COMMIT_PROP_NAME}_CNT 
                            ERROR_VARIABLE ${COMMIT_PROP_NAME}_ERR 
                            GET ${commit_CNT} "${COMMIT_PROP_NAME}")
                        if(NOT ${COMMIT_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                            if (COMMIT_PROP_TYPE STREQUAL "STRING")
                                set(${COMMIT_PROP_NAME}_CNT "\"\"")
                            elseif (COMMIT_PROP_TYPE STREQUAL "OBJECT")
                                set(${COMMIT_PROP_NAME}_CNT "{}")
                            endif()
                            string(JSON commit_CNT SET ${commit_CNT} 
                                "${COMMIT_PROP_NAME}" "${${COMMIT_PROP_NAME}_CNT}")
                        endif()
                    endforeach()
                    string(JSON LANGUAGE_CNT SET ${LANGUAGE_CNT} "commit" "${commit_CNT}")
                endif()
            endforeach()
            string(JSON po_CNT SET ${po_CNT} "${_LANGUAGE}" "${LANGUAGE_CNT}")
        endforeach()
        unset(_LANGUAGE)
        string(JSON JSON_CNT SET ${JSON_CNT} "po" "${po_CNT}")
    else()
        message(FATAL_ERROR "Invalid ARGS_IN_TYPE argument...")
    endif()
    #
    # Write ${JSON_CNT} into ${_FILEPATH}
    #
    file(WRITE "${_FILEPATH}" ${JSON_CNT})
endfunction()

#
# Get members of JSON object
#
function(get_members_of_json_object)
    #
    # Parse arguments.
    #
    set(MEMBER_OPTIONS)
    set(MEMBER_ONE_VALUE_ARGS     IN_JSON_OBJECT
                                  OUT_MEMBER_NAMES 
                                  OUT_MEMBER_VALUES
                                  OUT_MEMBER_NUMBER)
    set(MEMBER_MULTI_VALUE_ARGS)
    cmake_parse_arguments(ARGS 
        "${MEMBER_OPTIONS}" 
        "${MEMBER_ONE_VALUE_ARGS}" 
        "${MEMBER_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS             IN_JSON_OBJECT)
    foreach(_ARG ${REQUIRED_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Extract and store member names and values.
    #
    set(MEMBER_NAMES)
    set(MEMBER_VALUES)
    string(JSON MEMBER_LENGTH LENGTH ${ARGS_IN_JSON_OBJECT})
    math(EXPR MEMBER_MAX_ID "${MEMBER_LENGTH} - 1")
    foreach(MEMBER_ID RANGE ${MEMBER_MAX_ID})
        string(JSON MEMBER_NAME MEMBER ${ARGS_IN_JSON_OBJECT} "${MEMBER_ID}")
        string(JSON MEMBER_VALUE GET ${ARGS_IN_JSON_OBJECT} "${MEMBER_NAME}")
        list(APPEND MEMBER_NAMES "${MEMBER_NAME}")
        list(APPEND MEMBER_VALUES "${MEMBER_VALUE}")
    endforeach()
    unset(MEMBER_ID)
    #
    # Return OUT_MEMBER_NAMES, OUT_MEMBER_VALUES, and OUT_MEMBER_NUMBER.
    #
    if(ARGS_OUT_MEMBER_NAMES)
        set(${ARGS_OUT_MEMBER_NAMES} ${MEMBER_NAMES} PARENT_SCOPE)
    endif()
    if(ARGS_OUT_MEMBER_VALUES)
        set(${ARGS_OUT_MEMBER_VALUES} ${MEMBER_VALUES} PARENT_SCOPE)
    endif()
    if(ARGS_OUT_MEMBER_NUMBER)
        set(${ARGS_OUT_MEMBER_NUMBER} ${MEMBER_LENGTH} PARENT_SCOPE)
    endif()
endfunction()

#
# Set members of JSON object for 'commit'
#
function(set_members_of_commit_json_object)
    #
    # Parse arguments.
    #
    set(COMMIT_OPTIONS)
    set(COMMIT_ONE_VALUE_ARGS       IN_MEMBER_DATE 
                                    IN_MEMBER_HASH 
                                    IN_MEMBER_TITLE 
                                    OUT_JSON_OBJECT)
    set(COMMIT_MULTI_VALUE_ARGS)
    cmake_parse_arguments(ARGS 
        "${COMMIT_OPTIONS}" 
        "${COMMIT_ONE_VALUE_ARGS}" 
        "${COMMIT_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Validate required arguments.
    #
    set(REQUIRED_ARGS ${COMMIT_ONE_VALUE_ARGS})
    foreach(_ARG ${REQUIRED_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Construct JSON object for 'commit'
    #
    set(COMMIT_OBJECT "{}")
    string(JSON COMMIT_OBJECT SET ${COMMIT_OBJECT} "date"  "${ARGS_IN_MEMBER_DATE}")
    string(JSON COMMIT_OBJECT SET ${COMMIT_OBJECT} "hash"  "${ARGS_IN_MEMBER_HASH}")
    string(JSON COMMIT_OBJECT SET ${COMMIT_OBJECT} "title" "${ARGS_IN_MEMBER_TITLE}")
    #
    # Set constructed JSON object to output variable
    #
    set(${ARGS_OUT_JSON_OBJECT} ${COMMIT_OBJECT} PARENT_SCOPE)
endfunction()

#
# Set members of JSON object for 'language'
#
function(set_members_of_language_json_object)
    #
    # Parse arguments.
    #
    set(LANGUAGE_OPTIONS)
    set(LANGUAGE_ONE_VALUE_ARGS   IN_TYPE
                                  IN_MEMBER_BRANCH
                                  IN_MEMBER_COMMIT
                                  IN_MEMBER_TAG  
                                  OUT_JSON_OBJECT)
    set(LANGUAGE_MULTI_VALUE_ARGS)
    cmake_parse_arguments(ARGS 
        "${LANGUAGE_OPTIONS}" 
        "${LANGUAGE_ONE_VALUE_ARGS}" 
        "${LANGUAGE_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS             IN_TYPE
                                  OUT_JSON_OBJECT)
    foreach(_ARG ${REQUIRED_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Construct JSON object for 'language' based on ${ARGS_IN_TYPE}.
    #
    set(LANGUAGE_OBJECT "{}")
    if(ARGS_IN_TYPE STREQUAL "branch")
        if(NOT DEFINED ARGS_IN_MEMBER_BRANCH)
            message(FATAL_ERROR "Missing ARGS_IN_MEMBER_BRANCH argument.")
        endif()
        if(NOT DEFINED ARGS_IN_MEMBER_COMMIT)
            message(FATAL_ERROR "Missing ARGS_IN_MEMBER_COMMIT argument.")
        endif()
        string(JSON LANGUAGE_OBJECT SET ${LANGUAGE_OBJECT} "branch" "${ARGS_IN_MEMBER_BRANCH}")
        string(JSON LANGUAGE_OBJECT SET ${LANGUAGE_OBJECT} "commit" "${ARGS_IN_MEMBER_COMMIT}")
    elseif(ARGS_IN_TYPE STREQUAL "tag")
        if(NOT DEFINED ARGS_IN_MEMBER_TAG)
            message(FATAL_ERROR "Missing ARGS_IN_MEMBER_TAG argument.")
        endif()
        string(JSON LANGUAGE_OBJECT SET ${LANGUAGE_OBJECT} "tag" "${ARGS_IN_MEMBER_TAG}")
    else()
        message(FATAL_ERROR "Missing/Invalid IN_TYPE argument...")
    endif()
    #
    # Return the Content of ${LANGUAGE_OBJECT} to OUT_JSON_OBJECT
    #
    set(${ARGS_OUT_JSON_OBJECT} ${LANGUAGE_OBJECT} PARENT_SCOPE)
endfunction()

#
# Dot Notation Setter
#
function(set_json_value_by_dot_notation)
    #
    # Parse arguments.
    #
    set(DOT_OPTIONS)
    set(DOT_ONE_VALUE_ARGS      ERROR_VARIABLE
                                IN_JSON_OBJECT 
                                IN_DOT_NOTATION 
                                IN_JSON_VALUE 
                                OUT_JSON_OBJECT)
    set(DOT_MULTI_VALUE_ARGS)
    cmake_parse_arguments(ARGS 
        "${DOT_OPTIONS}" 
        "${DOT_ONE_VALUE_ARGS}" 
        "${DOT_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS           IN_JSON_OBJECT 
                                IN_DOT_NOTATION
                                IN_JSON_VALUE 
                                OUT_JSON_OBJECT)
    foreach(_ARG ${REQUIRED_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Ensure all required arguments are provided.
    #
    if(ARGS_IN_DOT_NOTATION MATCHES "^\\.")
        string(SUBSTRING ${ARGS_IN_DOT_NOTATION} 1 -1 ARGS_IN_DOT_NOTATION_NO_1ST_DOT)
    else()
        #
        # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
        # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
        #
        set(ERROR_MESSAGE "Dot Notation must start with a '.' (${ARGS_IN_DOT_NOTATION})")
        if(DEFINED ARGS_ERROR_VARIABLE)
            set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "${ERROR_MESSAGE}")
        endif()
    endif()
    #
    # Split the dot notation path and collect property names and JSON fragments.
    #
    set(NAME_STACK)
    set(JSON_STACK)
    set(CUR_NAME)
    set(CUR_PATH ${ARGS_IN_DOT_NOTATION_NO_1ST_DOT})
    set(CUR_JSON ${ARGS_IN_JSON_OBJECT})
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/4
    if (NOT "${CUR_PATH}" STREQUAL "")
        list(APPEND JSON_STACK ${CUR_JSON})
    endif()
    while(CUR_PATH MATCHES "\\.")
        string(FIND "${CUR_PATH}" "." DOT_POS)
        math(EXPR DOT_NEXT_POS "${DOT_POS} + 1")
        string(SUBSTRING "${CUR_PATH}" 0 ${DOT_POS}       CUR_NAME)
        string(SUBSTRING "${CUR_PATH}" ${DOT_NEXT_POS} -1 CUR_PATH)        
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET ${CUR_JSON} "${CUR_NAME}")
        if(CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${ARGS_IN_DOT_NOTATION})")
            if(DEFINED ARGS_ERROR_VARIABLE)
                set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
        list(APPEND NAME_STACK ${CUR_NAME})
        list(APPEND JSON_STACK ${CUR_JSON})
    endwhile()
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/4
    if ("${CUR_NAME}" STREQUAL "" AND "${CUR_PATH}" STREQUAL "")
        #
        # If the dot notation is '.', 
        # then no post-processing is needed after the while loop is executed.
        #
    else()
        #
        # If the dot notation is the correct syntax of '.xxx.yyy.zzz', 
        # then push the CUR_PATH at the end of the while loop into NAME_STACK as CUR_NAME.
        #
        set(CUR_NAME "${CUR_PATH}")
        set(CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET ${CUR_JSON} "${CUR_NAME}")
        if(CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${ARGS_IN_DOT_NOTATION})")
            if(DEFINED ARGS_ERROR_VARIABLE)
                set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
        list(APPEND NAME_STACK ${CUR_NAME})
    endif()
    #
    # Update the value at the specified path by reversing through the property names and JSON fragments.
    #
    set(CUR_NAME)
    set(CUR_JSON)
    set(CUR_VALUE ${ARGS_IN_JSON_VALUE})
    while(JSON_STACK)
        list(POP_BACK NAME_STACK CUR_NAME)
        list(POP_BACK JSON_STACK CUR_JSON)
        string(JSON CUR_JSON SET ${CUR_JSON} "${CUR_NAME}" "${CUR_VALUE}")
        set(CUR_VALUE ${CUR_JSON})
    endwhile()
    if(NOT CUR_JSON)
        set(CUR_JSON ${CUR_VALUE})
    endif()
    #
    # Return the Content of ${CUR_JSON} to OUT_JSON_OBJECT.
    #
    set(${ARGS_ERROR_VARIABLE} "NOTFOUND" PARENT_SCOPE)
    set(${ARGS_OUT_JSON_OBJECT} ${CUR_JSON} PARENT_SCOPE)
endfunction()

#
# Dot Notation Setter
#
function(get_json_value_by_dot_notation)
    #
    # Parse arguments.
    #
    set(DOT_OPTIONS)
    set(DOT_ONE_VALUE_ARGS      ERROR_VARIABLE
                                IN_JSON_OBJECT 
                                IN_DOT_NOTATION 
                                OUT_JSON_VALUE)
    set(DOT_MULTI_VALUE_ARGS)
    cmake_parse_arguments(ARGS 
        "${DOT_OPTIONS}" 
        "${DOT_ONE_VALUE_ARGS}" 
        "${DOT_MULTI_VALUE_ARGS}" 
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS           IN_JSON_OBJECT 
                                IN_DOT_NOTATION 
                                OUT_JSON_VALUE)
    foreach(_ARG ${REQUIRED_ARGS})
        if(NOT DEFINED ARGS_${_ARG})
            message(FATAL_ERROR "Missing ARGS_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Validate the IN_DOT_NOTATION argument.
    #
    if(ARGS_IN_DOT_NOTATION MATCHES "^\\.")
        string(SUBSTRING ${ARGS_IN_DOT_NOTATION} 1 -1 ARGS_IN_DOT_NOTATION_NO_1ST_DOT)
    else()
        #
        # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
        # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
        #
        set(ERROR_MESSAGE "Dot Notation must start with a '.' (${ARGS_IN_DOT_NOTATION})")
        if(DEFINED ARGS_ERROR_VARIABLE)
            set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "${ERROR_MESSAGE}")
        endif()
    endif()
    #
    # Navigate through the JSON object using the dot notation to find the desired value.
    # Split the dot notation at each dot to traverse nested objects.
    #
    set(CUR_NAME)
    set(CUR_PATH ${ARGS_IN_DOT_NOTATION_NO_1ST_DOT})
    set(CUR_JSON ${ARGS_IN_JSON_OBJECT})
    while(CUR_PATH MATCHES "\\.")
        string(FIND "${CUR_PATH}" "." DOT_POS)
        math(EXPR DOT_NEXT_POS "${DOT_POS} + 1")
        string(SUBSTRING "${CUR_PATH}" 0 ${DOT_POS}       CUR_NAME)
        string(SUBSTRING "${CUR_PATH}" ${DOT_NEXT_POS} -1 CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET ${CUR_JSON} "${CUR_NAME}")
        if(CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${ARGS_IN_DOT_NOTATION})")
            if(DEFINED ARGS_ERROR_VARIABLE)
                set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
    endwhile()
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/4
    if ("${CUR_NAME}" STREQUAL "" AND "${CUR_PATH}" STREQUAL "")
        #
        # If the dot notation is '.', 
        # then no post-processing is needed after the while loop is executed.
        #
    else()
        #
        # If the dot notation is the correct syntax of '.xxx.yyy.zzz', 
        # then push the CUR_PATH at the end of the while loop into NAME_STACK as CUR_NAME.
        #
        set(CUR_NAME "${CUR_PATH}")
        set(CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET ${CUR_JSON} "${CUR_NAME}")
        if(CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${ARGS_IN_DOT_NOTATION})")
            if(DEFINED ARGS_ERROR_VARIABLE)
                set(${ARGS_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
    endif()
    #
    # Assign the final value found using the dot notation to the output variable.
    #
    set(${ARGS_ERROR_VARIABLE} "NOTFOUND" PARENT_SCOPE)
    set(${ARGS_OUT_JSON_VALUE} ${CUR_JSON} PARENT_SCOPE)
endfunction()
