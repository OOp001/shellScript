#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

YESTERDAY=`date -d yesterday +%Y-%m-%d`
TERDAY=`date -d"-1 hour" "+%Y%m%d"`
TERDAY_TY=`date +"%Y-%m-%d %H:00:00"`
TOMORROW=`date -d next-day +%Y%m%d`
DAY_7_HOUR=`date -d "-7 day -1 hour" "+%Y%m%d%H"`
TERDAY_HOUR=`date -d"-1 hour" "+%Y%m%d%H"`
TERDAY_HOUR_H=`date -d"-1 hour" "+%Y-%m-%d %H:00:00"`
YESTERDAY_HOUR=`date -d "yesterday -1 hour" "+%Y%m%d%H"`  

pd=eadmin
password='EWQTB512Oikf;'

run(){
sqoop import --connect jdbc:mysql://172.16.14.65:3306/hyip?tinyInt1isBit=false --username $pd --password $password --table hyip_wallet_workflow --fields-terminated-by '\001' --where "create_time>=$TERDAY and create_time<$TOMORROW" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.hyip_wallet_workflow_hour --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $TERDAY --null-string '\\N' --null-non-string '\\N'

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "refresh base.hyip_wallet_workflow_hour;insert overwrite table dm.heavy_transfer_region_stat_diff_hour partition (dt='$TERDAY_HOUR')
select '$TERDAY_HOUR',i.province,i.city,sum(abs(a.amount)) total_amount,0 user_num from
(select wallet_id user_id,round(sum(abs(w.amount))/100,2) amount  from base.hyip_wallet_workflow_hour w where dt='$TERDAY' 
and w.type in(58,59,60,61) and w.create_time < '$TERDAY_TY' and w.create_time >= '$TERDAY_HOUR_H'
group by wallet_id) a
left join
dw.user_province_city_info i on a.user_id = i.user_id
group by i.province,i.city;"

if [ $? -eq 0 ] ; then
echo "recharge hour $TERDAY_TY is success!"
else
echo "recharge hour $TERDAY_TY is false!"
exit 1
fi

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert overwrite table dm.heavy_transfer_region_stat_hour partition (dt='$TERDAY_HOUR')
select '$TERDAY_HOUR',i.province,i.city,sum(abs(a.amount)) total_amount,0 user_num from
(select wallet_id user_id,round(sum(abs(w.amount))/100,2) amount  from base.hyip_wallet_workflow_hour w where dt='$TERDAY'
and w.type in(58,59,60,61) and w.create_time < '$TERDAY_TY' group by wallet_id) a
left join
dw.user_province_city_info i on a.user_id = i.user_id
group by i.province,i.city;"

if [ $? -eq 0 ] ; then
echo "recharge hour $TERDAY_TY is success!"
else
echo "recharge hour $TERDAY_TY is false!"
exit 1
fi

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "insert overwrite table dm.heavy_transfer_region_hour_info partition(dt='$TERDAY_HOUR')
select '$TERDAY_HOUR',province,city,total_amount,user_num,
round(nvl(total_amount/sum_amount,0),4) ratio,
0 del_dod_amount,
0 dod_amount_ratio,
total_amount - wow_amount del_wow_amount,
round(NVL((total_amount - wow_amount)/wow_amount,9999),2) wow_amount_ratio
from
(select '$TERDAY_HOUR' as dt,
COALESCE(d1.province,d3.province,'未知') province,
COALESCE(d1.city,d3.city,'未知') city,
sum(NVL(d1.total_amount,0)) total_amount,
sum(NVL(d1.user_num,0)) user_num,
sum(NVL(d3.pre_week_amount,0)) wow_amount
from
(select province,city,total_amount,user_num from dm.heavy_transfer_region_stat_hour where dt='$TERDAY_HOUR') d1
FULL JOIN
(select province,city,total_amount pre_week_amount from dm.heavy_transfer_region_stat_hour where dt='$DAY_7_HOUR') d3
ON d1.province = d3.province and d1.city = d3.city
group by COALESCE(d1.province,d3.province,'未知'),COALESCE(d1.city,d3.city,'未知')) a
left join
(select dt,sum(total_amount) sum_amount from dm.heavy_transfer_region_stat_hour where dt='$TERDAY_HOUR'
group by dt) d4 on d4.dt = a.dt;"

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "select '$TERDAY_HOUR_H',province,city,total_amount,user_num,ratio,dod_amount,dod_ratio,wow_amount,wow_ratio from dm.heavy_transfer_region_hour_info where dt=$TERDAY_HOUR" >/home/hive/gds/doc/heavy_transfer_region_hour_info_$TERDAY_HOUR.txt

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "select '$TERDAY_HOUR_H',nvl(province,'未知'),nvl(city,'未知'),total_amount,user_num from dm.heavy_transfer_region_stat_diff_hour where dt=$TERDAY_HOUR" >/home/hive/gds/doc/heavy_transfer_region_stat_diff_hour_$TERDAY_HOUR.txt
 }
run 1>>/home/hive/gds/logs/hive/heavy_transfer_region_hour/call_proc_heavy_transfer_region_hour_info_$TERDAY_HOUR.log 2>&1

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "LOAD DATA LOCAL INFILE '/home/hive/gds/doc/heavy_transfer_region_stat_diff_hour_$TERDAY_HOUR.txt' INTO TABLE heavy_transfer_region_diff_stat_hour FIELDS TERMINATED BY '\t'"

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "LOAD DATA LOCAL INFILE '/home/hive/gds/doc/heavy_transfer_region_hour_info_$TERDAY_HOUR.txt' INTO TABLE heavy_transfer_region_stat_hour FIELDS TERMINATED BY '\t'"
