update class_attr_property_cnfg set property_value = '560' where class_name = 'STRM_DAY_STREAM_MEAS_OIL' and attribute_name = 'ALLOC_NET_VOL' and property_code = 'SCREEN_SORT_ORDER' ;
update class_attr_property_cnfg set property_value = '565' where class_name = 'STRM_DAY_STREAM_MEAS_OIL' and attribute_name = 'NET_MASS_OIL' and property_code = 'SCREEN_SORT_ORDER' ;
update class_attr_property_cnfg set property_value = '570' where class_name = 'STRM_DAY_STREAM_MEAS_OIL' and attribute_name = 'ALLOC_OIL_ENERGY' and property_code = 'SCREEN_SORT_ORDER' ;
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STRM_DAY_STREAM_MEAS_OIL');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STRM_DAY_STREAM_MEAS_OIL',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STRM_DAY_STREAM_MEAS_OIL',p_force => 'Y');

update class_attr_property_cnfg 
set property_value = 'Volume'
where class_name = 'STRM_DAY_STREAM_DER_OIL' and attribute_name = 'ALLOC_NET_VOL' and property_code = 'LABEL' and owner_cntx = '2500';

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STRM_DAY_STREAM_DER_OIL');
commit;

EXECUTE EcDp_Viewlayer.BuildViewLayer('STRM_DAY_STREAM_DER_OIL ',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STRM_DAY_STREAM_DER_OIL ',p_force => 'Y');
