CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_APPROVALRECORDS" ("CLASS_NAME", "REC_ID", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT -- Generated by EcDp_Approval 

'dummy','dummy', 'O', 'dummy',to_date(null)
,'P', 'dummy', Ecdp_Timestamp.getCurrentSysdate, 'dummy', Ecdp_Timestamp.getCurrentSysdate
, 0, 'dummy'
FROM ctrl_db_version
WHERE 1 = 0