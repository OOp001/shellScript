#!/bin/sh
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
