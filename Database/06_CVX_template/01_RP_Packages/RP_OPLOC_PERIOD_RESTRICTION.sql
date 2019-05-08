
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.35.06 AM


CREATE or REPLACE PACKAGE RP_OPLOC_PERIOD_RESTRICTION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION RESTRICTED_CAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION RESTRICTION_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         RESTRICTED_CAPACITY NUMBER ,
         RESTRICTION_TYPE VARCHAR2 (32) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;

END RP_OPLOC_PERIOD_RESTRICTION;

/



CREATE or REPLACE PACKAGE BODY RP_OPLOC_PERIOD_RESTRICTION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_3      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RESTRICTED_CAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.RESTRICTED_CAPACITY      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END RESTRICTED_CAPACITY;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_5      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_7      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_8      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.COMMENTS      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.DATE_3      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.DATE_5      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_1      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_6      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_9      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_6      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.DATE_2      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.END_DATE      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION RESTRICTION_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.RESTRICTION_TYPE      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END RESTRICTION_TYPE;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_1      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_2      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_4      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_5      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_2      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_3      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_4      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.DATE_4      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.REC_ID      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_7      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_9      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.DATE_1      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.TEXT_10      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_10      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPLOC_PERIOD_RESTRICTION.VALUE_8      (
         P_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END VALUE_8;

END RP_OPLOC_PERIOD_RESTRICTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OPLOC_PERIOD_RESTRICTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.35.17 AM


