CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_EQPM_TYPE" ("CODE_TEXT", "CODE", "OBJECT_ID", "OP_FCTY_CLASS_1_ID", "OP_FCTY_CLASS_2_ID", "CP_COL_POINT_ID", "OP_SUB_PU_ID", "OP_AREA_ID", "OP_SUB_AREA_ID", "CP_OPERATOR_ROUTE_ID", "DAYTIME", "END_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_eqpm_type.sql
-- View name: v_eqpm_type
--
-- $Revision: 1.0 $
--
-- Purpose  : Used to Eqpm type under selected navigator.
--
-- Modification history:
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 06.12.2016 dhavaalo   ECPD-41100:Intial version
----------------------------------------------------------------------------------------------------
SELECT DISTINCT EC_PROSTY_CODES.CODE_TEXT(E.EQPM_TYPE, 'EQPM_TYPE') CODE_TEXT,
                E.EQPM_TYPE CODE,
                E.OBJECT_ID,
                OP_FCTY_CLASS_1_ID,
                OP_FCTY_CLASS_2_ID,
                CP_COL_POINT_ID,
                OP_SUB_PU_ID,
                OP_AREA_ID,
                OP_SUB_AREA_ID,
                CP_OPERATOR_ROUTE_ID,
                EV.DAYTIME,
                EV.END_DATE,
                NULL RECORD_STATUS,
                NULL CREATED_BY,
                NULL CREATED_DATE,
                NULL LAST_UPDATED_BY,
                NULL LAST_UPDATED_DATE,
                NULL REV_NO,
                NULL REV_TEXT
  FROM EQUIPMENT E, EQPM_VERSION EV
 WHERE E.OBJECT_ID = EV.OBJECT_ID
 )