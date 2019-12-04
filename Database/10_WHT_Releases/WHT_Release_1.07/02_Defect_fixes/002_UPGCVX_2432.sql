delete from class_attr_property_cnfg where class_name ='STRM_DAY_STREAM_DER_GAS' and attribute_name='NET_MASS_GAS' and PROPERTY_CODE='vieweditable' and owner_cntx=2500;

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'STRM_DAY_STREAM_DER_GAS');
commit;

execute ecdp_viewlayer.buildviewlayer('STRM_DAY_STREAM_DER_GAS', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('STRM_DAY_STREAM_DER_GAS', p_force => 'Y'); 

commit;