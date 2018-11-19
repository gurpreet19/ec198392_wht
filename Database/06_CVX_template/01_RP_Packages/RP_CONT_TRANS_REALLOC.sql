
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.19.09 AM


CREATE or REPLACE PACKAGE RP_CONT_TRANS_REALLOC
IS

   FUNCTION TEXT_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BOOKED_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OBJECT_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REALLOC_DATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSFER_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID2_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NAME(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REALLOC_LEVEL_CODE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         TRANSACTION_KEY VARCHAR2 (32) ,
         REALLOC_NO NUMBER ,
         NAME VARCHAR2 (240) ,
         BOOKING_PERIOD  DATE ,
         REALLOC_LEVEL_CODE VARCHAR2 (32) ,
         REALLOC_DATE  DATE ,
         SET_TO_PREV_IND VARCHAR2 (1) ,
         SET_TO_NEXT_IND VARCHAR2 (1) ,
         VALID1_USER_ID VARCHAR2 (30) ,
         VALID2_USER_ID VARCHAR2 (30) ,
         TRANSFER_USER_ID VARCHAR2 (30) ,
         BOOKED_USER_ID VARCHAR2 (30) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         APPROVAL_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SET_TO_NEXT_IND(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SET_TO_PREV_IND(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID1_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BOOKING_PERIOD(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER;

END RP_CONT_TRANS_REALLOC;

/



CREATE or REPLACE PACKAGE BODY RP_CONT_TRANS_REALLOC
IS

   FUNCTION TEXT_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.TEXT_3      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.TEXT_4      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.APPROVAL_BY      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.APPROVAL_STATE      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_5      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION BOOKED_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.BOOKED_USER_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END BOOKED_USER_ID;
   FUNCTION OBJECT_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.OBJECT_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION DATE_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.DATE_3      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.DATE_5      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION VALUE_6(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_6      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.DATE_2      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION REALLOC_DATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.REALLOC_DATE      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END REALLOC_DATE;
   FUNCTION RECORD_STATUS(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.RECORD_STATUS      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TRANSFER_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.TRANSFER_USER_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END TRANSFER_USER_ID;
   FUNCTION VALID2_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALID2_USER_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALID2_USER_ID;
   FUNCTION VALUE_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_1      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.APPROVAL_DATE      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.NAME      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION REALLOC_LEVEL_CODE(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.REALLOC_LEVEL_CODE      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END REALLOC_LEVEL_CODE;
   FUNCTION ROW_BY_PK(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.ROW_BY_PK      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SET_TO_NEXT_IND(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.SET_TO_NEXT_IND      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END SET_TO_NEXT_IND;
   FUNCTION SET_TO_PREV_IND(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.SET_TO_PREV_IND      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END SET_TO_PREV_IND;
   FUNCTION VALID1_USER_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALID1_USER_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALID1_USER_ID;
   FUNCTION VALUE_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_2      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_3      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_4      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BOOKING_PERIOD(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.BOOKING_PERIOD      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END BOOKING_PERIOD;
   FUNCTION DATE_4(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.DATE_4      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.REC_ID      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.TEXT_1      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.TEXT_2      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_7      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_9      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.DATE_1      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_10      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TRANSACTION_KEY IN VARCHAR2,
      P_REALLOC_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_TRANS_REALLOC.VALUE_8      (
         P_TRANSACTION_KEY,
         P_REALLOC_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CONT_TRANS_REALLOC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONT_TRANS_REALLOC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.19.16 AM


