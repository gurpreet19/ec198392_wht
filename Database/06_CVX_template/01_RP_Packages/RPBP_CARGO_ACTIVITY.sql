
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.35 AM


CREATE or REPLACE PACKAGE RPBP_CARGO_ACTIVITY
IS

   FUNCTION GETACTIVITYELAPSEDTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_START IN DATE,
      P_ACTIVITY_END IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETLIFTINGENDDATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_TYPE IN VARCHAR2 DEFAULT 'LOAD',
      P_LIFTING_EVENT IN VARCHAR2 DEFAULT 'LOAD')
      RETURN DATE;
   FUNCTION GETLIFTINGSTARTDATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_TYPE IN VARCHAR2 DEFAULT 'LOAD',
      P_LIFTING_EVENT IN VARCHAR2 DEFAULT 'LOAD')
      RETURN DATE;

END RPBP_CARGO_ACTIVITY;

/



CREATE or REPLACE PACKAGE BODY RPBP_CARGO_ACTIVITY
IS

   FUNCTION GETACTIVITYELAPSEDTIME(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_START IN DATE,
      P_ACTIVITY_END IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_ACTIVITY.GETACTIVITYELAPSEDTIME      (
         P_CARGO_NO,
         P_ACTIVITY_START,
         P_ACTIVITY_END );
         RETURN ret_value;
   END GETACTIVITYELAPSEDTIME;
   FUNCTION GETLIFTINGENDDATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_TYPE IN VARCHAR2 DEFAULT 'LOAD',
      P_LIFTING_EVENT IN VARCHAR2 DEFAULT 'LOAD')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECBP_CARGO_ACTIVITY.GETLIFTINGENDDATE      (
         P_CARGO_NO,
         P_ACTIVITY_TYPE,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END GETLIFTINGENDDATE;
   FUNCTION GETLIFTINGSTARTDATE(
      P_CARGO_NO IN NUMBER,
      P_ACTIVITY_TYPE IN VARCHAR2 DEFAULT 'LOAD',
      P_LIFTING_EVENT IN VARCHAR2 DEFAULT 'LOAD')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECBP_CARGO_ACTIVITY.GETLIFTINGSTARTDATE      (
         P_CARGO_NO,
         P_ACTIVITY_TYPE,
         P_LIFTING_EVENT );
         RETURN ret_value;
   END GETLIFTINGSTARTDATE;

END RPBP_CARGO_ACTIVITY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_CARGO_ACTIVITY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.36 AM


