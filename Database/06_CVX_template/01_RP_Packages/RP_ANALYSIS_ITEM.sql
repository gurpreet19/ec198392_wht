
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.03.33 AM


CREATE or REPLACE PACKAGE RP_ANALYSIS_ITEM
IS

   FUNCTION ANALYSIS_METHOD(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ITEM_LABEL(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMPONENT_NO(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ITEM_CODE VARCHAR2 (16) ,
         ITEM_CATEGORY VARCHAR2 (32) ,
         ITEM_LABEL VARCHAR2 (100) ,
         ITEM_NAME VARCHAR2 (30) ,
         ANALYSIS_METHOD VARCHAR2 (32) ,
         COMPONENT_NO VARCHAR2 (16) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240)  );
   FUNCTION ROW_BY_PK(
      P_ITEM_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ITEM_CATEGORY(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ITEM_NAME(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_ANALYSIS_ITEM;

/



CREATE or REPLACE PACKAGE BODY RP_ANALYSIS_ITEM
IS

   FUNCTION ANALYSIS_METHOD(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.ANALYSIS_METHOD      (
         P_ITEM_CODE );
         RETURN ret_value;
   END ANALYSIS_METHOD;
   FUNCTION ITEM_LABEL(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.ITEM_LABEL      (
         P_ITEM_CODE );
         RETURN ret_value;
   END ITEM_LABEL;
   FUNCTION TEXT_3(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_3      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_4      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.APPROVAL_BY      (
         P_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.APPROVAL_STATE      (
         P_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMPONENT_NO(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.COMPONENT_NO      (
         P_ITEM_CODE );
         RETURN ret_value;
   END COMPONENT_NO;
   FUNCTION VALUE_5(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_5      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_7      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_8      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION TEXT_6(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_6      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_9      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_6      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.RECORD_STATUS      (
         P_ITEM_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_1      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.APPROVAL_DATE      (
         P_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ITEM_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.ROW_BY_PK      (
         P_ITEM_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_5      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_2      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_3      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_4      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ITEM_CATEGORY(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.ITEM_CATEGORY      (
         P_ITEM_CODE );
         RETURN ret_value;
   END ITEM_CATEGORY;
   FUNCTION REC_ID(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.REC_ID      (
         P_ITEM_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_1      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_2      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_7      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_9      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ITEM_NAME(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.ITEM_NAME      (
         P_ITEM_CODE );
         RETURN ret_value;
   END ITEM_NAME;
   FUNCTION TEXT_10(
      P_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.TEXT_10      (
         P_ITEM_CODE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_10      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ANALYSIS_ITEM.VALUE_8      (
         P_ITEM_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_ANALYSIS_ITEM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ANALYSIS_ITEM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.03.39 AM


