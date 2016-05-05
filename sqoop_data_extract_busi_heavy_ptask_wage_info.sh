#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
if [ -z $1 ]; then
  YESTERDAY_YMD=`date -d yesterday +%Y%m%d`
  TODAY=`date +%Y-%m-%d`
  BEFOR_YESTERDAY=`date -d -2days +%Y%m%d`
else
  YESTERDAY_YMD=$1
  TODAY=$2
  BEFOR_YESTERDAY=$3
fi

sqoop import --connect jdbc:mysql://172.16.14.44:3306/dw?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table busi_heavy_ptask_wage_info --fields-terminated-by '\001' --where "stat_date=$BEFOR_YESTERDAY" -m 1 --hive-drop-import-delims --hive-import --hive-table dm.busi_heavy_ptask_wage_info --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $BEFOR_YESTERDAY --null-string '\\N' --null-non-string '\\N' &>> /home/hive/gds/logs/sqoop/input/$BEFOR_YESTERDAY/busi_heavy_ptask_wage_info.log
