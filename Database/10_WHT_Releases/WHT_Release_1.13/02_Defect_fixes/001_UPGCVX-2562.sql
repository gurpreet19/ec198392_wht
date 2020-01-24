UPDATE class_attribute_cnfg 
set db_sql_syntax ='nvl(STORAGE_LIFT_NOMINATION.DATE_3,START_LIFTING_DATE - UE_CT_LEADTIME.calc_ETA_LT(STORAGE_LIFT_NOMINATION.OBJECT_ID,STORAGE_LIFT_NOMINATION.PARCEL_NO,NULL,''STOR''))'
Where class_name = 'STORAGE_LIFT_NOMINATION'
and attribute_name = 'ETA';

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STORAGE_LIFT_NOMINATION');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STORAGE_LIFT_NOMINATION') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STORAGE_LIFT_NOMINATION');

commit;
 
