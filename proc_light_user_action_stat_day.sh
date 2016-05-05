#!/bin/sh
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


