INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE ) VALUES( 'STRM_OIL_ANALYSIS', 'RVP','LABEL',2500,'/EC', 'APPLICATION', 'Reid vapour pressure');

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN('STRM_OIL_ANALYSIS');
commit;
exec ecdp_viewlayer.BuildViewLayer(p_class_name => 'STRM_OIL_ANALYSIS',p_force => 'Y');

exec  EcDp_Viewlayer.BuildReportLayer(p_class_name => 'STRM_OIL_ANALYSIS',p_force => 'Y');
commit;


