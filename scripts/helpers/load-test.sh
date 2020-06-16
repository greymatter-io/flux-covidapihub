#!/bin/bash

set -e

ENDPOINT="/ping"
THREADS="5"
CONNS="5"
DURATION="30s"
HOST_HEADER="disease.sh"
HISTORY="$HOME/.rlwrap_load_test_history"
IP="54.196.249.239"

value_prompt() {
    local prompt=$1
    local dfault=$2
    echo -n $(rlwrap -pYellow -S "$prompt: " -P $dfault -H "$HISTORY" -D 1 -o cat) 2> /dev/null
}

IP=$(value_prompt "cluster IP" $IP)
ENDPOINT=$(value_prompt "url endpoint" $ENDPOINT)
THREADS=$(value_prompt "num threads" $THREADS)
CONNS=$(value_prompt "connections" $CONNS)
DURATION=$(value_prompt "duration" $DURATION)
HOST_HEADER=$(value_prompt "Host header" $HOST_HEADER)

echo ""
echo "Copy the following work script and EXECUTE it (if it looks good)"
echo "wrk -t${THREADS} -c${CONNS} -d${DURATION} -H \"Host: $HOST_HEADER\" \"https://${IP}${ENDPOINT}\""

