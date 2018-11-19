
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.47.27 AM


CREATE or REPLACE PACKAGE RP_OBJECT_AGA_ANALYSIS
IS

   FUNCTION GRS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PB(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION X4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GS_CALC_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION HV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RHOS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TH(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
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
   FUNCTION TS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION X3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AGA3_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FPVS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMPRESSIBILITY_STD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EFF_CORR_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION KFAC(
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
   FUNCTION VISC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         ANALYSIS_TYPE VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         VALID_FROM_DATE  DATE ,
         ANALYSIS_STATUS VARCHAR2 (32) ,
         USE_AGA8_IND VARCHAR2 (1) ,
         GS_CALC_METHOD VARCHAR2 (32) ,
         TS NUMBER ,
         PS NUMBER ,
         RHOTP NUMBER ,
         RHOS NUMBER ,
         FPVS NUMBER ,
         VISC NUMBER ,
         KFAC NUMBER ,
         IFLUID VARCHAR2 (1) ,
         GRS NUMBER ,
         ZAIRS NUMBER ,
         HV NUMBER ,
         GRGR NUMBER ,
         X1 NUMBER ,
         X2 NUMBER ,
         X3 NUMBER ,
         X4 NUMBER ,
         TB NUMBER ,
         PB NUMBER ,
         TGR NUMBER ,
         PGR NUMBER ,
         TD NUMBER ,
         PD NUMBER ,
         TH NUMBER ,
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
         AGA3_TYPE VARCHAR2 (32) ,
         COMPRESSIBILITY_FLOW NUMBER ,
         COMPRESSIBILITY_STD NUMBER ,
         CONDITION_FACTOR NUMBER ,
         EFF_CORR_FACTOR NUMBER  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMPRESSIBILITY_FLOW(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RHOTP(
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
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION X2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ZAIRS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONDITION_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION IFLUID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TB(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION USE_AGA8_IND(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION X1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;

END RP_OBJECT_AGA_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_OBJECT_AGA_ANALYSIS
IS

   FUNCTION GRS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.GRS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GRS;
   FUNCTION PB(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.PB      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PB;
   FUNCTION PD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.PD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PD;
   FUNCTION PS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.PS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PS;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TEXT_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TEXT_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TGR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TGR;
   FUNCTION X4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.X4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END X4;
   FUNCTION ANALYSIS_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.ANALYSIS_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_STATUS;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.APPROVAL_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.APPROVAL_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION GS_CALC_METHOD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.GS_CALC_METHOD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GS_CALC_METHOD;
   FUNCTION HV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.HV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END HV;
   FUNCTION RHOS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.RHOS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RHOS;
   FUNCTION TH(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TH      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TH;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_5      (
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
      ret_value := EC_OBJECT_AGA_ANALYSIS.NEXT_DAYTIME      (
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
      ret_value := EC_OBJECT_AGA_ANALYSIS.OBJECT_ID      (
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
      ret_value := EC_OBJECT_AGA_ANALYSIS.PREV_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TS;
   FUNCTION X3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.X3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END X3;
   FUNCTION AGA3_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.AGA3_TYPE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END AGA3_TYPE;
   FUNCTION CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.CLASS_NAME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION FPVS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.FPVS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END FPVS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.NEXT_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TD;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ANALYSIS_TYPE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.ANALYSIS_TYPE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ANALYSIS_TYPE;
   FUNCTION COMPRESSIBILITY_STD(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.COMPRESSIBILITY_STD      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END COMPRESSIBILITY_STD;
   FUNCTION EFF_CORR_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.EFF_CORR_FACTOR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END EFF_CORR_FACTOR;
   FUNCTION KFAC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.KFAC      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END KFAC;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.PREV_DAYTIME      (
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
      ret_value := EC_OBJECT_AGA_ANALYSIS.RECORD_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VISC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VISC      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VISC;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.APPROVAL_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.ROW_BY_PK      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION COMPRESSIBILITY_FLOW(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.COMPRESSIBILITY_FLOW      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END COMPRESSIBILITY_FLOW;
   FUNCTION GRGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.GRGR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GRGR;
   FUNCTION PGR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.PGR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END PGR;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.REC_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION RHOTP(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.RHOTP      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RHOTP;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TEXT_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TEXT_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALID_FROM_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION X2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.X2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END X2;
   FUNCTION ZAIRS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.ZAIRS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ZAIRS;
   FUNCTION CONDITION_FACTOR(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.CONDITION_FACTOR      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CONDITION_FACTOR;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION IFLUID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.IFLUID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END IFLUID;
   FUNCTION TB(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.TB      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TB;
   FUNCTION USE_AGA8_IND(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.USE_AGA8_IND      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END USE_AGA8_IND;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.VALUE_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION X1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_AGA_ANALYSIS.X1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END X1;

END RP_OBJECT_AGA_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJECT_AGA_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.47.39 AM


