#!/bin/bash

#Copyright University College London 2019
#Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
#For internal research only.

main()
{
    #create full paths
    LOGPATH=${1/"./"/$(pwd)"/"}    
    PREFIX=$(echo $2 | rev | cut -d'/' -f1 | rev) #prefix for xcat output
    OUTPUTPATH=${2//$PREFIX/} #path to output
    
    cd $OUTPUTPATH
    
    rm -f *signal
    
    TEXT=$(grep "Current heart phase index =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"Currentheartphaseindex="/}
    
    for i in $OUTPUT
    do
        echo -e $(echo $i | cut -d'(' -f1) >> $PREFIX"_heart_phase_signal"
    done
    
    TEXT=$(grep "Current resp phase index  =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"Currentrespphaseindex="/}
    
    for i in $OUTPUT
    do
        echo -e $(echo $i | cut -d'(' -f1) >> $PREFIX"_resp_phase_signal"
    done
    
    TEXT=$(grep "diaphragm motion    =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"diaphragmmotion="/}
    OUTPUT=${OUTPUT//"mm"/}
    
    for i in $OUTPUT
    do
        echo -e $i >> $PREFIX"_diaphragm_motion_signal"
    done
    
    TEXT=$(grep "delta AP diameter =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"deltaAPdiameter="/}
    OUTPUT=${OUTPUT//"mm"/}
    
    for i in $OUTPUT
    do
        echo -e $i >> $PREFIX"_delta_ap_diameter_signal"
    done
    
    exit 0
}

#start
main "$@"
