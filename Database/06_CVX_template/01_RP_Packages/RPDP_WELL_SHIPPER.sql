
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.06 AM


CREATE or REPLACE PACKAGE RPDP_WELL_SHIPPER
IS

   FUNCTION GETSHIPPEROILFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSHIPPERPHASEFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSHIPPERCONFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSHIPPERWATFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSHIPPERGASFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_WELL_SHIPPER;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_SHIPPER
IS

   FUNCTION GETSHIPPEROILFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_SHIPPER.GETSHIPPEROILFRACTION      (
         P_OBJECT_ID,
         P_SHIPPER,
         P_DAYTIME );
         RETURN ret_value;
   END GETSHIPPEROILFRACTION;
   FUNCTION GETSHIPPERPHASEFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_SHIPPER.GETSHIPPERPHASEFRACTION      (
         P_OBJECT_ID,
         P_SHIPPER,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END GETSHIPPERPHASEFRACTION;
   FUNCTION GETSHIPPERCONFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_SHIPPER.GETSHIPPERCONFRACTION      (
         P_OBJECT_ID,
         P_SHIPPER,
         P_DAYTIME );
         RETURN ret_value;
   END GETSHIPPERCONFRACTION;
   FUNCTION GETSHIPPERWATFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_SHIPPER.GETSHIPPERWATFRACTION      (
         P_OBJECT_ID,
         P_SHIPPER,
         P_DAYTIME );
         RETURN ret_value;
   END GETSHIPPERWATFRACTION;
   FUNCTION GETSHIPPERGASFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_SHIPPER.GETSHIPPERGASFRACTION      (
         P_OBJECT_ID,
         P_SHIPPER,
         P_DAYTIME );
         RETURN ret_value;
   END GETSHIPPERGASFRACTION;

END RPDP_WELL_SHIPPER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_SHIPPER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.07 AM


