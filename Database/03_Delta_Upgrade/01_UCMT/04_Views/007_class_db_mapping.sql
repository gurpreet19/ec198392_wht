CREATE MATERIALIZED VIEW class_db_mapping 
-------------------------------------------------------------------------------------
-- class_db_mapping
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
(
select
c.CLASS_NAME
,c.db_object_type
,c.db_object_owner
,c.db_object_name
,c.db_object_attribute
,c.db_where_condition
,c.RECORD_STATUS
,c.CREATED_BY
,c.CREATED_DATE
,c.LAST_UPDATED_BY
,c.LAST_UPDATED_DATE
,c.REV_NO
,c.REV_TEXT
,c.APPROVAL_STATE
,c.APPROVAL_BY
,c.APPROVAL_DATE
,c.REC_ID
from class_cnfg c
WHERE ec_install_constants.isBlockedAppSpaceCntx(c.app_space_cntx) = 0
);

-- TODO: create unique index uix_class_db_mapping on Class_db_mapping(Class_name)
-- TODO: TABLESPACE &ts_index
-- TODO: /


PROMPT Creating Index 'IR_CLASS_DB_MAPPING'
CREATE INDEX IR_CLASS_DB_MAPPING ON CLASS_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
/
