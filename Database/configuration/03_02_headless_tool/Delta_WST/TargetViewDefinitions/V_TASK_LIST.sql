CREATE OR REPLACE FORCE VIEW "V_TASK_LIST" ("TASK_NO", "TASK_TYPE", "TASK_PROCESS_ID", "TASK_CLASS", "SORT_ORDER", "DESCRIPTION", "BUSINESS_FUNCTION_NO", "TASK_DUE_DATE", "TASK_STATUS", "RESPONSIBLE", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  select
 t.TASK_NO
,t.TASK_TYPE
,t.TASK_PROCESS_ID
,td.class_name AS TASK_CLASS
,t.SORT_ORDER
,LTRIM(Nvl(t.task_description,' ')||' '||Nvl(c.label,c.class_name) ||' ('||TO_CHAR(count(*))||' records )') description
,t.BUSINESS_FUNCTION_NO
,t.TASK_DUE_DATE
,t.task_STATUS
,t.RESPONSIBLE
,t.COMMENTS
,t.RECORD_STATUS
,t.CREATED_BY
,t.CREATED_DATE
,t.LAST_UPDATED_BY
,t.LAST_UPDATED_DATE
,t.REV_NO
,t.REV_TEXT
,t.APPROVAL_BY
,t.APPROVAL_DATE
,t.APPROVAL_STATE
,t.REC_ID
FROM  TASK T, TASK_DETAIL td, class c, V_APPROVALRECORDS ar
where t.task_no = td.task_no
AND   td.class_name = c.class_name
AND   td.RECORD_REF_ID = ar.rec_id
and   t.task_type = 'APPROVAL'
GROUP by  t.TASK_NO
,t.TASK_TYPE
,t.TASK_PROCESS_ID
,td.class_name
,t.task_description
,Nvl(c.label,c.class_name)
,t.SORT_ORDER
,td.class_name
,t.BUSINESS_FUNCTION_NO
,t.TASK_DUE_DATE
,t.task_STATUS
,t.RESPONSIBLE
,t.COMMENTS
,t.RECORD_STATUS
,t.CREATED_BY
,t.CREATED_DATE
,t.LAST_UPDATED_BY
,t.LAST_UPDATED_DATE
,t.REV_NO
,t.REV_TEXT
,t.APPROVAL_BY
,t.APPROVAL_DATE
,t.APPROVAL_STATE
,t.REC_ID
UNION ALL
select
 t.TASK_NO
,t.TASK_TYPE
,t.TASK_PROCESS_ID
,NULL AS TASK_CLASS
,t.SORT_ORDER
,t.task_description ||' (run at '||TO_CHAR(t.created_date,'yyyy-mm-dd hh24:mi:ss')||' by '||t.created_by||')'   description
,t.BUSINESS_FUNCTION_NO
,t.TASK_DUE_DATE
,t.task_STATUS
,t.RESPONSIBLE
,t.COMMENTS
,t.RECORD_STATUS
,t.CREATED_BY
,t.CREATED_DATE
,t.LAST_UPDATED_BY
,t.LAST_UPDATED_DATE
,t.REV_NO
,t.REV_TEXT
,t.APPROVAL_BY
,t.APPROVAL_DATE
,t.APPROVAL_STATE
,t.REC_ID
FROM  TASK T
WHERE   t.task_type IN ('CP_ERROR','CP_WARNING')
AND EXISTS (
     SELECT 1
     FROM TASK_DETAIL TD
where t.task_no = td.task_no
AND   ecdp_approval.hasRowAccess(td.class_name,td.record_ref_id) = 'Y'
     )
UNION ALL
select
 t.TASK_NO
,t.TASK_TYPE
,t.TASK_PROCESS_ID
,NULL AS TASK_CLASS
,t.SORT_ORDER
,t.task_description description
,t.BUSINESS_FUNCTION_NO
,t.TASK_DUE_DATE
,t.task_STATUS
,t.RESPONSIBLE
,t.COMMENTS
,t.RECORD_STATUS
,t.CREATED_BY
,t.CREATED_DATE
,t.LAST_UPDATED_BY
,t.LAST_UPDATED_DATE
,t.REV_NO
,t.REV_TEXT
,t.APPROVAL_BY
,t.APPROVAL_DATE
,t.APPROVAL_STATE
,t.REC_ID
FROM  TASK T
WHERE  t.task_type NOT IN ('APPROVAL','CP_ERROR','CP_WARNING')