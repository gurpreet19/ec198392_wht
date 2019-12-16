update class_attr_property_cnfg set PROPERTY_VALUE='/FrontController/com.ec.wheatstone.screens/port_resource_popup_nav_link' where class_name='CT_PORT_RESOURCE_OFF' and attribute_name='OBJECT_ID' and property_code='PopupURL';

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'CT_PORT_RESOURCE_OFF');
commit;

execute ecdp_viewlayer.buildviewlayer('CT_PORT_RESOURCE_OFF', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('CT_PORT_RESOURCE_OFF', p_force => 'Y'); 

commit;