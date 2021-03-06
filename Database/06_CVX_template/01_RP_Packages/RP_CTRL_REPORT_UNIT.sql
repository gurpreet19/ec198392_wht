
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.15 AM


CREATE or REPLACE PACKAGE RP_CTRL_REPORT_UNIT
IS

   FUNCTION APPROVAL_BY(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         UNIT_CONTEXT_ID VARCHAR2 (32) ,
         MEASUREMENT_TYPE VARCHAR2 (32) ,
         REPORT_UNIT VARCHAR2 (16) ,
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
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_REPORT_UNIT;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_REPORT_UNIT
IS

   FUNCTION APPROVAL_BY(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.APPROVAL_BY      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.APPROVAL_STATE      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.RECORD_STATUS      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.APPROVAL_DATE      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.ROW_BY_PK      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_UNIT_CONTEXT_ID IN VARCHAR2,
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_REPORT_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_REPORT_UNIT.REC_ID      (
         P_UNIT_CONTEXT_ID,
         P_MEASUREMENT_TYPE,
         P_REPORT_UNIT );
         RETURN ret_value;
   END REC_ID;

END RP_CTRL_REPORT_UNIT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_REPORT_UNIT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.17 AM


