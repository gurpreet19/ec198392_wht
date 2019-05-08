
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.08.07 AM


CREATE or REPLACE PACKAGE RP_MESSAGE_FORMAT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION SPECIAL_CASE_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DEFAULT_EXT_FORMAT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         FORMAT_CODE VARCHAR2 (32) ,
         DEFAULT_EXT_FORMAT_IND VARCHAR2 (1) ,
         SPECIAL_CASE_IND VARCHAR2 (1) ,
         DESCRIPTION VARCHAR2 (240) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_MESSAGE_FORMAT;

/



CREATE or REPLACE PACKAGE BODY RP_MESSAGE_FORMAT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_3      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.VALUE_5      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION SPECIAL_CASE_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.SPECIAL_CASE_IND      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END SPECIAL_CASE_IND;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_7      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_8      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DATE_3      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DATE_5      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_1      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_6      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_9      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DATE_2      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.VALUE_1      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DEFAULT_EXT_FORMAT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DEFAULT_EXT_FORMAT_IND      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DEFAULT_EXT_FORMAT_IND;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DESCRIPTION      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_2      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_4      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_5      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.VALUE_2      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.VALUE_3      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.VALUE_4      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DATE_4      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.REC_ID      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.DATE_1      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORMAT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_FORMAT.TEXT_10      (
         P_OBJECT_ID,
         P_FORMAT_CODE );
         RETURN ret_value;
   END TEXT_10;

END RP_MESSAGE_FORMAT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_MESSAGE_FORMAT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.08.13 AM


