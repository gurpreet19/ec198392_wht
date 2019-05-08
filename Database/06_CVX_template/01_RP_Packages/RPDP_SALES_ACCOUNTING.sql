
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.46.14 AM


CREATE or REPLACE PACKAGE RPDP_SALES_ACCOUNTING
IS

   FUNCTION GETACCOUNTCALCORDER(
      P_CATEGORY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETHOURLYOFFSPECFRACTION(
      P_CONTRACT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETNUMBEROFAPPROVEDACCOUNTS(
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN INTEGER;
   FUNCTION GETDAILYOFFSPECFRACTION(
      P_CONTRACT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_CONTRACT_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION GETNUMBEROFPROCESSEDACCOUNTS(
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN INTEGER;
   FUNCTION ISACCOUNTEDITABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_SALES_ACCOUNTING;

/



CREATE or REPLACE PACKAGE BODY RPDP_SALES_ACCOUNTING
IS

   FUNCTION GETACCOUNTCALCORDER(
      P_CATEGORY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.GETACCOUNTCALCORDER      (
         P_CATEGORY );
         RETURN ret_value;
   END GETACCOUNTCALCORDER;
   FUNCTION GETHOURLYOFFSPECFRACTION(
      P_CONTRACT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.GETHOURLYOFFSPECFRACTION      (
         P_CONTRACT_ID,
         P_DELIVERY_POINT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETHOURLYOFFSPECFRACTION;
   FUNCTION GETNUMBEROFAPPROVEDACCOUNTS(
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.GETNUMBEROFAPPROVEDACCOUNTS      (
         P_CONTRACT_ID,
         P_DAYTIME,
         P_TIME_SPAN );
         RETURN ret_value;
   END GETNUMBEROFAPPROVEDACCOUNTS;
   FUNCTION GETDAILYOFFSPECFRACTION(
      P_CONTRACT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_CONTRACT_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.GETDAILYOFFSPECFRACTION      (
         P_CONTRACT_ID,
         P_DELIVERY_POINT_ID,
         P_CONTRACT_DAY );
         RETURN ret_value;
   END GETDAILYOFFSPECFRACTION;
   FUNCTION GETNUMBEROFPROCESSEDACCOUNTS(
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.GETNUMBEROFPROCESSEDACCOUNTS      (
         P_CONTRACT_ID,
         P_DAYTIME,
         P_TIME_SPAN );
         RETURN ret_value;
   END GETNUMBEROFPROCESSEDACCOUNTS;
   FUNCTION ISACCOUNTEDITABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SALES_ACCOUNTING.ISACCOUNTEDITABLE      (
         P_OBJECT_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN );
         RETURN ret_value;
   END ISACCOUNTEDITABLE;

END RPDP_SALES_ACCOUNTING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_SALES_ACCOUNTING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.46.16 AM


