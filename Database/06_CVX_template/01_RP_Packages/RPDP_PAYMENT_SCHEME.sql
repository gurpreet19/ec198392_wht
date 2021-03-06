
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.35 AM


CREATE or REPLACE PACKAGE RPDP_PAYMENT_SCHEME
IS

   FUNCTION GETDAYSLATETOTAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DOCUMENT_KEY IN VARCHAR2,
      P_CUSTOMER_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETBOOKEDTOTALMINUSFIXEDV(
      P_OBJECT_ID IN VARCHAR2,
      P_BOOKED_TOTAL IN NUMBER,
      P_PROD_MTH IN DATE)
      RETURN NUMBER;
   FUNCTION GETDAYSOVERDUE(
      P_DATE IN DATE)
      RETURN NUMBER;

END RPDP_PAYMENT_SCHEME;

/



CREATE or REPLACE PACKAGE BODY RPDP_PAYMENT_SCHEME
IS

   FUNCTION GETDAYSLATETOTAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DOCUMENT_KEY IN VARCHAR2,
      P_CUSTOMER_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PAYMENT_SCHEME.GETDAYSLATETOTAL      (
         P_OBJECT_ID,
         P_DOCUMENT_KEY,
         P_CUSTOMER_ID );
         RETURN ret_value;
   END GETDAYSLATETOTAL;
   FUNCTION GETBOOKEDTOTALMINUSFIXEDV(
      P_OBJECT_ID IN VARCHAR2,
      P_BOOKED_TOTAL IN NUMBER,
      P_PROD_MTH IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PAYMENT_SCHEME.GETBOOKEDTOTALMINUSFIXEDV      (
         P_OBJECT_ID,
         P_BOOKED_TOTAL,
         P_PROD_MTH );
         RETURN ret_value;
   END GETBOOKEDTOTALMINUSFIXEDV;
   FUNCTION GETDAYSOVERDUE(
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PAYMENT_SCHEME.GETDAYSOVERDUE      (
         P_DATE );
         RETURN ret_value;
   END GETDAYSOVERDUE;

END RPDP_PAYMENT_SCHEME;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PAYMENT_SCHEME TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.36 AM


