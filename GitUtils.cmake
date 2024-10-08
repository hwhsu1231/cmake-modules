# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[============================================================[.rst
GitUtilities
------------

.. command:: get_git_latest_branch_on_branch_pattern

  .. code-block:: cmake

    get_git_latest_branch_on_branch_pattern(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "local"
        IN_BRANCH_PATTERN   "${BRANCH_PATTERN}"
        IN_BRANCH_SUFFIX    "${BRANCH_SUFFIX}"
        OUT_BRANCH          BRANCH_NAME)

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

.. command:: switch_to_git_reference_on_branch

  .. code-block:: cmake

    switch_to_git_reference_on_branch(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_REFERENCE        "${SWITCH_REFERENCE}"
        IN_BRANCH           "current")

.. command:: create_git_worktree_for_l10n_branch

  .. code-block:: cmake

    create_git_worktree_for_l10n_branch(
        IN_REMOTE_URL       "${REMOTE_URL_OF_L10N}"
        IN_REPO_PATH        "${PROJ_SOURCE_DIR}"
        IN_WORKTREE_PATH    "${PROJ_L10N_DIR}")

#]============================================================]


include_guard()


include(JsonUtils)
include(LogUtils)


function(create_git_worktree_for_l10n_branch)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_REMOTE_URL
                            IN_REPO_PATH
                            IN_WORKTREE_PATH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(CGWLB
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_REMOTE_URL
                            IN_REPO_PATH
                            IN_WORKTREE_PATH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED CGWLB_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find Git executable if not exists.
    #
    if(NOT EXISTS "${Git_EXECUTABLE}")
        find_package(Git QUIET MODULE REQUIRED)
    endif()
    #
    #
    #
    message(STATUS "Checking if the remote '${CGWLB_IN_REMOTE_URL}' exists...")
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote --heads --exit-code ${CGWLB_IN_REMOTE_URL}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(NOT RES_VAR EQUAL 0)
        remove_cmake_message_indent()
        message("")
        message("The remote '${CGWLB_IN_REMOTE_URL}' doesn't exist.")
        message("")
        restore_cmake_message_indent()
    else()
        remove_cmake_message_indent()
        message("")
        message("The remote '${CGWLB_IN_REMOTE_URL}' exists.")
        message("")
        restore_cmake_message_indent()
        message(STATUS "Checking if the branch 'l10n' exists in the remote...")
        execute_process(
            COMMAND ${Git_EXECUTABLE} ls-remote --heads --exit-code ${CGWLB_IN_REMOTE_URL} l10n
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(NOT RES_VAR EQUAL 0)
            remove_cmake_message_indent()
            message("")
            message("The branch 'l10n' doesn't exist in the remote.")
            message("")
            restore_cmake_message_indent()
        else()
            remove_cmake_message_indent()
            message("")
            message("The branch 'l10n' exist in the remote.")
            message("")
            restore_cmake_message_indent()
            message(STATUS "Checking if the git worktree exists in '${CGWLB_IN_WORKTREE_PATH}'...")
            if(EXISTS "${CGWLB_IN_WORKTREE_PATH}/.git")
                remove_cmake_message_indent()
                message("")
                message("The git worktree exists in '${CGWLB_IN_WORKTREE_PATH}'.")
                message("")
                execute_process(
                    COMMAND ${Git_EXECUTABLE} status
                    WORKING_DIRECTORY ${CGWLB_IN_WORKTREE_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                message("")
                execute_process(
                    COMMAND ${Git_EXECUTABLE} show --no-patch --format=full
                    WORKING_DIRECTORY ${CGWLB_IN_WORKTREE_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                message("")
                restore_cmake_message_indent()
            else()
                remove_cmake_message_indent()
                message("")
                message("The git worktree doesn't exist in '${CGWLB_IN_WORKTREE_PATH}'.")
                message("")
                restore_cmake_message_indent()
                message(STATUS "Prepare to create a git worktree.")
                execute_process(
                    COMMAND ${Git_EXECUTABLE} remote
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    RESULT_VARIABLE RES_VAR
                    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
                if(RES_VAR EQUAL 0)
                    set(REMOTE_NAME "${OUT_VAR}")
                else()
                    message(FATAL_ERROR "${ERR_VAR}")
                endif()
                message(STATUS "Adding fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n'...")
                remove_cmake_message_indent()
                message("")
                execute_process(
                    COMMAND ${Git_EXECUTABLE} config --get-all
                            remote.${REMOTE_NAME}.fetch
                            refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    RESULT_VARIABLE RES_VAR
                    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
                if(RES_VAR EQUAL 0)
                    # Fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n' already exists.
                elseif(RES_VAR EQUAL 1)
                    # Fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n' doesn't exist.
                    execute_process(
                        COMMAND ${Git_EXECUTABLE} config --add
                                remote.${REMOTE_NAME}.fetch
                                +refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n
                        WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                        ECHO_OUTPUT_VARIABLE
                        ECHO_ERROR_VARIABLE
                        COMMAND_ERROR_IS_FATAL ANY)
                else()
                    message(FATAL_ERROR "${ERR_VAR}")
                endif()
                execute_process(
                    COMMAND ${Git_EXECUTABLE} config --get-all
                            remote.${REMOTE_NAME}.fetch
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                message("")
                restore_cmake_message_indent()
                message(STATUS "Fetching/Tracking the remote branch 'l10n' to the local branch 'l10n'...")
                remove_cmake_message_indent()
                message("")
                execute_process(
                    COMMAND ${Git_EXECUTABLE} fetch ${REMOTE_NAME} l10n:l10n --verbose --update-head-ok
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                execute_process(
                    COMMAND ${Git_EXECUTABLE} branch --set-upstream-to=${REMOTE_NAME}/l10n l10n
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                message("")
                restore_cmake_message_indent()
                message(STATUS "Creating a git worktree for 'l10n' branch in ${CGWLB_IN_WORKTREE_PATH}...")
                remove_cmake_message_indent()
                message("")
                execute_process(
                    COMMAND ${CMAKE_COMMAND} -E rm -rf ${CGWLB_IN_WORKTREE_PATH}
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                execute_process(
                    COMMAND ${Git_EXECUTABLE} worktree prune
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                execute_process(
                    COMMAND ${Git_EXECUTABLE} worktree add ${CGWLB_IN_WORKTREE_PATH} l10n
                    WORKING_DIRECTORY ${CGWLB_IN_REPO_PATH}
                    ECHO_OUTPUT_VARIABLE
                    ECHO_ERROR_VARIABLE
                    COMMAND_ERROR_IS_FATAL ANY)
                message("")
                restore_cmake_message_indent()
                unset(REMOTE_NAME)
            endif()
        endif()
    endif()
endfunction()


function(get_git_latest_branch_on_branch_pattern)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_REPO_PATH
                            IN_SOURCE_TYPE
                            IN_BRANCH_PATTERN
                            IN_BRANCH_SUFFIX
                            OUT_BRANCH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GGLBBP
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_REPO_PATH
                            IN_BRANCH_PATTERN
                            IN_SOURCE_TYPE
                            OUT_BRANCH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED GGLBBP_${ARG})
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
    # - If IN_SOURCE_TYPE is local,  then set GGLBBP_REPO_SOURCE to the local path of the repository.
    # - If IN_SOURCE_TYPE is remote, then set GGLBBP_REPO_SOURCE to the remote url of the repository.
    #
    if(GGLBBP_IN_SOURCE_TYPE STREQUAL "local")
        set(GGLBBP_REPO_SOURCE "${GGLBBP_IN_REPO_PATH}")
    elseif(GGLBBP_IN_SOURCE_TYPE STREQUAL "remote")
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote
            WORKING_DIRECTORY ${GGLBBP_IN_REPO_PATH}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(GGLBBP_REPO_REMOTE_NAME "${OUT_VAR}")
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote get-url ${GGLBBP_REPO_REMOTE_NAME}
            WORKING_DIRECTORY ${GGLBBP_IN_REPO_PATH}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(GGLBBP_REPO_SOURCE "${OUT_VAR}")
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    else()
        message(FATAL_ERROR "Invalid IN_SOURCE_TYPE argument. (${GGLBBP_IN_SOURCE_TYPE})")
    endif()
    #
    # Configures git version sort suffix.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} config versionsort.suffix "${GGLBBP_IN_BRANCH_SUFFIX}"
        WORKING_DIRECTORY ${GGLBBP_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    #
    # Get the list of branches matching the branch pattern.
    #
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote
                --refs
                --heads
                --sort=-v:refname
                ${GGLBBP_REPO_SOURCE}
        WORKING_DIRECTORY ${GGLBBP_IN_REPO_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    string(REPLACE "\n" ";" BRANCH_LINES "${OUT_VAR}")
    set(BRANCH_LIST "")
    foreach(BRANCH_LINE ${BRANCH_LINES})
        string(REGEX REPLACE "^[a-f0-9]+\trefs/heads/(.*)" "\\1" BRANCH_NAME "${BRANCH_LINE}")
        list(APPEND BRANCH_LIST ${BRANCH_NAME})
    endforeach()
    list(FILTER BRANCH_LIST INCLUDE REGEX "${GGLBBP_IN_BRANCH_PATTERN}")
    list(GET BRANCH_LIST 0 LATEST_BRANCH)
    #
    # Return the ${LATEST_BRANCH} on OUT_BRANCH.
    #
    set(${GGLBBP_OUT_BRANCH} "${LATEST_BRANCH}" PARENT_SCOPE)
endfunction()


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
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
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
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stdout:\n\n${OUT_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
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


function(switch_to_git_reference_on_branch)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_REPO_PATH
                            IN_REFERENCE
                            IN_BRANCH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(SGRB
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_REPO_PATH
                            IN_REFERENCE
                            IN_BRANCH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED SGRB_${ARG})
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
    # Switch to ${SGRB_IN_REFERENCE} on branch ${SGRB_IN_BRANCH}.
    #
    if(EXISTS "${SGRB_IN_REPO_PATH}/.gitmodules")
        execute_process(
            COMMAND ${Git_EXECUTABLE} submodule deinit --all --force
            WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E rm -rf .git/modules
            WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("Removed directory '.git/modules'")
        message("")
    endif()
    execute_process(
        COMMAND ${Git_EXECUTABLE} checkout -B ${SGRB_IN_BRANCH}
        WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                ${SGRB_IN_REFERENCE}
                --depth=1
                --verbose
        WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} reset --hard FETCH_HEAD
        WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    if(EXISTS "${SGRB_IN_REPO_PATH}/.gitmodules")
        message("")
        execute_process(
            COMMAND ${Git_EXECUTABLE} submodule sync
            WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("")
        execute_process(
            COMMAND ${Git_EXECUTABLE} submodule update
                    --init
                    --recursive
                    --depth=1
            WORKING_DIRECTORY ${SGRB_IN_REPO_PATH}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
    endif()
endfunction()
