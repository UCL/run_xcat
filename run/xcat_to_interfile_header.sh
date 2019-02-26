#!/bin/bash

#runs xcat on samppar config file with output to path
run_xcat()
{
    #store current path
    TEMPPATH=$(pwd)
    
    #check if path uses . $3=$SAMPPARPATH $5=$OUTPUTPATH
    TEMPSAMPPARPATH=$3
    TEMPOUTPUTPATH=$5
    
    if [ $TEMPSAMPPARPATH == "./" ]
    then
        TEMPSAMPPARPATH=$(pwd)"/"
    fi
    
    if [ $TEMPOUTPUTPATH == "./" ]
    then
        TEMPOUTPUTPATH=$(pwd)"/"
    fi
    
    #moves to xcatpath $1=$XCATPATH
    cd $1
    
    #runs xcat $2=$XCAT $4=$SAMPPAR $6=$PREFIX
    "./"$2 $TEMPSAMPPARPATH$4 $TEMPOUTPUTPATH$6
    
    #reset enviroment
    cd $TEMPPATH
}

#construct what is the same for every interfile header
generate_general_header()
{
    #generic parts of interfile header
    HEADERORIENTATION=".bin\n!GENERAL DATA :=\n!GENERAL IMAGE DATA :=\n!type of data := PET\nimagedata byte order := LITTLEENDIAN\n!PET STUDY (General) :=\npatient orientation := "
    HEADERROTATION="\npatient rotation := "
    HEADERMATRIXSIZE1="\n!PET data type := Image\nprocess status := Reconstructed\n!number format := float\n!number of bytes per pixel := 4\nnumber of dimensions := 3\nmatrix axis label [1] := x\n!matrix size [1] := "
    HEADERSCALINGFACTOR1="\nscaling factor (mm/pixel) [1] := "
    HEADERMATRIXSIZE2="\nmatrix axis label [2] := y\n!matrix size [2] := "
    HEADERSCALINGFACTOR2="\nscaling factor (mm/pixel) [2] := "
    HEADERMATRIXSIZE3="\nmatrix axis label [3] := z\n!matrix size [3] := "
    HEADERSCALINGFACTOR3="\nscaling factor (mm/pixel) [3] := "
    HEADEREND="\nnumber of time frames := 1\n!END OF INTERFILE :="

    #aquires variables from xcat config file and multiplied by 10 are being converted from cm in the xcat config file to mm for the interfile header $1=$OUTPUTPATH$SAMPPAR
    ARRAYSIZE=$(echo $(grep "array_size = " $1) | cut -d' ' -f3)
    PIXELWIDTH=$(echo "$(echo $(grep "pixel_width = " $1) | cut -d' ' -f3)*10" | bc -l)
    ENDSLICE=$(echo $(grep "endslice = " $1) | cut -d' ' -f3)
    STARTSLICE=$(echo $(grep "startslice = " $1) | cut -d' ' -f3)
    SLICEWIDTH=$(echo "$(echo $(grep "slice_width = " $1) | cut -d' ' -f3)*10" | bc -l)

    #number of slices
    MATRIXSIZE3=$(echo "($ENDSLICE-$STARTSLICE)+1" | bc -l)

    #appending variables to generic header parts of interfile header $2=$ORIENTATION $3=$ROTATION
    HEADERORIENTATION=$HEADERORIENTATION$2
    HEADERROTATION=$HEADERROTATION$3
    HEADERMATRIXSIZE1=$HEADERMATRIXSIZE1$ARRAYSIZE
    HEADERSCALINGFACTOR1=$HEADERSCALINGFACTOR1$PIXELWIDTH
    HEADERMATRIXSIZE2=$HEADERMATRIXSIZE2$ARRAYSIZE
    HEADERSCALINGFACTOR2=$HEADERSCALINGFACTOR2$PIXELWIDTH
    HEADERMATRIXSIZE3=$HEADERMATRIXSIZE3$MATRIXSIZE3
    HEADERSCALINGFACTOR3=$HEADERSCALINGFACTOR3$SLICEWIDTH
    HEADEREND=$HEADEREND
    
    #construct and return what is the same for every interfile header
    echo $HEADERORIENTATION$HEADERROTATION$HEADERMATRIXSIZE1$HEADERSCALINGFACTOR1$HEADERMATRIXSIZE2$HEADERSCALINGFACTOR2$HEADERMATRIXSIZE3$HEADERSCALINGFACTOR3$HEADEREND
}

#output header files for each image both activity and attenuation
output_headers()
{
    #to be appended to file names $4=$PREFIX
    ACTPREFIX=$4"_act_"
    ATNPREFIX=$4"_atn_"
    
    #generic part of interfile header
    HEADERNAME="!INTERFILE  :=\nname of data file := "
    
    i=1 #loop iterator
    END=$2 #loop to output $2=$OUTPUT
    
    while [ $i -le $END ]
    do
        #construct and output activity header $3=$GENERALHEADER
        FILE=$ACTPREFIX$i
        echo -e $HEADERNAME$FILE$3 > $FILE".hv"
        
        #construct and output attenuation header $3=$GENERALHEADER
        FILE=$ATNPREFIX$i
        echo -e $HEADERNAME$FILE$3 > $FILE".hv"
        
        #increment iterator
        i=$(($i+1))
    done
}

main()
{
    #if no arguments
    if [ $# -lt 1 ]
    then
        DEBUG=false #checks to see if xcat should be run
        
        #user variables
        XCATPATH="./" #path to xcat directory
        XCAT="dxcat2_linux_64bit" #xcat executable
        SAMPPARPATH="./" #path to xcat config file
        SAMPPAR="xcat.samp.par" #xcat config file
        OUTPUTPATH="./" #path to output
        PREFIX="" #prefix for xcat output
        
        ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
        ROTATION="prone" #rotation of patient prone|supine|other
    else
        #if debug
        if [ $1 == "-t" -o $1 == "--test" ]
        then
            DEBUG=true #checks to see if xcat should be run
            OUTPUT=1 #checks to see if xcat should be run
        else
            #if only output headers
            if [ $1 == "-o" -o $1 == "--output" ]
            then
                #if output is less than 2
                if [ $2 -lt 2 ]
                then
                    echo "Output must be greater then 1. Run with -t to Output 1."
                    exit
                fi
                
                DEBUG=true #checks to see if xcat should be run
                OUTPUT=$2 #checks to see if xcat should be run
            else
                DEBUG=false #checks to see if xcat should be run
            fi
        fi
        
        #if not debug
        if [ $DEBUG = false ]
        then
            #user variables
            XCAT=$(echo $1 | rev | cut -d'/' -f1 | rev) #xcat executable
            XCATPATH=${1//$XCAT/} #path to xcat directory
            SAMPPAR=$(echo $2 | rev | cut -d'/' -f1 | rev) #xcat config file
            SAMPPARPATH=${2//$SAMPPAR/} #path to xcat config file
            PREFIX=$(echo $3 | rev | cut -d'/' -f1 | rev) #prefix for xcat output
            OUTPUTPATH=${3//$PREFIX/} #path to output
            
            #if orientation and rotation arguments are given
            if [ $# -gt 4 ]
            then
                ORIENTATION=$4 #orientation of patient head_in|feet_in|other
                ROTATION=$5 #rotation of patient prone|supine|other
            else
                ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
                ROTATION="prone" #rotation of patient prone|supine|other
            fi
        else
            #if not only output headers
            if [ $OUTPUT -lt 2 ]
            then
                #if no arguments
                if [ $# -lt 2 ]
                then
                    #user variables
                    XCATPATH="./" #path to xcat directory
                    XCAT="dxcat2_linux_64bit" #xcat executable
                    SAMPPARPATH="./" #path to xcat config file
                    SAMPPAR="xcat.samp.par" #xcat config file
                    OUTPUTPATH="./" #path to output
                    PREFIX="" #prefix for xcat output
                    
                    ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
                    ROTATION="prone" #rotation of patient prone|supine|other
                else
                    #user variables
                    XCAT=$(echo $2 | rev | cut -d'/' -f1 | rev) #xcat executable
                    XCATPATH=${2//$XCAT/} #path to xcat directory
                    SAMPPAR=$(echo $3 | rev | cut -d'/' -f1 | rev) #xcat config file
                    SAMPPARPATH=${3//$SAMPPAR/} #path to xcat config file
                    PREFIX=$(echo $4 | rev | cut -d'/' -f1 | rev) #prefix for xcat output
                    OUTPUTPATH=${4//$PREFIX/} #path to output
                    
                    #if orientation and rotation arguments are given
                    if [ $# -gt 5 ]
                    then
                        ORIENTATION=$5 #orientation of patient head_in|feet_in|other
                        ROTATION=$6 #rotation of patient prone|supine|other
                    else
                        ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
                        ROTATION="prone" #rotation of patient prone|supine|other
                    fi
                fi
            else
                #if no arguments
                if [ $# -lt 3 ]
                then
                    #user variables
                    XCATPATH="./" #path to xcat directory
                    XCAT="dxcat2_linux_64bit" #xcat executable
                    SAMPPARPATH="./" #path to xcat config file
                    SAMPPAR="xcat.samp.par" #xcat config file
                    OUTPUTPATH="./" #path to output
                    PREFIX="" #prefix for xcat output
                    
                    ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
                    ROTATION="prone" #rotation of patient prone|supine|other
                else
                    #user variables
                    XCAT=$(echo $3 | rev | cut -d'/' -f1 | rev) #xcat executable
                    XCATPATH=${3//$XCAT/} #path to xcat directory
                    SAMPPAR=$(echo $4 | rev | cut -d'/' -f1 | rev) #xcat config file
                    SAMPPARPATH=${4//$SAMPPAR/} #path to xcat config file
                    PREFIX=$(echo $5 | rev | cut -d'/' -f1 | rev) #prefix for xcat output
                    OUTPUTPATH=${5//$PREFIX/} #path to output
                    
                    #if orientation and rotation arguments are given
                    if [ $# -gt 6 ]
                    then
                        ORIENTATION=$6 #orientation of patient head_in|feet_in|other
                        ROTATION=$7 #rotation of patient prone|supine|other
                    else
                        ORIENTATION="head_in" #orientation of patient head_in|feet_in|other
                        ROTATION="prone" #rotation of patient prone|supine|other
                    fi
                fi
            fi
        fi
    fi
    
    #move to output
    cd $OUTPUTPATH
    
    #remove any previous output
    rm -f *.bin
    rm -f *.hv
    rm -f *log*
    
    if [ $DEBUG = false ]
    then
        #current number of files in directory
        EXISTINGFILECOUNT=$(ls | wc -l)
        
        #runs xcat on samppar config file with output to path
        run_xcat $XCATPATH $XCAT $SAMPPARPATH $SAMPPAR $OUTPUTPATH $PREFIX
        
        OUTPUT=$(echo $(echo "(($(ls | wc -l)-$EXISTINGFILECOUNT)-1)/2" | bc -l) | cut -d'.' -f1)
    fi
        
    #store output from generate_general_header
    GENERALHEADER=$(generate_general_header $OUTPUTPATH$SAMPPAR $ORIENTATION $ROTATION) #constructs what is the same for every interfile header
    
    #output header files for each image both activity and attenuation
    output_headers $DEBUG $OUTPUT "$GENERALHEADER" $PREFIX
    
    exit 0
}

#start
main "$@"
