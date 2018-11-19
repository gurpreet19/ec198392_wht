
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.51.44 AM


CREATE or REPLACE PACKAGE RP_CARGO_ACTIVITY_CODE
IS

   FUNCTION SORT_ORDER(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ACTIVITY_NAME(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ACTIVITY_CODE VARCHAR2 (16) ,
         ACTIVITY_NAME VARCHAR2 (40) ,
         EXPORT_TYPE VARCHAR2 (16) ,
         EVENT_TYPE VARCHAR2 (16) ,
         FROM_DATE  DATE ,
         END_DATE  DATE ,
         SORT_ORDER NUMBER ,
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
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION EXPORT_TYPE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FROM_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION EVENT_TYPE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_CARGO_ACTIVITY_CODE;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_ACTIVITY_CODE
IS

   FUNCTION SORT_ORDER(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.SORT_ORDER      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.TEXT_3      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.TEXT_4      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.APPROVAL_BY      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.APPROVAL_STATE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_5      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_6      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ACTIVITY_NAME(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.ACTIVITY_NAME      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END ACTIVITY_NAME;
   FUNCTION END_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.END_DATE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.RECORD_STATUS      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_1      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.APPROVAL_DATE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.ROW_BY_PK      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_2      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_3      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_4      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION EXPORT_TYPE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.EXPORT_TYPE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END EXPORT_TYPE;
   FUNCTION FROM_DATE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.FROM_DATE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END FROM_DATE;
   FUNCTION REC_ID(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.REC_ID      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.TEXT_1      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.TEXT_2      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_7      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_9      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION EVENT_TYPE(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.EVENT_TYPE      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END EVENT_TYPE;
   FUNCTION VALUE_10(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_10      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ACTIVITY_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ACTIVITY_CODE.VALUE_8      (
         P_ACTIVITY_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_ACTIVITY_CODE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_ACTIVITY_CODE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.51.49 AM


