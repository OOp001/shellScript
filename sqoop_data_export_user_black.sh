#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
yesterday=`date -d yesterday +%Y%m%d`

hive -e "select ip,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_ip_blacklist ">/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt' INTO TABLE user_ip_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select presenter_id,username,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_presenter_blacklist">/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt' INTO TABLE user_presenter_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select stat_date,user_id,username,create_time,lock_reason_type,5 as status,operate_time from dw.user_login_blacklist_day where dt=$yesterday">/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt' INTO TABLE user_login_blacklist_day FIELDS TERMINATED BY '\t'"
