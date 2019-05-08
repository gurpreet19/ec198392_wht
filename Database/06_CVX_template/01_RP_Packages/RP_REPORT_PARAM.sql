
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.45.36 AM


CREATE or REPLACE PACKAGE RP_REPORT_PARAM
IS

   FUNCTION PARAMETER_SUB_TYPE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ACCESS_CHECK_IND(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION PARAMETER_VALUE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPORT_NO NUMBER ,
         PARAMETER_NAME VARCHAR2 (240) ,
         PARAMETER_TYPE VARCHAR2 (32) ,
         PARAMETER_SUB_TYPE VARCHAR2 (32) ,
         PARAMETER_VALUE VARCHAR2 (2000) ,
         SORT_ORDER NUMBER ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         ACCESS_CHECK_IND VARCHAR2 (1) ,
         USER_VISIBLE_IND VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION USER_VISIBLE_IND(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PARAMETER_TYPE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_REPORT_PARAM;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_PARAM
IS

   FUNCTION PARAMETER_SUB_TYPE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.PARAMETER_SUB_TYPE      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_SUB_TYPE;
   FUNCTION SORT_ORDER(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_PARAM.SORT_ORDER      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.APPROVAL_BY      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.APPROVAL_STATE      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION ACCESS_CHECK_IND(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.ACCESS_CHECK_IND      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END ACCESS_CHECK_IND;
   FUNCTION RECORD_STATUS(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.RECORD_STATUS      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_PARAM.APPROVAL_DATE      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PARAMETER_VALUE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.PARAMETER_VALUE      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_VALUE;
   FUNCTION ROW_BY_PK(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_PARAM.ROW_BY_PK      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION USER_VISIBLE_IND(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.USER_VISIBLE_IND      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END USER_VISIBLE_IND;
   FUNCTION PARAMETER_TYPE(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.PARAMETER_TYPE      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_TYPE;
   FUNCTION REC_ID(
      P_REPORT_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_PARAM.REC_ID      (
         P_REPORT_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_PARAM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_PARAM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.45.41 AM


