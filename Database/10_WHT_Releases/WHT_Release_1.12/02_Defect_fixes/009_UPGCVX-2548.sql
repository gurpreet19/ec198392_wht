update class_attr_property_cnfg set PROPERTY_VALUE=620 where  class_name='STRM_DAY_STREAM_MEAS_WAT' and ATTRIBUTE_NAME='GRS_VOL_TO_BE_USED' AND PROPERTY_CODE='SCREEN_SORT_ORDER';

update class_attr_property_cnfg set PROPERTY_VALUE=610 where  class_name='STRM_DAY_STREAM_MEAS_WAT' and ATTRIBUTE_NAME='IS_MEAS_ACTUAL_GRS_VOL' AND PROPERTY_CODE='SCREEN_SORT_ORDER';

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'STRM_DAY_STREAM_MEAS_WAT');
commit;
exec ecdp_viewlayer.BuildViewLayer(p_class_name => 'STRM_DAY_STREAM_MEAS_WAT',p_force => 'Y');

exec  EcDp_Viewlayer.BuildReportLayer(p_class_name => 'STRM_DAY_STREAM_MEAS_WAT',p_force => 'Y');
commit;


