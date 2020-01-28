insert INTO class_attr_property_cnfg  (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE )
VALUES ('STREAM_SET_LIST','BALANCING_USAGE','viewhidden','2500','/EC','STATIC_PRESENTATION','true');
  
  
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STREAM_SET_LIST');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STREAM_SET_LIST',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STREAM_SET_LIST',p_force => 'Y');

commit;
