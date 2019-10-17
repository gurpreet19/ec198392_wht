Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('WELL_DEFERMENT','REASON_CODE_1','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_popup.xml');
  
Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('WELL_DEFERMENT','REASON_CODE_1','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.REASON_CODE_1=ReturnField.CODE');
commit;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('WELL_DEFERMENT');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('WELL_DEFERMENT') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('WELL_DEFERMENT') ;
