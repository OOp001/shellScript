#!/bin/sh
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
