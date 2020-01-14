
update CLASS_ATTRIBUTE_CNFG
set db_sql_syntax = 'TO_CHAR(TRUNC(START_LIFTING_DATE - UE_CT_LEADTIME.calc_ETA_LT(STOR_FCST_LIFT_NOM.OBJECT_ID,STOR_FCST_LIFT_NOM.PARCEL_NO,STOR_FCST_LIFT_NOM.FORECAST_ID),''MI''), ''YYYY-MM-DD"T"HH24:MI:SS'') || ''S'''
where class_name = 'FCST_STOR_LIFT_NOM'
and attribute_name = 'ETA_CALC';

commit;

execute ecdp_viewlayer.buildviewlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 
