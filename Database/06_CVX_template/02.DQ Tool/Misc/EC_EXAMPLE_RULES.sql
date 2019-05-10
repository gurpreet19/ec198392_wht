--******************************************************************************************
--** SQL statements created by EC Configuration utility version 94001
--** Workbook source: P:\My Documents\TFS\CVX\9.3\Deployments\Enhancements\Data Quality Tool\Misc\EC Example Rules.xls
--** Computer name  : PBYKENX2347
--** User name      : Scott Sugarbaker
--** Date and time  : 2/26/2015 9:47:57 AM
--******************************************************************************************
set define off
--
--Extracting DELETE statements
--
--Extracting INSERT statements
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Perforation Split factors must sum to 100 %', 'EXAMPLE_CAT', 'EXAMPLE_SUBCAT', 'PERF_INTERVAL', 'SPLIT FACTORS', 'WELL_BORE_INTERVAL_ID', 'DAYTIME', 'FROM (select s.WELL_BORE_INTERVAL_ID, d.daytime, sum(oil) as oil_tot, sum(gas) as gas_tot, sum(water) as water_tot
from Rv_perf_interval_split s, 
(select distinct WELL_BORE_INTERVAL_ID, daytime
from rv_perf_interval_split) d
where s.WELL_BORE_INTERVAL_ID = d.WELL_BORE_INTERVAL_ID
and s.daytime <= d.daytime
and nvl(s.end_date,d.daytime + 1) > d.daytime
group by S.WELL_BORE_INTERVAL_ID , d.daytime)
where (oil_tot <> 100 or gas_tot <> 100 or water_tot <> 100)', 'Perf splits- oil = :oil_tot , gas = :gas_tot , water = :water_tot');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Monthly alloc gas not equal to sum of daily', 'EXAMPLE_CAT', 'EXAMPLE_SUBCAT', 'WELL', 'ALLOC_GAS_VOL', 'a.object_id', 'a.daytime', 'FROM (select 
daytime,
object_id,
nvl(ALLOC_GAS_VOL,0) as monthly_vol
FROM DV_PWEL_MTH_ALLOC
) a,
(
select 
object_id,
sum(nvl(alloc_gas_vol,0)) as daily_vol,
trunc(daytime,''MM'') as daytime
from Dv_pwel_day_alloc
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol , the monthly volume = :a.monthly_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL) VALUES ('N', 'Well Tests remaining in NEW status', 'EXAMPLE_CAT', 'EXAMPLE_SUBCAT', 'WELL', 'STATUS', 'object_id', 'DAYTIME', 'RESULT_NO', 'FROM DV_pwel_result
where status = ''NEW''');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL) VALUES ('N', 'Daily Instantiated Gas Stream Volumes are NULL', 'EXAMPLE_CAT', 'EXAMPLE_SUBCAT', 'STREAM', 'GRS_VOL_GAS', 'object_id', 'DAYTIME', 'FROM rv_strm_day_stream_meas_gas
where stream_type = ''M''
and strm_meter_method = ''FREQ''
and stream_meter_freq = ''DAY''
and grs_vol_gas_mscf is NULL');
INSERT INTO TV_CT_DQ_RULE_GROUP (RULE_GROUP_CODE, RULE_GROUP_DESCRIPTION, COMMENTS, IS_REPORT_ONLY, START_DATE_SOURCE, END_DATE_SOURCE) VALUES ('ALL_DATES', 'All Dates', 'Used for master data rules, or rules where dates are hard-codes in SQL, or for rules evaluating all data', 'N', 'to_date(''01/01/1900'',''mm/dd/yyyy'')', 'to_date(''12/31/9999'',''mm/dd/yyyy'')');
INSERT INTO TV_CT_DQ_RULE_GROUP (RULE_GROUP_CODE, RULE_GROUP_DESCRIPTION, IS_REPORT_ONLY, START_DATE_SOURCE, END_DATE_SOURCE) VALUES ('LAST_30_DAYS', 'Last 30 Days', 'N', 'trunc(sysdate) - 30', 'trunc(sysdate)');
INSERT INTO TV_CT_DQ_RULE_GROUP (RULE_GROUP_CODE, RULE_GROUP_DESCRIPTION, IS_REPORT_ONLY, START_DATE_SOURCE, END_DATE_SOURCE) VALUES ('YESTERDAY', 'Yesterday', 'N', 'trunc(sysdate) - 1', 'trunc(sysdate)');
INSERT INTO TV_CT_DQ_RULE_GROUP (RULE_GROUP_CODE, RULE_GROUP_DESCRIPTION, IS_REPORT_ONLY, START_DATE_SOURCE, END_DATE_SOURCE) VALUES ('MONTH_TO_DATE', 'Month to Date', 'N', 'trunc(sysdate,''MM'')', 'trunc(sysdate)');
--
--Extracting UPDATE statements
--
--
set define on