CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_OPEN_MTH" ("DAYTIME", "OBJECT_ID", "LAYER_MONTH", "CALC_RUN_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT DISTINCT add_months(DAYTIME,1) daytime, OBJECT_ID, LAYER_MONTH, CALC_RUN_NO,
       NULL RECORD_STATUS,
       NULL CREATED_BY ,
       NULL CREATED_DATE ,
       NULL LAST_UPDATED_BY ,
       NULL LAST_UPDATED_DATE  ,
       NULL REV_NO  ,
       NULL REV_TEXT
       FROM TRANS_INVENTORY_BALANCE X
       WHERE CALC_RUN_NO IN
        (select max(calc_run_no) from trans_inventory_balance where daytime=x.daytime AND
                ((select COUNT(*) from calc_parameter WHERE PARAMETER_CODE = 'ALLOW_PREC_PROVISIONAL' AND PARAMETER_VALUE = 'YES'
                AND EC_CALC_REFERENCE.CALCULATION_ID(CALC_RUN_NO) = OBJECT_ID) > 0
                OR  NVL(ec_calc_reference.record_status(calc_run_no),'P') != 'P')
                AND PROD_STREAM_ID = X.PROD_STREAM_ID
                AND OBJECT_ID = X.OBJECT_ID
                )
        --or calc_run_no = 162
GROUP BY OBJECT_ID,X.CALC_RUN_NO,LAYER_MONTH,DAYTIME
UNION ALL
--For reruns
SELECT DISTINCT daytime, OBJECT_ID, LAYER_MONTH, CALC_RUN_NO,
       NULL RECORD_STATUS,
       NULL CREATED_BY ,
       NULL CREATED_DATE ,
       NULL LAST_UPDATED_BY ,
       NULL LAST_UPDATED_DATE  ,
       NULL REV_NO  ,
       NULL REV_TEXT
       FROM TRANS_INVENTORY_BALANCE X
       WHERE CALC_RUN_NO IN
        (select max(calc_run_no) from trans_inventory_balance where daytime=x.daytime AND
                ((select COUNT(*) from calc_parameter WHERE PARAMETER_CODE = 'ALLOW_PREV_PROVISIONAL' AND PARAMETER_VALUE = 'YES'
                AND EC_CALC_REFERENCE.CALCULATION_ID(CALC_RUN_NO) = OBJECT_ID) > 0
                OR  NVL(ec_calc_reference.record_status(calc_run_no),'P') != 'P')
                AND PROD_STREAM_ID = X.PROD_STREAM_ID
                AND OBJECT_ID = X.OBJECT_ID
                )
GROUP BY OBJECT_ID,X.CALC_RUN_NO,LAYER_MONTH,DAYTIME