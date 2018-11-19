
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.50.36 AM


CREATE or REPLACE PACKAGE RP_CARGO_PROTEST
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         PROTEST_CODE VARCHAR2 (32) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
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
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE;

END RP_CARGO_PROTEST;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_PROTEST
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.TEXT_3      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.TEXT_4      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.APPROVAL_BY      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.APPROVAL_STATE      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.DATE_2      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.RECORD_STATUS      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.VALUE_1      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.APPROVAL_DATE      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.ROW_BY_PK      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.VALUE_2      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.VALUE_3      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.REC_ID      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.TEXT_1      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.TEXT_2      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_PROTEST_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_PROTEST.DATE_1      (
         P_CARGO_NO,
         P_PROTEST_CODE );
         RETURN ret_value;
   END DATE_1;

END RP_CARGO_PROTEST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_PROTEST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.50.40 AM


