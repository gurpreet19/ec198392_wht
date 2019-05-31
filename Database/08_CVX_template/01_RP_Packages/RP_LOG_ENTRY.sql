
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.08.53 AM


CREATE or REPLACE PACKAGE RP_LOG_ENTRY
IS

   FUNCTION TEXT_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION LOG_ENTRY_COMMENT(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ARCHIVED_IND(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION USER_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION BF_CODE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         USER_ID VARCHAR2 (32) ,
         ALARM_IND VARCHAR2 (1) ,
         ARCHIVED_IND VARCHAR2 (1) ,
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
         REC_ID VARCHAR2 (32) ,
         BF_CODE VARCHAR2 (32) ,
         LOG_ENTRY_COMMENT VARCHAR2 (2000) ,
         LOG_ENTRY_SEQ NUMBER  );
   FUNCTION ROW_BY_PK(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ALARM_IND(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_LOG_ENTRY;

/



CREATE or REPLACE PACKAGE BODY RP_LOG_ENTRY
IS

   FUNCTION TEXT_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.TEXT_3      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.TEXT_4      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.APPROVAL_BY      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.APPROVAL_STATE      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_5      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION LOG_ENTRY_COMMENT(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.LOG_ENTRY_COMMENT      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END LOG_ENTRY_COMMENT;
   FUNCTION NEXT_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.NEXT_DAYTIME      (
         P_LOG_ENTRY_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.OBJECT_ID      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.PREV_EQUAL_DAYTIME      (
         P_LOG_ENTRY_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION ARCHIVED_IND(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.ARCHIVED_IND      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END ARCHIVED_IND;
   FUNCTION DATE_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.DATE_3      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.NEXT_EQUAL_DAYTIME      (
         P_LOG_ENTRY_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION USER_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.USER_ID      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END USER_ID;
   FUNCTION VALUE_6(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_6      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.DATE_2      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.PREV_DAYTIME      (
         P_LOG_ENTRY_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.RECORD_STATUS      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_1      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.APPROVAL_DATE      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION BF_CODE(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.BF_CODE      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END BF_CODE;
   FUNCTION ROW_BY_PK(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LOG_ENTRY.ROW_BY_PK      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_2      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_3      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_4      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.DATE_4      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.REC_ID      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.TEXT_1      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.TEXT_2      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_7      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_9      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ALARM_IND(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LOG_ENTRY.ALARM_IND      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END ALARM_IND;
   FUNCTION DATE_1(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.DATE_1      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LOG_ENTRY.DAYTIME      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION VALUE_10(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_10      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_LOG_ENTRY_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LOG_ENTRY.VALUE_8      (
         P_LOG_ENTRY_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_LOG_ENTRY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LOG_ENTRY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.09.01 AM


