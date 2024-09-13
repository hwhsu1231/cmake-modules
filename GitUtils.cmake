# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[============================================================[.rst
GitUtilities
------------

.. command:: get_git_latest_commit_on_branch_name

  .. code-block:: cmake

    get_git_latest_commit_on_branch_name(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "local"
        IN_BRANCH_NAME      "${BRANCH_NAME}"
        OUT_COMMIT_DATE     LATEST_POT_COMMIT_DATE
        OUT_COMMIT_HASH     LATEST_POT_COMMIT_HASH
        OUT_COMMIT_TITLE    LATEST_POT_COMMIT_TITLE)

.. command:: get_git_latest_tag_on_tag_pattern

  .. code-block:: cmake

    get_git_latest_tag_on_tag_pattern(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "local"
        IN_TAG_PATTERN      "${TAG_PATTERN}"
        IN_TAG_SUFFIX       "${TAG_SUFFIX}"
        OUT_TAG             LATEST_POT_TAG)

#]============================================================]


function(get_git_latest_commit_on_branch_name)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_REPO_PATH
                            IN_SOURCE_TYPE
                            IN_BRANCH_NAME
                            OUT_COMMIT_DATE
                            OUT_COMMIT_HASH
                            OUT_COMMIT_TITLE)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GGLCBN
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_REPO_PATH
                            IN_SOURCE_TYPE
                            IN_BRANCH_NAME)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED GGLCBN_${ARG})
            message(FATAL_ERROR "Missing GGLCBN_${ARG} argument.")
        endif()
    endforeach()
    unset(ARG)
    #
    # Find Git executable if not exists.
    #
    if(NOT EXISTS "${Git_EXECUTABLE}")
        find_package(Git QUIET MODULE REQUIRED)
    endif()
    #
    # Get the local/remote repository source.
    #
    if(GGLCBN_IN_SOURCE_TYPE STREQUAL "local")
        set(GGLCBN_REPO_SOURCE "${GGLCBN_IN_REPO_PATH}")
    elseif(GGLCBN_IN_SOURCE_TYPE STREQUAL "remote")
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote get-url origin
            WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(GGLCBN_REPO_SOURCE "${OUT_VAR}")
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    else()
        message(FATAL_ERROR "Invalid IN_SOURCE_TYPE argument. (${GGLCBN_IN_SOURCE_TYPE})")
    endif()
    #
    # Get the head oid/ref of 'IN_BRANCH_NAME' from the local/remote repository.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote
                --refs
                --heads
                --sort=-v:refname
                ${GGLCBN_REPO_SOURCE}
                ${GGLCBN_IN_BRANCH_NAME}
        WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        if(OUT_VAR)
            string(REGEX REPLACE "^([0-9a-f]+)\t(.*)" "\\1" GGLCBN_HEAD_OID "${OUT_VAR}")
            string(REGEX REPLACE "^([0-9a-f]+)\t(.*)" "\\2" GGLCBN_HEAD_REF "${OUT_VAR}")
        else()
            message(FATAL_ERROR "No matching '${GGLCBN_IN_BRANCH_NAME}' branch pattern found.")
        endif()
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Fetch the '${GGLCBN_HEAD_OID}' to FETCH_HEAD from the remote.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                ${GGLCBN_HEAD_OID}
                --depth=1
                --verbose
        WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Get the 'hash' of the head commit from FETCH_HEAD.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} show
                --no-patch
                --format=%H
                FETCH_HEAD
        WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        set(LATEST_COMMIT_HASH ${OUT_VAR})
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Get the 'date'  of the latest commit from FETCH_HEAD.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} show
                --no-patch
                --format=%ci
                FETCH_HEAD
        WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        set(LATEST_COMMIT_DATE ${OUT_VAR})
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Get the 'title' of the latest commit from FETCH_HEAD.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} show
                --no-patch
                --format=%s
                FETCH_HEAD
        WORKING_DIRECTORY ${GGLCBN_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        set(LATEST_COMMIT_TITLE ${OUT_VAR})
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Return OUT_COMMIT_DATE, OUT_COMMIT_HASH, and OUT_COMMIT_TITLE.
    #
    set(${GGLCBN_OUT_COMMIT_DATE}  ${LATEST_COMMIT_DATE} PARENT_SCOPE)
    set(${GGLCBN_OUT_COMMIT_HASH}  ${LATEST_COMMIT_HASH} PARENT_SCOPE)
    set(${GGLCBN_OUT_COMMIT_TITLE} ${LATEST_COMMIT_TITLE} PARENT_SCOPE)
endfunction()


function(get_git_latest_tag_on_tag_pattern)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_REPO_PATH 
                            IN_SOURCE_TYPE
                            IN_TAG_PATTERN 
                            IN_TAG_SUFFIX
                            OUT_TAG)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GGLTTP 
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_REPO_PATH 
                            IN_TAG_PATTERN
                            IN_SOURCE_TYPE 
                            OUT_TAG)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED GGLTTP_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    unset(ARG)
    #
    # Find Git executable if not exists.
    #
    if(NOT EXISTS "${Git_EXECUTABLE}")
        find_package(Git QUIET MODULE REQUIRED)
    endif()
    #
    # Determine the repository source.
    # - If IN_SOURCE_TYPE is local,  then set GGLTTP_REPO_SOURCE to the local path of the repository.
    # - If IN_SOURCE_TYPE is remote, then set GGLTTP_REPO_SOURCE to the remote url of the repository.
    #
    if(GGLTTP_IN_SOURCE_TYPE STREQUAL "local")
        set(GGLTTP_REPO_SOURCE "${GGLTTP_IN_REPO_PATH}")
    elseif(GGLTTP_IN_SOURCE_TYPE STREQUAL "remote")
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote
            WORKING_DIRECTORY ${GGLTTP_IN_REPO_PATH}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(GGLTTP_REPO_REMOTE_NAME "${OUT_VAR}")
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote get-url ${GGLTTP_REPO_REMOTE_NAME}
            WORKING_DIRECTORY ${GGLTTP_IN_REPO_PATH}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(GGLTTP_REPO_SOURCE "${OUT_VAR}")
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    else()
        message(FATAL_ERROR "Invalid IN_SOURCE_TYPE argument. (${GGLTTP_IN_SOURCE_TYPE})")
    endif()
    #
    # Configures git version sort suffix.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} config versionsort.suffix "${GGLTTP_IN_TAG_SUFFIX}"
        WORKING_DIRECTORY ${GGLTTP_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Get the list of tags matching the tag pattern.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote 
                --refs 
                --tags 
                --sort=-v:refname
                ${GGLTTP_REPO_SOURCE}
        WORKING_DIRECTORY ${GGLTTP_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    string(REPLACE "\n" ";" TAG_LINES "${OUT_VAR}")
    set(TAG_LIST "")
    foreach(TAG_LINE ${TAG_LINES})
        string(REGEX REPLACE "^[a-f0-9]+\trefs/tags/(.*)" "\\1" TAG_NAME "${TAG_LINE}")
        list(APPEND TAG_LIST ${TAG_NAME})
    endforeach()
    list(FILTER TAG_LIST INCLUDE REGEX "${GGLTTP_IN_TAG_PATTERN}")
    message(STATUS "TAG_LIST = ${TAG_LIST}")
    # list(SORT TAG_LIST COMPARE "NATURAL" ORDER "DESCENDING")
    list(GET TAG_LIST 0 LATEST_TAG)
#[[
    #
    # Get the list of release tags. For example, v3.25.2.
    # Get the list of candidate release tags. For example, v3.25.0-rc2.
    #
    set(TAG_REL_LIST "${TAG_LIST}")
    set(TAG_RC_LIST "${TAG_LIST}")
    list(FILTER TAG_RC_LIST  INCLUDE REGEX "-rc[0-9]+")
    list(FILTER TAG_REL_LIST EXCLUDE REGEX "-rc[0-9]+")
    #
    # Get the max release candidate tag.
    #
    if(TAG_RC_LIST)
        list(GET TAG_RC_LIST 0 TAG_RC_MAX)
    else()
        set(TAG_RC_MAX "")
    endif()
    #
    # Get the max release tag.
    #
    if(TAG_REL_LIST)
        list(GET TAG_REL_LIST 0 TAG_REL_MAX)
    else()
        set(TAG_REL_MAX "")
    endif()
    #
    # - If ${TAG_REL_MAX} exists but ${TAG_RC_MAX} doesn't exist,
    #   then set LATEST_TAG to ${TAG_REL_MAX}.
    # - If ${TAG_REL_MAX} doesn't exist but ${TAG_RC_MAX} exists,
    #   then set LATEST_TAG to ${TAG_RC_MAX}.
    # - If both ${TAG_REL_MAX} and ${TAG_RC_MAX} exist,
    #   then compare their version numbers:
    #   - If TAG_REL_MAX_NUM <  TAG_RC_MAX_NUM, then set LATEST_TAG to ${TAG_RC_MAX}.
    #   - If TAG_REL_MAX_NUM >= TAG_RC_MAX_NUM, then set LATEST_TAG to ${TAG_REL_MAX}.
    #
    if (NOT TAG_REL_MAX STREQUAL "" AND TAG_RC_MAX STREQUAL "")
        set(LATEST_TAG ${TAG_REL_MAX})
    elseif (TAG_REL_MAX STREQUAL "" AND NOT TAG_RC_MAX STREQUAL "")
        set(LATEST_TAG ${TAG_RC_MAX})
    elseif (NOT TAG_REL_MAX STREQUAL "" AND NOT TAG_RC_MAX STREQUAL "")
        string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" TAG_RC_MAX_NUM ${TAG_RC_MAX})
        string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" TAG_REL_MAX_NUM ${TAG_REL_MAX})
        if (TAG_REL_MAX_NUM VERSION_LESS TAG_RC_MAX_NUM)
            set(LATEST_TAG ${TAG_RC_MAX})
        else()
            set(LATEST_TAG ${TAG_REL_MAX})
        endif()
    else()
        message(FATAL_ERROR "There is no available tag on IN_TAG_PATTERN. (${GGLTTP_IN_TAG_PATTERN})")
    endif()
#]]
    #
    # Return the ${LATEST_TAG} on OUT_TAG.
    #
    set(${GGLTTP_OUT_TAG} "${LATEST_TAG}" PARENT_SCOPE)
endfunction()
