
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.51 AM


CREATE or REPLACE PACKAGE RPDP_CALCULATION
IS

   FUNCTION GETEMPTYCALCULATIONDAYTIME
      RETURN DATE;
   FUNCTION GETCALCULATIONPATH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEPARATOR IN VARCHAR2 DEFAULT '/')
      RETURN VARCHAR2;
   FUNCTION GETEMPTYCALCULATIONID
      RETURN VARCHAR2;
   FUNCTION GETEMPTYCALCULATIONTYPE
      RETURN VARCHAR2;
   FUNCTION CALCOBJATTRFILTER(
      P_STARTDATE IN DATE,
      P_ENDDATE IN DATE,
      P_OBJECT_TYPE IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2,
      P_ATTR_VALUE IN VARCHAR2,
      P_ENGINEPARAMS IN VARCHAR2,
      P_ENGINEPARAMVALUES IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLOGPROFILENAME(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETSETDEFINITIONCOPYNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_NEW_OBJECT_ID IN VARCHAR2,
      P_NEW_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPDP_CALCULATION;

/



CREATE or REPLACE PACKAGE BODY RPDP_CALCULATION
IS

   FUNCTION GETEMPTYCALCULATIONDAYTIME
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN

         ret_value := ECDP_CALCULATION.GETEMPTYCALCULATIONDAYTIME ;
         RETURN ret_value;
   END GETEMPTYCALCULATIONDAYTIME;
   FUNCTION GETCALCULATIONPATH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEPARATOR IN VARCHAR2 DEFAULT '/')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALCULATION.GETCALCULATIONPATH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEPARATOR );
         RETURN ret_value;
   END GETCALCULATIONPATH;
   FUNCTION GETEMPTYCALCULATIONID
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN

         ret_value := ECDP_CALCULATION.GETEMPTYCALCULATIONID ;
         RETURN ret_value;
   END GETEMPTYCALCULATIONID;
   FUNCTION GETEMPTYCALCULATIONTYPE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN

         ret_value := ECDP_CALCULATION.GETEMPTYCALCULATIONTYPE ;
         RETURN ret_value;
   END GETEMPTYCALCULATIONTYPE;
   FUNCTION CALCOBJATTRFILTER(
      P_STARTDATE IN DATE,
      P_ENDDATE IN DATE,
      P_OBJECT_TYPE IN VARCHAR2,
      P_ATTR_NAME IN VARCHAR2,
      P_ATTR_VALUE IN VARCHAR2,
      P_ENGINEPARAMS IN VARCHAR2,
      P_ENGINEPARAMVALUES IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALCULATION.CALCOBJATTRFILTER      (
         P_STARTDATE,
         P_ENDDATE,
         P_OBJECT_TYPE,
         P_ATTR_NAME,
         P_ATTR_VALUE,
         P_ENGINEPARAMS,
         P_ENGINEPARAMVALUES );
         RETURN ret_value;
   END CALCOBJATTRFILTER;
   FUNCTION GETLOGPROFILENAME(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALCULATION.GETLOGPROFILENAME      (
         P_RUN_NO );
         RETURN ret_value;
   END GETLOGPROFILENAME;
   FUNCTION GETSETDEFINITIONCOPYNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_NEW_OBJECT_ID IN VARCHAR2,
      P_NEW_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := ECDP_CALCULATION.GETSETDEFINITIONCOPYNAME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_NEW_OBJECT_ID,
         P_NEW_DAYTIME );
         RETURN ret_value;
   END GETSETDEFINITIONCOPYNAME;

END RPDP_CALCULATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CALCULATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.53 AM

