
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.13 AM


CREATE or REPLACE PACKAGE RPDP_WELL_CHOKE_VALUE
IS

   FUNCTION FINDGLRATEFRMCHOKEANDDIFFPRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CHOKE_SIZE IN NUMBER,
      P_DIFF_PRESS IN NUMBER)
      RETURN NUMBER;

END RPDP_WELL_CHOKE_VALUE;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_CHOKE_VALUE
IS

   FUNCTION FINDGLRATEFRMCHOKEANDDIFFPRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CHOKE_SIZE IN NUMBER,
      P_DIFF_PRESS IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_CHOKE_VALUE.FINDGLRATEFRMCHOKEANDDIFFPRESS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CHOKE_SIZE,
         P_DIFF_PRESS );
         RETURN ret_value;
   END FINDGLRATEFRMCHOKEANDDIFFPRESS;

END RPDP_WELL_CHOKE_VALUE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_CHOKE_VALUE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.14 AM


