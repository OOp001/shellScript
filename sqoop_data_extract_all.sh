#!/bin/sh

source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`
ip=$1
port=$2
mysql_dw=$3
table_name=$4

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

sqoop import --connect jdbc:mysql://$ip:$port/$mysql_dw?tinyInt1isBit=false --username $username --password $password --table $table_name --fields-terminated-by '\001'  --hive-drop-import-delims --hive-import --hive-table base.$table_name -m 4 --delete-target-dir --hive-overwrite --null-string '\\N' --null-non-string '\\N' &>> $log_path/$table_name.log
if [ $? -eq 0 ] ; then
	echo $CURRENT_DATE >>$filewatch_path/$table_name
        echo "$YESTERDAY $table_name sqoop import  ok " >> $log_path/$table_name.log
else
        echo "$YESTERDAY $table_name sqoop import  error" >> $log_path/$table_name.log
exit 1
fi
