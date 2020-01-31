update CLASS_ATTR_PROPERTY_CNFG
set property_value='true'
where property_code='vieweditable' and class_name='FCST_STOR_LIFT_NOM'and attribute_name='NOM_VALID';
commit;

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE,REV_TEXT) 
values ('FCST_STOR_LIFT_NOM','NOM_VALID','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','UE_CT_TRAN_CP_PRES_SYNTAX.GetNomValidationResults(REFERENCE_LIFTING_NO, LIFTING_ACCOUNT_ID, FORECAST_ID)','Adding this for JIRA UPGCVX-2572');
commit;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('FCST_STOR_LIFT_NOM');
commit;

execute ecdp_viewlayer.buildviewlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 
commit;