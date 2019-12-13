INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('WELL_CHRONOLOGY', 'WELL_CHRON_CODE_CAT', 'IS_MANDATORY', 2500, '/', 'VIEWLAYER', 'N');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('WELL_CHRONOLOGY', 'WELL_CHRON_CODE_CAT', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION', 'true');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('WELL_CHRONOLOGY', 'WELL_CHRON_CODE', 'PopupQueryURL', 2500, '/EC', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/query/ec_code_popup.xml');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('WELL_CHRONOLOGY', 'WELL_CHRON_CODE', 'PopupDependency', 2500, '/EC', 'STATIC_PRESENTATION', 'Screen.this.currentRow.WELL_CHRON_CODE=ReturnField.CODE');

UPDATE PROSTY_CODES
SET IS_ACTIVE = 'N'
WHERE CODE_TYPE = 'WELL_CHRON_CODE' AND CODE <> 'CHOKE_ADJ';

COMMIT;

exec ecdp_viewlayer.buildviewlayer('WELL_CHRONOLOGY', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('WELL_CHRONOLOGY', p_force => 'Y'); 