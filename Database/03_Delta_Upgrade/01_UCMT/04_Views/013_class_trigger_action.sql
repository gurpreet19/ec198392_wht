CREATE MATERIALIZED VIEW class_trigger_action 
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
with class_tra_property_max as(
  select p1.class_name, p1.triggering_event, p1.trigger_type, p1.sort_order, p1.property_code, p1.property_value
  from class_tra_property_cnfg p1, class_cnfg cc
  where cc.class_name=p1.class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and   owner_cntx = (
        select max(owner_cntx)
        from class_tra_property_cnfg p1_1
        where p1.class_name = p1_1.class_name
        and   p1.triggering_event = p1_1.triggering_event
        and   p1.trigger_type = p1_1.trigger_type
        and p1.sort_order = p1_1.sort_order
        )
)
select
 c.CLASS_NAME
,c.TRIGGERING_EVENT
,c.TRIGGER_TYPE
,c.SORT_ORDER
,c.DB_SQL_SYNTAX
,c.app_space_cntx as CONTEXT_CODE
,cast(p1.property_value as varchar2(4000)) as description
,cast(p2.property_value as varchar2(1)) as disabled_ind
,c.RECORD_STATUS
,c.CREATED_BY
,c.CREATED_DATE
,c.LAST_UPDATED_BY
,c.LAST_UPDATED_DATE
,c.REV_NO
,c.REV_TEXT
,c.APPROVAL_BY
,c.APPROVAL_DATE
,c.APPROVAL_STATE
,c.REC_ID
from class_trigger_actn_cnfg  c
inner join class_cnfg cc on cc.class_name = c.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_tra_property_max p1 on (c.class_name = p1.class_name and c.triggering_event = p1.triggering_event and c.trigger_type = p1.trigger_type and c.sort_order = p1.sort_order and p1.property_code = 'DESCRIPTION' )
left join class_tra_property_max p2 on (c.class_name = p2.class_name and c.triggering_event = p2.triggering_event and c.trigger_type = p2.trigger_type and c.sort_order = p2.sort_order and p2.property_code = 'DISABLED_IND' );

create unique index uix_class_trigger_action on class_trigger_action(class_name,triggering_event,trigger_type,sort_order)
TABLESPACE &ts_index
/


PROMPT Creating Index 'IR_CLASS_TRIGGER_ACTION'
CREATE INDEX IR_CLASS_TRIGGER_ACTION ON CLASS_TRIGGER_ACTION
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
