
-- insert CLASS_CNFG related data

INSERT INTO INSERT_CLASS_CNFG (TABLE_NAME,CLASS_NAME) SELECT NULL TABLE_NAME, NULL CLASS_NAME FROM DUAL WHERE 1=0
;

-- insert CLASS_ATTRIBUTE_CNFG related data

INSERT INTO INSERT_CLASS_CNFG (TABLE_NAME,CLASS_NAME,ATTRIBUTE_NAME) SELECT NULL TABLE_NAME, NULL CLASS_NAME, NULL ATTRIBUTE_NAME FROM DUAL WHERE 1=0
;

-- insert CLASS_RELATION_CNFG related data

INSERT INTO INSERT_CLASS_CNFG (TABLE_NAME,FROM_CLASS_NAME,ROLE_NAME,TO_CLASS_NAME) SELECT NULL TABLE_NAME, NULL FROM_CLASS_NAME, NULL ROLE_NAME, NULL TO_CLASS_NAME FROM DUAL WHERE 1=0
;

-- insert CLASS_TRIGGER_ACTN_CNFG related data

INSERT INTO INSERT_CLASS_CNFG (TABLE_NAME,CLASS_NAME,SORT_ORDER,TRIGGER_TYPE,TRIGGERING_EVENT) SELECT NULL TABLE_NAME, NULL CLASS_NAME, NULL SORT_ORDER, NULL TRIGGER_TYPE, NULL TRIGGERING_EVENT FROM DUAL WHERE 1=0
;

-- insert CLASS_DEPENDENCY_CNFG related data

INSERT INTO INSERT_CLASS_CNFG (TABLE_NAME,CHILD_CLASS,DEPENDENCY_TYPE,PARENT_CLASS) SELECT NULL TABLE_NAME, NULL CHILD_CLASS, NULL DEPENDENCY_TYPE, NULL PARENT_CLASS FROM DUAL WHERE 1=0
;
