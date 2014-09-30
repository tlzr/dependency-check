#!/bin/bash

function get_real_path {
    realpath / > /dev/null 2>&1

    if [ $? -gt 0 ]
    then
        echo 'Error: realpath is not installed.
Please install it with the help of you packet manager.'
        exit 2
    else
        SCRIPTPATH=`realpath $0`
        SCRIPTDIRNAME=`dirname $SCRIPTPATH`
    fi
}

get_real_path

PACKAGESEARCH=1
BPROJECT=$1
IPROJECT=$2
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function help {
	echo '
Usage:
	   ./check.sh path_to_the_build_project_folder path_to_the_project_folder
'
        exit 1
}

function spec_infile_search {
    while true
    do
        if [ ! -z $TMPWORD ]
        then
            cat ${BPROJECT}${SPECFILEPATH}|grep $TMPWORD
            if [ $PACKAGESEARCH -eq 1 ]; then package_search; fi
            echo "..........................
Do you want to skip/change the keyword '$TMPWORD' ? (ENTER to abort)
.........................."
            read TMPWORD
            if [ -z $TMPWORD ] || [ $TMPWORD = "n" ]; then break; fi
        else
            break
        fi
    done
}

function package_search {
    if [ $PACKAGESEARCH -eq 1 ] && [ -f ../packaging-env/work.sh ]
    then
        ../packaging-env/work.sh search cache $TMPWORD
    fi
}

([ $# -eq 2 ]) || help

if [ ! -d $BPROJECT ] || [ ! -d $IPROJECT ]
then
    echo 'ERROR: Directory does not exist. Please specify the correct one'
    help
fi

for i in `cat ${IPROJECT}/requirements.txt\
|grep -E -v '^#'\
|tr [:upper:] [:lower:]\
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
    SPECFILEPATH='/debian/control'
    spec_infile_search
    echo '++++++++++++++++++++++++++'
    read
    TMPWORD=$LWORD
    echo '--------------------------'
    echo 'LOOKING IN THE RPM CONTROL'
    echo '--------------------------'
    SPECFILEPATH='/rpm/SPECS/*.spec'
    spec_infile_search
    echo '++++++++++++END+++++++++++'
    read
done

IFS=$SAVEIFS

unset SAVEIFS BPROJECT IPROJECT LWORD
