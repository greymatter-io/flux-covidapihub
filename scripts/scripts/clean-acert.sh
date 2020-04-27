#!/bin/bash

echo "Are you sure you want to delete your Acert files? Hit ENTER to continue; or any letters then ENTER to exit."
read answer

if [ ! -z "$answer" ]; then
    echo "Exiting without deleting Acert files"
    exit 1
fi

echo "Okay! Deleting Acert files."

# Delete Acert files
rm -f ~/.acert/authorities/*
rm -f ~/.acert/leaves/*