INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('IWEL_DAY_STATUS_WATER', 'THEOR_WATER_RATE', 'LABEL', '2500', '/EC', 'APPLICATION', 'Theo Water');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('IWEL_DAY_STATUS_WATER', 'THEOR_WATER_RATE', 'viewlabelhead', '2500', '/EC', 'STATIC_PRESENTATION', NULL);

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('IWEL_DAY_STATUS_WATER');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('IWEL_DAY_STATUS_WATER',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('IWEL_DAY_STATUS_WATER',p_force => 'Y');
commit;
