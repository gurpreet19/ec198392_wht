INSERT INTO class_attr_property_cnfg  (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE )
VALUES ('LIFTING_ACTIVITY_CODE','TIMELINE_CODE','viewhidden','2500','/EC','STATIC_PRESENTATION','true');
  
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('LIFTING_ACTIVITY_CODE');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('LIFTING_ACTIVITY_CODE',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('LIFTING_ACTIVITY_CODE',p_force => 'Y');
commit;
