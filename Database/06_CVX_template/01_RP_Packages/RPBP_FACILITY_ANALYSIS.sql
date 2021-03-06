
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.49 AM


CREATE or REPLACE PACKAGE RPBP_FACILITY_ANALYSIS
IS

   FUNCTION GETANALYSISFREQ(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETANALYSISTARGET(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETAVGVALUE(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2,
      P_DAYS IN NUMBER)
      RETURN NUMBER;

END RPBP_FACILITY_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RPBP_FACILITY_ANALYSIS
IS

   FUNCTION GETANALYSISFREQ(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_FACILITY_ANALYSIS.GETANALYSISFREQ      (
         P_FCTY_OBJECT_ID,
         P_START_DATE,
         P_ASSET_ID,
         P_ANALYSIS_ITEM );
         RETURN ret_value;
   END GETANALYSISFREQ;
   FUNCTION GETANALYSISTARGET(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_FACILITY_ANALYSIS.GETANALYSISTARGET      (
         P_FCTY_OBJECT_ID,
         P_START_DATE,
         P_ASSET_ID,
         P_ANALYSIS_ITEM );
         RETURN ret_value;
   END GETANALYSISTARGET;
   FUNCTION GETAVGVALUE(
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ASSET_ID IN VARCHAR2,
      P_ANALYSIS_ITEM IN VARCHAR2,
      P_DAYS IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FACILITY_ANALYSIS.GETAVGVALUE      (
         P_FCTY_OBJECT_ID,
         P_DAYTIME,
         P_ASSET_ID,
         P_ANALYSIS_ITEM,
         P_DAYS );
         RETURN ret_value;
   END GETAVGVALUE;

END RPBP_FACILITY_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_FACILITY_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.50 AM


