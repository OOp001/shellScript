#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

sqoop import --connect jdbc:mysql://172.16.10.174:3306/qianwang365?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table qw_cas_user --fields-terminated-by '\001' -m 4 --hive-import --columns "id,username,password,enabled,create_time,nick_name,ip_address,last_login_time,phone_city_id,phone_corp,mobile,email,third_platform_id,third_platform_name,trade_password,use_baoling,machine_code,dw_update_time" --hive-drop-import-delims --hive-table base.qw_cas_user --delete-target-dir --hive-overwrite --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/qw_cas_user.log

if [ $? -eq 0 ] ; then
 echo `date +'%Y-%m-%d %H:%M:%S'` >> /home/hive/gds/filewatch/sqoop/input/$YESTERDAY/qw_cas_user
else exit 1
fi
