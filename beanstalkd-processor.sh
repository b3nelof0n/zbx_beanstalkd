#!/usr/bin/env bash

###############################################################################

source /etc/sysconfig/beanstalkd

BEANSTALK_HOST="${ADDR:-localhost}"
BEANSTALK_PORT="${PORT:-11300}"

BEANSTALK_TMP="/var/tmp"
BEANSTALK_TUBES_LIST="$BEANSTALK_TMP/beanstalk-tubes-list.dat"
BEANSTALK_TUBE_FORMAT="$BEANSTALK_TMP/beanstalk-tube-%tube%.dat"

###############################################################################

runCmd() {
    cmd="$1"
    echo -e ''$cmd'\r' | nc $BEANSTALK_HOST $BEANSTALK_PORT
}

fetchTubesList() {
    runCmd "list-tubes" | grep -E "^(- )" | sed 's/- //g'
}

getTubeFormat() {
    tube="$1"
    echo "$BEANSTALK_TUBE_FORMAT" | sed 's/%tube%/'$tube'/g'
}

getTubesList() {
    if [[ ! -f "$BEANSTALK_TUBES_LIST" ]] ; then
        saveTubesList "`fetchTubesList`"
    fi
    tubesList=`cat "$BEANSTALK_TUBES_LIST"`
    echo "$tubesList"
}

getTubeStat() {
    tube="$1"
    data=`fetchTubeStat "$tube" | grep ':'`
    echo "$data"
}

getTubeStatByName() {
    tube="$1"
    param="$2"
    file=`getTubeFormat "$tube"`
    cat `getTubeFormat "$tube"` | grep "$param:" | awk -F ': ' '{print $2}'
}

fetchTubesStats() {
    IFS=$'\n'
    for tube in `getTubesList`; do
        saveTubeStat "$tube"
    done
}

discoverTubesList() {
    format="${1:-''}"
    tubesList=`getTubesList`
    if [[ "$format" == "raw" ]] ; then
        echo "$tubesList"
    else
        echo ${tubesList} | awk '{printf("{\n\t\"data\":[\n");for(i=1;i<=NF;i++){ printf("\t\t{\n\t\t\t\"{#TUBE_ITEM}\":\"%s\"}", $i); if(i+1<=NF){printf(",\n");}} printf("]}\n");}'
    fi
}

fetchTubeStat() {
    tube="$1"
    runCmd "stats-tube $tube"
}

saveTubeStat() {
    tube="$1"
    data=`getTubeStat "$tube"`
    echo "$data" > `getTubeFormat "$tube"`
}

saveTubesList() {
    tubesList="$1"
    echo "$tubesList" > "$BEANSTALK_TUBES_LIST"
}

###############################################################################

main() {
    case "$1" in
        discover)
            discoverTubesList "$2"
            ;;
        fetch)
            fetchTubesStats
            ;;
        get)
            getTubeStatByName "$2" "$3"
            ;;
    esac
}

###############################################################################

main "$@"

