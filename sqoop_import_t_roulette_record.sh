#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`
month=`date -d yesterday +%Y%m`

username=eadmin
password='EWQTB512Oikf;'
log_path=/home/hive/gds/logs/sqoop/input/$YESTERDAY
filewatch_path=/home/hive/gds/filewatch/sqoop/input/$YESTERDAY
if [ ! -d $log_path ] ; then
mkdir $log_path
fi
echo $log_path
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

sqoop import --connect jdbc:mysql://172.16.3.94:3306/hongbao?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table t_roulette_record_$month --fields-terminated-by '\001' -m 10 --hive-import  --hive-drop-import-delims --hive-table base.t_roulette_record --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $month --null-string '\\N' --null-non-string '\\N' &>> $log_path/t_roulette_record.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/t_roulette_record
        echo "$YESTERDAY t_roulette_record sqoop import  ok " >> $log_path/t_roulette_record.log
else
        echo "$YESTERDAY t_roulette_record sqoop import  error" >> $log_path/t_roulette_record.log
exit 1
fi

