#!/bin/bash

while [ ! -e "/dev/wlan" ]; do
        sleep 1
done

sleep 3

echo ON > /dev/wlan
