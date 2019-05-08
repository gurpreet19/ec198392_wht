
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.04.10 AM


CREATE or REPLACE PACKAGE RP_TANK_TAP_ANALYSIS
IS

   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         HEIGHT NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         BSW NUMBER ,
         DENSITY NUMBER ,
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
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION BSW(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2;

END RP_TANK_TAP_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_TANK_TAP_ANALYSIS
IS

   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_3      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.APPROVAL_BY      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.APPROVAL_STATE      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.VALUE_5      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_7      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_8      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DATE_3      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DATE_5      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_1      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_6      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_9      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DATE_2      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.RECORD_STATUS      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.VALUE_1      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.APPROVAL_DATE      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DENSITY      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DENSITY;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.ROW_BY_PK      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_2      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_4      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_5      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.VALUE_2      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.VALUE_3      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.VALUE_4      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BSW(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.BSW      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END BSW;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DATE_4      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.REC_ID      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.DATE_1      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_HEIGHT IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_TAP_ANALYSIS.TEXT_10      (
         P_ANALYSIS_NO,
         P_OBJECT_ID,
         P_HEIGHT );
         RETURN ret_value;
   END TEXT_10;

END RP_TANK_TAP_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TANK_TAP_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.04.37 AM


