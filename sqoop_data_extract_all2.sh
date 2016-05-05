#!/bin/sh

source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`

ip=$1
port=$2
mysql_dw=$3
table_name=$4

username=eadmin
password='EWQTB512Oikf;'
log_path=/home/hive/gds/logs/sqoop/$YESTERDAY

mkdir $log_path
echo $log_path
ERRORLOG=$log_path/$table_name$YSETERDAY.log

echo $ERRORLOG
run(){
sqoop import --connect jdbc:mysql://$ip:$port/$mysql_dw?tinyInt1isBit=false --username $username --password $password --table $table_name --fields-terminated-by '\001'  --hive-drop-import-delims --hive-import --hive-table base.$table_name -m 4 --delete-target-dir --hive-overwrite --null-string '\\N' --null-non-string '\\N' >$ERRORLOG
}

run""

