
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.26 AM


CREATE or REPLACE PACKAGE RPDP_METER_MEASUREMENT
IS

   FUNCTION GETNUMBEROFSUBDAILYRECORDS(
      P_OBJECT_ID IN VARCHAR2,
      P_DATE IN DATE)
      RETURN INTEGER;

END RPDP_METER_MEASUREMENT;

/



CREATE or REPLACE PACKAGE BODY RPDP_METER_MEASUREMENT
IS

   FUNCTION GETNUMBEROFSUBDAILYRECORDS(
      P_OBJECT_ID IN VARCHAR2,
      P_DATE IN DATE)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_METER_MEASUREMENT.GETNUMBEROFSUBDAILYRECORDS      (
         P_OBJECT_ID,
         P_DATE );
         RETURN ret_value;
   END GETNUMBEROFSUBDAILYRECORDS;

END RPDP_METER_MEASUREMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_METER_MEASUREMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.27 AM

