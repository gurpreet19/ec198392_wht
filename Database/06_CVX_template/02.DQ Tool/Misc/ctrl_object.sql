INSERT INTO ctrl_object (OBJECT_NAME, EC_PACKAGE) values ('CT_DQ_RULE', 'Y');
INSERT INTO ctrl_object (OBJECT_NAME, EC_PACKAGE) values ('CT_DQ_RULE_GROUP', 'Y');
INSERT INTO ctrl_object (OBJECT_NAME, EC_PACKAGE) values ('CT_DQ_RUN_LOG', 'Y');
COMMIT;

EXEC EcDp_Generate.generate('CT_DQ_RULE',EcDp_Generate.PACKAGES);
EXEC EcDp_Generate.generate('CT_DQ_RULE_GROUP',EcDp_Generate.PACKAGES);
EXEC EcDp_Generate.generate('CT_DQ_RUN_LOG',EcDp_Generate.PACKAGES);
COMMIT;
