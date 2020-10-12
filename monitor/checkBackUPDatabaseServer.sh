#!/bin/bash

## declare an array variable
declare -a arr=($@)
var=$(pwd)
DBPATH="~/../../virtual/$USER/"
## now loop through the above array
for i in "${arr[@]}"
do
    IFS=':' read -ra ITEM <<< "$i"

    var1="$(ssh ${ITEM[0]} "ps aux | grep 'db/DBServer ${ITEM[1]}'| grep -v 'grep'")"
    stringarray1=($var1)
    if [ -z "$var1" ]
    then
        echo "BackUP Database Server:${ITEM[1]} is not working on ${ITEM[0]}"
        var6= ssh ${ITEM[3]} "cd ${DBPATH} && sqlite3 ${ITEM[5]} 'PRAGMA integrity_check;'"
        ssh ${ITEM[3]} "cd ${DBPATH} && sqlite3 ${ITEM[5]} ".recover" | sqlite3 ${ITEM[2]}'"
        scp $2:"${DBPATH}${ITEM[2]}" ./../../virtual/$USER/
        ssh ${ITEM[0]} "cd ${var} && cd .. && nohup sh ./runDBBackup.sh ${ITEM[1]} > foo.out 2> foo.err < /dev/null & "
    else
        if [[ ${stringarray1[0]} == $USER ]]
        then
             echo "BackUP Database Server:${ITEM[1]} (${stringarray1[1]}) is working on ${ITEM[0]}"
        fi
    fi
done
