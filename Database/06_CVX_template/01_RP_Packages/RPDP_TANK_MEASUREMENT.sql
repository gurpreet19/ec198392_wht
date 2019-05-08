
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.35 AM


CREATE or REPLACE PACKAGE RPDP_TANK_MEASUREMENT
IS

   FUNCTION GETVOLUMECORRECTIONFACTOR(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETWATERVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETNETMASS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETBSWVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETBSWWT(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETOBSDENS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETNETVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTDDENS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETWATERDIPLEVEL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETGRSDIPLEVEL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETGRSMASS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETGRSVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_TANK_MEASUREMENT;

/



CREATE or REPLACE PACKAGE BODY RPDP_TANK_MEASUREMENT
IS

   FUNCTION GETVOLUMECORRECTIONFACTOR(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETVOLUMECORRECTIONFACTOR      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETVOLUMECORRECTIONFACTOR;
   FUNCTION GETWATERVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETWATERVOL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETWATERVOL;
   FUNCTION GETNETMASS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETNETMASS      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETNETMASS;
   FUNCTION GETBSWVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETBSWVOL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETBSWVOL;
   FUNCTION GETBSWWT(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETBSWWT      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETBSWWT;
   FUNCTION GETOBSDENS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETOBSDENS      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETOBSDENS;
   FUNCTION GETNETVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETNETVOL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETNETVOL;
   FUNCTION GETSTDDENS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETSTDDENS      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETSTDDENS;
   FUNCTION GETWATERDIPLEVEL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETWATERDIPLEVEL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETWATERDIPLEVEL;
   FUNCTION GETGRSDIPLEVEL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETGRSDIPLEVEL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETGRSDIPLEVEL;
   FUNCTION GETGRSMASS(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETGRSMASS      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETGRSMASS;
   FUNCTION GETGRSVOL(
      P_TANK_OBJECT_ID IN VARCHAR2,
      P_MEAS_EVENT_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_TANK_MEASUREMENT.GETGRSVOL      (
         P_TANK_OBJECT_ID,
         P_MEAS_EVENT_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETGRSVOL;

END RPDP_TANK_MEASUREMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_TANK_MEASUREMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.37 AM


