
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.18.34 AM


CREATE or REPLACE PACKAGE RP_BLEND
IS

   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION MASTER_SYS_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION MAIN_COMPONENT_NO(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         MAIN_COMPONENT_NO VARCHAR2 (16) ,
         MASTER_SYS_CODE VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (240) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         MAIN_COMPONENT_NO VARCHAR2 (16) ,
         MASTER_SYS_CODE VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (240) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_BLEND;

/



CREATE or REPLACE PACKAGE BODY RP_BLEND
IS

   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BLEND.SORT_ORDER      (
         P_OBJECT_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_BLEND.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BLEND.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION MASTER_SYS_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BLEND.MASTER_SYS_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END MASTER_SYS_CODE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BLEND.END_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION MAIN_COMPONENT_NO(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_BLEND.MAIN_COMPONENT_NO      (
         P_OBJECT_ID );
         RETURN ret_value;
   END MAIN_COMPONENT_NO;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BLEND.OBJECT_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_CODE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BLEND.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BLEND.START_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END START_DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BLEND.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_BLEND.DESCRIPTION      (
         P_OBJECT_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_BLEND.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_BLEND.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BLEND.OBJECT_ID_BY_UK      (
         P_OBJECT_CODE );
         RETURN ret_value;
   END OBJECT_ID_BY_UK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BLEND.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;

END RP_BLEND;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_BLEND TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.18.37 AM


