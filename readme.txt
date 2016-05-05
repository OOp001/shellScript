数据抽取脚本,在/home/hive/gds/bin下,需要切换到hive用户执行 
*_all为全量抽取脚本,参数：ip,端口,mysql库名,mysql表名
*_part为增量抽取脚本,参数: ip,端口,mysql库名,mysql表名,增量字段,日期(缺省为昨天)
#./soop_data_extract_full.sh 172.16.14.41 3306 qbaochou bc_shop_product
