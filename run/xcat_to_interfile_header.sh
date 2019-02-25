EXISTINGFILECOUNT=2

XCATPATH="/home/alexander/XCAT/"
XCAT="dxcat2_linux_64bit"
SAMPPAR="xcat.samp.par"
PREFIX="prefix"

ACTPREFIX=$PREFIX"_act_"
ATNPREFIX=$PREFIX"_atn_"

HEADERPART1="!INTERFILE  :=\nname of data file := "
HEADERPART2=".bin\n!GENERAL DATA :=\n!GENERAL IMAGE DATA :=\n!type of data := PET\nimagedata byte order := LITTLEENDIAN\n!PET STUDY (General) :=\n!PET data type := Image\nprocess status := Reconstructed\n!number format := float\n!number of bytes per pixel := 4\nnumber of dimensions := 3\nmatrix axis label [1] := x\n!matrix size [1] := "
HEADERPART3="\nscaling factor (mm/pixel) [1] := "
HEADERPART4="\nmatrix axis label [2] := y\n!matrix size [2] := "
HEADERPART5="\nscaling factor (mm/pixel) [2] := "
HEADERPART6="\nmatrix axis label [3] := z\n!matrix size [3] := "
HEADERPART7="\nscaling factor (mm/pixel) [3] := "
HEADERPART8="\nnumber of time frames := 1\n!END OF INTERFILE :="

ARRAYSIZE=$(echo $(grep "array_size = " "./"$SAMPPAR) | cut -d' ' -f3)
PIXELWIDTH=$(echo $(grep "pixel_width = " "./"$SAMPPAR) | cut -d' ' -f3)
ENDSLICE=$(echo $(grep "endslice = " "./"$SAMPPAR) | cut -d' ' -f3)
STARTSLICE=$(echo $(grep "startslice = " "./"$SAMPPAR) | cut -d' ' -f3)
SLICEWIDTH=$(echo $(grep "slice_width = " "./"$SAMPPAR) | cut -d' ' -f3)

PIXELWIDTHMM=$(echo "$PIXELWIDTH*10" | bc -l)
SLICEWIDTHMM=$(echo "$SLICEWIDTH*10" | bc -l)

MATRIXSIZE=$(echo "($ENDSLICE-$STARTSLICE)+1" | bc -l)

GENERALHEADERPART=$HEADERPART2$ARRAYSIZE$HEADERPART3$PIXELWIDTHMM$HEADERPART4$ARRAYSIZE$HEADERPART5$PIXELWIDTHMM$HEADERPART6$MATRIXSIZE$HEADERPART7$SLICEWIDTHMM$HEADERPART8

DIR=$(pwd)"/"

cd $XCATPATH

"./"$XCAT $DIR$SAMPPAR $DIR$PREFIX

cd $DIR

i=1
END=$(echo $(echo "(($(ls | wc -l)-$EXISTINGFILECOUNT)-1)/2" | bc -l) | cut -d'.' -f1)

while [ $i -le $END ]; do
    echo $i
    
    FILE=$ACTPREFIX$i
    
    echo $HEADERPART1$FILE$GENERALHEADERPART > $FILE".hv"
    
    FILE=$ATNPREFIX$i
    
    echo $HEADERPART1$FILE$GENERALHEADERPART > $FILE".hv"
    
    i=$(($i+1))
done
