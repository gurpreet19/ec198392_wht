
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.07.23 AM


CREATE or REPLACE PACKAGE RP_MESSAGE_WORKFLOW_ALERT
IS

   FUNCTION TEXT_3(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRIGGERED_BY(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECEIVED_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REVISION(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STATUS(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ORIGINAL_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECEIVER_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SENDER_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUBJECT(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ALERT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         ORIGINAL_DATE  DATE ,
         DIRECTION VARCHAR2 (32) ,
         SUBJECT VARCHAR2 (240) ,
         TRIGGERED_BY VARCHAR2 (240) ,
         RECEIVED_DATE  DATE ,
         STATUS VARCHAR2 (32) ,
         VALID_FROM_DATE  DATE ,
         VALID_TO_DATE  DATE ,
         SENDER_ID VARCHAR2 (32) ,
         RECEIVER_ID VARCHAR2 (32) ,
         REVISION NUMBER ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ALERT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_TO_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_7(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_ALERT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DIRECTION(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER;

END RP_MESSAGE_WORKFLOW_ALERT;

/



CREATE or REPLACE PACKAGE BODY RP_MESSAGE_WORKFLOW_ALERT
IS

   FUNCTION TEXT_3(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.TEXT_3      (
         P_ALERT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.TEXT_4      (
         P_ALERT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TRIGGERED_BY(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.TRIGGERED_BY      (
         P_ALERT_NO );
         RETURN ret_value;
   END TRIGGERED_BY;
   FUNCTION APPROVAL_BY(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.APPROVAL_BY      (
         P_ALERT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.APPROVAL_STATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECEIVED_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.RECEIVED_DATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END RECEIVED_DATE;
   FUNCTION REVISION(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.REVISION      (
         P_ALERT_NO );
         RETURN ret_value;
   END REVISION;
   FUNCTION STATUS(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.STATUS      (
         P_ALERT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_5      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.NEXT_DAYTIME      (
         P_ALERT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.OBJECT_ID      (
         P_ALERT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.PREV_EQUAL_DAYTIME      (
         P_ALERT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.NEXT_EQUAL_DAYTIME      (
         P_ALERT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION ORIGINAL_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.ORIGINAL_DATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END ORIGINAL_DATE;
   FUNCTION RECEIVER_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.RECEIVER_ID      (
         P_ALERT_NO );
         RETURN ret_value;
   END RECEIVER_ID;
   FUNCTION SENDER_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.SENDER_ID      (
         P_ALERT_NO );
         RETURN ret_value;
   END SENDER_ID;
   FUNCTION SUBJECT(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.SUBJECT      (
         P_ALERT_NO );
         RETURN ret_value;
   END SUBJECT;
   FUNCTION VALUE_6(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_6      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PREV_DAYTIME(
      P_ALERT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.PREV_DAYTIME      (
         P_ALERT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.RECORD_STATUS      (
         P_ALERT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_1      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.APPROVAL_DATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ALERT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.ROW_BY_PK      (
         P_ALERT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_2      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_3      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_4      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.REC_ID      (
         P_ALERT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.TEXT_1      (
         P_ALERT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.TEXT_2      (
         P_ALERT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALID_FROM_DATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALID_TO_DATE(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALID_TO_DATE      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALID_TO_DATE;
   FUNCTION VALUE_7(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_7      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_9      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_ALERT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.DAYTIME      (
         P_ALERT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DIRECTION(
      P_ALERT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.DIRECTION      (
         P_ALERT_NO );
         RETURN ret_value;
   END DIRECTION;
   FUNCTION VALUE_10(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_10      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ALERT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_WORKFLOW_ALERT.VALUE_8      (
         P_ALERT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_MESSAGE_WORKFLOW_ALERT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_MESSAGE_WORKFLOW_ALERT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.07.31 AM


