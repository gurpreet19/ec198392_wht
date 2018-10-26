CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_JS_REPORT_TAG_SUM" ("OBJECT_ID", "COMPANY_ID", "FISCAL_YEAR", "DAYTIME", "PERIOD", "MTHS", "DATASET", "FIN_ACCOUNT_ID", "FIN_COST_CENTER_ID", "FIN_COST_OBJECT_ID", "FIN_REVENUE_ORDER_ID", "FIN_WBS_ID", "DEBIT_CREDIT", "ACTUAL_AMOUNT", "ACTUAL_QTY_1", "AMEND_AMOUNT", "AMEND_QTY_1", "INVENTORY_ID", "UOM1_CODE", "TAG", "LABEL", "DOCUMENT_KEY", "CURRENCY_ID", "LIST_ITEM_KEY", "SUMMARY_SETUP_ID", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT
      OBJECT_ID
      ,COMPANY_ID
      ,FISCAL_YEAR
      ,cjs.DAYTIME
      ,PERIOD  -- start month
      ,m.MTHS -- number of months to sum
      ,DATASET
      ,FIN_ACCOUNT_ID
      ,FIN_COST_CENTER_ID
      ,FIN_COST_OBJECT_ID
      ,FIN_REVENUE_ORDER_ID
      ,FIN_WBS_ID
      ,DEBIT_CREDIT
      ,(SELECT SUM(ACTUAL_AMOUNT)
          FROM cont_journal_summary c
         WHERE c.object_id = cjs.object_id
           AND c.summary_setup_id = cjs.summary_setup_id
           AND c.tag = cjs.tag
           AND c.period >= cjs.period
           AND c.period < add_months(cjs.period, m.mths)
           AND c.document_key = ecdp_rr_revn_summary.GetLastAppSummaryDoc(c.object_id, c.summary_setup_id, c.period, ec_cont_doc.inventory_id(c.document_key))) ACTUAL_AMOUNT
      ,(SELECT SUM(ACTUAL_QTY_1)
          FROM cont_journal_summary c
         WHERE c.object_id = cjs.object_id
           AND c.summary_setup_id = cjs.summary_setup_id
           AND c.tag = cjs.tag
           AND c.period >= cjs.period
           AND c.period < add_months(cjs.period, m.mths)
           AND c.document_key = ecdp_rr_revn_summary.GetLastAppSummaryDoc(c.object_id, c.summary_setup_id, c.period, ec_cont_doc.inventory_id(c.document_key))) ACTUAL_QTY_1
      ,(SELECT SUM(AMEND_AMOUNT)
          FROM cont_journal_summary c
         WHERE c.object_id = cjs.object_id
           AND c.summary_setup_id = cjs.summary_setup_id
           AND c.tag = cjs.tag
           AND c.period >= cjs.period
           AND c.period < add_months(cjs.period, m.mths)
           AND c.document_key = ecdp_rr_revn_summary.GetLastAppSummaryDoc(c.object_id, c.summary_setup_id, c.period, ec_cont_doc.inventory_id(c.document_key))) AMEND_AMOUNT
      ,(SELECT SUM(AMEND_QTY_1)
          FROM cont_journal_summary c
         WHERE c.object_id = cjs.object_id
           AND c.summary_setup_id = cjs.summary_setup_id
           AND c.tag = cjs.tag
           AND c.period >= cjs.period
           AND c.period < add_months(cjs.period, m.mths)
           AND c.document_key = ecdp_rr_revn_summary.GetLastAppSummaryDoc(c.object_id, c.summary_setup_id, c.period, ec_cont_doc.inventory_id(c.document_key))) AMEND_QTY_1
      ,(SELECT cd.inventory_id
          FROM cont_doc cd
         WHERE cd.document_key =cjs.document_key) INVENTORY_ID
      ,UOM1_CODE
      ,TAG
      ,LABEL
      ,DOCUMENT_KEY
      ,CURRENCY_ID
      ,LIST_ITEM_KEY
      ,SUMMARY_SETUP_ID
      ,COMMENTS
      ,TEXT_1
      ,TEXT_2
      ,TEXT_3
      ,TEXT_4
      ,TEXT_5
      ,TEXT_6
      ,TEXT_7
      ,TEXT_8
      ,TEXT_9
      ,TEXT_10
      ,VALUE_1
      ,VALUE_2
      ,VALUE_3
      ,VALUE_4
      ,VALUE_5
      ,DATE_1
      ,DATE_2
      ,DATE_3
      ,DATE_4
      ,DATE_5
      ,REF_OBJECT_ID_1
      ,REF_OBJECT_ID_2
      ,REF_OBJECT_ID_3
      ,REF_OBJECT_ID_4
      ,REF_OBJECT_ID_5
      ,RECORD_STATUS
      ,CREATED_BY
      ,CREATED_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATED_DATE
      ,REV_NO
      ,REV_TEXT
      ,APPROVAL_BY
      ,APPROVAL_DATE
      ,APPROVAL_STATE
      ,REC_ID
 FROM (SELECT *
         FROM cont_journal_summary js
        WHERE js.document_key = (SELECT cd1.document_key
                          FROM cont_doc cd1
                         WHERE cd1.created_date = (SELECT MAX(created_date)
                                                     FROM cont_doc cd2
                                                    WHERE cd2.object_id = js.object_id
                                                      AND cd2.summary_setup_id = js.summary_setup_id
                                                      AND nvl(cd2.inventory_id,'XX') = nvl(cd1.inventory_id,'XX')
                                                      AND cd2.period = js.period
                                                      AND cd2.record_status in ('V', 'A'))
                           AND cd1.record_status = 'A')
      ) cjs,
       (SELECT NUM MTHS FROM summary_number WHERE NUM = 1 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 2 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 3 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 4 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 5 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 6 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 7 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 8 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 9 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 10 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 11 UNION ALL
        SELECT NUM MTHS FROM summary_number WHERE NUM = 12 ) m