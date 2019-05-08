
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.27 AM


CREATE or REPLACE PACKAGE RP_DATASET_FLOW_REPORT
IS

   FUNCTION COMMENTS(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_NO(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VERSION(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT_KEY(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RUN_NO(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION SCHEDULE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REPORT_RUNABLE(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         ID NUMBER ,
         OBJECT_ID VARCHAR2 (100) ,
         VERSION NUMBER ,
         REPORT_NO NUMBER ,
         REPORT_RUNABLE NUMBER ,
         COMMENTS VARCHAR2 (4000) ,
         STATUS VARCHAR2 (32) ,
         DOCUMENT_TYPE VARCHAR2 (32) ,
         DOCUMENT_KEY VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RUN_NO NUMBER ,
         SCHEDULE VARCHAR2 (100) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
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
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE;

END RP_DATASET_FLOW_REPORT;

/



CREATE or REPLACE PACKAGE BODY RP_DATASET_FLOW_REPORT
IS

   FUNCTION COMMENTS(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.COMMENTS      (
         P_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DOCUMENT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DOCUMENT_TYPE      (
         P_ID );
         RETURN ret_value;
   END DOCUMENT_TYPE;
   FUNCTION REPORT_NO(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REPORT_NO      (
         P_ID );
         RETURN ret_value;
   END REPORT_NO;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.TEXT_3      (
         P_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VERSION(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VERSION      (
         P_ID );
         RETURN ret_value;
   END VERSION;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.APPROVAL_BY      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.APPROVAL_STATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DOCUMENT_KEY(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DOCUMENT_KEY      (
         P_ID );
         RETURN ret_value;
   END DOCUMENT_KEY;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REF_OBJECT_ID_4      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION RUN_NO(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.RUN_NO      (
         P_ID );
         RETURN ret_value;
   END RUN_NO;
   FUNCTION SCHEDULE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.SCHEDULE      (
         P_ID );
         RETURN ret_value;
   END SCHEDULE;
   FUNCTION STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.STATUS      (
         P_ID );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VALUE_5      (
         P_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.NEXT_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.OBJECT_ID      (
         P_ID );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.PREV_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION REPORT_RUNABLE(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REPORT_RUNABLE      (
         P_ID );
         RETURN ret_value;
   END REPORT_RUNABLE;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DATE_3      (
         P_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DATE_5      (
         P_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.NEXT_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REF_OBJECT_ID_2      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REF_OBJECT_ID_3      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.TEXT_1      (
         P_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DATE_2      (
         P_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.PREV_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.RECORD_STATUS      (
         P_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REF_OBJECT_ID_5      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VALUE_1      (
         P_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.APPROVAL_DATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REF_OBJECT_ID_1      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.ROW_BY_PK      (
         P_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.TEXT_2      (
         P_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.TEXT_4      (
         P_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.TEXT_5      (
         P_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VALUE_2      (
         P_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VALUE_3      (
         P_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.VALUE_4      (
         P_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DATE_4      (
         P_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.REC_ID      (
         P_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DATE_1      (
         P_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_REPORT.DAYTIME      (
         P_ID );
         RETURN ret_value;
   END DAYTIME;

END RP_DATASET_FLOW_REPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DATASET_FLOW_REPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.36 AM


