

--RV_CT_PWEL_MTH_ALLOC_RBF
--------------------------


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_MTH_ALLOC_RBF','ALLOC_WATER_VOL','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_MTH_ALLOC_RBF','ALLOC_WATER_VOL_TTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_MTH_ALLOC_RBF','ALLOC_WATER_VOL_YTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_PWEL_MTH_ALLOC_RBF');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PWEL_MTH_ALLOC_RBF') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PWEL_MTH_ALLOC_RBF') ;

--RV_CT_STRM_DAY_STREAM
------------------------


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','GRS_WATER_VOL','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','GRS_WATER_VOL_MTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','GRS_WATER_VOL_QTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','GRS_WATER_VOL_YTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','NET_WATER_VOL','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','NET_WATER_VOL_MTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','NET_WATER_VOL_QTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_DAY_STREAM','NET_WATER_VOL_YTD','UOM_CODE',2500,'/','VIEWLAYER','WATER_VOL');

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_STRM_DAY_STREAM');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_STRM_DAY_STREAM') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_STRM_DAY_STREAM') ;

--RV_CT_STRM_EVENT
-------------------

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_EVENT','DAILY_RATE','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_EVENT','GRS_MASS','UOM_CODE',2500,'/','VIEWLAYER','OIL_MASS');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_EVENT','GRS_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_EVENT','MANUAL_ADJ_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_STRM_EVENT','TICKET_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL');  

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_STRM_EVENT');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_STRM_EVENT') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_STRM_EVENT') ;

--RV_CT_PWEL_DAY_STATUS_RBF
----------------------------


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','THEOR_GAS_RATE','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_VOL_RATE');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','ANNULUS_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_ANNULUS_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_BH_PRESS_2','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_COND_RATE','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_TUBING_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_WH_DSC_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_WH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PWEL_DAY_STATUS_RBF','AVG_WH_USC_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_PWEL_DAY_STATUS_RBF');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PWEL_DAY_STATUS_RBF') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PWEL_DAY_STATUS_RBF') ;

--RV_CT_IWEL_DAY_STATUS_RBF
----------------------------


Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_IWEL_DAY_STATUS_RBF','AVG_BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','CVX','N','NUMBER','FUNCTION','(NVL (ec_webo_split_factor.gas_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_Status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.gas_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.gas_inj_pct (cv_iwel_day_Status_rbf.perf_interval_id,cv_iwel_day_Status_rbf.daytime,''<=''),100)*DECODE (cv_iwel_day_status_rbf.inj_type, ''GI'', cv_iwel_day_Status_rbf.inj_rate, NULL))/ 1000000' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','(NVL (ec_webo_split_factor.gas_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_Status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.gas_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.gas_inj_pct (cv_iwel_day_Status_rbf.perf_interval_id,cv_iwel_day_Status_rbf.daytime,''<=''),100)*DECODE (cv_iwel_day_status_rbf.inj_type, ''GI'', cv_iwel_day_Status_rbf.inj_rate, NULL))/ 1000000' from dual) where c.class_name = 'CT_IWEL_DAY_STATUS_RBF' and c.attribute_name = 'RBF_ALLOC_GAS_RATE';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','DESCRIPTION',2500,'/EC','APPLICATION','RBF Alloc Gas Rate' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','DB_SORT_ORDER',2500,'/','VIEWLAYER','8500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','LABEL',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','8500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_RATE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','CVX','N','NUMBER','FUNCTION','(NVL (ec_webo_split_factor.gas_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_webo_interval_gor.gas_inj_pct (cv_iwel_day_Status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.gas_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * (ec_iwel_day_alloc.alloc_inj_vol (cv_iwel_day_status_rbf.object_id, cv_iwel_day_Status_rbf.daytime,''GI'')))/ 1000000' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','(NVL (ec_webo_split_factor.gas_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_webo_interval_gor.gas_inj_pct (cv_iwel_day_Status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.gas_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * (ec_iwel_day_alloc.alloc_inj_vol (cv_iwel_day_status_rbf.object_id, cv_iwel_day_Status_rbf.daytime,''GI'')))/ 1000000' from dual) where c.class_name = 'CT_IWEL_DAY_STATUS_RBF' and c.attribute_name = 'RBF_ALLOC_GAS_VOL';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','DESCRIPTION',2500,'/EC','APPLICATION','RBF Alloc Gas Vol' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','DB_SORT_ORDER',2500,'/','VIEWLAYER','8700' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','LABEL',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','8700' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_GAS_VOL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','CVX','N','NUMBER','FUNCTION','(NVL (ec_webo_split_factor.wat_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* (ec_iwel_day_alloc.alloc_inj_vol (cv_iwel_day_status_rbf.object_id,cv_iwel_day_status_rbf.daytime,''WI'' )))/1000000' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','(NVL (ec_webo_split_factor.wat_inj_pct (cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* (ec_iwel_day_alloc.alloc_inj_vol (cv_iwel_day_status_rbf.object_id,cv_iwel_day_status_rbf.daytime,''WI'' )))/1000000' from dual) where c.class_name = 'CT_IWEL_DAY_STATUS_RBF' and c.attribute_name = 'RBF_ALLOC_WATER_VOL';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','DESCRIPTION',2500,'/EC','APPLICATION','RBF Alloc Water Vol' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','DB_SORT_ORDER',2500,'/','VIEWLAYER','8800' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_LIQ_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','LABEL',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','8800' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WATER_VOL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','CVX','N','NUMBER','FUNCTION','(NVL (ec_webo_split_factor.wat_inj_pct(cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_Status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* DECODE (cv_iwel_day_status_rbf.inj_type, ''WI'',cv_iwel_day_status_rbf.inj_rate,NULL))/ 1000000' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','(NVL (ec_webo_split_factor.wat_inj_pct(cv_iwel_day_status_rbf.well_id,cv_iwel_day_status_rbf.well_bore_id,cv_iwel_day_Status_rbf.daytime,''<=''),100)* NVL (ec_webo_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.well_bore_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100) * NVL (ec_perf_interval_gor.wat_inj_pct (cv_iwel_day_status_rbf.perf_interval_id,cv_iwel_day_status_rbf.daytime,''<=''),100)* DECODE (cv_iwel_day_status_rbf.inj_type, ''WI'',cv_iwel_day_status_rbf.inj_rate,NULL))/ 1000000' from dual) where c.class_name = 'CT_IWEL_DAY_STATUS_RBF' and c.attribute_name = 'RBF_ALLOC_WAT_RATE';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','DESCRIPTION',2500,'/EC','APPLICATION','RBF Alloc Water Rate' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','DB_SORT_ORDER',2500,'/','VIEWLAYER','8600' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','UOM_CODE',2500,'/','VIEWLAYER','STD_LIQ_VOL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','LABEL',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','8600' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_IWEL_DAY_STATUS_RBF','RBF_ALLOC_WAT_RATE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_IWEL_DAY_STATUS_RBF');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_IWEL_DAY_STATUS_RBF') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_IWEL_DAY_STATUS_RBF') ;