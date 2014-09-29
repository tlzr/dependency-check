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

for i in `cat ${IPROJECT}/requirements.txt\
|grep -E -v '^#'\
| tr [:upper:] [:lower:]\
|sort`
do
    LWORD=`echo $i | grep -E -o '^[a-z1-9_.-]+'`
    echo '+++++++++++-AP-+++++++++++'
    echo "======> [${i}]"
    echo '++++++++++++++++++++++++++'
    TMPWORD=$LWORD
    echo '--------------------------'
    echo 'LOOKING IN THE DEB CONTROL'
    echo '--------------------------'
    while true
    do
        if [ ! -z $TMPWORD ]
        then
            cat ${BPROJECT}/debian/control|grep $TMPWORD
            echo "..........................
Do you want to skip/change the keyword '$LWORD' ? (ENTER to abort)
.........................."
            read LWORD
            if [ ! -z $TMPWORD ] && [ $TMPWORD != "n" ]; then break; fi
        else
            break
        fi
    done
    echo '++++++++++++++++++++++++++'
    read
    TMPWORD=$LWORD
    echo '--------------------------'
    echo 'LOOKING IN THE RPM CONTROL'
    echo '--------------------------'
    while true
    do
        if [ ! -z $TMPWORD ]
        then
            cat ${BPROJECT}/rpm/SPECS/*.spec|grep $TMPWORD
            echo "..........................
Do you want to skip/change the keyword '$LWORD' ? (ENTER to abort)
.........................."
            read LWORD
            if [ ! -z $TMPWORD ] && [ $TMPWORD != "n" ]; then break; fi
        else
            break
        fi
    done

    echo '++++++++++++END+++++++++++'
    read
done

IFS=$SAVEIFS

unset SAVEIFS BPROJECT IPROJECT LWORD
