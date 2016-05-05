##################
##@name task_waiting.sh
##@author 01
##@function  等待抛出文件
##@example ： sh task_waiting.sh sqoop test
##################

#!/bin/bash

  if [ $# -eq 3 ];then
    filewatch_path=$1
    stat_date=$2
    task_name=$3
  elif [ $# -eq 2 ];then
    filewatch_path=$1
    stat_date=`date -d yesterday +%Y%m%d`
    task_name=$2
  fi

  if [ ${filewatch_path} = 'sqoop' ];then
   path=/home/hive/gds/filewatch/${filewatch_path}/input/${stat_date}
  else
   path=/home/hive/gds/filewatch/${filewatch_path}/${stat_date}
  fi

echo ${path}
##等待抛出文件

   while [ ! -f ${path}/${task_name} ]
     do
      echo "waiting file ${task_name}"

     sleep 5
    
    done


