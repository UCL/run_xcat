#!/bin/bash

#current number of files in directory
EXISTINGFILECOUNT=$(ls | wc -l)

#user variables
XCATPATH="/home/alexander/XCAT/" #path to xcat directory
XCAT="dxcat2_linux_64bit" #xcat executable
SAMPPARPATH="/home/alexander/Workspace/ALEXJAZZ008008_xcat_example/xcat_example/run/" #path to xcat config file
SAMPPAR="xcat.samp.par" #xcat config file
PREFIXPATH=$SAMPPARPATH #path to output
PREFIX="prefix" #prefix for xcat output

#generic parts of interfile header
HEADERPART1="!INTERFILE  :=\nname of data file := "
HEADERPART2=".bin\n!GENERAL DATA :=\n!GENERAL IMAGE DATA :=\n!type of data := PET\nimagedata byte order := LITTLEENDIAN\n!PET STUDY (General) :=\n!PET data type := Image\nprocess status := Reconstructed\n!number format := float\n!number of bytes per pixel := 4\nnumber of dimensions := 3\nmatrix axis label [1] := x\n!matrix size [1] := "
HEADERPART3="\nscaling factor (mm/pixel) [1] := "
HEADERPART4="\nmatrix axis label [2] := y\n!matrix size [2] := "
HEADERPART5="\nscaling factor (mm/pixel) [2] := "
HEADERPART6="\nmatrix axis label [3] := z\n!matrix size [3] := "
HEADERPART7="\nscaling factor (mm/pixel) [3] := "
HEADERPART8="\nnumber of time frames := 1\n!END OF INTERFILE :="

#aquires variables from xcat config file
ARRAYSIZE=$(echo $(grep "array_size = " "./"$SAMPPAR) | cut -d' ' -f3)
PIXELWIDTH=$(echo $(grep "pixel_width = " "./"$SAMPPAR) | cut -d' ' -f3)
ENDSLICE=$(echo $(grep "endslice = " "./"$SAMPPAR) | cut -d' ' -f3)
STARTSLICE=$(echo $(grep "startslice = " "./"$SAMPPAR) | cut -d' ' -f3)
SLICEWIDTH=$(echo $(grep "slice_width = " "./"$SAMPPAR) | cut -d' ' -f3)

#converts xcat config file variables which are in cm to mm for interfile header
PIXELWIDTHMM=$(echo "$PIXELWIDTH*10" | bc -l)
SLICEWIDTHMM=$(echo "$SLICEWIDTH*10" | bc -l)

#number of slices
MATRIXSIZE=$(echo "($ENDSLICE-$STARTSLICE)+1" | bc -l)

#to be appended to file names
ACTPREFIX=$PREFIX"_act_"
ATNPREFIX=$PREFIX"_atn_"

#constructs what is the same for every interfile header
GENERALHEADERPART=$HEADERPART2$ARRAYSIZE$HEADERPART3$PIXELWIDTHMM$HEADERPART4$ARRAYSIZE$HEADERPART5$PIXELWIDTHMM$HEADERPART6$MATRIXSIZE$HEADERPART7$SLICEWIDTHMM$HEADERPART8

#moves to xcatpath
cd $XCATPATH

#runs xcat
"./"$XCAT $SAMPPARPATH$SAMPPAR $PREFIXPATH$PREFIX

#moves to sampparpath
cd $SAMPPARPATH

i=1 #loop iterator
END=$(echo $(echo "(($(ls | wc -l)-$EXISTINGFILECOUNT)-1)/2" | bc -l) | cut -d'.' -f1) #loop to

while [ $i -le $END ]
do
    #construct and output activity header
    FILE=$ACTPREFIX$i
    echo -e $HEADERPART1$FILE$GENERALHEADERPART > $FILE".hv"
    
    #construct and output attenuation header
    FILE=$ATNPREFIX$i
    echo -e $HEADERPART1$FILE$GENERALHEADERPART > $FILE".hv"
    
    #increment iterator
    i=$(($i+1))
done
