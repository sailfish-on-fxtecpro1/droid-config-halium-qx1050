#!/bin/bash
if [ -e "/dev/wlan" ]; then
	echo OFF > /dev/wlan
fi
