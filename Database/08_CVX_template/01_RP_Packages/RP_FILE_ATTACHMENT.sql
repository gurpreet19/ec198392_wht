
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.30.31 AM


CREATE or REPLACE PACKAGE RP_FILE_ATTACHMENT
IS

   FUNCTION TEXT_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CLASS_NAME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FILE_CONTENT(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN BLOB;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_REF_ID(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ATTACHMENT_NO NUMBER ,
         CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         OBJECT_REF_ID VARCHAR2 (32) ,
         REF_NO NUMBER ,
         FILE_NAME VARCHAR2 (240) ,
         FILE_CONTENT  BLOB ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_ATTACHMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FILE_NAME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_NO(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_FILE_ATTACHMENT;

/



CREATE or REPLACE PACKAGE BODY RP_FILE_ATTACHMENT
IS

   FUNCTION TEXT_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_3      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.APPROVAL_BY      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.APPROVAL_STATE      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.VALUE_5      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.NEXT_DAYTIME      (
         P_ATTACHMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.PREV_EQUAL_DAYTIME      (
         P_ATTACHMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_7      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_8      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION CLASS_NAME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.CLASS_NAME      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.COMMENTS      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DATE_3      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DATE_5      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION FILE_CONTENT(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.FILE_CONTENT      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END FILE_CONTENT;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.NEXT_EQUAL_DAYTIME      (
         P_ATTACHMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OBJECT_REF_ID(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.OBJECT_REF_ID      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END OBJECT_REF_ID;
   FUNCTION TEXT_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_1      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_6      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_9      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DATE_2      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_ATTACHMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.PREV_DAYTIME      (
         P_ATTACHMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.RECORD_STATUS      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.VALUE_1      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.APPROVAL_DATE      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.ROW_BY_PK      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_2      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_4      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_5      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.VALUE_2      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.VALUE_3      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.VALUE_4      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DATE_4      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.REC_ID      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DATE_1      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.DAYTIME      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION FILE_NAME(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.FILE_NAME      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END FILE_NAME;
   FUNCTION REF_NO(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.REF_NO      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END REF_NO;
   FUNCTION TEXT_10(
      P_ATTACHMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FILE_ATTACHMENT.TEXT_10      (
         P_ATTACHMENT_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_FILE_ATTACHMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FILE_ATTACHMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.30.39 AM


