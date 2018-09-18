CREATE OR REPLACE FORCE VIEW "DAO_CLASS_DEPENDENCY" ("PARENT_CLASS", "CHILD_CLASS", "CLASS_TYPE") AS 
  SELECT 	cd.parent_class,
		cd.child_class,
    c.class_type
FROM class_dependency cd, class c
WHERE cd.child_class = c.class_name
AND cd.dependency_type = 'IMPLEMENTS'
-- get all classes in group_model but for class name GROUPS
UNION
SELECT 	distinct 'GROUPS' parent_class,
		to_class_name child_class,
      c.class_type
FROM class_relation cr, class c
WHERE cr.to_class_name = c.class_name
AND  cr.group_type IS NOT NULL
-- get all classes in objects but for class name OBJECTS
UNION
SELECT 	'OBJECTS' parent_class,
		c.class_name child_class,
    c.class_type
FROM class c
WHERE c.class_type = 'OBJECT'
UNION
SELECT 'NAV_MODEL_OBJ_RELATION' parent_class,
	to_class_name child_class,
	'OBJECT' class_type
FROM nav_model