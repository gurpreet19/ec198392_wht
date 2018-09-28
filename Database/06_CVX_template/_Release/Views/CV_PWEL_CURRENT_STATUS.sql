---------------------------------------------------------------------------------------------------
--  CV_PWEL_CURRENT_STATUS
--
--  Purpose:           Provides most current well master detail for producing wells at any period in time
--
--
--  Notes:
--
--      MVAS 02/2006     Duplicated V_RE_PWEL_PERIOD_STATUS 
--             Modified to use ec_pwel_period_status.prev_equal_daytime rather than prev_daytime
--             Modified to exclude OV_WELL columns not on ECKERNEL_TEST:  
--                 AUMA_CHOKE, FIXED_CHOKE, MIN_PROD_RATE, NODE_TYPE, ALLOC_SEQ, 
--                 OP_WELL_HOLE_ID, OP_WELL_HOLE_CODE
--             Modified to include OV_WELL columns not in original script, needed for report:  
--                 OP_AREA_ID, OP_AREA_CODE, OP_SUB_AREA_ID, OP_SUB_AREA_CODE, 
--                 OP_FCTY_2_ID, OP_FCTY_2_CODE
--    MVAS 06/2006    Updated for new Geographic Navigation
--    MVAS 08/2006    Modified to retrieve only last record when more than one per day exists 
--            in DV_PWEL_PERIOD_STATUS (DAYTIME includes time)
--      HNKO 08/2008    Changed to hit to the base tables rather than DV_PWEL_PERIOD_STATUS. 
--
--
---------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW CV_PWEL_CURRENT_STATUS
 AS  SELECT 'WELL' AS owner_class_name, 'PWEL_PERIOD_STATUS' AS data_class_name,
          o.object_id AS object_id, o.object_code AS code, oa.NAME AS NAME,
          o.start_date AS object_start_date,
          o.end_date AS object_end_date, s.daytime AS production_day,
          pwel_period_status.daytime AS daytime, TO_CHAR ('WELL') AS node_class_name,
          oa.well_class AS well_class, oa.well_type AS well_type,
          oa.prod_method AS prod_method, oa.calc_method AS calc_method,
          oa.potential_method AS potential_method,
          oa.well_test_method AS well_test_method,
          o.description AS description,
          oa.alloc_fixed_gor AS alloc_fixed_gor,
          oa.alloc_fixed_wc AS alloc_fixed_wc, oa.value_1 AS top_depth,
          oa.alloc_flag AS alloc_flag, TO_CHAR ('N') AS can_proc_oil,
          oa.text_1 AS well_uid, TO_CHAR ('N') AS can_proc_gas,
          TO_CHAR ('N') AS can_proc_wat,
          TO_CHAR ('N') AS can_proc_gaslift,
          TO_CHAR ('N') AS can_proc_gasinj,
          TO_CHAR ('N') AS can_proc_watinj,
          oa.diagram_layout_info AS diagram_layout_info,
--          oa.poten_2nd_value AS poten_2nd_value,
--          oa.poten_3rd_value AS poten_3rd_value,
          oa.choke_uom AS choke_uom,
          oa.std_oil_density_method AS std_oil_density_method,
          oa.std_gas_density_method AS std_gas_density_method,
          --OV.CALC_METHOD_MASS AS CALC_METHOD_MASS,
          o.well_hole_id AS well_hole_id,
          ec_well_hole.object_code (o.well_hole_id) AS well_hole_code, 
          oa.op_area_id AS op_area_id,
          oa.op_area_code AS op_area_code,
          oa.op_sub_area_id AS op_sub_area_id,
          oa.op_sub_area_code AS op_sub_area_code,
          oa.op_fcty_class_1_id AS op_fcty_1_id,
          oa.op_fcty_class_1_code AS op_fcty_1_code,
          oa.op_fcty_class_2_id AS op_fcty_2_id,
          oa.op_fcty_class_2_code AS op_fcty_2_code,
          oa.group_ref_id_1 AS geo_country_id,
          oa.group_ref_code_1 AS geo_country_code,
          oa.group_ref_id_2 AS geo_region_id,
          oa.group_ref_code_2 AS geo_region_code,
          oa.group_ref_id_6 AS geo_licence_id,
          oa.group_ref_code_6 AS geo_licence_code,
          oa.geo_field_id AS geo_field_id,
          oa.geo_field_code AS geo_field_code, 
          pwel_period_status.well_status AS well_status,
          ec_prosty_codes.description (pwel_period_status.well_status,
                                       'WELL_STATUS'
                                      ) AS well_status_desc,
          pwel_period_status.comments AS comments, pwel_period_status.time_span AS time_span,
          pwel_period_status.summer_time AS summer_time, pwel_period_status.active_well_status AS active_status,
          pwel_period_status.record_status AS record_status, pwel_period_status.created_by AS created_by,
          pwel_period_status.created_date AS created_date,
          pwel_period_status.last_updated_by AS last_updated_by,
          pwel_period_status.last_updated_date AS last_updated_date, pwel_period_status.rev_no AS rev_no,
          pwel_period_status.rev_text AS rev_text
     FROM system_days s, pwel_period_status, well_version oa, well o
    WHERE s.daytime >= oa.daytime
      AND (s.daytime < oa.end_date OR oa.end_date IS NULL)
      AND (s.daytime < o.end_date OR o.end_date IS NULL)
      AND oa.object_id=o.object_id
      AND o.object_id = pwel_period_status.object_id
      AND pwel_period_status.daytime <
                             NVL (oa.end_date, pwel_period_status.daytime + 1)
      AND pwel_period_status.day =
             TRUNC (ec_pwel_period_status.prev_equal_daytime (o.object_id,
                                                              s.daytime,
                                                              'EVENT'
                                                             ),
                    'DD'
                   )
      AND pwel_period_status.daytime IN (SELECT   MAX (dv1.daytime)
                             FROM dv_pwel_period_status dv1,well_version oa,well o
                            WHERE dv1.objecT_id=oa.object_id
                            AND 
                            dv1.object_id = pwel_period_status.object_id
                         GROUP BY TRUNC (dv1.daytime, 'dd'));
