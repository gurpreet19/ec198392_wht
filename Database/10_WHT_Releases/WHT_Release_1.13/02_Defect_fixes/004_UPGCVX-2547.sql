insert INTO class_attr_property_cnfg  (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE )
VALUES ('RESV_BLOCK_FORMATION','CALC_RULE_ID','viewhidden','2500','/EC','STATIC_PRESENTATION','false');
  
  
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('RESV_BLOCK_FORMATION');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('RESV_BLOCK_FORMATION',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('RESV_BLOCK_FORMATION',p_force => 'Y');

commit;