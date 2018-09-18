CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEFERMENT_CALC_ASSET_ID" ("NAME", "OBJECT_ID", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT "NAME","OBJECT_ID","SORT_ORDER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT"
  FROM (
        --PRODUCTIONUNIT,PROD_SUB_UNIT,AREA,SUB_AREA
        SELECT ECDP_OBJECTS.GETOBJNAME(A.OBJECT_ID,
                                        Ecdp_Timestamp.getCurrentSysdate) NAME,
                A.OBJECT_ID,
                DECODE(CLASS_NAME,
                       'PRODUCTIONUNIT',
                       1,
                       'PROD_SUB_UNIT',
                       2,
                       'AREA',
                       3,
                       'SUB_AREA',
                       4) SORT_ORDER,
                NULL AS RECORD_STATUS,
                NULL AS CREATED_BY,
                NULL AS CREATED_DATE,
                NULL AS LAST_UPDATED_BY,
                NULL AS LAST_UPDATED_DATE,
                NULL AS REV_NO,
                NULL AS REV_TEXT
        FROM GEOGRAPHICAL_AREA A
        WHERE A.CLASS_NAME IN
               ('PRODUCTIONUNIT', 'PROD_SUB_UNIT', 'AREA', 'SUB_AREA')
        UNION ALL
        --FCTY_CLASS_1,FCTY_CLASS_2
        SELECT ECDP_OBJECTS.GETOBJNAME(A.OBJECT_ID,
                                        Ecdp_Timestamp.getCurrentSysdate) NAME,
                A.OBJECT_ID,
                DECODE(CLASS_NAME, 'FCTY_CLASS_1', 5, 'FCTY_CLASS_2', 6) SORT_ORDER,
                NULL AS RECORD_STATUS,
                NULL AS CREATED_BY,
                NULL AS CREATED_DATE,
                NULL AS LAST_UPDATED_BY,
                NULL AS LAST_UPDATED_DATE,
                NULL AS REV_NO,
                NULL AS REV_TEXT
                FROM PRODUCTION_FACILITY A
        WHERE A.CLASS_NAME IN ('FCTY_CLASS_2', 'FCTY_CLASS_1')
        UNION ALL
        --WELL HOOKUP
        SELECT ECDP_OBJECTS.GETOBJNAME(A.OBJECT_ID,
                                        Ecdp_Timestamp.getCurrentSysdate) NAME,
                A.OBJECT_ID,
                7 SORT_ORDER,
                NULL AS RECORD_STATUS,
                NULL AS CREATED_BY,
                NULL AS CREATED_DATE,
                NULL AS LAST_UPDATED_BY,
                NULL AS LAST_UPDATED_DATE,
                NULL AS REV_NO,
                NULL AS REV_TEXT
        FROM WELL_HOOKUP A
        )
 ORDER BY SORT_ORDER, NAME