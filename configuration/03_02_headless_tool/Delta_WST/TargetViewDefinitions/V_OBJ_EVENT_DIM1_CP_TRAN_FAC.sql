CREATE OR REPLACE FORCE VIEW "V_OBJ_EVENT_DIM1_CP_TRAN_FAC" ("OBJECT_ID", "DAYTIME", "COMPONENT_NO", "COMPONENT_NAME", "FRAC", "CLASS_NAME", "DIM1_KEY", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REC_ID", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_obj_event_dim1_cp_tran_fac.sql
-- View name: v_obj_event_dim1_cp_tran_fac
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  : Use as source for classes used to present period product factor numbers per component as a cross tab
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  ----------------------------------------------------------------------------
-- 20.09.2013 leeeewei  ECPD-25332: Initial version
----------------------------------------------------------------------------------------------------
SELECT o.object_id,
       o.daytime,
       o.component_no,
       ec_hydrocarbon_component.name(o.component_no) component_name,
       o.frac,
       o.class_name,
	   o.dim1_key,
       l.sort_order,
       o.record_status,
       o.created_by,
       o.created_date,
       o.last_updated_by,
       o.last_updated_date,
       o.rev_no,
	   o.rec_id,
       o.rev_text
  FROM obj_event_dim1_cp_tran_fac o, comp_set_list l
 WHERE o.component_no = l.component_no
   AND l.component_set = 'COMP_TRAN_FACTOR'
)