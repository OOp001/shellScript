#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
pd=hadoopadmin
pswd34='1243vczx;'
pswd38='asdWQ$3d^&*sdf#$#2eqs'
tablenm=light_present_stat_day
if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

ERRORLOG=/home/hive/gds/logs/sqoop/output/$YESTERDAY/$tablenm.log
if [ ! -d $ERRORLOG ] ; then
mkdir /home/hive/gds/logs/sqoop/output/$YESTERDAY/
fi
echo /home/hive/gds/logs/sqoop/output/$YESTERDAY/

filewatch_path=/home/hive/gds/filewatch/hive/$YESTERDAY
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table light_present_stat_day --export-dir /user/hive/warehouse/dw.db/light_present_stat_day_crnt --update-key "register_date,presenter_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4
