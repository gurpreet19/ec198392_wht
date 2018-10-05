CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OBJECT_LIST_UPLOAD" ("LIST_CLASS", "LIST_ACTION", "OBJECT_LIST_CODE", "START_DATE", "END_DATE", "OBJECT_LIST_NAME", "OBJ_LIST_DESC", "REVISION_DATE", "REVISION_END_DATE", "OBJECT_ACTION", "GENERIC_OBJECT_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "OBJECT_CODE", "OBJECT_START_DATE", "OBJECT_END_DATE", "EC_CODE", "OBJECT_NAME", "FIN_CODE", "OBJ_DESCR") AS 
  WITH LIST  AS
(
SELECT
olv.class_name list_class,
'INSERT/UPDATE/NOACTION' List_action, --No Action,
ol.object_code as object_list_code,
ol.start_date as start_date,
ol.end_date as end_date,
olv.name object_list_name,
ol.description obj_list_desc,
ols.daytime revision_date,
ols.end_date revision_end_date,
'INSERT/UPDATE/NOACTION' object_action,
ols.generic_object_code,
ol.RECORD_STATUS,
ol.CREATED_BY,
ol.CREATED_DATE,
ol.LAST_UPDATED_BY,
ol.LAST_UPDATED_DATE,
ol.REV_NO,
ol.REV_TEXT,
ol.APPROVAL_BY,
ol.APPROVAL_DATE,
ol.APPROVAL_STATE
from
object_list_version olv,
object_list ol,
object_list_setup ols,
( SELECT MAX(daytime) daytime, object_id FROM object_list_version GROUP BY object_id )max_olv
where
  ol.object_id = olv.object_id
  and ol.object_id = ols.object_id
	AND ol.object_id = max_olv.object_id
	AND olv.daytime = max_olv.daytime
  AND olv.class_name IN ('FIN_WBS', 'FIN_ACCOUNT','FIN_COST_CENTER','FIN_REVENUE_ORDER')
),
WBS_OBJECT AS
(SELECT
    o.object_code  object_code,
    o.start_date object_start_date,
    o.end_date object_end_date,
    o.object_code ec_code,
    ov.name object_name,
    ov.Wbs fin_code,
    o.description Obj_Descr
FROM
    fin_wbs o,
    fin_wbs_version ov
WHERE o.object_id = ov.object_id
),
FIN_ACT_OBJECT AS
(SELECT
    o.object_code  object_code,
    o.start_date object_start_date,
    o.end_date object_end_date,
    o.object_code ec_code,
    ov.name object_name,
    ov.GL_ACCOUNT fin_code,
    o.description Obj_Descr
FROM
    fin_ACCOUNT o,
    fin_account_version ov
WHERE o.object_id = ov.object_id
),
FIN_COST_OBJECT AS
(SELECT
    o.object_code  object_code,
    o.start_date object_start_date,
    o.end_date object_end_date,
    o.object_code ec_code,
    ov.name object_name,
    ov.COST_CENTER fin_code,
    o.description Obj_Descr
FROM
    fin_cost_center o,
    fin_cost_center_version ov
WHERE o.object_id = ov.object_id
),
REVN_ORDER AS
(
SELECT
    o.object_code  object_code,
    o.start_date object_start_date,
    o.end_date object_end_date,
    o.object_code ec_code,
    ov.name object_name,
    ov.REVENUE_ORDER fin_code,
    o.description Obj_Descr
FROM
    fin_REVENUE_ORDER o,
    fin_REVENUE_ORDER_version ov
WHERE o.object_id = ov.object_id
)
SELECT "LIST_CLASS","LIST_ACTION","OBJECT_LIST_CODE","START_DATE","END_DATE","OBJECT_LIST_NAME","OBJ_LIST_DESC","REVISION_DATE","REVISION_END_DATE","OBJECT_ACTION","GENERIC_OBJECT_CODE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","OBJECT_CODE","OBJECT_START_DATE","OBJECT_END_DATE","EC_CODE","OBJECT_NAME","FIN_CODE","OBJ_DESCR"
FROM  LIST
JOIN WBS_OBJECT
ON   WBS_OBJECT.object_code = LIST.generic_object_code    AND
     LIST.list_class = 'FIN_WBS'
UNION
SELECT "LIST_CLASS","LIST_ACTION","OBJECT_LIST_CODE","START_DATE","END_DATE","OBJECT_LIST_NAME","OBJ_LIST_DESC","REVISION_DATE","REVISION_END_DATE","OBJECT_ACTION","GENERIC_OBJECT_CODE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","OBJECT_CODE","OBJECT_START_DATE","OBJECT_END_DATE","EC_CODE","OBJECT_NAME","FIN_CODE","OBJ_DESCR"
FROM  LIST
 JOIN FIN_ACT_OBJECT
ON   FIN_ACT_OBJECT.object_code = LIST.generic_object_code    AND
     LIST.list_class = 'FIN_ACCOUNT'
UNION
SELECT "LIST_CLASS","LIST_ACTION","OBJECT_LIST_CODE","START_DATE","END_DATE","OBJECT_LIST_NAME","OBJ_LIST_DESC","REVISION_DATE","REVISION_END_DATE","OBJECT_ACTION","GENERIC_OBJECT_CODE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","OBJECT_CODE","OBJECT_START_DATE","OBJECT_END_DATE","EC_CODE","OBJECT_NAME","FIN_CODE","OBJ_DESCR"
FROM  LIST
 JOIN FIN_COST_OBJECT
ON   FIN_COST_OBJECT.object_code = LIST.generic_object_code    AND
     LIST.list_class = 'FIN_COST_CENTER'
UNION
SELECT "LIST_CLASS","LIST_ACTION","OBJECT_LIST_CODE","START_DATE","END_DATE","OBJECT_LIST_NAME","OBJ_LIST_DESC","REVISION_DATE","REVISION_END_DATE","OBJECT_ACTION","GENERIC_OBJECT_CODE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","OBJECT_CODE","OBJECT_START_DATE","OBJECT_END_DATE","EC_CODE","OBJECT_NAME","FIN_CODE","OBJ_DESCR"
FROM  LIST
 JOIN REVN_ORDER
ON   REVN_ORDER.object_code = LIST.generic_object_code    AND
     LIST.list_class = 'FIN_REVENUE_ORDER'