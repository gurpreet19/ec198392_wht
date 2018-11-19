
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.16.24 AM


CREATE or REPLACE PACKAGE RP_CT_PORT_ROLE_CONNECT
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION REPRESENTATIVE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         ROLE_CODE VARCHAR2 (32) ,
         EFFECTIVE_DAYTIME  DATE ,
         REPRESENTATIVE_CODE VARCHAR2 (32) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (240) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RP_CT_PORT_ROLE_CONNECT;

/



CREATE or REPLACE PACKAGE BODY RP_CT_PORT_ROLE_CONNECT
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REPRESENTATIVE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.REPRESENTATIVE_CODE      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END REPRESENTATIVE_CODE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_ROLE_CODE IN VARCHAR2,
      P_EFFECTIVE_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CT_PORT_ROLE_CONNECT.REC_ID      (
         P_OBJECT_ID,
         P_ROLE_CODE,
         P_EFFECTIVE_DAYTIME );
         RETURN ret_value;
   END REC_ID;

END RP_CT_PORT_ROLE_CONNECT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CT_PORT_ROLE_CONNECT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.16.26 AM


