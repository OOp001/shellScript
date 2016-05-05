me call_mysql_proc.sh                                                            
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
