
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.16 AM


CREATE or REPLACE PACKAGE RPDP_PINC
IS

   FUNCTION GETINSTALLMODETAG
      RETURN VARCHAR2;
   FUNCTION COMPUTEMD5(
      P_OBJECT IN BLOB)
      RETURN VARCHAR2;
   FUNCTION GETLIVETAG(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETLIVESRC(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN BLOB;
   FUNCTION GETMD5BYTAG(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_TAG IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETREP_TEST(
      P_REPORTNAME IN VARCHAR2,
      P_DAYTIME IN TIMESTAMP,
      P_TYPEFILTER IN VARCHAR2,
      P_NAMEFILTER IN VARCHAR2,
      P_TAG IN VARCHAR2)
      RETURN CLOB;
   FUNCTION GETMD5BYDAYTIME(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_DAYTIME IN TIMESTAMP)
      RETURN VARCHAR2;
   FUNCTION ENABLEINSTALLMODESQLLDR(
      P_TAG IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLIVEMD5(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION ISINSTALLMODE
      RETURN BOOLEAN;

END RPDP_PINC;

/



CREATE or REPLACE PACKAGE BODY RPDP_PINC
IS

   FUNCTION GETINSTALLMODETAG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PINC.GETINSTALLMODETAG ;
         RETURN ret_value;
   END GETINSTALLMODETAG;
   FUNCTION COMPUTEMD5(
      P_OBJECT IN BLOB)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.COMPUTEMD5      (
         P_OBJECT );
         RETURN ret_value;
   END COMPUTEMD5;
   FUNCTION GETLIVETAG(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.GETLIVETAG      (
         P_TYPE,
         P_NAME,
         P_KEY );
         RETURN ret_value;
   END GETLIVETAG;
   FUNCTION GETLIVESRC(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := ECDP_PINC.GETLIVESRC      (
         P_TYPE,
         P_NAME,
         P_KEY );
         RETURN ret_value;
   END GETLIVESRC;
   FUNCTION GETMD5BYTAG(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_TAG IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.GETMD5BYTAG      (
         P_TYPE,
         P_NAME,
         P_TAG );
         RETURN ret_value;
   END GETMD5BYTAG;
   FUNCTION GETREP_TEST(
      P_REPORTNAME IN VARCHAR2,
      P_DAYTIME IN TIMESTAMP,
      P_TYPEFILTER IN VARCHAR2,
      P_NAMEFILTER IN VARCHAR2,
      P_TAG IN VARCHAR2)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := ECDP_PINC.GETREP_TEST      (
         P_REPORTNAME,
         P_DAYTIME,
         P_TYPEFILTER,
         P_NAMEFILTER,
         P_TAG );
         RETURN ret_value;
   END GETREP_TEST;
   FUNCTION GETMD5BYDAYTIME(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_DAYTIME IN TIMESTAMP)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.GETMD5BYDAYTIME      (
         P_TYPE,
         P_NAME,
         P_DAYTIME );
         RETURN ret_value;
   END GETMD5BYDAYTIME;
   FUNCTION ENABLEINSTALLMODESQLLDR(
      P_TAG IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.ENABLEINSTALLMODESQLLDR      (
         P_TAG );
         RETURN ret_value;
   END ENABLEINSTALLMODESQLLDR;
   FUNCTION GETLIVEMD5(
      P_TYPE IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PINC.GETLIVEMD5      (
         P_TYPE,
         P_NAME,
         P_KEY );
         RETURN ret_value;
   END GETLIVEMD5;
   FUNCTION ISINSTALLMODE
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN

         ret_value := ECDP_PINC.ISINSTALLMODE ;
         RETURN ret_value;
   END ISINSTALLMODE;

END RPDP_PINC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PINC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.18 AM


