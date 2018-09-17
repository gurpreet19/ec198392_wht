CREATE OR REPLACE PACKAGE BODY EcDp_ClassMeta_cnfg IS
/**************************************************************
** Package:    	EcDp_ClassMeta_cnfg
**
** $Revision: 	1.39 $
**
** Filename:   	EcDp_ClassMeta_cnfg.sql
**
** Part of :   	EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:     02.11.2015  Arild Vervik, EC
**
**
** Modification history:
**
**
** Date:        Whom:  Change description:
** --------    ----- --------------------------------------------
** 02.11.2015   AV    Needed separate package to reswolve dependency building Materialized Views
**************************************************************/
/*
 * Propperty code prefixes:
 *
 *   CP - class-level property
 *   AP - attribute-level property
 *   RP - Relation-level property
 *   TP - Trigger action property
 */

/* VIEWLAYER properties */
CP_ENSURE_REV_TEXT_ON_UPD CONSTANT VARCHAR2(100) := 'ENSURE_REV_TEXT_ON_UPD';
CP_JOURNAL_RULE_DB_SYNTAX CONSTANT VARCHAR2(100) := 'JOURNAL_RULE_DB_SYNTAX';
CP_REV_TEXT_DB_SYNTAX     CONSTANT VARCHAR2(100) := 'REV_TEXT_DB_SYNTAX';
CP_LOCK_IND               CONSTANT VARCHAR2(100) := 'LOCK_IND';
CP_LOCK_RULE              CONSTANT VARCHAR2(100) := 'LOCK_RULE';
CP_CLASS_SHORT_CODE       CONSTANT VARCHAR2(100) := 'CLASS_SHORT_CODE';
CP_ACCESS_CONTROL_IND     CONSTANT VARCHAR2(100) := 'ACCESS_CONTROL_IND';
CP_APPROVAL_IND           CONSTANT VARCHAR2(100) := 'APPROVAL_IND';
CP_SKIP_TRG_CHECK_IND     CONSTANT VARCHAR2(100) := 'SKIP_TRG_CHECK_IND';
CP_INCLUDE_WEBSERVICE     CONSTANT VARCHAR2(100) := 'INCLUDE_WEBSERVICE';
CP_CREATE_EV_IND          CONSTANT VARCHAR2(100) := 'CREATE_EV_IND';
CP_READ_ONLY_IND          CONSTANT VARCHAR2(100) := 'READ_ONLY_IND';
CP_INCLUDE_IN_MAPPING_IND CONSTANT VARCHAR2(100) := 'INCLUDE_IN_MAPPING_IND';

AP_READ_ONLY_IND          CONSTANT VARCHAR2(100) := 'READ_ONLY_IND';
AP_DB_SORT_ORDER          CONSTANT VARCHAR2(100) := 'DB_SORT_ORDER';
AP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';
AP_IS_MANDATORY           CONSTANT VARCHAR2(100) := 'IS_MANDATORY';
AP_REPORT_ONLY_IND        CONSTANT VARCHAR2(100) := 'REPORT_ONLY_IND';
AP_UOM_CODE               CONSTANT VARCHAR2(100) := 'UOM_CODE';
AP_PRESENTATION_SYNTAX    CONSTANT VARCHAR2(100) := 'PresentationSyntax';

RP_ALLOC_PRIORITY         CONSTANT VARCHAR2(100) := 'ALLOC_PRIORITY';
RP_DB_SORT_ORDER          CONSTANT VARCHAR2(100) := 'DB_SORT_ORDER';
RP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';
RP_IS_MANDATORY           CONSTANT VARCHAR2(100) := 'IS_MANDATORY';
RP_REPORT_ONLY_IND        CONSTANT VARCHAR2(100) := 'REPORT_ONLY_IND';
RP_ACCESS_CONTROL_METHOD  CONSTANT VARCHAR2(100) := 'ACCESS_CONTROL_METHOD';
RP_APPROVAL_IND           CONSTANT VARCHAR2(100) := 'APPROVAL_IND';
RP_REVERSE_APPROVAL_IND   CONSTANT VARCHAR2(100) := 'REVERSE_APPROVAL_IND';
RP_PRESENTATION_SYNTAX    CONSTANT VARCHAR2(100) := 'PresentationSyntax';

TP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';

/* APPLICATION properties */
CP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
AP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
RP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
AP_LABEL_ID               CONSTANT VARCHAR2(100) := 'LABEL_ID';
CP_INCLUDE_IN_VALIDATION  CONSTANT VARCHAR2(100) := 'INCLUDE_IN_VALIDATION';
CP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
AP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
RP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
TP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
AP_NAME                   CONSTANT VARCHAR2(100) := 'NAME';
RP_NAME                   CONSTANT VARCHAR2(100) := 'NAME';
AP_DB_PRES_SYNTAX         CONSTANT VARCHAR2(100) := 'DB_PRES_SYNTAX';
RP_DB_PRES_SYNTAX         CONSTANT VARCHAR2(100) := 'DB_PRES_SYNTAX';
AP_SCREEN_SORT_ORDER      CONSTANT VARCHAR2(100) := 'SCREEN_SORT_ORDER';
RP_SCREEN_SORT_ORDER      CONSTANT VARCHAR2(100) := 'SCREEN_SORT_ORDER';

/* *_PRESENTATION properties */
PP_VIEWLABELHEAD          CONSTANT VARCHAR2(100) := 'viewlabelhead';

TYPE PropertyValueCache1_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(250);
TYPE PropertyValueCache2_t IS TABLE OF PropertyValueCache1_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache3_t IS TABLE OF PropertyValueCache2_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache4_t IS TABLE OF PropertyValueCache3_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache5_t IS TABLE OF PropertyValueCache4_t INDEX BY VARCHAR2(250);

/**
 * Class property caches
 * =====================
 * VIEWLAYER property caches for a single class
 */
VL_CLASS_PROPERTY_CACHE    PropertyValueCache2_t;
VL_ATTR_PROPERTY_CACHE     PropertyValueCache3_t;
VL_REL_PROPERTY_CACHE      PropertyValueCache4_t;
VL_TRA_PROPERTY_CACHE      PropertyValueCache5_t;

/**
 * Class property caches
 * =====================
 * APPLICATION property caches for a single class
 */
AP_CLASS_PROPERTY_CACHE    PropertyValueCache2_t;
AP_ATTR_PROPERTY_CACHE     PropertyValueCache3_t;
AP_REL_PROPERTY_CACHE      PropertyValueCache4_t;
AP_TRA_PROPERTY_CACHE      PropertyValueCache5_t;

CACHING_MODE VARCHAR2(32) := 'SESSION';

CURSOR c_class_property_max(
       p_class_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.class_name, p.property_code, p.property_value
  FROM class_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_property_cnfg x
        WHERE p.class_name = x.class_name AND p.property_code = x.property_code AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_class_rel_property_max(
       p_from_class_name IN VARCHAR2,
       p_to_class_name IN VARCHAR2,
       p_role_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.from_class_name, p.to_class_name, p.role_name, p.property_code, p.property_value
  FROM class_rel_property_cnfg p
  WHERE p.from_class_name = Nvl(p_from_class_name, p.from_class_name)
  AND p.to_class_name = p_to_class_name
  AND p.role_name = Nvl(p_role_name, p.role_name)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_rel_property_cnfg x
        WHERE p.from_class_name = x.from_class_name
        AND p.to_class_name = x.to_class_name
        AND p.role_name = x.role_name
        AND p.property_code = x.property_code
        AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_class_tra_property_max(
       p_class_name IN VARCHAR2,
       p_triggering_event IN VARCHAR2,
       p_trigger_type IN VARCHAR2,
       p_sort_order IN NUMBER,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2) IS
  SELECT p.class_name, p.triggering_event, p.trigger_type, p.sort_order, p.property_code, p.property_value
  FROM class_tra_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.triggering_event = Nvl(p_triggering_event, p.triggering_event)
  AND p.trigger_type = Nvl(p_trigger_type, p.trigger_type)
  AND p.sort_order = Nvl(p_sort_order, p.sort_order)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_tra_property_cnfg x
        WHERE p.class_name = x.class_name
        AND p.triggering_event = x.triggering_event
        AND p.trigger_type = x.trigger_type
        AND p.sort_order = x.sort_order
        AND p.property_code = x.property_code
  );

CURSOR c_class_attr_property_max(
       p_class_name IN VARCHAR2,
       p_attribute_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.class_name, p.attribute_name, p.property_code, p.property_value
  FROM class_attr_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.attribute_name = Nvl(p_attribute_name, p.attribute_name)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_attr_property_cnfg x
        WHERE p.class_name = x.class_name
        AND p.attribute_name = x.attribute_name
        AND p.property_code = x.property_code
        AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_attr_presentation_syntax_max(
       p_class_name IN VARCHAR2,
       p_attribute_name IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT class_name, attribute_name, property_type, presentation_cntx,
       CASE WHEN p_property_type = 'STATIC_PRESENTATION' THEN
                 LISTAGG(property_code||'='||property_value, ';') WITHIN GROUP (ORDER BY property_code)
            WHEN p_property_type = 'DYNAMIC_PRESENTATION' THEN
                 LISTAGG(chr(39)||property_code||'='||chr(39)||'||'||property_value, '|| '';'' ||') WITHIN GROUP (ORDER BY property_code)
       END AS presentation_syntax
  FROM (
    SELECT x.*, p.property_value FROM (
      SELECT class_name, attribute_name, property_type, presentation_cntx, property_code, max(owner_cntx) AS owner_cntx, count(*)
      FROM class_attr_property_cnfg
      GROUP BY class_name, attribute_name, property_type, presentation_cntx, property_code
    ) x
    INNER JOIN class_attr_property_cnfg p ON p.class_name = x.class_name
                                         AND p.attribute_name = x.attribute_name
                                         AND p.presentation_cntx = x.presentation_cntx
                                         AND p.property_code = x.property_code
                                         AND p.property_type = x.property_type
    WHERE p.class_name = p_class_name
    AND   p.attribute_name = p_attribute_name
    AND   p.property_type = p_property_type
    AND   p.presentation_cntx = p_presentation_cntx
    AND   p.property_code<>AP_PRESENTATION_SYNTAX
  )
  GROUP BY class_name, attribute_name, property_type, presentation_cntx;

CURSOR c_rel_presentation_syntax_max(
       p_from_class_name IN VARCHAR2,
       p_to_class_name IN VARCHAR2,
       p_role_name IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT from_class_name, to_class_name, role_name, property_type, presentation_cntx,
         CASE WHEN p_property_type = 'STATIC_PRESENTATION' THEN
                   LISTAGG(property_code||'='||property_value, ';') WITHIN GROUP (ORDER BY property_code)
              WHEN p_property_type = 'DYNAMIC_PRESENTATION' THEN
                   LISTAGG(chr(39)||property_code||'='||chr(39)||'||'||property_value, '|| '';'' ||') WITHIN GROUP (ORDER BY property_code)
         END AS presentation_syntax
  FROM (
    SELECT x.*, p.property_value FROM (
      SELECT from_class_name, to_class_name, role_name, property_type, presentation_cntx, property_code, max(owner_cntx) AS owner_cntx, count(*)
      FROM class_rel_property_cnfg
      GROUP BY from_class_name, to_class_name, role_name, property_type, presentation_cntx, property_code
    ) x
    INNER JOIN class_rel_property_cnfg p ON p.from_class_name = x.from_class_name
                                        AND p.to_class_name = x.to_class_name
                                        AND p.role_name = x.role_name
                                        AND p.presentation_cntx = x.presentation_cntx
                                        AND p.property_code = x.property_code
                                        AND p.property_type = x.property_type
    WHERE p.from_class_name = p_from_class_name
    AND   p.to_class_name = p_to_class_name
    AND   p.role_name = p_role_name
    AND   p.property_type = p_property_type
    AND   p.presentation_cntx = p_presentation_cntx
    AND   p.property_code<>RP_PRESENTATION_SYNTAX
  )
  GROUP BY from_class_name, to_class_name, role_name, property_type, presentation_cntx;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassAttrProperty
-- Description    : Updates or inserts into class_attr_property_cnfg
--                  This procedure should only be used by more specific procedures in this package
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTR_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassAttrProperty(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN

  -- TODO: Should NULL mean all pres cntx? What about when it is not existing for owner context

  UPDATE class_attr_property_cnfg
    SET
      property_value = p_property_value
    WHERE class_name = p_class_name
      AND attribute_name = p_attribute_name
      AND presentation_cntx = p_presentation_cntx
      AND owner_cntx = p_owner_cntx
      AND property_type = p_property_type
      AND property_code = p_property_code;

  INSERT INTO class_attr_property_cnfg (class_name, attribute_name, presentation_cntx, owner_cntx, property_type, property_code, property_value)
  SELECT p_class_name, p_attribute_name, p_presentation_cntx, p_owner_cntx, p_property_type, p_property_code, p_property_value
  FROM DUAL
  WHERE NOT EXISTS(
    SELECT 'X'
      FROM class_attr_property_cnfg
      WHERE class_name = p_class_name
        AND attribute_name = p_attribute_name
        AND presentation_cntx = p_presentation_cntx
        AND owner_cntx = p_owner_cntx
        AND property_type = p_property_type
        AND property_code = p_property_code
    );

END SetClassAttrProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassRelProperty
-- Description    : Updates or inserts into class_rel_property_cnfg
--                  This procedure should only be used by more specific procedures in this package
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_REL_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassRelProperty(
    p_from_class_name VARCHAR2,
    p_to_class_name VARCHAR2,
    p_role_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN
  UPDATE  class_rel_property_cnfg
    SET   property_value = p_property_value
    WHERE from_class_name = p_from_class_name
      AND to_class_name = p_to_class_name
      AND role_name = p_role_name
      AND presentation_cntx = p_presentation_cntx
      AND owner_cntx = p_owner_cntx
      AND property_type = p_property_type
      AND property_code = p_property_code;

  IF SQL%ROWCOUNT < 1 THEN
     INSERT INTO class_rel_property_cnfg (from_class_name, to_class_name, role_name, presentation_cntx, owner_cntx, property_type, property_code, property_value)
     VALUES (p_from_class_name, p_to_class_name, p_role_name, p_presentation_cntx, p_owner_cntx, p_property_type, p_property_code, p_property_value);
  END IF;
END SetClassRelProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassAttrDisabledInd
-- Description    : Updates or inserts the disabled indicator for a class.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTR_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassAttrDisabledInd(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2, -- Should NULL mean all pres cntx? What about when it is not existing for owner context
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN
  SetClassAttrProperty(p_class_name, p_attribute_name, p_presentation_cntx, p_owner_cntx, 'VIEWLAYER', 'DISABLED_IND', p_property_value);
END SetClassAttrDisabledInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassRelDisabledInd
-- Description    : Updates or inserts the disabled indicator for a class relation.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_REL_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassRelDisabledInd(
    p_from_class_name VARCHAR2,
    p_to_class_name VARCHAR2,
    p_role_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN
  SetClassRelProperty(p_from_class_name, p_to_class_name, p_role_name, p_presentation_cntx, p_owner_cntx, 'VIEWLAYER', 'DISABLED_IND', p_property_value);
END SetClassRelDisabledInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : AssertValidProperty
-- Description    : Raises exception if the given property value is not valid for the given table.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_PROPERTY_CNFG,
--                  CLASS_ATTR_PROPERTY_CNFG,
--                  CLASS_REL_PROPERTY_CNFG,
--                  CLASS_TRA_PROPERTY_CNFG
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AssertValidProperty(
    p_property_table_name VARCHAR2,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2,
    p_presentation_cntx VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  CURSOR c_property_codes(cp_property_table_name VARCHAR2, cp_property_type VARCHAR2, cp_property_code VARCHAR2) IS
    SELECT property_table_name, property_type, property_code, data_type
    FROM   class_property_codes
    WHERE  property_table_name = upper(cp_property_table_name)
    AND    property_type = upper(cp_property_type)
    AND    property_code = cp_property_code;

  ln_number NUMBER;
BEGIN
  IF p_property_table_name IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_table_name is null.');
  END IF;
  IF p_property_code IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_code is null.');
  END IF;
  IF p_property_type IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_type is null.');
  END IF;

  FOR cur IN c_property_codes(p_property_table_name, p_property_type, p_property_code) LOOP
    IF cur.data_type = 'NUMBER' AND p_property_value IS NOT NULL THEN
      BEGIN
         ln_number := TO_NUMBER(p_property_value);
      EXCEPTION
      WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(
          -20002,
          'Expected a numeric value for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END;
    END IF;
    IF cur.data_type = 'BOOLEAN' AND p_property_value IS NOT NULL THEN
      IF p_property_type = 'STATIC_PRESENTATION' AND p_property_value NOT IN ('true', 'false') THEN
        RAISE_APPLICATION_ERROR(
          -20002,
          'Expected a value of "true" or "false" for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END IF;
      IF p_property_type IN ('VIEWLAYER', 'APPLICATION') AND p_property_value NOT IN ('Y', 'N') THEN
        RAISE_APPLICATION_ERROR(
          -20002,
          'Expected a value of "Y" or "N" for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END IF;
    END IF;
	IF p_property_table_name <> CLASS_TRA_PROPERTY_CNFG  AND p_property_type = 'VIEWLAYER' AND p_presentation_cntx <> '/' THEN
        RAISE_APPLICATION_ERROR(
          -20002,
          'Expected presentation_cntx=''/'' when property_type=''VIEWLAYER'' for '||p_property_table_name||' with '||
          'p_presentation_cntx="'||p_presentation_cntx||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
	END IF;
    RETURN;
  END LOOP;

  -- TODO: Should we rely on constraints in the property cnfg tables instead?
  --
  RAISE_APPLICATION_ERROR(
          -20002,
          'No class_property_codes where '||
          'property_table_name='||CHR(39)||p_property_table_name||CHR(39)||' and '||
          'property_type='||CHR(39)||p_property_type||CHR(39)||' and '||
          'property_code='||CHR(39)||p_property_code||CHR(39)||'.');
END AssertValidProperty;

FUNCTION getClassViewName(p_class_name IN VARCHAR2, p_class_type IN VARCHAR2) RETURN VARCHAR2
IS
  lv2_pfx VARCHAR2(32);
BEGIN
  lv2_pfx := CASE p_class_type
               WHEN 'OBJECT' THEN 'OV_'
               WHEN 'DATA' THEN 'DV_'
               WHEN 'SUB_CLASS' THEN 'OSV_'
               WHEN 'INTERFACE' THEN 'IV_'
               WHEN 'TABLE' THEN 'TV_'
               ELSE NULL
             END;
  IF lv2_pfx IS NOT NULL THEN
    RETURN lv2_pfx||p_class_name;
  END IF;
  RAISE_APPLICATION_ERROR(-20104, 'Unknown class_type '||p_class_type||' for class_name '||p_class_name||'.');
END getClassViewName;

PROCEDURE flushCache
IS
BEGIN
  VL_CLASS_PROPERTY_CACHE.DELETE;
  VL_ATTR_PROPERTY_CACHE.DELETE;
  VL_REL_PROPERTY_CACHE.DELETE;
  VL_TRA_PROPERTY_CACHE.DELETE;
  AP_CLASS_PROPERTY_CACHE.DELETE;
  AP_ATTR_PROPERTY_CACHE.DELETE;
  AP_REL_PROPERTY_CACHE.DELETE;
  AP_TRA_PROPERTY_CACHE.DELETE;
END flushCache;

FUNCTION getCacheSize(p_cache IN PropertyValueCache1_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + LENGTH(Nvl(p_cache(ln_idx), 0));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache2_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache3_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache4_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache5_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize
RETURN NUMBER
IS
BEGIN
  RETURN getCacheSize(VL_CLASS_PROPERTY_CACHE)
       + getCacheSize(VL_ATTR_PROPERTY_CACHE)
       + getCacheSize(VL_REL_PROPERTY_CACHE)
       + getCacheSize(VL_TRA_PROPERTY_CACHE)
       + getCacheSize(AP_CLASS_PROPERTY_CACHE)
       + getCacheSize(AP_ATTR_PROPERTY_CACHE)
       + getCacheSize(AP_REL_PROPERTY_CACHE)
       + getCacheSize(AP_TRA_PROPERTY_CACHE);

END getCacheSize;

---------------------------------------------------------------------------------------------------
-- Function       : cacheClass *** INTERNAL ***
-- Description    : Cache all VIEWLAYER propertes for the given class to improve performance
---------------------------------------------------------------------------------------------------
PROCEDURE cacheClassProperties(p_class_name IN VARCHAR2)
IS
BEGIN
  IF VL_CLASS_PROPERTY_CACHE.COUNT > 0 AND VL_CLASS_PROPERTY_CACHE.FIRST <> p_class_name THEN
    flushCache;
  END IF;
  IF VL_CLASS_PROPERTY_CACHE.COUNT = 0 THEN
    VL_CLASS_PROPERTY_CACHE(p_class_name)('__FLAG__') := 'Y';

    FOR cur IN c_class_property_max(p_class_name, NULL, 'VIEWLAYER', '/') LOOP
      VL_CLASS_PROPERTY_CACHE(cur.class_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_property_max(p_class_name, NULL, 'APPLICATION', '/EC') LOOP
      AP_CLASS_PROPERTY_CACHE(cur.class_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_attr_property_max(p_class_name, NULL, NULL, 'VIEWLAYER', '/') LOOP
      VL_ATTR_PROPERTY_CACHE(cur.class_name)(cur.attribute_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_attr_property_max(p_class_name, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_ATTR_PROPERTY_CACHE(cur.class_name)(cur.attribute_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_rel_property_max(NULL, p_class_name, NULL, NULL, 'VIEWLAYER', '/') LOOP
      VL_REL_PROPERTY_CACHE(cur.from_class_name)(cur.to_class_name)(cur.role_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_rel_property_max(NULL, p_class_name, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_REL_PROPERTY_CACHE(cur.from_class_name)(cur.to_class_name)(cur.role_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_tra_property_max(p_class_name, NULL, NULL, NULL, 'VIEWLAYER', '/') LOOP
      VL_TRA_PROPERTY_CACHE(cur.class_name)(cur.triggering_event)(cur.trigger_type)(cur.sort_order)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_tra_property_max(p_class_name, NULL, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_TRA_PROPERTY_CACHE(cur.class_name)(cur.triggering_event)(cur.trigger_type)(cur.sort_order)(cur.property_code) := cur.property_value;
    END LOOP;
  END IF;
END cacheClassProperties;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  trigger action property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_triggering_event IS NOT NULL AND p_trigger_type IS NOT NULL AND p_sort_order IS NOT NULL THEN
    IF VL_TRA_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_TRA_PROPERTY_CACHE(p_class_name).EXISTS(p_triggering_event) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event).EXISTS(p_trigger_type) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type).EXISTS(p_sort_order) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order).EXISTS(p_property_code) THEN
      RETURN VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
     VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_tra_property_max(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, p_property_code, 'VIEWLAYER') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_from_class_name IS NOT NULL AND p_to_class_name IS NOT NULL AND p_role_name IS NOT NULL THEN
    IF VL_REL_PROPERTY_CACHE.EXISTS(p_from_class_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name).EXISTS(p_to_class_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name).EXISTS(p_role_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name).EXISTS(p_property_code) THEN
      RETURN VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'VIEWLAYER', '/') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_attribute_name IS NOT NULL THEN
    IF VL_ATTR_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_ATTR_PROPERTY_CACHE(p_class_name).EXISTS(p_attribute_name) AND
       VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name).EXISTS(p_property_code) THEN
      RETURN VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'VIEWLAYER', '/') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStaticPresProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'STATIC_PRESENTATION', '/EC') LOOP
    RETURN cur.property_value;
  END LOOP;
  RETURN NULL;
END getMaxStaticPresProperty;


---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStaticPresProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'STATIC_PRESENTATION', '/EC') LOOP
    RETURN cur.property_value;
  END LOOP;
  RETURN NULL;
END getMaxStaticPresProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  class property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL THEN
    IF VL_CLASS_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_CLASS_PROPERTY_CACHE(p_class_name).EXISTS(p_property_code) THEN
      RETURN VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_property_max(p_class_name, p_property_code, 'VIEWLAYER', '/') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_from_class_name IS NOT NULL AND p_to_class_name IS NOT NULL AND p_role_name IS NOT NULL THEN
    IF AP_REL_PROPERTY_CACHE.EXISTS(p_from_class_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name).EXISTS(p_to_class_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name).EXISTS(p_role_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name).EXISTS(p_property_code) THEN
      RETURN AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_attribute_name IS NOT NULL THEN
    IF AP_ATTR_PROPERTY_CACHE.EXISTS(p_class_name) AND
       AP_ATTR_PROPERTY_CACHE(p_class_name).EXISTS(p_attribute_name) AND
       AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name).EXISTS(p_property_code) THEN
      RETURN AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  class property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_class_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL THEN
    IF AP_CLASS_PROPERTY_CACHE.EXISTS(p_class_name) AND
       AP_CLASS_PROPERTY_CACHE(p_class_name).EXISTS(p_property_code) THEN
      RETURN AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_property_max(p_class_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClassShortCode
-- Description    : Returns the CLASS_SHORT_CODE property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getClassShortCode(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_CLASS_SHORT_CODE);
END getClassShortCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReadOnly
-- Description    : Returns the READ_ONLY_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReadOnly(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_READ_ONLY_IND), 'N');
END isReadOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : skipTriggerCheck
-- Description    : Returns the SKIP_TRG_CHECK_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION skipTriggerCheck(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_SKIP_TRG_CHECK_IND), 'N');
END skipTriggerCheck;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCreateEventInd
-- Description    : Returns the CREATE_EV_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getCreateEventInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_CREATE_EV_IND), 'N');
END getCreateEventInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getApprovalInd
-- Description    : Returns the APPROVAL_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getApprovalInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_APPROVAL_IND), 'N');
END getApprovalInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInWebservice
-- Description    : Returns the INCLUDE_WEBSERVICE property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInWebservice(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_INCLUDE_WEBSERVICE), 'N');
END includeInWebservice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInMapping
-- Description    : Returns the INCLUDE_IN_MAPPING_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'Y'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInMapping(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_INCLUDE_IN_MAPPING_IND), 'Y');
END includeInMapping;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInValidation
-- Description    : Returns the INCLUDE_IN_VALIDATION property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInValidation(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxApplicationProperty(p_class_name, CP_INCLUDE_IN_VALIDATION), 'N');
END includeInValidation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLockInd
-- Description    : Returns the LOCK_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getLockInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_LOCK_IND), 'N');
END getLockInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLockRule
-- Description    : Returns the LOCK_RULE property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getLockRule(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_LOCK_RULE);
END getLockRule;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEnsureRevTextOnUpdate
-- Description    : Returns the ENSURE_REV_TEXT_ON_UPD property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getEnsureRevTextOnUpdate(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_ENSURE_REV_TEXT_ON_UPD), 'N');
END getEnsureRevTextOnUpdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccessControlInd
-- Description    : Returns the ACCESS_CONTROL_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getAccessControlInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_ACCESS_CONTROL_IND), 'N');
END getAccessControlInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, CP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, CP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getScreenSortOrder
-- Description    : Returns the SCREEN_SORT_ORDER property with the highest owner_cntx for the given attribute.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getScreenSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxApplicationProperty(p_class_name, p_attribute_name, AP_SCREEN_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       AP_SCREEN_SORT_ORDER||' property for class attribute '||p_class_name||'.'||p_attribute_name||' is not a number. '||CHR(10)||SQLERRM);
END getScreenSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getScreenSortOrder
-- Description    : Returns the SCREEN_SORT_ORDER property with the highest owner_cntx for the given relation.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getScreenSortOrder(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_SCREEN_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       RP_SCREEN_SORT_ORDER||' property for class relation '||p_from_class_name||'.'||p_to_class_name||'.'||p_role_name||' is not a number. '||CHR(10)||SQLERRM);
END getScreenSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getJournalRuleDbSyntax
-- Description    : Returns the JOURNAL_RULE_DB_SYNTAX property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getJournalRuleDbSyntax(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_JOURNAL_RULE_DB_SYNTAX);
END getJournalRuleDbSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReadOnly
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReadOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxApplicationProperty(p_class_name, p_attribute_name, AP_READ_ONLY_IND), 'N');
END isReadOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbPresSyntax
-- Description    : Returns the DB_PRES_SYNTAX property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getDbPresSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_DB_PRES_SYNTAX);
END getDbPresSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isMandatory
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isMandatory(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_IS_MANDATORY), 'N');
END isMandatory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbSortOrder
-- Description    : Returns the DB_SORT_ORDER property with the highest owner_cntx for the given attribute.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getDbSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_DB_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       AP_DB_SORT_ORDER||' property for class attribude '||p_class_name||'.'||p_attribute_name||' is not a number. '||CHR(10)||SQLERRM);
END getDbSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getUomCode
-- Description    : Returns the UOM_CODE property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getUomCode(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_UOM_CODE);
END getUomCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStaticPresentationSyntax
-- Description    : Returns STATIC_PRESENTATION properties with the highest owner_cntx for the given
--                  attribute as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 static_presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_attr_presentation_syntax_max(p_class_name, p_attribute_name, 'STATIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.presentation_syntax;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getStaticPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDynamicPresentationSyntax
-- Description    : Returns DYNAMIC_PRESENTATION properties with the highest owner_cntx for the given
--                  attribute as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getDynamicPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, RP_PRESENTATION_SYNTAX, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.property_value;
    EXIT;
  END LOOP;

  -- TODO: If an attribute has a PresentationSyntax property, should we ignore the individual DYNAMIC_PRESENTATION properties?
  --
  /*
  IF lv2_presentation_syntax IS NOT NULL THEN
    RETURN lv2_presentation_syntax;
  END IF;
  */

  FOR cur IN c_attr_presentation_syntax_max(p_class_name, p_attribute_name, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    IF lv2_presentation_syntax IS NOT NULL THEN
      lv2_presentation_syntax := lv2_presentation_syntax || ';' || cur.presentation_syntax;
    ELSE
      lv2_presentation_syntax := cur.presentation_syntax;
    END IF;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getDynamicPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReportOnly
-- Description    : Returns the REPORT_ONLY_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReportOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_REPORT_ONLY_IND), 'N');
END isReportOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the viewlabelhead property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticViewlabelhead(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxStaticPresProperty(p_class_name, p_attribute_name, PP_VIEWLABELHEAD);
END getStaticViewlabelhead;
--FUNCTION getStaticViewhidden(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the viewhidden property with the highest owner_cntx for the given attribute.
--                  Defaults to 'false'.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticViewhidden(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxStaticPresProperty(p_class_name, p_attribute_name, PP_VIEWLABELHEAD), 'false');
END getStaticViewhidden;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getName
-- Description    : Returns the NAME property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getName(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_NAME);
END getName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbSortOrder
-- Description    : Returns the DB_SORT_ORDER property with the highest owner_cntx for the given relation.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getDbSortOrder(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DB_SORT_ORDER), '0'));
END getDbSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocPriority
-- Description    : Returns the ALLOC_PRIORITY property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getAllocPriority(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_property_value VARCHAR2(4000);
BEGIN
  lv2_property_value := getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_ALLOC_PRIORITY);
  RETURN CASE WHEN lv2_property_value IS NULL THEN NULL ELSE to_number(lv2_property_value) END;
END getAllocPriority;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbPresSyntax
-- Description    : Returns the DB_PRES_SYNTAX property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getDbPresSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DB_PRES_SYNTAX);
END getDbPresSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getName
-- Description    : Returns the NAME property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getName(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_NAME);
END getName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getApprovalInd
-- Description    : Returns the APPROVAL_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_APPROVAL_IND), 'N');
END getApprovalInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReverseApprovalInd
-- Description    : Returns the REVERSE_APPROVAL_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getReverseApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_REVERSE_APPROVAL_IND), 'N');
END getReverseApprovalInd;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isMandatory
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isMandatory(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_IS_MANDATORY), 'N');
END isMandatory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccessControlMethod
-- Description    : Returns the ACCESS_CONTROL_METHOD property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getAccessControlMethod(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_ACCESS_CONTROL_METHOD);
END getAccessControlMethod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReportOnly
-- Description    : Returns the REPORT_ONLY_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReportOnly(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_REPORT_ONLY_IND), 'N');
END isReportOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStaticPresentationSyntax
-- Description    : Returns STATIC_PRESENTATION properties with the highest owner_cntx for the given
--                  relation as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 static_presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_rel_presentation_syntax_max(p_from_class_name, p_to_class_name, p_role_name, 'STATIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.presentation_syntax;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getStaticPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDynamicPresentationSyntax
-- Description    : Returns DYNAMIC_PRESENTATION properties with the highest owner_cntx for the given
--                  relation as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getDynamicPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, RP_PRESENTATION_SYNTAX, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.property_value;
    EXIT;
  END LOOP;

  -- TODO: If a relation has a PresentationSyntax property, should individual DYNAMIC_PRESENTATION properties be ignored?
  --
  /*
  IF lv2_presentation_syntax IS NOT NULL THEN
    RETURN lv2_presentation_syntax;
  END IF;
  */

  FOR cur IN c_rel_presentation_syntax_max(p_from_class_name, p_to_class_name, p_role_name, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    IF lv2_presentation_syntax IS NOT NULL THEN
      lv2_presentation_syntax := lv2_presentation_syntax || ';' || cur.presentation_syntax;
    ELSE
      lv2_presentation_syntax := cur.presentation_syntax;
    END IF;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getDynamicPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given trigger action.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, TP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given trigger action.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, TP_DESCRIPTION);
END getDescription;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CLASS_PROPERTY_CNFG
-- Description    : Returns CLASS_PROPERTY_CNFG table name.
---------------------------------------------------------------------------------------------------
FUNCTION CLASS_PROPERTY_CNFG
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN 'CLASS_PROPERTY_CNFG';
END CLASS_PROPERTY_CNFG;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CLASS_ATTR_PROPERTY_CNFG
-- Description    : Returns CLASS_ATTR_PROPERTY_CNFG table name.
---------------------------------------------------------------------------------------------------
FUNCTION CLASS_ATTR_PROPERTY_CNFG
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN 'CLASS_ATTR_PROPERTY_CNFG';
END CLASS_ATTR_PROPERTY_CNFG;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CLASS_REL_PROPERTY_CNFG
-- Description    : Returns CLASS_REL_PROPERTY_CNFG table name.
---------------------------------------------------------------------------------------------------
FUNCTION CLASS_REL_PROPERTY_CNFG
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN 'CLASS_REL_PROPERTY_CNFG';
END CLASS_REL_PROPERTY_CNFG;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CLASS_TRA_PROPERTY_CNFG
-- Description    : Returns CLASS_TRA_PROPERTY_CNFG table name.
---------------------------------------------------------------------------------------------------
FUNCTION CLASS_TRA_PROPERTY_CNFG
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN 'CLASS_TRA_PROPERTY_CNFG';
END CLASS_TRA_PROPERTY_CNFG;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isViewlayerProperty
-- Description    : Returns 'Y' if the given property code is a VIEWLAYER property for the given
--                  given table.
---------------------------------------------------------------------------------------------------
FUNCTION isViewlayerProperty(p_property_table_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  IF ec_class_property_codes.row_by_pk(p_property_table_name, p_property_code,'VIEWLAYER').property_table_name IS NOT NULL THEN
    RETURN 'Y';
  END IF;
  RETURN 'N';
END isViewlayerProperty;

END EcDp_ClassMeta_cnfg;