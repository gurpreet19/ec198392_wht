
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.32.19 AM


CREATE or REPLACE PACKAGE RP_CT_MARINE_NOTICE
IS

   FUNCTION DATE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         NOTICE_NO NUMBER ,
         DESCRIPTION VARCHAR2 (2000) ,
         IN_FORCE VARCHAR2 (1) ,
         TEXT_1 VARCHAR2 (2000) ,
         TEXT_2 VARCHAR2 (2000) ,
         TEXT_3 VARCHAR2 (2000) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         TEXT_10 VARCHAR2 (2000) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (240) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION IN_FORCE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER;

END RP_CT_MARINE_NOTICE;

/



CREATE or REPLACE PACKAGE BODY RP_CT_MARINE_NOTICE
IS

   FUNCTION DATE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_10      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DESCRIPTION      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_4      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_7      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.APPROVAL_BY      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_5      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_7      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_9      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_NOTICE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_NOTICE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_10      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_5      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_6      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_3      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_5      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_NOTICE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_6      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_2      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_NOTICE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.RECORD_STATUS      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_1      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_6      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.ROW_BY_PK      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_2      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_9      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_2      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_3      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_4      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_4      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.REC_ID      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_1      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_7      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_9      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_1      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DATE_8      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.DAYTIME      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION IN_FORCE(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.IN_FORCE      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END IN_FORCE;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_3      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.TEXT_8      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_10      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NOTICE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CT_MARINE_NOTICE.VALUE_8      (
         P_OBJECT_ID,
         P_NOTICE_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CT_MARINE_NOTICE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CT_MARINE_NOTICE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.32.29 AM


