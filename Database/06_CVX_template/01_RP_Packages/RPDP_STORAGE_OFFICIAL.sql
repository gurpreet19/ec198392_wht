
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.44 AM


CREATE or REPLACE PACKAGE RPDP_STORAGE_OFFICIAL
IS

   FUNCTION GETDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETSTORDAYAVERAGE(
      P_STORAGE_ID IN VARCHAR2,
      P_FIRST_OF_MONTH IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RPDP_STORAGE_OFFICIAL;

/



CREATE or REPLACE PACKAGE BODY RPDP_STORAGE_OFFICIAL
IS

   FUNCTION GETDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_OFFICIAL.GETDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFICIAL_TYPE );
         RETURN ret_value;
   END GETDAY;
   FUNCTION GETSTORDAYAVERAGE(
      P_STORAGE_ID IN VARCHAR2,
      P_FIRST_OF_MONTH IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_OFFICIAL.GETSTORDAYAVERAGE      (
         P_STORAGE_ID,
         P_FIRST_OF_MONTH,
         P_XTRA_QTY,
         P_OFFICIAL_TYPE );
         RETURN ret_value;
   END GETSTORDAYAVERAGE;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_OFFICIAL_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_OFFICIAL.GETTOTALMONTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY,
         P_OFFICIAL_TYPE );
         RETURN ret_value;
   END GETTOTALMONTH;

END RPDP_STORAGE_OFFICIAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STORAGE_OFFICIAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.45 AM


