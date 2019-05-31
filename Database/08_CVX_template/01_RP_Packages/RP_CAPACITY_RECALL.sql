
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.09.52 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_RECALL
IS

   FUNCTION TEXT_3(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RELEASE_NO(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECALL_CAPACITY(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECALL_NOTE(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         RECALL_NO NUMBER ,
         RELEASE_NO NUMBER ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         RECALL_CAPACITY NUMBER ,
         RECALL_STATUS VARCHAR2 (32) ,
         RECALL_NOTE VARCHAR2 (2000) ,
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
      P_RECALL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECALL_STATUS(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;

END RP_CAPACITY_RECALL;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_RECALL
IS

   FUNCTION TEXT_3(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_3      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.APPROVAL_BY      (
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.APPROVAL_STATE      (
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_5      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.NEXT_DAYTIME      (
         P_RECALL_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.PREV_EQUAL_DAYTIME      (
         P_RECALL_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION RELEASE_NO(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.RELEASE_NO      (
         P_RECALL_NO );
         RETURN ret_value;
   END RELEASE_NO;
   FUNCTION TEXT_7(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_7      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_8      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DATE_3      (
         P_RECALL_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DATE_5      (
         P_RECALL_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.NEXT_EQUAL_DAYTIME      (
         P_RECALL_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_1      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_6      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_9      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_6      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.CONTRACT_ID      (
         P_RECALL_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DATE_2      (
         P_RECALL_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.END_DATE      (
         P_RECALL_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_RECALL_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.PREV_DAYTIME      (
         P_RECALL_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECALL_CAPACITY(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.RECALL_CAPACITY      (
         P_RECALL_NO );
         RETURN ret_value;
   END RECALL_CAPACITY;
   FUNCTION RECORD_STATUS(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.RECORD_STATUS      (
         P_RECALL_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_1      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.APPROVAL_DATE      (
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION RECALL_NOTE(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.RECALL_NOTE      (
         P_RECALL_NO );
         RETURN ret_value;
   END RECALL_NOTE;
   FUNCTION ROW_BY_PK(
      P_RECALL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.ROW_BY_PK      (
         P_RECALL_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_2      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_4      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_5      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_2      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_3      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_4      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DATE_4      (
         P_RECALL_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION RECALL_STATUS(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.RECALL_STATUS      (
         P_RECALL_NO );
         RETURN ret_value;
   END RECALL_STATUS;
   FUNCTION REC_ID(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.REC_ID      (
         P_RECALL_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_7      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_9      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DATE_1      (
         P_RECALL_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.DAYTIME      (
         P_RECALL_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.TEXT_10      (
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_10      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RECALL.VALUE_8      (
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_RECALL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_RECALL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.10.01 AM


