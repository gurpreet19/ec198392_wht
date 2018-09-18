CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_EC_CODE_TYPES_REVN" ("CODE_TYPE", "IS_SYSTEM_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_EC_CODE_TYPES_REVN.sql
-- View name: V_EC_CODE_TYPES_REVN
--
-- $Revision:
--
-- Purpose  : Provides distinct EC code types together with dummy revision attributes for the DAO.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------
SELECT DISTINCT
 code_type
,is_system_code
,NULL record_status
,NULL created_by
,NULL created_date
,NULL last_updated_by
,NULL last_updated_date
,NULL rev_no
,NULL rev_text
FROM prosty_codes
)