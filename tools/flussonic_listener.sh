#!/bin/bash
## Sends once on connection
#while true; do (echo -e "{#Ref<0.648973382.1545338882.250354>,ok}") | netcat -lp 9090 &>/dev/null; done
#exit 0

## Sends every N secconds
while echo "{#Ref<0.648973382.1545338882.250354>,ok}"; do
	sleep 5
done | netcat -lp 9090 &>/dev/null
