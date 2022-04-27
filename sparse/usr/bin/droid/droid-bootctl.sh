#!/bin/sh

# Check currentl used boot slot
SLOT="$(/system/bin/bootctl get-current-slot)"

# Check if current slot is marked successful
/system/bin/bootctl is-slot-marked-successful $SLOT 2> /dev/null

if [ $? -ne 0 ]
then
    echo "Marking boot as successful"
    /system/bin/bootctl mark-boot-successful 2> /dev/null
fi
