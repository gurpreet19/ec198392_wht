
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.28 AM


CREATE or REPLACE PACKAGE RPDP_TIMESTAMP_UTILS
IS

   FUNCTION GETDSTTIME(
      P_TIME_ZONE IN VARCHAR2,
      P_DAY IN DATE)
      RETURN DATE;
   FUNCTION TIMEOFFSETTOHRS(
      P_TIME_OFFSET IN VARCHAR2,
      P_STRICT IN VARCHAR2 DEFAULT 'Y')
      RETURN NUMBER;

END RPDP_TIMESTAMP_UTILS;

/



CREATE or REPLACE PACKAGE BODY RPDP_TIMESTAMP_UTILS
IS

   FUNCTION GETDSTTIME(
      P_TIME_ZONE IN VARCHAR2,
      P_DAY IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_TIMESTAMP_UTILS.GETDSTTIME      (
         P_TIME_ZONE,
         P_DAY );
         RETURN ret_value;
   END GETDSTTIME;
   FUNCTION TIMEOFFSETTOHRS(
      P_TIME_OFFSET IN VARCHAR2,
      P_STRICT IN VARCHAR2 DEFAULT 'Y')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TIMESTAMP_UTILS.TIMEOFFSETTOHRS      (
         P_TIME_OFFSET,
         P_STRICT );
         RETURN ret_value;
   END TIMEOFFSETTOHRS;

END RPDP_TIMESTAMP_UTILS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_TIMESTAMP_UTILS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.29 AM


