#!/bin/bash
YESTERDAY_YMD=`date -d yesterday +%Y%m%d`
file_path=/home/hive/gds/filewatch/hive/$YESTERDAY_YMD/c_qb_mobile_nginx

while [ ! -s $file_path ]
do
 /usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.8.38 -P3306 --default-character-set=utf8 -Ddc -e "select * from td_hive_report_task where TASK_DATE=$YESTERDAY_YMD and REPORT_NAME='qb_mobile_nginx_web_url_day' and flag=1" > $file_path

cat $file_path

sleep 300

done
