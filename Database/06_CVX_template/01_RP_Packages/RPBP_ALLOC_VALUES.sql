
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.45 AM


CREATE or REPLACE PACKAGE RPBP_ALLOC_VALUES
IS

   FUNCTION CALCSUMOPERWELLHOOKOILALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFACILITYOILALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFACILITYCONDALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFACILITYWATALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFCTYGASMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFCTYOILMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERWELLHOOKCONDALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFACILITYGASALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFCTYCONDMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERFCTYWATMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERWELLHOOKGASALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCSUMOPERWELLHOOKWATALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_ALLOC_VALUES;

/



CREATE or REPLACE PACKAGE BODY RPBP_ALLOC_VALUES
IS

   FUNCTION CALCSUMOPERWELLHOOKOILALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERWELLHOOKOILALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERWELLHOOKOILALLOC;
   FUNCTION CALCSUMOPERFACILITYOILALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFACILITYOILALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFACILITYOILALLOC;
   FUNCTION CALCSUMOPERFACILITYCONDALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFACILITYCONDALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFACILITYCONDALLOC;
   FUNCTION CALCSUMOPERFACILITYWATALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFACILITYWATALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFACILITYWATALLOC;
   FUNCTION CALCSUMOPERFCTYGASMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFCTYGASMASSALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFCTYGASMASSALLOC;
   FUNCTION CALCSUMOPERFCTYOILMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFCTYOILMASSALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFCTYOILMASSALLOC;
   FUNCTION CALCSUMOPERWELLHOOKCONDALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERWELLHOOKCONDALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERWELLHOOKCONDALLOC;
   FUNCTION CALCSUMOPERFACILITYGASALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFACILITYGASALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFACILITYGASALLOC;
   FUNCTION CALCSUMOPERFCTYCONDMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFCTYCONDMASSALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFCTYCONDMASSALLOC;
   FUNCTION CALCSUMOPERFCTYWATMASSALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERFCTYWATMASSALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERFCTYWATMASSALLOC;
   FUNCTION CALCSUMOPERWELLHOOKGASALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERWELLHOOKGASALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERWELLHOOKGASALLOC;
   FUNCTION CALCSUMOPERWELLHOOKWATALLOC(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ALLOC_VALUES.CALCSUMOPERWELLHOOKWATALLOC      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSUMOPERWELLHOOKWATALLOC;

END RPBP_ALLOC_VALUES;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_ALLOC_VALUES TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.48 AM


