
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.29 AM


CREATE or REPLACE PACKAGE RP_CTRL_DASHBOARD
IS

   FUNCTION DESCRIPTION(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION WIDGET_CLASS(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION CATEGORY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         WIDGET_CODE VARCHAR2 (32) ,
         CATEGORY VARCHAR2 (255) ,
         NAME VARCHAR2 (255) ,
         LABEL VARCHAR2 (255) ,
         DESCRIPTION VARCHAR2 (2000) ,
         WIDGET_CLASS VARCHAR2 (255) ,
         CACHE_POLICY VARCHAR2 (1020) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION CACHE_POLICY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_DASHBOARD;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_DASHBOARD
IS

   FUNCTION DESCRIPTION(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.DESCRIPTION      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION LABEL(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.LABEL      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END LABEL;
   FUNCTION NAME(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.NAME      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION APPROVAL_BY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.APPROVAL_BY      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.APPROVAL_STATE      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION WIDGET_CLASS(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.WIDGET_CLASS      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END WIDGET_CLASS;
   FUNCTION RECORD_STATUS(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.RECORD_STATUS      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.APPROVAL_DATE      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CATEGORY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.CATEGORY      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END CATEGORY;
   FUNCTION ROW_BY_PK(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.ROW_BY_PK      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CACHE_POLICY(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1020) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.CACHE_POLICY      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END CACHE_POLICY;
   FUNCTION REC_ID(
      P_WIDGET_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_DASHBOARD.REC_ID      (
         P_WIDGET_CODE );
         RETURN ret_value;
   END REC_ID;

END RP_CTRL_DASHBOARD;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_DASHBOARD TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.32 AM


