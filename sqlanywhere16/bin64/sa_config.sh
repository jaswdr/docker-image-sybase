#!/bin/sh
#

# the following lines set the SA location.
SQLANY16="/opt/sqlanywhere16"
export SQLANY16

[ -r "$HOME/.sqlanywhere16/sample_env64.sh" ] && . "$HOME/.sqlanywhere16/sample_env64.sh" 
[ -z "${SQLANYSAMP16:-}" ] && SQLANYSAMP16="/opt/sqlanywhere16/samples"
export SQLANYSAMP16

# the following lines add SA binaries to your path.
PATH="$SQLANY16/bin64:${PATH:-}"
export PATH

# the following lines are required to load the various shared objects of SA
PATH="$SQLANY16/bin64/jre170/bin/:${PATH:-}"
LD_LIBRARY_PATH="$SQLANY16/bin64/jre170/lib/amd64/client:$SQLANY16/bin64/jre170/lib/amd64/server:$SQLANY16/bin64/jre170/lib/amd64:$SQLANY16/bin64/jre170/lib/amd64/native_threads:${LD_LIBRARY_PATH:-}"
export PATH
[ -z "${JAVA_HOME:-}" ] && JAVA_HOME="$SQLANY16/bin64/jre170"
export JAVA_HOME
LD_LIBRARY_PATH="$SQLANY16/lib64:${LD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH
