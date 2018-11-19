
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.45.45 AM


CREATE or REPLACE PACKAGE RP_STRM_COMPANY_SWAP
IS

   FUNCTION TEXT_3(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_SWAP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_SWAP_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SWAP_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
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
      P_SWAP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_SWAP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER;

END RP_STRM_COMPANY_SWAP;

/



CREATE or REPLACE PACKAGE BODY RP_STRM_COMPANY_SWAP
IS

   FUNCTION TEXT_3(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.TEXT_3      (
         P_SWAP_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.TEXT_4      (
         P_SWAP_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.APPROVAL_BY      (
         P_SWAP_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.APPROVAL_STATE      (
         P_SWAP_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_5      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.NEXT_DAYTIME      (
         P_SWAP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.OBJECT_ID      (
         P_SWAP_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.PREV_EQUAL_DAYTIME      (
         P_SWAP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.COMMENTS      (
         P_SWAP_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.NEXT_EQUAL_DAYTIME      (
         P_SWAP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_6      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.COMPANY_ID      (
         P_SWAP_NO );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION END_DATE(
      P_SWAP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.END_DATE      (
         P_SWAP_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_SWAP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.PREV_DAYTIME      (
         P_SWAP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.RECORD_STATUS      (
         P_SWAP_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_1      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_SWAP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.APPROVAL_DATE      (
         P_SWAP_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_SWAP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.ROW_BY_PK      (
         P_SWAP_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_2      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_3      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_4      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.REC_ID      (
         P_SWAP_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.TEXT_1      (
         P_SWAP_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_SWAP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.TEXT_2      (
         P_SWAP_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_7      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_9      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_SWAP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.DAYTIME      (
         P_SWAP_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION VALUE_10(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_10      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_SWAP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_COMPANY_SWAP.VALUE_8      (
         P_SWAP_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_STRM_COMPANY_SWAP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STRM_COMPANY_SWAP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.45.52 AM


