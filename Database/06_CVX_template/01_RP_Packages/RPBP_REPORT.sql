
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.05 AM


CREATE or REPLACE PACKAGE RPBP_REPORT
IS

   FUNCTION HASACCESSTOREPORTDEFINITION(
      P_REP_GROUP_CODE IN VARCHAR2,
      P_REPORT_AREA_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION HASACCESSTOGENERATEDREPORT(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION HASACCESSTOPUBLISHEDREPORT(
      P_REPORT_PUBLISHED_NO IN NUMBER,
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETHIDEIND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION HASACCESSTOREPORTRUNABLE(
      P_REPORT_RUNABLE_NO IN NUMBER,
      P_REP_GROUP_CODE IN VARCHAR2,
      P_REPORT_AREA_ID IN VARCHAR2,
      P_NAV_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISREPORTDEFINGROUP(
      P_REPORT_DEF_NO IN VARCHAR2,
      P_REPORT_GROUP IN VARCHAR2)
      RETURN VARCHAR2;

END RPBP_REPORT;

/



CREATE or REPLACE PACKAGE BODY RPBP_REPORT
IS

   FUNCTION HASACCESSTOREPORTDEFINITION(
      P_REP_GROUP_CODE IN VARCHAR2,
      P_REPORT_AREA_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.HASACCESSTOREPORTDEFINITION      (
         P_REP_GROUP_CODE,
         P_REPORT_AREA_ID );
         RETURN ret_value;
   END HASACCESSTOREPORTDEFINITION;
   FUNCTION HASACCESSTOGENERATEDREPORT(
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.HASACCESSTOGENERATEDREPORT      (
         P_REPORT_NO );
         RETURN ret_value;
   END HASACCESSTOGENERATEDREPORT;
   FUNCTION HASACCESSTOPUBLISHEDREPORT(
      P_REPORT_PUBLISHED_NO IN NUMBER,
      P_REPORT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.HASACCESSTOPUBLISHEDREPORT      (
         P_REPORT_PUBLISHED_NO,
         P_REPORT_NO );
         RETURN ret_value;
   END HASACCESSTOPUBLISHEDREPORT;
   FUNCTION GETHIDEIND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.GETHIDEIND      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END GETHIDEIND;
   FUNCTION HASACCESSTOREPORTRUNABLE(
      P_REPORT_RUNABLE_NO IN NUMBER,
      P_REP_GROUP_CODE IN VARCHAR2,
      P_REPORT_AREA_ID IN VARCHAR2,
      P_NAV_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.HASACCESSTOREPORTRUNABLE      (
         P_REPORT_RUNABLE_NO,
         P_REP_GROUP_CODE,
         P_REPORT_AREA_ID,
         P_NAV_DATE );
         RETURN ret_value;
   END HASACCESSTOREPORTRUNABLE;
   FUNCTION ISREPORTDEFINGROUP(
      P_REPORT_DEF_NO IN VARCHAR2,
      P_REPORT_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_REPORT.ISREPORTDEFINGROUP      (
         P_REPORT_DEF_NO,
         P_REPORT_GROUP );
         RETURN ret_value;
   END ISREPORTDEFINGROUP;

END RPBP_REPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_REPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.07 AM


