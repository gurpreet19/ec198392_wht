INSERT INTO CLASS_REL_PROPERTY_CNFG (FROM_CLASS_NAME, TO_CLASS_NAME, ROLE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('PORT','FCST_STOR_LIFT_NOM','PORT','viewhidden',2500,'/EC','STATIC_PRESENTATION','true');

UPDATE CLASS_ATTR_PROPERTY_CNFG
SET PROPERTY_VALUE = 1350
WHERE CLASS_NAME = 'FCST_STOR_LIFT_NOM' AND ATTRIBUTE_NAME = 'NOM_DATE_TIME' AND PROPERTY_CODE = 'SCREEN_SORT_ORDER' AND OWNER_CNTX = 2500;

commit;

exec ecdp_viewlayer.buildviewlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('FCST_STOR_LIFT_NOM', p_force => 'Y'); 