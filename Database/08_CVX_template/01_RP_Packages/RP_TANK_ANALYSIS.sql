
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.08.34 AM


CREATE or REPLACE PACKAGE RP_TANK_ANALYSIS
IS

   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DILUENT_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TANK_BSW_OVERRIDE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BITUMEN_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TANK_DENSITY_OVERRIDE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OBJECT_CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         VALID_FROM_DATE  DATE ,
         PRODUCTION_DAY  DATE ,
         ANALYSIS_STATUS VARCHAR2 (32) ,
         TANK_BSW_OVERRIDE NUMBER ,
         TANK_DENSITY_OVERRIDE NUMBER ,
         DILUENT_DENSITY NUMBER ,
         BITUMEN_DENSITY NUMBER ,
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
         REC_ID VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (4000) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_TANK_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_TANK_ANALYSIS
IS

   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.COMMENTS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DILUENT_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DILUENT_DENSITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DILUENT_DENSITY;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.ANALYSIS_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_STATUS;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.APPROVAL_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.APPROVAL_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALUE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.NEXT_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.OBJECT_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.PREV_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TANK_BSW_OVERRIDE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TANK_BSW_OVERRIDE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TANK_BSW_OVERRIDE;
   FUNCTION TEXT_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION BITUMEN_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.BITUMEN_DENSITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END BITUMEN_DENSITY;
   FUNCTION DATE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DATE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DATE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.NEXT_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TANK_DENSITY_OVERRIDE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TANK_DENSITY_OVERRIDE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TANK_DENSITY_OVERRIDE;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UTC_DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.UTC_DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION DATE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DATE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.PREV_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.RECORD_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALUE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.APPROVAL_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION OBJECT_CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.OBJECT_CLASS_NAME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END OBJECT_CLASS_NAME;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.ROW_BY_PK      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALUE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALUE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALUE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DATE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.REC_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALID_FROM_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.VALID_FROM_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION DATE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DATE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PRODUCTION_DAY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.PRODUCTION_DAY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION TEXT_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TANK_ANALYSIS.TEXT_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_TANK_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TANK_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.09.15 AM


