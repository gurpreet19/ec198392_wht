CREATE OR REPLACE PACKAGE Ecdp_Calc_Mapping IS
/****************************************************************
** Package        :  Ecdp_Calc_Mapping, header part
**
** $Revision: 1.11 $
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

TYPE CalcVarDimensions IS VARRAY(5) OF VARCHAR2(32);

--

PROCEDURE copyVariable (
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_new_object_id       VARCHAR2,
   p_new_name            VARCHAR2
);

--

PROCEDURE addVariableAttrMappings (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
);

--

PROCEDURE addVarWriteAttrMappings (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
);

--

FUNCTION getVariableSignature (
   p_var_name	      VARCHAR2,
   p_dim_obj_type1  VARCHAR2,
   p_dim_obj_type2  VARCHAR2,
   p_dim_obj_type3  VARCHAR2,
   p_dim_obj_type4  VARCHAR2,
   p_dim_obj_type5  VARCHAR2
)
RETURN CALC_VARIABLE.CALC_VAR_SIGNATURE%TYPE;

PRAGMA RESTRICT_REFERENCES(getVariableSignature, WNDS, WNPS, RNPS);

--

PROCEDURE deleteVariable(
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2
);

--

PROCEDURE deleteVarMappings(
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2
);

--

PROCEDURE deleteVarKeyDBMappingRead (
   p_object_id             VARCHAR2,
   p_calc_var_signature    VARCHAR2,
   p_calc_dataset          VARCHAR2,
   p_cls_name              VARCHAR2
);

--

PROCEDURE deleteVarKeyDBMappingWrite (
   p_object_id             VARCHAR2,
   p_calc_var_signature    VARCHAR2,
   p_calc_dataset          VARCHAR2,
   p_cls_name              VARCHAR2
);

--


PROCEDURE validateVarMapping (
   p_dim_obj_type1  VARCHAR2,
   p_dim_obj_type2  VARCHAR2,
   p_dim_obj_type3  VARCHAR2,
   p_dim_obj_type4  VARCHAR2,
   p_dim_obj_type5  VARCHAR2
);

--

PROCEDURE deleteObjectTypeAttributes (
   p_object_id        VARCHAR2,
   p_object_type_code VARCHAR2
);

--

PROCEDURE deleteObjectTypeAttrDBMapping(
   p_object_id        VARCHAR2,
   p_object_type_code VARCHAR2,
   p_name VARCHAR2
);

--

PROCEDURE deleteObjectTypeFilters(
   p_object_id        VARCHAR2,
   p_object_type_code VARCHAR2
);

--

FUNCTION getClassAttributeLabel(
   p_class_name	    VARCHAR2,
   p_attr_name      VARCHAR2
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getClassAttributeLabel, WNDS, WNPS, RNPS);

--

FUNCTION getClassAttributeSort(
   p_class_name	    VARCHAR2,
   p_attr_name      VARCHAR2
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getClassAttributeSort, WNDS, WNPS, RNPS);

--

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
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getSetDescription, WNDS, WNPS, RNPS);

--

PROCEDURE insertStandardAttributes (
   p_operation                      VARCHAR2,
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
);

--

PROCEDURE insertAttributeDBMapping (
   p_operation                      VARCHAR2,
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2,
   p_attr_name                      VARCHAR2,
   p_attr_level_code                VARCHAR2
);

--

FUNCTION getMappingDetail (
   p_calc_context_id              VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dim_mapping_code        VARCHAR2,
   p_calc_mapping_detail          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getMappingDetail, WNDS, WNPS, RNPS);

--

FUNCTION getCalcObjectTypeLabel (
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getCalcObjectTypeLabel, WNDS, WNPS, RNPS);

--

PROCEDURE setDefaultDataValidity (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
);

--

PROCEDURE setVarWriteDefaultDataValidity (
   p_operation           VARCHAR2,
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2,
   p_calc_dataset        VARCHAR2,
   p_class_name          VARCHAR2
);

--

FUNCTION getEstimatedObjectType(
   p_object_id VARCHAR2,
   p_class_name VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getEstimatedObjectType, WNDS, WNPS, RNPS);

--

FUNCTION getVariableDimensions(
   p_object_id           VARCHAR2,
   p_calc_var_signature  VARCHAR2
)
RETURN CalcVarDimensions;

PRAGMA RESTRICT_REFERENCES(getVariableDimensions, WNDS, WNPS, RNPS);

--

FUNCTION getVariableMappingsInd (
   p_calc_context_id              VARCHAR2,
   p_calc_var_signature           VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getVariableMappingsInd, WNDS, WNPS, RNPS);

--

FUNCTION getWriteDimAttributeName(
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2,
   p_dim_no                       NUMBER
)
RETURN VARCHAR2;



FUNCTION getReadDimAttributeName(
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2,
   p_dim_no                       NUMBER
)
RETURN VARCHAR2;

FUNCTION getQualifierReadParamName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getQualifierWriteParamName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getQualifierReadAttributeName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getQualifierWriteAttributeName (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getQualifierReadDataType (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getQualifierWriteDataType (
   p_object_id                    VARCHAR2,
   p_calc_var_signature           VARCHAR2,
   p_calc_dataset                 VARCHAR2,
   p_cls_name                     VARCHAR2
)
RETURN VARCHAR2;

--

FUNCTION getCalcSetConditionDescription(
   p_op1_sql_syntax               VARCHAR2,
   p_operator                     VARCHAR2,
   p_op2_set_cond_type            VARCHAR2,
   p_op2_set_cond_value           VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getCalcSetConditionDescription, WNDS, WNPS, RNPS);

--

FUNCTION getCalcSetConditionDescrFromPk(
   p_object_id                    VARCHAR2,
   p_daytime                      DATE,
   p_calc_set_name                VARCHAR2,
   p_seq_no                       NUMBER)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getCalcSetConditionDescrFromPk, WNDS, WNPS, RNPS);

FUNCTION keyReadMappingsSupportedByOE(
  p_object_id          VARCHAR2,
  p_calc_var_signature VARCHAR2,
  p_calc_dataset       VARCHAR2,
  p_cls_name           VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(keyReadMappingsSupportedByOE, WNDS, WNPS, RNPS);

FUNCTION keyWriteMappingsSupportedByOE(
  p_object_id          VARCHAR2,
  p_calc_var_signature VARCHAR2,
  p_calc_dataset       VARCHAR2,
  p_cls_name           VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(keyWriteMappingsSupportedByOE, WNDS, WNPS, RNPS);

END;