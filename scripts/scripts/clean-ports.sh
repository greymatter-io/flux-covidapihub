#!/bin/bash


listener=$(lsof -t -i:10080)
if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

listener=$(lsof -t -i:10081)
if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10081"
    kill $listener
fi
