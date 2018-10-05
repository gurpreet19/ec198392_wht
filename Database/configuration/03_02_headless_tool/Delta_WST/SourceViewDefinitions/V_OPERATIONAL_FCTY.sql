CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OPERATIONAL_FCTY" ("OBJECT_ID", "START_DATE", "END_DATE", "OBJECT_CODE", "NAME") AS 
  SELECT object_id,
       START_DATE,
       END_DATE,
       OBJECT_CODE,
       ec_fcty_version.name(object_id,
         				Ecdp_Timestamp.getCurrentSysdate,
					'<=') AS NAME
    FROM PRODUCTION_FACILITY
    WHERE CLASS_NAME in ('FCTY_CLASS_1')