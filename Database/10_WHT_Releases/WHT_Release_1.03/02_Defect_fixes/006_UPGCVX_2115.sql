--RV_CT_DQ_RULE
---------------
Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','ADDNL_INFO','CVX','N','STRING','COLUMN','ADDNL_INFO' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','ADDNL_INFO' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'ADDNL_INFO';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DESCRIPTION',2500,'/EC','APPLICATION','Additional Record Information' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DB_SORT_ORDER',2500,'/','VIEWLAYER','140' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','LABEL',2500,'/EC','APPLICATION','Additional Information' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','127' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ADDNL_INFO','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ADDNL_INFO','viewwidth',2500,'/EC','STATIC_PRESENTATION','600');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ADDNL_INFO','viewtype',2500,'/EC','STATIC_PRESENTATION','textarea');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','CVX','N','STRING','COLUMN','ALT_UNIQUE_KEY_SOURCE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','ALT_UNIQUE_KEY_SOURCE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'ALT_UNIQUE_KEY_SOURCE';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DESCRIPTION',2500,'/EC','APPLICATION','Alternate Unique Key Source' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DB_SORT_ORDER',2500,'/','VIEWLAYER','125' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','LABEL',2500,'/EC','APPLICATION','Alt Unique Key' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','125' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','viewwidth',2500,'/EC','STATIC_PRESENTATION','70');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ALT_UNIQUE_KEY_SOURCE','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Select Source');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','APP_ID','CVX','N','INTEGER','COLUMN','APP_ID' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','APP_ID' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'APP_ID';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'APP_ID' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DESCRIPTION',2500,'/EC','APPLICATION','Application' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DB_SORT_ORDER',2500,'/','VIEWLAYER','145' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_t_basis_application.app_name(APP_ID)' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','LABEL',2500,'/EC','APPLICATION','Application' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','149' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','APP_ID','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','APP_ID','viewwidth',2500,'/EC','STATIC_PRESENTATION','70');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','APP_ID','vieweditable',2500,'/EC','STATIC_PRESENTATION','false');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','ATTRIBUTE_NAME','CVX','N','STRING','COLUMN','ATTRIBUTE_NAME' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','ATTRIBUTE_NAME' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'ATTRIBUTE_NAME';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'ATTRIBUTE_NAME' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DESCRIPTION',2500,'/EC','APPLICATION','Attribute Name' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DB_SORT_ORDER',2500,'/','VIEWLAYER','100' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','LABEL',2500,'/EC','APPLICATION','Target Attribute' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','100' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ATTRIBUTE_NAME','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ATTRIBUTE_NAME','viewwidth',2500,'/EC','STATIC_PRESENTATION','140');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','COMMENTS','CVX','N','STRING','COLUMN','COMMENTS' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','COMMENTS' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'COMMENTS';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'COMMENTS' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DESCRIPTION',2500,'/EC','APPLICATION','Comments' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DB_SORT_ORDER',2500,'/','VIEWLAYER','60' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','LABEL',2500,'/EC','APPLICATION','Comments' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','200' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','COMMENTS','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','COMMENTS','viewwidth',2500,'/EC','STATIC_PRESENTATION','400');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','DAYTIME_SOURCE','CVX','N','STRING','COLUMN','DAYTIME_SOURCE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','DAYTIME_SOURCE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'DAYTIME_SOURCE';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'DAYTIME_SOURCE' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DESCRIPTION',2500,'/EC','APPLICATION','Daytime Source' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DB_SORT_ORDER',2500,'/','VIEWLAYER','120' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','LABEL',2500,'/EC','APPLICATION','Daytime' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','120' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','DAYTIME_SOURCE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','DAYTIME_SOURCE','viewwidth',2500,'/EC','STATIC_PRESENTATION','70');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','DAYTIME_SOURCE','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Select Source');



Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','ERROR_TYPE','CVX','N','STRING','COLUMN','ERROR_TYPE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','ERROR_TYPE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'ERROR_TYPE';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'ERROR_TYPE' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DESCRIPTION',2500,'/EC','APPLICATION','Error Type' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DB_SORT_ORDER',2500,'/','VIEWLAYER','70' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_prosty_codes.CODE_TEXT(ERROR_TYPE, ''CT_DQ_ERROR_TYPE'' )' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','LABEL',2500,'/EC','APPLICATION','Error Type' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','70' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ERROR_TYPE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','viewwidth',2500,'/EC','STATIC_PRESENTATION','140');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/layout/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','CT_DQ_ERROR_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupWhereOperator',2500,'/EC','STATIC_PRESENTATION','=');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.ERROR_TYPE=ReturnField.CODE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupWidth',2500,'/EC','STATIC_PRESENTATION','200');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ERROR_TYPE','viewtranslate',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','FROM_SQL','CVX','N','STRING','COLUMN','FROM_SQL' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','FROM_SQL' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'FROM_SQL';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'FROM_SQL' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','IS_MANDATORY',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DESCRIPTION',2500,'/EC','APPLICATION','From SQL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DB_SORT_ORDER',2500,'/','VIEWLAYER','130' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','LABEL',2500,'/EC','APPLICATION','From SQL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','130' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FROM_SQL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','FROM_SQL','viewwidth',2500,'/EC','STATIC_PRESENTATION','900');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','FROM_SQL','viewtype',2500,'/EC','STATIC_PRESENTATION','textarea');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','FULL_SQL','CVX','N','STRING','FUNCTION','UE_CT_DQ_RULES_PKG.CONVERT_TO_DATE_RANGE_SQL(UE_CT_DQ_RULES_PKG.COMBINE_WITH_OBJECT_SQL(UE_CT_DQ_RULES_PKG.CONVERT_RULE_TO_SQL(rule_id, sysdate, sysdate + 1), UE_CT_DQ_RULES_PKG.BUILD_OBJECT_SQL(object_type), null, null, null), sysdate, sysdate + 1)' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','UE_CT_DQ_RULES_PKG.CONVERT_TO_DATE_RANGE_SQL(UE_CT_DQ_RULES_PKG.COMBINE_WITH_OBJECT_SQL(UE_CT_DQ_RULES_PKG.CONVERT_RULE_TO_SQL(rule_id, sysdate, sysdate + 1), UE_CT_DQ_RULES_PKG.BUILD_OBJECT_SQL(object_type), null, null, null), sysdate, sysdate + 1)' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'FULL_SQL';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'FULL_SQL' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DESCRIPTION',2500,'/EC','APPLICATION','Full Dynamic SQL with Date' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DB_SORT_ORDER',2500,'/','VIEWLAYER','180' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','LABEL',2500,'/EC','APPLICATION','Full SQL with Obj and Date' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','510' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','FULL_SQL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','FULL_SQL','viewwidth',2500,'/EC','STATIC_PRESENTATION','1200');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','FULL_SQL','vieweditable',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','FULL_SQL','viewhidden',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','IS_ACTIVE','CVX','N','BOOLEAN','COLUMN','IS_ACTIVE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','IS_ACTIVE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'IS_ACTIVE';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'IS_ACTIVE' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DEFAULT_VALUE',2500,'/','VIEWLAYER','''N''' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DESCRIPTION',2500,'/EC','APPLICATION','Active' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DB_SORT_ORDER',2500,'/','VIEWLAYER','40' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','LABEL',2500,'/EC','APPLICATION','Active' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','40' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','IS_ACTIVE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','IS_ACTIVE','viewwidth',2500,'/EC','STATIC_PRESENTATION','20');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','IS_ACTIVE','viewtype',2500,'/EC','STATIC_PRESENTATION','checkbox');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','LOGGING_LEVEL','CVX','N','STRING','COLUMN','LOGGING_LEVEL' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','LOGGING_LEVEL' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'LOGGING_LEVEL';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'LOGGING_LEVEL' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DESCRIPTION',2500,'/EC','APPLICATION','Logging Level' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DB_SORT_ORDER',2500,'/','VIEWLAYER','155' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_prosty_codes.CODE_TEXT(LOGGING_LEVEL, ''CT_DQ_LOGGING_LEVEL'' )' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','LABEL',2500,'/EC','APPLICATION','Logging Level' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','152' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','LOGGING_LEVEL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','viewwidth',2500,'/EC','STATIC_PRESENTATION','140');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/layout/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','CT_DQ_LOGGING_LEVEL');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupWhereOperator',2500,'/EC','STATIC_PRESENTATION','=');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.LOGGING_LEVEL=ReturnField.CODE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupWidth',2500,'/EC','STATIC_PRESENTATION','200');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','LOGGING_LEVEL','viewtranslate',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','CVX','N','STRING','COLUMN','OBJECT_ID_SOURCE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','OBJECT_ID_SOURCE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'OBJECT_ID_SOURCE';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'OBJECT_ID_SOURCE' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DESCRIPTION',2500,'/EC','APPLICATION','Object ID Source' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DB_SORT_ORDER',2500,'/','VIEWLAYER','110' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','LABEL',2500,'/EC','APPLICATION','Object ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','110' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_ID_SOURCE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_ID_SOURCE','viewwidth',2500,'/EC','STATIC_PRESENTATION','100');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_ID_SOURCE','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Select Source');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','OBJECT_TYPE','CVX','N','STRING','COLUMN','OBJECT_TYPE' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','OBJECT_TYPE' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'OBJECT_TYPE';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'OBJECT_TYPE' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','IS_MANDATORY',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DESCRIPTION',2500,'/EC','APPLICATION','Object Type' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DB_SORT_ORDER',2500,'/','VIEWLAYER','95' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_prosty_codes.CODE_TEXT(OBJECT_TYPE, ''CT_DQ_HIER_OBJ_TYPE'' )' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','LABEL',2500,'/EC','APPLICATION','Hierarchy Object Type' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','95' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','OBJECT_TYPE','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','viewwidth',2500,'/EC','STATIC_PRESENTATION','140');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/layout/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','CT_DQ_HIER_OBJ_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupWhereOperator',2500,'/EC','STATIC_PRESENTATION','=');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.OBJECT_TYPE=ReturnField.CODE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupWidth',2500,'/EC','STATIC_PRESENTATION','200');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','viewtranslate',2500,'/EC','STATIC_PRESENTATION','true');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','OBJECT_TYPE','sortheader',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','CVX','N','NUMBER','COLUMN','RESULT_RETENTION_DAYS' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','RESULT_RETENTION_DAYS' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'RESULT_RETENTION_DAYS';


--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'RESULT_RETENTION_DAYS' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DESCRIPTION',2500,'/EC','APPLICATION','Result Retention Days' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DB_SORT_ORDER',2500,'/','VIEWLAYER','160' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','LABEL',2500,'/EC','APPLICATION','Retention Days' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','155' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RESULT_RETENTION_DAYS','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RESULT_RETENTION_DAYS','viewwidth',2500,'/EC','STATIC_PRESENTATION','90');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RESULT_RETENTION_DAYS','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Result');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','ROLE_ID','CVX','N','STRING','COLUMN','ROLE_ID' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','ROLE_ID' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'ROLE_ID';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'ROLE_ID' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DESCRIPTION',2500,'/EC','APPLICATION','Role ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DB_SORT_ORDER',2500,'/','VIEWLAYER','150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_t_basis_role.role_name(ROLE_ID, APP_ID)' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','LABEL',2500,'/EC','APPLICATION','Role' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','ROLE_ID','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','viewwidth',2500,'/EC','STATIC_PRESENTATION','150');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/access/query/get_role.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/access/layout/role_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','2');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.ROLE_ID=ReturnField.ROLE_ID$Screen.this.currentRow.APP_ID=ReturnField.APP_ID$Screen.this.currentRow.APP_ID_POPUP=ReturnField.APP_ID_POPUP');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupWidth',2500,'/EC','STATIC_PRESENTATION','250');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','ROLE_ID','viewtranslate',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','RULE_CATEGORY','CVX','N','STRING','COLUMN','RULE_CATEGORY' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','RULE_CATEGORY' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'RULE_CATEGORY';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'RULE_CATEGORY' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DESCRIPTION',2500,'/EC','APPLICATION','Rule Category' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DB_SORT_ORDER',2500,'/','VIEWLAYER','85' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_prosty_codes.CODE_TEXT(RULE_CATEGORY, ''CT_DQ_RULE_CATEGORY'' )' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','LABEL',2500,'/EC','APPLICATION','Category' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','85' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_CATEGORY','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','viewwidth',2500,'/EC','STATIC_PRESENTATION','130');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/layout/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','CT_DQ_RULE_CATEGORY');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupWhereOperator',2500,'/EC','STATIC_PRESENTATION','=');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupDependency',2500,'/EC','STATIC_PRESENTATION','Screen.this.currentRow.RULE_CATEGORY=ReturnField.CODE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupWidth',2500,'/EC','STATIC_PRESENTATION','250');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','viewtranslate',2500,'/EC','STATIC_PRESENTATION','true');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Rule');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_CATEGORY','sortheader',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','RULE_DESCRIPTION','CVX','N','STRING','COLUMN','RULE_DESCRIPTION' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','RULE_DESCRIPTION' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'RULE_DESCRIPTION';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'RULE_DESCRIPTION' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','IS_MANDATORY',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DESCRIPTION',2500,'/EC','APPLICATION','Rule Description' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DB_SORT_ORDER',2500,'/','VIEWLAYER','50' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','LABEL',2500,'/EC','APPLICATION','Rule Description' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','50' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_DESCRIPTION','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_DESCRIPTION','viewwidth',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_DESCRIPTION','sortheader',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','RULE_ID','CVX','Y','NUMBER','COLUMN','RULE_ID' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','RULE_ID' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'RULE_ID';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'RULE_ID' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DESCRIPTION',2500,'/EC','APPLICATION','Rule ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DB_SORT_ORDER',2500,'/','VIEWLAYER','10' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','LABEL',2500,'/EC','APPLICATION','Rule ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','10' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_ID','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_ID','viewwidth',2500,'/EC','STATIC_PRESENTATION','30');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_ID','vieweditable',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_ID','sortheader',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','RULE_SUBCATEGORY','CVX','N','STRING','COLUMN','RULE_SUBCATEGORY' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','RULE_SUBCATEGORY' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'RULE_SUBCATEGORY';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'RULE_SUBCATEGORY' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DESCRIPTION',2500,'/EC','APPLICATION','Rule SubCategory' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DB_SORT_ORDER',2500,'/','VIEWLAYER','90' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','ec_prosty_codes.CODE_TEXT(RULE_SUBCATEGORY, ''CT_DQ_RULE_SUBCATEGORY'' )' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','LABEL',2500,'/EC','APPLICATION','SubCategory' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','90' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','RULE_SUBCATEGORY','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','viewwidth',2500,'/EC','STATIC_PRESENTATION','130');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/query/ec_code_dep_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.frmw.co.screens/layout/ec_code_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupWhereColumn',2500,'/EC','STATIC_PRESENTATION','CODE_TYPE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupWhereValue',2500,'/EC','STATIC_PRESENTATION','CT_DQ_RULE_SUBCATEGORY');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupWhereOperator',2500,'/EC','STATIC_PRESENTATION','=');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupDependency',2500,'/EC','STATIC_PRESENTATION','RetrieveArg.CODE_TYPE1=CT_DQ_RULE_CATEGORY$RetrieveArg.CODE1=Screen.this.currentRow.RULE_CATEGORY$Screen.this.currentRow.RULE_SUBCATEGORY=ReturnField.CODE');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','1');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupWidth',2500,'/EC','STATIC_PRESENTATION','250');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','PopupCache',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Rule');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','RULE_SUBCATEGORY','sortheader',2500,'/EC','STATIC_PRESENTATION','true');


Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','CVX','N','STRING','COLUMN','SCREEN_COMPONENT_ID' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'COLUMN','SCREEN_COMPONENT_ID' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'SCREEN_COMPONENT_ID';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'SCREEN_COMPONENT_ID' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DESCRIPTION',2500,'/EC','APPLICATION','EC Screen Object ID' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DB_SORT_ORDER',2500,'/','VIEWLAYER','190' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','LABEL',2500,'/EC','APPLICATION','EC Screen' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','190' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SCREEN_COMPONENT_ID','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','vieweditable',2500,'/EC','STATIC_PRESENTATION','true');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','viewwidth',2500,'/EC','STATIC_PRESENTATION','150');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','PopupQueryURL',2500,'/EC','STATIC_PRESENTATION','/com.ec.cvx.common.screens/query/ct_ctrl_tv_presentation.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','PopupLayout',2500,'/EC','STATIC_PRESENTATION','/com.ec.cvx.common.screens/layout/ct_ctrl_tv_presentation_popup.xml');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','PopupReturnColumn',2500,'/EC','STATIC_PRESENTATION','3');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','PopupWidth',2500,'/EC','STATIC_PRESENTATION','500');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SCREEN_COMPONENT_ID','PopupHeight',2500,'/EC','STATIC_PRESENTATION','300');

Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type, db_mapping_type, db_sql_syntax) select 'CT_DQ_RULE','SQL','CVX','N','STRING','FUNCTION','UE_CT_DQ_RULES_PKG.convert_rule_to_sql(RULE_ID, SYSDATE, SYSDATE)' from dual;
update CLASS_ATTRIBUTE_CNFG c set (db_mapping_type, db_sql_syntax) = (select 'FUNCTION','UE_CT_DQ_RULES_PKG.convert_rule_to_sql(RULE_ID, SYSDATE, SYSDATE)' from dual) where c.class_name = 'CT_DQ_RULE' and c.attribute_name = 'SQL';

--delete from CLASS_ATTR_PROPERTY_CNFG where class_name = 'CT_DQ_RULE' and attribute_name = 'SQL' and owner_cntx = 2500;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','IS_MANDATORY',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','REPORT_ONLY_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DEFAULT_VALUE',2500,'/','VIEWLAYER','' from dual;
--Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DEFAULT_CLIENT_VALUE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DESCRIPTION',2500,'/EC','APPLICATION','SQL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DB_SORT_ORDER',2500,'/','VIEWLAYER','170' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','DB_PRES_SYNTAX',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','LABEL',2500,'/EC','APPLICATION','SQL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','LABEL_ID',2500,'/EC','APPLICATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'CT_DQ_RULE','SQL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SQL','viewwidth',2500,'/EC','STATIC_PRESENTATION','1200');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SQL','vieweditable',2500,'/EC','STATIC_PRESENTATION','false');
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('CT_DQ_RULE','SQL','viewhidden',2500,'/EC','STATIC_PRESENTATION','true');
COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_DQ_RULE');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_DQ_RULE') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_DQ_RULE') ;

---RV_CT_EQPM_OIL_PLANT
-----------------------

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_EQPM_OIL_PLANT','CURT_WATER','UOM_CODE',2500,'/','VIEWLAYER','GAS_RATE');

Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_EQPM_OIL_PLANT','CURT_GAS','UOM_CODE',2500,'/','VIEWLAYER','STD_LIQ_VOL_RATE'); 

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_EQPM_OIL_PLANT');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_EQPM_OIL_PLANT') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_EQPM_OIL_PLANT') ;

--RV_CT_EQPM_OFF_CHILD
----------------------

UPDATE CLASS_CNFG SET DB_OBJECT_NAME = 'DEFERMENT_EVENT' WHERE CLASS_NAME = 'CT_EQPM_OFF_CHILD';
COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_EQPM_OFF_CHILD');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_EQPM_OFF_CHILD') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_EQPM_OFF_CHILD') ;

--RV_CT_PTST_PWEL_TDEV_RESULT
----------------------------------------------------------
Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PTST_PWEL_TDEV_RESULT','BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_PTST_PWEL_TDEV_RESULT');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PTST_PWEL_TDEV_RESULT') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PTST_PWEL_TDEV_RESULT') ;

--RV_CT_PTST_PWEL_TDEV_RES_KS
------------------------------
Insert into class_attr_property_cnfg (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) 
values ('CT_PTST_PWEL_TDEV_RES_KS','BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

COMMIT;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_PTST_PWEL_TDEV_RES_KS');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PTST_PWEL_TDEV_RES_KS') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PTST_PWEL_TDEV_RES_KS') ;

---RV_CT_MSG_PWEL_DAY_ALLOC
---------------------------
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('CT_MSG_PWEL_DAY_ALLOC');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_MSG_PWEL_DAY_ALLOC') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_MSG_PWEL_DAY_ALLOC') ;