
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.38.22 AM


CREATE or REPLACE PACKAGE RP_CNTR_DAY_INV_SWAP
IS

   FUNCTION TEXT_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECEIVER_OBJECT_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SWAP_UOM(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION SWAP_STATUS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SWAP_SEQ NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         RECEIVER_OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SWAP_QTY NUMBER ,
         SWAP_UOM VARCHAR2 (32) ,
         SWAP_STATUS VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
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
      P_SWAP_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION SWAP_QTY(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_CNTR_DAY_INV_SWAP;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_DAY_INV_SWAP
IS

   FUNCTION TEXT_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.TEXT_3      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.APPROVAL_BY      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.APPROVAL_STATE      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECEIVER_OBJECT_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.RECEIVER_OBJECT_ID      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END RECEIVER_OBJECT_ID;
   FUNCTION SWAP_UOM(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.SWAP_UOM      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END SWAP_UOM;
   FUNCTION VALUE_5(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_5      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.NEXT_DAYTIME      (
         P_SWAP_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.OBJECT_ID      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.PREV_EQUAL_DAYTIME      (
         P_SWAP_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION SWAP_STATUS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.SWAP_STATUS      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END SWAP_STATUS;
   FUNCTION COMMENTS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.COMMENTS      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.DATE_3      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.NEXT_EQUAL_DAYTIME      (
         P_SWAP_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.TEXT_1      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION VALUE_6(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_6      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.DATE_2      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_SWAP_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.PREV_DAYTIME      (
         P_SWAP_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.RECORD_STATUS      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_1      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.APPROVAL_DATE      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_SWAP_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.ROW_BY_PK      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.TEXT_2      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.TEXT_4      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_2(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_2      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_3      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_4      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CLASS_NAME(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.CLASS_NAME      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION DATE_4(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.DATE_4      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_SWAP_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.REC_ID      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_7      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_9      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.DATE_1      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_SWAP_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.DAYTIME      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION SWAP_QTY(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.SWAP_QTY      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END SWAP_QTY;
   FUNCTION VALUE_10(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_10      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_SWAP_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_DAY_INV_SWAP.VALUE_8      (
         P_SWAP_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_CNTR_DAY_INV_SWAP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_DAY_INV_SWAP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.38.29 AM


