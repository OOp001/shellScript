##################################################################################
##@name backup_file.sh                                                          ##
##@author 01                                                                    ##
##@function  备份日志                                                           ##
##@example ： sh backup_file.sh                                                 ##
##################################################################################
#!/bin/bash

stat_date=`date +%Y%m%d`
backup_path=$1
file_name=$2
log_path=/home/logs
logfile=${log_path}/${file_name}_${stat_date}_bak.log

echo "---Starting Backup Files ----  $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${logfile}

tar -zcvf ${backup_path}/${file_name}_${stat_date}.gz ${backup_path} &>>${logfile}

echo "---Finished Backup File ----  $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${logfile}

scp  ${backup_path}/${file_name}_${stat_date}.gz root@172.16.14.75:/home/bak/


rm -rf ${backup_path}/${file_name}_${stat_date}.gz
