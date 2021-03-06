
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.24.48 AM


CREATE or REPLACE PACKAGE RP_FT_ST_LI_DIST_COMPANY
IS

   FUNCTION COMPANY_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FT_ST_TRANSACTION_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VENDOR_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VENDOR_SHARE_QTY3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VENDOR_SHARE_QTY2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FT_ST_LINE_ITEM_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FT_ST_LI_DIST_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRICING_TOTAL(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SPLIT_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VAT_RATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VENDOR_SHARE_QTY4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ALLOC_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRICING_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRICING_VAT_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VENDOR_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CUSTOMER_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CUSTOMER_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FT_ST_DOCUMENT_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         FT_ST_LI_DIST_COMPANY_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         FT_ST_DOCUMENT_NO NUMBER ,
         FT_ST_TRANSACTION_NO NUMBER ,
         FT_ST_LINE_ITEM_NO NUMBER ,
         FT_ST_LI_DIST_NO NUMBER ,
         VENDOR_ID VARCHAR2 (32) ,
         CUSTOMER_ID VARCHAR2 (32) ,
         DIST_ID VARCHAR2 (32) ,
         NODE_ID VARCHAR2 (32) ,
         VENDOR_SHARE NUMBER ,
         CUSTOMER_SHARE NUMBER ,
         QTY1 NUMBER ,
         QTY2 NUMBER ,
         QTY3 NUMBER ,
         QTY4 NUMBER ,
         NON_ADJUSTED_VALUE NUMBER ,
         PRICING_VALUE NUMBER ,
         PRICING_VAT_VALUE NUMBER ,
         PRICING_TOTAL NUMBER ,
         SPLIT_SHARE NUMBER ,
         VAT_RATE NUMBER ,
         ALLOC_STREAM_ITEM_ID VARCHAR2 (32) ,
         COMPANY_STREAM_ITEM_ID VARCHAR2 (32) ,
         SPLIT_VALUE NUMBER ,
         VENDOR_SHARE_QTY2 NUMBER ,
         VENDOR_SHARE_QTY3 NUMBER ,
         VENDOR_SHARE_QTY4 NUMBER ,
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
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION QTY2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DIST_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NODE_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NON_ADJUSTED_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER;

END RP_FT_ST_LI_DIST_COMPANY;

/



CREATE or REPLACE PACKAGE BODY RP_FT_ST_LI_DIST_COMPANY
IS

   FUNCTION COMPANY_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.COMPANY_STREAM_ITEM_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END COMPANY_STREAM_ITEM_ID;
   FUNCTION FT_ST_TRANSACTION_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.FT_ST_TRANSACTION_NO      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END FT_ST_TRANSACTION_NO;
   FUNCTION QTY1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.QTY1      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END QTY1;
   FUNCTION TEXT_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.TEXT_3      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.TEXT_4      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VENDOR_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VENDOR_SHARE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VENDOR_SHARE;
   FUNCTION VENDOR_SHARE_QTY3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VENDOR_SHARE_QTY3      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VENDOR_SHARE_QTY3;
   FUNCTION APPROVAL_BY(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.APPROVAL_BY      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.APPROVAL_STATE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_5      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VENDOR_SHARE_QTY2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VENDOR_SHARE_QTY2      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VENDOR_SHARE_QTY2;
   FUNCTION FT_ST_LINE_ITEM_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.FT_ST_LINE_ITEM_NO      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END FT_ST_LINE_ITEM_NO;
   FUNCTION FT_ST_LI_DIST_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.FT_ST_LI_DIST_NO      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END FT_ST_LI_DIST_NO;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.NEXT_DAYTIME      (
         P_FT_ST_LI_DIST_COMPANY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.OBJECT_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.PREV_EQUAL_DAYTIME      (
         P_FT_ST_LI_DIST_COMPANY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRICING_TOTAL(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.PRICING_TOTAL      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END PRICING_TOTAL;
   FUNCTION SPLIT_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.SPLIT_SHARE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END SPLIT_SHARE;
   FUNCTION VAT_RATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VAT_RATE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VAT_RATE;
   FUNCTION VENDOR_SHARE_QTY4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VENDOR_SHARE_QTY4      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VENDOR_SHARE_QTY4;
   FUNCTION ALLOC_STREAM_ITEM_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.ALLOC_STREAM_ITEM_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END ALLOC_STREAM_ITEM_ID;
   FUNCTION DATE_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DATE_3      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DATE_5      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.NEXT_EQUAL_DAYTIME      (
         P_FT_ST_LI_DIST_COMPANY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PRICING_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.PRICING_VALUE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END PRICING_VALUE;
   FUNCTION PRICING_VAT_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.PRICING_VAT_VALUE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END PRICING_VAT_VALUE;
   FUNCTION VALUE_6(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_6      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION VENDOR_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VENDOR_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VENDOR_ID;
   FUNCTION CUSTOMER_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.CUSTOMER_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END CUSTOMER_ID;
   FUNCTION CUSTOMER_SHARE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.CUSTOMER_SHARE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END CUSTOMER_SHARE;
   FUNCTION DATE_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DATE_2      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION FT_ST_DOCUMENT_NO(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.FT_ST_DOCUMENT_NO      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END FT_ST_DOCUMENT_NO;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.PREV_DAYTIME      (
         P_FT_ST_LI_DIST_COMPANY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION QTY3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.QTY3      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END QTY3;
   FUNCTION QTY4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.QTY4      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END QTY4;
   FUNCTION RECORD_STATUS(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.RECORD_STATUS      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPLIT_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.SPLIT_VALUE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END SPLIT_VALUE;
   FUNCTION VALUE_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_1      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.APPROVAL_DATE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.ROW_BY_PK      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_2      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_3      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_4      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DATE_4      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION QTY2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.QTY2      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END QTY2;
   FUNCTION REC_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.REC_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.TEXT_1      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.TEXT_2      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_7      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_9      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DATE_1      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DAYTIME      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DIST_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.DIST_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END DIST_ID;
   FUNCTION NODE_ID(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.NODE_ID      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END NODE_ID;
   FUNCTION NON_ADJUSTED_VALUE(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.NON_ADJUSTED_VALUE      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END NON_ADJUSTED_VALUE;
   FUNCTION VALUE_10(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_10      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_FT_ST_LI_DIST_COMPANY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_LI_DIST_COMPANY.VALUE_8      (
         P_FT_ST_LI_DIST_COMPANY_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FT_ST_LI_DIST_COMPANY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FT_ST_LI_DIST_COMPANY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.24.59 AM


