
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.32 AM


CREATE or REPLACE PACKAGE RPDP_CHEMICAL_PRODUCT
IS

   FUNCTION GETPRODUCTTYPE(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETASSETVOLUME(
      P_ASSET IN VARCHAR2,
      P_ASSET_OBJECT_ID IN VARCHAR2,
      P_REC_DOSAGE_METHOD IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETCONSUMEDVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETCLOSINGVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETFILLEDVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETOPENINGVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETPRODUCTCODE(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETPRODUCTNAME(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETDEFAULTUOM(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

END RPDP_CHEMICAL_PRODUCT;

/



CREATE or REPLACE PACKAGE BODY RPDP_CHEMICAL_PRODUCT
IS

   FUNCTION GETPRODUCTTYPE(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETPRODUCTTYPE      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPRODUCTTYPE;
   FUNCTION GETASSETVOLUME(
      P_ASSET IN VARCHAR2,
      P_ASSET_OBJECT_ID IN VARCHAR2,
      P_REC_DOSAGE_METHOD IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETASSETVOLUME      (
         P_ASSET,
         P_ASSET_OBJECT_ID,
         P_REC_DOSAGE_METHOD,
         P_DAYTIME );
         RETURN ret_value;
   END GETASSETVOLUME;
   FUNCTION GETCONSUMEDVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETCONSUMEDVOL      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME,
         P_UOM );
         RETURN ret_value;
   END GETCONSUMEDVOL;
   FUNCTION GETCLOSINGVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETCLOSINGVOL      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME,
         P_UOM );
         RETURN ret_value;
   END GETCLOSINGVOL;
   FUNCTION GETFILLEDVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETFILLEDVOL      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME,
         P_UOM );
         RETURN ret_value;
   END GETFILLEDVOL;
   FUNCTION GETOPENINGVOL(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_UOM IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETOPENINGVOL      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME,
         P_UOM );
         RETURN ret_value;
   END GETOPENINGVOL;
   FUNCTION GETPRODUCTCODE(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETPRODUCTCODE      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPRODUCTCODE;
   FUNCTION GETPRODUCTNAME(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETPRODUCTNAME      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPRODUCTNAME;
   FUNCTION GETDEFAULTUOM(
      P_PRODUCT_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CHEMICAL_PRODUCT.GETDEFAULTUOM      (
         P_PRODUCT_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETDEFAULTUOM;

END RPDP_CHEMICAL_PRODUCT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CHEMICAL_PRODUCT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.34 AM


