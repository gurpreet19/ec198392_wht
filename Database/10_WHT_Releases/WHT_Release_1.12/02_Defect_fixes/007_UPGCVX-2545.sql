update class_attr_property_cnfg set PROPERTY_VALUE='Open Liq Vol' where  class_name='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='OPENING_GRS_VOL' AND PROPERTY_CODE='LABEL'and OWNER_CNTX=2500;
update class_attr_property_cnfg set PROPERTY_VALUE='Closing' where  class_name='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CLOSING_GRS_VOL' AND PROPERTY_CODE='LABEL'and OWNER_CNTX=2500;


Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'TANK_DAY_INV_OIL');
commit;
exec ecdp_viewlayer.BuildViewLayer(p_class_name => 'TANK_DAY_INV_OIL',p_force => 'Y');

exec  EcDp_Viewlayer.BuildReportLayer(p_class_name => 'TANK_DAY_INV_OIL',p_force => 'Y')
commit;