
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.31 AM


CREATE or REPLACE PACKAGE RPBP_CALCULATEAPI
IS

   FUNCTION GETVCFFORTRUCKTICKET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSTDDENSITYFORTRUCKTICKET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_NO IN VARCHAR2)
      RETURN NUMBER;

END RPBP_CALCULATEAPI;

/



CREATE or REPLACE PACKAGE BODY RPBP_CALCULATEAPI
IS

   FUNCTION GETVCFFORTRUCKTICKET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAPI.GETVCFFORTRUCKTICKET      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_NO );
         RETURN ret_value;
   END GETVCFFORTRUCKTICKET;
   FUNCTION GETSTDDENSITYFORTRUCKTICKET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAPI.GETSTDDENSITYFORTRUCKTICKET      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_NO );
         RETURN ret_value;
   END GETSTDDENSITYFORTRUCKTICKET;

END RPBP_CALCULATEAPI;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_CALCULATEAPI TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.32 AM

