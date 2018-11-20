
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.21.49 AM


CREATE or REPLACE PACKAGE RPDP_PPA_PRICE
IS

   FUNCTION GENPRICEADJUSTMENTDOC(
      P_CONTRACT_ID IN VARCHAR2,
      P_PERIOD_FROM IN DATE,
      P_PERIOD_TO IN DATE,
      P_USER IN VARCHAR2,
      P_LOG_ITEM_NO IN OUT NUMBER,
      P_NAV_ID IN VARCHAR2,
      P_DOCUMENT_KEY IN VARCHAR2 DEFAULT NULL,
      P_LOG_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_PPA_PRICE;

/



CREATE or REPLACE PACKAGE BODY RPDP_PPA_PRICE
IS

   FUNCTION GENPRICEADJUSTMENTDOC(
      P_CONTRACT_ID IN VARCHAR2,
      P_PERIOD_FROM IN DATE,
      P_PERIOD_TO IN DATE,
      P_USER IN VARCHAR2,
      P_LOG_ITEM_NO IN OUT NUMBER,
      P_NAV_ID IN VARCHAR2,
      P_DOCUMENT_KEY IN VARCHAR2 DEFAULT NULL,
      P_LOG_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PPA_PRICE.GENPRICEADJUSTMENTDOC      (
         P_CONTRACT_ID,
         P_PERIOD_FROM,
         P_PERIOD_TO,
         P_USER,
         P_LOG_ITEM_NO,
         P_NAV_ID,
         P_DOCUMENT_KEY,
         P_LOG_TYPE );
         RETURN ret_value;
   END GENPRICEADJUSTMENTDOC;

END RPDP_PPA_PRICE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PPA_PRICE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.21.50 AM

