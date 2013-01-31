#!/bin/bash

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Logger stuff has to exist before called, so make it early

logmsg()
{
	echo "$(date): $1" 2>&1
}

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Globals

INSTIP="${1}"
SP_TAR="${2}"

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Sanity Checks

if [ "${1}" == "" -o "${2}" == "" ]; then
	echo "usage: $0 instance_ip stack_core_tar"
else
	shift
	shift
fi

run_update()
{
	scp "${SP_TAR}" "${INSTIP}:/home/sstudio/"
	# generate the script to remotely execute
	cat code_push.sh > /tmp/codescript.sh
	ssh "${INSTIP}" "$(cat /tmp/codescript.sh)"
}

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Main line code

run_update

