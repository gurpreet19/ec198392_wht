
update CLASS_TRIGGER_ACTN_CNFG
   set DB_SQL_SYNTAX='EcBp_CalculateAPI.calcApiVal(n_OBJECT_ID,n_DAYTIME,n_MEASUREMENT_EVENT_TYPE,n_LAST_UPDATED_BY);'
 where class_name = 'TANK_OIL_BATCH_EXP_DET' 
   and triggering_event = 'INSERTING OR UPDATING' 
   and trigger_type = 'AFTER' 
   and sort_order = 100;
   
commit;  
   
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('TANK_OIL_BATCH_EXP_DET');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('TANK_OIL_BATCH_EXP_DET') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('TANK_OIL_BATCH_EXP_DET') ;