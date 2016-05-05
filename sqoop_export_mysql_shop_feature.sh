
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

