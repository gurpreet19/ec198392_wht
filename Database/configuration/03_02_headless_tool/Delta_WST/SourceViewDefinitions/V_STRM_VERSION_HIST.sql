CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STRM_VERSION_HIST" ("JN_UPD_CREATE_DATE", "JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DAYTIME", "END_DATE", "NAME", "STREAM_CATEGORY", "STREAM_TYPE", "STREAM_PHASE", "STREAM_CATEGORY_ID", "FROM_NODE_ID", "TO_NODE_ID", "STRM_METER_FREQ", "STRM_METER_METHOD", "AGGREGATE_FLAG", "PRODUCTION_DAY_ID", "PURPOSE", "REPORTING_CATEGORY", "PRODUCT_ID", "ALLOC_FLAG", "ALLOC_FIXED", "ALLOC_PERIOD", "ALLOC_DATA_FREQ", "SPECIFIC_GRAVITY_METHOD", "BSW_WT_METHOD", "BSW_VOL_METHOD", "NET_VOL_METHOD", "NET_MASS_METHOD", "GRS_MASS_METHOD", "GRS_VOL_METHOD", "WATER_VOL_METHOD", "WATER_MASS_METHOD", "STD_DENS_METHOD", "STD_GRS_DENS_METHOD", "ENERGY_METHOD", "CGR_METHOD", "WGR_METHOD", "WDF_METHOD", "GCV_METHOD", "GOR_METHOD", "COND_VOL_METHOD", "SALT_WT_METHOD", "VAPOUR_RECOVERY_METHOD", "VCF_METHOD", "COMP_SET_CODE", "ON_STREAM_METHOD", "REF_GAS_CONST_STD_ID", "REF_GAS_FLUID_STATE", "REF_OIL_CONST_STD_ID", "REF_OIL_FLUID_STATE", "DIAGRAM_LAYOUT_INFO", "COMMENTS", "REF_ANALYSIS_STREAM_ID", "REF_BITUMEN_STREAM_ID", "REF_DILUENT_STREAM_ID", "REF_ORF_STREAM_ID", "AGA_REF_ANALYSIS_ID", "DISPOSITION_TYPE_ID", "CONVERSION_GROUP_ID", "MASTER_SYS_NAME", "STRM_BAL_CATEGORY", "REF_ALLOC_STREAM_ID", "COMMERCIAL_ENTITY_ID", "FORMULA_EDITOR_FLAG", "FIELD_REF_ID", "OP_PU_ID", "OP_PU_CODE", "OP_SUB_PU_ID", "OP_SUB_PU_CODE", "OP_AREA_ID", "OP_AREA_CODE", "OP_SUB_AREA_ID", "OP_SUB_AREA_CODE", "OP_FCTY_CLASS_2_ID", "OP_FCTY_CLASS_2_CODE", "OP_FCTY_CLASS_1_ID", "OP_FCTY_CLASS_1_CODE", "TOOLTIP", "HC_LIQ_PHASE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "TEXT_21", "TEXT_22", "TEXT_23", "TEXT_24", "TEXT_25", "TEXT_26", "TEXT_27", "TEXT_28", "TEXT_29", "TEXT_30", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "GROUP_REF_ID_1", "GROUP_REF_CODE_1", "GROUP_REF_ID_2", "GROUP_REF_CODE_2", "GROUP_REF_ID_3", "GROUP_REF_CODE_3", "GROUP_REF_ID_4", "GROUP_REF_CODE_4", "GROUP_REF_ID_5", "GROUP_REF_CODE_5", "GROUP_REF_ID_6", "GROUP_REF_CODE_6", "GROUP_REF_ID_7", "GROUP_REF_CODE_7", "GROUP_REF_ID_8", "GROUP_REF_CODE_8", "GROUP_REF_ID_9", "GROUP_REF_CODE_9", "GROUP_REF_ID_10", "GROUP_REF_CODE_10", "CP_AREA_CODE", "CP_AREA_ID", "CP_COL_POINT_CODE", "CP_COL_POINT_ID", "CP_OPERATOR_ROUTE_CODE", "CP_PU_CODE", "CP_PU_ID", "CP_SUB_AREA_CODE", "CP_SUB_AREA_ID", "CP_SUB_PU_CODE", "CP_SUB_PU_ID", "CP_OPERATOR_ROUTE_ID", "REF_SEASONAL_STREAM_ID", "DESCRIPTION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_strm_version_hist.sql
-- View name: v_strm_version_hist
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 27.10.2015 wonggkai   ECPD-30931:Intial version
----------------------------------------------------------------------------------------------------
	SELECT "JN_UPD_CREATE_DATE","JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DAYTIME","END_DATE","NAME","STREAM_CATEGORY","STREAM_TYPE","STREAM_PHASE","STREAM_CATEGORY_ID","FROM_NODE_ID","TO_NODE_ID","STRM_METER_FREQ","STRM_METER_METHOD","AGGREGATE_FLAG","PRODUCTION_DAY_ID","PURPOSE","REPORTING_CATEGORY","PRODUCT_ID","ALLOC_FLAG","ALLOC_FIXED","ALLOC_PERIOD","ALLOC_DATA_FREQ","SPECIFIC_GRAVITY_METHOD","BSW_WT_METHOD","BSW_VOL_METHOD","NET_VOL_METHOD","NET_MASS_METHOD","GRS_MASS_METHOD","GRS_VOL_METHOD","WATER_VOL_METHOD","WATER_MASS_METHOD","STD_DENS_METHOD","STD_GRS_DENS_METHOD","ENERGY_METHOD","CGR_METHOD","WGR_METHOD","WDF_METHOD","GCV_METHOD","GOR_METHOD","COND_VOL_METHOD","SALT_WT_METHOD","VAPOUR_RECOVERY_METHOD","VCF_METHOD","COMP_SET_CODE","ON_STREAM_METHOD","REF_GAS_CONST_STD_ID","REF_GAS_FLUID_STATE","REF_OIL_CONST_STD_ID","REF_OIL_FLUID_STATE","DIAGRAM_LAYOUT_INFO","COMMENTS","REF_ANALYSIS_STREAM_ID","REF_BITUMEN_STREAM_ID","REF_DILUENT_STREAM_ID","REF_ORF_STREAM_ID","AGA_REF_ANALYSIS_ID","DISPOSITION_TYPE_ID","CONVERSION_GROUP_ID","MASTER_SYS_NAME","STRM_BAL_CATEGORY","REF_ALLOC_STREAM_ID","COMMERCIAL_ENTITY_ID","FORMULA_EDITOR_FLAG","FIELD_REF_ID","OP_PU_ID","OP_PU_CODE","OP_SUB_PU_ID","OP_SUB_PU_CODE","OP_AREA_ID","OP_AREA_CODE","OP_SUB_AREA_ID","OP_SUB_AREA_CODE","OP_FCTY_CLASS_2_ID","OP_FCTY_CLASS_2_CODE","OP_FCTY_CLASS_1_ID","OP_FCTY_CLASS_1_CODE","TOOLTIP","HC_LIQ_PHASE","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","TEXT_11","TEXT_12","TEXT_13","TEXT_14","TEXT_15","TEXT_16","TEXT_17","TEXT_18","TEXT_19","TEXT_20","TEXT_21","TEXT_22","TEXT_23","TEXT_24","TEXT_25","TEXT_26","TEXT_27","TEXT_28","TEXT_29","TEXT_30","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","GROUP_REF_ID_1","GROUP_REF_CODE_1","GROUP_REF_ID_2","GROUP_REF_CODE_2","GROUP_REF_ID_3","GROUP_REF_CODE_3","GROUP_REF_ID_4","GROUP_REF_CODE_4","GROUP_REF_ID_5","GROUP_REF_CODE_5","GROUP_REF_ID_6","GROUP_REF_CODE_6","GROUP_REF_ID_7","GROUP_REF_CODE_7","GROUP_REF_ID_8","GROUP_REF_CODE_8","GROUP_REF_ID_9","GROUP_REF_CODE_9","GROUP_REF_ID_10","GROUP_REF_CODE_10","CP_AREA_CODE","CP_AREA_ID","CP_COL_POINT_CODE","CP_COL_POINT_ID","CP_OPERATOR_ROUTE_CODE","CP_PU_CODE","CP_PU_ID","CP_SUB_AREA_CODE","CP_SUB_AREA_ID","CP_SUB_PU_CODE","CP_SUB_PU_ID","CP_OPERATOR_ROUTE_ID","REF_SEASONAL_STREAM_ID","DESCRIPTION","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,'CURRENT' jn_operation
		,NVL(last_updated_by,created_by) jn_oracle_user
		,NVL(LAST_UPDATED_DATE,created_date) jn_datetime
		,'CURRENT' jn_notes
		,NULL jn_appln
		,NULL jn_session
		,strm_version.*
	  FROM strm_version
	  UNION
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,strm_version_jn.*
	  FROM strm_version_jn
	)
)