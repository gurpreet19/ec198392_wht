CREATE OR REPLACE FORCE VIEW "V_TRANS_CONFIG_JN" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "MAPPING_NO", "TEMPLATE_NO", "TEMPLATE_CODE", "SOURCE_ID", "TAG_ID", "FROM_UNIT", "TO_UNIT", "DATA_CLASS", "ATTRIBUTE", "PK_ATTR_1", "PK_VAL_1", "PK_ATTR_2", "PK_VAL_2", "PK_ATTR_3", "PK_VAL_3", "PK_ATTR_4", "PK_VAL_4", "PK_ATTR_5", "PK_VAL_5", "PK_ATTR_6", "PK_VAL_6", "PK_ATTR_7", "PK_VAL_7", "PK_ATTR_8", "PK_VAL_8", "PK_ATTR_9", "PK_VAL_9", "PK_ATTR_10", "PK_VAL_10", "ACTIVE", "DESCRIPTION", "LAST_TRANSFER", "LAST_TRANSFER_WRITE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_trans_config_jn
--
-- $Revision: 1.1.118.1 $
--
--  Purpose:
--  Note:
--
--  When       Who Why
--  ---------- --- --------
SELECT M.jn_operation,
       M.jn_oracle_user,
       M.jn_datetime,
       M.jn_notes,
       M.jn_appln,
       M.jn_session,
       M.mapping_no,
       M.TEMPLATE_no,
       (SELECT TEMPLATE_CODE FROM TRANS_TEMPLATE T WHERE T.TEMPLATE_NO = M.TEMPLATE_NO) TEMPLATE_CODE,
       M.SOURCE_ID,
       M.TAG_ID,
       M.FROM_UNIT,
       M.TO_UNIT,
       M.DATA_CLASS,
       M.ATTRIBUTE,
       M.PK_ATTR_1,
       M.PK_VAL_1,
       M.PK_ATTR_2,
       M.PK_VAL_2,
       M.PK_ATTR_3,
       M.PK_VAL_3,
       M.PK_ATTR_4,
       M.PK_VAL_4,
       M.PK_ATTR_5,
       M.PK_VAL_5,
       M.PK_ATTR_6,
       M.PK_VAL_6,
       M.PK_ATTR_7,
       M.PK_VAL_7,
       M.PK_ATTR_8,
       M.PK_VAL_8,
       M.PK_ATTR_9,
       M.PK_VAL_9,
       M.PK_ATTR_10,
       M.PK_VAL_10,
       M.ACTIVE,
       M.DESCRIPTION,
       NULL LAST_TRANSFER,
       NULL LAST_TRANSFER_WRITE,
       M.RECORD_STATUS,
       M.CREATED_BY,
       M.CREATED_DATE,
       M.LAST_UPDATED_BY,
       M.LAST_UPDATED_DATE,
       M.REV_NO,
       M.REV_TEXT
  FROM TRANS_MAPPING_JN M
)