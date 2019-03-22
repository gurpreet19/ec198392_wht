CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OBJECT_LIST_SETUP_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "GENERIC_OBJECT_CODE", "GENERIC_CLASS_NAME", "RELATIONAL_OBJ_CODE", "RELATION_CLASS", "DAYTIME", "END_DATE", "SPLIT_SHARE", "SORT_ORDER", "GEN_REL_OBJ_CODE", "COMMENTS", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "OBJ_ID", "SELECTED_BY_USER_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_OBJECT_LIST_SETUP_HIST.sql
-- View name: V_OBJECT_LIST_SETUP_HIST
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 14.09.2016 lewisbra
-- 15.05.2018 fladebre   Expanded inner star-notation to enhance upgrade compatibility.
--                       Changed from "Including" to "To" based "end-date" handling for historical/journal rows by adding 1 sec to the CURRENT rows.
----------------------------------------------------------------------------------------------------
SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","GENERIC_OBJECT_CODE","GENERIC_CLASS_NAME","RELATIONAL_OBJ_CODE","RELATION_CLASS","DAYTIME","END_DATE","SPLIT_SHARE","SORT_ORDER","GEN_REL_OBJ_CODE","COMMENTS","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","TEXT_1","TEXT_2","TEXT_3","TEXT_4","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","OBJ_ID","SELECTED_BY_USER_ID","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID"
FROM (
        SELECT
            'CURRENT' "JN_OPERATION"
            ,NVL(last_updated_by,created_by) "JN_ORACLE_USER"
            ,Ecdp_Timestamp.getCurrentSysdate + INTERVAL '1' SECOND "JN_DATETIME"
            ,'CURRENT' "JN_NOTES"
            ,NULL "JN_APPLN"
            ,NULL "JN_SESSION"
            ,"OBJECT_ID"
            ,"GENERIC_OBJECT_CODE"
            ,"GENERIC_CLASS_NAME"
            ,"RELATIONAL_OBJ_CODE"
            ,"RELATION_CLASS"
            ,"DAYTIME"
            ,"END_DATE"
            ,"SPLIT_SHARE"
            ,"SORT_ORDER"
            ,"GEN_REL_OBJ_CODE"
            ,"COMMENTS"
            ,"VALUE_1"
            ,"VALUE_2"
            ,"VALUE_3"
            ,"VALUE_4"
            ,"VALUE_5"
            ,"VALUE_6"
            ,"VALUE_7"
            ,"VALUE_8"
            ,"VALUE_9"
            ,"VALUE_10"
            ,"TEXT_1"
            ,"TEXT_2"
            ,"TEXT_3"
            ,"TEXT_4"
            ,"DATE_1"
            ,"DATE_2"
            ,"DATE_3"
            ,"DATE_4"
            ,"DATE_5"
            ,"OBJ_ID"
            ,"SELECTED_BY_USER_ID"
            ,"RECORD_STATUS"
            ,"CREATED_BY"
            ,"CREATED_DATE"
            ,"LAST_UPDATED_BY"
            ,"LAST_UPDATED_DATE"
            ,"REV_NO"
            ,"REV_TEXT"
            ,"APPROVAL_BY"
            ,"APPROVAL_DATE"
            ,"APPROVAL_STATE"
            ,"REC_ID"
        FROM OBJECT_LIST_SETUP
        UNION
        SELECT
             "JN_OPERATION"
            ,"JN_ORACLE_USER"
            ,"JN_DATETIME"
            ,"JN_NOTES"
            ,"JN_APPLN"
            ,"JN_SESSION"
            ,"OBJECT_ID"
            ,"GENERIC_OBJECT_CODE"
            ,"GENERIC_CLASS_NAME"
            ,"RELATIONAL_OBJ_CODE"
            ,"RELATION_CLASS"
            ,"DAYTIME"
            ,"END_DATE"
            ,"SPLIT_SHARE"
            ,"SORT_ORDER"
            ,"GEN_REL_OBJ_CODE"
            ,"COMMENTS"
            ,"VALUE_1"
            ,"VALUE_2"
            ,"VALUE_3"
            ,"VALUE_4"
            ,"VALUE_5"
            ,"VALUE_6"
            ,"VALUE_7"
            ,"VALUE_8"
            ,"VALUE_9"
            ,"VALUE_10"
            ,"TEXT_1"
            ,"TEXT_2"
            ,"TEXT_3"
            ,"TEXT_4"
            ,"DATE_1"
            ,"DATE_2"
            ,"DATE_3"
            ,"DATE_4"
            ,"DATE_5"
            ,"OBJ_ID"
            ,"SELECTED_BY_USER_ID"
            ,"RECORD_STATUS"
            ,"CREATED_BY"
            ,"CREATED_DATE"
            ,"LAST_UPDATED_BY"
            ,"LAST_UPDATED_DATE"
            ,"REV_NO"
            ,"REV_TEXT"
            ,"APPROVAL_BY"
            ,"APPROVAL_DATE"
            ,"APPROVAL_STATE"
            ,"REC_ID"
        FROM OBJECT_LIST_SETUP_JN
    )
)