#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

if [ $# -eq 1 ];then
  YESTERDAY=$1
else
  YESTERDAY=`date -d yesterday +%Y%m%d`
fi

sqoop import --connect jdbc:mysql://172.16.14.45:3306/sign?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table sign_question_user_answer_$YESTERDAY --fields-terminated-by '\001' -m 4 --hive-import --hive-drop-import-delims --hive-table base.sign_question_user_answer --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/sign_question_user_answer.log

if [ $? -eq 0 ] ; then
 echo `date +'%Y-%m-%d %H:%M:%S'` >> /home/hive/gds/filewatch/sqoop/input/$YESTERDAY/sign_question_user_answer
else exit 1
fi
