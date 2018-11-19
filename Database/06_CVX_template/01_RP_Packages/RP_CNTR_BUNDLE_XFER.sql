
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.41.07 AM


CREATE or REPLACE PACKAGE RP_CNTR_BUNDLE_XFER
IS

   FUNCTION BUNDLE_TYPE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COUNTERPARTY_CNTR_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_5(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         XFER_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         COUNTERPARTY_CNTR_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         BUNDLE_TYPE VARCHAR2 (32) ,
         XFER_TYPE VARCHAR2 (32) ,
         XFER_STATUS VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
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
      P_XFER_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION XFER_TYPE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_XFER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION XFER_STATUS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_CNTR_BUNDLE_XFER;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_BUNDLE_XFER
IS

   FUNCTION BUNDLE_TYPE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.BUNDLE_TYPE      (
         P_XFER_NO );
         RETURN ret_value;
   END BUNDLE_TYPE;
   FUNCTION TEXT_3(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.TEXT_3      (
         P_XFER_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.TEXT_4      (
         P_XFER_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.APPROVAL_BY      (
         P_XFER_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.APPROVAL_STATE      (
         P_XFER_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.VALUE_5      (
         P_XFER_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COUNTERPARTY_CNTR_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.COUNTERPARTY_CNTR_ID      (
         P_XFER_NO );
         RETURN ret_value;
   END COUNTERPARTY_CNTR_ID;
   FUNCTION NEXT_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.NEXT_DAYTIME      (
         P_XFER_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.OBJECT_ID      (
         P_XFER_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.PREV_EQUAL_DAYTIME      (
         P_XFER_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_5(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.TEXT_5      (
         P_XFER_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION COMMENTS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.COMMENTS      (
         P_XFER_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.DATE_3      (
         P_XFER_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.NEXT_EQUAL_DAYTIME      (
         P_XFER_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.TEXT_1      (
         P_XFER_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.DATE_2      (
         P_XFER_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.END_DATE      (
         P_XFER_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_XFER_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.PREV_DAYTIME      (
         P_XFER_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.RECORD_STATUS      (
         P_XFER_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.VALUE_1      (
         P_XFER_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.APPROVAL_DATE      (
         P_XFER_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_XFER_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.ROW_BY_PK      (
         P_XFER_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.TEXT_2      (
         P_XFER_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_2(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.VALUE_2      (
         P_XFER_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.VALUE_3      (
         P_XFER_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_XFER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.VALUE_4      (
         P_XFER_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.REC_ID      (
         P_XFER_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION XFER_TYPE(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.XFER_TYPE      (
         P_XFER_NO );
         RETURN ret_value;
   END XFER_TYPE;
   FUNCTION DATE_1(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.DATE_1      (
         P_XFER_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_XFER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.DAYTIME      (
         P_XFER_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION XFER_STATUS(
      P_XFER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER.XFER_STATUS      (
         P_XFER_NO );
         RETURN ret_value;
   END XFER_STATUS;

END RP_CNTR_BUNDLE_XFER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_BUNDLE_XFER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.41.14 AM


