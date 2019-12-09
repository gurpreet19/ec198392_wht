insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('STRM_DAY_STREAM_MEAS_GAS',	'GRS_VOL_GAS'	,'viewlabelhead',	2500	,'/EC'	,'STATIC_PRESENTATION','');
insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('STRM_DAY_STREAM_MEAS_GAS',	'GRS_MASS_GAS'	,'viewlabelhead',	2500	,'/EC'	,'STATIC_PRESENTATION','');
update class_attr_property_cnfg set PROPERTY_VALUE =545 where class_name ='STRM_DAY_STREAM_MEAS_GAS' and attribute_name in ('NET_MASS_GAS') and property_code='SCREEN_SORT_ORDER' and owner_cntx=2500;
update class_attr_property_cnfg set PROPERTY_VALUE =1910 where class_name ='STRM_DAY_STREAM_MEAS_GAS' and attribute_name in ('ALLOC_GAS_MASS') and property_code='SCREEN_SORT_ORDER' and owner_cntx=2500;
insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('STRM_DAY_STREAM_MEAS_GAS',	'AVG_PRESS'	,'LABEL',	2500	,'/EC'	,'APPLICATION','Pressure');
insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('STRM_DAY_STREAM_MEAS_GAS',	'AVG_TEMP'	,'LABEL',	2500	,'/EC'	,'APPLICATION','Temperature');
Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'STRM_DAY_STREAM_MEAS_GAS');
commit;

execute ecdp_viewlayer.buildviewlayer('STRM_DAY_STREAM_MEAS_GAS', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('STRM_DAY_STREAM_MEAS_GAS', p_force => 'Y'); 

commit;