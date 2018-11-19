
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.14.52 AM


CREATE or REPLACE PACKAGE RP_CT_REPORT_DATE
IS

   FUNCTION RECORD_STATUS(
      P_DATE_ID IN DATE)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         DATE_ID  DATE ,
         MONTH_ID  DATE ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (240)  );
   FUNCTION ROW_BY_PK(
      P_DATE_ID IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION MONTH_ID(
      P_DATE_ID IN DATE)
      RETURN DATE;

END RP_CT_REPORT_DATE;

/



CREATE or REPLACE PACKAGE BODY RP_CT_REPORT_DATE
IS

   FUNCTION RECORD_STATUS(
      P_DATE_ID IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CT_REPORT_DATE.RECORD_STATUS      (
         P_DATE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION ROW_BY_PK(
      P_DATE_ID IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CT_REPORT_DATE.ROW_BY_PK      (
         P_DATE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION MONTH_ID(
      P_DATE_ID IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CT_REPORT_DATE.MONTH_ID      (
         P_DATE_ID );
         RETURN ret_value;
   END MONTH_ID;

END RP_CT_REPORT_DATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CT_REPORT_DATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.14.53 AM


