DELETE from class_attr_property_cnfg where class_name = 'IWEL_PERIOD_STATUS' and attribute_name = 'WELL_STATUS_REASON' AND PROPERTY_CODE = 'DISABLED_IND' AND OWNER_CNTX = '2000';

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('IWEL_PERIOD_STATUS');
commit;

EXECUTE EcDp_Viewlayer.BuildViewLayer('IWEL_PERIOD_STATUS',p_force => 'Y');
EXECUTE EcDp_Viewlayer.BuildReportLayer('IWEL_PERIOD_STATUS',p_force => 'Y');

commit;
