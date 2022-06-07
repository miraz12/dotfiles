#!/bin/sh

temp1=70
temp2=85

temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//'| sed 's/.0°C//')
temp=${temp%???}

if [ "$temp" -ge "$temp2" ] ; then
    echo "<fc=#ff5555>$temp</fc>°C"
elif [ "$temp" -ge "$temp1" ] ; then
    echo "<fc=#ffb86c>$temp</fc>°C"
else
    echo "<fc=#50fa7b>$temp</fc>°C"

fi
