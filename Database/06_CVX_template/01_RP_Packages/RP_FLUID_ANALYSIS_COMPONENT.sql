
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.13.53 AM


CREATE or REPLACE PACKAGE RP_FLUID_ANALYSIS_COMPONENT
IS

   FUNCTION ENERGY_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MEAS_SPECIFIC_GRAVITY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MOL_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION WT_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MOL_WT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         ANALYSIS_NO NUMBER ,
         COMPONENT_NO VARCHAR2 (16) ,
         WT_PCT NUMBER ,
         MOL_PCT NUMBER ,
         MOL_WT NUMBER ,
         DENSITY NUMBER ,
         ENERGY_PCT NUMBER ,
         VOL_PCT NUMBER ,
         MEAS_MOL_WT NUMBER ,
         MEAS_SPECIFIC_GRAVITY NUMBER ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VOL_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MEAS_MOL_WT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;

END RP_FLUID_ANALYSIS_COMPONENT;

/



CREATE or REPLACE PACKAGE BODY RP_FLUID_ANALYSIS_COMPONENT
IS

   FUNCTION ENERGY_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.ENERGY_PCT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END ENERGY_PCT;
   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.TEXT_3      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.TEXT_4      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.APPROVAL_BY      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.APPROVAL_STATE      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_5      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION MEAS_SPECIFIC_GRAVITY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.MEAS_SPECIFIC_GRAVITY      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END MEAS_SPECIFIC_GRAVITY;
   FUNCTION MOL_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.MOL_PCT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END MOL_PCT;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_6      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION WT_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.WT_PCT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END WT_PCT;
   FUNCTION MOL_WT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.MOL_WT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END MOL_WT;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.RECORD_STATUS      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_1      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.APPROVAL_DATE      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.DENSITY      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END DENSITY;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.ROW_BY_PK      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_2      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_3      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_4      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION VOL_PCT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VOL_PCT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VOL_PCT;
   FUNCTION MEAS_MOL_WT(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.MEAS_MOL_WT      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END MEAS_MOL_WT;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.REC_ID      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.TEXT_1      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.TEXT_2      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_7      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_9      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_10      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER,
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FLUID_ANALYSIS_COMPONENT.VALUE_8      (
         P_ANALYSIS_NO,
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FLUID_ANALYSIS_COMPONENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FLUID_ANALYSIS_COMPONENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.13.59 AM


