##################################################################################
##@name call_proc.sh                                                            ##
##@author 01                                                                    ##
##@function  调度hive脚本                                                       ##
##@example ： sh call_proc.sh.sh  20151102 proc_heavy_transfer_channel_stat_day ##
##################################################################################




#!/bin/bash
  if [ $# -eq 2 ]; then  
    stat_date="$1"  
    sqlfile="$2"
  elif  [ $# -eq 1 ]; then  
    stat_date=`date -d yesterday +%Y%m%d`
    sqlfile="$1"
  else
    echo "wrong arg[] number"
    exit 1
  fi 

  logpath=/home/hive/gds/logs/hive/${stat_date}
  test ! -d $logpath && mkdir $logpath
    
  logfile="${logpath}/${sqlfile}_${stat_date}.log"
  hqlpath="/home/hive/gds/hql/"
  filewatch_path="/home/hive/gds/filewatch/hive"
  echo "${filewatch_path/stat_date}"
  if [ ! -d ${filewatch_path}/${stat_date} ];then 
    mkdir ${filewatch_path}/${stat_date}
  fi

  
  echo "---start running procedure ${sqlfile} ${stat_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  
  hive -hivevar data_date=${stat_date}  -f ${hqlpath}${sqlfile}.sql &>> "$logfile"
  
  if [ $? -eq 0 ];then
  
    echo "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
     
    echo  "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${stat_date}/${sqlfile}


  else
  
    echo "---calling procedure error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
    exit 1
  
  fi 



