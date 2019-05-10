insert into tv_system_attribute
(from_date, attribute_type, attribute_value, DESCRIPTION)
VALUES
(TO_DATE('01/01/1900','MM/DD/YYYY'), 'CT_DQ_MAX_RULE_RESULTS',2000,'Maximum number of rule results for an individual rule before the DQ Job will fail.  Default is 2000.');

insert into tv_system_attribute
(from_date, attribute_type, attribute_value, DESCRIPTION)
VALUES
(TO_DATE('01/01/1900','MM/DD/YYYY'), 'CT_DQ_MAX_RULE_DURATION',5,'Maximum duration in minutes for an individual rule execution time before the DQ Job will fail.  Default is 5 minutes');

insert into tv_system_attribute
(from_date, attribute_type, attribute_value, DESCRIPTION)
VALUES
(TO_DATE('01/01/1900','MM/DD/YYYY'), 'CT_DQ_MAX_ROWS',1500,'Maximum rows retrieved on Rule Results detail table.  Default is 1500');