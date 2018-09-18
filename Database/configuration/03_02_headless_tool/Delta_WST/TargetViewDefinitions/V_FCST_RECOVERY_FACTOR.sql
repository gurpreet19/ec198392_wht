CREATE OR REPLACE FORCE VIEW "V_FCST_RECOVERY_FACTOR" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "COMPONENT_NO", "COMPONENT_NAME", "FRAC", "CLASS_NAME", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REC_ID", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_recovery_factor.sql
-- View name: v_fcst_recovery_factor
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  : Use as source for classes used to present period factor numbers per component as a cross tab in forecast version
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  ----------------------------------------------------------------------------
-- 10.05.2013 farhaann  ECPD-19505: Initial version
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.forecast_id,
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
  FROM fcst_recovery_factor f, comp_set_list l
 WHERE f.component_no = l.component_no
   AND l.component_set = 'COMP_TRAN_FACTOR'
)