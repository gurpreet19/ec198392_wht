CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_GROUP_LEVEL" ("CLASS_NAME", "TO_CLASS_NAME", "FROM_CLASS_NAME", "ROLE_NAME") AS 
  (
-- Get level 2
SELECT /*+ rule */
  cr1.to_class_name class_name,
  cr1.to_class_name,
  cr1.from_class_name,
  cr1.role_name
FROM class_relation_cnfg cr1
WHERE cr1.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
UNION
-- Get level 3
SELECT
  cr1.to_class_name class_name,
  cr2.to_class_name,
  cr2.from_class_name,
  cr2.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
UNION
-- Get level 4
SELECT
  cr1.to_class_name class_name,
  cr3.to_class_name,
  cr3.from_class_name,cr3.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
UNION
-- Get level 5
SELECT
  cr1.to_class_name class_name,
  cr4.to_class_name,
  cr4.from_class_name,
  cr4.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
UNION
-- Get level 6
SELECT
  cr1.to_class_name class_name,
  cr5.to_class_name,
  cr5.from_class_name,
  cr5.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4, class_relation_cnfg cr5
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr4.from_class_name = cr5.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type = cr5.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND cr5.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr5.from_class_name, cr5.to_class_name, cr5.role_name) = 'N'
UNION
-- Get level 7
SELECT
  cr1.to_class_name class_name,
  cr6.to_class_name,
  cr6.from_class_name,
  cr6.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4, class_relation_cnfg cr5, class_relation_cnfg cr6
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr4.from_class_name = cr5.to_class_name
  AND cr5.from_class_name = cr6.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type = cr5.group_type
  AND cr1.group_type = cr6.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND cr5.group_type IS NOT NULL
  AND cr6.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr5.from_class_name, cr5.to_class_name, cr5.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr6.from_class_name, cr6.to_class_name, cr6.role_name) = 'N'
UNION
-- Get level 8
SELECT
  cr1.to_class_name class_name,
  cr7.to_class_name,
  cr7.from_class_name,
  cr7.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4, class_relation_cnfg cr5, class_relation_cnfg cr6, class_relation_cnfg cr7
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr4.from_class_name = cr5.to_class_name
  AND cr5.from_class_name = cr6.to_class_name
  AND cr6.from_class_name = cr7.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type = cr5.group_type
  AND cr1.group_type = cr6.group_type
  AND cr1.group_type = cr7.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND cr5.group_type IS NOT NULL
  AND cr6.group_type IS NOT NULL
  AND cr7.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr5.from_class_name, cr5.to_class_name, cr5.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr6.from_class_name, cr6.to_class_name, cr6.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr7.from_class_name, cr7.to_class_name, cr7.role_name) = 'N'
UNION
-- Get level 9
SELECT
  cr1.to_class_name class_name,
  cr8.to_class_name,
  cr8.from_class_name,
  cr8.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4, class_relation_cnfg cr5, class_relation_cnfg cr6, class_relation_cnfg cr7, class_relation_cnfg cr8
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr4.from_class_name = cr5.to_class_name
  AND cr5.from_class_name = cr6.to_class_name
  AND cr6.from_class_name = cr7.to_class_name
  AND cr7.from_class_name = cr8.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type = cr5.group_type
  AND cr1.group_type = cr6.group_type
  AND cr1.group_type = cr7.group_type
  AND cr1.group_type = cr8.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND cr5.group_type IS NOT NULL
  AND cr6.group_type IS NOT NULL
  AND cr7.group_type IS NOT NULL
  AND cr8.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr5.from_class_name, cr5.to_class_name, cr5.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr6.from_class_name, cr6.to_class_name, cr6.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr7.from_class_name, cr7.to_class_name, cr7.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr8.from_class_name, cr8.to_class_name, cr8.role_name) = 'N'
UNION
-- Get level 10
SELECT
  cr1.to_class_name class_name,
  cr9.to_class_name,
  cr9.from_class_name,
  cr9.role_name
FROM class_relation_cnfg cr1, class_relation_cnfg cr2, class_relation_cnfg cr3, class_relation_cnfg cr4, class_relation_cnfg cr5, class_relation_cnfg cr6, class_relation_cnfg cr7, class_relation_cnfg cr8, class_relation_cnfg cr9
WHERE  cr1.from_class_name = cr2.to_class_name
  AND cr2.from_class_name = cr3.to_class_name
  AND cr3.from_class_name = cr4.to_class_name
  AND cr4.from_class_name = cr5.to_class_name
  AND cr5.from_class_name = cr6.to_class_name
  AND cr6.from_class_name = cr7.to_class_name
  AND cr7.from_class_name = cr8.to_class_name
  AND cr8.from_class_name = cr9.to_class_name
  AND cr1.group_type = cr2.group_type
  AND cr1.group_type = cr3.group_type
  AND cr1.group_type = cr4.group_type
  AND cr1.group_type = cr5.group_type
  AND cr1.group_type = cr6.group_type
  AND cr1.group_type = cr7.group_type
  AND cr1.group_type = cr8.group_type
  AND cr1.group_type = cr9.group_type
  AND cr1.group_type IS NOT NULL
  AND cr2.group_type IS NOT NULL
  AND cr3.group_type IS NOT NULL
  AND cr4.group_type IS NOT NULL
  AND cr5.group_type IS NOT NULL
  AND cr6.group_type IS NOT NULL
  AND cr7.group_type IS NOT NULL
  AND cr8.group_type IS NOT NULL
  AND cr9.group_type IS NOT NULL
  AND ecdp_classmeta_cnfg.isDisabled(cr1.from_class_name, cr1.to_class_name, cr1.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr2.from_class_name, cr2.to_class_name, cr2.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr3.from_class_name, cr3.to_class_name, cr3.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr4.from_class_name, cr4.to_class_name, cr4.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr5.from_class_name, cr5.to_class_name, cr5.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr6.from_class_name, cr6.to_class_name, cr6.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr7.from_class_name, cr7.to_class_name, cr7.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr8.from_class_name, cr8.to_class_name, cr8.role_name) = 'N'
  AND ecdp_classmeta_cnfg.isDisabled(cr9.from_class_name, cr9.to_class_name, cr9.role_name) = 'N'
)