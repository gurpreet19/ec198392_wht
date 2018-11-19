
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.31.38 AM


CREATE or REPLACE PACKAGE RP_CNTR_TRADE_INTEREST
IS

   FUNCTION SENT_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECEIVED_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION INTEREST_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         TRADE_NO NUMBER ,
         RECEIVED_DATE  DATE ,
         SENT_DATE  DATE ,
         INTEREST_QTY NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;

END RP_CNTR_TRADE_INTEREST;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_TRADE_INTEREST
IS

   FUNCTION SENT_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.SENT_DATE      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END SENT_DATE;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.TEXT_3      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.TEXT_4      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.APPROVAL_BY      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECEIVED_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.RECEIVED_DATE      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END RECEIVED_DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_5      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_6      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION INTEREST_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.INTEREST_QTY      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END INTEREST_QTY;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.RECORD_STATUS      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_1      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.ROW_BY_PK      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_2      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_3      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_4      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.REC_ID      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.TEXT_1      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.TEXT_2      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_7      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_9      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_10      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_TRADE_INTEREST.VALUE_8      (
         P_OBJECT_ID,
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CNTR_TRADE_INTEREST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_TRADE_INTEREST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.31.43 AM


