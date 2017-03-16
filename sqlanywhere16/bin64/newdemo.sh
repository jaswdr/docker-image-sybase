#!/bin/sh	

. "/opt/sqlanywhere16/bin64/sa_config.sh"

if [ "" = "" ]; then
    dbisql=dbisqlc
else
    dbisql=dbisql
fi


if [ "$1" = "" ]; then
    __new=demo.db
fi

__new=demo.db
if [ "$1" != "" ]; then
    __new=$1.db

    __new=`echo $__new | sed -e s/\.db\.db$/.db/`
fi
dberase $__new
if [ ! -r $__new ]; then
    dbinit $__new
    dbspawn -q -f dbeng16 -n newdemo $__new
    cd "$SQLANY16/scripts"
    $dbisql -c "UID=DBA;PWD=sql;SERVERNAME=newdemo" -q mkdemo.sql
    dbstop -c "UID=DBA;PWD=sql;SERVERNAME=newdemo" -q
fi

