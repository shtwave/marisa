#!/bin/bash

localtime() {
   perl -e "print(localtime($1).\"\n\");";
}

upnow="$(cut -f1 -d"." /proc/uptime)"
upmmt="$(( $(date +%s) - ${upnow} ))"

dmesg | while read line; do
   timestamp="$(echo "${line}" | sed "s/^\[ *\([0-9]\+\).*/\1/g")"
   timestamp=$(( ${timestamp} + ${upmmt} ))
   echo "${line}" | sed "s/^[^]]\+]\(.*\)/$(localtime "${timestamp}") -\1/g"
done

