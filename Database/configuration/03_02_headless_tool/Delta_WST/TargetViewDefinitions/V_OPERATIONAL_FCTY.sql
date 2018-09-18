CREATE OR REPLACE FORCE VIEW "V_OPERATIONAL_FCTY" ("OBJECT_ID", "START_DATE", "END_DATE", "OBJECT_CODE", "NAME") AS 
  SELECT object_id,
       START_DATE,
       END_DATE,
       OBJECT_CODE,
       ec_fcty_version.name(object_id,
         				EcDp_Date_Time.getCurrentSysdate,
					'<=') AS NAME
    FROM PRODUCTION_FACILITY
    WHERE CLASS_NAME in ('FCTY_CLASS_1')