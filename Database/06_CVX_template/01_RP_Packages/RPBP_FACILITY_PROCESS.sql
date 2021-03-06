
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.47 AM


CREATE or REPLACE PACKAGE RPBP_FACILITY_PROCESS
IS

   FUNCTION GETCOMPONENTKFACTOR2(
      P_PROCESS_TRAIN_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETCOMPONENTKFACTOR1(
      P_PROCESS_TRAIN_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_FACILITY_PROCESS;

/



CREATE or REPLACE PACKAGE BODY RPBP_FACILITY_PROCESS
IS

   FUNCTION GETCOMPONENTKFACTOR2(
      P_PROCESS_TRAIN_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FACILITY_PROCESS.GETCOMPONENTKFACTOR2      (
         P_PROCESS_TRAIN_ID,
         P_COMPONENT_NO,
         P_DAYTIME );
         RETURN ret_value;
   END GETCOMPONENTKFACTOR2;
   FUNCTION GETCOMPONENTKFACTOR1(
      P_PROCESS_TRAIN_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FACILITY_PROCESS.GETCOMPONENTKFACTOR1      (
         P_PROCESS_TRAIN_ID,
         P_COMPONENT_NO,
         P_DAYTIME );
         RETURN ret_value;
   END GETCOMPONENTKFACTOR1;

END RPBP_FACILITY_PROCESS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_FACILITY_PROCESS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.48 AM


