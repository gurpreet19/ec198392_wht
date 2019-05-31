
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.12.52 AM


CREATE or REPLACE PACKAGE RP_LIFTING_DELAY_CODE
IS

   FUNCTION SORT_ORDER(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DELAY_NAME(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LIFTING_EVENT(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_1(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         DELAY_CODE VARCHAR2 (32) ,
         DELAY_NAME VARCHAR2 (100) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         LIFTING_EVENT VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_DELAY_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_LIFTING_DELAY_CODE;

/



CREATE or REPLACE PACKAGE BODY RP_LIFTING_DELAY_CODE
IS

   FUNCTION SORT_ORDER(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.SORT_ORDER      (
         P_DELAY_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.TEXT_3      (
         P_DELAY_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.TEXT_4      (
         P_DELAY_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.APPROVAL_BY      (
         P_DELAY_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.APPROVAL_STATE      (
         P_DELAY_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_5      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DELAY_NAME(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.DELAY_NAME      (
         P_DELAY_CODE );
         RETURN ret_value;
   END DELAY_NAME;
   FUNCTION LIFTING_EVENT(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.LIFTING_EVENT      (
         P_DELAY_CODE );
         RETURN ret_value;
   END LIFTING_EVENT;
   FUNCTION VALUE_6(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_6      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION END_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.END_DATE      (
         P_DELAY_CODE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.RECORD_STATUS      (
         P_DELAY_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.START_DATE      (
         P_DELAY_CODE );
         RETURN ret_value;
   END START_DATE;
   FUNCTION VALUE_1(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_1      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_DELAY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.APPROVAL_DATE      (
         P_DELAY_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_DELAY_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.ROW_BY_PK      (
         P_DELAY_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_2      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_3      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_4      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.REC_ID      (
         P_DELAY_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.TEXT_1      (
         P_DELAY_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_DELAY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.TEXT_2      (
         P_DELAY_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_7      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_9      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_10      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_DELAY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DELAY_CODE.VALUE_8      (
         P_DELAY_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFTING_DELAY_CODE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFTING_DELAY_CODE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.12.57 AM


