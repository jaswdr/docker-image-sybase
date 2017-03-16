#!/bin/csh
#

# the following lines set the SA location.
setenv SQLANY16 "/opt/sqlanywhere16"

[ -r "$HOME/.sqlanywhere16/sample_env64.csh" ] && source "$HOME/.sqlanywhere16/sample_env64.csh" 
if ( ! $?SQLANYSAMP16 ) then
    setenv SQLANYSAMP16 "/opt/sqlanywhere16/samples"
endif

# the following lines add SA binaries to your path.
if ( $?PATH ) then
    setenv PATH "$SQLANY16/bin64:$PATH"
else
    setenv PATH "$SQLANY16/bin64"
endif

# the following lines are required to load the various shared objects of SA
if ( $?PATH ) then
    setenv PATH "$SQLANY16/bin64/jre170/bin/:$PATH"
else
    setenv PATH "$SQLANY16/bin64/jre170/bin/"
endif
if ( $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH "$SQLANY16/bin64/jre170/lib/amd64/client:$SQLANY16/bin64/jre170/lib/amd64/server:$SQLANY16/bin64/jre170/lib/amd64:$SQLANY16/bin64/jre170/lib/amd64/native_threads:$LD_LIBRARY_PATH"
else
    setenv LD_LIBRARY_PATH "$SQLANY16/bin64/jre170/lib/amd64/client:$SQLANY16/bin64/jre170/lib/amd64/server:$SQLANY16/bin64/jre170/lib/amd64:$SQLANY16/bin64/jre170/lib/amd64/native_threads"
endif
if ( ! $?JAVA_HOME ) then
    setenv JAVA_HOME "$SQLANY16/bin64/jre170"
endif
if ( $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH "$SQLANY16/lib64:$LD_LIBRARY_PATH"
else
    setenv LD_LIBRARY_PATH "$SQLANY16/lib64"
endif
