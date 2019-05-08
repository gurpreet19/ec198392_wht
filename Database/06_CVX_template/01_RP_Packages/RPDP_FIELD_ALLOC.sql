
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.29 AM


CREATE or REPLACE PACKAGE RPDP_FIELD_ALLOC
IS

   FUNCTION SUMFIELDALLOCPRODMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION SUMFIELDALLOCINJMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION SUMFIELDALLOCINJVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION SUMFIELDALLOCPRODVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_FIELD_ALLOC;

/



CREATE or REPLACE PACKAGE BODY RPDP_FIELD_ALLOC
IS

   FUNCTION SUMFIELDALLOCPRODMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FIELD_ALLOC.SUMFIELDALLOCPRODMASS      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END SUMFIELDALLOCPRODMASS;
   FUNCTION SUMFIELDALLOCINJMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FIELD_ALLOC.SUMFIELDALLOCINJMASS      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END SUMFIELDALLOCINJMASS;
   FUNCTION SUMFIELDALLOCINJVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FIELD_ALLOC.SUMFIELDALLOCINJVOLUME      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END SUMFIELDALLOCINJVOLUME;
   FUNCTION SUMFIELDALLOCPRODVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FIELD_ALLOC.SUMFIELDALLOCPRODVOLUME      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END SUMFIELDALLOCPRODVOLUME;

END RPDP_FIELD_ALLOC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_FIELD_ALLOC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.30 AM


