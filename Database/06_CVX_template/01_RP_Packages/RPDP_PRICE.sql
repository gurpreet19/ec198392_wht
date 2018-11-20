
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.21.47 AM


CREATE or REPLACE PACKAGE RPDP_PRICE
IS

   FUNCTION ISPRICEELEMSUMGROUP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPRICEELEMVAL(
      P_PRICE_ELEM_ID IN VARCHAR2,
      P_PRICE_STRUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETUNITPRICE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT IN VARCHAR2,
      P_PRICE_ELEMENT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION ISEDITABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT IN VARCHAR2,
      P_PRICE_ELEMENT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPRICESTRUCTVAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_PRICE;

/



CREATE or REPLACE PACKAGE BODY RPDP_PRICE
IS

   FUNCTION ISPRICEELEMSUMGROUP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PRICE.ISPRICEELEMSUMGROUP      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISPRICEELEMSUMGROUP;
   FUNCTION GETPRICEELEMVAL(
      P_PRICE_ELEM_ID IN VARCHAR2,
      P_PRICE_STRUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRICE.GETPRICEELEMVAL      (
         P_PRICE_ELEM_ID,
         P_PRICE_STRUCT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPRICEELEMVAL;
   FUNCTION GETUNITPRICE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT IN VARCHAR2,
      P_PRICE_ELEMENT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRICE.GETUNITPRICE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT,
         P_PRICE_ELEMENT,
         P_DAYTIME );
         RETURN ret_value;
   END GETUNITPRICE;
   FUNCTION ISEDITABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT IN VARCHAR2,
      P_PRICE_ELEMENT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PRICE.ISEDITABLE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT,
         P_PRICE_ELEMENT,
         P_DAYTIME );
         RETURN ret_value;
   END ISEDITABLE;
   FUNCTION GETPRICESTRUCTVAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRICE.GETPRICESTRUCTVAL      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPRICESTRUCTVAL;

END RPDP_PRICE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PRICE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.21.48 AM

