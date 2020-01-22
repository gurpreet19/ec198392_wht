insert INTO class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE )
VALUES ('PROD_TEST_RESULT','ACCEPTED_DATE','viewhidden','2500','/EC','STATIC_PRESENTATION','true');
  
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name = 'PROD_TEST_RESULT';
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('PROD_TEST_RESULT',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('PROD_TEST_RESULT',p_force => 'Y');

commit;
