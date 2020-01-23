update class_attr_property_cnfg set PROPERTY_VALUE=8100 where  class_name='PWEL_DAY_STATUS' and ATTRIBUTE_NAME='WELL_NAME_2' AND PROPERTY_CODE='SCREEN_SORT_ORDER';

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'PWEL_DAY_STATUS');
commit;
exec ecdp_viewlayer.BuildViewLayer(p_class_name => 'PWEL_DAY_STATUS',p_force => 'Y');

exec  EcDp_Viewlayer.BuildReportLayer(p_class_name => 'PWEL_DAY_STATUS',p_force => 'Y');
commit;