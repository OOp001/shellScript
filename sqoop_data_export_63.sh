##############################################################################################
##@name sqoop_data_export.sh                                                            
##@author 01                                                                    
##@function  导出hive数据至mysql                                                      
##@example ： sh sqoop_data_export.sh  heavy_transfer_channel_stat_day dw heavy_transfer_channel_stat_day 20151102
############################################################################################

#!/bin/sh

source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
yesterday=`date -d yesterday +%Y%m%d`
current_date=`date +'%Y-%m-%d %H:%M:%S'`




if [ $# -eq 4 ];then
  mysql_table_name=$1
  schema=$2
  hive_table_name=$3
  data_date=$4
else
  mysql_table_name=$1
  schema=$2
  hive_table_name=$3
  data_date=${yesterday}
fi

filewatch_path=/home/hive/gds/filewatch/sqoop/output/${data_date}
test ! -d ${filewatch_path} && mkdir ${filewatch_path}
logpath=/home/hive/gds/logs/sqoop/output/${data_date}
test ! -d ${logpath} && mkdir ${logpath}
logfile=${logpath}/${schema}.${hive_table_name}_${data_date}.log

username=eadmin
password='EWQTB512Oikf;'

echo "---start sqoop export data ${schema}.${hive_table_name}_63_${data_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"

sqoop export --connect jdbc:mysql://172.16.14.63:3306/dw --username  ${username} --password ${password} --table ${mysql_table_name} --export-dir /user/hive/warehouse/${schema}.db/${hive_table_name}/dt=${data_date} --input-fields-terminated-by '\001' &>> "$logfile"

if [ $? -eq 0 ];then
  echo "---sqoop export data ${schema}.${hive_table_name}_63_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
   
  echo "---sqoop export data ${schema}.${hive_table_name}_63_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${schema}.${hive_table_name}

else

  echo "---sqoop export data ${schema}.${hive_table_name}_63_${data_date} error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  exit 1

fi

