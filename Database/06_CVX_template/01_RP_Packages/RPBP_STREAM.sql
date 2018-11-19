
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.34.33 AM


CREATE or REPLACE PACKAGE RPBP_STREAM
IS

   FUNCTION GETRATEUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETRESVBLOCKFORMATIONVALUE(
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FINDREFANALYSISSTREAM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPBP_STREAM;

/



CREATE or REPLACE PACKAGE BODY RPBP_STREAM
IS

   FUNCTION GETRATEUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_STREAM.GETRATEUOM      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RATE_TYPE );
         RETURN ret_value;
   END GETRATEUOM;
   FUNCTION GETRESVBLOCKFORMATIONVALUE(
      P_BLOCK_ID IN VARCHAR2,
      P_FORMATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_STREAM.GETRESVBLOCKFORMATIONVALUE      (
         P_BLOCK_ID,
         P_FORMATION_ID );
         RETURN ret_value;
   END GETRESVBLOCKFORMATIONVALUE;
   FUNCTION FINDREFANALYSISSTREAM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_STREAM.FINDREFANALYSISSTREAM      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDREFANALYSISSTREAM;

END RPBP_STREAM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_STREAM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.34.34 AM


