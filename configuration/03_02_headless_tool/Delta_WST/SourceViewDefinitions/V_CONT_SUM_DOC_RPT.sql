CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_SUM_DOC_RPT" ("OBJECT_ID", "REPORTING_PERIOD", "DAYTIME", "PERIOD", "DOCUMENT_KEY", "SUMMARY_SETUP_ID", "PRECEDING_DOCUMENT_KEY", "DATASET", "COMMENTS", "INVENTORY_ID", "ACCRUAL_IND", "IS_MANUAL_IND", "REFERENCE", "FINANCIAL_CODE", "DOCUMENT_TYPE", "DOCUMENT_NUMBER", "DOCUMENT_LEVEL_CODE", "PARENT_DOCUMENT_KEY", "REVERSAL_DATE", "STATUS_CODE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT s.OBJECT_ID,
       nvl(REPORTING_PERIOD,open_period) REPORTING_PERIOD ,
       s.DAYTIME,
       s.PERIOD,
       s.DOCUMENT_KEY,
       s.SUMMARY_SETUP_ID,
       S.PRECEDING_DOCUMENT_KEY,
       s.DATASET,
       s.COMMENTS,
       NVL(s.inventory_id,'NONE') inventory_id,
       NVL(s.ACCRUAL_IND,'N') ACCRUAL_IND,
       NVL(s.Is_Manual_Ind,'N') Is_Manual_Ind,
       S.REFERENCE,
       S.FINANCIAL_CODE,
       S.DOCUMENT_TYPE,
       S.DOCUMENT_NUMBER,
       S.DOCUMENT_LEVEL_CODE,
       S.PARENT_DOCUMENT_KEY,
       S.REVERSAL_DATE,
       S.STATUS_CODE,
       s.TEXT_1,
       s.TEXT_2,
       s.TEXT_3,
       s.TEXT_4,
       s.TEXT_5,
       s.TEXT_6,
       s.TEXT_7,
       s.TEXT_8,
       s.TEXT_9,
       s.TEXT_10,
       s.VALUE_1,
       s.VALUE_2,
       s.VALUE_3,
       s.VALUE_4,
       s.VALUE_5,
       s.DATE_1,
       s.DATE_2,
       s.DATE_3,
       s.DATE_4,
       s.DATE_5,
       s.REF_OBJECT_ID_1,
       s.REF_OBJECT_ID_2,
       s.REF_OBJECT_ID_3,
       s.REF_OBJECT_ID_4,
       s.REF_OBJECT_ID_5,
       s.RECORD_STATUS,
       s.CREATED_BY,
       s.CREATED_DATE,
       s.LAST_UPDATED_BY,
       s.LAST_UPDATED_DATE,
       s.REV_NO,
       s.REV_TEXT,
       s.APPROVAL_BY,
       s.APPROVAL_DATE,
       s.APPROVAL_STATE,
       s.REC_ID
  FROM CONT_DOC s,
               (SELECT MIN(sms.DAYTIME) open_period, ECDP_OBJECTS.GETOBJCODE(cv.object_id),
                cv.object_id FROM
                  system_mth_status sms,
                  company_version c,
                  contract_version cv
                  where sms.company_id = cv.company_id
                    and sms.country_id = c.country_id
                    and sms.booking_area_code = replace(cv.financial_code,'REVENUE_STREAM','JOU_ENT')
                    and closed_report_date is null
                    and c.daytime<=sms.daytime
                    and nvl(c.end_date,sms.daytime+1)>sms.daytime
                    and cv.daytime<=sms.daytime
                    and nvl(cv.end_date,sms.daytime+1)>sms.daytime
                    group by cv.object_id) close_period
  WHERE s.RECORD_STATUS IN ('A','V')
  AND s.object_id = close_period.object_id
  AND DOCUMENT_TYPE = 'SUMMARY'
  AND s.created_date =
  (select max(created_date) from cont_doc x where x.object_id  = s.object_id
  and x.summary_setup_id = s.summary_setup_id
  and nvl(x.inventory_id,'xx') = nvl(s.inventory_id,'xx')
  and x.period = s.period
  and x.RECORD_STATUS IN ('A','V')
  and nvl(x.reporting_period,open_period)
   = nvl(s.reporting_period,open_period)
  AND NVL(s.ACCRUAL_IND,'N') = NVL(ACCRUAL_IND,'N')
  )