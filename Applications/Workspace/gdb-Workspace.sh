#!/bin/sh
# /usr/libexec/Xorg :0 -noreset -background none -seat seat0 -nolisten tcp -keeptty vt1

export CFNETWORK_LIBRARY_PATH="/usr/NextSpace/lib/libCFNetwork.so"

gnustep-services start
export DISPLAY=:0.0
PROG_NAME="Workspace"
PROG_PATH="/usr/NextSpace/Apps/Workspace.app/Workspace"
PROG_ARGS="--GNU-Debug=DBus --GNU-Debug=dealloc"

WS_PID="`ps auxw|grep ${PROG_NAME}|grep -v grep|grep -v /bin/sh|awk -c '{print $2}'`"
if [ "$WS_PID" == "" ];then
    echo "Starting new '${PROG_NAME}' instance..."
    gdb -q --args ${PROG_PATH} ${PROG_ARGS}
else
    echo "Found '${PROG_NAME}' PID: ${WS_PID}"
    gdb ${PROG_PATH} ${WS_PID}
fi

gnustep-services stop
