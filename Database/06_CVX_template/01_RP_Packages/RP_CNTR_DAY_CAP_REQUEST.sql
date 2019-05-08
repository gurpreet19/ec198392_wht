
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.56.30 AM


CREATE or REPLACE PACKAGE RP_CNTR_DAY_CAP_REQUEST
IS

   FUNCTION TEXT_3(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REQUESTED_STATUS(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REQUESTED_QTY(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         REQ_SEQ NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         REQUESTED_QTY NUMBER ,
         REQUESTED_STATUS VARCHAR2 (32) ,
         AWARDED_QTY NUMBER ,
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
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_REQ_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION AWARDED_QTY(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_CNTR_DAY_CAP_REQUEST;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_DAY_CAP_REQUEST
IS

   FUNCTION TEXT_3(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_3      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.APPROVAL_BY      (
         P_REQ_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.APPROVAL_STATE      (
         P_REQ_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_5      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.NEXT_DAYTIME      (
         P_REQ_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.OBJECT_ID      (
         P_REQ_SEQ );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.PREV_EQUAL_DAYTIME      (
         P_REQ_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_7      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_8      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DATE_3      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DATE_5      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.NEXT_EQUAL_DAYTIME      (
         P_REQ_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_1      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_6      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_9      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_6      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DATE_2      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_REQ_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.PREV_DAYTIME      (
         P_REQ_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.RECORD_STATUS      (
         P_REQ_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REQUESTED_STATUS(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.REQUESTED_STATUS      (
         P_REQ_SEQ );
         RETURN ret_value;
   END REQUESTED_STATUS;
   FUNCTION VALUE_1(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_1      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.APPROVAL_DATE      (
         P_REQ_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REQUESTED_QTY(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.REQUESTED_QTY      (
         P_REQ_SEQ );
         RETURN ret_value;
   END REQUESTED_QTY;
   FUNCTION ROW_BY_PK(
      P_REQ_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.ROW_BY_PK      (
         P_REQ_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_2      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_4      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_5      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_2      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_3      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_4      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION AWARDED_QTY(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.AWARDED_QTY      (
         P_REQ_SEQ );
         RETURN ret_value;
   END AWARDED_QTY;
   FUNCTION DATE_4(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DATE_4      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.REC_ID      (
         P_REQ_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_7      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_9      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DATE_1      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_REQ_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.DAYTIME      (
         P_REQ_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_REQ_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.TEXT_10      (
         P_REQ_SEQ );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_10      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_REQ_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_CAP_REQUEST.VALUE_8      (
         P_REQ_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_CNTR_DAY_CAP_REQUEST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_DAY_CAP_REQUEST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.56.39 AM


