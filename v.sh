#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 start/stop/restart/down/up/isolate/use"
    exit 1
fi

if [ $1 != "start" ] && [ $1 != "stop" ] && [ $1 != "restart" ] && [ $1 != "use" ] && [ $1 != "down" ] && [ $1 != "up" ] && [ $1 != "isolate" ]  && [ $1 != "use" ]; then
    echo "Usage: $0 start/stop/restart/down/up/isolate/use"
    exit 1
fi

if [ $1 = "start" ] || [ $1 = "up" ]; then
    valet start && brew services start mailhog
fi

if [ $1 = "stop" ] || [ $1 = "down" ]; then
    valet stop && valet stop dnsmasq && brew services stop mailhog
fi

if [ $1 = "restart" ]; then
    valet restart && brew services restart mailhog
fi

if [ $1 = "use" ]; then
    valet use $2 && composer global update
fi

if [ $1 = "isolate" ]; then
    valet isolate $2
fi

if [ $1 = "unisolate" ]; then
    valet unisolate
fi

if [ $1 = "share" ]; then
    valet share-tool ngrok
fi
