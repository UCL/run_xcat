#!/bin/bash

#Copyright University College London 2019
#Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
#For internal research only.

sum()
{
    ACTPREFIX=$(echo $1 | rev | cut -d'/' -f1 | rev)
    ACTPATH=$(pwd)"/"$ACTPREFIX
    
    LESIONACTPATH=$LESIONPATH"/"$ACTPREFIX
    OUTPUTACTPATH=$OUTPUTPATH"/"$ACTPREFIX
    
    if [ $(echo $ACTPREFIX | cut -d'.' -f2) == "hv" ]
    then
        $STIR $OUTPUTACTPATH $ACTPATH $LESIONACTPATH
    fi
}

phantom_directory()
{
    PHANTOMPREFIX=$(echo $1 | rev | cut -d'/' -f1 | rev)
    PHANTOMPATH=$(pwd)"/"$PHANTOMPREFIX
    
    PREFIX=${PHANTOMPREFIX//"_phantom"/}
    LESIONPATH=$(pwd)"/"$PREFIX"_lesion"
    OUTPUTPATH=$(pwd)"/"$PREFIX"_sum"
    
    rm -rf $OUTPUTPATH
    mkdir $OUTPUTPATH
    
    export STIR=$STIR
    export LESIONPATH=$LESIONPATH
    export OUTPUTPATH=$OUTPUTPATH
    
    export -f sum
    find $PHANTOMPATH -name *act* -execdir bash -c 'sum {}' \;
    find $PHANTOMPATH -name *atn* -execdir bash -c 'sum {}' \;
}

main()
{    
    export STIR=$1
    export -f phantom_directory
    export -f sum
    find ./ -name *phantom -execdir bash -c 'phantom_directory {}' \;
    
    exit 0
}

#start
main "$@"
