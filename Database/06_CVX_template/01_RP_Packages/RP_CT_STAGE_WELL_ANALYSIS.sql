
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.13.55 AM


CREATE or REPLACE PACKAGE RP_CT_STAGE_WELL_ANALYSIS
IS

      TYPE REC_ROW_BY_PK IS RECORD (
         STAGE_COMP_ANALYSIS_NO NUMBER ,
         CLASS_NAME VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_REF_CODE VARCHAR2 (1000) ,
         IMPORT_DATE  DATE ,
         ANALYSIS_DATE  DATE ,
         ANALYSIS_TYPE VARCHAR2 (256) ,
         SAMPLING_METHOD VARCHAR2 (256) ,
         PHASE VARCHAR2 (256) ,
         SAMPLE_PRESSURE VARCHAR2 (127) ,
         SAMPLE_TEMP VARCHAR2 (127) ,
         DENSITY VARCHAR2 (127) ,
         BS_W VARCHAR2 (127) ,
         GCV VARCHAR2 (127) ,
         RVP VARCHAR2 (127) ,
         C1_WT VARCHAR2 (127) ,
         C2_WT VARCHAR2 (127) ,
         C3_WT VARCHAR2 (127) ,
         IC4_WT VARCHAR2 (127) ,
         NC4_WT VARCHAR2 (127) ,
         IC5_WT VARCHAR2 (127) ,
         NC5_WT VARCHAR2 (127) ,
         NC6_WT VARCHAR2 (127) ,
         NC7_WT VARCHAR2 (127) ,
         NC8_WT VARCHAR2 (127) ,
         C9_PLUS_WT VARCHAR2 (127) ,
         O2_WT VARCHAR2 (127) ,
         CO2_WT VARCHAR2 (127) ,
         N2_WT VARCHAR2 (127) ,
         H2O_WT VARCHAR2 (127) ,
         C1_MOL VARCHAR2 (127) ,
         C2_MOL VARCHAR2 (127) ,
         C3_MOL VARCHAR2 (127) ,
         IC4_MOL VARCHAR2 (127) ,
         NC4_MOL VARCHAR2 (127) ,
         IC5_MOL VARCHAR2 (127) ,
         NC5_MOL VARCHAR2 (127) ,
         NC6_MOL VARCHAR2 (127) ,
         NC7_MOL VARCHAR2 (127) ,
         NC8_MOL VARCHAR2 (127) ,
         C9_PLUS_MOL VARCHAR2 (127) ,
         O2_MOL VARCHAR2 (127) ,
         CO2_MOL VARCHAR2 (127) ,
         N2_MOL VARCHAR2 (127) ,
         H2O_MOL VARCHAR2 (127) ,
         FULL_TEXTLINE VARCHAR2 (4000) ,
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
   FUNCTION ROW_BY_PK
      RETURN REC_ROW_BY_PK;

END RP_CT_STAGE_WELL_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_CT_STAGE_WELL_ANALYSIS
IS

   FUNCTION ROW_BY_PK
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN

         ret_value := EC_CT_STAGE_WELL_ANALYSIS.ROW_BY_PK ;
         RETURN ret_value;
   END ROW_BY_PK;

END RP_CT_STAGE_WELL_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CT_STAGE_WELL_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.13.56 AM


