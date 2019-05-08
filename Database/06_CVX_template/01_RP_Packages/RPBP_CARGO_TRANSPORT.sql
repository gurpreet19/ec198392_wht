
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.28 AM


CREATE or REPLACE PACKAGE RPBP_CARGO_TRANSPORT
IS

   FUNCTION GETCARGONO(
      P_CARGO_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCARGONAME(
      P_CARGO_NO IN NUMBER,
      P_PARCELS IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETCARRIERLAYTIME(
      P_CARRIER_ID IN VARCHAR2,
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETCARRIERLAYTIMEDATE(
      P_CARRIER_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETFIRSTNOMDATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GETLIFTINGACCOUNT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETSTORAGES(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETCARRIERNAME(
      P_CARRIER_ID IN VARCHAR2,
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETDATEDIFF(
      P_FROM_DATE IN DATE,
      P_TO_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETLASTNOMDATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;

END RPBP_CARGO_TRANSPORT;

/



CREATE or REPLACE PACKAGE BODY RPBP_CARGO_TRANSPORT
IS

   FUNCTION GETCARGONO(
      P_CARGO_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETCARGONO      (
         P_CARGO_NAME );
         RETURN ret_value;
   END GETCARGONO;
   FUNCTION GETCARGONAME(
      P_CARGO_NO IN NUMBER,
      P_PARCELS IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETCARGONAME      (
         P_CARGO_NO,
         P_PARCELS,
         P_FORECAST_ID );
         RETURN ret_value;
   END GETCARGONAME;
   FUNCTION GETCARRIERLAYTIME(
      P_CARRIER_ID IN VARCHAR2,
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETCARRIERLAYTIME      (
         P_CARRIER_ID,
         P_CARGO_NO );
         RETURN ret_value;
   END GETCARRIERLAYTIME;
   FUNCTION GETCARRIERLAYTIMEDATE(
      P_CARRIER_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETCARRIERLAYTIMEDATE      (
         P_CARRIER_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETCARRIERLAYTIMEDATE;
   FUNCTION GETFIRSTNOMDATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETFIRSTNOMDATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END GETFIRSTNOMDATE;
   FUNCTION GETLIFTINGACCOUNT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETLIFTINGACCOUNT      (
         P_CARGO_NO );
         RETURN ret_value;
   END GETLIFTINGACCOUNT;
   FUNCTION GETSTORAGES(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETSTORAGES      (
         P_CARGO_NO );
         RETURN ret_value;
   END GETSTORAGES;
   FUNCTION GETCARRIERNAME(
      P_CARRIER_ID IN VARCHAR2,
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETCARRIERNAME      (
         P_CARRIER_ID,
         P_CARGO_NO );
         RETURN ret_value;
   END GETCARRIERNAME;
   FUNCTION GETDATEDIFF(
      P_FROM_DATE IN DATE,
      P_TO_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETDATEDIFF      (
         P_FROM_DATE,
         P_TO_DATE );
         RETURN ret_value;
   END GETDATEDIFF;
   FUNCTION GETLASTNOMDATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECBP_CARGO_TRANSPORT.GETLASTNOMDATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END GETLASTNOMDATE;

END RPBP_CARGO_TRANSPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_CARGO_TRANSPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.31 AM


