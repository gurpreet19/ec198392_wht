CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IWEL_DAY_STATUS" ("OBJECT_ID", "DAYTIME", "INJ_TYPE", "CODE", "NAME", "CURRENT_WELL_TYPE", "ON_STREAM_HRS", "AVG_CHOKE_SIZE", "AVG_CHOKE_SIZE_2", "CHOKE_MM", "AVG_WH_PRESS_BARG", "AVG_WH_TEMP_C", "AVG_WH_USC_PRESS_BARG", "AVG_WH_USC_TEMP_C", "AVG_WH_DSC_PRESS_BARG", "AVG_WH_DSC_TEMP_C", "AVG_BH_PRESS_BARG", "AVG_BH_TEMP_C", "AVG_ANNULUS_PRESS_BARG", "INJ_VOL_SM3", "ALLOC_INJ_VOL_SM3", "THEOR_RATE_SM3PERDAY", "ISGASINJECTOR", "ISWATERINJECTOR", "ISSCO2INJECTOR", "ISSTEAMINJECTOR", "CALC_GAS_INJ_METHOD", "CALC_WATER_INJ_METHOD", "CALC_CO2_INJ_METHOD", "CALC_STEAM_INJ_METHOD", "THEOR_CALC_METHOD", "OFFICIAL_NAME", "WELL_CLASS", "OBJECT_START_DATE", "OBJECT_END_DATE", "DESCRIPTION", "FLOWLINE", "COMMENTS", "WELL_METER_FREQ", "INSTRUMENTRION_TYPE", "PR_RESDATA_CLASS", "CALC_METHOD", "CALC_GAS_METHOD", "CALC_WATER_METHOD", "CALC_COND_METHOD", "CALC_METHOD_MASS", "CHOKE_UOM", "CHOKE_ID", "CHOKE_CODE", "COMMERCIAL_ENTITY_ID", "COMMERCIAL_ENTITY_CODE", "OP_FCTY_1_ID", "OP_FCTY_1_CODE", "OP_WELL_HOOKUP_ID", "OP_WELL_HOOKUP_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE") AS 
  (
----------------------------------------------------------------------------------------------------------------
--  V_IWEL_DAY_STATUS
--
-- $Revision: 1.0 $
--
--  Purpose:   The main purpose of the view is to show the injection data for WAG wells in a single
--            view instead of using a specific water or gas view. This way you don't have to switch
--            the view you query against each time the well switches from a water injector to a
--            gas injector vica versa. The view shows the injection data for any kind of injection well.
--
--  Date           Whom 		  Change description:
--  -------------- --------		-----------------------------------------------------------------------------------
-- 22.09.2016      jainngou     ECPD-36906:Intial version
-----------------------------------------------------------------------------------------------------------------
SELECT
       ids.object_id                                                                         OBJECT_ID
      ,ids.daytime                                                                           DAYTIME
      ,ids.inj_type                                                                          INJ_TYPE
      ,o.object_code                                                                         CODE
      ,oa.name                                                                               NAME
      ,oa.well_type                                                                          CURRENT_WELL_TYPE
      ,ids.on_stream_hrs                                                                     ON_STREAM_HRS
      ,ids.avg_choke_size                                                                    AVG_CHOKE_SIZE
      ,ids.AVG_2ND_CHOKE_SIZE                                                                AVG_CHOKE_SIZE_2
      ,EcBp_Well_Choke.convertToMilliMeter(ids.object_id, ids.daytime, ids.avg_choke_size)   CHOKE_MM
      ,ids.avg_wh_press                                                                      AVG_WH_PRESS_BARG
      ,ids.avg_wh_temp                                                                       AVG_WH_TEMP_C
      ,ids.avg_wh_usc_press                                                                  AVG_WH_USC_PRESS_BARG
      ,ids.avg_wh_usc_temp                                                                   AVG_WH_USC_TEMP_C
      ,ids.avg_wh_dsc_press                                                                  AVG_WH_DSC_PRESS_BARG
      ,ids.avg_wh_dsc_temp                                                                   AVG_WH_DSC_TEMP_C
      ,ids.avg_bh_press                                                                      AVG_BH_PRESS_BARG
      ,ids.avg_bh_temp                                                                       AVG_BH_TEMP_C
      ,ids.annulus_press                                                                     AVG_ANNULUS_PRESS_BARG
      ,ids.inj_vol                                                                           INJ_VOL_SM3
      ,ec_iwel_day_alloc.alloc_inj_vol(ids.object_id, ids.daytime, ids.inj_type)             ALLOC_INJ_VOL_SM3
      ,EcBp_Well_Theoretical.getInjectedStdRateDay(ids.object_id, ids.inj_type, ids.daytime) THEOR_RATE_SM3PERDAY
      ,oa.isgasinjector                                                                      ISGASINJECTOR
      ,oa.iswaterinjector                                                                    ISWATERINJECTOR
      ,oa.isco2injector                                                                      ISSCO2INJECTOR
      ,oa.issteaminjector                                                                    ISSTEAMINJECTOR
      ,oa.calc_inj_method                                                                    CALC_GAS_INJ_METHOD
      ,oa.calc_water_inj_method                                                              CALC_WATER_INJ_METHOD
	  ,oa.calc_co2_inj_method                                                                CALC_CO2_INJ_METHOD
      ,oa.calc_steam_inj_method                                                              CALC_STEAM_INJ_METHOD
      ,DECODE(ids.inj_type,
	                  'GI', oa.calc_inj_method,
	                  'WI', oa.calc_water_inj_method,
                      'CI',	oa.calc_co2_inj_method,
                      'SI',	oa.calc_steam_inj_method)                         			     THEOR_CALC_METHOD
      ,oa.official_name                                                                      OFFICIAL_NAME
      ,oa.well_class                                                                         WELL_CLASS
      ,o.start_date                                                                          OBJECT_START_DATE
      ,o.end_date                                                                            OBJECT_END_DATE
      ,o.description                                                                         DESCRIPTION
      ,ecdp_flowline_sub_well_conn.FlowlinesForWellProdDay(ids.object_id, ids.daytime)       FLOWLINE
      ,ids.comments                                                                          COMMENTS
      ,oa.well_meter_freq                                                                    WELL_METER_FREQ
      ,oa.instrumentation_type                                                               INSTRUMENTRION_TYPE
      ,ecdp_performance_test.getResultDataClassName(o.object_id, oa.daytime)                 PR_RESDATA_CLASS
      ,oa.calc_method                                                                        CALC_METHOD
      ,oa.calc_gas_method                                                                    CALC_GAS_METHOD
      ,oa.calc_water_method                                                                  CALC_WATER_METHOD
      ,oa.calc_cond_method                                                                   CALC_COND_METHOD
      ,oa.calc_method_mass                                                                   CALC_METHOD_MASS
      ,ec_well_version.CHOKE_UOM(ids.object_id, ids.daytime, '<=')                           CHOKE_UOM
      ,oa.choke_id                                                                           CHOKE_ID
      ,EC_CHOKE.object_code(oa.CHOKE_ID)                                                     CHOKE_CODE
      ,oa.commercial_entity_id                                                               COMMERCIAL_ENTITY_ID
      ,EC_COMMERCIAL_ENTITY.object_code(oa.COMMERCIAL_ENTITY_ID)                             COMMERCIAL_ENTITY_CODE
      ,oa.op_fcty_class_1_id                                                                 OP_FCTY_1_ID
      ,oa.op_fcty_class_1_code                                                               OP_FCTY_1_CODE
      ,oa.op_well_hookup_id                                                                  OP_WELL_HOOKUP_ID
      ,oa.op_well_hookup_code                                                                OP_WELL_HOOKUP_CODE
      ,ids.record_status                                                                     RECORD_STATUS
      ,ids.created_by                                                                        CREATED_BY
      ,ids.created_date                                                                      CREATED_DATE
      ,ids.last_updated_by                                                                   LAST_UPDATED_BY
      ,ids.last_updated_date                                                                 LAST_UPDATED_DATE
      ,ids.rev_no                                                                            REV_NO
      ,ids.rev_text                                                                          REV_TEXT
      ,ids.approval_state                                                                    APPROVAL_STATE
      ,ids.approval_by                                                                       APPROVAL_BY
      ,ids.approval_date                                                                     APPROVAL_DATE
FROM iwel_day_status ids, well o, well_version oa
WHERE oa.object_id = o.object_id
AND ids.object_id = o.object_id
AND ids.DAYTIME >= oa.daytime
AND (oa.end_date IS NULL OR ids.daytime < oa.end_date)
)