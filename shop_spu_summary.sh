#!/bin/sh
source /etc/profile
HADOOP_HOME='/opt/cloudera/parcels/CDH-5.3.4-1.cdh5.3.4.p0.4/'

#商品综合信息，店铺综合排序--提供搜索使用
/home/hive/gds/bin/call_proc.sh proc_shop_spu_summary

/usr/bin/mysql -ueadmin -p'EWQTB512Oikf;' -h172.16.14.36 -P3306 --default-character-set=utf8 -Dmerchant_middle -e "truncate table merchant_middle.spu_summary;truncate table merchant_middle.shop_summary"

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username eadmin --password 'EWQTB512Oikf;' --table spu_summary --export-dir /user/hive/warehouse/dm.db/spu_summary --input-fields-terminated-by '\001' -m 10

/usr/bin/sqoop export --connect jdbc:mysql://172.16.14.36:3306/merchant_middle --username eadmin --password 'EWQTB512Oikf;' --table shop_summary --export-dir /user/hive/warehouse/dm.db/shop_summary --input-fields-terminated-by '\001' -m 4

