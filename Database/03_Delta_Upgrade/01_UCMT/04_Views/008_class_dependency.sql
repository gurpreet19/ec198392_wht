CREATE MATERIALIZED VIEW class_dependency 
-------------------------------------------------------------------------------------
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
( select
  c.parent_class
, c.child_class
, c.dependency_type
, c.record_status
, c.created_by
, c.created_date
, c.last_updated_by
, c.last_updated_date
, c.rev_no
, c.rev_text
, c.approval_state
, c.approval_by
, c.approval_date
, c.rec_id
from class_dependency_cnfg  c
inner join class_cnfg cc on cc.class_name = c.child_class and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
inner join class_cnfg pc on pc.class_name = c.parent_class and ec_install_constants.isBlockedAppSpaceCntx(pc.app_space_cntx) = 0
);

-- TODO: 
-- TODO: create unique index uix_class_dependency on Class_dependency(parent_class,child_class,dependency_type)
-- TODO: TABLESPACE &ts_index
-- TODO: /
-- TODO: 

PROMPT Creating Index 'IFK_CLASS_DEPENDENCY_2'
CREATE INDEX IFK_CLASS_DEPENDENCY_2 ON CLASS_DEPENDENCY
 (CHILD_CLASS)
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

PROMPT Creating Index 'IR_CLASS_DEPENDENCY'
CREATE INDEX IR_CLASS_DEPENDENCY ON CLASS_DEPENDENCY
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

