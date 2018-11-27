CREATE OR REPLACE PACKAGE ecdp_viewlayer_utils IS

TYPE DirtyMap_t IS TABLE OF NUMBER INDEX BY VARCHAR2(24);

CURSOR getGrmodel(p_class_name IN VARCHAR2) IS
  SELECT DISTINCT gl.class_name
  FROM  v_group_level gl
  WHERE gl.from_class_name = p_class_name;

CURSOR getAllGrmodel IS
  SELECT DISTINCT gl.class_name
  FROM  v_group_level gl
  UNION
  SELECT DISTINCT gl.from_class_name
  FROM  v_group_level gl;

CURSOR getAllNavModel IS
  SELECT DISTINCT nav.to_class_name class_name
  FROM  nav_model nav
  UNION
  SELECT DISTINCT nav.from_class_name
  FROM  nav_model nav;

CURSOR c_dac_dependent_class(p_class_name VARCHAR2) IS
    SELECT child_class dependent_class
    FROM class_dependency_cnfg
    WHERE parent_class =  p_class_name
    AND   dependency_type = 'ACCESS_CONTROLLED_BY'
    UNION
    SELECT class_name dependent_class
    FROM class_cnfg
    WHERE owner_class_name = p_class_name
    UNION
    SELECT to_class_name dependent_class
    FROM class_relation_cnfg
    WHERE EcDp_ClassMeta_Cnfg.getAccessControlMethod(p_class_name, to_class_name, role_name) IS NOT NULL;

CURSOR c_interface_class(p_class_name VARCHAR2) IS
    SELECT parent_class interface_class
    FROM class_dependency_cnfg
    WHERE child_class =  p_class_name
    AND   dependency_type = 'IMPLEMENTS';

FUNCTION installOrder(p_app_space_cntx IN VARCHAR2) RETURN NUMBER;
FUNCTION hasAppSpaceFootprint(p_class_name IN VARCHAR2, p_app_space_cntx IN VARCHAR2) RETURN VARCHAR2;

FUNCTION jnColumnList(p_ue_user_function IN VARCHAR2, p_alias IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION viewExists(p_name IN VARCHAR2, p_owner VARCHAR2) RETURN BOOLEAN;
FUNCTION tableExists(p_name IN VARCHAR2, p_owner VARCHAR2) RETURN BOOLEAN;
FUNCTION columnExists(p_table_name IN VARCHAR2, p_column_name IN VARCHAR2, p_table_owner IN VARCHAR2) RETURN BOOLEAN;

FUNCTION getDirtyClasses(p_class_name IN VARCHAR2, p_dirty_type IN VARCHAR2 DEFAULT 'VIEWLAYER', p_app_space_cntx IN VARCHAR2 DEFAULT NULL) RETURN DirtyMap_t;
FUNCTION countDirtyClasses(p_class_name IN VARCHAR2, p_dirty_type IN VARCHAR2 DEFAULT 'VIEWLAYER', p_app_space_cntx IN VARCHAR2 DEFAULT NULL) RETURN INTEGER;

PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_sql         CLOB,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_sql2        VARCHAR2 DEFAULT '',
                    p_id          VARCHAR2 DEFAULT 'GENCODE');

FUNCTION is_dirty(p_object_name IN VARCHAR2, p_dirty_type IN VARCHAR2) RETURN BOOLEAN;
PROCEDURE set_dirty_ind(p_object_name IN VARCHAR2, p_dirty_type IN VARCHAR2, p_dirty IN BOOLEAN);

END ecdp_viewlayer_utils;