#!/bin/bash

BPROJECT=$1
IPROJECT=$2
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function help {
	echo '
Usage:
	   ./check.sh path_to_the_build_project_folder path_to_the_project_folder
'
}

if [ $# -lt 2 ]
then
    help
    exit
fi

if [ ! -d $BPROJECT ] || [ ! -d $IPROJECT ]
then
    echo 'ERROR: Directory does not exist. Please specify the correct one'
    help
    exit 1
fi
#
for i in `cat ${IPROJECT}/requirements.txt\
|grep -E -v '^#'\
| tr [:upper:] [:lower:]\
|sort`
do
    LWORD=`echo $i | grep -E -o '^[a-z1-9_.-]+'`
    echo '+++++++++++-AP-+++++++++++'
    echo "======> [${i}]"
    echo '++++++++++++++++++++++++++'
    echo '--------------------------'
    echo 'LOOKING IN THE DEB CONTROL'
    echo '--------------------------'
    while true
    do
        cat ${BPROJECT}/debian/control|grep $LWORD
        echo 'Are you satisfied with the result or \
             you want to change the keyword ? ("n" to abort)'
        read $LWORD
        if [ $LWORD = "n" ]
        then
            exit
        fi
    done
    echo '++++++++++++++++++++++++++'
    read
    echo '--------------------------'
    echo 'LOOKING IN THE RPM CONTROL'
    echo '--------------------------'
    cat ${BPROJECT}/rpm/SPECS/*.spec|grep $LWORD
    echo '++++++++++++++++++++++++++'
    read
done

IFS=$SAVEIFS

unset SAVEIFS BPROJECT IPROJECT LWORD
