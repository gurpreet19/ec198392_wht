
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.37.06 AM


CREATE or REPLACE PACKAGE RP_CNTR_DP_TRADE_EVENT
IS

   FUNCTION SENT_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECEIVED_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TRADE_TYPE(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DELIVERY_POINT_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRADE_ITEM(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRADE_QTY(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         TRADE_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DELIVERY_POINT_ID VARCHAR2 (32) ,
         TRADE_TYPE VARCHAR2 (32) ,
         TRADE_ITEM VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RECEIVED_DATE  DATE ,
         SENT_DATE  DATE ,
         TRADE_QTY NUMBER ,
         UOM VARCHAR2 (32) ,
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
      P_TRADE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UOM(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_TRADE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER;

END RP_CNTR_DP_TRADE_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_DP_TRADE_EVENT
IS

   FUNCTION SENT_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.SENT_DATE      (
         P_TRADE_NO );
         RETURN ret_value;
   END SENT_DATE;
   FUNCTION TEXT_3(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TEXT_3      (
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TEXT_4      (
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.APPROVAL_BY      (
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.APPROVAL_STATE      (
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECEIVED_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.RECEIVED_DATE      (
         P_TRADE_NO );
         RETURN ret_value;
   END RECEIVED_DATE;
   FUNCTION TRADE_TYPE(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TRADE_TYPE      (
         P_TRADE_NO );
         RETURN ret_value;
   END TRADE_TYPE;
   FUNCTION VALUE_5(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_5      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.NEXT_DAYTIME      (
         P_TRADE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.OBJECT_ID      (
         P_TRADE_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.PREV_EQUAL_DAYTIME      (
         P_TRADE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.NEXT_EQUAL_DAYTIME      (
         P_TRADE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_6      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DELIVERY_POINT_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.DELIVERY_POINT_ID      (
         P_TRADE_NO );
         RETURN ret_value;
   END DELIVERY_POINT_ID;
   FUNCTION PREV_DAYTIME(
      P_TRADE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.PREV_DAYTIME      (
         P_TRADE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.RECORD_STATUS      (
         P_TRADE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TRADE_ITEM(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TRADE_ITEM      (
         P_TRADE_NO );
         RETURN ret_value;
   END TRADE_ITEM;
   FUNCTION TRADE_QTY(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TRADE_QTY      (
         P_TRADE_NO );
         RETURN ret_value;
   END TRADE_QTY;
   FUNCTION VALUE_1(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_1      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.APPROVAL_DATE      (
         P_TRADE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_TRADE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.ROW_BY_PK      (
         P_TRADE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_2      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_3      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_4      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.REC_ID      (
         P_TRADE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TEXT_1      (
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.TEXT_2      (
         P_TRADE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION UOM(
      P_TRADE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.UOM      (
         P_TRADE_NO );
         RETURN ret_value;
   END UOM;
   FUNCTION VALUE_7(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_7      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_9      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_TRADE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.DAYTIME      (
         P_TRADE_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION VALUE_10(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_10      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TRADE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DP_TRADE_EVENT.VALUE_8      (
         P_TRADE_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CNTR_DP_TRADE_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_DP_TRADE_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.37.13 AM


