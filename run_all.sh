#!/bin/bash

#Copyright University College London 2019
#Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
#For internal research only.

main()
{
    #create full paths
    RUNXCATPATH=${1/"./"/$(pwd)"/"}
    XCATPATH=${2/"./"/$(pwd)"/"}
    RUNLOGPATH=${3/"./"/$(pwd)"/"}
    
    for i in $(find ./ -name *.samp.par)
    do
        SAMPPAR=$(echo $i | rev | cut -d'/' -f1 | rev) #xcat executable
        SAMPPARPATH=${i//$SAMPPAR/} #path to xcat directory
        
        $RUNXCATPATH $XCATPATH $SAMPPARPATH$SAMPPAR $SAMPPARPATH
    done
    
    for i in $(find ./ -name *_log)
    do
        LOG=$(echo $i | rev | cut -d'/' -f1 | rev) #xcat executable
        LOGPATH=${i//$LOG/} #path to xcat directory
        
        $RUNLOGPATH $LOGPATH$LOG $LOGPATH
    done
    
    exit 0
}

#start
main "$@"
