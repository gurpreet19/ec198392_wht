
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.32 AM


CREATE or REPLACE PACKAGE RPDP_STREAM_DPT_VALUE
IS

   FUNCTION COL_SP_GRAV
      RETURN VARCHAR2;
   FUNCTION COL_VCF
      RETURN VARCHAR2;
   FUNCTION COL_BO
      RETURN VARCHAR2;
   FUNCTION GETINVERTEDFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DENSITY IN NUMBER,
      P_PRESSURE IN NUMBER,
      P_TEMPERATURE IN NUMBER,
      P_INV_FACTOR_COL_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COL_BG
      RETURN VARCHAR2;
   FUNCTION COL_RS
      RETURN VARCHAR2;
   FUNCTION FINDINVERTEDFACTORFROMDPT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DENSITY IN NUMBER,
      P_PRESSURE IN NUMBER,
      P_TEMPERATURE IN NUMBER,
      P_INV_FACTOR_COL_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COL_BW
      RETURN VARCHAR2;

END RPDP_STREAM_DPT_VALUE;

/



CREATE or REPLACE PACKAGE BODY RPDP_STREAM_DPT_VALUE
IS

   FUNCTION COL_SP_GRAV
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_SP_GRAV ;
         RETURN ret_value;
   END COL_SP_GRAV;
   FUNCTION COL_VCF
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_VCF ;
         RETURN ret_value;
   END COL_VCF;
   FUNCTION COL_BO
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_BO ;
         RETURN ret_value;
   END COL_BO;
   FUNCTION GETINVERTEDFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DENSITY IN NUMBER,
      P_PRESSURE IN NUMBER,
      P_TEMPERATURE IN NUMBER,
      P_INV_FACTOR_COL_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STREAM_DPT_VALUE.GETINVERTEDFACTOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_DENSITY,
         P_PRESSURE,
         P_TEMPERATURE,
         P_INV_FACTOR_COL_NAME );
         RETURN ret_value;
   END GETINVERTEDFACTOR;
   FUNCTION COL_BG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_BG ;
         RETURN ret_value;
   END COL_BG;
   FUNCTION COL_RS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_RS ;
         RETURN ret_value;
   END COL_RS;
   FUNCTION FINDINVERTEDFACTORFROMDPT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DENSITY IN NUMBER,
      P_PRESSURE IN NUMBER,
      P_TEMPERATURE IN NUMBER,
      P_INV_FACTOR_COL_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STREAM_DPT_VALUE.FINDINVERTEDFACTORFROMDPT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_DENSITY,
         P_PRESSURE,
         P_TEMPERATURE,
         P_INV_FACTOR_COL_NAME );
         RETURN ret_value;
   END FINDINVERTEDFACTORFROMDPT;
   FUNCTION COL_BW
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_DPT_VALUE.COL_BW ;
         RETURN ret_value;
   END COL_BW;

END RPDP_STREAM_DPT_VALUE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STREAM_DPT_VALUE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.34 AM


