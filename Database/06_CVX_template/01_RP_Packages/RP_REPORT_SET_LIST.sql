
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.26 AM


CREATE or REPLACE PACKAGE RP_REPORT_SET_LIST
IS

   FUNCTION SORT_ORDER(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REPORT_RUNABLE_NO(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPORT_SET_NO NUMBER ,
         REPORT_RUNABLE_NO NUMBER ,
         FUNCTIONAL_AREA_ID VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         REF_NO NUMBER  );
   FUNCTION ROW_BY_PK(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_REPORT_SET_LIST;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_SET_LIST
IS

   FUNCTION SORT_ORDER(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.SORT_ORDER      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.APPROVAL_BY      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.APPROVAL_STATE      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.FUNCTIONAL_AREA_ID      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END FUNCTIONAL_AREA_ID;
   FUNCTION RECORD_STATUS(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.RECORD_STATUS      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.APPROVAL_DATE      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REPORT_RUNABLE_NO(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.REPORT_RUNABLE_NO      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END REPORT_RUNABLE_NO;
   FUNCTION ROW_BY_PK(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.ROW_BY_PK      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_REPORT_SET_NO IN NUMBER,
      P_REF_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_SET_LIST.REC_ID      (
         P_REPORT_SET_NO,
         P_REF_NO );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_SET_LIST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_SET_LIST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.30 AM


