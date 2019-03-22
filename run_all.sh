#!/bin/bash

#Copyright University College London 2019
#Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
#For internal research only.

run_xcat()
{
    SAMPPAR=$(echo $1 | rev | cut -d'/' -f1 | rev) #xcat executable
    SAMPPARPATH=${1//$SAMPPAR/} #path to xcat directory
    
    $RUNXCATPATH $XCATPATH $SAMPPARPATH$SAMPPAR $SAMPPARPATH
}

run_signal()
{
    LOG=$(echo $1 | rev | cut -d'/' -f1 | rev)
    LOGPATH=${1//$LOG/}
    
    $RUNSIGNALPATH $LOGPATH$LOG $LOGPATH $PROCESSSIGNALSPATH
}

run_lesion()
{
    RUNLESIONPATH=${1/"./"/$(pwd)"/"}
    STIRPATH=${2/"./"/$(pwd)"/"}
    
    $RUNLESIONPATH $STIRPATH
}

main()
{
    #create full paths
    RUNXCATPATH=${1/"./"/$(pwd)"/"}
    XCATPATH=${2/"./"/$(pwd)"/"}
    RUNSIGNALPATH=${3/"./"/$(pwd)"/"}
    PROCESSSIGNALSPATH=${4/"./"/$(pwd)"/"}
    RUNLESIONPATH=${5/"./"/$(pwd)"/"}
    STIRPATH=${6/"./"/$(pwd)"/"}
    
    export RUNXCATPATH=$RUNXCATPATH
    export XCATPATH=$XCATPATH
    
    export -f run_xcat
    
    find ./ -name *.samp.par -execdir bash -c 'run_xcat {}' \;
    
    export RUNSIGNALPATH=$RUNSIGNALPATH
    export PROCESSSIGNALSPATH=$PROCESSSIGNALSPATH
    
    export -f run_signal
    
    find ./ -name *_log -execdir bash -c 'run_signal {}' \;
    
    run_lesion $RUNLESIONPATH $STIRPATH
    
    exit 0
}

#start
main "$@"
