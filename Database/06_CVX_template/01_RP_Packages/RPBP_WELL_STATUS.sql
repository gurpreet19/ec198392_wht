
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.33.22 AM


CREATE or REPLACE PACKAGE RPBP_WELL_STATUS
IS

   FUNCTION GETCONVERTVOLUME(
      P_INJ_VOL IN NUMBER,
      P_INJ_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETVOLUMEUOM(
      P_INJ_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RPBP_WELL_STATUS;

/



CREATE or REPLACE PACKAGE BODY RPBP_WELL_STATUS
IS

   FUNCTION GETCONVERTVOLUME(
      P_INJ_VOL IN NUMBER,
      P_INJ_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_WELL_STATUS.GETCONVERTVOLUME      (
         P_INJ_VOL,
         P_INJ_TYPE );
         RETURN ret_value;
   END GETCONVERTVOLUME;
   FUNCTION GETVOLUMEUOM(
      P_INJ_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_WELL_STATUS.GETVOLUMEUOM      (
         P_INJ_TYPE );
         RETURN ret_value;
   END GETVOLUMEUOM;

END RPBP_WELL_STATUS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_WELL_STATUS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.33.23 AM


