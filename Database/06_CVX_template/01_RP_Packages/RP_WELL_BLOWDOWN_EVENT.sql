
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.11.58 AM


CREATE or REPLACE PACKAGE RP_WELL_BLOWDOWN_EVENT
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BLOWDOWN_REASON(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHUT_IN_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXECUTOR_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EXECUTOR_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         EVENT_NO NUMBER ,
         DAYTIME  DATE ,
         END_DAYTIME  DATE ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         BLOWDOWN_FREQ VARCHAR2 (32) ,
         BLOWDOWN_REASON VARCHAR2 (32) ,
         SHUT_IN_PRESS NUMBER ,
         EXECUTOR_1 VARCHAR2 (200) ,
         EXECUTOR_2 VARCHAR2 (200) ,
         EXECUTOR_3 VARCHAR2 (200) ,
         COMMENTS VARCHAR2 (2000) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
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
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BLOWDOWN_FREQ(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EXECUTOR_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;

END RP_WELL_BLOWDOWN_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_BLOWDOWN_EVENT
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.TEXT_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.TEXT_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.APPROVAL_BY      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.APPROVAL_STATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BLOWDOWN_REASON(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.BLOWDOWN_REASON      (
         P_EVENT_NO );
         RETURN ret_value;
   END BLOWDOWN_REASON;
   FUNCTION SHUT_IN_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.SHUT_IN_PRESS      (
         P_EVENT_NO );
         RETURN ret_value;
   END SHUT_IN_PRESS;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.VALUE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION EXECUTOR_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.EXECUTOR_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END EXECUTOR_3;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.NEXT_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.COMMENTS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DATE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DATE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION END_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.END_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.NEXT_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DATE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.PREV_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.RECORD_STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.START_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END START_DATE;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.VALUE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.APPROVAL_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION EXECUTOR_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.EXECUTOR_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END EXECUTOR_2;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.ROW_BY_PK      (
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.TEXT_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.VALUE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.VALUE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.VALUE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BLOWDOWN_FREQ(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.BLOWDOWN_FREQ      (
         P_EVENT_NO );
         RETURN ret_value;
   END BLOWDOWN_FREQ;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DATE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION EXECUTOR_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.EXECUTOR_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END EXECUTOR_1;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.REC_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.TEXT_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.TEXT_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DATE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_EVENT.DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;

END RP_WELL_BLOWDOWN_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_BLOWDOWN_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.12.06 AM


