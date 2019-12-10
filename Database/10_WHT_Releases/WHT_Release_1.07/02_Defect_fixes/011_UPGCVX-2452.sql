insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values('IWEL_DAY_STATUS_STEAM', 'INJ_VOL_2', 'viewlabelhead', '2500', '/EC', 'STATIC_PRESENTATION', 'Injected Steam');

update class_attr_property_cnfg
set property_value = '710', OWNER_CNTX = '2500' where class_name = 'IWEL_DAY_STATUS_STEAM' and attribute_name = 'INJ_VOL_2' and property_code = 'SCREEN_SORT_ORDER';

update class_attr_property_cnfg
set property_value = '600', OWNER_CNTX = '2500' where class_name = 'IWEL_DAY_STATUS_STEAM' and attribute_name = 'INJ_VOL' and property_code = 'SCREEN_SORT_ORDER';


UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('IWEL_DAY_STATUS_STEAM');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('IWEL_DAY_STATUS_STEAM',p_force => 'Y');
EXECUTE EcDp_Viewlayer.BuildReportLayer('IWEL_DAY_STATUS_STEAM',p_force => 'Y');