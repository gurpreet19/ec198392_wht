
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.05.57 AM


CREATE or REPLACE PACKAGE RP_REPORT
IS

   FUNCTION ARCHIVE_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_RUNABLE_NAME(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SEND_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FORMAT_CODE(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXPORT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REPORT_SET_REP_REF_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SCHEDULE_DAYTIME(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION SCHEDULE_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ACCEPT_STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION ERROR_MSG(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRINT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REPORT_RUNABLE_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPORT_NO NUMBER ,
         DAYTIME  DATE ,
         RUN_DATE  DATE ,
         FORMAT_CODE VARCHAR2 (32) ,
         REPORT_RUNABLE_NO NUMBER ,
         REPORT_CONTENT  BLOB ,
         STATUS VARCHAR2 (32) ,
         SEND_IND VARCHAR2 (1) ,
         SEND_DATE  DATE ,
         GZIP_IND VARCHAR2 (1) ,
         PRINTER_PATH VARCHAR2 (2000) ,
         PRINT_DATE  DATE ,
         ARCHIVE_IND VARCHAR2 (1) ,
         REPORT_RUNABLE_NAME VARCHAR2 (240) ,
         EXPORT_DATE  DATE ,
         EXPORT_PATH VARCHAR2 (2000) ,
         REPORT_DATE  DATE ,
         ACCEPT_STATUS VARCHAR2 (1) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (240) ,
         ERROR_MSG VARCHAR2 (2000) ,
         REPORT_SET_REP_REF_NO NUMBER ,
         REPORT_SET_SEQ_NO NUMBER ,
         SCHEDULE_DAYTIME  DATE ,
         SCHEDULE_NO NUMBER ,
         USER_COMMENT VARCHAR2 (240)  );
   FUNCTION ROW_BY_PK(
      P_REPORT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_CONTENT(
      P_REPORT_NO IN NUMBER)
      RETURN BLOB;
   FUNCTION REPORT_SET_SEQ_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SEND_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USER_COMMENT(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EXPORT_PATH(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GZIP_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRINTER_PATH(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RUN_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_REPORT;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT
IS

   FUNCTION ARCHIVE_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.ARCHIVE_IND      (
         P_REPORT_NO );
         RETURN ret_value;
   END ARCHIVE_IND;
   FUNCTION REPORT_RUNABLE_NAME(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.REPORT_RUNABLE_NAME      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_RUNABLE_NAME;
   FUNCTION SEND_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.SEND_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END SEND_DATE;
   FUNCTION TEXT_3(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_3      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT.APPROVAL_BY      (
         P_REPORT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.APPROVAL_STATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FORMAT_CODE(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.FORMAT_CODE      (
         P_REPORT_NO );
         RETURN ret_value;
   END FORMAT_CODE;
   FUNCTION REF_OBJECT_ID_4(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REF_OBJECT_ID_4      (
         P_REPORT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.STATUS      (
         P_REPORT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.VALUE_5      (
         P_REPORT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION EXPORT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.EXPORT_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END EXPORT_DATE;
   FUNCTION NEXT_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.NEXT_DAYTIME      (
         P_REPORT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.PREV_EQUAL_DAYTIME      (
         P_REPORT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION REPORT_SET_REP_REF_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.REPORT_SET_REP_REF_NO      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_SET_REP_REF_NO;
   FUNCTION SCHEDULE_DAYTIME(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.SCHEDULE_DAYTIME      (
         P_REPORT_NO );
         RETURN ret_value;
   END SCHEDULE_DAYTIME;
   FUNCTION SCHEDULE_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.SCHEDULE_NO      (
         P_REPORT_NO );
         RETURN ret_value;
   END SCHEDULE_NO;
   FUNCTION TEXT_7(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_7      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_8      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION ACCEPT_STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.ACCEPT_STATUS      (
         P_REPORT_NO );
         RETURN ret_value;
   END ACCEPT_STATUS;
   FUNCTION COMMENTS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.COMMENTS      (
         P_REPORT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DATE_3      (
         P_REPORT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DATE_5      (
         P_REPORT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION ERROR_MSG(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT.ERROR_MSG      (
         P_REPORT_NO );
         RETURN ret_value;
   END ERROR_MSG;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.NEXT_EQUAL_DAYTIME      (
         P_REPORT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PRINT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.PRINT_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END PRINT_DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REF_OBJECT_ID_2      (
         P_REPORT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REF_OBJECT_ID_3      (
         P_REPORT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_1      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_6      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_9      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DATE_2      (
         P_REPORT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_REPORT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.PREV_DAYTIME      (
         P_REPORT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.RECORD_STATUS      (
         P_REPORT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REF_OBJECT_ID_5      (
         P_REPORT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.VALUE_1      (
         P_REPORT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.APPROVAL_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REF_OBJECT_ID_1      (
         P_REPORT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION REPORT_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.REPORT_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_DATE;
   FUNCTION REPORT_RUNABLE_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.REPORT_RUNABLE_NO      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_RUNABLE_NO;
   FUNCTION ROW_BY_PK(
      P_REPORT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT.ROW_BY_PK      (
         P_REPORT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_2      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_4      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_5      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.VALUE_2      (
         P_REPORT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.VALUE_3      (
         P_REPORT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.VALUE_4      (
         P_REPORT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DATE_4      (
         P_REPORT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT.REC_ID      (
         P_REPORT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REPORT_CONTENT(
      P_REPORT_NO IN NUMBER)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_REPORT.REPORT_CONTENT      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_CONTENT;
   FUNCTION REPORT_SET_SEQ_NO(
      P_REPORT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT.REPORT_SET_SEQ_NO      (
         P_REPORT_NO );
         RETURN ret_value;
   END REPORT_SET_SEQ_NO;
   FUNCTION SEND_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.SEND_IND      (
         P_REPORT_NO );
         RETURN ret_value;
   END SEND_IND;
   FUNCTION USER_COMMENT(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.USER_COMMENT      (
         P_REPORT_NO );
         RETURN ret_value;
   END USER_COMMENT;
   FUNCTION DATE_1(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DATE_1      (
         P_REPORT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.DAYTIME      (
         P_REPORT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION EXPORT_PATH(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT.EXPORT_PATH      (
         P_REPORT_NO );
         RETURN ret_value;
   END EXPORT_PATH;
   FUNCTION GZIP_IND(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT.GZIP_IND      (
         P_REPORT_NO );
         RETURN ret_value;
   END GZIP_IND;
   FUNCTION PRINTER_PATH(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT.PRINTER_PATH      (
         P_REPORT_NO );
         RETURN ret_value;
   END PRINTER_PATH;
   FUNCTION RUN_DATE(
      P_REPORT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT.RUN_DATE      (
         P_REPORT_NO );
         RETURN ret_value;
   END RUN_DATE;
   FUNCTION TEXT_10(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT.TEXT_10      (
         P_REPORT_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_REPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.06.09 AM


