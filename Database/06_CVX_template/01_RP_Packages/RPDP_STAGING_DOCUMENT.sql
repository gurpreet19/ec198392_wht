
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.52 AM


CREATE or REPLACE PACKAGE RPDP_STAGING_DOCUMENT
IS

   FUNCTION GETTRANSTEMPLATEID(
      P_CONTRACT_DOC_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPDP_STAGING_DOCUMENT;

/



CREATE or REPLACE PACKAGE BODY RPDP_STAGING_DOCUMENT
IS

   FUNCTION GETTRANSTEMPLATEID(
      P_CONTRACT_DOC_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_STAGING_DOCUMENT.GETTRANSTEMPLATEID      (
         P_CONTRACT_DOC_ID,
         P_PRICE_CONCEPT_CODE,
         P_DELIVERY_POINT_ID,
         P_PRODUCT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETTRANSTEMPLATEID;

END RPDP_STAGING_DOCUMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STAGING_DOCUMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.53 AM


