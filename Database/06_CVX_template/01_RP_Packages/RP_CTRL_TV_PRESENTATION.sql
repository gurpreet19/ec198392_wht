
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.05 AM


CREATE or REPLACE PACKAGE RP_CTRL_TV_PRESENTATION
IS

   FUNCTION PARENT_COMPONENT_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_NO(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMPONENT_TYPE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         WINDOW_ID VARCHAR2 (30) ,
         COMPONENT_ID VARCHAR2 (30) ,
         PARENT_WINDOW_ID VARCHAR2 (30) ,
         PARENT_COMPONENT_ID VARCHAR2 (30) ,
         COMPONENT_TYPE VARCHAR2 (32) ,
         SORT_NO NUMBER ,
         COMPONENT_EXT_NAME VARCHAR2 (2000) ,
         COMPONENT_EXT_NAV_NAME VARCHAR2 (2000) ,
         COMPONENT_LABEL VARCHAR2 (64) ,
         COMPONENT_ATTR VARCHAR2 (2000) ,
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
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION COMPONENT_EXT_NAME(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMPONENT_LABEL(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PARENT_WINDOW_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMPONENT_ATTR(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMPONENT_EXT_NAV_NAME(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_TV_PRESENTATION;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_TV_PRESENTATION
IS

   FUNCTION PARENT_COMPONENT_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.PARENT_COMPONENT_ID      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END PARENT_COMPONENT_ID;
   FUNCTION APPROVAL_BY(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.APPROVAL_BY      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.APPROVAL_STATE      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION SORT_NO(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.SORT_NO      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END SORT_NO;
   FUNCTION COMPONENT_TYPE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.COMPONENT_TYPE      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END COMPONENT_TYPE;
   FUNCTION RECORD_STATUS(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.RECORD_STATUS      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.APPROVAL_DATE      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.ROW_BY_PK      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION COMPONENT_EXT_NAME(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.COMPONENT_EXT_NAME      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END COMPONENT_EXT_NAME;
   FUNCTION COMPONENT_LABEL(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.COMPONENT_LABEL      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END COMPONENT_LABEL;
   FUNCTION PARENT_WINDOW_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.PARENT_WINDOW_ID      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END PARENT_WINDOW_ID;
   FUNCTION REC_ID(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.REC_ID      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION COMPONENT_ATTR(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.COMPONENT_ATTR      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END COMPONENT_ATTR;
   FUNCTION COMPONENT_EXT_NAV_NAME(
      P_WINDOW_ID IN VARCHAR2,
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_TV_PRESENTATION.COMPONENT_EXT_NAV_NAME      (
         P_WINDOW_ID,
         P_COMPONENT_ID );
         RETURN ret_value;
   END COMPONENT_EXT_NAV_NAME;

END RP_CTRL_TV_PRESENTATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_TV_PRESENTATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.08 AM


