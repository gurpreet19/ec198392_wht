
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.07 AM


CREATE or REPLACE PACKAGE RPDP_WELL_RESERVOIR
IS

   FUNCTION FINDBLOCKFORMATIONSTREAM(
      P_STREAM_PHASE IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETREFQUALITYSTREAM(
      P_WELL_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT TRUNC(Ecdp_Timestamp.getCurrentSysdate))
      RETURN VARCHAR2;
   FUNCTION GETWELLRBFPHASEFRACTION(
      P_WELL_ID IN VARCHAR2,
      P_RESV_BLOCK_FORM_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE_DIRECTION IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETFIRSTWELLPERFFAULTBLOCK(
      P_WELL_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETWELLCOENTPHASEFRACTION(
      P_WELL_ID IN VARCHAR2,
      P_COENT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETBLOCKFORMATIONSTREAM(
      P_STREAM_PHASE IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETFIRSTWELLPERFFORMATION(
      P_WELL_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETRESERVOIRBLOCKCONFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKWATINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKOILFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKSTEAMINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKPHASEFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKWATFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKGASINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETRESERVOIRBLOCKGASFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_WELL_RESERVOIR;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_RESERVOIR
IS

   FUNCTION FINDBLOCKFORMATIONSTREAM(
      P_STREAM_PHASE IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.FINDBLOCKFORMATIONSTREAM      (
         P_STREAM_PHASE,
         P_BLOCK_ID,
         P_FORMATION_ID );
         RETURN ret_value;
   END FINDBLOCKFORMATIONSTREAM;
   FUNCTION GETREFQUALITYSTREAM(
      P_WELL_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT TRUNC(Ecdp_Timestamp.getCurrentSysdate))
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETREFQUALITYSTREAM      (
         P_WELL_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END GETREFQUALITYSTREAM;
   FUNCTION GETWELLRBFPHASEFRACTION(
      P_WELL_ID IN VARCHAR2,
      P_RESV_BLOCK_FORM_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE_DIRECTION IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETWELLRBFPHASEFRACTION      (
         P_WELL_ID,
         P_RESV_BLOCK_FORM_ID,
         P_DAYTIME,
         P_PHASE_DIRECTION );
         RETURN ret_value;
   END GETWELLRBFPHASEFRACTION;
   FUNCTION GETFIRSTWELLPERFFAULTBLOCK(
      P_WELL_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETFIRSTWELLPERFFAULTBLOCK      (
         P_WELL_ID );
         RETURN ret_value;
   END GETFIRSTWELLPERFFAULTBLOCK;
   FUNCTION GETWELLCOENTPHASEFRACTION(
      P_WELL_ID IN VARCHAR2,
      P_COENT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETWELLCOENTPHASEFRACTION      (
         P_WELL_ID,
         P_COENT_ID,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END GETWELLCOENTPHASEFRACTION;
   FUNCTION GETBLOCKFORMATIONSTREAM(
      P_STREAM_PHASE IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETBLOCKFORMATIONSTREAM      (
         P_STREAM_PHASE,
         P_BLOCK_ID,
         P_FORMATION_ID );
         RETURN ret_value;
   END GETBLOCKFORMATIONSTREAM;
   FUNCTION GETFIRSTWELLPERFFORMATION(
      P_WELL_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETFIRSTWELLPERFFORMATION      (
         P_WELL_ID );
         RETURN ret_value;
   END GETFIRSTWELLPERFFORMATION;
   FUNCTION GETRESERVOIRBLOCKCONFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKCONFRACTION      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKCONFRACTION;
   FUNCTION GETRESERVOIRBLOCKWATINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKWATINJFRAC      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKWATINJFRAC;
   FUNCTION GETRESERVOIRBLOCKOILFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKOILFRACTION      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKOILFRACTION;
   FUNCTION GETRESERVOIRBLOCKSTEAMINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKSTEAMINJFRAC      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKSTEAMINJFRAC;
   FUNCTION GETRESERVOIRBLOCKPHASEFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKPHASEFRACTION      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END GETRESERVOIRBLOCKPHASEFRACTION;
   FUNCTION GETRESERVOIRBLOCKWATFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKWATFRACTION      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKWATFRACTION;
   FUNCTION GETRESERVOIRBLOCKGASINJFRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKGASINJFRAC      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKGASINJFRAC;
   FUNCTION GETRESERVOIRBLOCKGASFRACTION(
      P_OBJECT_ID IN VARCHAR2,
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_RESERVOIR.GETRESERVOIRBLOCKGASFRACTION      (
         P_OBJECT_ID,
         P_BLOCK_ID,
         P_FORMATION_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESERVOIRBLOCKGASFRACTION;

END RPDP_WELL_RESERVOIR;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_RESERVOIR TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.11 AM


