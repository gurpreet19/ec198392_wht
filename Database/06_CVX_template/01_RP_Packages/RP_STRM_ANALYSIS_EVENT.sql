
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.46.05 AM


CREATE or REPLACE PACKAGE RP_STRM_ANALYSIS_EVENT
IS

   FUNCTION PHASE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SAMPLE_PRESS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SAMPLING_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_TO_TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_TO_UTC_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CRITICAL_PRESS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CRITICAL_TEMP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GCR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SALINITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SHRINKAGE_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALID_TO_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BSW_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CNPL_MOL_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FLASH_GAS_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FLUID_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION RVP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SP_GRAV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALID_FROM_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LABORATORY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION UTC_DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CNPL_GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CNPL_SP_GRAV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION MOL_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
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
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NCVM(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         ANALYSIS_TYPE VARCHAR2 (32) ,
         SAMPLING_METHOD VARCHAR2 (32) ,
         DAYTIME_SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         VALID_FROM_DATE  DATE ,
         VALID_TO_DATE  DATE ,
         VALID_FROM_SUMMER_TIME VARCHAR2 (1) ,
         VALID_TO_SUMMER_TIME VARCHAR2 (1) ,
         ANALYSIS_STATUS VARCHAR2 (32) ,
         PHASE VARCHAR2 (32) ,
         SAMPLE_PRESS NUMBER ,
         SAMPLE_TEMP NUMBER ,
         SP_GRAV NUMBER ,
         GCV NUMBER ,
         NCV NUMBER ,
         GCVM NUMBER ,
         NCVM NUMBER ,
         GCR NUMBER ,
         MOL_WT NUMBER ,
         CNPL_MOL_WT NUMBER ,
         CRITICAL_PRESS NUMBER ,
         CRITICAL_TEMP NUMBER ,
         RVP NUMBER ,
         SALT NUMBER ,
         DENSITY NUMBER ,
         LABORATORY VARCHAR2 (240) ,
         LAB_REF_NO VARCHAR2 (240) ,
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
         SHRINKAGE_FACTOR NUMBER ,
         BSW_WT NUMBER ,
         CNPL_SP_GRAV NUMBER ,
         CNPL_DENSITY NUMBER ,
         BS_W NUMBER ,
         FLUID_STATE VARCHAR2 (32) ,
         CNPL_GCV NUMBER ,
         SULFUR_WT NUMBER ,
         VAPOUR NUMBER ,
         CNPL_API NUMBER ,
         SALINITY NUMBER ,
         FLASH_GAS_FACTOR NUMBER ,
         API NUMBER ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE ,
         VALID_FROM_TIME_ZONE VARCHAR2 (65) ,
         VALID_FROM_UTC_DATE  DATE ,
         VALID_TO_TIME_ZONE VARCHAR2 (65) ,
         VALID_TO_UTC_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SAMPLE_TEMP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LAB_REF_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SULFUR_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_FROM_UTC_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_TO_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION API(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BS_W(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CNPL_API(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CNPL_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GCVM(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION SALT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VAPOUR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;

END RP_STRM_ANALYSIS_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_STRM_ANALYSIS_EVENT
IS

   FUNCTION PHASE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.PHASE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PHASE;
   FUNCTION SAMPLE_PRESS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SAMPLE_PRESS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SAMPLE_PRESS;
   FUNCTION SAMPLING_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SAMPLING_METHOD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SAMPLING_METHOD;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.TEXT_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.TEXT_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.TIME_ZONE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION VALID_TO_TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_TO_TIME_ZONE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_TO_TIME_ZONE;
   FUNCTION VALID_TO_UTC_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_TO_UTC_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_TO_UTC_DATE;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.ANALYSIS_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_STATUS;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.APPROVAL_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.APPROVAL_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CRITICAL_PRESS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CRITICAL_PRESS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CRITICAL_PRESS;
   FUNCTION CRITICAL_TEMP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CRITICAL_TEMP      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CRITICAL_TEMP;
   FUNCTION GCR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.GCR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GCR;
   FUNCTION SALINITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SALINITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SALINITY;
   FUNCTION SHRINKAGE_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SHRINKAGE_FACTOR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SHRINKAGE_FACTOR;
   FUNCTION VALID_TO_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_TO_SUMMER_TIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_TO_SUMMER_TIME;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION BSW_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.BSW_WT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END BSW_WT;
   FUNCTION CNPL_MOL_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CNPL_MOL_WT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CNPL_MOL_WT;
   FUNCTION FLASH_GAS_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.FLASH_GAS_FACTOR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END FLASH_GAS_FACTOR;
   FUNCTION FLUID_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.FLUID_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END FLUID_STATE;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.NEXT_DAYTIME      (
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
      ret_value := EC_STRM_ANALYSIS_EVENT.OBJECT_ID      (
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
      ret_value := EC_STRM_ANALYSIS_EVENT.PREV_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION RVP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.RVP      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RVP;
   FUNCTION SP_GRAV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SP_GRAV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SP_GRAV;
   FUNCTION VALID_FROM_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_FROM_SUMMER_TIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_SUMMER_TIME;
   FUNCTION VALID_FROM_TIME_ZONE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_FROM_TIME_ZONE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_TIME_ZONE;
   FUNCTION COMMENTS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.COMMENTS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.GCV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GCV;
   FUNCTION LABORATORY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.LABORATORY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END LABORATORY;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.NEXT_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION UTC_DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.UTC_DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.ANALYSIS_TYPE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_TYPE;
   FUNCTION CNPL_GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CNPL_GCV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CNPL_GCV;
   FUNCTION CNPL_SP_GRAV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CNPL_SP_GRAV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CNPL_SP_GRAV;
   FUNCTION MOL_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.MOL_WT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END MOL_WT;
   FUNCTION NCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.NCV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END NCV;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.PREV_DAYTIME      (
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
      ret_value := EC_STRM_ANALYSIS_EVENT.RECORD_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.APPROVAL_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.DENSITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DENSITY;
   FUNCTION NCVM(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.NCVM      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END NCVM;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.ROW_BY_PK      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SAMPLE_TEMP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SAMPLE_TEMP      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SAMPLE_TEMP;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION LAB_REF_NO(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.LAB_REF_NO      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END LAB_REF_NO;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.REC_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SULFUR_WT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SULFUR_WT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SULFUR_WT;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.TEXT_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.TEXT_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_FROM_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALID_FROM_UTC_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_FROM_UTC_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_UTC_DATE;
   FUNCTION VALID_TO_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALID_TO_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_TO_DATE;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION API(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.API      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END API;
   FUNCTION BS_W(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.BS_W      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END BS_W;
   FUNCTION CNPL_API(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CNPL_API      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CNPL_API;
   FUNCTION CNPL_DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.CNPL_DENSITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CNPL_DENSITY;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DAYTIME_SUMMER_TIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.DAYTIME_SUMMER_TIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME_SUMMER_TIME;
   FUNCTION GCVM(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.GCVM      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GCVM;
   FUNCTION PRODUCTION_DAY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.PRODUCTION_DAY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION SALT(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.SALT      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SALT;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VALUE_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION VAPOUR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_ANALYSIS_EVENT.VAPOUR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VAPOUR;

END RP_STRM_ANALYSIS_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STRM_ANALYSIS_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.46.21 AM


