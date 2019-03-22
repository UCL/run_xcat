#!/bin/bash

#Copyright University College London 2019
#Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
#For internal research only.

main()
{
    #create full paths
    LOGPATH=${1/"./"/$(pwd)"/"}
    PREFIX=$(echo $2 | rev | cut -d'/' -f1 | rev)
    OUTPUTPATH=${2//$PREFIX/} #path to output
    PROCESSSIGNALSPATH=${3/"./"/$(pwd)"/"}
    
    cd $OUTPUTPATH
    
    rm -f *signal
    rm -f *nifty_reg_resp
    
    TEXT=$(grep "Current heart phase index =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"Currentheartphaseindex="/}
    
    FILENAME=$PREFIX"_heart_phase_signal"
    
    for i in $OUTPUT
    do
        echo -e $(echo $i | cut -d'(' -f1) >> $FILENAME
    done
    
    python $PROCESSSIGNALSPATH $FILENAME
    
    TEXT=$(grep "Current resp phase index  =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"Currentrespphaseindex="/}
    
    FILENAME=$PREFIX"_resp_phase_signal"
    
    for i in $OUTPUT
    do
        echo -e $(echo $i | cut -d'(' -f1) >> $FILENAME
    done
    
    python $PROCESSSIGNALSPATH $FILENAME
    
    TEXT=$(grep "diaphragm motion    =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"diaphragmmotion="/}
    OUTPUT=${OUTPUT//"mm"/}
    
    FILENAME=$PREFIX"_diaphragm_motion_signal"
    
    for i in $OUTPUT
    do
        echo -e $i >> $FILENAME
    done
    
    python $PROCESSSIGNALSPATH $FILENAME
    
    TEXT=$(grep "delta AP diameter =" $LOGPATH)
    
    OUTPUT=${TEXT//" "/}
    OUTPUT=${OUTPUT//"deltaAPdiameter="/}
    OUTPUT=${OUTPUT//"mm"/}
    
    FILENAME=$PREFIX"_delta_ap_diameter_signal"
    
    for i in $OUTPUT
    do
        echo -e $i >> $FILENAME
    done
    
    python $PROCESSSIGNALSPATH $FILENAME
    
    exit 0
}

#start
main "$@"
