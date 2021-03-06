
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.52 AM


CREATE or REPLACE PACKAGE RPBP_ENTITLEMENT
IS

   FUNCTION REAL_PROD_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FIND_DAY_ECO_SHARE(
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CALC_DAY_BALANCE(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PROD_PLAN IN VARCHAR2,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GET_LIFTED_VOLUME(
      P_ACCOUNT_NO IN VARCHAR2,
      P_STORAGE_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION CALC_PRODUCTION_PROD(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FORCAST_PROD_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALC_PRODUCTION(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_NO IN VARCHAR2,
      P_PROD_PLAN IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FIND_START_DATE(
      P_ACCOUNT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GET_PRODUCTION_BY_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_DAY IN DATE)
      RETURN NUMBER;

END RPBP_ENTITLEMENT;

/



CREATE or REPLACE PACKAGE BODY RPBP_ENTITLEMENT
IS

   FUNCTION REAL_PROD_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.REAL_PROD_DAY      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_DAYTIME );
         RETURN ret_value;
   END REAL_PROD_DAY;
   FUNCTION FIND_DAY_ECO_SHARE(
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.FIND_DAY_ECO_SHARE      (
         P_SHIPPER,
         P_COMPANY_ID,
         P_DAY,
         P_PHASE );
         RETURN ret_value;
   END FIND_DAY_ECO_SHARE;
   FUNCTION CALC_DAY_BALANCE(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PROD_PLAN IN VARCHAR2,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.CALC_DAY_BALANCE      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_COMPANY_ID,
         P_ACCOUNT_NO,
         P_DAYTIME,
         P_PROD_PLAN,
         P_PHASE );
         RETURN ret_value;
   END CALC_DAY_BALANCE;
   FUNCTION GET_LIFTED_VOLUME(
      P_ACCOUNT_NO IN VARCHAR2,
      P_STORAGE_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.GET_LIFTED_VOLUME      (
         P_ACCOUNT_NO,
         P_STORAGE_ID,
         P_FROM_DAY,
         P_TO_DAY );
         RETURN ret_value;
   END GET_LIFTED_VOLUME;
   FUNCTION CALC_PRODUCTION_PROD(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.CALC_PRODUCTION_PROD      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_COMPANY_ID,
         P_PLAN,
         P_FROM_DAY,
         P_TO_DAY,
         P_PHASE );
         RETURN ret_value;
   END CALC_PRODUCTION_PROD;
   FUNCTION FORCAST_PROD_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.FORCAST_PROD_DAY      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_PLAN,
         P_DAYTIME );
         RETURN ret_value;
   END FORCAST_PROD_DAY;
   FUNCTION CALC_PRODUCTION(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_NO IN VARCHAR2,
      P_PROD_PLAN IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.CALC_PRODUCTION      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_COMPANY_ID,
         P_ACCOUNT_NO,
         P_PROD_PLAN,
         P_FROM_DAY,
         P_TO_DAY,
         P_PHASE );
         RETURN ret_value;
   END CALC_PRODUCTION;
   FUNCTION FIND_START_DATE(
      P_ACCOUNT_NO IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.FIND_START_DATE      (
         P_ACCOUNT_NO,
         P_DAYTIME );
         RETURN ret_value;
   END FIND_START_DATE;
   FUNCTION GET_PRODUCTION_BY_DAY(
      P_STORAGE_ID IN VARCHAR2,
      P_SHIPPER IN VARCHAR2,
      P_PLAN IN VARCHAR2,
      P_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_ENTITLEMENT.GET_PRODUCTION_BY_DAY      (
         P_STORAGE_ID,
         P_SHIPPER,
         P_PLAN,
         P_DAY );
         RETURN ret_value;
   END GET_PRODUCTION_BY_DAY;

END RPBP_ENTITLEMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_ENTITLEMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.54 AM


