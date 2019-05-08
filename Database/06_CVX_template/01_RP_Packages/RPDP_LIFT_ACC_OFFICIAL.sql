
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.37 AM


CREATE or REPLACE PACKAGE RPDP_LIFT_ACC_OFFICIAL
IS

   FUNCTION ISMISSINGOFFICIALNUMBERS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;

END RPDP_LIFT_ACC_OFFICIAL;

/



CREATE or REPLACE PACKAGE BODY RPDP_LIFT_ACC_OFFICIAL
IS

   FUNCTION ISMISSINGOFFICIALNUMBERS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_LIFT_ACC_OFFICIAL.ISMISSINGOFFICIALNUMBERS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISMISSINGOFFICIALNUMBERS;
   FUNCTION GETDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_LIFT_ACC_OFFICIAL.GETDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFICIAL_TYPE );
         RETURN ret_value;
   END GETDAY;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_LIFT_ACC_OFFICIAL.GETTOTALMONTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFICIAL_TYPE,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETTOTALMONTH;

END RPDP_LIFT_ACC_OFFICIAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_LIFT_ACC_OFFICIAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.38 AM


