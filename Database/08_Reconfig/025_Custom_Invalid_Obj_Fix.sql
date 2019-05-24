--DV_CT_MSG_CNQ

UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='ROUND(EcDp_Unit.ConvertValue(WPT_ENERGY, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_CNQ'',''WPT_ENERGY'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''),2)' WHERE CLASS_NAME='CT_MSG_CNQ' AND ATTRIBUTE_NAME='WPT_ENERGY';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='ROUND(EcDp_Unit.ConvertValue(LNG_ENERGY, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_CNQ'',''LNG_ENERGY'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''),2)' WHERE CLASS_NAME='CT_MSG_CNQ' AND ATTRIBUTE_NAME='LNG_ENERGY';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='ROUND(EcDp_Unit.ConvertValue(DG_ENERGY, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_CNQ'',''DG_ENERGY'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''),2)' WHERE CLASS_NAME='CT_MSG_CNQ' AND ATTRIBUTE_NAME='DG_ENERGY';

--DV_CT_PORT_RESOURCE_OFF
UPDATE CLASS_CNFG SET DB_OBJECT_NAME='DEFERMENT_EVENT' , DB_WHERE_CONDITION='EVENT_TYPE=''CT_PORT_RESOURCE_OFF''' WHERE CLASS_NAME='CT_PORT_RESOURCE_OFF';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='EVENT_TYPE' WHERE CLASS_NAME='CT_PORT_RESOURCE_OFF' AND ATTRIBUTE_NAME='DOWNTIME_CATEG';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='DEFERMENT_TYPE' WHERE CLASS_NAME='CT_PORT_RESOURCE_OFF' AND ATTRIBUTE_NAME='DOWNTIME_CLASS_TYPE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='TRUNC(DEFERMENT_EVENT.END_DATE)' WHERE CLASS_NAME='CT_PORT_RESOURCE_OFF' AND ATTRIBUTE_NAME='PROD_DAY_END';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='TRUNC(DEFERMENT_EVENT.DAYTIME)' WHERE CLASS_NAME='CT_PORT_RESOURCE_OFF' AND ATTRIBUTE_NAME='PROD_DAY_START';

--DV_CT_MSG_ENQ--RV_CT_MSG_ENQ
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(ec_nompnt_day_availability.value_19(cv_msg_enq.nompnt_id, cv_msg_enq.daytime, ''CT_TRNP_DAY_FCST''), EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''BORROW_LOAN_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''),2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='BORROW_LOAN_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' THEN ROUND(EcDp_Unit.ConvertValue(cv_msg_enq.value_29, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''DG_ENE_ENQ'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='DG_ENE_ENQ';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' THEN ROUND(EcDp_Unit.ConvertValue(cv_msg_enq.value_28, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''DG_ENE_PROD'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='DG_ENE_PROD';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_23, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''LNG_ADP_REQ_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='LNG_ADP_REQ_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_49, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''LNG_REF_PROD_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='LNG_CONF_EXC_QTY_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_25, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''LNG_ENE_ENQ'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='LNG_ENE_ENQ';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_48, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''LNG_REF_PROD_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='LNG_REF_PROD_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_20, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''LNG_TRAIN_RUN_DOWN_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='LNG_TRAIN_RUN_DOWN_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue(VALUE_60, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''UNMET_AMOUNT_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='NGI_ADJ_OUTLET_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue( VALUE_52, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''UNMET_AMOUNT_ENE'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='UNMET_AMOUNT_ENE';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='CASE WHEN cv_msg_enq.nomination_type = ''TRAN_INPUT'' AND cv_msg_enq.contract_level = ''UPG'' THEN ROUND(EcDp_Unit.ConvertValue( VALUE_32, EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(''CT_MSG_ENQ'',''WPT_ENE_ENQ'',''UOM_CODE'',''VIEWLAYER'',2500,''/'')), ''TJ''), 2) END' WHERE CLASS_NAME='CT_MSG_ENQ' AND ATTRIBUTE_NAME='WPT_ENE_ENQ';

--UE_CT_WELL_EQPM_DOWNTIME--IV_EQUIPMENT_JN
DROP VIEW IV_EQUIPMENT_JN;
DROP PACKAGE UE_CT_WELL_EQPM_DOWNTIME;

--PRICE_INDEX_YR_VALUE
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='ec_price_in_item_version.text_1(PRICE_IN_ITEM_VALUE.object_id, PRICE_IN_ITEM_VALUE.daytime, ''<='')' WHERE CLASS_NAME='PRICE_INDEX_YR_VALUE' AND ATTRIBUTE_NAME='PRICE_INDEX_TYPE'; 
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='ec_currency.object_code(ec_price_in_item_version.currency_id(PRICE_IN_ITEM_VALUE.object_id, PRICE_IN_ITEM_VALUE.daytime, ''<='')) ' WHERE CLASS_NAME='PRICE_INDEX_YR_VALUE' AND ATTRIBUTE_NAME='UNIT'; 

--IUD_CT_MSG_FORECAST_ENTS
CREATE OR REPLACE VIEW "CV_FCST_STORAGE_GRAPH" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "PROD_FCST_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (SELECT s.OBJECT_ID AS STORAGE_ID,
           sd.daytime,
           fv.OBJECT_ID,
           fv.REF_OBJECT_ID_1 AS PROD_FCST_ID,
           NULL AS RECORD_STATUS,
           NULL AS CREATED_BY,
           NULL AS CREATED_DATE,
           NULL AS LAST_UPDATED_BY,
           NULL AS LAST_UPDATED_DATE,
           NULL AS REV_NO,
           NULL AS REV_TEXT,
           NULL AS APPROVAL_STATE,
           NULL AS APPROVAL_BY,
           NULL AS APPROVAL_DATE,
           NULL AS REC_ID
      FROM FORECAST f
           INNER JOIN FORECAST_VERSION fv ON f.object_id = fv.object_id
           INNER JOIN
           STORAGE s
              ON (   f.STORAGE_ID = s.OBJECT_ID
                  OR (    f.STORAGE_ID IS NULL
                      AND s.OBJECT_ID IN
                             (SELECT DISTINCT STORAGE_ID FROM LIFTING_ACCOUNT)))
           INNER JOIN
           (SELECT (SELECT MIN (START_DATE) FROM FORECAST) + ROWNUM - 1
                      AS DAYTIME
              FROM user_objects
             WHERE ROWNUM <=
                      (SELECT MAX (END_DATE) - MIN (START_DATE) FROM FORECAST)) sd
              ON     sd.daytime >= fv.daytime
                 AND sd.daytime < NVL (fv.end_date, f.end_date));
/