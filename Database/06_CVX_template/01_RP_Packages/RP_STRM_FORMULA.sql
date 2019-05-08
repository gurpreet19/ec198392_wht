
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.55.20 AM


CREATE or REPLACE PACKAGE RP_STRM_FORMULA
IS

   FUNCTION APPROVAL_BY(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FORMULA_METHOD(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_FORMULA_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         FORMULA_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         FORMULA_METHOD VARCHAR2 (32) ,
         DAYTIME  DATE ,
         FORMULA VARCHAR2 (2000) ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_FORMULA_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DAYTIME(
      P_FORMULA_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FORMULA(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_STRM_FORMULA;

/



CREATE or REPLACE PACKAGE BODY RP_STRM_FORMULA
IS

   FUNCTION APPROVAL_BY(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.APPROVAL_BY      (
         P_FORMULA_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.APPROVAL_STATE      (
         P_FORMULA_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FORMULA_METHOD(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.FORMULA_METHOD      (
         P_FORMULA_NO );
         RETURN ret_value;
   END FORMULA_METHOD;
   FUNCTION NEXT_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.NEXT_DAYTIME      (
         P_FORMULA_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.OBJECT_ID      (
         P_FORMULA_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.PREV_EQUAL_DAYTIME      (
         P_FORMULA_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.COMMENTS      (
         P_FORMULA_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.NEXT_EQUAL_DAYTIME      (
         P_FORMULA_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_FORMULA_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.PREV_DAYTIME      (
         P_FORMULA_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.RECORD_STATUS      (
         P_FORMULA_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_FORMULA_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.APPROVAL_DATE      (
         P_FORMULA_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_FORMULA_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STRM_FORMULA.ROW_BY_PK      (
         P_FORMULA_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.REC_ID      (
         P_FORMULA_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DAYTIME(
      P_FORMULA_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_FORMULA.DAYTIME      (
         P_FORMULA_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION FORMULA(
      P_FORMULA_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_FORMULA.FORMULA      (
         P_FORMULA_NO );
         RETURN ret_value;
   END FORMULA;

END RP_STRM_FORMULA;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STRM_FORMULA TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.55.32 AM


