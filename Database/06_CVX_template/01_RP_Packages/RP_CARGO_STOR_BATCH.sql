
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.06.28 AM


CREATE or REPLACE PACKAGE RP_CARGO_STOR_BATCH
IS

   FUNCTION TEXT_3(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BATCH_SEQ(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LIFTING_EVENT(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_NO(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_BATCH_NO NUMBER ,
         CARGO_NO NUMBER ,
         STORAGE_ID VARCHAR2 (32) ,
         LIFTING_EVENT VARCHAR2 (32) ,
         START_DATE  DATE ,
         BATCH_SEQ NUMBER ,
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
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE;
   FUNCTION STORAGE_ID(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER;

END RP_CARGO_STOR_BATCH;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_STOR_BATCH
IS

   FUNCTION TEXT_3(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.TEXT_3      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.TEXT_4      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.APPROVAL_BY      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.APPROVAL_STATE      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BATCH_SEQ(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.BATCH_SEQ      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END BATCH_SEQ;
   FUNCTION VALUE_5(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_5      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION LIFTING_EVENT(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.LIFTING_EVENT      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END LIFTING_EVENT;
   FUNCTION VALUE_6(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_6      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CARGO_NO(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.CARGO_NO      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END CARGO_NO;
   FUNCTION DATE_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.DATE_2      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.RECORD_STATUS      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.START_DATE      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END START_DATE;
   FUNCTION VALUE_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_1      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.APPROVAL_DATE      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.ROW_BY_PK      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_2      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_3      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_4      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.REC_ID      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.TEXT_1      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.TEXT_2      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_7      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_9      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.DATE_1      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION STORAGE_ID(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.STORAGE_ID      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END STORAGE_ID;
   FUNCTION VALUE_10(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_10      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_BATCH_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_STOR_BATCH.VALUE_8      (
         P_CARGO_BATCH_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_STOR_BATCH;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_STOR_BATCH TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.06.34 AM


