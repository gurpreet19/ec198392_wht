CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_HISTORICAL" ("CLASS_NAME", "OBJECT_ID", "OBJECT_CODE", "OBJECT_START_DATE", "OBJECT_END_DATE", "TEMPLATE_NO", "MASTER_SYS_CODE", "DESCRIPTION", "OBJECT_REV_NO", "DAYTIME", "END_DATE", "NAME", "WELL_TYPE", "PUMP_TYPE", "INSTRUMENTATION_TYPE", "BF_PROFILE", "CHOKE_ID", "CHOKE_UOM", "CALC_METHOD", "PROD_METHOD", "GAS_LIFT_METHOD", "ON_STRM_METHOD", "APPROACH_METHOD", "CALC_INJ_METHOD", "WELL_TEST_METHOD", "CALC_METHOD_MASS", "DILUENT_METHOD", "POTENTIAL_METHOD", "STD_GAS_DENSITY_METHOD", "STD_OIL_DENSITY_METHOD", "BSW_VOL_METHOD", "CGR_METHOD", "SAND_METHOD", "GOR_METHOD", "WGR_METHOD", "WDF_METHOD", "WOR_METHOD", "BH_GL_VALVE_MD", "BH_PRESS_GAUGE_MD", "CALC_STEAM_INJ_METHOD", "CALC_WATER_INJ_METHOD", "POTENTIAL_MASS_METHOD", "CALC_SUB_DAY_METHOD", "CALC_COND_METHOD", "CALC_GAS_METHOD", "CALC_SUB_DAY_COND_METHOD", "CALC_SUB_DAY_GAS_METHOD", "CALC_SUB_DAY_WATER_METHOD", "CALC_WATER_METHOD", "CO2_DIAGRAM_LAYOUT_INFO", "PROC_NODE_CO2_ID", "DILUENT_SUB_DAY_METHOD", "GAS_LIFT_SUB_DAY_METHOD", "POTENTIAL_GAS_INJ_METHOD", "POT_STEAM_INJ_METHOD", "POT_WATER_INJ_METHOD", "GI_EVENT_INJ_DATA_METHOD", "SI_EVENT_INJ_DATA_METHOD", "WI_EVENT_INJ_DATA_METHOD", "STD_WAT_DENSITY_METHOD", "FLUID_QUALITY", "FORECAST_SCENARIO", "FORECAST_TYPE", "ALLOC_FLAG", "ALLOC_FIXED", "ALLOC_FIXED_WC", "ALLOC_FIXED_GOR", "BH_GL_VALVE_TVD", "BH_PRESS_GAUGE_TVD", "WELL_METER_FREQ", "WELL_CALC_RULE", "DIAGRAM_LAYOUT_INFO", "DL_DIAGRAM_LAYOUT_INFO", "GI_DIAGRAM_LAYOUT_INFO", "GL_DIAGRAM_LAYOUT_INFO", "GP_DIAGRAM_LAYOUT_INFO", "OP_DIAGRAM_LAYOUT_INFO", "WI_DIAGRAM_LAYOUT_INFO", "WP_DIAGRAM_LAYOUT_INFO", "SI_DIAGRAM_LAYOUT_INFO", "CI_DIAGRAM_LAYOUT_INFO", "WELL_HOLE_ID", "WELL_REFERENCE_OBJ_ID", "COMMERCIAL_ENTITY_ID", "PROCESS_TRAIN_ID", "GL_CHOKE_ID", "DEF_FCTY_CLASS_1_ID", "DEF_EQUIPMENT_ID", "DEF_FLOWLINE_ID", "DEF_PUMP_ID", "DEF_COMPRESSOR_ID", "DEF_CTRL_SAFETY_SYSTEM_ID", "DEF_GAS_PROC_ID", "DEF_POWER_DISTRIBUTION_ID", "DEF_UTILITY_ID", "TEST_DEVICE_ID", "COUNTY_ID", "MMS_LEASE_ID", "OPERATOR_LEASE_ID", "STATE_LEASE_ID", "ISAIRINJECTOR", "ISCONDENSATEPRODUCER", "ISGASINJECTOR", "ISGASPRODUCER", "ISINJECTOR", "ISNOTOTHER", "ISOILPRODUCER", "ISOTHER", "ISPRODUCER", "ISPRODUCEROROTHER", "ISSTEAMINJECTOR", "ISWASTEINJECTOR", "ISWATERINJECTOR", "ISCO2INJECTOR", "ISWATERPRODUCER", "PROC_NODE_OIL_ID", "PROC_NODE_GAS_ID", "PROC_NODE_COND_ID", "PROC_NODE_WATER_ID", "PROC_NODE_WATER_INJ_ID", "PROC_NODE_STEAM_INJ_ID", "PROC_NODE_GAS_INJ_ID", "PROC_NODE_DILUENT_ID", "PROC_NODE_GAS_LIFT_ID", "PROC_NODE_CO2_INJ_ID", "OFFICIAL_NAME", "DECLINE_FLAG", "CALC_CO2_INJ_METHOD", "CALC_CO2_METHOD", "POT_CO2_INJ_METHOD", "ENERGY_METHOD", "GCV_METHOD", "GWR_METHOD", "REF_GAS_CONST_STD_ID", "REF_GAS_FLUID_STATE", "REF_OIL_CONST_STD_ID", "REF_OIL_FLUID_STATE", "COMP_GASINJ_CODE", "COMP_GAS_CODE", "COMP_LIQ_CODE", "MASTER_SYS_NAME", "CALC_INJ_METHOD_MASS", "ALLOW_THEOR_OVERRIDE", "DEPTH_MEAS_REF", "DWF_METHOD", "DETAILED_PROD_METHOD", "WELL_METER_METHOD", "WELL_CLASS", "SORT_ORDER", "COMMENTS", "OP_PU_ID", "OP_PU_CODE", "OP_SUB_PU_ID", "OP_SUB_PU_CODE", "OP_AREA_ID", "OP_AREA_CODE", "OP_SUB_AREA_ID", "OP_SUB_AREA_CODE", "OP_FCTY_CLASS_2_ID", "OP_FCTY_CLASS_2_CODE", "OP_FCTY_CLASS_1_ID", "OP_FCTY_CLASS_1_CODE", "SECONDARY_FCTY_ID", "SECONDARY_FCTY_CODE", "OP_WELL_HOOKUP_ID", "OP_WELL_HOOKUP_CODE", "GEO_AREA_ID", "GEO_AREA_CODE", "GEO_SUB_AREA_ID", "GEO_SUB_AREA_CODE", "GEO_FIELD_ID", "GEO_FIELD_CODE", "GEO_SUB_FIELD_ID", "GEO_SUB_FIELD_CODE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "TEXT_21", "TEXT_22", "TEXT_23", "TEXT_24", "TEXT_25", "TEXT_26", "TEXT_27", "TEXT_28", "TEXT_29", "TEXT_30", "TEXT_31", "TEXT_32", "TEXT_33", "TEXT_34", "TEXT_35", "TEXT_36", "TEXT_37", "TEXT_38", "TEXT_39", "TEXT_40", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "VALUE_11", "VALUE_12", "VALUE_13", "VALUE_14", "VALUE_15", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "GROUP_REF_ID_1", "GROUP_REF_CODE_1", "GROUP_REF_ID_2", "GROUP_REF_CODE_2", "GROUP_REF_ID_3", "GROUP_REF_CODE_3", "GROUP_REF_ID_4", "GROUP_REF_CODE_4", "GROUP_REF_ID_5", "GROUP_REF_CODE_5", "GROUP_REF_ID_6", "GROUP_REF_CODE_6", "GROUP_REF_ID_7", "GROUP_REF_CODE_7", "GROUP_REF_ID_8", "GROUP_REF_CODE_8", "GROUP_REF_ID_9", "GROUP_REF_CODE_9", "GROUP_REF_ID_10", "GROUP_REF_CODE_10", "CP_AREA_CODE", "CP_AREA_ID", "CP_COL_POINT_CODE", "CP_COL_POINT_ID", "CP_OPERATOR_ROUTE_CODE", "CP_OPERATOR_ROUTE_ID", "CP_PU_CODE", "CP_PU_ID", "CP_SUB_AREA_CODE", "CP_SUB_AREA_ID", "CP_SUB_PU_CODE", "CP_SUB_PU_ID", "FFV_FLAG", "DSM_FLARE_METHOD", "DSM_FUEL_METHOD", "DSM_VENT_METHOD", "USM_FLARE_METHOD", "USM_FUEL_METHOD", "USM_VENT_METHOD", "REF_SEASONAL_WELL_ID", "CALC_EVENT_METHOD", "CALC_EVENT_GAS_METHOD", "CALC_EVENT_WATER_METHOD", "CALC_EVENT_COND_METHOD", "VERSION_REV_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  V_WELL_HISTORICAL
--
-- $Revision: 1.0 $
--
--  Purpose:   Use in Well Historical
--  Note:
--
--  Date           Whom 		Change description:
--  -------------- --------		--------
--  09-10-2015     abdulmaw     ECPD-30931:Intial version
-------------------------------------------------------------------------------------
SELECT
'V_WELL_HISTORICAL' AS CLASS_NAME
,o.OBJECT_ID
,o.OBJECT_CODE
,o.START_DATE AS OBJECT_START_DATE
,o.END_DATE AS OBJECT_END_DATE
,o.TEMPLATE_NO
,o.MASTER_SYS_CODE
,o.DESCRIPTION
,o.REV_NO AS OBJECT_REV_NO
,oa.DAYTIME AS DAYTIME
,oa.END_DATE AS END_DATE
,oa.NAME
,oa.WELL_TYPE
,oa.PUMP_TYPE
,oa.INSTRUMENTATION_TYPE
,oa.BF_PROFILE
,oa.CHOKE_ID
,oa.CHOKE_UOM
,oa.CALC_METHOD
,oa.PROD_METHOD
,oa.GAS_LIFT_METHOD
,oa.ON_STRM_METHOD
,oa.APPROACH_METHOD
,oa.CALC_INJ_METHOD
,oa.WELL_TEST_METHOD
,oa.CALC_METHOD_MASS
,oa.DILUENT_METHOD
,oa.POTENTIAL_METHOD
,oa.STD_GAS_DENSITY_METHOD
,oa.STD_OIL_DENSITY_METHOD
,oa.BSW_VOL_METHOD
,oa.CGR_METHOD
,oa.SAND_METHOD
,oa.GOR_METHOD
,oa.WGR_METHOD
,oa.WDF_METHOD
,oa.WOR_METHOD
,oa.BH_GL_VALVE_MD
,oa.BH_PRESS_GAUGE_MD
,oa.CALC_STEAM_INJ_METHOD
,oa.CALC_WATER_INJ_METHOD
,oa.POTENTIAL_MASS_METHOD
,oa.CALC_SUB_DAY_METHOD
,oa.CALC_COND_METHOD
,oa.CALC_GAS_METHOD
,oa.CALC_SUB_DAY_COND_METHOD
,oa.CALC_SUB_DAY_GAS_METHOD
,oa.CALC_SUB_DAY_WATER_METHOD
,oa.CALC_WATER_METHOD
,oa.CO2_DIAGRAM_LAYOUT_INFO
,oa.PROC_NODE_CO2_ID
,oa.DILUENT_SUB_DAY_METHOD
,oa.GAS_LIFT_SUB_DAY_METHOD
,oa.POTENTIAL_GAS_INJ_METHOD
,oa.POT_STEAM_INJ_METHOD
,oa.POT_WATER_INJ_METHOD
,oa.GI_EVENT_INJ_DATA_METHOD
,oa.SI_EVENT_INJ_DATA_METHOD
,oa.WI_EVENT_INJ_DATA_METHOD
,oa.STD_WAT_DENSITY_METHOD
,oa.FLUID_QUALITY
,oa.FORECAST_SCENARIO
,oa.FORECAST_TYPE
,oa.ALLOC_FLAG
,oa.ALLOC_FIXED
,oa.ALLOC_FIXED_WC
,oa.ALLOC_FIXED_GOR
,oa.BH_GL_VALVE_TVD
,oa.BH_PRESS_GAUGE_TVD
,oa.WELL_METER_FREQ
,oa.WELL_CALC_RULE
,oa.DIAGRAM_LAYOUT_INFO
,oa.DL_DIAGRAM_LAYOUT_INFO
,oa.GI_DIAGRAM_LAYOUT_INFO
,oa.GL_DIAGRAM_LAYOUT_INFO
,oa.GP_DIAGRAM_LAYOUT_INFO
,oa.OP_DIAGRAM_LAYOUT_INFO
,oa.WI_DIAGRAM_LAYOUT_INFO
,oa.WP_DIAGRAM_LAYOUT_INFO
,oa.SI_DIAGRAM_LAYOUT_INFO
,oa.CI_DIAGRAM_LAYOUT_INFO
,oa.WELL_HOLE_ID
,oa.WELL_REFERENCE_OBJ_ID
,oa.COMMERCIAL_ENTITY_ID
,oa.PROCESS_TRAIN_ID
,oa.GL_CHOKE_ID
,oa.DEF_FCTY_CLASS_1_ID
,oa.DEF_EQUIPMENT_ID
,oa.DEF_FLOWLINE_ID
,oa.DEF_PUMP_ID
,oa.DEF_COMPRESSOR_ID
,oa.DEF_CTRL_SAFETY_SYSTEM_ID
,oa.DEF_GAS_PROC_ID
,oa.DEF_POWER_DISTRIBUTION_ID
,oa.DEF_UTILITY_ID
,oa.TEST_DEVICE_ID
,oa.COUNTY_ID
,oa.MMS_LEASE_ID
,oa.OPERATOR_LEASE_ID
,oa.STATE_LEASE_ID
,oa.ISAIRINJECTOR
,oa.ISCONDENSATEPRODUCER
,oa.ISGASINJECTOR
,oa.ISGASPRODUCER
,oa.ISINJECTOR
,oa.ISNOTOTHER
,oa.ISOILPRODUCER
,oa.ISOTHER
,oa.ISPRODUCER
,oa.ISPRODUCEROROTHER
,oa.ISSTEAMINJECTOR
,oa.ISWASTEINJECTOR
,oa.ISWATERINJECTOR
,oa.ISCO2INJECTOR
,oa.ISWATERPRODUCER
,oa.PROC_NODE_OIL_ID
,oa.PROC_NODE_GAS_ID
,oa.PROC_NODE_COND_ID
,oa.PROC_NODE_WATER_ID
,oa.PROC_NODE_WATER_INJ_ID
,oa.PROC_NODE_STEAM_INJ_ID
,oa.PROC_NODE_GAS_INJ_ID
,oa.PROC_NODE_DILUENT_ID
,oa.PROC_NODE_GAS_LIFT_ID
,oa.PROC_NODE_CO2_INJ_ID
,oa.OFFICIAL_NAME
,oa.DECLINE_FLAG
,oa.CALC_CO2_INJ_METHOD
,oa.CALC_CO2_METHOD
,oa.POT_CO2_INJ_METHOD
,oa.ENERGY_METHOD
,oa.GCV_METHOD
,oa.GWR_METHOD
,oa.REF_GAS_CONST_STD_ID
,oa.REF_GAS_FLUID_STATE
,oa.REF_OIL_CONST_STD_ID
,oa.REF_OIL_FLUID_STATE
,oa.COMP_GASINJ_CODE
,oa.COMP_GAS_CODE
,oa.COMP_LIQ_CODE
,oa.MASTER_SYS_NAME
,oa.CALC_INJ_METHOD_MASS
,oa.ALLOW_THEOR_OVERRIDE
,oa.DEPTH_MEAS_REF
,oa.DWF_METHOD
,oa.DETAILED_PROD_METHOD
,oa.WELL_METER_METHOD
,oa.WELL_CLASS
,oa.SORT_ORDER
,oa.COMMENTS
,oa.OP_PU_ID
,oa.OP_PU_CODE
,oa.OP_SUB_PU_ID
,oa.OP_SUB_PU_CODE
,oa.OP_AREA_ID
,oa.OP_AREA_CODE
,oa.OP_SUB_AREA_ID
,oa.OP_SUB_AREA_CODE
,oa.OP_FCTY_CLASS_2_ID
,oa.OP_FCTY_CLASS_2_CODE
,oa.OP_FCTY_CLASS_1_ID
,oa.OP_FCTY_CLASS_1_CODE
,oa.SECONDARY_FCTY_ID
,oa.SECONDARY_FCTY_CODE
,oa.OP_WELL_HOOKUP_ID
,oa.OP_WELL_HOOKUP_CODE
,oa.GEO_AREA_ID
,oa.GEO_AREA_CODE
,oa.GEO_SUB_AREA_ID
,oa.GEO_SUB_AREA_CODE
,oa.GEO_FIELD_ID
,oa.GEO_FIELD_CODE
,oa.GEO_SUB_FIELD_ID
,oa.GEO_SUB_FIELD_CODE
,oa.TEXT_1
,oa.TEXT_2
,oa.TEXT_3
,oa.TEXT_4
,oa.TEXT_5
,oa.TEXT_6
,oa.TEXT_7
,oa.TEXT_8
,oa.TEXT_9
,oa.TEXT_10
,oa.TEXT_11
,oa.TEXT_12
,oa.TEXT_13
,oa.TEXT_14
,oa.TEXT_15
,oa.TEXT_16
,oa.TEXT_17
,oa.TEXT_18
,oa.TEXT_19
,oa.TEXT_20
,oa.TEXT_21
,oa.TEXT_22
,oa.TEXT_23
,oa.TEXT_24
,oa.TEXT_25
,oa.TEXT_26
,oa.TEXT_27
,oa.TEXT_28
,oa.TEXT_29
,oa.TEXT_30
,oa.TEXT_31
,oa.TEXT_32
,oa.TEXT_33
,oa.TEXT_34
,oa.TEXT_35
,oa.TEXT_36
,oa.TEXT_37
,oa.TEXT_38
,oa.TEXT_39
,oa.TEXT_40
,oa.VALUE_1
,oa.VALUE_2
,oa.VALUE_3
,oa.VALUE_4
,oa.VALUE_5
,oa.VALUE_6
,oa.VALUE_7
,oa.VALUE_8
,oa.VALUE_9
,oa.VALUE_10
,oa.VALUE_11
,oa.VALUE_12
,oa.VALUE_13
,oa.VALUE_14
,oa.VALUE_15
,oa.DATE_1
,oa.DATE_2
,oa.DATE_3
,oa.DATE_4
,oa.DATE_5
,oa.REF_OBJECT_ID_1
,oa.REF_OBJECT_ID_2
,oa.REF_OBJECT_ID_3
,oa.REF_OBJECT_ID_4
,oa.REF_OBJECT_ID_5
,oa.GROUP_REF_ID_1
,oa.GROUP_REF_CODE_1
,oa.GROUP_REF_ID_2
,oa.GROUP_REF_CODE_2
,oa.GROUP_REF_ID_3
,oa.GROUP_REF_CODE_3
,oa.GROUP_REF_ID_4
,oa.GROUP_REF_CODE_4
,oa.GROUP_REF_ID_5
,oa.GROUP_REF_CODE_5
,oa.GROUP_REF_ID_6
,oa.GROUP_REF_CODE_6
,oa.GROUP_REF_ID_7
,oa.GROUP_REF_CODE_7
,oa.GROUP_REF_ID_8
,oa.GROUP_REF_CODE_8
,oa.GROUP_REF_ID_9
,oa.GROUP_REF_CODE_9
,oa.GROUP_REF_ID_10
,oa.GROUP_REF_CODE_10
,oa.CP_AREA_CODE
,oa.CP_AREA_ID
,oa.CP_COL_POINT_CODE
,oa.CP_COL_POINT_ID
,oa.CP_OPERATOR_ROUTE_CODE
,oa.CP_OPERATOR_ROUTE_ID
,oa.CP_PU_CODE
,oa.CP_PU_ID
,oa.CP_SUB_AREA_CODE
,oa.CP_SUB_AREA_ID
,oa.CP_SUB_PU_CODE
,oa.CP_SUB_PU_ID
,oa.FFV_FLAG
,oa.DSM_FLARE_METHOD
,oa.DSM_FUEL_METHOD
,oa.DSM_VENT_METHOD
,oa.USM_FLARE_METHOD
,oa.USM_FUEL_METHOD
,oa.USM_VENT_METHOD
,oa.REF_SEASONAL_WELL_ID
,oa.CALC_EVENT_METHOD
,oa.CALC_EVENT_GAS_METHOD
,oa.CALC_EVENT_WATER_METHOD
,oa.CALC_EVENT_COND_METHOD
,oa.REV_NO AS VERSION_REV_NO
,oa.RECORD_STATUS AS RECORD_STATUS
,oa.CREATED_BY AS CREATED_BY
,oa.CREATED_DATE AS CREATED_DATE
,oa.LAST_UPDATED_BY AS LAST_UPDATED_BY
,oa.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
,oa.REV_NO AS REV_NO
,oa.REV_TEXT AS REV_TEXT
FROM V_WELL_HIST o, V_WELL_VERSION_HIST oa
WHERE oa.object_id = o.object_id
)