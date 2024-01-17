#!/bin/bash
# Short command of Laravel Valet
if [ $# -eq 0 ]; then
    echo "Usage: $0 start/stop/restart"
    exit 1
fi

if [ $1 != "start" ] && [ $1 != "stop" ] && [ $1 != "restart" ] && [ $1 != "use" ]; then
    echo "Usage: $0 start/stop/restart"
    exit 1
fi

if [ $1 = "start" ]; then
    valet start
fi

if [ $1 = "stop" ]; then
    valet stop && valet stop dnsmasq
fi

if [ $1 = "restart" ]; then
    valet restart
fi

if [ $1 = "use" ]; then
    valet use $2 && composer global update
fi