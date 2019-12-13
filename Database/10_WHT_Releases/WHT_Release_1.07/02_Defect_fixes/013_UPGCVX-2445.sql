Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('STRM_DAY_STREAM_MEAS_OIL','ALLOC_NET_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2650');


update class_attr_property_cnfg
set property_value = 565
where class_name = 'STRM_DAY_STREAM_MEAS_OIL' and property_code = 'SCREEN_SORT_ORDER' and attribute_name = 'NET_MASS_OIL'
and OWNER_CNTX=2500;

update class_attr_property_cnfg
set property_value = 3200
where class_name = 'STRM_DAY_STREAM_MEAS_OIL' and property_code = 'SCREEN_SORT_ORDER' and attribute_name = 'ALLOC_OIL_ENERGY'
and OWNER_CNTX=2500;


update class_attr_property_cnfg 
set property_value = 'Volume'
where class_name = 'STRM_DAY_STREAM_DER_OIL' and attribute_name = 'ALLOC_NET_VOL' and property_code = 'LABEL' and owner_cntx = '2500';



UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STRM_DAY_STREAM_MEAS_OIL');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STRM_DAY_STREAM_MEAS_OIL',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STRM_DAY_STREAM_MEAS_OIL',p_force => 'Y');

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STRM_DAY_STREAM_DER_OIL');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STRM_DAY_STREAM_DER_OIL',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STRM_DAY_STREAM_DER_OIL',p_force => 'Y');






