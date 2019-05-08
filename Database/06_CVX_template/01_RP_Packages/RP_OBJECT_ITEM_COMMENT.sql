
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.50.22 AM


CREATE or REPLACE PACKAGE RP_OBJECT_ITEM_COMMENT
IS

   FUNCTION COMMENT_EVENT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_10(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DURATION(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_7(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION CLASS_NAME(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS_2(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COPY_FORWARD_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PLANNED_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION OBJECT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         COMMENT_ID NUMBER ,
         OBJECT_TYPE VARCHAR2 (24) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         PRODUCTION_DAY  DATE ,
         CLASS_NAME VARCHAR2 (24) ,
         DURATION NUMBER ,
         PLANNED_IND VARCHAR2 (1) ,
         COMMENT_EVENT_TYPE VARCHAR2 (32) ,
         COMMENT_TYPE VARCHAR2 (32) ,
         REPORT_IND VARCHAR2 (1) ,
         COMMENTS VARCHAR2 (2000) ,
         COMMENTS_2 VARCHAR2 (2000) ,
         COMMENTS_VALUE NUMBER ,
         COPY_FORWARD_IND VARCHAR2 (1) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE  );
   FUNCTION ROW_BY_PK(
      P_COMMENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS_VALUE(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REPORT_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER;

END RP_OBJECT_ITEM_COMMENT;

/



CREATE or REPLACE PACKAGE BODY RP_OBJECT_ITEM_COMMENT
IS

   FUNCTION COMMENT_EVENT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COMMENT_EVENT_TYPE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COMMENT_EVENT_TYPE;
   FUNCTION DATE_10(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_10      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_10;
   FUNCTION TEXT_3(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.TEXT_3      (
         P_COMMENT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.TEXT_4      (
         P_COMMENT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.APPROVAL_BY      (
         P_COMMENT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.APPROVAL_STATE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DURATION(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DURATION      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DURATION;
   FUNCTION VALUE_5(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_5      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMENT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COMMENT_TYPE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COMMENT_TYPE;
   FUNCTION DATE_7(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_7      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_9      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.NEXT_DAYTIME      (
         P_COMMENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.OBJECT_ID      (
         P_COMMENT_ID );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.PREV_EQUAL_DAYTIME      (
         P_COMMENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION CLASS_NAME(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.CLASS_NAME      (
         P_COMMENT_ID );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COMMENTS      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_3      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_5      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.NEXT_EQUAL_DAYTIME      (
         P_COMMENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_6      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMMENTS_2(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COMMENTS_2      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COMMENTS_2;
   FUNCTION COPY_FORWARD_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COPY_FORWARD_IND      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COPY_FORWARD_IND;
   FUNCTION DATE_2(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_2      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PLANNED_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.PLANNED_IND      (
         P_COMMENT_ID );
         RETURN ret_value;
   END PLANNED_IND;
   FUNCTION PREV_DAYTIME(
      P_COMMENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.PREV_DAYTIME      (
         P_COMMENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.RECORD_STATUS      (
         P_COMMENT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_1      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.APPROVAL_DATE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_6      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_6;
   FUNCTION OBJECT_TYPE(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.OBJECT_TYPE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION ROW_BY_PK(
      P_COMMENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.ROW_BY_PK      (
         P_COMMENT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_2      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_3      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_4      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION COMMENTS_VALUE(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.COMMENTS_VALUE      (
         P_COMMENT_ID );
         RETURN ret_value;
   END COMMENTS_VALUE;
   FUNCTION DATE_4(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_4      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.REC_ID      (
         P_COMMENT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.TEXT_1      (
         P_COMMENT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.TEXT_2      (
         P_COMMENT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_7      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_9      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_1      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DATE_8      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.DAYTIME      (
         P_COMMENT_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PRODUCTION_DAY(
      P_COMMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.PRODUCTION_DAY      (
         P_COMMENT_ID );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION REPORT_IND(
      P_COMMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.REPORT_IND      (
         P_COMMENT_ID );
         RETURN ret_value;
   END REPORT_IND;
   FUNCTION VALUE_10(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_10      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_COMMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_ITEM_COMMENT.VALUE_8      (
         P_COMMENT_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_OBJECT_ITEM_COMMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJECT_ITEM_COMMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.50.43 AM


