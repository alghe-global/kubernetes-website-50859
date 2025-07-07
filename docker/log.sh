#!/bin/bash

function sighandler()
{
    echo "Signal received. Sleeping 10 seconds before exiting..."
    sleep 10
    exit 0
}

trap sighandler SIGHUP SIGINT SIGTERM

while true; do
    date | tee -a /opt/logs.txt
    sleep 1
done
