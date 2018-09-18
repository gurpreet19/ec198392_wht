CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CURVE" ("PERF_CURVE_ID", "CURVE_OBJECT_ID", "DAYTIME", "CURVE_PURPOSE", "CURVE_PARAMETER_CODE", "PERF_CURVE_STATUS", "PLANE_INTERSECT_CODE", "POTEN_2ND_VALUE", "POTEN_3RD_VALUE", "COMMENTS", "CGR", "GOR", "MAX_ALLOW_WH_PRESS", "MIN_ALLOW_WH_PRESS", "WGR", "WATERCUT_PCT", "CLASS_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "CURVE_Z_VALUE", "CURVE_PHASE", "CURVE_FORMULA_TYPE", "CURVE_C0", "CURVE_C1", "CURVE_C2", "CURVE_C3", "CURVE_C4", "CURVE_Y_VALID_FROM", "CURVE_Y_VALID_TO", "CURVE_COMMENTS", "CURVE_VALUE_1", "CURVE_VALUE_2", "CURVE_VALUE_3", "CURVE_VALUE_4", "CURVE_VALUE_5", "CURVE_VALUE_6", "CURVE_VALUE_7", "CURVE_VALUE_8", "CURVE_VALUE_9", "CURVE_VALUE_10", "CURVE_TEXT_1", "CURVE_TEXT_2", "CURVE_TEXT_3", "CURVE_TEXT_4", "CURVE_RECORD_STATUS", "CURVE_CREATED_BY", "CURVE_CREATED_DATE", "CURVE_LAST_UPDATED_BY", "CURVE_LAST_UPDATED_DATE", "CURVE_REV_NO", "CURVE_REV_TEXT", "CURVE_APPROVAL_BY", "CURVE_APPROVAL_DATE", "CURVE_APPROVAL_STATE", "CURVE_REC_ID") AS 
  (
-------------------------------------------------------------------------------------
--  v_curve
--
-- $Revision: 1.2 $
--
--  Purpose:   Used to load new performance curve from EXCEL or external sources.
--
--  Note:
--
--  Created by: Mahanim
-------------------------------------------------------------------------------------
SELECT  pc.perf_curve_id,
        pc.curve_object_id,
        pc.daytime,
        pc.curve_purpose,
        pc.curve_parameter_code,
        pc.perf_curve_status,
        pc.plane_intersect_code,
        pc.poten_2nd_value,
        pc.poten_3rd_value,
        pc.comments,
        pc.cgr,
        pc.gor,
        pc.max_allow_wh_press,
        pc.min_allow_wh_press,
        pc.wgr,
        pc.watercut_pct,
        pc.class_name,
        pc.record_status,
        pc.created_by,
        pc.created_date,
        pc.last_updated_by,
        pc.last_updated_date,
        pc.rev_no,
        pc.rev_text,
        pc.approval_by,
        pc.approval_date,
        pc.approval_state,
        pc.rec_id,
        c.z_value AS curve_z_value,
        c.phase AS curve_phase,
        c.formula_type AS curve_formula_type,
        c.c0 AS curve_c0,
        c.c1 AS curve_c1,
        c.c2 AS curve_c2,
        c.c3 AS curve_c3,
        c.c4 AS curve_c4,
        c.y_valid_from AS curve_y_valid_from,
        c.y_valid_to AS curve_y_valid_to,
        c.comments AS curve_comments,
        c.value_1 AS curve_value_1,
        c.value_2 AS curve_value_2,
        c.value_3 AS curve_value_3,
        c.value_4 AS curve_value_4,
        c.value_5 AS curve_value_5,
        c.value_6 AS curve_value_6,
        c.value_7 AS curve_value_7,
        c.value_8 AS curve_value_8,
        c.value_9 AS curve_value_9,
        c.value_10 AS curve_value_10,
        c.text_1 AS curve_text_1,
        c.text_2 AS curve_text_2,
        c.text_3 AS curve_text_3,
        c.text_4 AS curve_text_4,
        c.record_status AS curve_record_status,
        c.created_by AS curve_created_by,
        c.created_date AS curve_created_date,
        c.last_updated_by AS curve_last_updated_by,
        c.last_updated_date AS curve_last_updated_date,
        c.rev_no AS curve_rev_no,
        c.rev_text AS curve_rev_text,
        c.approval_by AS curve_approval_by,
        c.approval_date AS curve_approval_date,
        c.approval_state AS curve_approval_state,
        c.rec_id AS curve_rec_id
  FROM performance_curve pc,
       curve c
 WHERE pc.perf_curve_id = c.perf_curve_id
)