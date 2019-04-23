--Issue Fixes
/*****************************************************************************************************************/
-- Below update query updates 5 records for which DB SQL Syntax has to be changed. 
-- resv_block_formation_id has been moved from PERF_INTERNAL to PERF_INTERVAL_VERSION. 
/*****************************************************************************************************************/
update CLASS_ATTRIBUTE_CNFG
 set DB_SQL_SYNTAX = 'ECDP_OBJECTS.GETOBJCODE(EC_RESV_BLOCK_FORMATION.RESV_FORMATION_ID(oa.resv_block_formation_id))'
where DB_SQL_SYNTAX = 'ECDP_OBJECTS.GETOBJCODE(EC_RESV_BLOCK_FORMATION.RESV_FORMATION_ID(o.resv_block_formation_id))';

update CLASS_ATTRIBUTE_CNFG
 set DB_SQL_SYNTAX = 'ECDP_OBJECTS.GETOBJNAME(EC_RESV_BLOCK_FORMATION.RESV_FORMATION_ID(oa.resv_block_formation_id),oa.daytime)'
where DB_SQL_SYNTAX = 'ECDP_OBJECTS.GETOBJNAME(EC_RESV_BLOCK_FORMATION.RESV_FORMATION_ID(o.resv_block_formation_id),oa.daytime)';

UPDATE class_attribute_cnfg
  SET DB_SQL_SYNTAX = 'DATE_8'
WHERE class_name IN ( 'CT_MSG_FORECAST_LIFTINGS','CT_MSG_CARGO_LIFTING','CT_MSG_CARGO')
  AND attribute_name = 'NOM_FIRM_DATE_TIME';
  
 UPDATE class_attribute_cnfg
  SET DB_SQL_SYNTAX = 'DATE_9'
WHERE class_name IN ( 'CT_MSG_FORECAST_LIFTINGS','CT_MSG_CARGO_LIFTING','CT_G_STOR_LIFT_ACTUAL')
  AND attribute_name = 'BL_DATE_TIME';
  
UPDATE class_attribute_cnfg
  SET DB_SQL_SYNTAX = 'decode(ec_forecast_version.TEXT_5(STOR_FCST_LIFT_NOM.FORECAST_ID, STOR_FCST_LIFT_NOM.NOM_FIRM_DATE , ''<=''),''V'',STOR_FCST_LIFT_NOM.DATE_5,''A'',STOR_FCST_LIFT_NOM.DATE_5,nvl(STOR_FCST_LIFT_NOM.DATE_3,DATE_8 - UE_CT_LEADTIME.calc_ETA_LT(STOR_FCST_LIFT_NOM.OBJECT_ID,STOR_FCST_LIFT_NOM.PARCEL_NO,STOR_FCST_LIFT_NOM.FORECAST_ID)))'
WHERE class_name IN ( 'CT_MSG_FORECAST_LIFTINGS')
  AND attribute_name = 'EST_ARRIVAL_TIME';

  
update CLASS_CNFG
set DB_WHERE_CONDITION = null
where CLASS_NAME = 'CT_MSG_CARGO_TIMESHEET';

update CLASS_ATTRIBUTE_CNFG
set DB_SQL_SYNTAX = 'ec_lifting_activity_code.activity_name(LIFTING_ACTIVITY.ACTIVITY_CODE,''LOAD'')'
where  CLASS_NAME = 'CT_MSG_CARGO_TIMESHEET' and attribute_name = 'ACTIVITY_NAME';

