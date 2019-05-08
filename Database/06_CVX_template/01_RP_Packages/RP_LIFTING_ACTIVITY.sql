
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.13.05 AM


CREATE or REPLACE PACKAGE RP_LIFTING_ACTIVITY
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FROM_DAYTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION EVENT_NO(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         ACTIVITY_CODE VARCHAR2 (32) ,
         RUN_NO NUMBER ,
         EVENT_NO NUMBER ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         COMMENTS VARCHAR2 (2000) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         LIFTING_EVENT VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TO_DAYTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER;

END RP_LIFTING_ACTIVITY;

/



CREATE or REPLACE PACKAGE BODY RP_LIFTING_ACTIVITY
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.TEXT_3      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.TEXT_4      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.APPROVAL_BY      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.APPROVAL_STATE      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FROM_DAYTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.FROM_DAYTIME      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END FROM_DAYTIME;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_5      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.COMMENTS      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.DATE_3      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.DATE_5      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END DATE_5;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_6      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.DATE_2      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.RECORD_STATUS      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_1      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.APPROVAL_DATE      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION EVENT_NO(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.EVENT_NO      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END EVENT_NO;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.ROW_BY_PK      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TO_DAYTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.TO_DAYTIME      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END TO_DAYTIME;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_2      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_3      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_4      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.DATE_4      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.REC_ID      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.TEXT_1      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.TEXT_2      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_7      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_9      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.DATE_1      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_10      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_CODE IN VARCHAR2,
      P_RUN_NO IN NUMBER,
      P_LIFTING_EVENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFTING_ACTIVITY.VALUE_8      (
         P_CARGO_NO,
         P_ACTIVITY_CODE,
         P_RUN_NO,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFTING_ACTIVITY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFTING_ACTIVITY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.13.11 AM


