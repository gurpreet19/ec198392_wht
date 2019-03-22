CREATE OR REPLACE PACKAGE BODY Ecdp_Calc_Mapping IS
/****************************************************************
** Package        :  Ecdp_Calc_Mapping, body part
**
** $Revision: 1.20 $
**
** Purpose        :  Support functions for the calculation metadata (object, attribute and variable mappings).
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.12.2008
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : copyVariable
-- Description    : Copies a variable definition, including all mappings.
--
-- Preconditions  : The new variabe name should not already be used in the target context.
--                  If the target context is different from the source context, then it is
--                  assumed that all necessary object types exist in the target context.
-- Postconditions :
--
-- Using tables   : calc_variable, calc_var_read_mapping, calc_var_key_read_mapping, calc_var_write_mapping, calc_var_key_write_mapping
--
-- Using functions: GetVariableSignature, ec_calc_variable,
--                  EcDp_User_Session.getUserSessionParameter, Ecdp_Timestamp.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Copies the variable to a new variable with the same dimensions but a new name.
--                  If the p_new_object_id parameter is NULL then the new variable will be put
--                  in the same calculation context as the original variable.
--                  If the p_new_name parameter is NULL then the new variable will get the same
--                  name as the original.
--                  At least one of these two must be filled in.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE copyVariable (
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_new_object_id       VARCHAR2,
   p_new_name            VARCHAR2
)
--</EC-DOC>
IS
   CURSOR c_read_mappings IS
      SELECT * FROM calc_var_read_mapping
      WHERE object_id = p_object_id
      AND calc_var_signature = p_calc_var_signature;

   CURSOR c_read_key_mappings IS
      SELECT * FROM calc_var_key_read_mapping
      WHERE object_id = p_object_id
      AND calc_var_signature = p_calc_var_signature;

   CURSOR c_write_mappings IS
      SELECT * FROM calc_var_write_mapping
      WHERE object_id = p_object_id
      AND calc_var_signature = p_calc_var_signature;

   CURSOR c_write_key_mappings IS
      SELECT * FROM calc_var_key_write_mapping
      WHERE object_id = p_object_id
      AND calc_var_signature = p_calc_var_signature;

   var                   calc_variable%ROWTYPE;
   lv_user               VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate            DATE := Ecdp_Timestamp.getCurrentSysdate;
BEGIN
   --
   -- First copy the variable definition itself
   --
   var := ec_calc_variable.row_by_pk(p_object_id, p_calc_var_signature);
   var.object_id := NVL(p_new_object_id, var.object_id);
   var.name := NVL(p_new_name, var.name);
   var.calc_var_signature := GetVariableSignature(var.name, var.dim1_object_type_code, var.dim2_object_type_code, var.dim3_object_type_code, var.dim4_object_type_code, var.dim5_object_type_code);
   var.created_by:=lv_user; var.created_date:=ld_sysdate; var.last_updated_by:=NULL; var.last_updated_date:=NULL; var.rev_no:=0; var.rev_text:=NULL; var.record_status:='P'; var.approval_by:=NULL; var.approval_date:=NULL; var.approval_state:=NULL; var.rec_id:=SYS_GUID();
   INSERT INTO calc_variable VALUES var;

   --
   -- Copy read mappings (only the mapping itself, not the keys)
   --
   FOR m IN c_read_mappings LOOP
      m.object_id := var.object_id;
      m.calc_var_signature := var.calc_var_signature;
      m.created_by:=lv_user; m.created_date:=ld_sysdate; m.last_updated_by:=NULL; m.last_updated_date:=NULL; m.rev_no:=0; m.rev_text:=NULL; m.record_status:='P'; m.approval_by:=NULL; m.approval_date:=NULL; m.approval_state:=NULL; m.rec_id:=SYS_GUID();
      INSERT INTO calc_var_read_mapping VALUES m;
   END LOOP;

   --
   -- Copy read mapping key mappings
   --
   FOR m IN c_read_key_mappings LOOP
      m.object_id := var.object_id;
      m.calc_var_signature := var.calc_var_signature;
      m.created_by:=lv_user; m.created_date:=ld_sysdate; m.last_updated_by:=NULL; m.last_updated_date:=NULL; m.rev_no:=0; m.rev_text:=NULL; m.record_status:='P'; m.approval_by:=NULL; m.approval_date:=NULL; m.approval_state:=NULL; m.rec_id:=SYS_GUID();
      INSERT INTO calc_var_key_read_mapping VALUES m;
   END LOOP;

   --
   -- Copy write mappings (only the mapping itself, not the keys)
   --
   FOR m IN c_write_mappings LOOP
      m.object_id := var.object_id;
      m.calc_var_signature := var.calc_var_signature;
      m.created_by:=lv_user; m.created_date:=ld_sysdate; m.last_updated_by:=NULL; m.last_updated_date:=NULL; m.rev_no:=0; m.rev_text:=NULL; m.record_status:='P'; m.approval_by:=NULL; m.approval_date:=NULL; m.approval_state:=NULL; m.rec_id:=SYS_GUID();
      INSERT INTO calc_var_write_mapping VALUES m;
   END LOOP;

   --
   -- Copy write mapping key mappings
   --
   FOR m IN c_write_key_mappings LOOP
      m.object_id := var.object_id;
      m.calc_var_signature := var.calc_var_signature;
      m.created_by:=lv_user; m.created_date:=ld_sysdate; m.last_updated_by:=NULL; m.last_updated_date:=NULL; m.rev_no:=0; m.rev_text:=NULL; m.record_status:='P'; m.approval_by:=NULL; m.approval_date:=NULL; m.approval_state:=NULL; m.rec_id:=SYS_GUID();
      INSERT INTO calc_var_key_write_mapping VALUES m;
   END LOOP;

END copyVariable;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : addVariableAttrMappings
-- Description    : Insert key attribute mappings for a variable read mapping.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class, class_attribute, class_relation, calc_object_type, calc_var_key_read_mapping
--
-- Using functions: getVariableDimensions, getEstimatedObjectType
--                  ec_class_attr_db_mapping, ec_class_rel_db_mapping
--
-- Configuration
-- required       :
--
-- Behaviour      : Only adds mappings if the operation is 'create' (row inserted from screen).
--                  This procedure is used on insert of new variable read mappings to create
--                  a default class key mapping. The procedure tries to determine the correct mapping
--                  for each key by comparing an estimated object type (based on attribute name,
--                  data type and class relations) to the dimensions on the variable.
--                  Keys that the procedure is not able to determine a default mapping for will
--                  still be created but with a NULL mapping.
--                  The class attributes PRODUCTION_DAY and SUMMERTIME get special handling since
--                  there is not a one to one relationship between class keys and variable dimensions
--                  for sub-daily data.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE addVariableAttrMappings(
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
)
--</EC-DOC>
IS
   lv_ref_obj_type       VARCHAR2(32);
   ln_dim_no             NUMBER;
   ln_cnt                NUMBER;
   var_dims              CalcVarDimensions;
   lv2_mapping_type      VARCHAR2(32);
   lv2_user_id           VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

   CURSOR c_variable_attribute_key (cp_class_name VARCHAR2) IS
      SELECT ca.class_name,
             ca.attribute_name,
             EcDp_ClassMeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) as sort_order,
             ca.data_type,
             DECODE(ca.attribute_name,'OBJECT_ID', DECODE(c.class_type,'OBJECT',c.class_name,'INTERFACE',c.class_name,'DATA',c.owner_class_name,NULL), 'COMPONENT_NO', 'HYDROCARBON_COMPONENT', NULL) as ref_class
      FROM class_attribute_cnfg ca, class_cnfg c
      WHERE ca.class_name = cp_class_name
      AND c.class_name = ca.class_name
      AND (is_key = 'Y' OR attribute_name IN ('PRODUCTION_DAY'))
      AND attribute_name not in ('SUMMER_TIME')
      UNION ALL
      SELECT cr.to_class_name as class_name,
             cr.role_name || '_ID' as attribute_name,
             EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) as sort_order,
             'STRING' as data_type,
             cr.from_class_name as ref_class
      FROM class_relation_cnfg cr
      WHERE to_class_name = cp_class_name
      AND is_key = 'Y'
      ORDER BY sort_order;
BEGIN
   IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
   END IF;
   var_dims := getVariableDimensions(p_object_id, p_calc_var_signature);
   FOR cur_var IN c_variable_attribute_key(p_class_name) LOOP
     -- Try to find default mapping for this attribute based on data / object type
     -- 1) Owner and Object relation: Try to find corresponding Object Type
     -- 2) Date: Look for corresponding dimension(s) of type PREDEFINED DATE
     ln_dim_no := NULL;

     -- First try to see if this is a DB object type, and map that to a dimension
     lv_ref_obj_type := getEstimatedObjectType(p_object_id, cur_var.ref_class);
     IF lv_ref_obj_type IS NOT NULL THEN
        -- Try to find a dimension of the same object type
        FOR i IN 1..5 LOOP
           IF ln_dim_no IS NULL AND var_dims(i) = lv_ref_obj_type THEN
              ln_dim_no := i;
              var_dims(i) := NULL;
           END IF;
        END LOOP;
     END IF;

     -- Then try to see if this is a DATE type dimension, and map that
     IF ln_dim_no IS NULL AND cur_var.data_type = 'DATE' THEN
        FOR i IN 1..5 LOOP
           IF ln_dim_no IS NULL AND var_dims(i) IS NOT NULL THEN
              select count(*) into ln_cnt
              from calc_object_type
              where object_id = p_object_id
              and calc_obj_type_category='PREDEFINED'
              and data_type = 'DATE'
              and object_type_code = var_dims(i);
              IF ln_cnt>0 THEN
                 ln_dim_no := i;
                 var_dims(i) := NULL;
              END IF;
           END IF;
        END LOOP;
     END IF;

     lv2_mapping_type := NULL;
     IF ln_dim_no IS NOT NULL THEN
        lv2_mapping_type := 'DIMENSION';
     END IF;

     INSERT INTO calc_var_key_read_mapping(object_id,calc_var_signature,calc_dataset,cls_name,sql_syntax,calc_dim_mapping_code,mapping_detail,dim_no,created_by)
     VALUES (p_object_id, p_calc_var_signature, p_calc_dataset, p_class_name, cur_var.attribute_name,lv2_mapping_type,ln_dim_no,ln_dim_no,lv2_user_id);

   END LOOP;
END addVariableAttrMappings;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : addVarWriteAttrMappings
-- Description    : Insert key attribute mappings for a variable write mapping.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class, class_attribute, class_relation, calc_object_type, calc_var_key_write_mapping
--
-- Using functions: getVariableDimensions, getEstimatedObjectType
--                  ec_class_attr_db_mapping, ec_class_rel_db_mapping
--
-- Configuration
-- required       :
--
-- Behaviour      : Only adds mappings if the operation is 'create' (row inserted from screen).
--                  This procedure is used on insert of new variable write mappings to create
--                  a default class key mapping. The procedure tries to determine the correct mapping
--                  for each key by comparing an estimated object type (based on attribute name,
--                  data type and class relations) to the dimensions on the variable.
--                  Keys that the procedure is not able to determine a default mapping for will
--                  still be created but with a NULL mapping.
--                  The class attributes PRODUCTION_DAY and SUMMERTIME get special handling since
--                  there is not a one to one relationship between class keys and variable dimensions
--                  for sub-daily data.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE addVarWriteAttrMappings(
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
)
--</EC-DOC>
IS
   lv_ref_obj_type       VARCHAR2(32);
   ln_dim_no             NUMBER;
   ln_cnt                NUMBER;
   var_dims              CalcVarDimensions;
   lv2_mapping_type      VARCHAR2(32);
   lv2_user_id           VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

   CURSOR c_variable_attribute_key (cp_class_name VARCHAR2) IS
      SELECT ca.class_name,
             ca.attribute_name,
             EcDp_ClassMeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) as sort_order,
             ca.data_type,
             DECODE(ca.attribute_name,'OBJECT_ID', DECODE(c.class_type,'OBJECT',c.class_name,'INTERFACE',c.class_name,'DATA',c.owner_class_name,NULL), 'COMPONENT_NO', 'HYDROCARBON_COMPONENT', NULL) as ref_class
      FROM class_attribute_cnfg ca, class_cnfg c
      WHERE ca.class_name = cp_class_name
      AND c.class_name = ca.class_name
      AND (is_key = 'Y' OR attribute_name IN ('PRODUCTION_DAY'))
      AND attribute_name not in ('SUMMER_TIME')
      UNION ALL
      SELECT cr.to_class_name as class_name,
             cr.role_name || '_ID' as attribute_name,
             EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) as sort_order,
             'STRING' as data_type,
             cr.from_class_name as ref_class
      FROM class_relation_cnfg cr
      WHERE to_class_name = cp_class_name
      AND is_key = 'Y'
      ORDER BY sort_order;
BEGIN
   IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
   END IF;

   var_dims := getVariableDimensions(p_object_id, p_calc_var_signature);
   FOR cur_var IN c_variable_attribute_key(p_class_name) LOOP
     -- Try to find default mapping for this attribute based on data / object type
     -- 1) Owner and Object relation: Try to find corresponding Object Type
     -- 2) Date: Look for corresponding dimension(s) of type PREDEFINED DATE
     ln_dim_no := NULL;

     -- First try to see if this is a DB object type, and map that to a dimension
     lv_ref_obj_type := getEstimatedObjectType(p_object_id, cur_var.ref_class);
     IF lv_ref_obj_type IS NOT NULL THEN
        -- Try to find a dimension of the same object type
        FOR i IN 1..5 LOOP
           IF ln_dim_no IS NULL AND var_dims(i) = lv_ref_obj_type THEN
              ln_dim_no := i;
              var_dims(i) := NULL;
           END IF;
        END LOOP;
     END IF;

     -- Then try to see if this is a DATE type dimension, and map that
     IF ln_dim_no IS NULL AND cur_var.data_type = 'DATE' THEN
        FOR i IN 1..5 LOOP
           IF ln_dim_no IS NULL AND var_dims(i) IS NOT NULL THEN
              select count(*) into ln_cnt
              from calc_object_type
              where object_id = p_object_id
              and calc_obj_type_category='PREDEFINED'
              and data_type = 'DATE'
              and object_type_code = var_dims(i);
              IF ln_cnt>0 THEN
                 ln_dim_no := i;
                 var_dims(i) := NULL;
              END IF;
           END IF;
        END LOOP;
     END IF;

     lv2_mapping_type := NULL;
     IF ln_dim_no IS NOT NULL THEN
        lv2_mapping_type := 'DIMENSION';
     END IF;

     INSERT INTO calc_var_key_write_mapping(object_id,calc_var_signature,calc_dataset,cls_name,sql_syntax,calc_dim_mapping_code,mapping_detail,dim_no,created_by)
     VALUES (p_object_id, p_calc_var_signature, p_calc_dataset, p_class_name, cur_var.attribute_name,lv2_mapping_type,ln_dim_no,ln_dim_no,lv2_user_id);

   END LOOP;
END addVarWriteAttrMappings;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEstimatedObjectType
-- Description    : Tries to guess the object type for a given class in the context of a given calculation context.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_object_type, class_dependency
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Scans the object types defined for the given calculation context to try and find one
--                  that maps the given class.
--                  The guess is not 100% accurate due to interface classes.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getEstimatedObjectType(
   p_object_id VARCHAR2,
   p_class_name VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
  ln_cnt        NUMBER;
  lv2_obj_type  VARCHAR2(32);
BEGIN
  -- First try and see if we can get a direct hit
  select count(*), max(object_type_code) INTO ln_cnt, lv2_obj_type
  from calc_object_type
  where object_id = p_object_id
  and calc_obj_type_category = 'DB'
  and object_type_code = p_class_name;

  IF ln_cnt = 1 AND lv2_obj_type IS NOT NULL THEN
     RETURN lv2_obj_type;
  END IF;

  -- Then scan interfaces...
  select count(*), max(object_type_code) INTO ln_cnt, lv2_obj_type
  from calc_object_type
  where object_id = p_object_id
  and calc_obj_type_category = 'DB'
  and object_type_code in (
      select parent_class
      from class_dependency_cnfg cd
      where cd.child_class = p_class_name
      and cd.dependency_type = 'IMPLEMENTS'
  );

  IF ln_cnt = 1 AND lv2_obj_type IS NOT NULL THEN
     RETURN lv2_obj_type;
  END IF;

  RETURN NULL;
END getEstimatedObjectType;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getVariableSignature
-- Description    : Creates a variable signature
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns a variable signature on the form name[dim1_type, dim2_type, ...].
--                  Dimension types that are blank are skipped.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getVariableSignature (
   p_var_name	      VARCHAR2,
   p_dim_obj_type1  VARCHAR2,
   p_dim_obj_type2  VARCHAR2,
   p_dim_obj_type3  VARCHAR2,
   p_dim_obj_type4  VARCHAR2,
   p_dim_obj_type5  VARCHAR2
)
RETURN CALC_VARIABLE.CALC_VAR_SIGNATURE%TYPE
--</EC-DOC>
IS
   lv_dimensions       CALC_VARIABLE.CALC_VAR_SIGNATURE%TYPE;
BEGIN
   lv_dimensions := '';
   IF p_dim_obj_type1 IS NOT NULL THEN
      lv_dimensions := lv_dimensions || p_dim_obj_type1;
   END IF;
   IF p_dim_obj_type2 IS NOT NULL THEN
      lv_dimensions := lv_dimensions || ',' || p_dim_obj_type2;
   END IF;
   IF p_dim_obj_type3 IS NOT NULL THEN
      lv_dimensions := lv_dimensions || ',' || p_dim_obj_type3;
   END IF;
   IF p_dim_obj_type4 IS NOT NULL THEN
      lv_dimensions := lv_dimensions || ',' || p_dim_obj_type4;
   END IF;
   IF p_dim_obj_type5 IS NOT NULL THEN
      lv_dimensions := lv_dimensions || ',' || p_dim_obj_type5;
   END IF;
   IF Length(lv_dimensions)>0 THEN
      lv_dimensions := '[' || lv_dimensions || ']';
   END IF;
   RETURN p_var_name || lv_dimensions;
END getVariableSignature;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteVariable
-- Description    : Deletes a given variable including all read and write mappings.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable
--
-- Using functions: deleteVarMappings
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteVariable(
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2
)
--</EC-DOC>
IS
BEGIN
   deleteVarMappings(p_object_id, p_calc_var_signature);
   DELETE calc_variable WHERE calc_var_signature = p_calc_var_signature AND object_id = p_object_id;
END deleteVariable;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteVarMappings
-- Description    : Deletes all read and write mappings for a given variable.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_var_key_read_mapping, calc_var_key_write_mapping,
--                  calc_var_read_mapping, calc_var_write_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteVarMappings(p_object_id VARCHAR2, p_calc_var_signature VARCHAR2)
--</EC-DOC>
IS
  CURSOR c_calc_var_read_mapping IS
    SELECT *
    FROM   calc_var_read_mapping
    WHERE  object_id = p_object_id
    AND    calc_var_signature = p_calc_var_signature;

  CURSOR c_calc_var_write_mapping IS
    SELECT *
    FROM   calc_var_write_mapping
    WHERE  object_id = p_object_id
    AND    calc_var_signature = p_calc_var_signature;

BEGIN
  FOR cur IN c_calc_var_read_mapping LOOP
    deleteVarKeyDBMappingRead(cur.object_id, cur.calc_var_signature, cur.calc_dataset, cur.cls_name);
  END LOOP;
  DELETE calc_var_read_mapping where calc_var_signature = p_calc_var_signature and object_id = p_object_id;

  FOR cur IN c_calc_var_write_mapping LOOP
    deleteVarKeyDBMappingWrite(cur.object_id, cur.calc_var_signature, cur.calc_dataset, cur.cls_name);
  END LOOP;
  DELETE calc_var_write_mapping where calc_var_signature = p_calc_var_signature and object_id = p_object_id;
END deleteVarMappings;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteVarKeyDBMappingRead
-- Description    : Deletes class key mappings for a variable read mapping.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_var_key_read_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteVarKeyDBMappingRead(p_object_id VARCHAR2, p_calc_var_signature VARCHAR2, p_calc_dataset VARCHAR2, p_cls_name VARCHAR2)
--</EC-DOC>
IS
BEGIN
    DELETE calc_var_key_read_mapping where calc_var_signature = p_calc_var_signature and calc_dataset = p_calc_dataset and object_id = p_object_id and cls_name = p_cls_name;
END deleteVarKeyDBMappingRead;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteVarKeyDBMappingWrite
-- Description    : Deletes class key mappings for a variable write mapping.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_var_key_write_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteVarKeyDBMappingWrite(p_object_id VARCHAR2, p_calc_var_signature VARCHAR2, p_calc_dataset VARCHAR2, p_cls_name VARCHAR2)
--</EC-DOC>
IS
BEGIN
    DELETE calc_var_key_write_mapping where calc_var_signature = p_calc_var_signature and calc_dataset = p_calc_dataset and object_id = p_object_id and cls_name = p_cls_name;
END deleteVarKeyDBMappingWrite;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : validateVarMapping
-- Description    : Validates that a set of variable dimensions is valid.
--
-- Preconditions  :
-- Postconditions : Raises an exception if errors are found.
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Checks that the list of dimensions is without "holes", i.e.
--                  that it is not allowed to map a dimension unless all "lower" dimensions
--                  are also mapped.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE validateVarMapping(
   p_dim_obj_type1  VARCHAR2,
   p_dim_obj_type2  VARCHAR2,
   p_dim_obj_type3  VARCHAR2,
   p_dim_obj_type4  VARCHAR2,
   p_dim_obj_type5  VARCHAR2
)
--</EC-DOC>
IS
    lv_message VARCHAR2(4000);
BEGIN
  lv_message := null;
  IF p_dim_obj_type5 is not null AND p_dim_obj_type4 is null THEN
     lv_message := 'Dimension 5 is selected. Please select Dimension 2, Dimension 3 and Dimension 4';
  ELSIF p_dim_obj_type4 is not null AND p_dim_obj_type3 is null THEN
     lv_message := 'Dimension 4 is selected. Please select Dimension 2 and Dimension 3';
  ELSIF p_dim_obj_type3 is not null AND p_dim_obj_type2 is null THEN
     lv_message := 'Dimension 3 is selected. Please select Dimension 2';
  ELSIF p_dim_obj_type2 is not null AND p_dim_obj_type1 is null THEN
     lv_message := 'Dimension 2 is selected. Please select Dimension 1';
  END IF;

  IF lv_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20000, lv_message);
  END IF;

END validateVarMapping;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteObjectTypeAttributes
-- Description    : Deletes all attributes and attribute DB mappings for the given DB object type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_obj_attr_db_mapping, calc_object_attribute
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteObjectTypeAttributes(p_object_id VARCHAR2, p_object_type_code VARCHAR2)
--</EC-DOC>
IS
BEGIN
  DELETE calc_obj_attr_db_mapping where object_id = p_object_id and object_type_code = p_object_type_code;
  DELETE calc_object_attribute where object_id = p_object_id and object_type_code = p_object_type_code;
END deleteObjectTypeAttributes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteObjectTypeAttrDBMapping
-- Description    : Deletes attribute DB mappings for the given object type attribute.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_obj_attr_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteObjectTypeAttrDBMapping(p_object_id VARCHAR2, p_object_type_code VARCHAR2, p_name VARCHAR2)
--</EC-DOC>
IS
BEGIN
  DELETE calc_obj_attr_db_mapping where object_id = p_object_id and object_type_code = p_object_type_code and name = p_name;
END deleteObjectTypeAttrDBMapping;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteObjectTypeFilters
-- Description    : Deletes all filters for the given DB object type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_object_filter, calc_object_attribute
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteObjectTypeFilters(p_object_id VARCHAR2, p_object_type_code VARCHAR2)
--</EC-DOC>
IS
BEGIN
  DELETE calc_object_filter where object_id = p_object_id and object_type_code = p_object_type_code;
END deleteObjectTypeFilters;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getClassAttributeLabel
-- Description    : Gets the label of a class attribute or relation, based on column name in the view.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class_rel_presentation
--
-- Using functions: ec_class_attr_presentation
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the label for a given column in the view, either an attribute
--                  or a relation ID or code.
--                  For attributes, the parameter should be the attribute name and the function returns
--                  the attribute label.
--                  For relations, the parameter should be either role name plus _ID or role name plus _CODE.
--                  The function returns the label plus ' (ID)' or the label plus ' (Code)'.
--                  In addition, the function recognizes the special "attribute" CLASS_NAME and
--                  assigns it the label "Class Name" if no label is found.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getClassAttributeLabel(
   p_class_name	    VARCHAR2,
   p_attr_name      VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_retval VARCHAR2(100);
BEGIN
   select EcDp_ClassMeta_Cnfg.getLabel(p_class_name, p_attr_name) into lv2_retval from dual;

   IF (lv2_retval IS null) THEN
     select max(EcDp_ClassMeta_Cnfg.getLabel(cr.from_class_name, cr.to_class_name, cr.role_name)||' (ID)') into lv2_retval
     from class_relation_cnfg cr
     where cr.to_class_name = p_class_name and substr(p_attr_name,1,instr(p_attr_name,'_ID') -1) = cr.role_name;
   END IF;

   IF (lv2_retval IS null) THEN
     select max(EcDp_ClassMeta_Cnfg.getLabel(cr.from_class_name, cr.to_class_name, cr.role_name)||' (Code)') into lv2_retval
     from class_relation_cnfg cr
     where cr.to_class_name = p_class_name and substr(p_attr_name,1,instr(p_attr_name,'_CODE') -1) = cr.role_name;
   END IF;

   IF (lv2_retval IS null) AND (p_attr_name = 'CLASS_NAME') THEN
     lv2_retval := 'Class Name';
   END IF;

   RETURN lv2_retval;
END getClassAttributeLabel;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getClassAttributeSort
-- Description    : Gets the sort order for a class attribute or relation, based on column name in the view.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class_rel_db_mapping
--
-- Using functions: ec_class_attr_db_mapping
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the (db) sort order for a given column in the view, either an attribute
--                  or a relation ID or code.
--                  For attributes, the parameter should be the attribute name and the function returns
--                  the DB sort order.
--                  For relations, the parameter should be either role name plus _ID or role name plus _CODE.
--                  The function returns the relation sort order.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getClassAttributeSort(
   p_class_name	    VARCHAR2,
   p_attr_name      VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
 ln_retval NUMBER;
 BEGIN
   select EcDp_ClassMeta_Cnfg.getDbSortOrder(p_class_name, p_attr_name) into ln_retval from dual;

   IF (ln_retval IS null) THEN
     select max(EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name)) into ln_retval
     from class_relation_cnfg cr
     where cr.to_class_name = p_class_name and substr(p_attr_name,1,instr(p_attr_name,'_ID') -1) = cr.role_name;
   END IF;

   IF (ln_retval IS null) THEN
     select max(EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name)) into ln_retval
     from class_relation_cnfg cr
     where cr.to_class_name = p_class_name and substr(p_attr_name,1,instr(p_attr_name,'_CODE') -1) = cr.role_name;
   END IF;

   RETURN ln_retval;
END getClassAttributeSort;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getCalcSetConditionDescription
-- Description    : Generates a textual description from the given calc_set_condition columns.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getCalcSetConditionDescription(p_op1_sql_syntax VARCHAR2, p_operator VARCHAR2, p_op2_set_cond_type VARCHAR2, p_op2_set_cond_value VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
  IF p_op2_set_cond_type IN ('PARAMETER','ITERATOR','SET') THEN
    RETURN p_op1_sql_syntax || ' ' ||ec_prosty_codes.code_text(p_operator, 'CALC_SET_FILTER_OPERATOR') || ' (' || ec_prosty_codes.code_text(p_op2_set_cond_type, 'CALC_SET_FILTER_OPERAND_TYPE') ||') "' || p_op2_set_cond_value || '"';
  END IF;
  IF p_op2_set_cond_type='CONSTANT' THEN
    RETURN p_op1_sql_syntax || ' ' ||ec_prosty_codes.code_text(p_operator, 'CALC_SET_FILTER_OPERATOR') || ' "' || p_op2_set_cond_value || '"';
  END IF;

  RETURN Nvl(p_op1_sql_syntax, '<blank>') || ' ' || Nvl(ec_prosty_codes.code_text(p_operator, 'CALC_SET_FILTER_OPERATOR'), Nvl(p_operator, '<blank>')) || ' ' ||  ' (' || Nvl(p_op2_set_cond_type, '<blank>') || ') '  || Nvl(p_op2_set_cond_value, '<blank>');
END getCalcSetConditionDescription;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getCalcSetConditionDescrFromPk
-- Description    : Generates a textual description from the calc_set_condition identified by the
--                  input parameters.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getCalcSetConditionDescrFromPk(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2, p_seq_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
  lr_row calc_set_condition%ROWTYPE := Ec_Calc_Set_Condition.row_by_pk(p_object_id, p_daytime, p_calc_set_name, p_seq_no);
BEGIN
  RETURN getCalcSetConditionDescription(lr_row.object_id, lr_row.daytime, lr_row.calc_set_name, lr_row.seq_no);
END getCalcSetConditionDescrFromPk;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getSetDescription
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_set_condition, calc_set_combination,
--
-- Using functions: getCalcObjectTypeLabel, ec_prosty_codes.code_text
--
-- Configuration
-- required       : Relevant EC codes must be configured and their text must be formulated to fit
--                  with the way the description is built.
--                  (CALC_SET_FILTER_OPERATOR, CALC_SET_FILTER_OPERAND_TYPE, CALC_SET_ORDER_TYPE)
--
-- Behaviour      : Builds a textual description of a set based on the set configuration and any
--                  conditions or combination records.
--                  The description will include the text for some EC codes, so if these texts are changed
--                  then the descriptions would be affected.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getSetDescription(
   p_calc_context_id   VARCHAR2,
   p_object_id         VARCHAR2,
   p_set_name          VARCHAR2,
   p_object_type_code  VARCHAR2,
   p_set_type          VARCHAR2,
   p_set_op_name       VARCHAR2,
   p_order_dir         VARCHAR2,
   p_order_by          VARCHAR2,
   p_desc_override     VARCHAR2,
   p_operator          VARCHAR2,
   p_daytime           date
)
RETURN VARCHAR2
--</EC-DOC>
IS
 CURSOR c_calc_set_condition (cp_object_id VARCHAR2, cp_daytime DATE, cp_set_name VARCHAR2) IS
  SELECT sc.op1_sql_syntax, sc.operator, sc.op2_set_cond_type, sc.op2_set_cond_value, sc.calc_set_name, getCalcSetConditionDescription(sc.op1_sql_syntax, sc.operator, sc.op2_set_cond_type, sc.op2_set_cond_value) AS description
  FROM calc_set_condition sc
  WHERE sc.object_id = cp_object_id
  AND sc.daytime = cp_daytime
  AND sc.calc_set_name = cp_set_name
  ORDER BY sc.seq_no;

 CURSOR c_set_combination (cp_object_id VARCHAR2, cp_daytime DATE, cp_set_name VARCHAR2) IS
  SELECT sc.seq_no, sc.op_calc_set_name
  FROM calc_set_combination sc
  WHERE sc.object_id = cp_object_id
  AND sc.daytime = cp_daytime
  AND sc.calc_set_name = cp_set_name
  ORDER BY sc.seq_no;

 lv2_retval  VARCHAR2(4000);
 ln_num_rows INTEGER := 0;
 ln_row_num  INTEGER := 0;
 lt_calc_ver CALCULATION_VERSION%ROWTYPE := ec_calculation_version.row_by_pk(p_object_id,p_daytime,'<=');

 BEGIN
    -- Things that are unique to each type
    IF (p_set_type = 'DB_OBJECT_TYPE') THEN
       lv2_retval := 'Objects of type ' ||  getCalcObjectTypeLabel(p_calc_context_id, p_object_type_code);
    ELSIF (p_set_type = 'COMBINED_SET') THEN
      lv2_retval := 'Objects in set ' || p_set_op_name;
      IF p_operator = 'UNION' THEN
         lv2_retval := lv2_retval || ', ';
      ELSIF p_operator = 'MINUSUNION' THEN
         lv2_retval := lv2_retval || ' but not in ';
      ELSIF p_operator = 'INTERSECT' THEN
         lv2_retval := lv2_retval || ' that are also in ';
      END IF;
      FOR cur_set_combination IN c_set_combination(lt_calc_ver.object_id,lt_calc_ver.daytime,p_set_name) LOOP
          ln_num_rows := ln_num_rows + 1;
      END LOOP;
      FOR cur_set_combination IN c_set_combination(lt_calc_ver.object_id,lt_calc_ver.daytime,p_set_name) LOOP
          lv2_retval := lv2_retval || cur_set_combination.op_calc_set_name;
          IF p_operator IN ('UNION', 'MINUSUNION') AND ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' or ';
          ELSIF ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' and ';
          ELSIF ln_row_num<(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ', ';
          END IF;
          ln_row_num := ln_row_num + 1;
      END LOOP;
    ELSIF (p_set_type = 'FILTERED_SET') THEN
       lv2_retval := 'All ' || p_set_op_name;
    END IF;

   -- Filtering (DB Objects and Filtered)
   IF (p_set_type IN ('DB_OBJECT_TYPE', 'FILTERED_SET')) AND p_operator IS NOT NULL THEN
      lv2_retval := lv2_retval || ' where ';
      FOR cur_set_cons IN c_calc_set_condition(lt_calc_ver.object_id,lt_calc_ver.daytime,p_set_name) LOOP
          ln_num_rows := ln_num_rows + 1;
      END LOOP;
      FOR cur_set_cons IN c_calc_set_condition(lt_calc_ver.object_id,lt_calc_ver.daytime,p_set_name) LOOP
          lv2_retval := lv2_retval || cur_set_cons.description;
          IF p_operator = 'ALL' AND ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' and ';
          ELSIF p_operator = 'ALL' AND ln_row_num<(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ', ';
          ELSIF p_operator = 'ONE' AND ln_row_num<=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' or ';
          END IF;
          ln_row_num := ln_row_num + 1;
      END LOOP;
    END IF;

    -- Sorting (all types)
    IF (p_order_dir IS NOT NULL) THEN
       lv2_retval := lv2_retval || ' sorted ' || ec_prosty_codes.code_text(p_order_dir, 'CALC_SET_ORDER_TYPE')  || ' by ' || p_order_by;
    END IF;

   RETURN lv2_retval;
END getSetDescription;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : insertStandardAttributes
-- Description    : Insert the mandatory Key object attribute, and the key db mapping (if possible).
--                  Also inserts the Code and Name attributes and corresponding db mappings
--                  for OBJECT and INTERFACE classes, and the special ClassName attribute for
--                  INTERFACE classes.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_obj_attr_db_mapping, calc_object_attribute, class, class_attribute
--
-- Using functions: ec_class_attr_db_mapping.db_sql_syntax
--
-- Configuration
-- required       :
--
-- Behaviour      : Only adds attributes if the operation is 'create' (row inserted from screen).
--                  Tries to detect the db mapping for the Key attribute from the class key.
--                  For Object and Interface classes the mapping is assumed to be OBJECT_ID.
--                  For all other classes the mapping is set up only if the class has a single key attribute.
--                  Code and name are only added if the CODE and NAME class attributes exists.
--                  ClassName is only added for INTERFACE classes.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE insertStandardAttributes (
   p_operation                      VARCHAR2,
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
)
--</EC-DOC>
IS
  ln_num_keys   INTEGER;
  lv_class_type VARCHAR2(32);
  ln_code_exist INTEGER;
  ln_name_exist INTEGER;
  lv_key_attr   VARCHAR2(32) := NULL;
  lv2_user_id   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

BEGIN
  IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
  END IF;
  --
  -- Key
  --
  -- Insert the attribute itself
  INSERT INTO calc_object_attribute(object_id,object_type_code,name,value_object_type_code,calc_attr_level_code,created_by)
  VALUES (p_object_id, p_object_type_code, 'Key', p_object_type_code, 'MAIN',lv2_user_id);
  -- Try to find the DB mapping from the class
  SELECT c.class_type INTO lv_class_type FROM class_cnfg c WHERE c.class_name = p_object_type_code;
  IF lv_class_type IN ('OBJECT','INTERFACE') THEN
    lv_key_attr := 'OBJECT_ID';
  ELSE
    SELECT COUNT(*) INTO ln_num_keys FROM class_attribute_cnfg a WHERE a.class_name = p_object_type_code AND a.is_key='Y';
    IF ln_num_keys = 1 THEN
      SELECT a.attribute_name INTO lv_key_attr FROM class_attribute_cnfg a WHERE a.class_name = p_object_type_code AND a.is_key='Y';
    END IF;
  END IF;

  INSERT INTO calc_obj_attr_db_mapping(object_id,object_type_code,name,impl_class_name,sql_syntax,created_by)
  VALUES (p_object_id, p_object_type_code, 'Key', p_object_type_code, lv_key_attr,lv2_user_id);

  --
  -- Code
  --
  SELECT COUNT(*) INTO ln_code_exist FROM class_attribute_cnfg WHERE class_name = p_object_type_code AND attribute_name = 'CODE';
  IF (lv_class_type IN ('OBJECT','INTERFACE')) AND (ln_code_exist > 0) AND (NVL(EcDp_ClassMeta_Cnfg.isDisabled(p_object_type_code,'CODE'),'N')<>'Y') THEN
    INSERT INTO calc_object_attribute(object_id,object_type_code,name,value_object_type_code,calc_attr_level_code,created_by)
    VALUES (p_object_id, p_object_type_code, 'Code', NULL, 'MAIN',lv2_user_id);
    INSERT INTO calc_obj_attr_db_mapping(object_id,object_type_code,name,impl_class_name,sql_syntax,created_by)
    VALUES (p_object_id, p_object_type_code, 'Code', p_object_type_code, 'CODE',lv2_user_id);
  END IF;
  --
  -- Name
  --
  SELECT COUNT(*) INTO ln_name_exist FROM class_attribute_cnfg WHERE class_name = p_object_type_code AND attribute_name = 'NAME';
  IF (lv_class_type IN ('OBJECT','INTERFACE')) AND (ln_name_exist > 0) AND(NVL(EcDp_ClassMeta_Cnfg.isDisabled(p_object_type_code,'NAME'),'N')<>'Y') THEN
    INSERT INTO calc_object_attribute(object_id,object_type_code,name,value_object_type_code,calc_attr_level_code,created_by)
    VALUES (p_object_id, p_object_type_code, 'Name', NULL, 'MAIN',lv2_user_id);
    INSERT INTO calc_obj_attr_db_mapping(object_id,object_type_code,name,impl_class_name,sql_syntax,created_by)
    VALUES (p_object_id, p_object_type_code, 'Name', p_object_type_code, 'NAME',lv2_user_id);
  END IF;
  --
  -- ClassName
  --
  IF (lv_class_type IN ('INTERFACE')) THEN
    INSERT INTO calc_object_attribute(object_id,object_type_code,name,value_object_type_code,calc_attr_level_code,created_by)
    VALUES (p_object_id, p_object_type_code, 'ClassName', NULL, 'MAIN',lv2_user_id);
    INSERT INTO calc_obj_attr_db_mapping(object_id,object_type_code,name,impl_class_name,sql_syntax,created_by)
    VALUES (p_object_id, p_object_type_code, 'ClassName', p_object_type_code, 'CLASS_NAME',lv2_user_id);
  END IF;
END insertStandardAttributes;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : insertAttributeDBMapping
-- Description    : Insert database mapping for a newly created attribute (if possible).
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_obj_attr_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Only adds db mapping if the operation is 'create' (row inserted from screen).
--                  For a MAIN level attribute, the implementing class is pre-filled to the object type.
--                  Otherwise, no mapping is created since the implementing class is unknown and part of PK.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE insertAttributeDBMapping (
   p_operation                      VARCHAR2,
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2,
   p_attr_name                      VARCHAR2,
   p_attr_level_code                VARCHAR2
)
--</EC-DOC>
IS
  lv2_user_id VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
BEGIN
  IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
  END IF;
  IF p_attr_level_code = 'MAIN' THEN
    INSERT INTO calc_obj_attr_db_mapping(object_id, object_type_code, impl_class_name, name,created_by)
    VALUES(p_object_id, p_object_type_code, p_object_type_code, p_attr_name,lv2_user_id);
  END IF;
END insertAttributeDBMapping;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getMappingDetail
-- Description    : Returns the textual description of a variable class key mapping.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : v_calc_var_dims, v_calc_context_parameter, calc_variable
--
-- Using functions: getCalcObjectTypeLabel, getClassAttributeLabel
--
-- Configuration
-- required       :
--
-- Behaviour      : How the description is found depends on the mapping type:
--                  * Dimension mappings return the Object Type for the selected dimension
--                  * Parameter mappings return the description as found in v_calc_context_parameter
--                  * Alias mappings return the label for the alias class attribute/relation
--
-----------------------------------------------------------------------------------------------------
FUNCTION getMappingDetail (
   p_calc_context_id              VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dim_mapping_code        VARCHAR2,
   p_calc_mapping_detail          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(100);
BEGIN
  IF (p_calc_dim_mapping_code = 'DIMENSION') THEN
    select getCalcObjectTypeLabel(object_id, decode(p_calc_mapping_detail,'1',dim1_object_type_code,'2',dim2_object_type_code,'3',dim3_object_type_code,'4',dim4_object_type_code,'5',dim5_object_type_code,NULL)) into lv2_retval
    from calc_variable cv
    where cv.OBJECT_ID = p_calc_context_id
    and cv.CALC_VAR_SIGNATURE = p_calc_var_signature;
  ELSIF (p_calc_dim_mapping_code = 'SCREEN_PARAMETER') THEN
    select description into lv2_retval
    from v_calc_context_parameter
    where object_id=p_calc_context_id
    and name=p_calc_mapping_detail;
  ELSIF (p_calc_dim_mapping_code = 'ALIAS') THEN
    select getClassAttributeLabel(cv.alias_class_name, p_calc_mapping_detail) into lv2_retval
    from calc_variable cv
    where cv.OBJECT_ID = p_calc_context_id
    and cv.CALC_VAR_SIGNATURE = p_calc_var_signature;
  END IF;

  return lv2_retval;
END getMappingDetail;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getCalcObjectTypeLabel
-- Description    : Returns the label for a given Object Type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_calc_object_type.row_by_pk, ecdp_classmeta_cnfg.getLabel
--
-- Configuration
-- required       :
--
-- Behaviour      : Tries to determine the label to use in the following order:
--                  1) If the object type has a label_override then that is used
--                  2) If the object type is a database object type, and the corresponding
--                     class has a label, then that is used
--                  3) If none of the above was found then the object type code is used
--
-----------------------------------------------------------------------------------------------------
FUNCTION getCalcObjectTypeLabel (
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   lr_obj_type   CALC_OBJECT_TYPE%ROWTYPE;
BEGIN
   lr_obj_type := ec_calc_object_type.row_by_pk(p_object_id, p_object_type_code);
   IF lr_obj_type.CALC_OBJ_TYPE_CATEGORY = 'DB' THEN
      RETURN NVL(lr_obj_type.label_override, NVL(EcDp_ClassMeta_Cnfg.getLabel(p_object_type_code), p_object_type_code));
   END IF;
   RETURN NVL(lr_obj_type.label_override, p_object_type_code);
END getCalcObjectTypeLabel;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setDefaultDataValidity
-- Description    : Updates a read mapping with a guess of the data validity for data in the given class.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class, class_attribute, calc_var_read_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Only updates the mapping if operation = 'create' (inserted from screen).
--                  Tries to autodetect the data validity from the attributes of the class.
--                  The period type, valid at/from and valid to attributes are detected from
--                  whether or not the class has a DAYTIME and/or END_DATE attribute.
--                  Sub-daily setup is detected from the whether or not the class has the
--                  PRODUCTION_DAY and SUMMERTIME attributes.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE setDefaultDataValidity (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
)
--</EC-DOC>
IS
   lv2_calc_date_handling          VARCHAR2(32);
   lv2_valid_from_attr_name        VARCHAR2(32);
   lv2_valid_to_attr_name          VARCHAR2(32);
   lv2_sub_daily_ind               VARCHAR2(1);
   lv2_prod_day_attr_name          VARCHAR2(32);
   lv2_summer_time_attr_name       VARCHAR2(32);
   lv2_user_id                     VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

  CURSOR c_date_props IS
    select
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='DAYTIME') has_daytime,
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='END_DATE') has_end_date,
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='SUMMER_TIME') has_summertime,
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='PRODUCTION_DAY') has_production_day
    from class_cnfg c
    where c.class_name = p_class_name;

BEGIN
  IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
  END IF;

  FOR dp IN c_date_props LOOP
    -- Date handling, valid from and valid to are detected as follows:
    -- 1) If the class has DAYTIME but not END_DATE then we assume FIXED_INTERVALS, DAYTIME, NULL
    -- 2) If the class has DAYTIME and END_DATE then we assume VARIABLE_PERIOD, DAYTIME, END_DATE
    -- Otherwise, assume NULL, NULL, NULL (not known)
    IF dp.has_daytime='Y' and dp.has_end_date='N' THEN
       lv2_calc_date_handling := 'FIXED_INTERVALS';
       lv2_valid_from_attr_name := 'DAYTIME';
       lv2_valid_to_attr_name := NULL;
    ELSIF dp.has_daytime='Y' and dp.has_end_date='Y' THEN
       lv2_calc_date_handling := 'VARIABLE_PERIOD';
       lv2_valid_from_attr_name := 'DAYTIME';
       lv2_valid_to_attr_name := 'END_DATE';
    ELSE
       lv2_calc_date_handling := NULL;
       lv2_valid_from_attr_name := NULL;
       lv2_valid_to_attr_name := NULL;
    END IF;
    -- Sub daily ind and day attribute are detected as follows
    -- 1) If the class has SUMMERTIME_FLAG and PRODUCTION_DAY, assume Y, PRODUCTION_DAY
    -- Otherwise, assume N, NULL (no subdaily)
    IF dp.has_summertime='Y' and dp.has_production_day='Y' THEN
       lv2_sub_daily_ind := 'Y';
       lv2_prod_day_attr_name := 'PRODUCTION_DAY';
       lv2_summer_time_attr_name := 'SUMMER_TIME';
    ELSE
       lv2_sub_daily_ind := 'N';
       lv2_prod_day_attr_name := NULL;
       lv2_summer_time_attr_name := null;
    END IF;
  END LOOP;

  UPDATE calc_var_read_mapping m
  SET m.calc_date_handling = lv2_calc_date_handling,
      m.valid_from_attr_name = lv2_valid_from_attr_name,
      m.valid_to_attr_name = lv2_valid_to_attr_name,
      m.sub_daily_ind = lv2_sub_daily_ind,
      m.prod_day_attr_name = lv2_prod_day_attr_name,
      m.summer_time_attr_name = lv2_summer_time_attr_name,
      m.last_updated_by = lv2_user_id
  WHERE m.object_id = p_object_id
  AND m.calc_var_signature = p_calc_var_signature
  AND m.calc_dataset = p_calc_dataset
  AND m.cls_name = p_class_name;
END setDefaultDataValidity;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setVarWriteDefaultDataValidity
-- Description    : Updates a write mapping with a guess of the data validity for data in the given class.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class, class_attribute, calc_var_write_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Only updates the mapping if operation = 'create' (inserted from screen).
--                  Tries to autodetect the data validity from the attributes of the class.
--                  Sub-daily setup is detected from the whether or not the class has the
--                  PRODUCTION_DAY and SUMMERTIME attributes.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE setVarWriteDefaultDataValidity (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
)
--</EC-DOC>
IS
   lv2_sub_daily_ind               VARCHAR2(1);
   lv2_prod_day_attr_name          VARCHAR2(32);
   lv2_summer_time_attr_name       VARCHAR2(32);
   lv2_user_id                     VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

  CURSOR c_date_props IS
    select
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='SUMMER_TIME') has_summertime,
      (select decode(count(*),0,'N','Y') from class_attribute_cnfg ca where ca.class_name=c.class_name and attribute_name='PRODUCTION_DAY') has_production_day
    from class_cnfg c
    where c.class_name = p_class_name;

BEGIN
  IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
  END IF;

  FOR dp IN c_date_props LOOP
    -- Sub daily ind and day attribute are detected as follows
    -- 1) If the class has SUMMERTIME_FLAG and PRODUCTION_DAY, assume Y, PRODUCTION_DAY
    -- Otherwise, assume N, NULL (no subdaily)
    IF dp.has_summertime='Y' and dp.has_production_day='Y' THEN
       lv2_sub_daily_ind := 'Y';
       lv2_prod_day_attr_name := 'PRODUCTION_DAY';
       lv2_summer_time_attr_name := 'SUMMER_TIME';
    ELSE
       lv2_sub_daily_ind := 'N';
       lv2_prod_day_attr_name := NULL;
       lv2_summer_time_attr_name := null;
    END IF;
  END LOOP;

  UPDATE calc_var_write_mapping m
  SET m.sub_daily_ind = lv2_sub_daily_ind,
      m.prod_day_attr_name = lv2_prod_day_attr_name,
      m.summer_time_attr_name = lv2_summer_time_attr_name,
      m.last_updated_by = lv2_user_id
  WHERE m.object_id = p_object_id
  AND m.calc_var_signature = p_calc_var_signature
  AND m.calc_dataset = p_calc_dataset
  AND m.cls_name = p_class_name;
END setVarWriteDefaultDataValidity;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getVariableDimensions
-- Description    : Returns the dimensions of a variable as a CalcVarDimensions array.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getVariableDimensions(
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2
)
RETURN CalcVarDimensions
--</EC-DOC>
IS
  lv2_dim1_code    VARCHAR2(32);
  lv2_dim2_code    VARCHAR2(32);
  lv2_dim3_code    VARCHAR2(32);
  lv2_dim4_code    VARCHAR2(32);
  lv2_dim5_code    VARCHAR2(32);
BEGIN
  SELECT dim1_object_type_code, dim2_object_type_code, dim3_object_type_code, dim4_object_type_code, dim5_object_type_code
  INTO lv2_dim1_code, lv2_dim2_code, lv2_dim3_code, lv2_dim4_code, lv2_dim5_code
  FROM calc_variable v
  WHERE v.object_id = p_object_id
  AND v.calc_var_signature = p_calc_var_signature;

  RETURN CalcVarDimensions(lv2_dim1_code, lv2_dim2_code, lv2_dim3_code, lv2_dim4_code, lv2_dim5_code);
END getVariableDimensions;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getVariableMappingsInd
-- Description    : Returns an indicator of mappings on a variable.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getVariableMappingsInd (
   p_calc_context_id              VARCHAR2,
   p_calc_var_signature           VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   ln_readmapping_count           INTEGER;
   ln_writemapping_count          INTEGER;
BEGIN
   -- Get # of read mappings
   SELECT COUNT(*)
   INTO ln_readmapping_count
   FROM calc_var_read_mapping
   WHERE object_id = p_calc_context_id
   AND calc_var_signature = p_calc_var_signature;
   -- Get # of write mappings
   SELECT COUNT(*)
   INTO ln_writemapping_count
   FROM calc_var_write_mapping
   WHERE object_id = p_calc_context_id
   AND calc_var_signature = p_calc_var_signature;
   -- Return mappings indication
   IF ln_readmapping_count > 0 AND ln_writemapping_count > 0 THEN
      RETURN 'Read/Write';
   ELSIF ln_readmapping_count > 0 THEN
      RETURN 'Read';
   ELSIF ln_writemapping_count > 0 THEN
      RETURN 'Write';
   ELSE
      RETURN NULL;
   END IF;
END getVariableMappingsInd;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getWriteDimAttributeName
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION getWriteDimAttributeName(
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2,
   p_dim_no                       NUMBER
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT cvr.sql_syntax into lv2_retval FROM calc_var_key_write_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'DIMENSION' and cvr.dim_no = p_dim_no;

  return lv2_retval;
END getWriteDimAttributeName;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getReadDimAttributeName
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION getReadDimAttributeName(
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2,
   p_dim_no                       NUMBER
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT cvr.sql_syntax into lv2_retval FROM calc_var_key_read_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'DIMENSION' and cvr.dim_no = p_dim_no;

  return lv2_retval;
END getReadDimAttributeName;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getQualifierReadParamName
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getQualifierReadParamName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT min(cvr.parameter_name) into lv2_retval FROM calc_var_key_read_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER';

  return lv2_retval;
END getQualifierReadParamName;


FUNCTION getQualifierWriteParamName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT min(cvr.parameter_name) into lv2_retval FROM calc_var_key_write_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER';

  return lv2_retval;
END getQualifierWriteParamName;


FUNCTION getQualifierReadAttributeName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT min(cvr.sql_syntax) into lv2_retval FROM calc_var_key_read_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER';

  return lv2_retval;
END getQualifierReadAttributeName;


FUNCTION getQualifierWriteAttributeName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT min(cvr.sql_syntax) into lv2_retval FROM calc_var_key_write_mapping cvr where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER';

  return lv2_retval;
END getQualifierWriteAttributeName;


FUNCTION getQualifierReadDataType (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  -- Use NVL to string in case the key is a relation...
  -- And use min(...) in case there are more than one (engine won't work with that setup, but at least it doesn't fail in the v_calc_variable_meta view)
  SELECT NVL(min(ca.data_type),'STRING') into lv2_retval FROM calc_var_key_read_mapping cvr, class_attribute_cnfg ca where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER'
  and ca.class_name = cvr.cls_name and ca.attribute_name = cvr.sql_syntax;

  return lv2_retval;
END getQualifierReadDataType;


FUNCTION getQualifierWriteDataType (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2
IS
  lv2_retval VARCHAR2(100);
BEGIN
  SELECT min(ca.data_type) into lv2_retval FROM calc_var_key_write_mapping cvr, class_attribute_cnfg ca where cvr.object_id = p_object_id and cvr.calc_var_signature = p_calc_var_signature
  and cvr.calc_dataset = p_calc_dataset and cvr.cls_name = p_cls_name and cvr.calc_dim_mapping_code = 'SCREEN_PARAMETER'
  and ca.class_name = cvr.cls_name and ca.attribute_name = cvr.sql_syntax;


  return lv2_retval;
END getQualifierWriteDataType;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : keyReadMappingsSupportedByOE
-- Description    : Returns 'Y' if the key mappings for the given variable read mapping are supported
--                  by the old engine.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION keyReadMappingsSupportedByOE(p_object_id VARCHAR2, p_calc_var_signature VARCHAR2, p_calc_dataset VARCHAR2, p_cls_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  ln_cnt NUMBER;
BEGIN
  --
  -- Count unsupported key mappings
  --
  SELECT count(*) INTO ln_cnt
  FROM   calc_var_key_read_mapping cvkm, calc_context ctx
  WHERE  ctx.object_id=p_object_id
  AND    cvkm.object_id=p_object_id
  AND    cvkm.calc_var_signature=p_calc_var_signature
  AND    cvkm.calc_dataset=p_calc_dataset
  AND    cvkm.cls_name=p_cls_name
  AND    (cvkm.calc_dim_mapping_code='CONSTANT' OR
          (cvkm.calc_dim_mapping_code='SCREEN_PARAMETER' AND cvkm.parameter_name!='forecast_id') OR
          (cvkm.calc_dim_mapping_code='SCREEN_PARAMETER' AND cvkm.parameter_name='forecast_id' AND ctx.object_code NOT IN ('EC_TRAN_FC','EC_TRAN_CP','EC_SALE_SD','EC_SALE_SA','EC_SALE_PR')));

  IF ln_cnt > 0 THEN
    RETURN 'N'; -- Unsupported mappings found
  END IF;

  --
  -- Count SCREEN_PARAMETER='forecast_id' for contexts that support it
  --
  SELECT count(*) INTO ln_cnt
  FROM   calc_var_key_read_mapping cvkm, calc_context ctx
  WHERE  ctx.object_id=p_object_id
  AND    cvkm.object_id=p_object_id
  AND    cvkm.calc_var_signature=p_calc_var_signature
  AND    cvkm.calc_dataset=p_calc_dataset
  AND    cvkm.cls_name=p_cls_name
  AND    cvkm.calc_dim_mapping_code='SCREEN_PARAMETER'
  AND    cvkm.parameter_name='forecast_id'
  AND    ctx.object_code IN ('EC_TRAN_FC','EC_TRAN_CP','EC_SALE_SD','EC_SALE_SA','EC_SALE_PR');

  IF ln_cnt > 1 THEN
    RETURN 'N'; -- We only support 0 or 1
  END IF;

  RETURN 'Y';
END keyReadMappingsSupportedByOE;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : keyWriteMappingsSupportedByOE
-- Description    : Returns 'Y' if the key mappings for the given variable write mapping are supported
--                  by the old engine.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION keyWriteMappingsSupportedByOE(p_object_id VARCHAR2, p_calc_var_signature VARCHAR2, p_calc_dataset VARCHAR2, p_cls_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  ln_cnt NUMBER;
BEGIN
  --
  -- Count unsupported key mappings
  --
  SELECT count(*) INTO ln_cnt
  FROM   calc_var_key_write_mapping cvkm, calc_context ctx
  WHERE  ctx.object_id=p_object_id
  AND    cvkm.object_id=p_object_id
  AND    cvkm.calc_var_signature=p_calc_var_signature
  AND    cvkm.calc_dataset=p_calc_dataset
  AND    cvkm.cls_name=p_cls_name
  AND    (cvkm.calc_dim_mapping_code='CONSTANT' OR
          (cvkm.calc_dim_mapping_code='SCREEN_PARAMETER' AND cvkm.parameter_name!='forecast_id') OR
          (cvkm.calc_dim_mapping_code='SCREEN_PARAMETER' AND cvkm.parameter_name='forecast_id' AND ctx.object_code NOT IN ('EC_TRAN_FC','EC_TRAN_CP','EC_SALE_SD','EC_SALE_SA','EC_SALE_PR')));

  IF ln_cnt > 0 THEN
    RETURN 'N'; -- Unsupported mappings found
  END IF;

  --
  -- Count SCREEN_PARAMETER='forecast_id' for contexts that support it
  --
  SELECT count(*) INTO ln_cnt
  FROM   calc_var_key_write_mapping cvkm, calc_context ctx
  WHERE  ctx.object_id=p_object_id
  AND    cvkm.object_id=p_object_id
  AND    cvkm.calc_var_signature=p_calc_var_signature
  AND    cvkm.calc_dataset=p_calc_dataset
  AND    cvkm.cls_name=p_cls_name
  AND    cvkm.calc_dim_mapping_code='SCREEN_PARAMETER'
  AND    cvkm.parameter_name='forecast_id'
  AND    ctx.object_code IN ('EC_TRAN_FC','EC_TRAN_CP','EC_SALE_SD','EC_SALE_SA','EC_SALE_PR');

  IF ln_cnt > 1 THEN
    RETURN 'N'; -- We only support 0 or 1
  END IF;

  RETURN 'Y';
END keyWriteMappingsSupportedByOE;

END;