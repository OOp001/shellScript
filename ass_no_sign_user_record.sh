birthday_user_bless.sh                                                                              0000644 0000000 0000000 00000002034 12707562267 014161  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
#会员生日祝福,每日生成明天过生日的会员ID并写入Redis
if [ $# -eq 1 ]; then
TERDAY=$1
TERDAY_TY=`date -d "$1 0 days" "+%Y-%m-%d"`
else
TERDAY=`date "+%Y%m%d"`
TERDAY_TY=`date "+%Y-%m-%d"`
fi
run(){
#计算当天用户
/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "select user_id from base.hyip_third_verifieduser where length(id_code)=18 and substring(trim(id_code),11,2)<='12' and substring(trim(id_code),13,2)<='31'and (substring(trim(id_code),11,4)) = FROM_UNIXTIME(UNIX_TIMESTAMP(date_add(FROM_UNIXTIME(UNIX_TIMESTAMP('$TERDAY_TY'),'yyyy-MM-dd'),1)),'MMdd')" -o /home/hive/gds/doc/BIRTHDAY_USER_ID.txt -B

if [ $? -eq 0 ];then
echo "succeed!"
else
exit 1
echo "false!"
fi
#写入redis
java -jar /home/hive/gds/lib/redisUtil.jar redis03 0 birthday_user
if [ $? -eq 0 ];then
echo "succeed!"
else
exit 1
echo "false!"
fi }
run 1 >>/home/hive/gds/logs/java/birthday_user_$TERDAY.log 2>&1
echo $TERDAY
echo $TERDAY_TY
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    call_mysql_proc_busi_shop_list_sqoop_input.sh                                                       0000644 0000000 0000000 00000000761 12703635427 021056  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
username=dcadmin
password='EWQTB512Oikf;'
YESTERDAY=`date -d yesterday +%Y%m%d`

ip=172.16.14.63
mysql_proc_name=proc_busi_shop_list
dw_name=dw
port=3306
data_date=$YESTERDAY

/usr/bin/mysql -u$username -p'sadas3432$#%ret@!sd76' -h$ip -P$port --default-character-set=utf8 -D$dw_name -e "call $mysql_proc_name($data_date)"

/home/hive/gds/bin/sqoop_data_extract_all.sh 172.16.14.63 3306 dw busi_shop_list
               call_mysql_proc.sh                                                                                  0000644 0000000 0000000 00000001631 12642474131 013300  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   me call_mysql_proc.sh                                                            
##@author yqf                                                                   
##@function  call proc for mysql                                                      
##@example ： sh call_mysql_proc.sh  172.16.8.38 3306 dw proc_team_merchant_assess_stat_day (20160103)
############################################################################################
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
username=dcadmin
password=`sadas3432$#%ret@!sd76`
YESTERDAY=`date -d yesterday +%Y%m%d`

if [ $# -eq 5 ];then
  ip=$1
  mysql_proc_name=$2
  dw_name=$3
  port=$4
  data_date=$5
 else
  ip=$1
  mysql_proc_name=$2
  dw_name=$3
  port=$4
  data_date=$YESTERDAY

/usr/bin/mysql -u$username -p$password -h$ip -P$port --default-character-set=utf8 -D$dw_name -e "call $mysql_proc_name($data_date)"
                                                                                                       call_proc_heavy_recharge_region_hour_info.sh                                                        0000644 0000000 0000000 00000010352 12710333164 020516  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
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
/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert overwrite table dm.heavy_recharge_region_stat_diff_hour partition (dt='$TERDAY_HOUR')
select '$TERDAY_HOUR',i.province,i.city,sum(abs(a.amount)) total_amount,0 user_num from
(select wallet_id user_id,round(sum(abs(w.amount))/100,2) amount  from base.hyip_wallet_workflow_hour w 
where dt='$TERDAY'and w.type in(3,353) and w.create_time < '$TERDAY_TY' and w.create_time >= '$TERDAY_HOUR_H'
group by wallet_id) a
left join
dw.user_province_city_info  i
on a.user_id = i.user_id
group by i.province,i.city;"

if [ $? -eq 0 ] ; then
echo "recharge hour $TERDAY_TY is success!"
else
echo "recharge hour $TERDAY_TY is false!"
exit 1
fi
/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert overwrite table dm.heavy_recharge_region_stat_hour partition (dt='$TERDAY_HOUR')
select '$TERDAY_HOUR',i.province,i.city,sum(abs(a.amount)) total_amount,0 user_num from
(select wallet_id user_id,round(sum(abs(w.amount))/100,2) amount  from base.hyip_wallet_workflow_hour w where dt='$TERDAY'
and w.type in(3,353) and w.create_time < '$TERDAY_TY' group by wallet_id) a
left join
dw.user_province_city_info i
on a.user_id = i.user_id
group by i.province,i.city;"

if [ $? -eq 0 ] ; then
echo "recharge hour $TERDAY_TY is success!"
else
echo "recharge hour $TERDAY_TY is false!"
exit 1
fi

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "insert overwrite table dm.heavy_recharge_region_hour_info partition(dt='$TERDAY_HOUR')
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
(select province,city,total_amount,user_num from dm.heavy_recharge_region_stat_hour where dt='$TERDAY_HOUR') d1
FULL JOIN
(select province,city,total_amount pre_week_amount from dm.heavy_recharge_region_stat_hour where dt='$DAY_7_HOUR') d3
ON d1.province = d3.province and d1.city = d3.city
group by COALESCE(d1.province,d3.province,'未知'),COALESCE(d1.city,d3.city,'未知')) a
left join
(select dt,sum(total_amount) sum_amount from dm.heavy_recharge_region_stat_hour where dt='$TERDAY_HOUR'
group by dt) d4 on d4.dt = a.dt;"

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "select '$TERDAY_HOUR_H',province,city,total_amount,user_num,ratio,dod_amount,dod_ratio,wow_amount,wow_ratio from dm.heavy_recharge_region_hour_info where dt=$TERDAY_HOUR" >/home/hive/gds/doc/heavy_recharge_region_hour_info_$TERDAY_HOUR.txt

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "select '$TERDAY_HOUR_H',nvl(province,'未知'),nvl(city,'未知'),total_amount,user_num from dm.heavy_recharge_region_stat_diff_hour where dt=$TERDAY_HOUR" >/home/hive/gds/doc/heavy_recharge_region_stat_diff_hour_$TERDAY_HOUR.txt
}
run 1>>/home/hive/gds/logs/hive/heavy_recharge_region_hour/call_proc_heavy_recharge_region_hour_info_$TERDAY_HOUR.log 2>&1

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "LOAD DATA LOCAL INFILE '/home/hive/gds/doc/heavy_recharge_region_stat_diff_hour_$TERDAY_HOUR.txt' INTO TABLE heavy_recharge_region_diff_stat_hour FIELDS TERMINATED BY '\t'"

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "LOAD DATA LOCAL INFILE '/home/hive/gds/doc/heavy_recharge_region_hour_info_$TERDAY_HOUR.txt' INTO TABLE heavy_recharge_region_stat_hour FIELDS TERMINATED BY '\t'"
                                                                                                                                                                                                                                                                                      call_proc_heavy_transfer_region_hour_info.sh                                                        0000644 0000000 0000000 00000011353 12710333214 020560  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
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
                                                                                                                                                                                                                                                                                     call_proc.sh                                                                                        0000744 0000000 0000000 00000003224 12625304714 012054  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##################################################################################
##@name call_proc.sh                                                            ##
##@author 01                                                                    ##
##@function  调度hive脚本                                                       ##
##@example ： sh call_proc.sh.sh  20151102 proc_heavy_transfer_channel_stat_day ##
##################################################################################




#!/bin/bash
  if [ $# -eq 2 ]; then  
    stat_date="$1"  
    sqlfile="$2"
  elif  [ $# -eq 1 ]; then  
    stat_date=`date -d yesterday +%Y%m%d`
    sqlfile="$1"
  else
    echo "wrong arg[] number"
    exit 1
  fi 

  logpath=/home/hive/gds/logs/hive/${stat_date}
  test ! -d $logpath && mkdir $logpath
    
  logfile="${logpath}/${sqlfile}_${stat_date}.log"
  hqlpath="/home/hive/gds/hql/"
  filewatch_path="/home/hive/gds/filewatch/hive"
  echo "${filewatch_path/stat_date}"
  if [ ! -d ${filewatch_path}/${stat_date} ];then 
    mkdir ${filewatch_path}/${stat_date}
  fi

  
  echo "---start running procedure ${sqlfile} ${stat_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  
  hive -hivevar data_date=${stat_date}  -f ${hqlpath}${sqlfile}.sql &>> "$logfile"
  
  if [ $? -eq 0 ];then
  
    echo "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
     
    echo  "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${stat_date}/${sqlfile}


  else
  
    echo "---calling procedure error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
    exit 1
  
  fi 



                                                                                                                                                                                                                                                                                                                                                                            call_proc_team_merchant_assess_stat_day.sh                                                          0000744 0000000 0000000 00000001250 12651563365 020221  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "call proc_team_merchant_assess_stat_week($YESTERDAY)"
/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "call proc_team_merchant_assess_stat_month($YESTERDAY)"

#/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.8.38 -P3306 --default-character-set=utf8 -Ddw -e "call proc_team_merchant_assess_stat_day($YESTERDAY)"
                                                                                                                                                                                                                                                                                                                                                        event_c_qb_mobile_nginx.sh                                                                          0000744 0000000 0000000 00000000665 12651344467 014773  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/bash
YESTERDAY_YMD=`date -d yesterday +%Y%m%d`
file_path=/home/hive/gds/filewatch/hive/$YESTERDAY_YMD/c_qb_mobile_nginx

while [ ! -s $file_path ]
do
 /usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.8.38 -P3306 --default-character-set=utf8 -Ddc -e "select * from td_hive_report_task where TASK_DATE=$YESTERDAY_YMD and REPORT_NAME='qb_mobile_nginx_web_url_day' and flag=1" > $file_path

cat $file_path

sleep 300

done
                                                                           lxwl_assets_user.sh                                                                                 0000644 0000000 0000000 00000002006 12712341211 013506  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          mer_spu_baogou.sh                                                                                   0000644 0000000 0000000 00000002265 12705641364 013133  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
#推荐系统头宝购商品状态判断程序
TERDAY_TY=`date +"%Y-%m-%d"`
TERDAY=`date -d yesterday +"%Y%m%d"`
logpath=/home/hive/gds/logs/hive/${TERDAY}
  test ! -d $logpath && mkdir $logpath
echo "$logpath"

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/hive -e "insert overwrite table dm.mer_spu_baogou
select t.spu_id,spu_name,case when t1.spu_id is not null then 1 else 0 end is_baogou 
from (select * from base.mer_spu t where t.publish_status=1) t
left join
(select * from base.bc_product t1 where t1.end_time>='$TERDAY_TY') t1
on t.spu_id=t1.spu_id;" &>>$logpath/dm.mer_spu_baogou_$TERDAY.log

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username eadmin --password 'EWQTB512Oikf;' --table mer_spu_baogou --export-dir /user/hive/warehouse/dm.db/mer_spu_baogou --update-key "spu_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4 &>> $logpath/dm.mer_spu_baogou_$TERDAY.log

#CREATE TABLE IF NOT EXISTS dm.mer_spu_baogou(
#spu_id int,
#spu_name string,
#is_baogou int
#)
#ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001'
#STORED AS TEXTFILE;
                                                                                                                                                                                                                                                                                                                                           proc_light_user_action_stat_day.sh                                                                  0000644 0000000 0000000 00000020021 12677376147 016544  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

if [ ! -n "$1" ]; then  
  YESTERDAY=`date -d yesterday +%Y%m%d`
  YESTERDAY_YMD=`date -d yesterday +%Y-%m-%d`
  TODAY=`date +%Y-%m-%d`
  MONTH=`date -d yesterday +%Y%m`
else  
   YESTERDAY="$1"
   TODAY=`date -d "$1 +1 days" "+%Y-%m-%d"`
   YESTERDAY_YMD=`date -d "$1 0 days" "+%Y-%m-%d"`
   MONTH=`date -d "$1 0 days" "+%Y%m"`
fi

run(){
/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert overwrite dw.user_action_stat_day_info partition (dt='$YESTERDAY')
select base.id,base.username,flag from
base.hyip_user base inner join 
(
select distinct username,case when sign_from IN (2, 3) then 'qian_dao_app' when sign_from=1 then 'qian_dao_web' end flag from (
 SELECT username,cast(sign_from as int) sign_from FROM base.hyip_signrecord_temp t WHERE dt='$YESTERDAY'
   union all
 SELECT username,sign_from from base.sign_user_record where dt='$YESTERDAY')sign 
union all
select distinct username,'da_zhuan_pan_web' flag from base.t_roulette_record where dt='$MONTH' and create_time>='$YESTERDAY_YMD' and create_time<'$TODAY'
) t on base.username=t.username;"

/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert into dw.user_action_stat_day_info partition (dt='$YESTERDAY')
select base.id,base.username,flag from
base.hyip_user base inner join 
(
SELECT DISTINCT user_id,case when source = 1  then 'zuo_ren_wu_web' when source = 2 then 'zuo_ren_wu_app' end flag FROM base.hyip_user_task_do_log WHERE dt = '$YESTERDAY'
union all
 SELECT DISTINCT id user_id,'is_new_user' flag FROM base.hyip_user WHERE dt = '$YESTERDAY' 
union all
 SELECT DISTINCT cast(qb_account as int) user_id,'wei_shang_zhu_ce_web' flag FROM base.busi_merchant_cooperator WHERE in_time>='$YESTERDAY_YMD' and in_time<'$TODAY'
 union all  
 SELECT DISTINCT t2.hyip_user_id user_id,'huan_hong_bao_web' flag 
  FROM ( SELECT id,hyip_user_id FROM base.t_user  WHERE dt = '$YESTERDAY' ) t2, 
    ( SELECT user_id FROM base.t_buy_record WHERE  create_time >='$YESTERDAY_YMD' and create_time<'$TODAY' AND STATUS = 'FINISHED' ) t3 
  WHERE t2.id = t3.user_id 
 union all
 SELECT DISTINCT user_id,'wei_shang_buyer_app' flag FROM base.nbiz_shop_order_base WHERE pay_time>='$YESTERDAY_YMD' and pay_time<'$TODAY'
 union all
 SELECT DISTINCT shop_id user_id,'wei_shang_seller_app' flag FROM base.nbiz_shop_order_base WHERE pay_time>='$YESTERDAY_YMD' and pay_time<'$TODAY'
 union all
 select distinct user_id,'ling_ren_wu_web' from (
   SELECT user_id  FROM base.hyip_user_task WHERE start_time < '$TODAY' AND start_time>='$YESTERDAY_YMD' and margins>0
   union all
   select user_id  from base.task_user_activity where create_time < '$TODAY' AND create_time>='$YESTERDAY_YMD' and margins>0) task
 union all   
 select distinct user_id,'lei_pai_web' flag from 
   (select user_id from base.sign_auc_shared where create_time >='$YESTERDAY_YMD' and create_time<'$TODAY' and status=1
    union all
    select user_id from base.auc_user_luck where join_time>='$YESTERDAY_YMD' and join_time<'$TODAY' and status=1)lp  
 union all
 SELECT DISTINCT t2.hyip_user_id user_id,'qiang_hong_bao_web' flag 
  FROM ( SELECT hyip_user_id,id FROM base.t_user ) t2, 
  ( SELECT user_id FROM base.t_raffle_record WHERE dt = '$YESTERDAY' 
  union all
    select user_id from base.t_bid_record where bid_time>='$YESTERDAY_YMD' and bid_time<'$TODAY'
  ) t3 WHERE t2.id = t3.user_id  
  union all
 SELECT DISTINCT buyer_id,case when order_channel='wap' then 'bao_gou_app' else 'bao_gou_web' end as flag FROM base.bc_order 
     WHERE  create_time >='$YESTERDAY_YMD' and create_time<'$TODAY'
 union all 
 SELECT DISTINCT user_id, case when source = 1 then 'chong_zhi_web' when source =2 then 'chong_zhi_app' end flag FROM base.hyip_recharge WHERE create_time>='$YESTERDAY_YMD' and create_time<'$TODAY' AND type NOT IN (1000, 1004, 1005, 1006, 1007, 1008, 1019 ) AND recharge = 1   
 union all 
 SELECT DISTINCT user_id,case when type IN (58, 60) then 'ti_xian_web'  when type IN (59, 61) then 'ti_xian_app' end flag
  FROM ( SELECT user_id FROM base.hyip_transfer where create_time>='$YESTERDAY_YMD' and create_time<'$TODAY') t2, 
 ( SELECT  wallet_id,type FROM base.hyip_wallet_workflow WHERE dt = '$YESTERDAY' AND type IN (58, 60,59, 61) ) t3 WHERE t3.wallet_id = t2.user_id 
union all
select pay_user_id as user_id ,'fa_hong_bao_web' flag from base.fhb_detail_records where create_time>='$YESTERDAY_YMD' and create_time<'$TODAY' 
union all
select user_id,'you_piao_qian_dao' from base.tickets_sign_record where dt='$YESTERDAY'
  ) t on base.id=t.user_id;"

#lei_pai_winner_app(you_piao_qian_dao),bao_gou_guan_zhu_web(da_zhuan_pan_web),bao_gou_guan_zhu_app(fa_hong_bao_web)
/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/bin/impala-shell -q "insert overwrite table default.mysql_day_user_action partition(dt='$YESTERDAY')
select 
'$YESTERDAY_YMD',user_id,user_name,
cast(sum(case when flag='is_new_user' then 1 else 0 end) as int) as is_new_user, 
cast(sum(case when flag='chong_zhi_web' then 1 else 0 end) as int) as chong_zhi_web, 
cast(sum(case when flag='chong_zhi_app' then 1 else 0 end) as int) as chong_zhi_app,
cast(sum(case when flag='ti_xian_web' then 1 else 0 end) as int) as ti_xian_web,
cast(sum(case when flag='ti_xian_app' then 1 else 0 end) as int) as ti_xian_app,
cast(sum(case when flag='wei_shang_buyer_web' then 1 else 0 end) as int) as wei_shang_buyer_web, 
cast(sum(case when flag='wei_shang_buyer_app' then 1 else 0 end) as int) as wei_shang_buyer_app, 
cast(sum(case when flag='wei_shang_seller_web' then 1 else 0 end) as int) as wei_shang_seller_web,
cast(sum(case when flag='wei_shang_seller_app' then 1 else 0 end) as int) as wei_shang_seller_app,
cast(sum(case when flag='ling_ren_wu_web' then 1 else 0 end) as int) as ling_ren_wu_web,
cast(sum(case when flag='ling_ren_wu_app' then 1 else 0 end) as int) as ling_ren_wu_app, 
cast(sum(case when flag='qian_dao_web' then 1 else 0 end) as int) as qian_dao_web, 
cast(sum(case when flag='qian_dao_app' then 1 else 0 end) as int) as qian_dao_app,
cast(sum(case when flag='lei_pai_web' then 1 else 0 end) as int) as lei_pai_web,
cast(sum(case when flag='lei_pai_app' then 1 else 0 end) as int) as lei_pai_app,
0 as lei_pai_winner_web,
cast(sum(case when flag='you_piao_qian_dao' then 1 else 0 end) as int) as lei_pai_winner_app,
cast(sum(case when flag='qiang_hong_bao_web' then 1 else 0 end) as int) as qiang_hong_bao_web, 
0 as qiang_hong_bao_app,
cast(sum(case when flag='bao_gou_web' then 1 else 0 end) as int) as bao_gou_web, 
cast(sum(case when flag='bao_gou_app' then 1 else 0 end) as int) as bao_gou_app,
cast(sum(case when flag='zuo_ren_wu_web' then 1 else 0 end) as int) as zuo_ren_wu_web,
cast(sum(case when flag='zuo_ren_wu_app' then 1 else 0 end) as int) as zuo_ren_wu_app,0 as tui_jian_web,0 as tui_jian_app,
cast(sum(case when flag='wei_shang_zhu_ce_web' then 1 else 0 end) as int) as wei_shang_zhu_ce_web, 0 as wei_shang_zhu_ce_app, 
cast(sum(case when flag='huan_hong_bao_web' then 1 else 0 end) as int) as huan_hong_bao_web,
0 as huan_hong_bao_app,0 as fa_dong_tai_web,0 as fa_dong_tai_app,0 as ping_lun_web,0 as ping_lun_app,0 as jia_hao_you_web,0 as jia_hao_you_app,0 as qun_liao_web,0 as qun_liao_app,0 as is_tui_jian,0 as is_bei_tui_jian,
cast(sum(case when flag='da_zhuan_pan_web' then 1 else 0 end) as int) as bao_gou_guan_zhu_web,
cast(sum(case when flag='fa_hong_bao_web' then 1 else 0 end) as int) as bao_gou_guan_zhu_app
from dw.user_action_stat_day_info where dt='$YESTERDAY' group by user_id,user_name;"

if [ $? -eq 0 ] ; then
        echo "$YESTERDAY action daily stats ok "
        echo `date +'%Y-%m-%d %H:%M:%S'` >>/home/hive/gds/filewatch/hive/$YESTERDAY/proc_light_user_action_stat_day
else
        echo "$YESTERDAY_YMD action daily stats error"
        exit 1
fi

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.63:3306/dw --username eadmin --password 'EWQTB512Oikf;' --table light_user_action_stat_day   --export-dir /user/hive/warehouse/mysql_day_user_action/dt=$YESTERDAY --input-fields-terminated-by '\001' -m 12

}
run 1>>/home/hive/gds/logs/hive/$YESTERDAY/proc_light_user_action_stat_day_$YESTERDAY.log 2>&1


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               readme.txt                                                                                          0000644 0000000 0000000 00000000506 12620315002 011542  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   数据抽取脚本,在/home/hive/gds/bin下,需要切换到hive用户执行 
*_all为全量抽取脚本,参数：ip,端口,mysql库名,mysql表名
*_part为增量抽取脚本,参数: ip,端口,mysql库名,mysql表名,增量字段,日期(缺省为昨天)
#./soop_data_extract_full.sh 172.16.14.41 3306 qbaochou bc_shop_product
                                                                                                                                                                                          shop_spu_summary.sh                                                                                 0000644 0000000 0000000 00000001575 12710342642 013536  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

#商品综合信息，店铺综合排序--提供搜索使用
/home/hive/gds/bin/call_proc.sh proc_shop_spu_summary

/usr/bin/mysql -ueadmin -p'EWQTB512Oikf;' -h172.16.14.36 -P3306 --default-character-set=utf8 -Dmerchant_middle -e "truncate table merchant_middle.spu_summary;truncate table merchant_middle.shop_summary"

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username eadmin --password 'EWQTB512Oikf;' --table spu_summary --export-dir /user/hive/warehouse/dm.db/spu_summary --input-fields-terminated-by '\001' -m 10

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username eadmin --password 'EWQTB512Oikf;' --table shop_summary --export-dir /user/hive/warehouse/dm.db/shop_summary --input-fields-terminated-by '\001' -m 4

                                                                                                                                   sqoo_date_export_general.sh                                                                         0000744 0000000 0000000 00000001723 12633667717 015212  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
pd=hadoopadmin
pswd34='1243vczx;'
pswd38='asdWQ$3d^&*sdf#$#2eqs'
tablenm=light_user_general_stat_day
if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

ERRORLOG=/home/hive/gds/logs/sqoop/output/$YESTERDAY/$tablenm.log
if [ ! -d $ERRORLOG ] ; then
mkdir /home/hive/gds/logs/sqoop/output/$YESTERDAY/
fi
echo /home/hive/gds/logs/sqoop/output/$YESTERDAY/

filewatch_path=/home/hive/gds/filewatch/hive/$YESTERDAY
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table light_user_general_stat_day --export-dir /user/hive/warehouse/dw.db/light_user_general_stat_day_mysql_extend/dt=$YESTERDAY --input-fields-terminated-by '\t' -m 12  --null-string '\\N' --null-non-string '\\N' &>>$ERRORLOG
                                             sqoop_data_export_63.sh                                                                             0000744 0000000 0000000 00000004151 12637251521 014161  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##############################################################################################
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

                                                                                                                                                                                                                                                                                                                                                                                                                       sqoop_data_export_merge.sh                                                                          0000744 0000000 0000000 00000003774 12674447377 015063  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##############################################################################################
##@name sqoop_data_export_merge.sh
##@author yqf
##@function  导出hive数据插入更新至mysql
##@example ： sh sqoop_data_export_merge.sh  heavy_transfer_channel_stat_day dw heavy_transfer_channel_stat_day 20151102 user_id
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
  column=$5
else
  mysql_table_name=$1
  schema=$2
  hive_table_name=$3
  data_date=${yesterday}
  column=$4
fi

filewatch_path=/home/hive/gds/filewatch/sqoop/output/${data_date}
test ! -d ${filewatch_path} && mkdir ${filewatch_path}
logpath=/home/hive/gds/logs/sqoop/output/${data_date}
test ! -d ${logpath} && mkdir ${logpath}
logfile=${logpath}/${schema}.${hive_table_name}_${data_date}.log

username=eadmin
password=`EWQTB512Oikf;`

echo "---start sqoop export data ${schema}.${hive_table_name}_${data_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"

sqoop export --connect jdbc:mysql://172.16.14.63:3306/dw --username  ${username} --password ${password} --table ${mysql_table_name} --export-dir /user/hive/warehouse/${schema}.db/${hive_table_name}/dt=${data_date} --update-key "$column" --update-mode allowinsert --input-fields-terminated-by '\001' 

if [ $? -eq 0 ];then
  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"

  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${schema}.${hive_table_name}

else

  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  exit 1

fi
    sqoop_data_export.sh                                                                                0000744 0000000 0000000 00000004167 12623562122 013655  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##############################################################################################
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




username=hadoopadmin
password=asdWQ\$3d\^\&\*sdf\#\$\#2eqs


  


echo "---start sqoop export data ${schema}.${hive_table_name}_${data_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"

sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username  ${username} --password ${password} --table ${mysql_table_name} --export-dir /user/hive/warehouse/${schema}.db/${hive_table_name}/dt=${data_date} --input-fields-terminated-by '\001' &>> "$logfile"

if [ $? -eq 0 ];then
  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
   
  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${schema}.${hive_table_name}

else

  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  exit 1

fi

                                                                                                                                                                                                                                                                                                                                                                                                         sqoop_data_export_user_black.sh                                                                     0000644 0000000 0000000 00000003075 12643442617 016053  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
yesterday=`date -d yesterday +%Y%m%d`

hive -e "select ip,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_ip_blacklist ">/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt' INTO TABLE user_ip_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select presenter_id,username,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_presenter_blacklist">/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt' INTO TABLE user_presenter_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select stat_date,user_id,username,create_time,lock_reason_type,5 as status,operate_time from dw.user_login_blacklist_day where dt=$yesterday">/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt' INTO TABLE user_login_blacklist_day FIELDS TERMINATED BY '\t'"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                   sqoop_data_extract_all2.sh                                                                          0000755 0000000 0000000 00000001303 12616600124 014704  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh

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

                                                                                                                                                                                                                                                                                                                             sqoop_data_extract_all.sh                                                                           0000777 0000747 0000000 00000002152 12647376621 014643  0                                                                                                    ustar   hive                            root                                                                                                                                                                                                                   #!/bin/sh

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
                                                                                                                                                                                                                                                                                                                                                                                                                      sqoop_data_extract_ass_avg_sign_float.sh                                                            0000644 0000000 0000000 00000002142 12674200421 017701  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/bash
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

username=eadmin
password='EWQTB512Oikf;'
log_path=/home/hive/gds/logs/sqoop/output/$YESTERDAY
filewatch_path=/home/hive/gds/filewatch/sqoop/output/$YESTERDAY
if [ ! -d $log_path ] ; then
mkdir $log_path
fi
echo $log_path
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.38:3306/qbass --username eadmin --password 'EWQTB512Oikf;' --table ass_avg_sign_float --export-dir /user/hive/warehouse/dm.db/ass_avg_sign_float/dt=$YESTERDAY --update-key "user_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4 &>> $log_path/dm.ass_avg_sign_float.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/merchant_shop_grey_list
        echo "$YESTERDAY $table_name sqoop export  ok " >> $log_path/dm.ass_avg_sign_float.log
else
        echo "$YESTERDAY $table_name sqoop export  error" >> $log_path/dm.ass_avg_sign_float.log
exit 1
fi
                                                                                                                                                                                                                                                                                                                                                                                                                              sqoop_data_extract_busi_heavy_ptask_wage_info.sh                                                    0000644 0000000 0000000 00000001471 12641162464 021443  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
if [ -z $1 ]; then
  YESTERDAY_YMD=`date -d yesterday +%Y%m%d`
  TODAY=`date +%Y-%m-%d`
  BEFOR_YESTERDAY=`date -d -2days +%Y%m%d`
else
  YESTERDAY_YMD=$1
  TODAY=$2
  BEFOR_YESTERDAY=$3
fi

sqoop import --connect jdbc:mysql://172.16.14.44:3306/dw?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table busi_heavy_ptask_wage_info --fields-terminated-by '\001' --where "stat_date=$BEFOR_YESTERDAY" -m 1 --hive-drop-import-delims --hive-import --hive-table dm.busi_heavy_ptask_wage_info --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $BEFOR_YESTERDAY --null-string '\\N' --null-non-string '\\N' &>> /home/hive/gds/logs/sqoop/input/$BEFOR_YESTERDAY/busi_heavy_ptask_wage_info.log
                                                                                                                                                                                                       sqoop_data_extract_part.sh                                                                          0000777 0000747 0000000 00000002710 12627443653 015037  0                                                                                                    ustar   hive                            root                                                                                                                                                                                                                   #!/bin/sh

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
                                                        sqoop_data_extract_qw_cas_user.sh                                                                   0000744 0000000 0000000 00000001642 12627210200 016363  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

sqoop import --connect jdbc:mysql://172.16.10.174:3306/qianwang365?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table qw_cas_user --fields-terminated-by '\001' -m 4 --hive-import --columns "id,username,password,enabled,create_time,nick_name,ip_address,last_login_time,phone_city_id,phone_corp,mobile,email,third_platform_id,third_platform_name,trade_password,use_baoling,machine_code,dw_update_time" --hive-drop-import-delims --hive-table base.qw_cas_user --delete-target-dir --hive-overwrite --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/qw_cas_user.log

if [ $? -eq 0 ] ; then
 echo `date +'%Y-%m-%d %H:%M:%S'` >> /home/hive/gds/filewatch/sqoop/input/$YESTERDAY/qw_cas_user
else exit 1
fi
                                                                                              sqoop_data_extract_user_account_charge_detail.sh                                                    0000644 0000000 0000000 00000013363 12702666763 021426  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
TODAY=`date +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_00 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_01 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_02 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_03 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_04 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_05 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_06 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_07 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_08 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
sqoop import --connect jdbc:mysql://172.16.3.195:3306/hyip?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table user_account_charge_detail_new_09 --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.user_account_charge_detail_new --delete-target-dir --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/user_account_charge_detail_new.log
if [ $? -eq 0 ] ; then
 echo `date +'%Y-%m-%d %H:%M:%S'` >> /home/hive/gds/filewatch/sqoop/input/$YESTERDAY/user_account_charge_detail_new
else exit 1
fi
                                                                                                                                                                                                                                                                             sqoop_date_export_present_stat.sh                                                                   0000744 0000000 0000000 00000001671 12633503203 016445  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
pd=hadoopadmin
pswd34='1243vczx;'
pswd38='asdWQ$3d^&*sdf#$#2eqs'
tablenm=light_present_stat_day
if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

ERRORLOG=/home/hive/gds/logs/sqoop/output/$YESTERDAY/$tablenm.log
if [ ! -d $ERRORLOG ] ; then
mkdir /home/hive/gds/logs/sqoop/output/$YESTERDAY/
fi
echo /home/hive/gds/logs/sqoop/output/$YESTERDAY/

filewatch_path=/home/hive/gds/filewatch/hive/$YESTERDAY
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table light_present_stat_day --export-dir /user/hive/warehouse/dw.db/light_present_stat_day_crnt --update-key "register_date,presenter_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4
                                                                       sqoop_export_merchant_shop_grey_list.sh                                                             0000644 0000000 0000000 00000002176 12653023723 017656  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/bash
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

username=eadmin
password='EWQTB512Oikf;'
log_path=/home/hive/gds/logs/sqoop/output/$YESTERDAY
filewatch_path=/home/hive/gds/filewatch/sqoop/output/$YESTERDAY
if [ ! -d $log_path ] ; then
mkdir $log_path
fi
echo $log_path
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table merchant_shop_grey_list --export-dir /user/hive/warehouse/dw.db/merchant_shop_grey_list/dt=$YESTERDAY --update-key "shop_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 1 &>>dw.merchant_shop_grey_list.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/merchant_shop_grey_list
        echo "$YESTERDAY $table_name sqoop export  ok " >> $log_path/dw.merchant_shop_grey_list.log
else
        echo "$YESTERDAY $table_name sqoop export  error" >> $log_path/dw.merchant_shop_grey_list.log
exit 1
fi
                                                                                                                                                                                                                                                                                                                                                                                                  sqoop_export_mysql_shop_feature.sh                                                                  0000644 0000000 0000000 00000001501 12703640771 016647  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   
#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
username=dcadmin
YESTERDAY=`date -d yesterday +%Y%m%d`

ip=172.16.14.36
mysql_proc_name=proc_busi_shop_list
dw_name=merchant_middle
port=3306
data_date=$YESTERDAY

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username dcadmin --password sadas3432\$\#\%ret\@\!sd76 --table shop_feature --export-dir /user/hive/warehouse/dm.db/shop_feature/dt=$data_date --update-key "shop_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4

/usr/bin/mysql -u$username -psadas3432\$\#\%ret\@\!sd76 -h$ip -P$port --default-character-set=utf8 -D$dw_name -e "replace into merchant_middle.spu_shop select spu_id,user_id,user_name from merchant.mer_spu where publish_status =1 and audit_status in (2,4) ;"

                                                                                                                                                                                               sqoop_import_sdkserver_sdk_pay_trans.sh                                                             0000644 0000000 0000000 00000002406 12653021723 017657  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`
month=`date -d yesterday +%Y%m`

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

sqoop import --connect jdbc:mysql://172.16.3.93:3307/sdkserver?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table sdk_pay_trans_$month --fields-terminated-by '\001' -m 1 --hive-import  --hive-drop-import-delims --hive-table base.sdkserver_sdk_pay_trans --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $month --null-string '\\N' --null-non-string '\\N' &>> $log_path/sdkserver_sdk_pay_trans.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/sdkserver_sdk_pay_trans
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  ok " >> $log_path/sdkserver_sdk_pay_trans.log
else
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  error" >> $log_path/sdkserver_sdk_pay_trans.log
exit 1
fi
                                                                                                                                                                                                                                                          sqoop_import_sign_question_user_answer.sh                                                           0000644 0000000 0000000 00000001552 12702714656 020244  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
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
                                                                                                                                                      sqoop_import_t_roulette_record.sh                                                                   0000644 0000000 0000000 00000002340 12703450201 016440  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`
month=`date -d yesterday +%Y%m`

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

sqoop import --connect jdbc:mysql://172.16.3.94:3306/hongbao?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table t_roulette_record_$month --fields-terminated-by '\001' -m 10 --hive-import  --hive-drop-import-delims --hive-table base.t_roulette_record --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $month --null-string '\\N' --null-non-string '\\N' &>> $log_path/t_roulette_record.log

if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/t_roulette_record
        echo "$YESTERDAY t_roulette_record sqoop import  ok " >> $log_path/t_roulette_record.log
else
        echo "$YESTERDAY t_roulette_record sqoop import  error" >> $log_path/t_roulette_record.log
exit 1
fi

                                                                                                                                                                                                                                                                                                sqoop_import_t_task_record.sh                                                                       0000644 0000000 0000000 00000002447 12672170740 015563  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`
month=`date -d yesterday +%Y%m`
TODAY=`date +'%Y%m%d'`

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

sqoop import --connect jdbc:mysql://172.16.3.94:3306/hongbao?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table t_task_record_$month --fields-terminated-by '\001' --where "create_time>=$YESTERDAY and create_time<$TODAY" -m 4 --hive-import  --hive-drop-import-delims --hive-table base.t_task_record --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $YESTERDAY --null-string '\\N' --null-non-string '\\N' &>> $log_path/t_task_record.log


if [ $? -eq 0 ] ; then
        echo $CURRENT_DATE >>$filewatch_path/t_task_record
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  ok " >> $log_path/t_task_record.log
else
        echo "$YESTERDAY sdkserver_sdk_pay_trans sqoop import  error" >> $log_path/t_task_record.log
exit 1
fi
                                                                                                                                                                                                                         task_waiting.sh                                                                                     0000744 0000000 0000000 00000001271 12621041423 012571  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##################
##@name task_waiting.sh
##@author 01
##@function  等待抛出文件
##@example ： sh task_waiting.sh sqoop test
##################

#!/bin/bash

  if [ $# -eq 3 ];then
    filewatch_path=$1
    stat_date=$2
    task_name=$3
  elif [ $# -eq 2 ];then
    filewatch_path=$1
    stat_date=`date -d yesterday +%Y%m%d`
    task_name=$2
  fi

  if [ ${filewatch_path} = 'sqoop' ];then
   path=/home/hive/gds/filewatch/${filewatch_path}/input/${stat_date}
  else
   path=/home/hive/gds/filewatch/${filewatch_path}/${stat_date}
  fi

echo ${path}
##等待抛出文件

   while [ ! -f ${path}/${task_name} ]
     do
      echo "waiting file ${task_name}"

     sleep 5
    
    done


                                                                                                                                                                                                                                                                                                                                       test.gz                                                                                             0000644 0000000 0000000 00000670000 12647652145 011114  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   home/hive/gds/bin/bee_mistake.java                                                                  0000644 0000000 0000000 00000035623 12634216670 016117  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   // ORM class for table 'bee_mistake'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Wed Dec 16 16:15:52 CST 2015
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class bee_mistake extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private String sub_username;
  public String get_sub_username() {
    return sub_username;
  }
  public void set_sub_username(String sub_username) {
    this.sub_username = sub_username;
  }
  public bee_mistake with_sub_username(String sub_username) {
    this.sub_username = sub_username;
    return this;
  }
  private String bee_name;
  public String get_bee_name() {
    return bee_name;
  }
  public void set_bee_name(String bee_name) {
    this.bee_name = bee_name;
  }
  public bee_mistake with_bee_name(String bee_name) {
    this.bee_name = bee_name;
    return this;
  }
  private String user_name;
  public String get_user_name() {
    return user_name;
  }
  public void set_user_name(String user_name) {
    this.user_name = user_name;
  }
  public bee_mistake with_user_name(String user_name) {
    this.user_name = user_name;
    return this;
  }
  private String device_id;
  public String get_device_id() {
    return device_id;
  }
  public void set_device_id(String device_id) {
    this.device_id = device_id;
  }
  public bee_mistake with_device_id(String device_id) {
    this.device_id = device_id;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof bee_mistake)) {
      return false;
    }
    bee_mistake that = (bee_mistake) o;
    boolean equal = true;
    equal = equal && (this.sub_username == null ? that.sub_username == null : this.sub_username.equals(that.sub_username));
    equal = equal && (this.bee_name == null ? that.bee_name == null : this.bee_name.equals(that.bee_name));
    equal = equal && (this.user_name == null ? that.user_name == null : this.user_name.equals(that.user_name));
    equal = equal && (this.device_id == null ? that.device_id == null : this.device_id.equals(that.device_id));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof bee_mistake)) {
      return false;
    }
    bee_mistake that = (bee_mistake) o;
    boolean equal = true;
    equal = equal && (this.sub_username == null ? that.sub_username == null : this.sub_username.equals(that.sub_username));
    equal = equal && (this.bee_name == null ? that.bee_name == null : this.bee_name.equals(that.bee_name));
    equal = equal && (this.user_name == null ? that.user_name == null : this.user_name.equals(that.user_name));
    equal = equal && (this.device_id == null ? that.device_id == null : this.device_id.equals(that.device_id));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.sub_username = JdbcWritableBridge.readString(1, __dbResults);
    this.bee_name = JdbcWritableBridge.readString(2, __dbResults);
    this.user_name = JdbcWritableBridge.readString(3, __dbResults);
    this.device_id = JdbcWritableBridge.readString(4, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.sub_username = JdbcWritableBridge.readString(1, __dbResults);
    this.bee_name = JdbcWritableBridge.readString(2, __dbResults);
    this.user_name = JdbcWritableBridge.readString(3, __dbResults);
    this.device_id = JdbcWritableBridge.readString(4, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(sub_username, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(bee_name, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(user_name, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(device_id, 4 + __off, 12, __dbStmt);
    return 4;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(sub_username, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(bee_name, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(user_name, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(device_id, 4 + __off, 12, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.sub_username = null;
    } else {
    this.sub_username = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.bee_name = null;
    } else {
    this.bee_name = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.user_name = null;
    } else {
    this.user_name = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.device_id = null;
    } else {
    this.device_id = Text.readString(__dataIn);
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.sub_username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, sub_username);
    }
    if (null == this.bee_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, bee_name);
    }
    if (null == this.user_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, user_name);
    }
    if (null == this.device_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, device_id);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.sub_username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, sub_username);
    }
    if (null == this.bee_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, bee_name);
    }
    if (null == this.user_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, user_name);
    }
    if (null == this.device_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, device_id);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    __sb.append(FieldFormatter.escapeAndEnclose(sub_username==null?"null":sub_username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bee_name==null?"null":bee_name, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_name==null?"null":user_name, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(device_id==null?"null":device_id, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(sub_username==null?"null":sub_username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bee_name==null?"null":bee_name, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_name==null?"null":user_name, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(device_id==null?"null":device_id, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.sub_username = null; } else {
      this.sub_username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.bee_name = null; } else {
      this.bee_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.user_name = null; } else {
      this.user_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.device_id = null; } else {
      this.device_id = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.sub_username = null; } else {
      this.sub_username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.bee_name = null; } else {
      this.bee_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.user_name = null; } else {
      this.user_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.device_id = null; } else {
      this.device_id = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    bee_mistake o = (bee_mistake) super.clone();
    return o;
  }

  public void clone0(bee_mistake o) throws CloneNotSupportedException {
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("sub_username", this.sub_username);
    __sqoop$field_map.put("bee_name", this.bee_name);
    __sqoop$field_map.put("user_name", this.user_name);
    __sqoop$field_map.put("device_id", this.device_id);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("sub_username", this.sub_username);
    __sqoop$field_map.put("bee_name", this.bee_name);
    __sqoop$field_map.put("user_name", this.user_name);
    __sqoop$field_map.put("device_id", this.device_id);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("sub_username".equals(__fieldName)) {
      this.sub_username = (String) __fieldVal;
    }
    else    if ("bee_name".equals(__fieldName)) {
      this.bee_name = (String) __fieldVal;
    }
    else    if ("user_name".equals(__fieldName)) {
      this.user_name = (String) __fieldVal;
    }
    else    if ("device_id".equals(__fieldName)) {
      this.device_id = (String) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("sub_username".equals(__fieldName)) {
      this.sub_username = (String) __fieldVal;
      return true;
    }
    else    if ("bee_name".equals(__fieldName)) {
      this.bee_name = (String) __fieldVal;
      return true;
    }
    else    if ("user_name".equals(__fieldName)) {
      this.user_name = (String) __fieldVal;
      return true;
    }
    else    if ("device_id".equals(__fieldName)) {
      this.device_id = (String) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
                                                                                                             home/hive/gds/bin/bee_user_1216.java                                                                0000644 0000000 0000000 00000040261 12634205173 016077  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   // ORM class for table 'bee_user_1216'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Wed Dec 16 14:53:47 CST 2015
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class bee_user_1216 extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private String sub_username;
  public String get_sub_username() {
    return sub_username;
  }
  public void set_sub_username(String sub_username) {
    this.sub_username = sub_username;
  }
  public bee_user_1216 with_sub_username(String sub_username) {
    this.sub_username = sub_username;
    return this;
  }
  private String bee_name;
  public String get_bee_name() {
    return bee_name;
  }
  public void set_bee_name(String bee_name) {
    this.bee_name = bee_name;
  }
  public bee_user_1216 with_bee_name(String bee_name) {
    this.bee_name = bee_name;
    return this;
  }
  private String username;
  public String get_username() {
    return username;
  }
  public void set_username(String username) {
    this.username = username;
  }
  public bee_user_1216 with_username(String username) {
    this.username = username;
    return this;
  }
  private java.sql.Timestamp new_createtime;
  public java.sql.Timestamp get_new_createtime() {
    return new_createtime;
  }
  public void set_new_createtime(java.sql.Timestamp new_createtime) {
    this.new_createtime = new_createtime;
  }
  public bee_user_1216 with_new_createtime(java.sql.Timestamp new_createtime) {
    this.new_createtime = new_createtime;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof bee_user_1216)) {
      return false;
    }
    bee_user_1216 that = (bee_user_1216) o;
    boolean equal = true;
    equal = equal && (this.sub_username == null ? that.sub_username == null : this.sub_username.equals(that.sub_username));
    equal = equal && (this.bee_name == null ? that.bee_name == null : this.bee_name.equals(that.bee_name));
    equal = equal && (this.username == null ? that.username == null : this.username.equals(that.username));
    equal = equal && (this.new_createtime == null ? that.new_createtime == null : this.new_createtime.equals(that.new_createtime));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof bee_user_1216)) {
      return false;
    }
    bee_user_1216 that = (bee_user_1216) o;
    boolean equal = true;
    equal = equal && (this.sub_username == null ? that.sub_username == null : this.sub_username.equals(that.sub_username));
    equal = equal && (this.bee_name == null ? that.bee_name == null : this.bee_name.equals(that.bee_name));
    equal = equal && (this.username == null ? that.username == null : this.username.equals(that.username));
    equal = equal && (this.new_createtime == null ? that.new_createtime == null : this.new_createtime.equals(that.new_createtime));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.sub_username = JdbcWritableBridge.readString(1, __dbResults);
    this.bee_name = JdbcWritableBridge.readString(2, __dbResults);
    this.username = JdbcWritableBridge.readString(3, __dbResults);
    this.new_createtime = JdbcWritableBridge.readTimestamp(4, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.sub_username = JdbcWritableBridge.readString(1, __dbResults);
    this.bee_name = JdbcWritableBridge.readString(2, __dbResults);
    this.username = JdbcWritableBridge.readString(3, __dbResults);
    this.new_createtime = JdbcWritableBridge.readTimestamp(4, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(sub_username, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(bee_name, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(username, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeTimestamp(new_createtime, 4 + __off, 93, __dbStmt);
    return 4;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(sub_username, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(bee_name, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(username, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeTimestamp(new_createtime, 4 + __off, 93, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.sub_username = null;
    } else {
    this.sub_username = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.bee_name = null;
    } else {
    this.bee_name = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.username = null;
    } else {
    this.username = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.new_createtime = null;
    } else {
    this.new_createtime = new Timestamp(__dataIn.readLong());
    this.new_createtime.setNanos(__dataIn.readInt());
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.sub_username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, sub_username);
    }
    if (null == this.bee_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, bee_name);
    }
    if (null == this.username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, username);
    }
    if (null == this.new_createtime) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.new_createtime.getTime());
    __dataOut.writeInt(this.new_createtime.getNanos());
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.sub_username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, sub_username);
    }
    if (null == this.bee_name) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, bee_name);
    }
    if (null == this.username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, username);
    }
    if (null == this.new_createtime) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.new_createtime.getTime());
    __dataOut.writeInt(this.new_createtime.getNanos());
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(sub_username==null?"\\N":sub_username, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(bee_name==null?"\\N":bee_name, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(username==null?"\\N":username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(new_createtime==null?"\\N":"" + new_createtime, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(sub_username==null?"\\N":sub_username, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(bee_name==null?"\\N":bee_name, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(username==null?"\\N":username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(new_createtime==null?"\\N":"" + new_createtime, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.sub_username = null; } else {
      this.sub_username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.bee_name = null; } else {
      this.bee_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.username = null; } else {
      this.username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.new_createtime = null; } else {
      this.new_createtime = java.sql.Timestamp.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.sub_username = null; } else {
      this.sub_username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.bee_name = null; } else {
      this.bee_name = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.username = null; } else {
      this.username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.new_createtime = null; } else {
      this.new_createtime = java.sql.Timestamp.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    bee_user_1216 o = (bee_user_1216) super.clone();
    o.new_createtime = (o.new_createtime != null) ? (java.sql.Timestamp) o.new_createtime.clone() : null;
    return o;
  }

  public void clone0(bee_user_1216 o) throws CloneNotSupportedException {
    o.new_createtime = (o.new_createtime != null) ? (java.sql.Timestamp) o.new_createtime.clone() : null;
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("sub_username", this.sub_username);
    __sqoop$field_map.put("bee_name", this.bee_name);
    __sqoop$field_map.put("username", this.username);
    __sqoop$field_map.put("new_createtime", this.new_createtime);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("sub_username", this.sub_username);
    __sqoop$field_map.put("bee_name", this.bee_name);
    __sqoop$field_map.put("username", this.username);
    __sqoop$field_map.put("new_createtime", this.new_createtime);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("sub_username".equals(__fieldName)) {
      this.sub_username = (String) __fieldVal;
    }
    else    if ("bee_name".equals(__fieldName)) {
      this.bee_name = (String) __fieldVal;
    }
    else    if ("username".equals(__fieldName)) {
      this.username = (String) __fieldVal;
    }
    else    if ("new_createtime".equals(__fieldName)) {
      this.new_createtime = (java.sql.Timestamp) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("sub_username".equals(__fieldName)) {
      this.sub_username = (String) __fieldVal;
      return true;
    }
    else    if ("bee_name".equals(__fieldName)) {
      this.bee_name = (String) __fieldVal;
      return true;
    }
    else    if ("username".equals(__fieldName)) {
      this.username = (String) __fieldVal;
      return true;
    }
    else    if ("new_createtime".equals(__fieldName)) {
      this.new_createtime = (java.sql.Timestamp) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
                                                                                                                                                                                                                                                                                                                                               home/hive/gds/bin/busi_heavy_ptask_wage_info.java                                                   0000644 0000000 0000000 00000113414 12641166065 021220  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   // ORM class for table 'busi_heavy_ptask_wage_info'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Thu Dec 31 16:49:57 CST 2015
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class busi_heavy_ptask_wage_info extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private Integer presenter_id;
  public Integer get_presenter_id() {
    return presenter_id;
  }
  public void set_presenter_id(Integer presenter_id) {
    this.presenter_id = presenter_id;
  }
  public busi_heavy_ptask_wage_info with_presenter_id(Integer presenter_id) {
    this.presenter_id = presenter_id;
    return this;
  }
  private Integer user_id;
  public Integer get_user_id() {
    return user_id;
  }
  public void set_user_id(Integer user_id) {
    this.user_id = user_id;
  }
  public busi_heavy_ptask_wage_info with_user_id(Integer user_id) {
    this.user_id = user_id;
    return this;
  }
  private String username;
  public String get_username() {
    return username;
  }
  public void set_username(String username) {
    this.username = username;
  }
  public busi_heavy_ptask_wage_info with_username(String username) {
    this.username = username;
    return this;
  }
  private Integer score;
  public Integer get_score() {
    return score;
  }
  public void set_score(Integer score) {
    this.score = score;
  }
  public busi_heavy_ptask_wage_info with_score(Integer score) {
    this.score = score;
    return this;
  }
  private Long reward;
  public Long get_reward() {
    return reward;
  }
  public void set_reward(Long reward) {
    this.reward = reward;
  }
  public busi_heavy_ptask_wage_info with_reward(Long reward) {
    this.reward = reward;
    return this;
  }
  private Long bq_amount;
  public Long get_bq_amount() {
    return bq_amount;
  }
  public void set_bq_amount(Long bq_amount) {
    this.bq_amount = bq_amount;
  }
  public busi_heavy_ptask_wage_info with_bq_amount(Long bq_amount) {
    this.bq_amount = bq_amount;
    return this;
  }
  private Long qbb_amount;
  public Long get_qbb_amount() {
    return qbb_amount;
  }
  public void set_qbb_amount(Long qbb_amount) {
    this.qbb_amount = qbb_amount;
  }
  public busi_heavy_ptask_wage_info with_qbb_amount(Long qbb_amount) {
    this.qbb_amount = qbb_amount;
    return this;
  }
  private java.math.BigDecimal bq_rate;
  public java.math.BigDecimal get_bq_rate() {
    return bq_rate;
  }
  public void set_bq_rate(java.math.BigDecimal bq_rate) {
    this.bq_rate = bq_rate;
  }
  public busi_heavy_ptask_wage_info with_bq_rate(java.math.BigDecimal bq_rate) {
    this.bq_rate = bq_rate;
    return this;
  }
  private java.math.BigDecimal qbb_rate;
  public java.math.BigDecimal get_qbb_rate() {
    return qbb_rate;
  }
  public void set_qbb_rate(java.math.BigDecimal qbb_rate) {
    this.qbb_rate = qbb_rate;
  }
  public busi_heavy_ptask_wage_info with_qbb_rate(java.math.BigDecimal qbb_rate) {
    this.qbb_rate = qbb_rate;
    return this;
  }
  private Long p_bq_amount;
  public Long get_p_bq_amount() {
    return p_bq_amount;
  }
  public void set_p_bq_amount(Long p_bq_amount) {
    this.p_bq_amount = p_bq_amount;
  }
  public busi_heavy_ptask_wage_info with_p_bq_amount(Long p_bq_amount) {
    this.p_bq_amount = p_bq_amount;
    return this;
  }
  private Long p_qbb_amount;
  public Long get_p_qbb_amount() {
    return p_qbb_amount;
  }
  public void set_p_qbb_amount(Long p_qbb_amount) {
    this.p_qbb_amount = p_qbb_amount;
  }
  public busi_heavy_ptask_wage_info with_p_qbb_amount(Long p_qbb_amount) {
    this.p_qbb_amount = p_qbb_amount;
    return this;
  }
  private java.sql.Date stat_date;
  public java.sql.Date get_stat_date() {
    return stat_date;
  }
  public void set_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
  }
  public busi_heavy_ptask_wage_info with_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
    return this;
  }
  private String type;
  public String get_type() {
    return type;
  }
  public void set_type(String type) {
    this.type = type;
  }
  public busi_heavy_ptask_wage_info with_type(String type) {
    this.type = type;
    return this;
  }
  private Long user_task_id;
  public Long get_user_task_id() {
    return user_task_id;
  }
  public void set_user_task_id(Long user_task_id) {
    this.user_task_id = user_task_id;
  }
  public busi_heavy_ptask_wage_info with_user_task_id(Long user_task_id) {
    this.user_task_id = user_task_id;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof busi_heavy_ptask_wage_info)) {
      return false;
    }
    busi_heavy_ptask_wage_info that = (busi_heavy_ptask_wage_info) o;
    boolean equal = true;
    equal = equal && (this.presenter_id == null ? that.presenter_id == null : this.presenter_id.equals(that.presenter_id));
    equal = equal && (this.user_id == null ? that.user_id == null : this.user_id.equals(that.user_id));
    equal = equal && (this.username == null ? that.username == null : this.username.equals(that.username));
    equal = equal && (this.score == null ? that.score == null : this.score.equals(that.score));
    equal = equal && (this.reward == null ? that.reward == null : this.reward.equals(that.reward));
    equal = equal && (this.bq_amount == null ? that.bq_amount == null : this.bq_amount.equals(that.bq_amount));
    equal = equal && (this.qbb_amount == null ? that.qbb_amount == null : this.qbb_amount.equals(that.qbb_amount));
    equal = equal && (this.bq_rate == null ? that.bq_rate == null : this.bq_rate.equals(that.bq_rate));
    equal = equal && (this.qbb_rate == null ? that.qbb_rate == null : this.qbb_rate.equals(that.qbb_rate));
    equal = equal && (this.p_bq_amount == null ? that.p_bq_amount == null : this.p_bq_amount.equals(that.p_bq_amount));
    equal = equal && (this.p_qbb_amount == null ? that.p_qbb_amount == null : this.p_qbb_amount.equals(that.p_qbb_amount));
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.type == null ? that.type == null : this.type.equals(that.type));
    equal = equal && (this.user_task_id == null ? that.user_task_id == null : this.user_task_id.equals(that.user_task_id));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof busi_heavy_ptask_wage_info)) {
      return false;
    }
    busi_heavy_ptask_wage_info that = (busi_heavy_ptask_wage_info) o;
    boolean equal = true;
    equal = equal && (this.presenter_id == null ? that.presenter_id == null : this.presenter_id.equals(that.presenter_id));
    equal = equal && (this.user_id == null ? that.user_id == null : this.user_id.equals(that.user_id));
    equal = equal && (this.username == null ? that.username == null : this.username.equals(that.username));
    equal = equal && (this.score == null ? that.score == null : this.score.equals(that.score));
    equal = equal && (this.reward == null ? that.reward == null : this.reward.equals(that.reward));
    equal = equal && (this.bq_amount == null ? that.bq_amount == null : this.bq_amount.equals(that.bq_amount));
    equal = equal && (this.qbb_amount == null ? that.qbb_amount == null : this.qbb_amount.equals(that.qbb_amount));
    equal = equal && (this.bq_rate == null ? that.bq_rate == null : this.bq_rate.equals(that.bq_rate));
    equal = equal && (this.qbb_rate == null ? that.qbb_rate == null : this.qbb_rate.equals(that.qbb_rate));
    equal = equal && (this.p_bq_amount == null ? that.p_bq_amount == null : this.p_bq_amount.equals(that.p_bq_amount));
    equal = equal && (this.p_qbb_amount == null ? that.p_qbb_amount == null : this.p_qbb_amount.equals(that.p_qbb_amount));
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.type == null ? that.type == null : this.type.equals(that.type));
    equal = equal && (this.user_task_id == null ? that.user_task_id == null : this.user_task_id.equals(that.user_task_id));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.presenter_id = JdbcWritableBridge.readInteger(1, __dbResults);
    this.user_id = JdbcWritableBridge.readInteger(2, __dbResults);
    this.username = JdbcWritableBridge.readString(3, __dbResults);
    this.score = JdbcWritableBridge.readInteger(4, __dbResults);
    this.reward = JdbcWritableBridge.readLong(5, __dbResults);
    this.bq_amount = JdbcWritableBridge.readLong(6, __dbResults);
    this.qbb_amount = JdbcWritableBridge.readLong(7, __dbResults);
    this.bq_rate = JdbcWritableBridge.readBigDecimal(8, __dbResults);
    this.qbb_rate = JdbcWritableBridge.readBigDecimal(9, __dbResults);
    this.p_bq_amount = JdbcWritableBridge.readLong(10, __dbResults);
    this.p_qbb_amount = JdbcWritableBridge.readLong(11, __dbResults);
    this.stat_date = JdbcWritableBridge.readDate(12, __dbResults);
    this.type = JdbcWritableBridge.readString(13, __dbResults);
    this.user_task_id = JdbcWritableBridge.readLong(14, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.presenter_id = JdbcWritableBridge.readInteger(1, __dbResults);
    this.user_id = JdbcWritableBridge.readInteger(2, __dbResults);
    this.username = JdbcWritableBridge.readString(3, __dbResults);
    this.score = JdbcWritableBridge.readInteger(4, __dbResults);
    this.reward = JdbcWritableBridge.readLong(5, __dbResults);
    this.bq_amount = JdbcWritableBridge.readLong(6, __dbResults);
    this.qbb_amount = JdbcWritableBridge.readLong(7, __dbResults);
    this.bq_rate = JdbcWritableBridge.readBigDecimal(8, __dbResults);
    this.qbb_rate = JdbcWritableBridge.readBigDecimal(9, __dbResults);
    this.p_bq_amount = JdbcWritableBridge.readLong(10, __dbResults);
    this.p_qbb_amount = JdbcWritableBridge.readLong(11, __dbResults);
    this.stat_date = JdbcWritableBridge.readDate(12, __dbResults);
    this.type = JdbcWritableBridge.readString(13, __dbResults);
    this.user_task_id = JdbcWritableBridge.readLong(14, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeInteger(presenter_id, 1 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(user_id, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeString(username, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeInteger(score, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(reward, 5 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(bq_amount, 6 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(qbb_amount, 7 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(bq_rate, 8 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(qbb_rate, 9 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeLong(p_bq_amount, 10 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(p_qbb_amount, 11 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeDate(stat_date, 12 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeString(type, 13 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeLong(user_task_id, 14 + __off, -5, __dbStmt);
    return 14;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeInteger(presenter_id, 1 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(user_id, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeString(username, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeInteger(score, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(reward, 5 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(bq_amount, 6 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(qbb_amount, 7 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(bq_rate, 8 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(qbb_rate, 9 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeLong(p_bq_amount, 10 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeLong(p_qbb_amount, 11 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeDate(stat_date, 12 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeString(type, 13 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeLong(user_task_id, 14 + __off, -5, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.presenter_id = null;
    } else {
    this.presenter_id = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.user_id = null;
    } else {
    this.user_id = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.username = null;
    } else {
    this.username = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.score = null;
    } else {
    this.score = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.reward = null;
    } else {
    this.reward = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.bq_amount = null;
    } else {
    this.bq_amount = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.qbb_amount = null;
    } else {
    this.qbb_amount = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.bq_rate = null;
    } else {
    this.bq_rate = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.qbb_rate = null;
    } else {
    this.qbb_rate = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.p_bq_amount = null;
    } else {
    this.p_bq_amount = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.p_qbb_amount = null;
    } else {
    this.p_qbb_amount = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.stat_date = null;
    } else {
    this.stat_date = new Date(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.type = null;
    } else {
    this.type = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.user_task_id = null;
    } else {
    this.user_task_id = Long.valueOf(__dataIn.readLong());
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.presenter_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.presenter_id);
    }
    if (null == this.user_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.user_id);
    }
    if (null == this.username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, username);
    }
    if (null == this.score) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.score);
    }
    if (null == this.reward) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.reward);
    }
    if (null == this.bq_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.bq_amount);
    }
    if (null == this.qbb_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.qbb_amount);
    }
    if (null == this.bq_rate) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.bq_rate, __dataOut);
    }
    if (null == this.qbb_rate) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.qbb_rate, __dataOut);
    }
    if (null == this.p_bq_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.p_bq_amount);
    }
    if (null == this.p_qbb_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.p_qbb_amount);
    }
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.type) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, type);
    }
    if (null == this.user_task_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.user_task_id);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.presenter_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.presenter_id);
    }
    if (null == this.user_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.user_id);
    }
    if (null == this.username) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, username);
    }
    if (null == this.score) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.score);
    }
    if (null == this.reward) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.reward);
    }
    if (null == this.bq_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.bq_amount);
    }
    if (null == this.qbb_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.qbb_amount);
    }
    if (null == this.bq_rate) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.bq_rate, __dataOut);
    }
    if (null == this.qbb_rate) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.qbb_rate, __dataOut);
    }
    if (null == this.p_bq_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.p_bq_amount);
    }
    if (null == this.p_qbb_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.p_qbb_amount);
    }
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.type) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, type);
    }
    if (null == this.user_task_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.user_task_id);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    __sb.append(FieldFormatter.escapeAndEnclose(presenter_id==null?"\\N":"" + presenter_id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_id==null?"\\N":"" + user_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(username==null?"\\N":username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(score==null?"\\N":"" + score, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(reward==null?"\\N":"" + reward, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bq_amount==null?"\\N":"" + bq_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(qbb_amount==null?"\\N":"" + qbb_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bq_rate==null?"\\N":bq_rate.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(qbb_rate==null?"\\N":qbb_rate.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(p_bq_amount==null?"\\N":"" + p_bq_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(p_qbb_amount==null?"\\N":"" + p_qbb_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"\\N":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(type==null?"\\N":type, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_task_id==null?"\\N":"" + user_task_id, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(presenter_id==null?"\\N":"" + presenter_id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_id==null?"\\N":"" + user_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(username==null?"\\N":username, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(score==null?"\\N":"" + score, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(reward==null?"\\N":"" + reward, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bq_amount==null?"\\N":"" + bq_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(qbb_amount==null?"\\N":"" + qbb_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(bq_rate==null?"\\N":bq_rate.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(qbb_rate==null?"\\N":qbb_rate.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(p_bq_amount==null?"\\N":"" + p_bq_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(p_qbb_amount==null?"\\N":"" + p_qbb_amount, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"\\N":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(type==null?"\\N":type, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_task_id==null?"\\N":"" + user_task_id, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.presenter_id = null; } else {
      this.presenter_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_id = null; } else {
      this.user_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.username = null; } else {
      this.username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.score = null; } else {
      this.score = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.reward = null; } else {
      this.reward = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.bq_amount = null; } else {
      this.bq_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.qbb_amount = null; } else {
      this.qbb_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.bq_rate = null; } else {
      this.bq_rate = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.qbb_rate = null; } else {
      this.qbb_rate = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.p_bq_amount = null; } else {
      this.p_bq_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.p_qbb_amount = null; } else {
      this.p_qbb_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.type = null; } else {
      this.type = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_task_id = null; } else {
      this.user_task_id = Long.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.presenter_id = null; } else {
      this.presenter_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_id = null; } else {
      this.user_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.username = null; } else {
      this.username = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.score = null; } else {
      this.score = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.reward = null; } else {
      this.reward = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.bq_amount = null; } else {
      this.bq_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.qbb_amount = null; } else {
      this.qbb_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.bq_rate = null; } else {
      this.bq_rate = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.qbb_rate = null; } else {
      this.qbb_rate = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.p_bq_amount = null; } else {
      this.p_bq_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.p_qbb_amount = null; } else {
      this.p_qbb_amount = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.type = null; } else {
      this.type = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_task_id = null; } else {
      this.user_task_id = Long.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    busi_heavy_ptask_wage_info o = (busi_heavy_ptask_wage_info) super.clone();
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
    return o;
  }

  public void clone0(busi_heavy_ptask_wage_info o) throws CloneNotSupportedException {
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("presenter_id", this.presenter_id);
    __sqoop$field_map.put("user_id", this.user_id);
    __sqoop$field_map.put("username", this.username);
    __sqoop$field_map.put("score", this.score);
    __sqoop$field_map.put("reward", this.reward);
    __sqoop$field_map.put("bq_amount", this.bq_amount);
    __sqoop$field_map.put("qbb_amount", this.qbb_amount);
    __sqoop$field_map.put("bq_rate", this.bq_rate);
    __sqoop$field_map.put("qbb_rate", this.qbb_rate);
    __sqoop$field_map.put("p_bq_amount", this.p_bq_amount);
    __sqoop$field_map.put("p_qbb_amount", this.p_qbb_amount);
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("type", this.type);
    __sqoop$field_map.put("user_task_id", this.user_task_id);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("presenter_id", this.presenter_id);
    __sqoop$field_map.put("user_id", this.user_id);
    __sqoop$field_map.put("username", this.username);
    __sqoop$field_map.put("score", this.score);
    __sqoop$field_map.put("reward", this.reward);
    __sqoop$field_map.put("bq_amount", this.bq_amount);
    __sqoop$field_map.put("qbb_amount", this.qbb_amount);
    __sqoop$field_map.put("bq_rate", this.bq_rate);
    __sqoop$field_map.put("qbb_rate", this.qbb_rate);
    __sqoop$field_map.put("p_bq_amount", this.p_bq_amount);
    __sqoop$field_map.put("p_qbb_amount", this.p_qbb_amount);
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("type", this.type);
    __sqoop$field_map.put("user_task_id", this.user_task_id);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("presenter_id".equals(__fieldName)) {
      this.presenter_id = (Integer) __fieldVal;
    }
    else    if ("user_id".equals(__fieldName)) {
      this.user_id = (Integer) __fieldVal;
    }
    else    if ("username".equals(__fieldName)) {
      this.username = (String) __fieldVal;
    }
    else    if ("score".equals(__fieldName)) {
      this.score = (Integer) __fieldVal;
    }
    else    if ("reward".equals(__fieldName)) {
      this.reward = (Long) __fieldVal;
    }
    else    if ("bq_amount".equals(__fieldName)) {
      this.bq_amount = (Long) __fieldVal;
    }
    else    if ("qbb_amount".equals(__fieldName)) {
      this.qbb_amount = (Long) __fieldVal;
    }
    else    if ("bq_rate".equals(__fieldName)) {
      this.bq_rate = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("qbb_rate".equals(__fieldName)) {
      this.qbb_rate = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("p_bq_amount".equals(__fieldName)) {
      this.p_bq_amount = (Long) __fieldVal;
    }
    else    if ("p_qbb_amount".equals(__fieldName)) {
      this.p_qbb_amount = (Long) __fieldVal;
    }
    else    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
    }
    else    if ("type".equals(__fieldName)) {
      this.type = (String) __fieldVal;
    }
    else    if ("user_task_id".equals(__fieldName)) {
      this.user_task_id = (Long) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("presenter_id".equals(__fieldName)) {
      this.presenter_id = (Integer) __fieldVal;
      return true;
    }
    else    if ("user_id".equals(__fieldName)) {
      this.user_id = (Integer) __fieldVal;
      return true;
    }
    else    if ("username".equals(__fieldName)) {
      this.username = (String) __fieldVal;
      return true;
    }
    else    if ("score".equals(__fieldName)) {
      this.score = (Integer) __fieldVal;
      return true;
    }
    else    if ("reward".equals(__fieldName)) {
      this.reward = (Long) __fieldVal;
      return true;
    }
    else    if ("bq_amount".equals(__fieldName)) {
      this.bq_amount = (Long) __fieldVal;
      return true;
    }
    else    if ("qbb_amount".equals(__fieldName)) {
      this.qbb_amount = (Long) __fieldVal;
      return true;
    }
    else    if ("bq_rate".equals(__fieldName)) {
      this.bq_rate = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("qbb_rate".equals(__fieldName)) {
      this.qbb_rate = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("p_bq_amount".equals(__fieldName)) {
      this.p_bq_amount = (Long) __fieldVal;
      return true;
    }
    else    if ("p_qbb_amount".equals(__fieldName)) {
      this.p_qbb_amount = (Long) __fieldVal;
      return true;
    }
    else    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
      return true;
    }
    else    if ("type".equals(__fieldName)) {
      this.type = (String) __fieldVal;
      return true;
    }
    else    if ("user_task_id".equals(__fieldName)) {
      this.user_task_id = (Long) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
                                                                                                                                                                                                                                                    home/hive/gds/bin/call_mysql_proc.sh                                                                0000644 0000000 0000000 00000001631 12642474131 016510  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   me call_mysql_proc.sh                                                            
##@author yqf                                                                   
##@function  call proc for mysql                                                      
##@example ： sh call_mysql_proc.sh  172.16.8.38 3306 dw proc_team_merchant_assess_stat_day (20160103)
############################################################################################
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
username=dcadmin
password=`sadas3432$#%ret@!sd76`
YESTERDAY=`date -d yesterday +%Y%m%d`

if [ $# -eq 5 ];then
  ip=$1
  mysql_proc_name=$2
  dw_name=$3
  port=$4
  data_date=$5
 else
  ip=$1
  mysql_proc_name=$2
  dw_name=$3
  port=$4
  data_date=$YESTERDAY

/usr/bin/mysql -u$username -p$password -h$ip -P$port --default-character-set=utf8 -D$dw_name -e "call $mysql_proc_name($data_date)"
                                                                                                       home/hive/gds/bin/call_proc.sh                                                                      0000744 0000000 0000000 00000003224 12625304714 015264  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##################################################################################
##@name call_proc.sh                                                            ##
##@author 01                                                                    ##
##@function  调度hive脚本                                                       ##
##@example ： sh call_proc.sh.sh  20151102 proc_heavy_transfer_channel_stat_day ##
##################################################################################




#!/bin/bash
  if [ $# -eq 2 ]; then  
    stat_date="$1"  
    sqlfile="$2"
  elif  [ $# -eq 1 ]; then  
    stat_date=`date -d yesterday +%Y%m%d`
    sqlfile="$1"
  else
    echo "wrong arg[] number"
    exit 1
  fi 

  logpath=/home/hive/gds/logs/hive/${stat_date}
  test ! -d $logpath && mkdir $logpath
    
  logfile="${logpath}/${sqlfile}_${stat_date}.log"
  hqlpath="/home/hive/gds/hql/"
  filewatch_path="/home/hive/gds/filewatch/hive"
  echo "${filewatch_path/stat_date}"
  if [ ! -d ${filewatch_path}/${stat_date} ];then 
    mkdir ${filewatch_path}/${stat_date}
  fi

  
  echo "---start running procedure ${sqlfile} ${stat_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  
  hive -hivevar data_date=${stat_date}  -f ${hqlpath}${sqlfile}.sql &>> "$logfile"
  
  if [ $? -eq 0 ];then
  
    echo "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
     
    echo  "---calling procedure complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${stat_date}/${sqlfile}


  else
  
    echo "---calling procedure error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
    exit 1
  
  fi 



                                                                                                                                                                                                                                                                                                                                                                            home/hive/gds/bin/call_proc_team_merchant_assess_stat_day.sh                                        0000744 0000000 0000000 00000001000 12645120360 023405  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.14.63 -P3306 --default-character-set=utf8 -Ddw -e "call proc_team_merchant_assess_stat_day($YESTERDAY)"

/usr/bin/mysql -udcadmin -p'sadas3432$#%ret@!sd76' -h172.16.8.38 -P3306 --default-character-set=utf8 -Ddw -e "call proc_team_merchant_assess_stat_day($YESTERDAY)"
home/hive/gds/bin/light_user_general_stat_day.java                                                  0000644 0000000 0000000 00000137472 12633667722 021415  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   // ORM class for table 'light_user_general_stat_day'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Tue Dec 15 09:41:38 CST 2015
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class light_user_general_stat_day extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private java.sql.Date stat_date;
  public java.sql.Date get_stat_date() {
    return stat_date;
  }
  public void set_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
  }
  public light_user_general_stat_day with_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
    return this;
  }
  private Integer user_id;
  public Integer get_user_id() {
    return user_id;
  }
  public void set_user_id(Integer user_id) {
    this.user_id = user_id;
  }
  public light_user_general_stat_day with_user_id(Integer user_id) {
    this.user_id = user_id;
    return this;
  }
  private Integer web_login_count;
  public Integer get_web_login_count() {
    return web_login_count;
  }
  public void set_web_login_count(Integer web_login_count) {
    this.web_login_count = web_login_count;
  }
  public light_user_general_stat_day with_web_login_count(Integer web_login_count) {
    this.web_login_count = web_login_count;
    return this;
  }
  private Integer client_login_count;
  public Integer get_client_login_count() {
    return client_login_count;
  }
  public void set_client_login_count(Integer client_login_count) {
    this.client_login_count = client_login_count;
  }
  public light_user_general_stat_day with_client_login_count(Integer client_login_count) {
    this.client_login_count = client_login_count;
    return this;
  }
  private Long total_assets;
  public Long get_total_assets() {
    return total_assets;
  }
  public void set_total_assets(Long total_assets) {
    this.total_assets = total_assets;
  }
  public light_user_general_stat_day with_total_assets(Long total_assets) {
    this.total_assets = total_assets;
    return this;
  }
  private Integer sign_count;
  public Integer get_sign_count() {
    return sign_count;
  }
  public void set_sign_count(Integer sign_count) {
    this.sign_count = sign_count;
  }
  public light_user_general_stat_day with_sign_count(Integer sign_count) {
    this.sign_count = sign_count;
    return this;
  }
  private Integer sign_reward;
  public Integer get_sign_reward() {
    return sign_reward;
  }
  public void set_sign_reward(Integer sign_reward) {
    this.sign_reward = sign_reward;
  }
  public light_user_general_stat_day with_sign_reward(Integer sign_reward) {
    this.sign_reward = sign_reward;
    return this;
  }
  private Integer get_task_count;
  public Integer get_get_task_count() {
    return get_task_count;
  }
  public void set_get_task_count(Integer get_task_count) {
    this.get_task_count = get_task_count;
  }
  public light_user_general_stat_day with_get_task_count(Integer get_task_count) {
    this.get_task_count = get_task_count;
    return this;
  }
  private Integer do_task_count;
  public Integer get_do_task_count() {
    return do_task_count;
  }
  public void set_do_task_count(Integer do_task_count) {
    this.do_task_count = do_task_count;
  }
  public light_user_general_stat_day with_do_task_count(Integer do_task_count) {
    this.do_task_count = do_task_count;
    return this;
  }
  private Long total_margins;
  public Long get_total_margins() {
    return total_margins;
  }
  public void set_total_margins(Long total_margins) {
    this.total_margins = total_margins;
  }
  public light_user_general_stat_day with_total_margins(Long total_margins) {
    this.total_margins = total_margins;
    return this;
  }
  private Integer recharge_count;
  public Integer get_recharge_count() {
    return recharge_count;
  }
  public void set_recharge_count(Integer recharge_count) {
    this.recharge_count = recharge_count;
  }
  public light_user_general_stat_day with_recharge_count(Integer recharge_count) {
    this.recharge_count = recharge_count;
    return this;
  }
  private java.math.BigDecimal recharge_amount;
  public java.math.BigDecimal get_recharge_amount() {
    return recharge_amount;
  }
  public void set_recharge_amount(java.math.BigDecimal recharge_amount) {
    this.recharge_amount = recharge_amount;
  }
  public light_user_general_stat_day with_recharge_amount(java.math.BigDecimal recharge_amount) {
    this.recharge_amount = recharge_amount;
    return this;
  }
  private Integer transfer_count;
  public Integer get_transfer_count() {
    return transfer_count;
  }
  public void set_transfer_count(Integer transfer_count) {
    this.transfer_count = transfer_count;
  }
  public light_user_general_stat_day with_transfer_count(Integer transfer_count) {
    this.transfer_count = transfer_count;
    return this;
  }
  private java.math.BigDecimal transfer_amount;
  public java.math.BigDecimal get_transfer_amount() {
    return transfer_amount;
  }
  public void set_transfer_amount(java.math.BigDecimal transfer_amount) {
    this.transfer_amount = transfer_amount;
  }
  public light_user_general_stat_day with_transfer_amount(java.math.BigDecimal transfer_amount) {
    this.transfer_amount = transfer_amount;
    return this;
  }
  private Integer refund_count;
  public Integer get_refund_count() {
    return refund_count;
  }
  public void set_refund_count(Integer refund_count) {
    this.refund_count = refund_count;
  }
  public light_user_general_stat_day with_refund_count(Integer refund_count) {
    this.refund_count = refund_count;
    return this;
  }
  private java.math.BigDecimal refund_amount;
  public java.math.BigDecimal get_refund_amount() {
    return refund_amount;
  }
  public void set_refund_amount(java.math.BigDecimal refund_amount) {
    this.refund_amount = refund_amount;
  }
  public light_user_general_stat_day with_refund_amount(java.math.BigDecimal refund_amount) {
    this.refund_amount = refund_amount;
    return this;
  }
  private Integer baoquan_amount;
  public Integer get_baoquan_amount() {
    return baoquan_amount;
  }
  public void set_baoquan_amount(Integer baoquan_amount) {
    this.baoquan_amount = baoquan_amount;
  }
  public light_user_general_stat_day with_baoquan_amount(Integer baoquan_amount) {
    this.baoquan_amount = baoquan_amount;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof light_user_general_stat_day)) {
      return false;
    }
    light_user_general_stat_day that = (light_user_general_stat_day) o;
    boolean equal = true;
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.user_id == null ? that.user_id == null : this.user_id.equals(that.user_id));
    equal = equal && (this.web_login_count == null ? that.web_login_count == null : this.web_login_count.equals(that.web_login_count));
    equal = equal && (this.client_login_count == null ? that.client_login_count == null : this.client_login_count.equals(that.client_login_count));
    equal = equal && (this.total_assets == null ? that.total_assets == null : this.total_assets.equals(that.total_assets));
    equal = equal && (this.sign_count == null ? that.sign_count == null : this.sign_count.equals(that.sign_count));
    equal = equal && (this.sign_reward == null ? that.sign_reward == null : this.sign_reward.equals(that.sign_reward));
    equal = equal && (this.get_task_count == null ? that.get_task_count == null : this.get_task_count.equals(that.get_task_count));
    equal = equal && (this.do_task_count == null ? that.do_task_count == null : this.do_task_count.equals(that.do_task_count));
    equal = equal && (this.total_margins == null ? that.total_margins == null : this.total_margins.equals(that.total_margins));
    equal = equal && (this.recharge_count == null ? that.recharge_count == null : this.recharge_count.equals(that.recharge_count));
    equal = equal && (this.recharge_amount == null ? that.recharge_amount == null : this.recharge_amount.equals(that.recharge_amount));
    equal = equal && (this.transfer_count == null ? that.transfer_count == null : this.transfer_count.equals(that.transfer_count));
    equal = equal && (this.transfer_amount == null ? that.transfer_amount == null : this.transfer_amount.equals(that.transfer_amount));
    equal = equal && (this.refund_count == null ? that.refund_count == null : this.refund_count.equals(that.refund_count));
    equal = equal && (this.refund_amount == null ? that.refund_amount == null : this.refund_amount.equals(that.refund_amount));
    equal = equal && (this.baoquan_amount == null ? that.baoquan_amount == null : this.baoquan_amount.equals(that.baoquan_amount));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof light_user_general_stat_day)) {
      return false;
    }
    light_user_general_stat_day that = (light_user_general_stat_day) o;
    boolean equal = true;
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.user_id == null ? that.user_id == null : this.user_id.equals(that.user_id));
    equal = equal && (this.web_login_count == null ? that.web_login_count == null : this.web_login_count.equals(that.web_login_count));
    equal = equal && (this.client_login_count == null ? that.client_login_count == null : this.client_login_count.equals(that.client_login_count));
    equal = equal && (this.total_assets == null ? that.total_assets == null : this.total_assets.equals(that.total_assets));
    equal = equal && (this.sign_count == null ? that.sign_count == null : this.sign_count.equals(that.sign_count));
    equal = equal && (this.sign_reward == null ? that.sign_reward == null : this.sign_reward.equals(that.sign_reward));
    equal = equal && (this.get_task_count == null ? that.get_task_count == null : this.get_task_count.equals(that.get_task_count));
    equal = equal && (this.do_task_count == null ? that.do_task_count == null : this.do_task_count.equals(that.do_task_count));
    equal = equal && (this.total_margins == null ? that.total_margins == null : this.total_margins.equals(that.total_margins));
    equal = equal && (this.recharge_count == null ? that.recharge_count == null : this.recharge_count.equals(that.recharge_count));
    equal = equal && (this.recharge_amount == null ? that.recharge_amount == null : this.recharge_amount.equals(that.recharge_amount));
    equal = equal && (this.transfer_count == null ? that.transfer_count == null : this.transfer_count.equals(that.transfer_count));
    equal = equal && (this.transfer_amount == null ? that.transfer_amount == null : this.transfer_amount.equals(that.transfer_amount));
    equal = equal && (this.refund_count == null ? that.refund_count == null : this.refund_count.equals(that.refund_count));
    equal = equal && (this.refund_amount == null ? that.refund_amount == null : this.refund_amount.equals(that.refund_amount));
    equal = equal && (this.baoquan_amount == null ? that.baoquan_amount == null : this.baoquan_amount.equals(that.baoquan_amount));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.stat_date = JdbcWritableBridge.readDate(1, __dbResults);
    this.user_id = JdbcWritableBridge.readInteger(2, __dbResults);
    this.web_login_count = JdbcWritableBridge.readInteger(3, __dbResults);
    this.client_login_count = JdbcWritableBridge.readInteger(4, __dbResults);
    this.total_assets = JdbcWritableBridge.readLong(5, __dbResults);
    this.sign_count = JdbcWritableBridge.readInteger(6, __dbResults);
    this.sign_reward = JdbcWritableBridge.readInteger(7, __dbResults);
    this.get_task_count = JdbcWritableBridge.readInteger(8, __dbResults);
    this.do_task_count = JdbcWritableBridge.readInteger(9, __dbResults);
    this.total_margins = JdbcWritableBridge.readLong(10, __dbResults);
    this.recharge_count = JdbcWritableBridge.readInteger(11, __dbResults);
    this.recharge_amount = JdbcWritableBridge.readBigDecimal(12, __dbResults);
    this.transfer_count = JdbcWritableBridge.readInteger(13, __dbResults);
    this.transfer_amount = JdbcWritableBridge.readBigDecimal(14, __dbResults);
    this.refund_count = JdbcWritableBridge.readInteger(15, __dbResults);
    this.refund_amount = JdbcWritableBridge.readBigDecimal(16, __dbResults);
    this.baoquan_amount = JdbcWritableBridge.readInteger(17, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.stat_date = JdbcWritableBridge.readDate(1, __dbResults);
    this.user_id = JdbcWritableBridge.readInteger(2, __dbResults);
    this.web_login_count = JdbcWritableBridge.readInteger(3, __dbResults);
    this.client_login_count = JdbcWritableBridge.readInteger(4, __dbResults);
    this.total_assets = JdbcWritableBridge.readLong(5, __dbResults);
    this.sign_count = JdbcWritableBridge.readInteger(6, __dbResults);
    this.sign_reward = JdbcWritableBridge.readInteger(7, __dbResults);
    this.get_task_count = JdbcWritableBridge.readInteger(8, __dbResults);
    this.do_task_count = JdbcWritableBridge.readInteger(9, __dbResults);
    this.total_margins = JdbcWritableBridge.readLong(10, __dbResults);
    this.recharge_count = JdbcWritableBridge.readInteger(11, __dbResults);
    this.recharge_amount = JdbcWritableBridge.readBigDecimal(12, __dbResults);
    this.transfer_count = JdbcWritableBridge.readInteger(13, __dbResults);
    this.transfer_amount = JdbcWritableBridge.readBigDecimal(14, __dbResults);
    this.refund_count = JdbcWritableBridge.readInteger(15, __dbResults);
    this.refund_amount = JdbcWritableBridge.readBigDecimal(16, __dbResults);
    this.baoquan_amount = JdbcWritableBridge.readInteger(17, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(stat_date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(user_id, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(web_login_count, 3 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(client_login_count, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(total_assets, 5 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeInteger(sign_count, 6 + __off, -6, __dbStmt);
    JdbcWritableBridge.writeInteger(sign_reward, 7 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(get_task_count, 8 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(do_task_count, 9 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(total_margins, 10 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeInteger(recharge_count, 11 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(recharge_amount, 12 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(transfer_count, 13 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(transfer_amount, 14 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(refund_count, 15 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(refund_amount, 16 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(baoquan_amount, 17 + __off, 4, __dbStmt);
    return 17;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(stat_date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(user_id, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(web_login_count, 3 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(client_login_count, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(total_assets, 5 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeInteger(sign_count, 6 + __off, -6, __dbStmt);
    JdbcWritableBridge.writeInteger(sign_reward, 7 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(get_task_count, 8 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(do_task_count, 9 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeLong(total_margins, 10 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeInteger(recharge_count, 11 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(recharge_amount, 12 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(transfer_count, 13 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(transfer_amount, 14 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(refund_count, 15 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(refund_amount, 16 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(baoquan_amount, 17 + __off, 4, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.stat_date = null;
    } else {
    this.stat_date = new Date(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.user_id = null;
    } else {
    this.user_id = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.web_login_count = null;
    } else {
    this.web_login_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.client_login_count = null;
    } else {
    this.client_login_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.total_assets = null;
    } else {
    this.total_assets = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.sign_count = null;
    } else {
    this.sign_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.sign_reward = null;
    } else {
    this.sign_reward = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.get_task_count = null;
    } else {
    this.get_task_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.do_task_count = null;
    } else {
    this.do_task_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.total_margins = null;
    } else {
    this.total_margins = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.recharge_count = null;
    } else {
    this.recharge_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.recharge_amount = null;
    } else {
    this.recharge_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.transfer_count = null;
    } else {
    this.transfer_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.transfer_amount = null;
    } else {
    this.transfer_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.refund_count = null;
    } else {
    this.refund_count = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.refund_amount = null;
    } else {
    this.refund_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.baoquan_amount = null;
    } else {
    this.baoquan_amount = Integer.valueOf(__dataIn.readInt());
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.user_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.user_id);
    }
    if (null == this.web_login_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.web_login_count);
    }
    if (null == this.client_login_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.client_login_count);
    }
    if (null == this.total_assets) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.total_assets);
    }
    if (null == this.sign_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sign_count);
    }
    if (null == this.sign_reward) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sign_reward);
    }
    if (null == this.get_task_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.get_task_count);
    }
    if (null == this.do_task_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.do_task_count);
    }
    if (null == this.total_margins) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.total_margins);
    }
    if (null == this.recharge_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.recharge_count);
    }
    if (null == this.recharge_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.recharge_amount, __dataOut);
    }
    if (null == this.transfer_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.transfer_count);
    }
    if (null == this.transfer_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.transfer_amount, __dataOut);
    }
    if (null == this.refund_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.refund_count);
    }
    if (null == this.refund_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.refund_amount, __dataOut);
    }
    if (null == this.baoquan_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.baoquan_amount);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.user_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.user_id);
    }
    if (null == this.web_login_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.web_login_count);
    }
    if (null == this.client_login_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.client_login_count);
    }
    if (null == this.total_assets) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.total_assets);
    }
    if (null == this.sign_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sign_count);
    }
    if (null == this.sign_reward) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sign_reward);
    }
    if (null == this.get_task_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.get_task_count);
    }
    if (null == this.do_task_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.do_task_count);
    }
    if (null == this.total_margins) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.total_margins);
    }
    if (null == this.recharge_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.recharge_count);
    }
    if (null == this.recharge_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.recharge_amount, __dataOut);
    }
    if (null == this.transfer_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.transfer_count);
    }
    if (null == this.transfer_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.transfer_amount, __dataOut);
    }
    if (null == this.refund_count) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.refund_count);
    }
    if (null == this.refund_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.refund_amount, __dataOut);
    }
    if (null == this.baoquan_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.baoquan_amount);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"\\N":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_id==null?"\\N":"" + user_id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(web_login_count==null?"\\N":"" + web_login_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(client_login_count==null?"\\N":"" + client_login_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(total_assets==null?"\\N":"" + total_assets, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sign_count==null?"\\N":"" + sign_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sign_reward==null?"\\N":"" + sign_reward, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(get_task_count==null?"\\N":"" + get_task_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(do_task_count==null?"\\N":"" + do_task_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(total_margins==null?"\\N":"" + total_margins, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(recharge_count==null?"\\N":"" + recharge_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(recharge_amount==null?"\\N":recharge_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(transfer_count==null?"\\N":"" + transfer_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(transfer_amount==null?"\\N":transfer_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(refund_count==null?"\\N":"" + refund_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(refund_amount==null?"\\N":refund_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(baoquan_amount==null?"\\N":"" + baoquan_amount, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"\\N":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(user_id==null?"\\N":"" + user_id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(web_login_count==null?"\\N":"" + web_login_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(client_login_count==null?"\\N":"" + client_login_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(total_assets==null?"\\N":"" + total_assets, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sign_count==null?"\\N":"" + sign_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sign_reward==null?"\\N":"" + sign_reward, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(get_task_count==null?"\\N":"" + get_task_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(do_task_count==null?"\\N":"" + do_task_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(total_margins==null?"\\N":"" + total_margins, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(recharge_count==null?"\\N":"" + recharge_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(recharge_amount==null?"\\N":recharge_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(transfer_count==null?"\\N":"" + transfer_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(transfer_amount==null?"\\N":transfer_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(refund_count==null?"\\N":"" + refund_count, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(refund_amount==null?"\\N":refund_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(baoquan_amount==null?"\\N":"" + baoquan_amount, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 9, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_id = null; } else {
      this.user_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.web_login_count = null; } else {
      this.web_login_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.client_login_count = null; } else {
      this.client_login_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.total_assets = null; } else {
      this.total_assets = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sign_count = null; } else {
      this.sign_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sign_reward = null; } else {
      this.sign_reward = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.get_task_count = null; } else {
      this.get_task_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.do_task_count = null; } else {
      this.do_task_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.total_margins = null; } else {
      this.total_margins = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.recharge_count = null; } else {
      this.recharge_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.recharge_amount = null; } else {
      this.recharge_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.transfer_count = null; } else {
      this.transfer_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.transfer_amount = null; } else {
      this.transfer_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.refund_count = null; } else {
      this.refund_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.refund_amount = null; } else {
      this.refund_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.baoquan_amount = null; } else {
      this.baoquan_amount = Integer.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.user_id = null; } else {
      this.user_id = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.web_login_count = null; } else {
      this.web_login_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.client_login_count = null; } else {
      this.client_login_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.total_assets = null; } else {
      this.total_assets = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sign_count = null; } else {
      this.sign_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sign_reward = null; } else {
      this.sign_reward = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.get_task_count = null; } else {
      this.get_task_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.do_task_count = null; } else {
      this.do_task_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.total_margins = null; } else {
      this.total_margins = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.recharge_count = null; } else {
      this.recharge_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.recharge_amount = null; } else {
      this.recharge_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.transfer_count = null; } else {
      this.transfer_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.transfer_amount = null; } else {
      this.transfer_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.refund_count = null; } else {
      this.refund_count = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.refund_amount = null; } else {
      this.refund_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.baoquan_amount = null; } else {
      this.baoquan_amount = Integer.valueOf(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    light_user_general_stat_day o = (light_user_general_stat_day) super.clone();
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
    return o;
  }

  public void clone0(light_user_general_stat_day o) throws CloneNotSupportedException {
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("user_id", this.user_id);
    __sqoop$field_map.put("web_login_count", this.web_login_count);
    __sqoop$field_map.put("client_login_count", this.client_login_count);
    __sqoop$field_map.put("total_assets", this.total_assets);
    __sqoop$field_map.put("sign_count", this.sign_count);
    __sqoop$field_map.put("sign_reward", this.sign_reward);
    __sqoop$field_map.put("get_task_count", this.get_task_count);
    __sqoop$field_map.put("do_task_count", this.do_task_count);
    __sqoop$field_map.put("total_margins", this.total_margins);
    __sqoop$field_map.put("recharge_count", this.recharge_count);
    __sqoop$field_map.put("recharge_amount", this.recharge_amount);
    __sqoop$field_map.put("transfer_count", this.transfer_count);
    __sqoop$field_map.put("transfer_amount", this.transfer_amount);
    __sqoop$field_map.put("refund_count", this.refund_count);
    __sqoop$field_map.put("refund_amount", this.refund_amount);
    __sqoop$field_map.put("baoquan_amount", this.baoquan_amount);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("user_id", this.user_id);
    __sqoop$field_map.put("web_login_count", this.web_login_count);
    __sqoop$field_map.put("client_login_count", this.client_login_count);
    __sqoop$field_map.put("total_assets", this.total_assets);
    __sqoop$field_map.put("sign_count", this.sign_count);
    __sqoop$field_map.put("sign_reward", this.sign_reward);
    __sqoop$field_map.put("get_task_count", this.get_task_count);
    __sqoop$field_map.put("do_task_count", this.do_task_count);
    __sqoop$field_map.put("total_margins", this.total_margins);
    __sqoop$field_map.put("recharge_count", this.recharge_count);
    __sqoop$field_map.put("recharge_amount", this.recharge_amount);
    __sqoop$field_map.put("transfer_count", this.transfer_count);
    __sqoop$field_map.put("transfer_amount", this.transfer_amount);
    __sqoop$field_map.put("refund_count", this.refund_count);
    __sqoop$field_map.put("refund_amount", this.refund_amount);
    __sqoop$field_map.put("baoquan_amount", this.baoquan_amount);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
    }
    else    if ("user_id".equals(__fieldName)) {
      this.user_id = (Integer) __fieldVal;
    }
    else    if ("web_login_count".equals(__fieldName)) {
      this.web_login_count = (Integer) __fieldVal;
    }
    else    if ("client_login_count".equals(__fieldName)) {
      this.client_login_count = (Integer) __fieldVal;
    }
    else    if ("total_assets".equals(__fieldName)) {
      this.total_assets = (Long) __fieldVal;
    }
    else    if ("sign_count".equals(__fieldName)) {
      this.sign_count = (Integer) __fieldVal;
    }
    else    if ("sign_reward".equals(__fieldName)) {
      this.sign_reward = (Integer) __fieldVal;
    }
    else    if ("get_task_count".equals(__fieldName)) {
      this.get_task_count = (Integer) __fieldVal;
    }
    else    if ("do_task_count".equals(__fieldName)) {
      this.do_task_count = (Integer) __fieldVal;
    }
    else    if ("total_margins".equals(__fieldName)) {
      this.total_margins = (Long) __fieldVal;
    }
    else    if ("recharge_count".equals(__fieldName)) {
      this.recharge_count = (Integer) __fieldVal;
    }
    else    if ("recharge_amount".equals(__fieldName)) {
      this.recharge_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("transfer_count".equals(__fieldName)) {
      this.transfer_count = (Integer) __fieldVal;
    }
    else    if ("transfer_amount".equals(__fieldName)) {
      this.transfer_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("refund_count".equals(__fieldName)) {
      this.refund_count = (Integer) __fieldVal;
    }
    else    if ("refund_amount".equals(__fieldName)) {
      this.refund_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("baoquan_amount".equals(__fieldName)) {
      this.baoquan_amount = (Integer) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
      return true;
    }
    else    if ("user_id".equals(__fieldName)) {
      this.user_id = (Integer) __fieldVal;
      return true;
    }
    else    if ("web_login_count".equals(__fieldName)) {
      this.web_login_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("client_login_count".equals(__fieldName)) {
      this.client_login_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("total_assets".equals(__fieldName)) {
      this.total_assets = (Long) __fieldVal;
      return true;
    }
    else    if ("sign_count".equals(__fieldName)) {
      this.sign_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("sign_reward".equals(__fieldName)) {
      this.sign_reward = (Integer) __fieldVal;
      return true;
    }
    else    if ("get_task_count".equals(__fieldName)) {
      this.get_task_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("do_task_count".equals(__fieldName)) {
      this.do_task_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("total_margins".equals(__fieldName)) {
      this.total_margins = (Long) __fieldVal;
      return true;
    }
    else    if ("recharge_count".equals(__fieldName)) {
      this.recharge_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("recharge_amount".equals(__fieldName)) {
      this.recharge_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("transfer_count".equals(__fieldName)) {
      this.transfer_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("transfer_amount".equals(__fieldName)) {
      this.transfer_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("refund_count".equals(__fieldName)) {
      this.refund_count = (Integer) __fieldVal;
      return true;
    }
    else    if ("refund_amount".equals(__fieldName)) {
      this.refund_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("baoquan_amount".equals(__fieldName)) {
      this.baoquan_amount = (Integer) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
                                                                                                                                                                                                      home/hive/gds/bin/readme.txt                                                                        0000644 0000000 0000000 00000000506 12620315002 014752  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   数据抽取脚本,在/home/hive/gds/bin下,需要切换到hive用户执行 
*_all为全量抽取脚本,参数：ip,端口,mysql库名,mysql表名
*_part为增量抽取脚本,参数: ip,端口,mysql库名,mysql表名,增量字段,日期(缺省为昨天)
#./soop_data_extract_full.sh 172.16.14.41 3306 qbaochou bc_shop_product
                                                                                                                                                                                          home/hive/gds/bin/sqoo_date_export_general.sh                                                       0000744 0000000 0000000 00000001723 12633667717 020422  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
pd=hadoopadmin
pswd34='1243vczx;'
pswd38='asdWQ$3d^&*sdf#$#2eqs'
tablenm=light_user_general_stat_day
if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

ERRORLOG=/home/hive/gds/logs/sqoop/output/$YESTERDAY/$tablenm.log
if [ ! -d $ERRORLOG ] ; then
mkdir /home/hive/gds/logs/sqoop/output/$YESTERDAY/
fi
echo /home/hive/gds/logs/sqoop/output/$YESTERDAY/

filewatch_path=/home/hive/gds/filewatch/hive/$YESTERDAY
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table light_user_general_stat_day --export-dir /user/hive/warehouse/dw.db/light_user_general_stat_day_mysql_extend/dt=$YESTERDAY --input-fields-terminated-by '\t' -m 12  --null-string '\\N' --null-non-string '\\N' &>>$ERRORLOG
                                             home/hive/gds/bin/sqoop_data_export_63.sh                                                           0000744 0000000 0000000 00000004151 12637251521 017371  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##############################################################################################
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

                                                                                                                                                                                                                                                                                                                                                                                                                       home/hive/gds/bin/sqoop_data_export_merge.sh                                                        0000644 0000000 0000000 00000001054 12636133060 020232  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111
1111

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    home/hive/gds/bin/sqoop_data_export.sh                                                              0000744 0000000 0000000 00000004167 12623562122 017065  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##############################################################################################
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




username=hadoopadmin
password=asdWQ\$3d\^\&\*sdf\#\$\#2eqs


  


echo "---start sqoop export data ${schema}.${hive_table_name}_${data_date} at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"

sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username  ${username} --password ${password} --table ${mysql_table_name} --export-dir /user/hive/warehouse/${schema}.db/${hive_table_name}/dt=${data_date} --input-fields-terminated-by '\001' &>> "$logfile"

if [ $? -eq 0 ];then
  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
   
  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} complete at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> ${filewatch_path}/${schema}.${hive_table_name}

else

  echo "---sqoop export data ${schema}.${hive_table_name}_${data_date} error at $(date +%Y"."%m"."%d" "%H":"%M":"%S)---" >> "$logfile"
  exit 1

fi

                                                                                                                                                                                                                                                                                                                                                                                                         home/hive/gds/bin/sqoop_data_export_user_black.sh                                                   0000644 0000000 0000000 00000003075 12643442617 021263  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
yesterday=`date -d yesterday +%Y%m%d`

hive -e "select ip,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_ip_blacklist ">/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_ip_blacklist.txt' INTO TABLE user_ip_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select presenter_id,username,lock_reason_type,null as unlock_reason_type,status,operate_time from dw.user_presenter_blacklist">/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_presenter_blacklist.txt' INTO TABLE user_presenter_blacklist FIELDS TERMINATED BY '\t'"

hive -e "select stat_date,user_id,username,create_time,lock_reason_type,5 as status,operate_time from dw.user_login_blacklist_day where dt=$yesterday">/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt

/usr/bin/mysql -udcadmin2 -p'ojewqt*^)%321lfsEGA' -h172.16.14.65 -P3306 --default-character-set=utf8 -Dfroze -e "LOAD DATA LOCAL INFILE '/home/hive/gds/aihui/offline_blacklist_calculation/user_login_blacklist_day.txt' INTO TABLE user_login_blacklist_day FIELDS TERMINATED BY '\t'"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                   home/hive/gds/bin/sqoop_data_extract_all2.sh                                                        0000755 0000000 0000000 00000001303 12616600124 020114  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh

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

                                                                                                                                                                                                                                                                                                                             home/hive/gds/bin/sqoop_data_extract_all.sh                                                         0000777 0000747 0000000 00000002152 12647376621 020053  0                                                                                                    ustar   hive                            root                                                                                                                                                                                                                   #!/bin/sh

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
                                                                                                                                                                                                                                                                                                                                                                                                                      home/hive/gds/bin/sqoop_data_extract_busi_heavy_ptask_wage_info.sh                                  0000644 0000000 0000000 00000001471 12641162464 024653  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
if [ -z $1 ]; then
  YESTERDAY_YMD=`date -d yesterday +%Y%m%d`
  TODAY=`date +%Y-%m-%d`
  BEFOR_YESTERDAY=`date -d -2days +%Y%m%d`
else
  YESTERDAY_YMD=$1
  TODAY=$2
  BEFOR_YESTERDAY=$3
fi

sqoop import --connect jdbc:mysql://172.16.14.44:3306/dw?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table busi_heavy_ptask_wage_info --fields-terminated-by '\001' --where "stat_date=$BEFOR_YESTERDAY" -m 1 --hive-drop-import-delims --hive-import --hive-table dm.busi_heavy_ptask_wage_info --delete-target-dir --hive-overwrite --hive-partition-key dt --hive-partition-value $BEFOR_YESTERDAY --null-string '\\N' --null-non-string '\\N' &>> /home/hive/gds/logs/sqoop/input/$BEFOR_YESTERDAY/busi_heavy_ptask_wage_info.log
                                                                                                                                                                                                       home/hive/gds/bin/sqoop_data_extract_part.sh                                                        0000777 0000747 0000000 00000002710 12627443653 020247  0                                                                                                    ustar   hive                            root                                                                                                                                                                                                                   #!/bin/sh

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
                                                        home/hive/gds/bin/sqoop_data_extract_qw_cas_user.sh                                                 0000744 0000000 0000000 00000001642 12627210200 021573  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
YESTERDAY=`date -d yesterday +%Y%m%d`
CURRENT_DATE=`date +'%Y-%m-%d %H:%M:%S'`

sqoop import --connect jdbc:mysql://172.16.10.174:3306/qianwang365?tinyInt1isBit=false --username eadmin --password 'EWQTB512Oikf;' --table qw_cas_user --fields-terminated-by '\001' -m 4 --hive-import --columns "id,username,password,enabled,create_time,nick_name,ip_address,last_login_time,phone_city_id,phone_corp,mobile,email,third_platform_id,third_platform_name,trade_password,use_baoling,machine_code,dw_update_time" --hive-drop-import-delims --hive-table base.qw_cas_user --delete-target-dir --hive-overwrite --null-string '\\N' --null-non-string '\\N' &>>/home/hive/gds/logs/sqoop/input/$YESTERDAY/qw_cas_user.log

if [ $? -eq 0 ] ; then
 echo `date +'%Y-%m-%d %H:%M:%S'` >> /home/hive/gds/filewatch/sqoop/input/$YESTERDAY/qw_cas_user
else exit 1
fi
                                                                                              home/hive/gds/bin/sqoop_date_export_present_stat.sh                                                 0000744 0000000 0000000 00000001671 12633503203 021655  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'
pd=hadoopadmin
pswd34='1243vczx;'
pswd38='asdWQ$3d^&*sdf#$#2eqs'
tablenm=light_present_stat_day
if [ ! -n "$1" ]; then
  YESTERDAY=`date -d yesterday +%Y%m%d`
else
   YESTERDAY="$1"
fi

ERRORLOG=/home/hive/gds/logs/sqoop/output/$YESTERDAY/$tablenm.log
if [ ! -d $ERRORLOG ] ; then
mkdir /home/hive/gds/logs/sqoop/output/$YESTERDAY/
fi
echo /home/hive/gds/logs/sqoop/output/$YESTERDAY/

filewatch_path=/home/hive/gds/filewatch/hive/$YESTERDAY
if [ ! -d $filewatch_path ] ; then
mkdir $filewatch_path
fi
echo $filewatch_path

/usr/bin/sqoop export --connect jdbc:mysql://172.16.8.38:3306/dw --username hadoopadmin --password asdWQ\$3d\^\&\*sdf\#\$\#2eqs --table light_present_stat_day --export-dir /user/hive/warehouse/dw.db/light_present_stat_day_crnt --update-key "register_date,presenter_id" --update-mode allowinsert --input-fields-terminated-by '\001' -m 4
                                                                       home/hive/gds/bin/task_waiting.sh                                                                   0000744 0000000 0000000 00000001271 12621041423 016001  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   ##################
##@name task_waiting.sh
##@author 01
##@function  等待抛出文件
##@example ： sh task_waiting.sh sqoop test
##################

#!/bin/bash

  if [ $# -eq 3 ];then
    filewatch_path=$1
    stat_date=$2
    task_name=$3
  elif [ $# -eq 2 ];then
    filewatch_path=$1
    stat_date=`date -d yesterday +%Y%m%d`
    task_name=$2
  fi

  if [ ${filewatch_path} = 'sqoop' ];then
   path=/home/hive/gds/filewatch/${filewatch_path}/input/${stat_date}
  else
   path=/home/hive/gds/filewatch/${filewatch_path}/${stat_date}
  fi

echo ${path}
##等待抛出文件

   while [ ! -f ${path}/${task_name} ]
     do
      echo "waiting file ${task_name}"

     sleep 5
    
    done


                                                                                                                                                                                                                                                                                                                                       home/hive/gds/bin/team_merchant_assess_stat_day.java                                                0000644 0000000 0000000 00000177677 12636360216 021745  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   // ORM class for table 'team_merchant_assess_stat_day'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Wed Dec 23 07:45:18 CST 2015
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class team_merchant_assess_stat_day extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private java.sql.Date stat_date;
  public java.sql.Date get_stat_date() {
    return stat_date;
  }
  public void set_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
  }
  public team_merchant_assess_stat_day with_stat_date(java.sql.Date stat_date) {
    this.stat_date = stat_date;
    return this;
  }
  private Integer deal_num;
  public Integer get_deal_num() {
    return deal_num;
  }
  public void set_deal_num(Integer deal_num) {
    this.deal_num = deal_num;
  }
  public team_merchant_assess_stat_day with_deal_num(Integer deal_num) {
    this.deal_num = deal_num;
    return this;
  }
  private java.math.BigDecimal deal_amount;
  public java.math.BigDecimal get_deal_amount() {
    return deal_amount;
  }
  public void set_deal_amount(java.math.BigDecimal deal_amount) {
    this.deal_amount = deal_amount;
  }
  public team_merchant_assess_stat_day with_deal_amount(java.math.BigDecimal deal_amount) {
    this.deal_amount = deal_amount;
    return this;
  }
  private Integer deal_seller_num;
  public Integer get_deal_seller_num() {
    return deal_seller_num;
  }
  public void set_deal_seller_num(Integer deal_seller_num) {
    this.deal_seller_num = deal_seller_num;
  }
  public team_merchant_assess_stat_day with_deal_seller_num(Integer deal_seller_num) {
    this.deal_seller_num = deal_seller_num;
    return this;
  }
  private Integer jingxuan_deal_num;
  public Integer get_jingxuan_deal_num() {
    return jingxuan_deal_num;
  }
  public void set_jingxuan_deal_num(Integer jingxuan_deal_num) {
    this.jingxuan_deal_num = jingxuan_deal_num;
  }
  public team_merchant_assess_stat_day with_jingxuan_deal_num(Integer jingxuan_deal_num) {
    this.jingxuan_deal_num = jingxuan_deal_num;
    return this;
  }
  private java.math.BigDecimal jingxuan_deal_amount;
  public java.math.BigDecimal get_jingxuan_deal_amount() {
    return jingxuan_deal_amount;
  }
  public void set_jingxuan_deal_amount(java.math.BigDecimal jingxuan_deal_amount) {
    this.jingxuan_deal_amount = jingxuan_deal_amount;
  }
  public team_merchant_assess_stat_day with_jingxuan_deal_amount(java.math.BigDecimal jingxuan_deal_amount) {
    this.jingxuan_deal_amount = jingxuan_deal_amount;
    return this;
  }
  private Integer jingxuan_deal_seller_num;
  public Integer get_jingxuan_deal_seller_num() {
    return jingxuan_deal_seller_num;
  }
  public void set_jingxuan_deal_seller_num(Integer jingxuan_deal_seller_num) {
    this.jingxuan_deal_seller_num = jingxuan_deal_seller_num;
  }
  public team_merchant_assess_stat_day with_jingxuan_deal_seller_num(Integer jingxuan_deal_seller_num) {
    this.jingxuan_deal_seller_num = jingxuan_deal_seller_num;
    return this;
  }
  private Integer first_user_num;
  public Integer get_first_user_num() {
    return first_user_num;
  }
  public void set_first_user_num(Integer first_user_num) {
    this.first_user_num = first_user_num;
  }
  public team_merchant_assess_stat_day with_first_user_num(Integer first_user_num) {
    this.first_user_num = first_user_num;
    return this;
  }
  private Integer again_user_num;
  public Integer get_again_user_num() {
    return again_user_num;
  }
  public void set_again_user_num(Integer again_user_num) {
    this.again_user_num = again_user_num;
  }
  public team_merchant_assess_stat_day with_again_user_num(Integer again_user_num) {
    this.again_user_num = again_user_num;
    return this;
  }
  private Integer fair_pv;
  public Integer get_fair_pv() {
    return fair_pv;
  }
  public void set_fair_pv(Integer fair_pv) {
    this.fair_pv = fair_pv;
  }
  public team_merchant_assess_stat_day with_fair_pv(Integer fair_pv) {
    this.fair_pv = fair_pv;
    return this;
  }
  private Integer fair_uv;
  public Integer get_fair_uv() {
    return fair_uv;
  }
  public void set_fair_uv(Integer fair_uv) {
    this.fair_uv = fair_uv;
  }
  public team_merchant_assess_stat_day with_fair_uv(Integer fair_uv) {
    this.fair_uv = fair_uv;
    return this;
  }
  private Integer company_num;
  public Integer get_company_num() {
    return company_num;
  }
  public void set_company_num(Integer company_num) {
    this.company_num = company_num;
  }
  public team_merchant_assess_stat_day with_company_num(Integer company_num) {
    this.company_num = company_num;
    return this;
  }
  private Integer company_sku_num;
  public Integer get_company_sku_num() {
    return company_sku_num;
  }
  public void set_company_sku_num(Integer company_sku_num) {
    this.company_sku_num = company_sku_num;
  }
  public team_merchant_assess_stat_day with_company_sku_num(Integer company_sku_num) {
    this.company_sku_num = company_sku_num;
    return this;
  }
  private Integer sku_num;
  public Integer get_sku_num() {
    return sku_num;
  }
  public void set_sku_num(Integer sku_num) {
    this.sku_num = sku_num;
  }
  public team_merchant_assess_stat_day with_sku_num(Integer sku_num) {
    this.sku_num = sku_num;
    return this;
  }
  private Integer merchant_num;
  public Integer get_merchant_num() {
    return merchant_num;
  }
  public void set_merchant_num(Integer merchant_num) {
    this.merchant_num = merchant_num;
  }
  public team_merchant_assess_stat_day with_merchant_num(Integer merchant_num) {
    this.merchant_num = merchant_num;
    return this;
  }
  private Integer deal_merchant_num;
  public Integer get_deal_merchant_num() {
    return deal_merchant_num;
  }
  public void set_deal_merchant_num(Integer deal_merchant_num) {
    this.deal_merchant_num = deal_merchant_num;
  }
  public team_merchant_assess_stat_day with_deal_merchant_num(Integer deal_merchant_num) {
    this.deal_merchant_num = deal_merchant_num;
    return this;
  }
  private Integer value_num;
  public Integer get_value_num() {
    return value_num;
  }
  public void set_value_num(Integer value_num) {
    this.value_num = value_num;
  }
  public team_merchant_assess_stat_day with_value_num(Integer value_num) {
    this.value_num = value_num;
    return this;
  }
  private java.math.BigDecimal merchant_margins;
  public java.math.BigDecimal get_merchant_margins() {
    return merchant_margins;
  }
  public void set_merchant_margins(java.math.BigDecimal merchant_margins) {
    this.merchant_margins = merchant_margins;
  }
  public team_merchant_assess_stat_day with_merchant_margins(java.math.BigDecimal merchant_margins) {
    this.merchant_margins = merchant_margins;
    return this;
  }
  private java.math.BigDecimal warrant_balance;
  public java.math.BigDecimal get_warrant_balance() {
    return warrant_balance;
  }
  public void set_warrant_balance(java.math.BigDecimal warrant_balance) {
    this.warrant_balance = warrant_balance;
  }
  public team_merchant_assess_stat_day with_warrant_balance(java.math.BigDecimal warrant_balance) {
    this.warrant_balance = warrant_balance;
    return this;
  }
  private Integer certificate_num;
  public Integer get_certificate_num() {
    return certificate_num;
  }
  public void set_certificate_num(Integer certificate_num) {
    this.certificate_num = certificate_num;
  }
  public team_merchant_assess_stat_day with_certificate_num(Integer certificate_num) {
    this.certificate_num = certificate_num;
    return this;
  }
  private java.math.BigDecimal certificate_amount;
  public java.math.BigDecimal get_certificate_amount() {
    return certificate_amount;
  }
  public void set_certificate_amount(java.math.BigDecimal certificate_amount) {
    this.certificate_amount = certificate_amount;
  }
  public team_merchant_assess_stat_day with_certificate_amount(java.math.BigDecimal certificate_amount) {
    this.certificate_amount = certificate_amount;
    return this;
  }
  private java.sql.Timestamp update_time;
  public java.sql.Timestamp get_update_time() {
    return update_time;
  }
  public void set_update_time(java.sql.Timestamp update_time) {
    this.update_time = update_time;
  }
  public team_merchant_assess_stat_day with_update_time(java.sql.Timestamp update_time) {
    this.update_time = update_time;
    return this;
  }
  private java.math.BigDecimal dynamic_pin_ratio;
  public java.math.BigDecimal get_dynamic_pin_ratio() {
    return dynamic_pin_ratio;
  }
  public void set_dynamic_pin_ratio(java.math.BigDecimal dynamic_pin_ratio) {
    this.dynamic_pin_ratio = dynamic_pin_ratio;
  }
  public team_merchant_assess_stat_day with_dynamic_pin_ratio(java.math.BigDecimal dynamic_pin_ratio) {
    this.dynamic_pin_ratio = dynamic_pin_ratio;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof team_merchant_assess_stat_day)) {
      return false;
    }
    team_merchant_assess_stat_day that = (team_merchant_assess_stat_day) o;
    boolean equal = true;
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.deal_num == null ? that.deal_num == null : this.deal_num.equals(that.deal_num));
    equal = equal && (this.deal_amount == null ? that.deal_amount == null : this.deal_amount.equals(that.deal_amount));
    equal = equal && (this.deal_seller_num == null ? that.deal_seller_num == null : this.deal_seller_num.equals(that.deal_seller_num));
    equal = equal && (this.jingxuan_deal_num == null ? that.jingxuan_deal_num == null : this.jingxuan_deal_num.equals(that.jingxuan_deal_num));
    equal = equal && (this.jingxuan_deal_amount == null ? that.jingxuan_deal_amount == null : this.jingxuan_deal_amount.equals(that.jingxuan_deal_amount));
    equal = equal && (this.jingxuan_deal_seller_num == null ? that.jingxuan_deal_seller_num == null : this.jingxuan_deal_seller_num.equals(that.jingxuan_deal_seller_num));
    equal = equal && (this.first_user_num == null ? that.first_user_num == null : this.first_user_num.equals(that.first_user_num));
    equal = equal && (this.again_user_num == null ? that.again_user_num == null : this.again_user_num.equals(that.again_user_num));
    equal = equal && (this.fair_pv == null ? that.fair_pv == null : this.fair_pv.equals(that.fair_pv));
    equal = equal && (this.fair_uv == null ? that.fair_uv == null : this.fair_uv.equals(that.fair_uv));
    equal = equal && (this.company_num == null ? that.company_num == null : this.company_num.equals(that.company_num));
    equal = equal && (this.company_sku_num == null ? that.company_sku_num == null : this.company_sku_num.equals(that.company_sku_num));
    equal = equal && (this.sku_num == null ? that.sku_num == null : this.sku_num.equals(that.sku_num));
    equal = equal && (this.merchant_num == null ? that.merchant_num == null : this.merchant_num.equals(that.merchant_num));
    equal = equal && (this.deal_merchant_num == null ? that.deal_merchant_num == null : this.deal_merchant_num.equals(that.deal_merchant_num));
    equal = equal && (this.value_num == null ? that.value_num == null : this.value_num.equals(that.value_num));
    equal = equal && (this.merchant_margins == null ? that.merchant_margins == null : this.merchant_margins.equals(that.merchant_margins));
    equal = equal && (this.warrant_balance == null ? that.warrant_balance == null : this.warrant_balance.equals(that.warrant_balance));
    equal = equal && (this.certificate_num == null ? that.certificate_num == null : this.certificate_num.equals(that.certificate_num));
    equal = equal && (this.certificate_amount == null ? that.certificate_amount == null : this.certificate_amount.equals(that.certificate_amount));
    equal = equal && (this.update_time == null ? that.update_time == null : this.update_time.equals(that.update_time));
    equal = equal && (this.dynamic_pin_ratio == null ? that.dynamic_pin_ratio == null : this.dynamic_pin_ratio.equals(that.dynamic_pin_ratio));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof team_merchant_assess_stat_day)) {
      return false;
    }
    team_merchant_assess_stat_day that = (team_merchant_assess_stat_day) o;
    boolean equal = true;
    equal = equal && (this.stat_date == null ? that.stat_date == null : this.stat_date.equals(that.stat_date));
    equal = equal && (this.deal_num == null ? that.deal_num == null : this.deal_num.equals(that.deal_num));
    equal = equal && (this.deal_amount == null ? that.deal_amount == null : this.deal_amount.equals(that.deal_amount));
    equal = equal && (this.deal_seller_num == null ? that.deal_seller_num == null : this.deal_seller_num.equals(that.deal_seller_num));
    equal = equal && (this.jingxuan_deal_num == null ? that.jingxuan_deal_num == null : this.jingxuan_deal_num.equals(that.jingxuan_deal_num));
    equal = equal && (this.jingxuan_deal_amount == null ? that.jingxuan_deal_amount == null : this.jingxuan_deal_amount.equals(that.jingxuan_deal_amount));
    equal = equal && (this.jingxuan_deal_seller_num == null ? that.jingxuan_deal_seller_num == null : this.jingxuan_deal_seller_num.equals(that.jingxuan_deal_seller_num));
    equal = equal && (this.first_user_num == null ? that.first_user_num == null : this.first_user_num.equals(that.first_user_num));
    equal = equal && (this.again_user_num == null ? that.again_user_num == null : this.again_user_num.equals(that.again_user_num));
    equal = equal && (this.fair_pv == null ? that.fair_pv == null : this.fair_pv.equals(that.fair_pv));
    equal = equal && (this.fair_uv == null ? that.fair_uv == null : this.fair_uv.equals(that.fair_uv));
    equal = equal && (this.company_num == null ? that.company_num == null : this.company_num.equals(that.company_num));
    equal = equal && (this.company_sku_num == null ? that.company_sku_num == null : this.company_sku_num.equals(that.company_sku_num));
    equal = equal && (this.sku_num == null ? that.sku_num == null : this.sku_num.equals(that.sku_num));
    equal = equal && (this.merchant_num == null ? that.merchant_num == null : this.merchant_num.equals(that.merchant_num));
    equal = equal && (this.deal_merchant_num == null ? that.deal_merchant_num == null : this.deal_merchant_num.equals(that.deal_merchant_num));
    equal = equal && (this.value_num == null ? that.value_num == null : this.value_num.equals(that.value_num));
    equal = equal && (this.merchant_margins == null ? that.merchant_margins == null : this.merchant_margins.equals(that.merchant_margins));
    equal = equal && (this.warrant_balance == null ? that.warrant_balance == null : this.warrant_balance.equals(that.warrant_balance));
    equal = equal && (this.certificate_num == null ? that.certificate_num == null : this.certificate_num.equals(that.certificate_num));
    equal = equal && (this.certificate_amount == null ? that.certificate_amount == null : this.certificate_amount.equals(that.certificate_amount));
    equal = equal && (this.update_time == null ? that.update_time == null : this.update_time.equals(that.update_time));
    equal = equal && (this.dynamic_pin_ratio == null ? that.dynamic_pin_ratio == null : this.dynamic_pin_ratio.equals(that.dynamic_pin_ratio));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.stat_date = JdbcWritableBridge.readDate(1, __dbResults);
    this.deal_num = JdbcWritableBridge.readInteger(2, __dbResults);
    this.deal_amount = JdbcWritableBridge.readBigDecimal(3, __dbResults);
    this.deal_seller_num = JdbcWritableBridge.readInteger(4, __dbResults);
    this.jingxuan_deal_num = JdbcWritableBridge.readInteger(5, __dbResults);
    this.jingxuan_deal_amount = JdbcWritableBridge.readBigDecimal(6, __dbResults);
    this.jingxuan_deal_seller_num = JdbcWritableBridge.readInteger(7, __dbResults);
    this.first_user_num = JdbcWritableBridge.readInteger(8, __dbResults);
    this.again_user_num = JdbcWritableBridge.readInteger(9, __dbResults);
    this.fair_pv = JdbcWritableBridge.readInteger(10, __dbResults);
    this.fair_uv = JdbcWritableBridge.readInteger(11, __dbResults);
    this.company_num = JdbcWritableBridge.readInteger(12, __dbResults);
    this.company_sku_num = JdbcWritableBridge.readInteger(13, __dbResults);
    this.sku_num = JdbcWritableBridge.readInteger(14, __dbResults);
    this.merchant_num = JdbcWritableBridge.readInteger(15, __dbResults);
    this.deal_merchant_num = JdbcWritableBridge.readInteger(16, __dbResults);
    this.value_num = JdbcWritableBridge.readInteger(17, __dbResults);
    this.merchant_margins = JdbcWritableBridge.readBigDecimal(18, __dbResults);
    this.warrant_balance = JdbcWritableBridge.readBigDecimal(19, __dbResults);
    this.certificate_num = JdbcWritableBridge.readInteger(20, __dbResults);
    this.certificate_amount = JdbcWritableBridge.readBigDecimal(21, __dbResults);
    this.update_time = JdbcWritableBridge.readTimestamp(22, __dbResults);
    this.dynamic_pin_ratio = JdbcWritableBridge.readBigDecimal(23, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.stat_date = JdbcWritableBridge.readDate(1, __dbResults);
    this.deal_num = JdbcWritableBridge.readInteger(2, __dbResults);
    this.deal_amount = JdbcWritableBridge.readBigDecimal(3, __dbResults);
    this.deal_seller_num = JdbcWritableBridge.readInteger(4, __dbResults);
    this.jingxuan_deal_num = JdbcWritableBridge.readInteger(5, __dbResults);
    this.jingxuan_deal_amount = JdbcWritableBridge.readBigDecimal(6, __dbResults);
    this.jingxuan_deal_seller_num = JdbcWritableBridge.readInteger(7, __dbResults);
    this.first_user_num = JdbcWritableBridge.readInteger(8, __dbResults);
    this.again_user_num = JdbcWritableBridge.readInteger(9, __dbResults);
    this.fair_pv = JdbcWritableBridge.readInteger(10, __dbResults);
    this.fair_uv = JdbcWritableBridge.readInteger(11, __dbResults);
    this.company_num = JdbcWritableBridge.readInteger(12, __dbResults);
    this.company_sku_num = JdbcWritableBridge.readInteger(13, __dbResults);
    this.sku_num = JdbcWritableBridge.readInteger(14, __dbResults);
    this.merchant_num = JdbcWritableBridge.readInteger(15, __dbResults);
    this.deal_merchant_num = JdbcWritableBridge.readInteger(16, __dbResults);
    this.value_num = JdbcWritableBridge.readInteger(17, __dbResults);
    this.merchant_margins = JdbcWritableBridge.readBigDecimal(18, __dbResults);
    this.warrant_balance = JdbcWritableBridge.readBigDecimal(19, __dbResults);
    this.certificate_num = JdbcWritableBridge.readInteger(20, __dbResults);
    this.certificate_amount = JdbcWritableBridge.readBigDecimal(21, __dbResults);
    this.update_time = JdbcWritableBridge.readTimestamp(22, __dbResults);
    this.dynamic_pin_ratio = JdbcWritableBridge.readBigDecimal(23, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(stat_date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_num, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(deal_amount, 3 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_seller_num, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(jingxuan_deal_num, 5 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(jingxuan_deal_amount, 6 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(jingxuan_deal_seller_num, 7 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(first_user_num, 8 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(again_user_num, 9 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(fair_pv, 10 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(fair_uv, 11 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(company_num, 12 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(company_sku_num, 13 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(sku_num, 14 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(merchant_num, 15 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_merchant_num, 16 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(value_num, 17 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(merchant_margins, 18 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(warrant_balance, 19 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(certificate_num, 20 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(certificate_amount, 21 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeTimestamp(update_time, 22 + __off, 93, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(dynamic_pin_ratio, 23 + __off, 3, __dbStmt);
    return 23;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(stat_date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_num, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(deal_amount, 3 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_seller_num, 4 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(jingxuan_deal_num, 5 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(jingxuan_deal_amount, 6 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(jingxuan_deal_seller_num, 7 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(first_user_num, 8 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(again_user_num, 9 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(fair_pv, 10 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(fair_uv, 11 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(company_num, 12 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(company_sku_num, 13 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(sku_num, 14 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(merchant_num, 15 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(deal_merchant_num, 16 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(value_num, 17 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(merchant_margins, 18 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(warrant_balance, 19 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeInteger(certificate_num, 20 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(certificate_amount, 21 + __off, 3, __dbStmt);
    JdbcWritableBridge.writeTimestamp(update_time, 22 + __off, 93, __dbStmt);
    JdbcWritableBridge.writeBigDecimal(dynamic_pin_ratio, 23 + __off, 3, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.stat_date = null;
    } else {
    this.stat_date = new Date(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.deal_num = null;
    } else {
    this.deal_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.deal_amount = null;
    } else {
    this.deal_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.deal_seller_num = null;
    } else {
    this.deal_seller_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.jingxuan_deal_num = null;
    } else {
    this.jingxuan_deal_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.jingxuan_deal_amount = null;
    } else {
    this.jingxuan_deal_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.jingxuan_deal_seller_num = null;
    } else {
    this.jingxuan_deal_seller_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.first_user_num = null;
    } else {
    this.first_user_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.again_user_num = null;
    } else {
    this.again_user_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.fair_pv = null;
    } else {
    this.fair_pv = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.fair_uv = null;
    } else {
    this.fair_uv = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.company_num = null;
    } else {
    this.company_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.company_sku_num = null;
    } else {
    this.company_sku_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.sku_num = null;
    } else {
    this.sku_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.merchant_num = null;
    } else {
    this.merchant_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.deal_merchant_num = null;
    } else {
    this.deal_merchant_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.value_num = null;
    } else {
    this.value_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.merchant_margins = null;
    } else {
    this.merchant_margins = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.warrant_balance = null;
    } else {
    this.warrant_balance = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.certificate_num = null;
    } else {
    this.certificate_num = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.certificate_amount = null;
    } else {
    this.certificate_amount = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.update_time = null;
    } else {
    this.update_time = new Timestamp(__dataIn.readLong());
    this.update_time.setNanos(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.dynamic_pin_ratio = null;
    } else {
    this.dynamic_pin_ratio = com.cloudera.sqoop.lib.BigDecimalSerializer.readFields(__dataIn);
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.deal_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_num);
    }
    if (null == this.deal_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.deal_amount, __dataOut);
    }
    if (null == this.deal_seller_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_seller_num);
    }
    if (null == this.jingxuan_deal_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.jingxuan_deal_num);
    }
    if (null == this.jingxuan_deal_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.jingxuan_deal_amount, __dataOut);
    }
    if (null == this.jingxuan_deal_seller_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.jingxuan_deal_seller_num);
    }
    if (null == this.first_user_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.first_user_num);
    }
    if (null == this.again_user_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.again_user_num);
    }
    if (null == this.fair_pv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.fair_pv);
    }
    if (null == this.fair_uv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.fair_uv);
    }
    if (null == this.company_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.company_num);
    }
    if (null == this.company_sku_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.company_sku_num);
    }
    if (null == this.sku_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sku_num);
    }
    if (null == this.merchant_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.merchant_num);
    }
    if (null == this.deal_merchant_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_merchant_num);
    }
    if (null == this.value_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.value_num);
    }
    if (null == this.merchant_margins) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.merchant_margins, __dataOut);
    }
    if (null == this.warrant_balance) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.warrant_balance, __dataOut);
    }
    if (null == this.certificate_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.certificate_num);
    }
    if (null == this.certificate_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.certificate_amount, __dataOut);
    }
    if (null == this.update_time) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.update_time.getTime());
    __dataOut.writeInt(this.update_time.getNanos());
    }
    if (null == this.dynamic_pin_ratio) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.dynamic_pin_ratio, __dataOut);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.stat_date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.stat_date.getTime());
    }
    if (null == this.deal_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_num);
    }
    if (null == this.deal_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.deal_amount, __dataOut);
    }
    if (null == this.deal_seller_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_seller_num);
    }
    if (null == this.jingxuan_deal_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.jingxuan_deal_num);
    }
    if (null == this.jingxuan_deal_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.jingxuan_deal_amount, __dataOut);
    }
    if (null == this.jingxuan_deal_seller_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.jingxuan_deal_seller_num);
    }
    if (null == this.first_user_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.first_user_num);
    }
    if (null == this.again_user_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.again_user_num);
    }
    if (null == this.fair_pv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.fair_pv);
    }
    if (null == this.fair_uv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.fair_uv);
    }
    if (null == this.company_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.company_num);
    }
    if (null == this.company_sku_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.company_sku_num);
    }
    if (null == this.sku_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.sku_num);
    }
    if (null == this.merchant_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.merchant_num);
    }
    if (null == this.deal_merchant_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.deal_merchant_num);
    }
    if (null == this.value_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.value_num);
    }
    if (null == this.merchant_margins) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.merchant_margins, __dataOut);
    }
    if (null == this.warrant_balance) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.warrant_balance, __dataOut);
    }
    if (null == this.certificate_num) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.certificate_num);
    }
    if (null == this.certificate_amount) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.certificate_amount, __dataOut);
    }
    if (null == this.update_time) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.update_time.getTime());
    __dataOut.writeInt(this.update_time.getNanos());
    }
    if (null == this.dynamic_pin_ratio) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    com.cloudera.sqoop.lib.BigDecimalSerializer.write(this.dynamic_pin_ratio, __dataOut);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"null":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_num==null?"null":"" + deal_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_amount==null?"null":deal_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_seller_num==null?"null":"" + deal_seller_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_num==null?"null":"" + jingxuan_deal_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_amount==null?"null":jingxuan_deal_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_seller_num==null?"null":"" + jingxuan_deal_seller_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(first_user_num==null?"null":"" + first_user_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(again_user_num==null?"null":"" + again_user_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(fair_pv==null?"null":"" + fair_pv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(fair_uv==null?"null":"" + fair_uv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(company_num==null?"null":"" + company_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(company_sku_num==null?"null":"" + company_sku_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sku_num==null?"null":"" + sku_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(merchant_num==null?"null":"" + merchant_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_merchant_num==null?"null":"" + deal_merchant_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(value_num==null?"null":"" + value_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(merchant_margins==null?"null":merchant_margins.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(warrant_balance==null?"null":warrant_balance.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(certificate_num==null?"null":"" + certificate_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(certificate_amount==null?"null":certificate_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(update_time==null?"null":"" + update_time, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(dynamic_pin_ratio==null?"null":dynamic_pin_ratio.toPlainString(), delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(stat_date==null?"null":"" + stat_date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_num==null?"null":"" + deal_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_amount==null?"null":deal_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_seller_num==null?"null":"" + deal_seller_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_num==null?"null":"" + jingxuan_deal_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_amount==null?"null":jingxuan_deal_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(jingxuan_deal_seller_num==null?"null":"" + jingxuan_deal_seller_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(first_user_num==null?"null":"" + first_user_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(again_user_num==null?"null":"" + again_user_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(fair_pv==null?"null":"" + fair_pv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(fair_uv==null?"null":"" + fair_uv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(company_num==null?"null":"" + company_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(company_sku_num==null?"null":"" + company_sku_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(sku_num==null?"null":"" + sku_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(merchant_num==null?"null":"" + merchant_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(deal_merchant_num==null?"null":"" + deal_merchant_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(value_num==null?"null":"" + value_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(merchant_margins==null?"null":merchant_margins.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(warrant_balance==null?"null":warrant_balance.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(certificate_num==null?"null":"" + certificate_num, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(certificate_amount==null?"null":certificate_amount.toPlainString(), delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(update_time==null?"null":"" + update_time, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(dynamic_pin_ratio==null?"null":dynamic_pin_ratio.toPlainString(), delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_num = null; } else {
      this.deal_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_amount = null; } else {
      this.deal_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_seller_num = null; } else {
      this.deal_seller_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_num = null; } else {
      this.jingxuan_deal_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_amount = null; } else {
      this.jingxuan_deal_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_seller_num = null; } else {
      this.jingxuan_deal_seller_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.first_user_num = null; } else {
      this.first_user_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.again_user_num = null; } else {
      this.again_user_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.fair_pv = null; } else {
      this.fair_pv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.fair_uv = null; } else {
      this.fair_uv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.company_num = null; } else {
      this.company_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.company_sku_num = null; } else {
      this.company_sku_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sku_num = null; } else {
      this.sku_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.merchant_num = null; } else {
      this.merchant_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_merchant_num = null; } else {
      this.deal_merchant_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.value_num = null; } else {
      this.value_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.merchant_margins = null; } else {
      this.merchant_margins = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.warrant_balance = null; } else {
      this.warrant_balance = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.certificate_num = null; } else {
      this.certificate_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.certificate_amount = null; } else {
      this.certificate_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.update_time = null; } else {
      this.update_time = java.sql.Timestamp.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.dynamic_pin_ratio = null; } else {
      this.dynamic_pin_ratio = new java.math.BigDecimal(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.stat_date = null; } else {
      this.stat_date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_num = null; } else {
      this.deal_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_amount = null; } else {
      this.deal_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_seller_num = null; } else {
      this.deal_seller_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_num = null; } else {
      this.jingxuan_deal_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_amount = null; } else {
      this.jingxuan_deal_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.jingxuan_deal_seller_num = null; } else {
      this.jingxuan_deal_seller_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.first_user_num = null; } else {
      this.first_user_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.again_user_num = null; } else {
      this.again_user_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.fair_pv = null; } else {
      this.fair_pv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.fair_uv = null; } else {
      this.fair_uv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.company_num = null; } else {
      this.company_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.company_sku_num = null; } else {
      this.company_sku_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.sku_num = null; } else {
      this.sku_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.merchant_num = null; } else {
      this.merchant_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.deal_merchant_num = null; } else {
      this.deal_merchant_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.value_num = null; } else {
      this.value_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.merchant_margins = null; } else {
      this.merchant_margins = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.warrant_balance = null; } else {
      this.warrant_balance = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.certificate_num = null; } else {
      this.certificate_num = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.certificate_amount = null; } else {
      this.certificate_amount = new java.math.BigDecimal(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.update_time = null; } else {
      this.update_time = java.sql.Timestamp.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.dynamic_pin_ratio = null; } else {
      this.dynamic_pin_ratio = new java.math.BigDecimal(__cur_str);
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    team_merchant_assess_stat_day o = (team_merchant_assess_stat_day) super.clone();
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
    o.update_time = (o.update_time != null) ? (java.sql.Timestamp) o.update_time.clone() : null;
    return o;
  }

  public void clone0(team_merchant_assess_stat_day o) throws CloneNotSupportedException {
    o.stat_date = (o.stat_date != null) ? (java.sql.Date) o.stat_date.clone() : null;
    o.update_time = (o.update_time != null) ? (java.sql.Timestamp) o.update_time.clone() : null;
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("deal_num", this.deal_num);
    __sqoop$field_map.put("deal_amount", this.deal_amount);
    __sqoop$field_map.put("deal_seller_num", this.deal_seller_num);
    __sqoop$field_map.put("jingxuan_deal_num", this.jingxuan_deal_num);
    __sqoop$field_map.put("jingxuan_deal_amount", this.jingxuan_deal_amount);
    __sqoop$field_map.put("jingxuan_deal_seller_num", this.jingxuan_deal_seller_num);
    __sqoop$field_map.put("first_user_num", this.first_user_num);
    __sqoop$field_map.put("again_user_num", this.again_user_num);
    __sqoop$field_map.put("fair_pv", this.fair_pv);
    __sqoop$field_map.put("fair_uv", this.fair_uv);
    __sqoop$field_map.put("company_num", this.company_num);
    __sqoop$field_map.put("company_sku_num", this.company_sku_num);
    __sqoop$field_map.put("sku_num", this.sku_num);
    __sqoop$field_map.put("merchant_num", this.merchant_num);
    __sqoop$field_map.put("deal_merchant_num", this.deal_merchant_num);
    __sqoop$field_map.put("value_num", this.value_num);
    __sqoop$field_map.put("merchant_margins", this.merchant_margins);
    __sqoop$field_map.put("warrant_balance", this.warrant_balance);
    __sqoop$field_map.put("certificate_num", this.certificate_num);
    __sqoop$field_map.put("certificate_amount", this.certificate_amount);
    __sqoop$field_map.put("update_time", this.update_time);
    __sqoop$field_map.put("dynamic_pin_ratio", this.dynamic_pin_ratio);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("stat_date", this.stat_date);
    __sqoop$field_map.put("deal_num", this.deal_num);
    __sqoop$field_map.put("deal_amount", this.deal_amount);
    __sqoop$field_map.put("deal_seller_num", this.deal_seller_num);
    __sqoop$field_map.put("jingxuan_deal_num", this.jingxuan_deal_num);
    __sqoop$field_map.put("jingxuan_deal_amount", this.jingxuan_deal_amount);
    __sqoop$field_map.put("jingxuan_deal_seller_num", this.jingxuan_deal_seller_num);
    __sqoop$field_map.put("first_user_num", this.first_user_num);
    __sqoop$field_map.put("again_user_num", this.again_user_num);
    __sqoop$field_map.put("fair_pv", this.fair_pv);
    __sqoop$field_map.put("fair_uv", this.fair_uv);
    __sqoop$field_map.put("company_num", this.company_num);
    __sqoop$field_map.put("company_sku_num", this.company_sku_num);
    __sqoop$field_map.put("sku_num", this.sku_num);
    __sqoop$field_map.put("merchant_num", this.merchant_num);
    __sqoop$field_map.put("deal_merchant_num", this.deal_merchant_num);
    __sqoop$field_map.put("value_num", this.value_num);
    __sqoop$field_map.put("merchant_margins", this.merchant_margins);
    __sqoop$field_map.put("warrant_balance", this.warrant_balance);
    __sqoop$field_map.put("certificate_num", this.certificate_num);
    __sqoop$field_map.put("certificate_amount", this.certificate_amount);
    __sqoop$field_map.put("update_time", this.update_time);
    __sqoop$field_map.put("dynamic_pin_ratio", this.dynamic_pin_ratio);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
    }
    else    if ("deal_num".equals(__fieldName)) {
      this.deal_num = (Integer) __fieldVal;
    }
    else    if ("deal_amount".equals(__fieldName)) {
      this.deal_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("deal_seller_num".equals(__fieldName)) {
      this.deal_seller_num = (Integer) __fieldVal;
    }
    else    if ("jingxuan_deal_num".equals(__fieldName)) {
      this.jingxuan_deal_num = (Integer) __fieldVal;
    }
    else    if ("jingxuan_deal_amount".equals(__fieldName)) {
      this.jingxuan_deal_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("jingxuan_deal_seller_num".equals(__fieldName)) {
      this.jingxuan_deal_seller_num = (Integer) __fieldVal;
    }
    else    if ("first_user_num".equals(__fieldName)) {
      this.first_user_num = (Integer) __fieldVal;
    }
    else    if ("again_user_num".equals(__fieldName)) {
      this.again_user_num = (Integer) __fieldVal;
    }
    else    if ("fair_pv".equals(__fieldName)) {
      this.fair_pv = (Integer) __fieldVal;
    }
    else    if ("fair_uv".equals(__fieldName)) {
      this.fair_uv = (Integer) __fieldVal;
    }
    else    if ("company_num".equals(__fieldName)) {
      this.company_num = (Integer) __fieldVal;
    }
    else    if ("company_sku_num".equals(__fieldName)) {
      this.company_sku_num = (Integer) __fieldVal;
    }
    else    if ("sku_num".equals(__fieldName)) {
      this.sku_num = (Integer) __fieldVal;
    }
    else    if ("merchant_num".equals(__fieldName)) {
      this.merchant_num = (Integer) __fieldVal;
    }
    else    if ("deal_merchant_num".equals(__fieldName)) {
      this.deal_merchant_num = (Integer) __fieldVal;
    }
    else    if ("value_num".equals(__fieldName)) {
      this.value_num = (Integer) __fieldVal;
    }
    else    if ("merchant_margins".equals(__fieldName)) {
      this.merchant_margins = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("warrant_balance".equals(__fieldName)) {
      this.warrant_balance = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("certificate_num".equals(__fieldName)) {
      this.certificate_num = (Integer) __fieldVal;
    }
    else    if ("certificate_amount".equals(__fieldName)) {
      this.certificate_amount = (java.math.BigDecimal) __fieldVal;
    }
    else    if ("update_time".equals(__fieldName)) {
      this.update_time = (java.sql.Timestamp) __fieldVal;
    }
    else    if ("dynamic_pin_ratio".equals(__fieldName)) {
      this.dynamic_pin_ratio = (java.math.BigDecimal) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("stat_date".equals(__fieldName)) {
      this.stat_date = (java.sql.Date) __fieldVal;
      return true;
    }
    else    if ("deal_num".equals(__fieldName)) {
      this.deal_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("deal_amount".equals(__fieldName)) {
      this.deal_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("deal_seller_num".equals(__fieldName)) {
      this.deal_seller_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("jingxuan_deal_num".equals(__fieldName)) {
      this.jingxuan_deal_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("jingxuan_deal_amount".equals(__fieldName)) {
      this.jingxuan_deal_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("jingxuan_deal_seller_num".equals(__fieldName)) {
      this.jingxuan_deal_seller_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("first_user_num".equals(__fieldName)) {
      this.first_user_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("again_user_num".equals(__fieldName)) {
      this.again_user_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("fair_pv".equals(__fieldName)) {
      this.fair_pv = (Integer) __fieldVal;
      return true;
    }
    else    if ("fair_uv".equals(__fieldName)) {
      this.fair_uv = (Integer) __fieldVal;
      return true;
    }
    else    if ("company_num".equals(__fieldName)) {
      this.company_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("company_sku_num".equals(__fieldName)) {
      this.company_sku_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("sku_num".equals(__fieldName)) {
      this.sku_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("merchant_num".equals(__fieldName)) {
      this.merchant_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("deal_merchant_num".equals(__fieldName)) {
      this.deal_merchant_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("value_num".equals(__fieldName)) {
      this.value_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("merchant_margins".equals(__fieldName)) {
      this.merchant_margins = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("warrant_balance".equals(__fieldName)) {
      this.warrant_balance = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("certificate_num".equals(__fieldName)) {
      this.certificate_num = (Integer) __fieldVal;
      return true;
    }
    else    if ("certificate_amount".equals(__fieldName)) {
      this.certificate_amount = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else    if ("update_time".equals(__fieldName)) {
      this.update_time = (java.sql.Timestamp) __fieldVal;
      return true;
    }
    else    if ("dynamic_pin_ratio".equals(__fieldName)) {
      this.dynamic_pin_ratio = (java.math.BigDecimal) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
                                                                 home/hive/gds/bin/tmpetl.sh                                                                         0000644 0000000 0000000 00000000702 12616315264 014632  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	trace_nginx_domain
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_share          
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_order          
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_user_sign_up   
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_sms            
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_product        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              tmpetl.sh                                                                                           0000644 0000000 0000000 00000000702 12616315264 011422  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	trace_nginx_domain
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_share          
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_order          
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_user_sign_up   
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_sms            
	./sqoop_data_extract_all.sh 172.16.14.41 3306 qbaochou	bc_product        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              