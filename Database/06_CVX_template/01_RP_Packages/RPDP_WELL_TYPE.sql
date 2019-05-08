
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.42.51 AM


CREATE or REPLACE PACKAGE RPDP_WELL_TYPE
IS

   FUNCTION FINDWELLCLASS(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GAS_PRODUCER_2
      RETURN VARCHAR2;
   FUNCTION ISCONDENSATEPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISGASINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISWASTEINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GAS_PRODUCER_INJECTOR
      RETURN VARCHAR2;
   FUNCTION ISOILPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISPRODUCEROROTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OIL_PRODUCER_STEAM_INJECTOR
      RETURN VARCHAR2;
   FUNCTION WATER_PRODUCER
      RETURN VARCHAR2;
   FUNCTION AIR_INJECTOR
      RETURN VARCHAR2;
   FUNCTION GAS_PRODUCER
      RETURN VARCHAR2;
   FUNCTION OIL_PRODUCER_GAS_INJECTOR
      RETURN VARCHAR2;
   FUNCTION SIM_WATER_GAS_INJECTION
      RETURN VARCHAR2;
   FUNCTION CLOSED
      RETURN VARCHAR2;
   FUNCTION CONDENSATE_PRODUCER
      RETURN VARCHAR2;
   FUNCTION WATER_GAS_INJECTOR
      RETURN VARCHAR2;
   FUNCTION WATER_INJECTOR
      RETURN VARCHAR2;
   FUNCTION WATER_SOURCE
      RETURN VARCHAR2;
   FUNCTION ISAIRINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISOTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION WASTE
      RETURN VARCHAR2;
   FUNCTION WATER_INJECTION_FOR_DISPOSAL
      RETURN VARCHAR2;
   FUNCTION ISINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STEAM_INJECTOR
      RETURN VARCHAR2;
   FUNCTION WATER_STEAM_INJECTOR
      RETURN VARCHAR2;
   FUNCTION CO2_INJECTOR
      RETURN VARCHAR2;
   FUNCTION GAS_INJECTOR
      RETURN VARCHAR2;
   FUNCTION ISNOTOTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OIL_PRODUCER
      RETURN VARCHAR2;
   FUNCTION ISCO2INJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISGASPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISSTEAMINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISWATERINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISWATERPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OBSERVATION
      RETURN VARCHAR2;

END RPDP_WELL_TYPE;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_TYPE
IS

   FUNCTION FINDWELLCLASS(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.FINDWELLCLASS      (
         P_WELL_TYPE );
         RETURN ret_value;
   END FINDWELLCLASS;
   FUNCTION GAS_PRODUCER_2
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.GAS_PRODUCER_2 ;
         RETURN ret_value;
   END GAS_PRODUCER_2;
   FUNCTION ISCONDENSATEPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISCONDENSATEPRODUCER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISCONDENSATEPRODUCER;
   FUNCTION ISGASINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISGASINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISGASINJECTOR;
   FUNCTION ISWASTEINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISWASTEINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISWASTEINJECTOR;
   FUNCTION GAS_PRODUCER_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.GAS_PRODUCER_INJECTOR ;
         RETURN ret_value;
   END GAS_PRODUCER_INJECTOR;
   FUNCTION ISOILPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISOILPRODUCER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISOILPRODUCER;
   FUNCTION ISPRODUCEROROTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISPRODUCEROROTHER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISPRODUCEROROTHER;
   FUNCTION OIL_PRODUCER_STEAM_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.OIL_PRODUCER_STEAM_INJECTOR ;
         RETURN ret_value;
   END OIL_PRODUCER_STEAM_INJECTOR;
   FUNCTION WATER_PRODUCER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_PRODUCER ;
         RETURN ret_value;
   END WATER_PRODUCER;
   FUNCTION AIR_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.AIR_INJECTOR ;
         RETURN ret_value;
   END AIR_INJECTOR;
   FUNCTION GAS_PRODUCER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.GAS_PRODUCER ;
         RETURN ret_value;
   END GAS_PRODUCER;
   FUNCTION OIL_PRODUCER_GAS_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.OIL_PRODUCER_GAS_INJECTOR ;
         RETURN ret_value;
   END OIL_PRODUCER_GAS_INJECTOR;
   FUNCTION SIM_WATER_GAS_INJECTION
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.SIM_WATER_GAS_INJECTION ;
         RETURN ret_value;
   END SIM_WATER_GAS_INJECTION;
   FUNCTION CLOSED
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.CLOSED ;
         RETURN ret_value;
   END CLOSED;
   FUNCTION CONDENSATE_PRODUCER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.CONDENSATE_PRODUCER ;
         RETURN ret_value;
   END CONDENSATE_PRODUCER;
   FUNCTION WATER_GAS_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_GAS_INJECTOR ;
         RETURN ret_value;
   END WATER_GAS_INJECTOR;
   FUNCTION WATER_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_INJECTOR ;
         RETURN ret_value;
   END WATER_INJECTOR;
   FUNCTION WATER_SOURCE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_SOURCE ;
         RETURN ret_value;
   END WATER_SOURCE;
   FUNCTION ISAIRINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISAIRINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISAIRINJECTOR;
   FUNCTION ISOTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISOTHER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISOTHER;
   FUNCTION WASTE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WASTE ;
         RETURN ret_value;
   END WASTE;
   FUNCTION WATER_INJECTION_FOR_DISPOSAL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_INJECTION_FOR_DISPOSAL ;
         RETURN ret_value;
   END WATER_INJECTION_FOR_DISPOSAL;
   FUNCTION ISINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISINJECTOR;
   FUNCTION ISPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISPRODUCER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISPRODUCER;
   FUNCTION STEAM_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.STEAM_INJECTOR ;
         RETURN ret_value;
   END STEAM_INJECTOR;
   FUNCTION WATER_STEAM_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.WATER_STEAM_INJECTOR ;
         RETURN ret_value;
   END WATER_STEAM_INJECTOR;
   FUNCTION CO2_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.CO2_INJECTOR ;
         RETURN ret_value;
   END CO2_INJECTOR;
   FUNCTION GAS_INJECTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.GAS_INJECTOR ;
         RETURN ret_value;
   END GAS_INJECTOR;
   FUNCTION ISNOTOTHER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISNOTOTHER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISNOTOTHER;
   FUNCTION OIL_PRODUCER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.OIL_PRODUCER ;
         RETURN ret_value;
   END OIL_PRODUCER;
   FUNCTION ISCO2INJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISCO2INJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISCO2INJECTOR;
   FUNCTION ISGASPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISGASPRODUCER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISGASPRODUCER;
   FUNCTION ISSTEAMINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISSTEAMINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISSTEAMINJECTOR;
   FUNCTION ISWATERINJECTOR(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISWATERINJECTOR      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISWATERINJECTOR;
   FUNCTION ISWATERPRODUCER(
      P_WELL_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_TYPE.ISWATERPRODUCER      (
         P_WELL_TYPE );
         RETURN ret_value;
   END ISWATERPRODUCER;
   FUNCTION OBSERVATION
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_WELL_TYPE.OBSERVATION ;
         RETURN ret_value;
   END OBSERVATION;

END RPDP_WELL_TYPE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_TYPE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.42.58 AM


