#!/bin/sh
if [ ! -f /home.img ]; then
    fallocate -l 80G /home.img
fi
