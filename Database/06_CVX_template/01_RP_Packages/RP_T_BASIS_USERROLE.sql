
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.26.51 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_USERROLE
IS

   FUNCTION TEXT_3(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         USER_ID VARCHAR2 (30) ,
         ROLE_ID VARCHAR2 (30) ,
         APP_ID NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
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
         VALID_FROM  DATE ,
         VALID_TO  DATE  );
   FUNCTION ROW_BY_PK(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_TO(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE;

END RP_T_BASIS_USERROLE;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_USERROLE
IS

   FUNCTION TEXT_3(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.TEXT_3      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.TEXT_4      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.APPROVAL_BY      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.APPROVAL_STATE      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALUE_5      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION RECORD_STATUS(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.RECORD_STATUS      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALUE_1      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.APPROVAL_DATE      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.ROW_BY_PK      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.TEXT_5      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALUE_2      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALUE_3      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALUE_4      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.REC_ID      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.TEXT_1      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.TEXT_2      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALID_FROM      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALID_FROM;
   FUNCTION VALID_TO(
      P_USER_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_USERROLE.VALID_TO      (
         P_USER_ID,
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END VALID_TO;

END RP_T_BASIS_USERROLE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_USERROLE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.26.56 AM


