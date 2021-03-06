--screen navigation
UPDATE CTRL_PROPERTY_META SET DEFAULT_VALUE_STRING='PRODUCTIONUNIT' WHERE  key ='CUSTOM_TARGET_MANDATORY_OP'; 
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getParentEventLossRate(event_no, ''COND'', deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','Cond Event Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','3010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','3010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','WST','','NUMBER','FUNCTION','COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','Cond Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','COND_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','Cond Potential Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','COND_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getParentEventLossRate(event_no, ''GAS'', deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','Gas Event Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','WST','','NUMBER','FUNCTION','GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','Gas Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','Gas Potential Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','GAS_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT','NO_LOSS_FLAG','WST','','STRING','COLUMN','TEXT_3' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','DESCRIPTION',2500,'/EC','APPLICATION','No Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','DB_SORT_ORDER',2500,'/','VIEWLAYER','1150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','LABEL',2500,'/EC','APPLICATION','Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','viewtype',2500,'/EC','STATIC_PRESENTATION','checkbox' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','NO_LOSS_FLAG','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','No' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getEventLossRate(DEFERMENT_EVENT.event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','WST','','NUMBER','FUNCTION','DEFERMENT_EVENT.COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getEventLossRate(DEFERMENT_EVENT.event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','WST','','NUMBER','FUNCTION','DEFERMENT_EVENT.GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','WST','','STRING','COLUMN','TEXT_3' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','DESCRIPTION',2500,'/EC','APPLICATION','No Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','DB_SORT_ORDER',2500,'/','VIEWLAYER','360' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','LABEL',2500,'/EC','APPLICATION','Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','360' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','viewtype',2500,'/EC','STATIC_PRESENTATION','checkbox' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_CHILD','NO_LOSS_FLAG','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','No' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_1','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_1','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','DEFER_SYS_GRP' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_1','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_1','viewwidth',2500,'/EC','STATIC_PRESENTATION','130' from dual;

-- REASON_CODE_1

UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='EXTERNAL';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='S_SUBSEA';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_CASING';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_ESP';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_GAS_LIFT';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_PACKER';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_PROG_CAVITY';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_RESERVOIR';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_ROD_PUMP';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_RODS_BEAM';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_RODS_PCP';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_SAND';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_MEASURE';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_VALVE_CHOKE';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_TUBING';
UPDATE PROSTY_CODES SET IS_ACTIVE='Y' WHERE CODE_TYPE='DEFER_SYS_GRP' AND CODE ='SS_OTHER';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupCache',2500,'/EC','STATIC_PRESENTATION','false' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','DEFER_CAUSE_GRP' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupDependency',2500,'/EC','STATIC_PRESENTATION','RetrieveArg.CODE_TYPE1=DEFER_SYS_GRP$RetrieveArg.CODE1=Screen.this.currentRow.REASON_CODE_1$Screen.this.currentRow.REASON_CODE_2=ReturnField.CODE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_dep_popup.xml' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','viewwidth',2500,'/EC','STATIC_PRESENTATION','130' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupCache',2500,'/EC','STATIC_PRESENTATION','false' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupDependency',2500,'/EC','STATIC_PRESENTATION','RetrieveArg.CODE_TYPE1=DEFER_CAUSE_GRP$RetrieveArg.CODE1=Screen.this.currentRow.REASON_CODE_2$Screen.this.currentRow.REASON_CODE_3=ReturnField.CODE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','DEFER_CAUSE_CAT' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','viewwidth',2500,'/EC','STATIC_PRESENTATION','130' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_dep_popup.xml' from dual;

UPDATE PROSTY_CODES SET IS_ACTIVE='N' WHERE CODE_TYPE='DEFER_CAUSE_CAT' AND CODE not in ('GAS_INJECTION','GAS_LIFT','GAS_SUPPLY','GAS_TREAT','EXPORT_STORAGE');
update tv_ec_codes set is_active = 'Y' where code_type = 'DEFER_CAUSE_CAT' and is_active = 'N';

--Class Attribute Properties
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','EQUIPMENT_ID','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','EQUIPMENT_ID','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.EQUIPMENT_ID=ReturnField.OBJECT_ID' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'MASTER_EVENT_ID', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','WORK_ORDER','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','750' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','STATUS','DISABLED_IND',2500,'/','VIEWLAYER','Y' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'STEAM_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'OIL_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'DILUENT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_LIFT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'STEAM_INJ_LOSS_RATE',  'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_INJ_LOSS_RATE',  'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'OIL_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'DILUENT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_LIFT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'STEAM_INJ_EVENT_LOSS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_INJ_EVENT_LOSS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_EVENT_LOSS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_INJ_EVENT_LOSS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'OIL_EVENT_LOSS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'DILUENT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_LIFT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

--WELL_DEFERMENT_CHILD
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getEventLossRate(DEFERMENT_EVENT.event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='COND_EVENT_LOSS_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getPotentialRate(event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='GAS_POTENTIAL_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getPotentialRate(event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='COND_POTENTIAL_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='deferment_event.GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='GAS_LOSS_RATE_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getEventLossRate(DEFERMENT_EVENT.event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='GAS_EVENT_LOSS_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='deferment_event.COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='WELL_DEFERMENT_CHILD' AND ATTRIBUTE_NAME='COND_LOSS_RATE_V';

--Object Type dropdown
update prosty_codes set is_active='N' where code_type='DEFER_OBJECT_TYPES' and code in ('OPERATOR_ROUTE','COLLECTION_POINT','WELL_HOOKUP');
update prosty_codes set sort_order=30 where code_type='DEFER_OBJECT_TYPES' and code='PROD_SUB_UNIT';
update prosty_codes set sort_order='60' where code_type='DEFER_OBJECT_TYPES' and code='SUB_AREA';
update prosty_codes set is_active='Y' where code_type='DEFER_OBJECT_TYPES' and code in ('FCTY_CLASS_2');


insert into ctrl_code_dependency (dependency_type,code_type1,code1,code_type2,code2) values ('WHATEVER','DEFER_GROUP_TYPES','operational','DEFER_OBJECT_TYPES','PROD_SUB_UNIT');
insert into ctrl_code_dependency (dependency_type,code_type1,code1,code_type2,code2) values ('WHATEVER','DEFER_GROUP_TYPES','operational','DEFER_OBJECT_TYPES','AREA');
insert into ctrl_code_dependency (dependency_type,code_type1,code1,code_type2,code2) values ('WHATEVER','DEFER_GROUP_TYPES','operational','DEFER_OBJECT_TYPES','SUB_AREA');


insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'COND_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'DILUENT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_LIFT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'GAS_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'OIL_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'STEAM_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'WATER_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','GAS_POTENTIAL','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS_RATE' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','COND_POTENTIAL','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS_RATE' from dual;

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_MASS_RATE' AND UNIT='LBSPERDAY';

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='LIQ_MASS_RATE' AND UNIT='LBSPERDAY';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','GAS_LOSS_RATE','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS_RATE' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','COND_LOSS_RATE','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS_RATE' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','GAS_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','COND_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'EVENT_TAG', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

--WELL_DEFERMENT_CHILD

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'DILUENT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_LIFT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'OIL_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'STEAM_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');
 
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS_RATE' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS_RATE' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'DILUENT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_LIFT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'OIL_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'STEAM_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS_RATE' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS_RATE' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'COND_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'DILUENT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_LIFT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'OIL_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'STEAM_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'DILUENT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'GAS_LIFT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'OIL_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'STEAM_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_CHILD', 'WATER_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS' from dual;

--BBO Changes
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'NEED_REVIEW', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT','EVENT_TYPE','LABEL',2500,'/EC','APPLICATION','LPO Type' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_BY_WELL','EVENT_TYPE','LABEL',2500,'/EC','APPLICATION','LPO Type' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'NEED_REVIEW', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','DOWNTIME_CLASS_TYPE','LABEL',2100,'/EC','APPLICATION','LPO Type' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','DOWNTIME_CLASS_TYPE','viewlabelhead',2100,'/EC','STATIC_PRESENTATION',null from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','OBJECT_TYPE','LABEL',2100,'/EC','APPLICATION','Asset Type' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','OBJECT_TYPE','viewlabelhead',2100,'/EC','STATIC_PRESENTATION','Production Asset Impacted by Event' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','OBJECT_ID','LABEL',2100,'/EC','APPLICATION','Asset Name' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','OBJECT_ID','viewlabelhead',2100,'/EC','STATIC_PRESENTATION','Production Asset Impacted by Event' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'EQUIP_DOWNTIME','REASON_CODE_2','LABEL',2100,'/EC','APPLICATION','What' from dual;


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax)
select 'EQUIP_DOWNTIME','NEED_REVIEW','CVX_ENH','','STRING','COLUMN','TEXT_9' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','DISABLED_IND',2100,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','DB_SORT_ORDER',2100,'/','VIEWLAYER','1220' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','IS_MANDATORY',2100,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','LABEL',2100,'/EC','APPLICATION','Codes Need Review' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','SCREEN_SORT_ORDER',2100,'/EC','APPLICATION','1220' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','viewtype',2100,'/EC','STATIC_PRESENTATION','checkbox' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','viewwidth',2100,'/EC','STATIC_PRESENTATION','100' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'EQUIP_DOWNTIME','NEED_REVIEW','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

UPDATE PROSTY_CODES SET SORT_ORDER=45 WHERE CODE_TYPE='EQPM_TYPE' AND CODE='EQUIPMENT_OTHER';

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','GAS_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( GAS_LOSS_RATE=GAS_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','COND_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( COND_LOSS_RATE=COND_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','DILUENT_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( DILUENT_LOSS_RATE=DILUENT_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','GAS_INJ_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( GAS_INJ_LOSS_RATE=GAS_INJ_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','GAS_LIFT_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( GAS_LIFT_LOSS_RATE=GAS_LIFT_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','OIL_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( OIL_LOSS_RATE=OIL_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','STEAM_INJ_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( STEAM_INJ_LOSS_RATE=STEAM_INJ_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','WATER_INJ_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( WATER_INJ_LOSS_RATE=WATER_INJ_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('WELL_DEFERMENT','WATER_LOSS_RATE','verificationText',2500,'/EC','DYNAMIC_PRESENTATION','CASE WHEN(( WATER_LOSS_RATE=WATER_POTENTIAL) AND EVENT_TYPE=''CONSTRAINT'')THEN ''Loss Rate is same as potential'' end');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'REASON_CODE_4', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'EVENT_TAG', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','WST','','STRING','COLUMN','TEXT_3' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','DESCRIPTION',2500,'/EC','APPLICATION','No Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','DB_SORT_ORDER',2500,'/','VIEWLAYER','1150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','LABEL',2500,'/EC','APPLICATION','Loss' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','No' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','NO_LOSS_FLAG','viewtype',2500,'/EC','STATIC_PRESENTATION','checkbox' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','WST','','STRING','FUNCTION','ec_prosty_codes.code_text(REASON_CODE_1, ''DEFER_SYS_GRP'')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','REPORT_ONLY_IND',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','DESCRIPTION',2500,'/EC','APPLICATION','Reason Code Text 1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','DB_SORT_ORDER',2500,'/','VIEWLAYER','3500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','LABEL',2500,'/EC','APPLICATION','Reason Code Text 1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','3500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_1_TEXT','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(V_DEF_EVENT_BY_WELL.event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getParentEventLossRate(V_DEF_EVENT_BY_WELL.event_no, ''COND'', deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getParentEventLossRate(V_DEF_EVENT_BY_WELL.event_no, ''GAS'', deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2410' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_EVENT_LOSS_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','WST','','NUMBER','FUNCTION','V_DEF_EVENT_BY_WELL.COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2010' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(V_DEF_EVENT_BY_WELL.event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_COND_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','UOM_CODE',2500,'/','VIEWLAYER','STD_OIL_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','LABEL',2500,'/EC','APPLICATION','Cond' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','COND_POTENTIAL_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','WST','','STRING','FUNCTION','ec_prosty_codes.code_text(REASON_CODE_2, ''DEFER_CAUSE_GRP'')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','REPORT_ONLY_IND',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','DESCRIPTION',2500,'/EC','APPLICATION','Reason Code Text 2' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','DB_SORT_ORDER',2500,'/','VIEWLAYER','3600' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','LABEL',2500,'/EC','APPLICATION','Reason Code Text 2' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','3600' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_2_TEXT','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','WST','','STRING','FUNCTION','ec_prosty_codes.code_text(REASON_CODE_3, ''DEFER_CAUSE_CAT'')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','REPORT_ONLY_IND',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','DESCRIPTION',2500,'/EC','APPLICATION','Reason Code Text 3' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','DB_SORT_ORDER',2500,'/','VIEWLAYER','3700' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','LABEL',2500,'/EC','APPLICATION','Reason Code Text 3' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','3700' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','REASON_CODE_3_TEXT','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','WST','','NUMBER','FUNCTION','V_DEF_EVENT_BY_WELL.GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(V_DEF_EVENT_BY_WELL.daytime,''LPO_GAS_DEN'',''<='')' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','DISABLED_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','IS_MANDATORY',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','REPORT_ONLY_IND',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','DESCRIPTION',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','DB_SORT_ORDER',2500,'/','VIEWLAYER','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','UOM_CODE',2500,'/','VIEWLAYER','STD_GAS_RATE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','LABEL',2500,'/EC','APPLICATION','Gas' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','1910' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','GAS_LOSS_RATE_V','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'DILUENT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_LIFT_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'OIL_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'STEAM_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_INJ_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_POTENTIAL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'PARENT_COMMENTS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'DILUENT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_LIFT_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'OIL_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'STEAM_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_INJ_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_LOSS_RATE', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'DILUENT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_LIFT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'OIL_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'STEAM_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_INJ_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'COND_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'DILUENT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_LIFT_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'GAS_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'OIL_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'STEAM_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_INJ_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT_BY_WELL', 'WATER_LOSS_VOLUME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT_BY_WELL','STATUS','DISABLED_IND',2500,'/','VIEWLAYER','Y' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'WELL_DEFERMENT_BY_WELL','WORK_ORDER','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','355' from dual;
