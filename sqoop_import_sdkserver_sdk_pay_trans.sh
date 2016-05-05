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

sqoop import --connect jdbc:mysql://172.16.3.93:3307/sdkserver?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table sdk_pay_trans_$month --fields-terminated-by '\001' -m 1 --hive-import  --hive-drop-import-delims --hive-table base.sdkserver_sdk_pay_trans --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $month --null-string '\\N' --null-non-string '\\N' &>> $log_path/sdkserver_sdk_pay_trans.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/sdkserver_sdk_pay_trans
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  ok " >> $log_path/sdkserver_sdk_pay_trans.log
else
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  error" >> $log_path/sdkserver_sdk_pay_trans.log
exit 1
fi
