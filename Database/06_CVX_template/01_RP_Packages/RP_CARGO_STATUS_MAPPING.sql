
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.06.34 AM


CREATE or REPLACE PACKAGE RP_CARGO_STATUS_MAPPING
IS

   FUNCTION SORT_ORDER(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRAN_QTY_CODE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REV_QTY_CODE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_STATUS VARCHAR2 (32) ,
         EC_CARGO_STATUS VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         REV_QTY_CODE VARCHAR2 (32) ,
         TRAN_QTY_CODE VARCHAR2 (32) ,
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
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER;

END RP_CARGO_STATUS_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_STATUS_MAPPING
IS

   FUNCTION SORT_ORDER(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.SORT_ORDER      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.TEXT_3      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.TEXT_4      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TRAN_QTY_CODE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.TRAN_QTY_CODE      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END TRAN_QTY_CODE;
   FUNCTION APPROVAL_BY(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.APPROVAL_BY      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.APPROVAL_STATE      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REV_QTY_CODE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.REV_QTY_CODE      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END REV_QTY_CODE;
   FUNCTION VALUE_5(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_5      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_6      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.RECORD_STATUS      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_1      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.APPROVAL_DATE      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.ROW_BY_PK      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_2      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_3      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_4      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.REC_ID      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.TEXT_1      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.TEXT_2      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_7      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_9      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_10      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_STATUS IN VARCHAR2,
      P_EC_CARGO_STATUS IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STATUS_MAPPING.VALUE_8      (
         P_CARGO_STATUS,
         P_EC_CARGO_STATUS );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_STATUS_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_STATUS_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.06.39 AM


