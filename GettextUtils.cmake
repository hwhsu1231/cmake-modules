# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.


include_guard()


function(update_sphinx_pot_from_def_to_pkg)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_DEF_FILE
                            IN_PKG_FILE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(USPFSTD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_DEF_FILE
                            IN_PKG_FILE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED USPFSTD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    #
    #
    if(EXISTS "${USPFSTD_IN_PKG_FILE}")
        #
        # Concatenate the package 'sphinx.pot' with the default 'sphinx.pot'.
        #
        message("msgcat:")
        message("  --use-first")
        message("  --width        ${USPFSTD_IN_WRAP_WIDTH}")
        message("  --output-file  ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_DEF_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                    --use-first
                    --width=${USPFSTD_IN_WRAP_WIDTH}
                    --output-file=${USPFSTD_IN_PKG_FILE}
                    ${USPFSTD_IN_PKG_FILE}  # [inputfile]
                    ${USPFSTD_IN_DEF_FILE}  # [inputfile]
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
    else()
        #
        # Generate the package 'sphinx.pot' from the default 'sphinx.pot'.
        #
        message("msgcat:")
        message("  --use-first")
        message("  --width        ${USPFSTD_IN_WRAP_WIDTH}")
        message("  --output-file  ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_DEF_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                    --width=${USPFSTD_IN_WRAP_WIDTH}
                    --output-file=${USPFSTD_IN_PKG_FILE}
                    ${USPFSTD_IN_DEF_FILE}
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
    endif()
endfunction()


function(update_pot_from_src_to_dst)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_SRC_DIR
                            IN_DST_DIR
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(UPFSTD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_SRC_DIR
                            IN_DST_DIR
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED UPFSTD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executables if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    #
    #
    file(GLOB_RECURSE SRC_FILES "${UPFSTD_IN_SRC_DIR}/*.pot")
    foreach(SRC_FILE ${SRC_FILES})
        string(REPLACE "${UPFSTD_IN_SRC_DIR}/" "" SRC_FILE_RELATIVE "${SRC_FILE}")
        set(DST_FILE "${UPFSTD_IN_DST_DIR}/${SRC_FILE_RELATIVE}")
        get_filename_component(DST_FILE_DIR "${DST_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${DST_FILE_DIR}")
        if(EXISTS "${DST_FILE}")
            #
            # If the ${DST_FILE} exists, then merge it using msgmerge.
            #
            message("msgmerge:")
            message("  --width      ${UPFSTD_IN_WRAP_WIDTH}")
            message("  --backup     off")
            message("  --update")
            message("  --force-po")
            message("  --no-fuzzy-matching")
            message("  [def.po]     ${DST_FILE}")
            message("  [ref.pot]    ${SRC_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                        --width=${UPFSTD_IN_WRAP_WIDTH}
                        --backup=off
                        --update
                        --force-po
                        --no-fuzzy-matching
                        ${DST_FILE}   # [def.po]
                        ${SRC_FILE}   # [ref.pot]
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
        else()
            #
            # If the ${DST_FILE} doesn't exist, then create it using msgcat.
            #
            message("msgcat:")
            message("  --width        ${UPFSTD_IN_WRAP_WIDTH}")
            message("  --output-file  ${DST_FILE}")
            message("  [inputfile]    ${SRC_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                        --width=${UPFSTD_IN_WRAP_WIDTH}
                        --output-file=${DST_FILE}
                        ${SRC_FILE}   # [inputfile]
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
        endif()
    endforeach()
    unset(SRC_FILE)
endfunction()


function(update_po_from_pot_in_locale)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_LOCALE_POT_DIR
                            IN_LOCALE_PO_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(UPFP
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_LOCALE_POT_DIR
                            IN_LOCALE_PO_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED UPFP_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgmerge and msgcat executables if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGMERGE_EXECUTABLE}" OR
        NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgmerge Msgcat)
    endif()
    #
    #
    #
    file(GLOB_RECURSE POT_FILES "${UPFP_IN_LOCALE_POT_DIR}/*.pot")
    foreach(POT_FILE ${POT_FILES})
        string(REPLACE "${UPFP_IN_LOCALE_POT_DIR}/" "" POT_FILE_RELATIVE "${POT_FILE}")
        string(REGEX REPLACE "\\.pot$" ".po" PO_FILE_RELATIVE "${POT_FILE_RELATIVE}")
        set(PO_FILE "${UPFP_IN_LOCALE_PO_DIR}/${PO_FILE_RELATIVE}")
        get_filename_component(PO_FILE_DIR "${PO_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${PO_FILE_DIR}")
        if(EXISTS "${PO_FILE}")
            #
            # If the ${PO_FILE} exists, then merge it using msgmerge.
            #
            message("msgmerge:")
            message("  --lang       ${UPFP_IN_LANGUAGE}")
            message("  --width      ${UPFP_IN_WRAP_WIDTH}")
            message("  --backup     off")
            message("  --update")
            message("  --force-po")
            message("  --no-fuzzy-matching")
            message("  [def.po]     ${PO_FILE}")
            message("  [ref.pot]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                        --lang=${UPFP_IN_LANGUAGE}
                        --width=${UPFP_IN_WRAP_WIDTH}
                        --backup=off
                        --update
                        --force-po
                        --no-fuzzy-matching
                        ${PO_FILE}      # [def.po]
                        ${POT_FILE}     # [ref.pot]
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
        else()
            #
            # If the ${PO_FILE} doesn't exist, then create it using msgcat.
            #
            message("msgcat:")
            message("  --lang         ${UPFP_IN_LANGUAGE}")
            message("  --width        ${UPFP_IN_WRAP_WIDTH}")
            message("  --output-file  ${PO_FILE}")
            message("  [inputfile]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                        --lang=${UPFP_IN_LANGUAGE}
                        --width=${UPFP_IN_WRAP_WIDTH}
                        --output-file=${PO_FILE}
                        ${POT_FILE}
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
        endif()
    endforeach()
    unset(POT_FILE)
endfunction()


function(concat_po_from_locale_to_compendium)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_LOCALE_PO_DIR
                            IN_COMPEND_PO_FILE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(CPFLTC
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_LOCALE_PO_DIR
                            IN_COMPEND_PO_FILE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED CPFLTC_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    #
    #
    file(GLOB_RECURSE LOCALE_PO_FILES "${CPFLTC_IN_LOCALE_PO_DIR}/*.po")
    get_filename_component(COMPENDIUM_PO_DIR "${CPFLTC_IN_COMPEND_PO_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${COMPENDIUM_PO_DIR}")
    message("msgcat:")
    message("  --width=${CPFLTC_IN_WRAP_WIDTH}")
    message("  --use-first")
    message("  --output-file ${CPFLTC_IN_COMPEND_PO_FILE}")
    foreach(LOCALE_PO_FILE ${LOCALE_PO_FILES})
    message("  ${LOCALE_PO_FILE}")
    endforeach()
    execute_process(
        COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                --width=${CPFLTC_IN_WRAP_WIDTH}
                --use-first
                --output-file=${CPFLTC_IN_COMPEND_PO_FILE}
                ${LOCALE_PO_FILES}
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
endfunction()


function(merge_po_from_compendium_to_locale)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_COMPEND_PO_FILE
                            IN_LOCALE_PO_DIR
                            IN_LOCALE_POT_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(MPFCTL
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_COMPEND_PO_FILE
                            IN_LOCALE_PO_DIR
                            IN_LOCALE_POT_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if(NOT DEFINED MPFCTL_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgmerge executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGMERGE_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgmerge)
    endif()
    #
    #
    #
    file(GLOB_RECURSE LOCALE_PO_FILES "${MPFCTL_IN_LOCALE_PO_DIR}/*.po")
    foreach(LOCALE_PO_FILE ${LOCALE_PO_FILES})
        string(REPLACE "${MPFCTL_IN_LOCALE_PO_DIR}/" "" PO_FILE_RELATIVE "${LOCALE_PO_FILE}")
        string(REGEX REPLACE "\\.po$" ".pot" POT_FILE_RELATIVE "${PO_FILE_RELATIVE}")
        set(LOCALE_PO_FILE      "${MPFCTL_IN_LOCALE_PO_DIR}/${PO_FILE_RELATIVE}")
        set(LOCALE_POT_FILE     "${LOCALE_POT_DIR}/${POT_FILE_RELATIVE}")
        message("msgmerge:")
        message("  --lang           ${MPFCTL_IN_LANGUAGE}")
        message("  --width          ${MPFCTL_IN_WRAP_WIDTH}")
        message("  --compendium     ${MPFCTL_IN_COMPEND_PO_FILE}")
        message("  --output-file    ${LOCALE_PO_FILE}")
        message("  [def.po]         ${LOCALE_POT_FILE}")
        message("  [ref.pot]        ${LOCALE_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                    --lang=${MPFCTL_IN_LANGUAGE}
                    --width=${MPFCTL_IN_WRAP_WIDTH}
                    --compendium=${MPFCTL_IN_COMPEND_PO_FILE}
                    --output-file=${LOCALE_PO_FILE}
                    ${LOCALE_POT_FILE}  # [def.po]
                    ${LOCALE_POT_FILE}  # [ref.pot]
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
    endforeach()
    unset(LOCALE_PO_FILE)
endfunction()

