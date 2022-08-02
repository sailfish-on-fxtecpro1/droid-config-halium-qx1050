#!/bin/sh

c=`getprop | grep keymaster | grep running | wc -l`
while [ $c -lt 1 ]
do
   echo Waiting for keymaster...
   c=`getprop | grep keymaster | grep running | wc -l`
   sleep 1
done

echo done
exit 0

