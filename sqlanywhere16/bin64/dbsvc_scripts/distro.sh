# ***************************************************************************
# Copyright (c) 2013 SAP AG or an SAP affiliate company. All rights reserved.
# ***************************************************************************
is_redflag()
############
{
    if [ `plat_os` = "linux" ] ; then
	grep -q -s "Red Flag" /etc/issue >/dev/null
	if [ $? -ne 0 ]; then
	    false
	else
	    true
	fi
    else
	false
    fi
}

is_redhat()
###########
{
    if [ `plat_os` = "linux" ] ; then
	grep -q -s "Red Hat" /etc/issue >/dev/null
	if [ $? -ne 0 ]; then
	    false
	else
	    true
	fi
    else
	false
    fi
}

is_suse()
#########
{
    if [ `plat_os` = "linux" ] ; then
	grep -q -s -i "SuSE" /etc/issue >/dev/null
	if [ $? -ne 0 ]; then
	    false
	else
	    true
	fi
    else
	false
    fi
}

is_ubuntu()
###########
{
    if [ `plat_os` = "linux" ] ; then
	grep -q -s -i "Ubuntu" /etc/issue >/dev/null
	if [ $? -ne 0 ]; then
	    false
	else
	    true
	fi
    else
	false
    fi
}

plat_os()
#########
{
    case "`uname -s`" in
	Linux)
	    echo "linux"
	    ;;
	AIX)
	    echo "aix"
	    ;;
	HP-UX)
	    echo "hpux"
	    ;;
	Darwin)
	    echo "macos"
	    ;;
	SunOS)
	    echo "solaris"
	    ;;
    esac
}

