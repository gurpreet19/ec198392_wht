
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.22 AM


CREATE or REPLACE PACKAGE RPDP_CALC_MAPPING
IS

   FUNCTION GETREADDIMATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2,
      P_DIM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION KEYREADMAPPINGSSUPPORTEDBYOE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCALCSETCONDITIONDESCRFROMPK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERWRITEPARAMNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETVARIABLEMAPPINGSIND(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETWRITEDIMATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2,
      P_DIM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERWRITEATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETVARIABLESIGNATURE(
      P_VAR_NAME IN VARCHAR2,
      P_DIM_OBJ_TYPE1 IN VARCHAR2,
      P_DIM_OBJ_TYPE2 IN VARCHAR2,
      P_DIM_OBJ_TYPE3 IN VARCHAR2,
      P_DIM_OBJ_TYPE4 IN VARCHAR2,
      P_DIM_OBJ_TYPE5 IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCALCSETCONDITIONDESCRIPTION(
      P_OP1_SQL_SYNTAX IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_OP2_SET_COND_TYPE IN VARCHAR2,
      P_OP2_SET_COND_VALUE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERREADPARAMNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERWRITEDATATYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCALCOBJECTTYPELABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETESTIMATEDOBJECTTYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEYWRITEMAPPINGSSUPPORTEDBYOE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCLASSATTRIBUTESORT(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETMAPPINGDETAIL(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DIM_MAPPING_CODE IN VARCHAR2,
      P_CALC_MAPPING_DETAIL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCLASSATTRIBUTELABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERREADATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETQUALIFIERREADDATATYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSETDESCRIPTION(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_SET_NAME IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2,
      P_SET_TYPE IN VARCHAR2,
      P_SET_OP_NAME IN VARCHAR2,
      P_ORDER_DIR IN VARCHAR2,
      P_ORDER_BY IN VARCHAR2,
      P_DESC_OVERRIDE IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPDP_CALC_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RPDP_CALC_MAPPING
IS

   FUNCTION GETREADDIMATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2,
      P_DIM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETREADDIMATTRIBUTENAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME,
         P_DIM_NO );
         RETURN ret_value;
   END GETREADDIMATTRIBUTENAME;
   FUNCTION KEYREADMAPPINGSSUPPORTEDBYOE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.KEYREADMAPPINGSSUPPORTEDBYOE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END KEYREADMAPPINGSSUPPORTEDBYOE;
   FUNCTION GETCALCSETCONDITIONDESCRFROMPK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETCALCSETCONDITIONDESCRFROMPK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END GETCALCSETCONDITIONDESCRFROMPK;
   FUNCTION GETQUALIFIERWRITEPARAMNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERWRITEPARAMNAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERWRITEPARAMNAME;
   FUNCTION GETVARIABLEMAPPINGSIND(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETVARIABLEMAPPINGSIND      (
         P_CALC_CONTEXT_ID,
         P_CALC_VAR_SIGNATURE );
         RETURN ret_value;
   END GETVARIABLEMAPPINGSIND;
   FUNCTION GETWRITEDIMATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2,
      P_DIM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETWRITEDIMATTRIBUTENAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME,
         P_DIM_NO );
         RETURN ret_value;
   END GETWRITEDIMATTRIBUTENAME;
   FUNCTION GETQUALIFIERWRITEATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERWRITEATTRIBUTENAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERWRITEATTRIBUTENAME;
   FUNCTION GETVARIABLESIGNATURE(
      P_VAR_NAME IN VARCHAR2,
      P_DIM_OBJ_TYPE1 IN VARCHAR2,
      P_DIM_OBJ_TYPE2 IN VARCHAR2,
      P_DIM_OBJ_TYPE3 IN VARCHAR2,
      P_DIM_OBJ_TYPE4 IN VARCHAR2,
      P_DIM_OBJ_TYPE5 IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETVARIABLESIGNATURE      (
         P_VAR_NAME,
         P_DIM_OBJ_TYPE1,
         P_DIM_OBJ_TYPE2,
         P_DIM_OBJ_TYPE3,
         P_DIM_OBJ_TYPE4,
         P_DIM_OBJ_TYPE5 );
         RETURN ret_value;
   END GETVARIABLESIGNATURE;
   FUNCTION GETCALCSETCONDITIONDESCRIPTION(
      P_OP1_SQL_SYNTAX IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_OP2_SET_COND_TYPE IN VARCHAR2,
      P_OP2_SET_COND_VALUE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETCALCSETCONDITIONDESCRIPTION      (
         P_OP1_SQL_SYNTAX,
         P_OPERATOR,
         P_OP2_SET_COND_TYPE,
         P_OP2_SET_COND_VALUE );
         RETURN ret_value;
   END GETCALCSETCONDITIONDESCRIPTION;
   FUNCTION GETQUALIFIERREADPARAMNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERREADPARAMNAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERREADPARAMNAME;
   FUNCTION GETQUALIFIERWRITEDATATYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERWRITEDATATYPE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERWRITEDATATYPE;
   FUNCTION GETCALCOBJECTTYPELABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETCALCOBJECTTYPELABEL      (
         P_OBJECT_ID,
         P_OBJECT_TYPE_CODE );
         RETURN ret_value;
   END GETCALCOBJECTTYPELABEL;
   FUNCTION GETESTIMATEDOBJECTTYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETESTIMATEDOBJECTTYPE      (
         P_OBJECT_ID,
         P_CLASS_NAME );
         RETURN ret_value;
   END GETESTIMATEDOBJECTTYPE;
   FUNCTION KEYWRITEMAPPINGSSUPPORTEDBYOE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.KEYWRITEMAPPINGSSUPPORTEDBYOE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END KEYWRITEMAPPINGSSUPPORTEDBYOE;
   FUNCTION GETCLASSATTRIBUTESORT(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETCLASSATTRIBUTESORT      (
         P_CLASS_NAME,
         P_ATTR_NAME );
         RETURN ret_value;
   END GETCLASSATTRIBUTESORT;
   FUNCTION GETMAPPINGDETAIL(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DIM_MAPPING_CODE IN VARCHAR2,
      P_CALC_MAPPING_DETAIL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETMAPPINGDETAIL      (
         P_CALC_CONTEXT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DIM_MAPPING_CODE,
         P_CALC_MAPPING_DETAIL );
         RETURN ret_value;
   END GETMAPPINGDETAIL;
   FUNCTION GETCLASSATTRIBUTELABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETCLASSATTRIBUTELABEL      (
         P_CLASS_NAME,
         P_ATTR_NAME );
         RETURN ret_value;
   END GETCLASSATTRIBUTELABEL;
   FUNCTION GETQUALIFIERREADATTRIBUTENAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERREADATTRIBUTENAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERREADATTRIBUTENAME;
   FUNCTION GETQUALIFIERREADDATATYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETQUALIFIERREADDATATYPE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END GETQUALIFIERREADDATATYPE;
   FUNCTION GETSETDESCRIPTION(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_SET_NAME IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2,
      P_SET_TYPE IN VARCHAR2,
      P_SET_OP_NAME IN VARCHAR2,
      P_ORDER_DIR IN VARCHAR2,
      P_ORDER_BY IN VARCHAR2,
      P_DESC_OVERRIDE IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALC_MAPPING.GETSETDESCRIPTION      (
         P_CALC_CONTEXT_ID,
         P_OBJECT_ID,
         P_SET_NAME,
         P_OBJECT_TYPE_CODE,
         P_SET_TYPE,
         P_SET_OP_NAME,
         P_ORDER_DIR,
         P_ORDER_BY,
         P_DESC_OVERRIDE,
         P_OPERATOR,
         P_DAYTIME );
         RETURN ret_value;
   END GETSETDESCRIPTION;

END RPDP_CALC_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CALC_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.26 AM


