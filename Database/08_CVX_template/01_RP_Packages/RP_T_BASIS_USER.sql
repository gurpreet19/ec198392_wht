
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.26.56 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_USER
IS

   FUNCTION DEPARTMENT(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION USER_AUTOLOGIN_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION PHONE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REFERENCE_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SYSTEM_PRIV(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TITLE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ACTIVE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APP_ID(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FAILED_LOGIN_ATTEMPTS(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION SURNAME(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION PASSWORD_LOGIN(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_USER_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION MIDDLE_INITIAL(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PASSWORD_PROTECT_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         USER_ID VARCHAR2 (30) ,
         PASSWORD_LOGIN VARCHAR2 (64) ,
         PASSWORD_DB VARCHAR2 (30) ,
         USER_LOGIN_ID VARCHAR2 (64) ,
         PASSWORD_PROTECT_IND VARCHAR2 (1) ,
         SURNAME VARCHAR2 (40) ,
         GIVEN_NAME VARCHAR2 (40) ,
         MIDDLE_INITIAL VARCHAR2 (40) ,
         EMAIL_ADDRESS VARCHAR2 (100) ,
         PHONE VARCHAR2 (240) ,
         SYSTEM_PRIV VARCHAR2 (1) ,
         USER_GROUP VARCHAR2 (32) ,
         APP_ID NUMBER ,
         ACTIVE VARCHAR2 (1) ,
         PASSWORD_EXPIRY_DATE  DATE ,
         FAILED_LOGIN_ATTEMPTS NUMBER ,
         DEPARTMENT VARCHAR2 (32) ,
         REFERENCE_IND VARCHAR2 (1) ,
         PKI_USER_ID VARCHAR2 (32) ,
         USER_AUTOLOGIN_IND VARCHAR2 (1) ,
         CERTIFICATE_ID VARCHAR2 (100) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         TITLE VARCHAR2 (256)  );
   FUNCTION ROW_BY_PK(
      P_USER_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GIVEN_NAME(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PASSWORD_DB(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION USER_LOGIN_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CERTIFICATE_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION EMAIL_ADDRESS(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PASSWORD_EXPIRY_DATE(
      P_USER_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION PKI_USER_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION USER_GROUP(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_T_BASIS_USER;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_USER
IS

   FUNCTION DEPARTMENT(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.DEPARTMENT      (
         P_USER_ID );
         RETURN ret_value;
   END DEPARTMENT;
   FUNCTION TEXT_3(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TEXT_3      (
         P_USER_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TEXT_4      (
         P_USER_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.APPROVAL_BY      (
         P_USER_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.APPROVAL_STATE      (
         P_USER_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION USER_AUTOLOGIN_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.USER_AUTOLOGIN_IND      (
         P_USER_ID );
         RETURN ret_value;
   END USER_AUTOLOGIN_IND;
   FUNCTION VALUE_5(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_5      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION PHONE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PHONE      (
         P_USER_ID );
         RETURN ret_value;
   END PHONE;
   FUNCTION REFERENCE_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.REFERENCE_IND      (
         P_USER_ID );
         RETURN ret_value;
   END REFERENCE_IND;
   FUNCTION SYSTEM_PRIV(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.SYSTEM_PRIV      (
         P_USER_ID );
         RETURN ret_value;
   END SYSTEM_PRIV;
   FUNCTION TITLE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (256) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TITLE      (
         P_USER_ID );
         RETURN ret_value;
   END TITLE;
   FUNCTION ACTIVE(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.ACTIVE      (
         P_USER_ID );
         RETURN ret_value;
   END ACTIVE;
   FUNCTION APP_ID(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.APP_ID      (
         P_USER_ID );
         RETURN ret_value;
   END APP_ID;
   FUNCTION FAILED_LOGIN_ATTEMPTS(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.FAILED_LOGIN_ATTEMPTS      (
         P_USER_ID );
         RETURN ret_value;
   END FAILED_LOGIN_ATTEMPTS;
   FUNCTION SURNAME(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.SURNAME      (
         P_USER_ID );
         RETURN ret_value;
   END SURNAME;
   FUNCTION VALUE_6(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_6      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PASSWORD_LOGIN(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PASSWORD_LOGIN      (
         P_USER_ID );
         RETURN ret_value;
   END PASSWORD_LOGIN;
   FUNCTION RECORD_STATUS(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.RECORD_STATUS      (
         P_USER_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_1      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_USER_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_USER.APPROVAL_DATE      (
         P_USER_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION MIDDLE_INITIAL(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.MIDDLE_INITIAL      (
         P_USER_ID );
         RETURN ret_value;
   END MIDDLE_INITIAL;
   FUNCTION PASSWORD_PROTECT_IND(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PASSWORD_PROTECT_IND      (
         P_USER_ID );
         RETURN ret_value;
   END PASSWORD_PROTECT_IND;
   FUNCTION ROW_BY_PK(
      P_USER_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_USER.ROW_BY_PK      (
         P_USER_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TEXT_5      (
         P_USER_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_2      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_3      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_4      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION GIVEN_NAME(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.GIVEN_NAME      (
         P_USER_ID );
         RETURN ret_value;
   END GIVEN_NAME;
   FUNCTION PASSWORD_DB(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PASSWORD_DB      (
         P_USER_ID );
         RETURN ret_value;
   END PASSWORD_DB;
   FUNCTION REC_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.REC_ID      (
         P_USER_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TEXT_1      (
         P_USER_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.TEXT_2      (
         P_USER_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION USER_LOGIN_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.USER_LOGIN_ID      (
         P_USER_ID );
         RETURN ret_value;
   END USER_LOGIN_ID;
   FUNCTION VALUE_7(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_7      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_9      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION CERTIFICATE_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.CERTIFICATE_ID      (
         P_USER_ID );
         RETURN ret_value;
   END CERTIFICATE_ID;
   FUNCTION EMAIL_ADDRESS(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.EMAIL_ADDRESS      (
         P_USER_ID );
         RETURN ret_value;
   END EMAIL_ADDRESS;
   FUNCTION PASSWORD_EXPIRY_DATE(
      P_USER_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PASSWORD_EXPIRY_DATE      (
         P_USER_ID );
         RETURN ret_value;
   END PASSWORD_EXPIRY_DATE;
   FUNCTION PKI_USER_ID(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.PKI_USER_ID      (
         P_USER_ID );
         RETURN ret_value;
   END PKI_USER_ID;
   FUNCTION USER_GROUP(
      P_USER_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_USER.USER_GROUP      (
         P_USER_ID );
         RETURN ret_value;
   END USER_GROUP;
   FUNCTION VALUE_10(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_10      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_USER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_USER.VALUE_8      (
         P_USER_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_T_BASIS_USER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_USER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.27.05 AM


