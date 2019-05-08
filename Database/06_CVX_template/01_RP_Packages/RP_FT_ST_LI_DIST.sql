
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.25.00 AM


CREATE or REPLACE PACKAGE RP_FT_ST_LI_DIST
IS

   FUNCTION FT_ST_TRANSACTION_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SORT_ORDER(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FT_ST_LINE_ITEM_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRICING_TOTAL(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SPLIT_SHARE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ALLOC_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRICING_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRICING_VAT_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FT_ST_DOCUMENT_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         FT_ST_LI_DIST_NO NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
         NODE_ID VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         FT_ST_DOCUMENT_NO NUMBER ,
         FT_ST_TRANSACTION_NO NUMBER ,
         FT_ST_LINE_ITEM_NO NUMBER ,
         DIST_ID VARCHAR2 (32) ,
         QTY1 NUMBER ,
         QTY2 NUMBER ,
         QTY3 NUMBER ,
         QTY4 NUMBER ,
         ALLOC_STREAM_ITEM_ID VARCHAR2 (32) ,
         STREAM_ITEM_ID VARCHAR2 (32) ,
         SPLIT_SHARE NUMBER ,
         SPLIT_METHOD VARCHAR2 (32) ,
         PRICING_VALUE NUMBER ,
         SPLIT_VALUE NUMBER ,
         PRICING_VAT_VALUE NUMBER ,
         PRICING_TOTAL NUMBER ,
         SPLIT_SHARE_QTY2 NUMBER ,
         SPLIT_SHARE_QTY3 NUMBER ,
         SPLIT_SHARE_QTY4 NUMBER ,
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
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION QTY2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_METHOD(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_SHARE_QTY2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SPLIT_SHARE_QTY3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DIST_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NODE_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_SHARE_QTY4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER;

END RP_FT_ST_LI_DIST;

/



CREATE or REPLACE PACKAGE BODY RP_FT_ST_LI_DIST
IS

   FUNCTION FT_ST_TRANSACTION_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.FT_ST_TRANSACTION_NO      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END FT_ST_TRANSACTION_NO;
   FUNCTION QTY1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.QTY1      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END QTY1;
   FUNCTION SORT_ORDER(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SORT_ORDER      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.TEXT_3      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.TEXT_4      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.APPROVAL_BY      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.APPROVAL_STATE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_5      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION FT_ST_LINE_ITEM_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.FT_ST_LINE_ITEM_NO      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END FT_ST_LINE_ITEM_NO;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.NEXT_DAYTIME      (
         P_FT_ST_LI_DIST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.OBJECT_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.PREV_EQUAL_DAYTIME      (
         P_FT_ST_LI_DIST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRICING_TOTAL(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.PRICING_TOTAL      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END PRICING_TOTAL;
   FUNCTION SPLIT_SHARE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_SHARE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_SHARE;
   FUNCTION ALLOC_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.ALLOC_STREAM_ITEM_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END ALLOC_STREAM_ITEM_ID;
   FUNCTION COMMENTS(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.COMMENTS      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DATE_3      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DATE_5      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.NEXT_EQUAL_DAYTIME      (
         P_FT_ST_LI_DIST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PRICING_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.PRICING_VALUE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END PRICING_VALUE;
   FUNCTION PRICING_VAT_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.PRICING_VAT_VALUE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END PRICING_VAT_VALUE;
   FUNCTION VALUE_6(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_6      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DATE_2      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION FT_ST_DOCUMENT_NO(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.FT_ST_DOCUMENT_NO      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END FT_ST_DOCUMENT_NO;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.PREV_DAYTIME      (
         P_FT_ST_LI_DIST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION QTY3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.QTY3      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END QTY3;
   FUNCTION QTY4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.QTY4      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END QTY4;
   FUNCTION RECORD_STATUS(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.RECORD_STATUS      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPLIT_VALUE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_VALUE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_VALUE;
   FUNCTION VALUE_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_1      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.APPROVAL_DATE      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.ROW_BY_PK      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_2      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_3      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_4      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DATE_4      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION QTY2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.QTY2      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END QTY2;
   FUNCTION REC_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.REC_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SPLIT_METHOD(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_METHOD      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_METHOD;
   FUNCTION SPLIT_SHARE_QTY2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_SHARE_QTY2      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_SHARE_QTY2;
   FUNCTION SPLIT_SHARE_QTY3(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_SHARE_QTY3      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_SHARE_QTY3;
   FUNCTION TEXT_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.TEXT_1      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.TEXT_2      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_7      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_9      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DATE_1      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DAYTIME      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DIST_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.DIST_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END DIST_ID;
   FUNCTION NODE_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.NODE_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END NODE_ID;
   FUNCTION SPLIT_SHARE_QTY4(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.SPLIT_SHARE_QTY4      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END SPLIT_SHARE_QTY4;
   FUNCTION STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.STREAM_ITEM_ID      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END STREAM_ITEM_ID;
   FUNCTION VALUE_10(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_10      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_FT_ST_LI_DIST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST.VALUE_8      (
         P_FT_ST_LI_DIST_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FT_ST_LI_DIST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FT_ST_LI_DIST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.25.11 AM


