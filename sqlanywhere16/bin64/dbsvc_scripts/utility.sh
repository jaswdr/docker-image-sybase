# ***************************************************************************
# Copyright (c) 2013 SAP AG or an SAP affiliate company. All rights reserved.
# ***************************************************************************
toupper()
#########
{
    echo "$*" | tr a-z A-Z
}

tolower()
#########
{
    echo "$*" | tr A-Z a-z
}

not()
#####
{
    CMD=""
    while [ -n "${1:-}" ] ; do
        CMD="$CMD \"$1\""
        shift
    done

    if eval "$CMD" ; then
        false
    else
        true
    fi
}

check_tool_requirements()
#########################
{
    local sedtest awktest greptest trtest tailtest

    # make sure sed understands substituting hex codes
    sedtest=`echo "o o" | sed 's/ /\x00/'`
    if [ "$sedtest" = "ox00o" ]; then
	output_fatal_error "${ERR_SED}"
    fi
    # check existence of other required tools
    awktest=`echo "awktest" | awk '{print $1}'`
    if [ "$awktest" != "awktest" ]; then
	output_fatal_error "${ERR_AWK}"
    fi
    greptest=`echo "greptest" | grep 'greptest'`
    if [ "$greptest" != "greptest" ]; then
	output_fatal_error "${ERR_GREP}"
    fi
    # tailtest=`echo "tailtest" | tail --lines 1`
    # if [ "$tailtest" != "tailtest" ]; then
    #	output_fatal_error "${ERR_TAIL}"
    # fi
    trtest=`echo "trtest" | tr a-z a-z`
    if [ "$trtest" != "trtest" ]; then
	output_fatal_error "${ERR_TR}"
    fi
}

output_msg()
###########
{
    ## [ ${QUIET:-0} -ne 0 ] && return ;

    JUNK=`eval echo "$*"`
    echo "$JUNK"
}

output_fatal_error()
####################
{
    JUNK=`eval echo "$*"`
    echo "$JUNK" >&2
    exit 1
}

output_usage_error()
####################
{
    JUNK=`eval echo "$*"`
    echo "$JUNK" >&2
    usage
}

cui_echo()
##########
{
    ## [ ${QUIET:-0} -eq 0 ] && echo "$*"
    NOOP=NOOP
}

cui_eval_echo()
###############
{
    ## [ ${QUIET:-0} -ne 0 ] && return ;

    JUNK=`eval echo "$*"`
    echo "$JUNK"
}

cui_wait_for_input()
####################
# $2 - default response if the user hits enter in interactive mode
{
    if [ ${AUTOYES:-1} -eq 1 ] && [ -n "${2:-}" ] ; then
	CUI_RESPONSE="${2:-}"
    else
	cui_eval_echo "${1:-}"
	read CUI_RESPONSE
	[ -z "${CUI_RESPONSE:-}" ] && CUI_RESPONSE="${2:-}"
    fi
}

cui_ask_y_n()
#############
# $1 - prompt question
# $2 - default answer "Y" or "N" (influences key Y/n or N/y)
{
    if [ ${AUTOYES:-1} -eq 1 ] ; then
	true 
	return 
    fi

    _DEFAULT_ANSWER=${2:-N}

    if [ "${_DEFAULT_ANSWER}" = "Y" ] ; then
        _PROMPT="${MSG_PROMPT_YES_NO}"
    else
        _PROMPT="${MSG_PROMPT_NO_YES}"
    fi
    
    cui_echo ""
    cui_wait_for_input "${1} ${_PROMPT}" "${_DEFAULT_ANSWER}"

    case $CUI_RESPONSE in
        "${MSG_ANSWER_yes}" | "${MSG_ANSWER_Yes}" | "${MSG_ANSWER_y}" | "${MSG_ANSWER_Y}" )
	    true
            ;;
        * )
	    false
            ;;
    esac
}

