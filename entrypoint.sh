#!/bin/bash

set -e
set -u
set -o pipefail

cd /sandbox
echo "$1" | base64 -d > onlineapp.d

args=${DOCKER_FLAGS:-""}
coloring=${DOCKER_COLOR:-"off"}
export TERM="dtour"

if  grep -qE "dub[.](sdl|json):" onlineapp.d > /dev/null 2>&1  ; then
    exec timeout -s KILL ${TIMEOUT:-30} dub -q --compiler=${DLANG_EXEC} --single --skip-registry=all onlineapp.d | tail -n10000
elif [ -z ${2:-""} ] ; then
    exec timeout -s KILL ${TIMEOUT:-30} \
        bash -c 'faketty () { script -qfc "$(printf "%q " "$@")" /dev/null ; };'"faketty ${DLANG_EXEC} $args -color=$coloring -g -run onlineapp.d | cat" \
        | sed 's/\r//' \
        | tail -n10000
else
    exec timeout -s KILL ${TIMEOUT:-30} bash -c "echo $2 | base64 -d | ${DLANG_EXEC} $args -g -run onlineapp.d | tail -n10000"
fi
