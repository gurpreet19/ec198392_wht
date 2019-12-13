insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values('IWEL_DAY_STATUS_STEAM', 'INJ_VOL_2', 'viewlabelhead', '2500', '/EC', 'STATIC_PRESENTATION', 'Injected Steam');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('IWEL_DAY_STATUS_STEAM','INJ_VOL_2','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','710');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('IWEL_DAY_STATUS_STEAM','INJ_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','600');


UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('IWEL_DAY_STATUS_STEAM');

commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('IWEL_DAY_STATUS_STEAM',p_force => 'Y');
EXECUTE EcDp_Viewlayer.BuildReportLayer('IWEL_DAY_STATUS_STEAM',p_force => 'Y');