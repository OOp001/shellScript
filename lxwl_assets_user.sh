
#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

DAY_90=`date -d "-91 day" +%Y%m%d`
DAY_30=`date -d "-31 day" +%Y%m%d`
YESTERDAY=`date -d yesterday +%Y%m%d`

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "select user_id,t90,t30,t0,t90-t0,t30-t0 from (
select user_id,
max(total_assets) t90,
max(case when dt>='$DAY_30' then total_assets else 0 end) t30,
max(case when dt= '$YESTERDAY' then total_assets else 0 end) t0
from dw.light_user_general_stat_day_mysql_extend 
where dt>='$DAY_90' 
group by user_id) t where t90>=500000 or t30>=500000 or t0>=500000;" > /home/hive/gds/doc/lxwl_assets_user_$YESTERDAY.txt

if [ $? -eq 0 ] ; then
echo "analyse is success!"
else
echo "analyse is false!"
exit 1
fi

/usr/bin/mysql -ueadmin -p'EWQTB512Oikf;' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dtest -e "TRUNCATE table lxwl_assets_user;LOAD DATA LOCAL INFILE '/home/hive/gds/doc/lxwl_assets_user_$YESTERDAY.txt' INTO TABLE lxwl_assets_user FIELDS TERMINATED BY '\t'"
