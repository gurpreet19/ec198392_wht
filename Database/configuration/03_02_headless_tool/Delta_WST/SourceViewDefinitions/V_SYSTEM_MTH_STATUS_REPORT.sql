CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SYSTEM_MTH_STATUS_REPORT" ("DAYTIME", "COUNTRY_ID", "COMPANY_ID", "SALE", "PURCHASE", "TA_INCOME", "TA_COST", "QUANTITIES", "INVENTORY", "JOU_ENT", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "RECORD_STATUS") AS 
  SELECT DISTINCT
sms.DAYTIME,
sms.COUNTRY_ID,
sms.COMPANY_ID,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'SALE'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS SALE,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'PURCHASE'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS PURCHASE,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'TA_INCOME'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS TA_INCOME,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'TA_COST'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS TA_COST,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'QUANTITIES'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS QUANTITIES,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'INVENTORY'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS INVENTORY,
(select t.closed_report_date FROM system_mth_status t
WHERE t.daytime = sms.daytime AND t.country_id = sms.country_id AND t.company_id = sms.company_id AND t.booking_area_code = 'JOU_ENT'
AND t.closed_report_date <= Ecdp_Timestamp.getCurrentSysdate)
AS JOU_ENT,
'N/A' CREATED_BY,
to_date('01.01.1900', 'DD.MM.YYYY') CREATED_DATE,
'N/A' last_updated_by,
to_date('01.01.1900', 'DD.MM.YYYY') LAST_UPDATED_DATE,
0 REV_NO,
'N/A' REV_TEXT,
'P' RECORD_STATUS
FROM system_mth_status sms