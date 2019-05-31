
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.28 AM


CREATE or REPLACE PACKAGE RPDP_MATRIX
IS

   FUNCTION EMPTYCELLINMATRIX(
      P_ROW IN INTEGER ,
      P_COL IN INTEGER )
      RETURN BOOLEAN;
   FUNCTION CELL(
      P_ROW IN INTEGER ,
      P_COL IN INTEGER )
      RETURN NUMBER;

END RPDP_MATRIX;

/



CREATE or REPLACE PACKAGE BODY RPDP_MATRIX
IS

   FUNCTION EMPTYCELLINMATRIX(
      P_ROW IN INTEGER ,
      P_COL IN INTEGER )
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_MATRIX.EMPTYCELLINMATRIX      (
         P_ROW,
         P_COL );
         RETURN ret_value;
   END EMPTYCELLINMATRIX;
   FUNCTION CELL(
      P_ROW IN INTEGER ,
      P_COL IN INTEGER )
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_MATRIX.CELL      (
         P_ROW,
         P_COL );
         RETURN ret_value;
   END CELL;

END RPDP_MATRIX;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_MATRIX TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.29 AM


