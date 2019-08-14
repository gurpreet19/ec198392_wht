 CREATE OR REPLACE  VIEW CV_PWEL_MTH_ALLOC as 
 SELECT
          pwel_mth_alloc.OBJECT_ID AS OBJECT_ID,
          pwel_mth_alloc.DAYTIME AS PRODUCTION_MTH,
          pwel_mth_alloc.ALLOC_GAS_ENERGY,
          o.object_code AS CODE,
          oa.name AS NAME,
          o.start_date AS OBJECT_START_DATE,
          o.end_date AS OBJECT_END_DATE,
          TO_CHAR ('WELL') AS NODE_CLASS_NAME,
          NVL (
             Ue_Stream_Node_Diagram.label (o.OBJECT_ID, oa.DAYTIME, 'WELL'),
             o.OBJECT_CODE)
             AS SND_LABEL,
          o.description AS DESCRIPTION,
          oa.text_1 AS WELL_UID,
          oa.value_1 AS TOP_DEPTH,
          oa.well_class AS WELL_CLASS,
          oa.well_type AS WELL_TYPE,
          oa.prod_method AS PROD_METHOD,
          oa.pump_type AS PUMP_TYPE,
          oa.well_meter_freq AS WELL_METER_FREQ,
          oa.instrumentation_type AS INSTRUMENTATION_TYPE,
          NULL AS DAY_METHOD_LABEL,
          oa.gas_lift_method AS GAS_LIFT_METHOD,
          oa.diluent_method AS DILUENT_METHOD,
          ecdp_performance_test.
          getResultDataClassName (o.object_id, oa.daytime)
             AS PT_RESDATA_CLASS,
          oa.calc_method AS CALC_METHOD,
          oa.calc_method_mass AS CALC_METHOD_MASS,
          oa.calc_inj_method AS CALC_INJ_METHOD,
          oa.calc_water_inj_method AS CALC_WATER_INJ_METHOD,
          oa.calc_steam_inj_method AS CALC_STEAM_INJ_METHOD,
          oa.gi_event_inj_data_method AS GI_EVENT_INJ_DATA_METHOD,
          oa.wi_event_inj_data_method AS WI_EVENT_INJ_DATA_METHOD,
          oa.si_event_inj_data_method AS SI_EVENT_INJ_DATA_METHOD,
          oa.potential_method AS POTENTIAL_METHOD,
          oa.potential_mass_method AS POTENTIAL_MASS_METHOD,
          oa.potential_gas_inj_method AS POTENTIAL_GAS_INJ_METHOD,
          oa.pot_water_inj_method AS POT_WATER_INJ_METHOD,
          oa.pot_steam_inj_method AS POT_STEAM_INJ_METHOD,
          oa.on_strm_method AS ON_STREAM_METHOD,
          oa.bsw_vol_method AS BSW_VOL_METHOD,
          oa.gor_method AS GOR_METHOD,
          oa.cgr_method AS CGR_METHOD,
          oa.wgr_method AS WGR_METHOD,
          oa.sand_method AS SAND_METHOD,
          oa.wdf_method AS WDF_METHOD,
          NULL AS SUB_DAY_METHOD_LABEL,
          oa.calc_sub_day_method AS CALC_SUB_DAY_METHOD,
          oa.gas_lift_sub_day_method AS GAS_LIFT_SUB_DAY_METHOD,
          oa.diluent_sub_day_method AS DILUENT_SUB_DAY_METHOD,
          NULL AS OTHER_CONF_OPTS_LABEL,
          oa.well_test_method AS WELL_TEST_METHOD,
          oa.approach_method AS APPROACH_METHOD,
          NVL (
             ec_calc_rule_version.name (oa.WELL_CALC_RULE, oa.DAYTIME, '<='),
             ec_ctrl_system_attribute.
             attribute_text (oa.daytime, 'DEF_WELL_CALC_RULE', '<='))
             AS CALC_RULE_CODE,
          oa.well_calc_rule AS WELL_CALC_RULE,
          oa.alloc_fixed_gor AS ALLOC_FIXED_GOR,
          oa.alloc_fixed_wc AS ALLOC_FIXED_WC,
          NVL (
             WELL_CALC_RULE,
             ecdp_objects.
             GetObjIDFromCode (
                'CALC_RULE',
                ec_ctrl_system_attribute.
                attribute_text (oa.daytime, 'DEF_WELL_CALC_RULE', '<=')))
             AS CALC_RULE_ID,
          100 AS CALC_SEQ_NO,
          oa.alloc_flag AS ALLOC_FLAG,
          TO_CHAR ('N') AS CAN_PROC_OIL,
          TO_CHAR ('N') AS CAN_PROC_GAS,
          TO_CHAR ('N') AS CAN_PROC_WAT,
          TO_CHAR ('N') AS CAN_PROC_GASLIFT,
          TO_CHAR ('N') AS CAN_PROC_GASINJ,
          TO_CHAR ('N') AS CAN_PROC_WATINJ,
          TO_CHAR ('N') AS CAN_PROC_STEAMINJ,
          TO_CHAR ('N') AS CAN_PROC_COND,
          TO_CHAR ('N') AS CAN_PROC_DILUENT,
          oa.diagram_layout_info AS DIAGRAM_LAYOUT_INFO,
          oa.choke_uom AS CHOKE_UOM,
          oa.std_oil_density_method AS STD_OIL_DENSITY_METHOD,
          oa.std_gas_density_method AS STD_GAS_DENSITY_METHOD,
          oa.std_wat_density_method AS STD_WAT_DENSITY_METHOD,
          PROC_NODE_OIL_ID AS OP_NODE_ID,
          PROC_NODE_GAS_ID AS GP_NODE_ID,
          PROC_NODE_WATER_ID AS WP_NODE_ID,
          PROC_NODE_COND_ID AS CP_NODE_ID,
          PROC_NODE_GAS_LIFT_ID AS GL_NODE_ID,
          PROC_NODE_DILUENT_ID AS DL_NODE_ID,
          PROC_NODE_GAS_INJ_ID AS GI_NODE_ID,
          PROC_NODE_WATER_INJ_ID AS WI_NODE_ID,
          PROC_NODE_STEAM_INJ_ID AS SI_NODE_ID,
          ecdp_productionday.
          findProductionDayDefinition ('WELL', o.object_id, oa.daytime)
             AS ACTIVE_PRODUCTION_DAY,
          oa.well_reference_obj_id AS WELL_REFERENCE_OBJECT,
          oa.forecast_type AS FORECAST_TYPE,
          oa.forecast_scenario AS FORECAST_SCENARIO,
          oa.fluid_quality AS FLUID_QUALITY,
          oa.isproducer AS ISPRODUCER,
          oa.isproducerorother AS ISPRODUCEROROTHER,
          oa.isinjector AS ISINJECTOR,
          oa.isother AS ISOTHER,
          oa.isnotother AS ISNOTOTHER,
          oa.isoilproducer AS ISOILPRODUCER,
          oa.isgasproducer AS ISGASPRODUCER,
          oa.iscondensateproducer AS ISCONDENSATEPRODUCER,
          oa.iswaterproducer AS ISWATERPRODUCER,
          oa.isgasinjector AS ISGASINJECTOR,
          oa.iswaterinjector AS ISWATERINJECTOR,
          oa.isairinjector AS ISAIRINJECTOR,
          oa.issteaminjector AS ISSTEAMINJECTOR,
          oa.iswasteinjector AS ISWASTEINJECTOR,
          oa.text_7 AS GL_CONTROL_DEVICE,
          oa.text_5 AS GL_CHOKE_UOM,
          oa.text_6 AS GATHERING_POINT,
          oa.text_8 AS DEVELOPMENT_AREA,
          100 AS CALC_DC_SEQ_NO,
          EcDp_Objects.GetObjIDFromCode ('CALC_RULE', 'EC_DEFER_01')
             AS CALC_RULE_DC_ID,
          NVL2 (PROC_NODE_OIL_ID, 'Y', 'N') AS OP_IND,
          NVL2 (PROC_NODE_GAS_ID, 'Y', 'N') AS GP_IND,
          NVL2 (PROC_NODE_WATER_ID, 'Y', 'N') AS WP_IND,
          NVL2 (PROC_NODE_COND_ID, 'Y', 'N') AS CP_IND,
          NVL2 (PROC_NODE_GAS_LIFT_ID, 'Y', 'N') AS GL_IND,
          NVL2 (PROC_NODE_DILUENT_ID, 'Y', 'N') AS DL_IND,
          NVL2 (PROC_NODE_WATER_INJ_ID, 'Y', 'N') AS WI_IND,
          NVL2 (PROC_NODE_GAS_INJ_ID, 'Y', 'N') AS GI_IND,
          NVL2 (PROC_NODE_STEAM_INJ_ID, 'Y', 'N') AS SI_IND,
          oa.group_ref_code_1 AS GEO_COUNTRY_CODE,
          oa.group_ref_id_1 AS GEO_COUNTRY_ID,
          oa.group_ref_code_2 AS GEO_REGION_CODE,
          oa.group_ref_id_2 AS GEO_REGION_ID,
          oa.group_ref_code_6 AS GEO_LICENCE_CODE,
          oa.group_ref_id_6 AS GEO_LICENCE_ID,
          oa.choke_id AS CHOKE_ID,
          EC_CHOKE.object_code (oa.CHOKE_ID) AS CHOKE_CODE,
          oa.gl_choke_id AS GL_CHOKE_ID,
          EC_CHOKE.object_code (oa.GL_CHOKE_ID) AS GL_CHOKE_CODE,
          oa.geo_field_code AS GEO_FIELD_CODE,
          oa.geo_field_id AS GEO_FIELD_ID,
          o.well_hole_id AS WELL_HOLE_ID,
          EC_WELL_HOLE.object_code (o.WELL_HOLE_ID) AS WELL_HOLE_CODE,
          oa.commercial_entity_id AS COMMERCIAL_ENTITY_ID,
          EC_COMMERCIAL_ENTITY.object_code (oa.COMMERCIAL_ENTITY_ID)
             AS COMMERCIAL_ENTITY_CODE,
          oa.process_train_id AS PROCESS_TRAIN_ID,
          EC_PROCESS_TRAIN.object_code (oa.PROCESS_TRAIN_ID)
             AS PROCESS_TRAIN_CODE,
          oa.test_device_id AS TEST_DEVICE_ID,
          EC_EQUIPMENT.object_code (oa.TEST_DEVICE_ID) AS TEST_DEVICE_CODE,
          oa.op_pu_code AS OP_PRODUCTIONUNIT_CODE,
          oa.op_pu_id AS OP_PRODUCTIONUNIT_ID,
          oa.op_sub_pu_code AS OP_PROD_SUB_UNIT_CODE,
          oa.op_sub_pu_id AS OP_PROD_SUB_UNIT_ID,
          oa.op_area_code AS OP_AREA_CODE,
          oa.op_area_id AS OP_AREA_ID,
          oa.op_sub_area_code AS OP_SUB_AREA_CODE,
          oa.op_sub_area_id AS OP_SUB_AREA_ID,
          oa.op_fcty_class_2_code AS OP_FCTY_2_CODE,
          oa.op_fcty_class_2_id AS OP_FCTY_2_ID,
          oa.op_fcty_class_1_code AS OP_FCTY_1_CODE,
          oa.op_fcty_class_1_id AS OP_FCTY_1_ID,
          pwel_mth_alloc.DAYTIME AS DAYTIME,
          pwel_mth_alloc.PROD_DAYS AS PROD_DAYS,
          pwel_mth_alloc.VALUE_1 AS OPERATING_DAYS,
          pwel_mth_alloc.ON_STREAM_HRS AS ON_STREAM_HRS,
          pwel_mth_alloc.ALLOC_NET_OIL_VOL AS ALLOC_NET_OIL_VOL,
          ec_pwel_mth_alloc.math_alloc_net_oil_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_NET_OIL_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_net_oil_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_NET_OIL_VOL_TTD,
          DECODE(to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd')), 0, 0, pwel_mth_alloc.alloc_net_oil_vol/to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd'))) AS ALLOC_NET_OIL_CDAY,
          DECODE(pwel_mth_alloc.prod_days, 0, 0, pwel_mth_alloc.alloc_net_oil_vol/pwel_mth_alloc.prod_days) AS ALLOC_NET_OIL_RATE,
          pwel_mth_alloc.ALLOC_GAS_VOL AS ALLOC_GAS_VOL,
          ec_pwel_mth_alloc.math_alloc_gas_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_GAS_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_gas_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_GAS_VOL_TTD,
          DECODE(to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd')), 0, 0, pwel_mth_alloc.alloc_gas_vol/to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd'))) AS ALLOC_GAS_CDAY,
          DECODE(pwel_mth_alloc.prod_days, 0, 0, pwel_mth_alloc.alloc_gas_vol/pwel_mth_alloc.prod_days) AS ALLOC_GAS_RATE,
          pwel_mth_alloc.ALLOC_COND_VOL AS ALLOC_COND_VOL,
          ec_pwel_mth_alloc.math_alloc_cond_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_COND_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_cond_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_COND_VOL_TTD,
          pwel_mth_alloc.ALLOC_WATER_VOL AS ALLOC_WATER_VOL,
          ec_pwel_mth_alloc.math_alloc_water_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_WATER_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_water_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_WATER_VOL_TTD,
          DECODE(to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd')), 0, 0, pwel_mth_alloc.alloc_water_vol/to_number(to_char(last_day(pwel_mth_alloc.daytime),'dd'))) AS ALLOC_WATER_CDAY,
          DECODE(pwel_mth_alloc.prod_days, 0, 0, pwel_mth_alloc.alloc_water_vol/pwel_mth_alloc.prod_days) AS ALLOC_WATER_RATE,
          pwel_mth_alloc.ALLOC_NET_OIL_MASS AS ALLOC_NET_OIL_MASS,
          ec_pwel_mth_alloc.math_alloc_net_oil_mass(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_NET_OIL_MASS_YTD,
          ec_pwel_mth_alloc.math_alloc_net_oil_mass(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_NET_OIL_MASS_TTD,
          pwel_mth_alloc.ALLOC_NET_GAS_VOL AS ALLCO_NET_GAS_VOL,
          pwel_mth_alloc.ALLOC_NET_GAS_MASS AS ALLOC_NET_GAS_MASS,
          pwel_mth_alloc.ALLOC_GAS_MASS AS ALLOC_GAS_MASS,
          ec_pwel_mth_alloc.math_alloc_gas_mass(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_GAS_MASS_YTD,
          ec_pwel_mth_alloc.math_alloc_gas_mass(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_GAS_MASS_TTD,
          pwel_mth_alloc.ALLOC_COND_MASS AS ALLOC_COND_MASS,
          ec_pwel_mth_alloc.math_alloc_cond_mass(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_COND_MASS_YTD,
          ec_pwel_mth_alloc.math_alloc_cond_mass(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_COND_MASS_TTD,
          pwel_mth_alloc.ALLOC_WATER_MASS AS ALLOC_WATER_MASS,
          ec_pwel_mth_alloc.math_alloc_water_mass(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_WATER_MASS_YTD,
          ec_pwel_mth_alloc.math_alloc_water_mass(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_WATER_MASS_TTD,
          pwel_mth_alloc.ALLOC_GL_VOL AS ALLOC_GL_VOL,
          ec_pwel_mth_alloc.math_alloc_gl_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_GL_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_gl_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_GL_VOL_TTD,
          pwel_mth_alloc.ALLOC_DILUENT_VOL AS ALLOC_DILUENT_VOL,
          ec_pwel_mth_alloc.math_alloc_diluent_vol(pwel_mth_alloc.object_id,TRUNC(pwel_mth_alloc.daytime,'YEAR'),pwel_mth_alloc.daytime,'SUM') AS ALLOC_DILUENT_VOL_YTD,
          ec_pwel_mth_alloc.math_alloc_diluent_vol(pwel_mth_alloc.object_id,NULL,pwel_mth_alloc.daytime,'SUM') AS ALLOC_DILUENT_VOL_TTD,
          pwel_mth_alloc.THEOR_NET_OIL_RATE AS THEOR_NET_OIL_RATE,
          pwel_mth_alloc.THEOR_GAS_RATE AS THEOR_GAS_RATE,
          pwel_mth_alloc.THEOR_COND_RATE AS THEOR_COND_RATE,
          pwel_mth_alloc.THEOR_WATER_RATE AS THEOR_WATER_RATE,
          pwel_mth_alloc.THEOR_GAS_MASS AS THEOR_GAS_MASS,
          pwel_mth_alloc.THEOR_NET_OIL_MASS AS THEOR_NET_OIL_MASS,
          pwel_mth_alloc.THEOR_COND_MASS AS THEOR_COND_MASS,
          pwel_mth_alloc.THEOR_WATER_MASS AS THEOR_WATER_MASS,
          pwel_mth_alloc.THEOR_GL_RATE AS THEOR_GL_RATE,
          pwel_mth_alloc.THEOR_DILUENT_RATE AS THEOR_DILUENT_RATE,
          pwel_mth_alloc.NET_OIL_VOL_FACTOR AS NET_OIL_VOL_FACTOR,
          pwel_mth_alloc.GAS_VOL_FACTOR AS GAS_VOL_FACTOR,
          pwel_mth_alloc.COND_VOL_FACTOR AS COND_VOL_FACTOR,
          pwel_mth_alloc.WATER_VOL_FACTOR AS WATER_VOL_FACTOR,
          pwel_mth_alloc.GL_VOL_FACTOR AS GL_VOL_FACTOR,
          pwel_mth_alloc.DILUENT_VOL_FACTOR AS DILUENT_VOL_FACTOR,
          pwel_mth_alloc.NET_OIL_MASS_FACTOR AS NET_OIL_MASS_FACTOR,
          pwel_mth_alloc.GAS_MASS_FACTOR AS GAS_MASS_FACTOR,
          pwel_mth_alloc.COND_MASS_FACTOR AS COND_MASS_FACTOR,
          pwel_mth_alloc.WATER_MASS_FACTOR AS WATER_MASS_FACTOR,
          pwel_mth_alloc.LOAD_OIL_CL_ACC_GRS_MASS AS LOAD_OIL_CL_ACC_GRS_MASS,
          pwel_mth_alloc.LOAD_OIL_CL_ACC_NET_MASS AS LOAD_OIL_CL_ACC_NET_MASS,
          pwel_mth_alloc.LOAD_OIL_PROD_GRS_MASS AS LOAD_OIL_PROD_GRS_MASS,
          pwel_mth_alloc.LOAD_OIL_PROD_NET_MASS AS LOAD_OIL_PROD_NET_MASS,
          pwel_mth_alloc.LOAD_OIL_RCV_GRS_MASS AS LOAD_OIL_RCV_GRS_MASS,
          pwel_mth_alloc.LOAD_OIL_RCV_NET_MASS AS LOAD_OIL_RCV_NET_MASS,
          pwel_mth_alloc.LOAD_WATER_CLOSING_ACC AS LOAD_WATER_CLOSING_ACC,
          pwel_mth_alloc.LOAD_WATER_PROD AS LOAD_WATER_PROD,
          pwel_mth_alloc.LOAD_WATER_RECEIVED AS LOAD_WATER_RECEIVED,
          pwel_mth_alloc.RECORD_STATUS,
          pwel_mth_alloc.CREATED_BY,
          pwel_mth_alloc.CREATED_DATE,
          pwel_mth_alloc.LAST_UPDATED_BY,
          pwel_mth_alloc.LAST_UPDATED_DATE,
          pwel_mth_alloc.REV_NO,
          pwel_mth_alloc.REV_TEXT,
          pwel_mth_alloc.APPROVAL_STATE AS APPROVAL_STATE,
          pwel_mth_alloc.APPROVAL_BY AS APPROVAL_BY,
          pwel_mth_alloc.APPROVAL_DATE AS APPROVAL_DATE,
          pwel_mth_alloc.REC_ID AS REC_ID,
          pwel_mth_alloc.ALLOC_NET_GAS_VOL AS ALLOC_NET_GAS_VOL
     FROM WELL_VERSION oa, WELL o, pwel_mth_alloc
    WHERE     oa.object_id = pwel_mth_alloc.object_id
          AND pwel_mth_alloc.object_id = o.object_id
          AND pwel_mth_alloc.daytime >= TRUNC (oa.daytime, 'MONTH')
          AND oa.daytime =
                 (SELECT MIN (daytime)
                    FROM WELL_VERSION oa2
                   WHERE oa2.object_id = oa.object_id
                         AND oa2.well_class = 'P'
                         AND pwel_mth_alloc.DAYTIME >=
                                TRUNC (oa2.daytime, 'MONTH')
                         AND pwel_mth_alloc.DAYTIME <
                                NVL (oa2.end_date,
                                     TO_DATE ('01.01.2200', 'dd.mm.yyyy')));
/