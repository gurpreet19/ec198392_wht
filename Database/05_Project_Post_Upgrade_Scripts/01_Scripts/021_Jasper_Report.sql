--Update Valid Directory
update ctrl_property_meta
set DEFAULT_VALUE_STRING = 'D:\EnergyComponents\WHEATSTONE_CI\wildfly-14.0.1.Final\web-resources'
where key = 'com/ec/frmw/valid-directories'; 

--Report Configuration
UPDATE REPORT_DEFINITION_PARAM
SET PARAMETER_VALUE       = REPLACE(PARAMETER_VALUE,'/Cargo_Documents/','/web-resources/reports/')
WHERE PARAMETER_NAME      ='JRXML'
AND REPORT_DEFINITION_NO IN
(SELECT REPORT_DEFINITION_NO
FROM REPORT_DEFINITION
WHERE TEMPLATE_CODE IN ('COQ_COND', 'COA_COND', 'ASB_COND', 'ASB_LNG', 'BOL_COND', 'BOL_LNG', 'CAM_COND', 'CAM_LNG', 'CAT_COND', 'CAT_LNG', 'COA_LNG', 'COO_COND', 'COO_LNG', 'COQ_LNG', 'NCR_COND', 'NCR_LNG', 'RFD_COND', 'RFD_LNG', 'RFS_COND', 'RFS_LNG', 'SOC_LNG'));
COMMIT;
