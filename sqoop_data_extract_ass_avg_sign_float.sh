#!/bin/bash
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

username=eadmin
password='EWQTB512Oikf;'
log_path=/home/hive/gds/logs/sqoop/output/$YESTERDAY
filewatch_path=/home/hive/gds/filewatch/sqoop/output/$YESTERDAY
if [ ! -d $log_path ] ; then
mkdir $log_path
fi
echo $log_path
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.38:3306/qbass --username eadmin --password 'EWQTB512Oikf;' --table ass_avg_sign_float --export-dir /user/hive/warehouse/dm.db/ass_avg_sign_float/dt=$YESTERDAY --update-key "user_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4 &>> $log_path/dm.ass_avg_sign_float.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/merchant_shop_grey_list
        echo "$YESTERDAY $table_name sqoop export  ok " >> $log_path/dm.ass_avg_sign_float.log
else
        echo "$YESTERDAY $table_name sqoop export  error" >> $log_path/dm.ass_avg_sign_float.log
exit 1
fi
