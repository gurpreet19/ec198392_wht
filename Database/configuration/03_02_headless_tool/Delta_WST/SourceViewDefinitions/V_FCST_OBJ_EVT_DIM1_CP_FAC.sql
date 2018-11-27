CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_OBJ_EVT_DIM1_CP_FAC" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "DIM1_KEY", "COMPONENT_NO", "COMPONENT_NAME", "FRAC", "CLASS_NAME", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REC_ID", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_obj_dim1_cp_rec_fac.sql
-- View name: v_fcst_obj_dim1_cp_rec_fac
--
-- $Revision: 1.1 $
--
-- Purpose  : Use as source for classes used to present period factor numbers per component per product as a cross tab in forecast version
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  ----------------------------------------------------------------------------
-- 18.08.2014 leeeewei  ECPD-28347: Initial version
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.forecast_id,
	   f.dim1_key,
       f.component_no,
       ec_hydrocarbon_component.name(f.component_no) component_name,
       f.frac,
       f.class_name,
       l.sort_order,
       f.record_status,
       f.created_by,
       f.created_date,
       f.last_updated_by,
       f.last_updated_date,
       f.rev_no,
       f.rec_id,
       f.rev_text
  FROM fcst_obj_evt_dim1_cp_fac f, comp_set_list l
 WHERE f.component_no = l.component_no
   AND l.component_set = 'COMP_TRAN_FACTOR'
)