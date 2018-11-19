
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.17.31 AM


CREATE or REPLACE PACKAGE RPDP_XLS_REPORTS
IS

   FUNCTION GETOBJECTTYPELABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSETDESCRIPTION(
      P_REPT_CONTEXT_ID IN VARCHAR2,
      P_SET_NAME IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2,
      P_SET_TYPE IN VARCHAR2,
      P_SET_OP_NAME IN VARCHAR2,
      P_ORDER_DIR IN VARCHAR2,
      P_ORDER_BY IN VARCHAR2,
      P_DESC_OVERRIDE IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_ELEMENT_TIME_SCOPE_CODE IN VARCHAR2,
      P_SET_TIME_SCOPE_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_XLS_REPORTS;

/



CREATE or REPLACE PACKAGE BODY RPDP_XLS_REPORTS
IS

   FUNCTION GETOBJECTTYPELABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_XLS_REPORTS.GETOBJECTTYPELABEL      (
         P_OBJECT_ID,
         P_OBJECT_TYPE_CODE );
         RETURN ret_value;
   END GETOBJECTTYPELABEL;
   FUNCTION GETSETDESCRIPTION(
      P_REPT_CONTEXT_ID IN VARCHAR2,
      P_SET_NAME IN VARCHAR2,
      P_OBJECT_TYPE_CODE IN VARCHAR2,
      P_SET_TYPE IN VARCHAR2,
      P_SET_OP_NAME IN VARCHAR2,
      P_ORDER_DIR IN VARCHAR2,
      P_ORDER_BY IN VARCHAR2,
      P_DESC_OVERRIDE IN VARCHAR2,
      P_OPERATOR IN VARCHAR2,
      P_ELEMENT_TIME_SCOPE_CODE IN VARCHAR2,
      P_SET_TIME_SCOPE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_XLS_REPORTS.GETSETDESCRIPTION      (
         P_REPT_CONTEXT_ID,
         P_SET_NAME,
         P_OBJECT_TYPE_CODE,
         P_SET_TYPE,
         P_SET_OP_NAME,
         P_ORDER_DIR,
         P_ORDER_BY,
         P_DESC_OVERRIDE,
         P_OPERATOR,
         P_ELEMENT_TIME_SCOPE_CODE,
         P_SET_TIME_SCOPE_CODE );
         RETURN ret_value;
   END GETSETDESCRIPTION;

END RPDP_XLS_REPORTS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_XLS_REPORTS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.17.34 AM


