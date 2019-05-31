
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.12.42 AM


CREATE or REPLACE PACKAGE RP_LIFTING_DOC_SET
IS

   FUNCTION SORT_ORDER(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PARCEL_NO NUMBER ,
         DOC_CODE VARCHAR2 (32) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_LIFTING_DOC_SET;

/



CREATE or REPLACE PACKAGE BODY RP_LIFTING_DOC_SET
IS

   FUNCTION SORT_ORDER(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.SORT_ORDER      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.TEXT_3      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.TEXT_4      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.APPROVAL_BY      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.APPROVAL_STATE      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_5      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_6      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.RECORD_STATUS      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_1      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.APPROVAL_DATE      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.ROW_BY_PK      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_2      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_3      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_4      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.REC_ID      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.TEXT_1      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.TEXT_2      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_7      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_9      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_10      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_PARCEL_NO IN NUMBER,
      P_DOC_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_DOC_SET.VALUE_8      (
         P_PARCEL_NO,
         P_DOC_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFTING_DOC_SET;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFTING_DOC_SET TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.12.47 AM


