
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.13 AM


CREATE or REPLACE PACKAGE RPBP_COMP_PC_ANALYSIS
IS

   FUNCTION CALCCOMPMASSFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCCOMPMOLFRACPERIODAN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DAYTIME_SUMMER_TIME IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCCOMPMASSFRACPERIODAN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DAYTIME_SUMMER_TIME IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCCOMPWTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCTOTMOLPERIODANFRAC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCTOTPERIODANMASSFRAC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCTOTMASSFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCCOMPMOLFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCTOTMOLFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCCOMPMOLPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETSTREAMCOMPWTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_PHASE IN VARCHAR2 DEFAULT NULL,
      P_FLUID_STATE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RPBP_COMP_PC_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RPBP_COMP_PC_ANALYSIS
IS

   FUNCTION CALCCOMPMASSFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPMASSFRAC      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_PC_ID,
         P_SAMPLING_METHOD,
         P_MOL_PCT );
         RETURN ret_value;
   END CALCCOMPMASSFRAC;
   FUNCTION CALCCOMPMOLFRACPERIODAN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DAYTIME_SUMMER_TIME IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPMOLFRACPERIODAN      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_DAYTIME_SUMMER_TIME,
         P_COMPONENT_NO,
         P_ANALYSIS_TYPE,
         P_SAMPLING_METHOD,
         P_WEIGHT_PCT );
         RETURN ret_value;
   END CALCCOMPMOLFRACPERIODAN;
   FUNCTION CALCCOMPMASSFRACPERIODAN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DAYTIME_SUMMER_TIME IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPMASSFRACPERIODAN      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_DAYTIME_SUMMER_TIME,
         P_COMPONENT_NO,
         P_ANALYSIS_TYPE,
         P_SAMPLING_METHOD,
         P_MOL_PCT );
         RETURN ret_value;
   END CALCCOMPMASSFRACPERIODAN;
   FUNCTION CALCCOMPWTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_MOL_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPWTPCT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_ANALYSIS_TYPE,
         P_SAMPLING_METHOD,
         P_MOL_PCT );
         RETURN ret_value;
   END CALCCOMPWTPCT;
   FUNCTION CALCTOTMOLPERIODANFRAC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCTOTMOLPERIODANFRAC      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CALCTOTMOLPERIODANFRAC;
   FUNCTION CALCTOTPERIODANMASSFRAC(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCTOTPERIODANMASSFRAC      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CALCTOTPERIODANMASSFRAC;
   FUNCTION CALCTOTMASSFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCTOTMASSFRAC      (
         P_OBJECT_ID,
         P_PC_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCTOTMASSFRAC;
   FUNCTION CALCCOMPMOLFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPMOLFRAC      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_PC_ID,
         P_SAMPLING_METHOD,
         P_WEIGHT_PCT );
         RETURN ret_value;
   END CALCCOMPMOLFRAC;
   FUNCTION CALCTOTMOLFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_PC_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCTOTMOLFRAC      (
         P_OBJECT_ID,
         P_PC_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCTOTMOLFRAC;
   FUNCTION CALCCOMPMOLPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_WEIGHT_PCT IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.CALCCOMPMOLPCT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_ANALYSIS_TYPE,
         P_SAMPLING_METHOD,
         P_WEIGHT_PCT );
         RETURN ret_value;
   END CALCCOMPMOLPCT;
   FUNCTION GETSTREAMCOMPWTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_ANALYSIS_TYPE IN VARCHAR2,
      P_SAMPLING_METHOD IN VARCHAR2,
      P_PHASE IN VARCHAR2 DEFAULT NULL,
      P_FLUID_STATE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_COMP_PC_ANALYSIS.GETSTREAMCOMPWTPCT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_ANALYSIS_TYPE,
         P_SAMPLING_METHOD,
         P_PHASE,
         P_FLUID_STATE );
         RETURN ret_value;
   END GETSTREAMCOMPWTPCT;

END RPBP_COMP_PC_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_COMP_PC_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.16 AM

