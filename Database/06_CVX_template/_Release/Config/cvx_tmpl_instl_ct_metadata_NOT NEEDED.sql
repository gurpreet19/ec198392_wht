--
-- Loading Class (product)
--
--
-- Loading Attribute (product)
--
--
-- Loading Relation (product)
--
--
-- Loading Dependency (product)
--
--
-- Loading Action (original)
--
--
-- Loading Action (product)
--
--
-- Loading Delete Action (product)
--
--
-- Loading Delete Rel. (product)
--
--
-- Loading Class (original)
--
--
-- Loading Attribute (original)
--
--
-- Loading Relation (original)
--
--
-- Loading Dependency (original)
--
--
-- Loading Delete Class (product)
--
--
-- Loading Class (project)
--
INSERT INTO CLASS (CLASS_NAME,CLASS_TYPE,APP_SPACE_CODE,TIME_SCOPE_CODE,CLASS_VERSION,LABEL,DESCRIPTION,READ_ONLY_IND,JOURNAL_RULE_DB_SYNTAX) VALUES ('CT_EC_INSTALL_HISTORY','TABLE','CVX','VERSIONED','1','EC Install History','EC Install History','Y','False');
INSERT INTO CLASS_DB_MAPPING (CLASS_NAME,DB_OBJECT_TYPE,DB_OBJECT_OWNER,DB_OBJECT_NAME) VALUES ('CT_EC_INSTALL_HISTORY','TABLE',USER,'CT_EC_INSTALL_HISTORY');
INSERT INTO CLASS (CLASS_NAME,CLASS_TYPE,APP_SPACE_CODE,CLASS_VERSION,LABEL,DESCRIPTION,READ_ONLY_IND) VALUES ('CT_EC_INSTALLED_FEATURES','TABLE','CVX','1','Chevron Installed Features','EC Installed Features','Y');
INSERT INTO CLASS_DB_MAPPING (CLASS_NAME,DB_OBJECT_TYPE,DB_OBJECT_OWNER,DB_OBJECT_NAME) VALUES ('CT_EC_INSTALLED_FEATURES','TABLE',USER,'CT_EC_INSTALLED_FEATURES');
--
-- Loading Attribute (project)
--
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_KEY,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','DESCRIPTION','STRING','N','N','CVX','Description');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','DESCRIPTION','COLUMN','DESCRIPTION',700);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','DESCRIPTION','Description',700);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_KEY,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','INSTALL_ID','STRING','Y','Y','CVX','Install ID');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALL_ID','COLUMN','INSTALL_ID',100);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALL_ID','Install ID',100);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_KEY,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_BY','STRING','N','N','CVX','Installed By');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_BY','COLUMN','INSTALLED_BY',600);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_BY','Installed By',600);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_KEY,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_DATE','DATE','N','N','CVX','Install Date');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_DATE','COLUMN','INSTALLED_DATE',500);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','INSTALLED_DATE','Install Date',500);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','PREPARED_BY','STRING','CVX','The author of this update');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','PREPARED_BY','COLUMN','PREPARED_BY',800);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','PREPARED_BY','Prepared By',800);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_KEY,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALL_HISTORY','RELEASE_DATE','DATE','Y','Y','CVX','Release Date');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','RELEASE_DATE','COLUMN','RELEASE_DATE',200);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALL_HISTORY','RELEASE_DATE','Release Date',200);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALLED_FEATURES','CONTEXT_CODE','STRING','Y','CVX','Indicates which department drove the feature.');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','CONTEXT_CODE','COLUMN','CONTEXT_CODE',300);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','CONTEXT_CODE','Context Code',300);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,CONTEXT_CODE) VALUES ('CT_EC_INSTALLED_FEATURES','DESCRIPTION','STRING','CVX');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','DESCRIPTION','COLUMN','DESCRIPTION',700);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','DESCRIPTION','Description',700);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_ID','STRING','Y','CVX','A unique ID for the feature');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_ID','COLUMN','FEATURE_ID',100);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_ID','Feature ID',100);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_NAME','STRING','Y','CVX','A user-friendly name for the feature');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_NAME','COLUMN','FEATURE_NAME',200);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','FEATURE_NAME','Feature Name',200);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALLED_FEATURES','MAJOR_VERSION','NUMBER','Y','CVX','Major version number.');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','MAJOR_VERSION','COLUMN','MAJOR_VERSION',400);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','MAJOR_VERSION','Major Version',400);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,IS_MANDATORY,CONTEXT_CODE,DESCRIPTION) VALUES ('CT_EC_INSTALLED_FEATURES','MINOR_VERSION','NUMBER','Y','CVX','Major version number.');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','MINOR_VERSION','COLUMN','MINOR_VERSION',500);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','MINOR_VERSION','Minor Version',500);
INSERT INTO CLASS_ATTRIBUTE (CLASS_NAME,ATTRIBUTE_NAME,DATA_TYPE,CONTEXT_CODE,DESCRIPTION,REPORT_ONLY_IND) VALUES ('CT_EC_INSTALLED_FEATURES','VERSION_STRING','STRING','CVX','Printable version number','Y');
INSERT INTO CLASS_ATTR_DB_MAPPING (CLASS_NAME,ATTRIBUTE_NAME,DB_MAPPING_TYPE,DB_SQL_SYNTAX,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','VERSION_STRING','FUNCTION','MAJOR_VERSION || ''.'' || MINOR_VERSION',600);
INSERT INTO CLASS_ATTR_PRESENTATION (CLASS_NAME,ATTRIBUTE_NAME,LABEL,SORT_ORDER) VALUES ('CT_EC_INSTALLED_FEATURES','VERSION_STRING','Version String',600);
--
-- Loading Relation (project)
--
--
-- Loading Dependency (project)
--
--
-- Loading Action (project)
--
--
-- Loading Regenerate
--
