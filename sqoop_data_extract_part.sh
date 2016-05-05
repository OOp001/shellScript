#!/bin/sh

source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
if [ ! -n "$6" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
  TODAY=`date +%Y%m%d`

else
   YESTERDAY="$6"
   SECONDS=`date -d "$6" +%s`       
   SECONDS_NEW=`expr $SECONDS + 86400`              
   TODAY=`date -d @$SECONDS_NEW "+%Y%m%d"` 

fi
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

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

ip=$1
port=$2
mysql_dw=$3
table_name=$4
where_column=$5

sqoop import --connect jdbc:mysql://$ip:$port/$mysql_dw?tinyInt1isBit=false --username $username --password $password --table $table_name --fields-terminated-by '\001' --where "$where_column >=$YESTERDAY and $where_column<$TODAY" -m 4  --hive-drop-import-delims --hive-import --hive-table base.$table_name --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>> $log_path/$table_name.log

if [ $? -eq 0 ] ; then
        echo "$YESTERDAY $table_name sqoop import  ok " >> $log_path/$table_name.log
	echo $CURRENT_DATE >>$filewatch_path/$table_name
else
        echo "$YESTERDAY $table_name sqoop import  error" >> $log_path/$table_name.log
	exit 1
fi
