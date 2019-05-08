
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.07.58 AM


CREATE or REPLACE PACKAGE RP_PROSTY_CODES
IS

   FUNCTION DESCRIPTION(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION IS_ACTIVE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION IS_SYSTEM_CODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CODE_TEXT(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION IS_DEFAULT(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ALT_CODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CODE_TYPE VARCHAR2 (32) ,
         CODE VARCHAR2 (32) ,
         CODE_TEXT VARCHAR2 (240) ,
         ALT_CODE VARCHAR2 (240) ,
         IS_SYSTEM_CODE VARCHAR2 (1) ,
         IS_DEFAULT VARCHAR2 (1) ,
         IS_ACTIVE VARCHAR2 (1) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (2000) ,
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
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_PROSTY_CODES;

/



CREATE or REPLACE PACKAGE BODY RP_PROSTY_CODES
IS

   FUNCTION DESCRIPTION(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.DESCRIPTION      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION IS_ACTIVE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.IS_ACTIVE      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END IS_ACTIVE;
   FUNCTION IS_SYSTEM_CODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.IS_SYSTEM_CODE      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END IS_SYSTEM_CODE;
   FUNCTION SORT_ORDER(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PROSTY_CODES.SORT_ORDER      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_3      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.APPROVAL_BY      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.APPROVAL_STATE      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CODE_TEXT(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.CODE_TEXT      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END CODE_TEXT;
   FUNCTION IS_DEFAULT(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.IS_DEFAULT      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END IS_DEFAULT;
   FUNCTION ALT_CODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.ALT_CODE      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END ALT_CODE;
   FUNCTION TEXT_7(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_7      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_8      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION TEXT_1(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_1      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_6      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_9      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION RECORD_STATUS(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.RECORD_STATUS      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PROSTY_CODES.APPROVAL_DATE      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PROSTY_CODES.ROW_BY_PK      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_2      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_4      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_5      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION REC_ID(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.REC_ID      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_10(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PROSTY_CODES.TEXT_10      (
         P_CODE,
         P_CODE_TYPE );
         RETURN ret_value;
   END TEXT_10;

END RP_PROSTY_CODES;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PROSTY_CODES TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.08.06 AM


