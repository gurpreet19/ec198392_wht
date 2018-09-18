CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OBJ_EVENT_CP_TRAN_FACTOR" ("OBJECT_ID", "DAYTIME", "COMPONENT_NO", "COMPONENT_NAME", "FRAC", "CLASS_NAME", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REC_ID", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_obj_event_cp_tran_factor.sql
-- View name: v_obj_event_cp_tran_factor
--
-- $Revision: 1.2 $
--
-- Purpose  : Use as source for classes used to present period factor numbers per component as a cross tab
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  ----------------------------------------------------------------------------
-- 22.02.2012 farhaann  ECPD-19517: Initial version
-- 27.02.2013 chooysie  ECPD-23338: Rec_id is missing in view V_OBJ_EVENT_CP_TRAN_FACTOR
----------------------------------------------------------------------------------------------------
SELECT c.object_id,
       c.daytime,
       c.component_no,
       ec_hydrocarbon_component.name(c.component_no) component_name,
       c.frac,
       c.class_name,
       l.sort_order,
       c.record_status,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date,
       c.rev_no,
	   c.rec_id,
       c.rev_text
  FROM obj_event_cp_tran_factor c, comp_set_list l
 WHERE c.component_no = l.component_no
   AND l.component_set = 'COMP_TRAN_FACTOR'
)