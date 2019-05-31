
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.07.57 AM


CREATE or REPLACE PACKAGE RP_CARGO_ANALYSIS
IS

   FUNCTION SAMPLING_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SEAL_NAME_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OFFICIAL_IND(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VERIFIED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ENTERED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LAB_REPORT_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LIFTING_EVENT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRODUCT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION SAMPLE_ORIGIN(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARGO_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SERIAL_NUMBER(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CYLINDER_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         CARGO_NO NUMBER ,
         DAYTIME  DATE ,
         PRODUCT_ID VARCHAR2 (32) ,
         LIFTING_EVENT VARCHAR2 (32) ,
         SAMPLING_METHOD VARCHAR2 (32) ,
         ANALYSIS_TYPE VARCHAR2 (32) ,
         SERIAL_NUMBER NUMBER ,
         SAMPLE_ORIGIN VARCHAR2 (32) ,
         LAB_REPORT_NO VARCHAR2 (64) ,
         CYLINDER_NO VARCHAR2 (64) ,
         SEAL_NAME_1 VARCHAR2 (64) ,
         SEAL_NAME_2 VARCHAR2 (64) ,
         ENTERED_BY VARCHAR2 (30) ,
         VERIFIED_BY VARCHAR2 (30) ,
         APPROVED_BY VARCHAR2 (30) ,
         COMMENTS VARCHAR2 (2000) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         OFFICIAL_IND VARCHAR2 (1) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240)  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SEAL_NAME_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;

END RP_CARGO_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_ANALYSIS
IS

   FUNCTION SAMPLING_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.SAMPLING_METHOD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SAMPLING_METHOD;
   FUNCTION SEAL_NAME_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.SEAL_NAME_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SEAL_NAME_2;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.APPROVAL_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.APPROVAL_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION OFFICIAL_IND(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.OFFICIAL_IND      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END OFFICIAL_IND;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VERIFIED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VERIFIED_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VERIFIED_BY;
   FUNCTION ENTERED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.ENTERED_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ENTERED_BY;
   FUNCTION LAB_REPORT_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.LAB_REPORT_NO      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END LAB_REPORT_NO;
   FUNCTION LIFTING_EVENT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.LIFTING_EVENT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END LIFTING_EVENT;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.NEXT_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.PREV_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRODUCT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.PRODUCT_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.COMMENTS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DATE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DATE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.NEXT_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION SAMPLE_ORIGIN(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.SAMPLE_ORIGIN      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SAMPLE_ORIGIN;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.ANALYSIS_TYPE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_TYPE;
   FUNCTION APPROVED_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.APPROVED_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVED_BY;
   FUNCTION CARGO_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.CARGO_NO      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CARGO_NO;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DATE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.PREV_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.RECORD_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SERIAL_NUMBER(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.SERIAL_NUMBER      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SERIAL_NUMBER;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.APPROVAL_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CYLINDER_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.CYLINDER_NO      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CYLINDER_NO;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.ROW_BY_PK      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SEAL_NAME_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.SEAL_NAME_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SEAL_NAME_1;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DATE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.REC_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DATE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.TEXT_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_ANALYSIS.VALUE_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.08.08 AM


