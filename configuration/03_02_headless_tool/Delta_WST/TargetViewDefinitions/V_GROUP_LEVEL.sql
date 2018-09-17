CREATE OR REPLACE FORCE VIEW "V_GROUP_LEVEL" ("CLASS_NAME", "TO_CLASS_NAME", "FROM_CLASS_NAME", "ROLE_NAME") AS 
  (
-- Get level 2
SELECT /*+ rule */
	cr1.to_class_name class_name,
	cr1.to_class_name,
	cr1.from_class_name,
	cr1.role_name
FROM class_relation cr1
WHERE cr1.group_type IS NOT NULL
  AND NVL(cr1.disabled_ind, 'N') = 'N'
UNION
-- Get level 3
SELECT
	cr1.to_class_name class_name,
	cr2.to_class_name,
	cr2.from_class_name,
	cr2.role_name
FROM class_relation cr1, class_relation cr2
WHERE  cr1.from_class_name = cr2.to_class_name
	AND cr1.group_type = cr2.group_type
	AND cr1.group_type IS NOT NULL
	AND cr2.group_type IS NOT NULL
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
UNION
-- Get level 4
SELECT
	cr1.to_class_name class_name,
	cr3.to_class_name,
	cr3.from_class_name,cr3.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3
WHERE  cr1.from_class_name = cr2.to_class_name
	AND cr2.from_class_name = cr3.to_class_name
	AND cr1.group_type = cr2.group_type
	AND cr1.group_type = cr3.group_type
	AND cr1.group_type IS NOT NULL
	AND cr2.group_type IS NOT NULL
	AND cr3.group_type IS NOT NULL
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
UNION
-- Get level 5
SELECT
	cr1.to_class_name class_name,
	cr4.to_class_name,
	cr4.from_class_name,
	cr4.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
UNION
-- Get level 6
SELECT
	cr1.to_class_name class_name,
	cr5.to_class_name,
	cr5.from_class_name,
	cr5.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4, class_relation cr5
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
	AND NVL(cr5.disabled_ind, 'N') = 'N'
UNION
-- Get level 7
SELECT
	cr1.to_class_name class_name,
	cr6.to_class_name,
	cr6.from_class_name,
	cr6.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4, class_relation cr5, class_relation cr6
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
	AND NVL(cr5.disabled_ind, 'N') = 'N'
	AND NVL(cr6.disabled_ind, 'N') = 'N'
UNION
-- Get level 8
SELECT
	cr1.to_class_name class_name,
	cr7.to_class_name,
	cr7.from_class_name,
	cr7.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4, class_relation cr5, class_relation cr6, class_relation cr7
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
	AND NVL(cr5.disabled_ind, 'N') = 'N'
	AND NVL(cr6.disabled_ind, 'N') = 'N'
	AND NVL(cr7.disabled_ind, 'N') = 'N'
UNION
-- Get level 9
SELECT
	cr1.to_class_name class_name,
	cr8.to_class_name,
	cr8.from_class_name,
	cr8.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4, class_relation cr5, class_relation cr6, class_relation cr7, class_relation cr8
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
	AND NVL(cr5.disabled_ind, 'N') = 'N'
	AND NVL(cr6.disabled_ind, 'N') = 'N'
	AND NVL(cr7.disabled_ind, 'N') = 'N'
	AND NVL(cr8.disabled_ind, 'N') = 'N'
UNION
-- Get level 10
SELECT
	cr1.to_class_name class_name,
	cr9.to_class_name,
	cr9.from_class_name,
	cr9.role_name
FROM class_relation cr1, class_relation cr2, class_relation cr3, class_relation cr4, class_relation cr5, class_relation cr6, class_relation cr7, class_relation cr8, class_relation cr9
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
	AND NVL(cr1.disabled_ind, 'N') = 'N'
	AND NVL(cr2.disabled_ind, 'N') = 'N'
	AND NVL(cr3.disabled_ind, 'N') = 'N'
	AND NVL(cr4.disabled_ind, 'N') = 'N'
	AND NVL(cr5.disabled_ind, 'N') = 'N'
	AND NVL(cr6.disabled_ind, 'N') = 'N'
	AND NVL(cr7.disabled_ind, 'N') = 'N'
	AND NVL(cr8.disabled_ind, 'N') = 'N'
	AND NVL(cr9.disabled_ind, 'N') = 'N'
)