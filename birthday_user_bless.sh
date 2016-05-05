#!/bin/sh
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
