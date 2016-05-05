#!/bin/sh
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
