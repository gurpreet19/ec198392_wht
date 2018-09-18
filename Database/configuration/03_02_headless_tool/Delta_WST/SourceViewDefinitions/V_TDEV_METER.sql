CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TDEV_METER" ("OBJECT_ID", "CODE_TEXT", "CODE", "SORT_ORDER", "CODE_TYPE", "DAYTIME", "END_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT DISTINCT OBJECT_ID,
                ECBP_TESTDEVICE.GETMETERTEXT(E.CODE,
                                             E.CODE_TYPE,
                                             OV.OBJECT_ID,
                                             OV.DAYTIME) AS CODE_TEXT,
                E.CODE AS CODE,
                E.SORT_ORDER AS SORT_ORDER,
                E.CODE_TYPE AS CODE_TYPE,
                OV.DAYTIME,
                OV.END_DATE,
                NULL AS RECORD_STATUS,
                NULL AS CREATED_BY,
                NULL AS CREATED_DATE,
                NULL AS LAST_UPDATED_BY,
                NULL AS LAST_UPDATED_DATE,
                NULL AS REV_NO,
                NULL AS REV_TEXT
  FROM OV_TEST_DEVICE OV, TV_EC_CODES_POPUP E
 WHERE E.IS_ACTIVE = 'Y'
   AND E.CODE_TYPE IN (SELECT CODE FROM PROSTY_CODES WHERE CODE_TYPE='TDEV_METER')