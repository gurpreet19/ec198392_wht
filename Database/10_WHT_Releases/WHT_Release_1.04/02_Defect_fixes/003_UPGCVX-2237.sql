
Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PTST_PWEL_RESULT','GAS_RATE_ADJ','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE_WT');
commit;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_PTST_PWEL_RESULT');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PTST_PWEL_RESULT') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PTST_PWEL_RESULT') ;
