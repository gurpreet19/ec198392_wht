
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.42.50 AM


CREATE or REPLACE PACKAGE RP_REPRESENTATIVE
IS

   FUNCTION IS_ACTIVE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CLASS_NAME VARCHAR2 (24) ,
         CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (100) ,
         IS_ACTIVE VARCHAR2 (1) ,
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
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         TEXT_10 VARCHAR2 (2000) ,
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
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_9(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_8(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_REPRESENTATIVE;

/



CREATE or REPLACE PACKAGE BODY RP_REPRESENTATIVE
IS

   FUNCTION IS_ACTIVE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.IS_ACTIVE      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END IS_ACTIVE;
   FUNCTION TEXT_3(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_3      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_4      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_7(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_7      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.APPROVAL_BY      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.APPROVAL_STATE      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.NAME      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION VALUE_5(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_5      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_10(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_10      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_5(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_5      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_6      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION VALUE_6(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_6      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.RECORD_STATUS      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_1      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.APPROVAL_DATE      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.ROW_BY_PK      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_9(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_9      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_2(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_2      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_3      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_4      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.REC_ID      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_1      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_2      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_7      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_9      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION TEXT_8(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.TEXT_8      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_10(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_10      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CLASS_NAME IN VARCHAR2,
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPRESENTATIVE.VALUE_8      (
         P_CLASS_NAME,
         P_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_REPRESENTATIVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPRESENTATIVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.01 AM


