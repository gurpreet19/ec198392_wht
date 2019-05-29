--screen navigation
UPDATE CTRL_PROPERTY_META SET DEFAULT_VALUE_STRING='PRODUCTIONUNIT' WHERE  key ='CUSTOM_TARGET_MANDATORY_OP'; 
begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-COND_EVENT_LOSS_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-COND_LOSS_RATE_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-COND_POTENTIAL_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-GAS_EVENT_LOSS_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-GAS_LOSS_RATE_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-GAS_POTENTIAL_V');
end;
/
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

begin
dbms_output.put_line('WELL_DEFERMENT AND WELL_EQPM_LOW-NO_LOSS_FLAG');
end;
/
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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-COND_EVENT_LOSS_V');
end;
/

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getEventLossRate(WELL_EQUIP_DOWNTIME.event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_COND_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-COND_LOSS_RATE_V');
end;
/
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_LOSS_RATE_V','WST','','NUMBER','FUNCTION','well_equip_downtime.COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_COND_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-COND_POTENTIAL_V');
end;
/
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','COND_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_COND_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-GAS_EVENT_LOSS_V');
end;
/
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_EVENT_LOSS_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getEventLossRate(WELL_EQUIP_DOWNTIME.event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_GAS_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-GAS_LOSS_RATE_V');
end;
/
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_LOSS_RATE_V','WST','','NUMBER','FUNCTION','well_equip_downtime.GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_GAS_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-GAS_POTENTIAL_V');
end;
/
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'WELL_DEFERMENT_CHILD','GAS_POTENTIAL_V','WST','','NUMBER','FUNCTION','EcBp_Deferment.getPotentialRate(event_no, ''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(well_equip_downtime.daytime,''LPO_GAS_DEN'',''<='')' from dual;

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

begin
dbms_output.put_line('WELL_EQPM_OFF_CHILD AND WELL_EQPM_LOW_CHILD-NO_LOSS_FLAG');
end;
/
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

begin
dbms_output.put_line('REASON_CODE_1-REASON_CODE_1');
end;
/


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

begin
dbms_output.put_line('REASON_CODE_1-REASON_CODE_2');
end;
/
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupCache',2500,'/EC','STATIC_PRESENTATION','false' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','DEFER_CAUSE_GRP' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupDependency',2500,'/EC','STATIC_PRESENTATION','RetrieveArg.CODE_TYPE1=DEFER_SYS_GRP$RetrieveArg.CODE1=Screen.this.currentRow.REASON_CODE_1$Screen.this.currentRow.REASON_CODE_2=ReturnField.CODE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_dep_popup.xml' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','viewwidth',2500,'/EC','STATIC_PRESENTATION','130' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_2','LABEL',2500,'/EC','APPLICATION','Activity Type' from dual;

begin
dbms_output.put_line('REASON_CODE_1-REASON_CODE_3');
end;
/
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupCache',2500,'/EC','STATIC_PRESENTATION','false' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupDependency',2500,'/EC','STATIC_PRESENTATION','RetrieveArg.CODE_TYPE1=DEFER_CAUSE_GRP$RetrieveArg.CODE1=Screen.this.currentRow.REASON_CODE_2$Screen.this.currentRow.REASON_CODE_3=ReturnField.CODE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','DEFER_CAUSE_CAT' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','viewwidth',2500,'/EC','STATIC_PRESENTATION','130' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','REASON_CODE_3','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_dep_popup.xml' from dual;


--Class Attribute Properties
begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - EQUIPMENT_ID');
end;
/

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','EQUIPMENT_ID','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','EQUIPMENT_ID','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.EQUIPMENT_ID=ReturnField.OBJECT_ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','EQUIPMENT_ID','LABEL',2500,'/EC','APPLICATION','Equipment' from dual;

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - MASTER_EVENT_ID/CVX_CONTROL/WORK_ORDER/NEED_REVIEW/STATUS');
end;
/
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'MASTER_EVENT_ID', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'CVX_CONTROL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','WORK_ORDER','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','2850' from dual;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'NEED_REVIEW', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'WELL_DEFERMENT','STATUS','DISABLED_IND',2500,'/','VIEWLAYER','Y' from dual;

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - STEAM_INJ_POTENTIAL/WATER_INJ_POTENTIAL/WATER_POTENTIAL/GAS_INJ_POTENTIAL/OIL_POTENTIAL');
end;
/
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

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - DILUENT_POTENTIAL/GAS_LIFT_POTENTIAL/STEAM_INJ_LOSS_RATE/WATER_INJ_LOSS_RATE/WATER_LOSS_RATE');
end;
/
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

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - GAS_INJ_LOSS_RATE/OIL_LOSS_RATE/DILUENT_LOSS_RATE/GAS_LIFT_LOSS_RATE/STEAM_INJ_EVENT_LOSS');
end;
/
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

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - WATER_INJ_EVENT_LOSS/WATER_EVENT_LOSS/GAS_INJ_EVENT_LOSS/OIL_EVENT_LOSS/DILUENT_EVENT_LOSS');
end;
/
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

begin
dbms_output.put_line('Class Attribute Properties - WELL_DEFERMENT - GAS_LIFT_EVENT_LOSS/STATUS');
end;
/
--insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
--values ('WELL_DEFERMENT', 'GAS_LIFT_EVENT_LOSS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('WELL_DEFERMENT', 'STATUS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');

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
