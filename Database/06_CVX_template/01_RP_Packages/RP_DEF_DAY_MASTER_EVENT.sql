
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.25.32 AM


CREATE or REPLACE PACKAGE RP_DEF_DAY_MASTER_EVENT
IS

   FUNCTION DEF_CODE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEF_CODE_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ASSET_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEFER_LEVEL_OBJECT_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEF_CODE_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_REASON(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EVENT_CATEGORY(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_SYSTEM(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION ASSET_TYPE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEF_CODE_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INCIDENT_TITLE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         INCIDENT_NO NUMBER ,
         DEFER_LEVEL_OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         INCIDENT_TITLE VARCHAR2 (2000) ,
         ASSET_TYPE VARCHAR2 (32) ,
         ASSET_ID VARCHAR2 (32) ,
         EVENT_CATEGORY VARCHAR2 (32) ,
         EVENT_REASON VARCHAR2 (32) ,
         EVENT_SYSTEM VARCHAR2 (32) ,
         ROOT_CAUSE VARCHAR2 (32) ,
         SCHEDULED VARCHAR2 (32) ,
         DEF_CODE_1 VARCHAR2 (32) ,
         DEF_CODE_2 VARCHAR2 (32) ,
         DEF_CODE_3 VARCHAR2 (32) ,
         DEF_CODE_4 VARCHAR2 (32) ,
         DEF_CODE_5 VARCHAR2 (32) ,
         STATUS VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
         TEXT_5 VARCHAR2 (32) ,
         TEXT_6 VARCHAR2 (32) ,
         TEXT_7 VARCHAR2 (32) ,
         TEXT_8 VARCHAR2 (32) ,
         TEXT_9 VARCHAR2 (32) ,
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
      P_INCIDENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULED(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DEF_CODE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ROOT_CAUSE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_DEF_DAY_MASTER_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_DEF_DAY_MASTER_EVENT
IS

   FUNCTION DEF_CODE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEF_CODE_2      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEF_CODE_2;
   FUNCTION TEXT_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_3      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_4      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_8(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_8      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION APPROVAL_BY(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.APPROVAL_BY      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.APPROVAL_STATE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DEF_CODE_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEF_CODE_5      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEF_CODE_5;
   FUNCTION STATUS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.STATUS      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION TEXT_7(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_7      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_9(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_9      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_5      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ASSET_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.ASSET_ID      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END ASSET_ID;
   FUNCTION DEFER_LEVEL_OBJECT_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEFER_LEVEL_OBJECT_ID      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEFER_LEVEL_OBJECT_ID;
   FUNCTION NEXT_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.NEXT_DAYTIME      (
         P_INCIDENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.PREV_EQUAL_DAYTIME      (
         P_INCIDENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.COMMENTS      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DEF_CODE_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEF_CODE_3      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEF_CODE_3;
   FUNCTION EVENT_REASON(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.EVENT_REASON      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END EVENT_REASON;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.NEXT_EQUAL_DAYTIME      (
         P_INCIDENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_5(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_5      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_6(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_6      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DATE_2      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.END_DATE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION EVENT_CATEGORY(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.EVENT_CATEGORY      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END EVENT_CATEGORY;
   FUNCTION EVENT_SYSTEM(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.EVENT_SYSTEM      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END EVENT_SYSTEM;
   FUNCTION PREV_DAYTIME(
      P_INCIDENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.PREV_DAYTIME      (
         P_INCIDENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.RECORD_STATUS      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_1      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.APPROVAL_DATE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ASSET_TYPE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.ASSET_TYPE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END ASSET_TYPE;
   FUNCTION DEF_CODE_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEF_CODE_4      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEF_CODE_4;
   FUNCTION INCIDENT_TITLE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.INCIDENT_TITLE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END INCIDENT_TITLE;
   FUNCTION ROW_BY_PK(
      P_INCIDENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.ROW_BY_PK      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_2      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_3      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_4      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.REC_ID      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SCHEDULED(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.SCHEDULED      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END SCHEDULED;
   FUNCTION TEXT_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_1      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_2      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_6(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.TEXT_6      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION VALUE_7(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_7      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_9      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DATE_1      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_INCIDENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DAYTIME      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DEF_CODE_1(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.DEF_CODE_1      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END DEF_CODE_1;
   FUNCTION ROOT_CAUSE(
      P_INCIDENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.ROOT_CAUSE      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END ROOT_CAUSE;
   FUNCTION VALUE_10(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_10      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_INCIDENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEF_DAY_MASTER_EVENT.VALUE_8      (
         P_INCIDENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_DEF_DAY_MASTER_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DEF_DAY_MASTER_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.25.42 AM


