CREATE OR REPLACE FORCE EDITIONABLE VIEW "TRANS_TARGET_TAG" ("SOURCE_ID", "TARGET_TAGID", "FACILITY", "FROM_UNIT", "TO_UNIT", "TARGET_INTERVAL", "TARGET_INTERVAL_TIME", "TARGET_DELAY", "TARGET_FUNCTION", "TARGET_DATATYPE", "TARGET_TABLE", "PRIM_KEY", "PRIM_KEY_VALUES", "TARGET_COLUMN", "TARGET_DATETIME", "TARGET_WHERE", "USE_DAYTIME", "USE_SUMMERTIME", "ONCE_A_DAY", "TARGET_SUMMERTIME", "TARGET_SUMMERTIME_TRUE", "TARGET_SUMMERTIME_FALSE", "VALID", "ACTIVE", "TARGET_TABLE_ID", "ID_TYPE", "INSERT_METHOD", "UPDATE_WHERE", "UPDATE_STATEMENT", "USER_FIELD1", "USER_FIELD2", "BEFORE_TRANS_PROC", "AFTER_TRANS_PROC", "TARGET_FACTOR", "TARGET_TIME_CORRECTION", "TARGET_LOW_BOUNDARY", "TARGET_HIGH_BOUNDARY", "TARGET_NUMBER", "TARGET_TRUNCATE", "RULE_NUMBER", "DEBUG_ON", "UNIT_CONVERT", "OVERWRITE_USER", "OVERWRITE_STATUS", "PROD_DAY_START", "DESCRIPTION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  trans_target_tag
--
-- $Revision: 1.3 $
--
--  Purpose:   Provides a view on top of trans_mapping and trans_template, extracting information
--             corresponding to the old trans_target_tag table
--
--  Note:
--
--  When       Who Why
--  ---------- --- --------
--  05.03.2005 AV  New object storage structure, change in EcDp_Objects.GetObjCode
-----------------------------------------------------------------------------------
SELECT --'EC',
        M.SOURCE_ID,
        M.TAG_ID,
        'NA',
        M.FROM_UNIT,
        M.TO_UNIT,
        T.TARGET_INTERVAL,
        'START',
        NULL,
        T.TARGET_FUNCTION,
        T.TARGET_DATATYPE,
        Ec_Class_Cnfg.db_object_name(M.DATA_CLASS),
        transfer_web_util.getPrimKey(m.mapping_no),
        transfer_web_util.getPrimKeyValues(m.mapping_no),
        Ec_Class_Attribute_Cnfg.db_sql_syntax(M.DATA_CLASS,M.ATTRIBUTE),
        T.TARGET_DATETIME,
        T.TARGET_WHERE,
        T.USE_DAYTIME,
        T.USE_SUMMERTIME,
        NULL,
        T.TARGET_SUMMERTIME,
        T.TARGET_SUMMERTIME_TRUE,
        T.TARGET_SUMMERTIME_FALSE,
        M.VALID,
        M.ACTIVE,
        EcDp_Objects.GetObjCode(m.pk_val_1),
        Ec_Class_Cnfg.owner_class_name(m.data_class),
        'INSERT',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        T.TARGET_TIME_CORRECTION,
        T.TARGET_LOW_BOUNDARY,
        T.TARGET_HIGH_BOUNDARY,
        NULL,
        T.TARGET_TRUNCATE,
        NULL,
        NULL,
        NULL,
        T.OVERWRITE_USER,
        T.OVERWRITE_STATUS,
        T.PROD_DAY_START,
        M.DESCRIPTION,
        M.RECORD_STATUS,
        M.CREATED_BY,
        M.CREATED_DATE,
        M.LAST_UPDATED_BY,
        GREATEST(NVL(T.LAST_UPDATED_DATE,T.CREATED_DATE),NVL(M.LAST_UPDATED_DATE,M.CREATED_DATE)),
        M.REV_NO,
        M.REV_TEXT
   FROM TRANS_MAPPING M,
        TRANS_TEMPLATE T
  WHERE M.TEMPLATE_NO = T.TEMPLATE_NO
)