
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.53 AM


CREATE or REPLACE PACKAGE RPDP_UTILITIES
IS

   FUNCTION EXECUTESINGLEROWSTRING(
      P_STATEMENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION EXECUTESINGLEROWNUMBER(
      P_STATEMENT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETTAG(
      P_IN_STRING IN VARCHAR2,
      P_TAG_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISNUMBERUPDATED(
      P_OLD IN NUMBER,
      P_NEW IN NUMBER)
      RETURN BOOLEAN;
   FUNCTION ISVARCHARUPDATED(
      P_OLD IN VARCHAR2,
      P_NEW IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION EXECUTESINGLEROWDATE(
      P_STATEMENT IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETTAGTOKEN(
      P_TAGGED_STRING IN OUT VARCHAR2,
      P_FIND_TAG IN VARCHAR2,
      P_FIELD_SEP IN VARCHAR2,
      P_TAG_SEP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISDATEUPDATED(
      P_OLD IN DATE,
      P_NEW IN DATE)
      RETURN BOOLEAN;
   FUNCTION ISNUMBER(
      P_STRING_REPR IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION GETNEXTTOKEN(
      P_TOKEN_STRING IN OUT VARCHAR2,
      P_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETVALUE(
      P_IN_STRING IN VARCHAR2,
      P_TAG_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_UTILITIES;

/



CREATE or REPLACE PACKAGE BODY RPDP_UTILITIES
IS

   FUNCTION EXECUTESINGLEROWSTRING(
      P_STATEMENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UTILITIES.EXECUTESINGLEROWSTRING      (
         P_STATEMENT );
         RETURN ret_value;
   END EXECUTESINGLEROWSTRING;
   FUNCTION EXECUTESINGLEROWNUMBER(
      P_STATEMENT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_UTILITIES.EXECUTESINGLEROWNUMBER      (
         P_STATEMENT );
         RETURN ret_value;
   END EXECUTESINGLEROWNUMBER;
   FUNCTION GETTAG(
      P_IN_STRING IN VARCHAR2,
      P_TAG_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UTILITIES.GETTAG      (
         P_IN_STRING,
         P_TAG_SEPARATOR );
         RETURN ret_value;
   END GETTAG;
   FUNCTION ISNUMBERUPDATED(
      P_OLD IN NUMBER,
      P_NEW IN NUMBER)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_UTILITIES.ISNUMBERUPDATED      (
         P_OLD,
         P_NEW );
         RETURN ret_value;
   END ISNUMBERUPDATED;
   FUNCTION ISVARCHARUPDATED(
      P_OLD IN VARCHAR2,
      P_NEW IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_UTILITIES.ISVARCHARUPDATED      (
         P_OLD,
         P_NEW );
         RETURN ret_value;
   END ISVARCHARUPDATED;
   FUNCTION EXECUTESINGLEROWDATE(
      P_STATEMENT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_UTILITIES.EXECUTESINGLEROWDATE      (
         P_STATEMENT );
         RETURN ret_value;
   END EXECUTESINGLEROWDATE;
   FUNCTION GETTAGTOKEN(
      P_TAGGED_STRING IN OUT VARCHAR2,
      P_FIND_TAG IN VARCHAR2,
      P_FIELD_SEP IN VARCHAR2,
      P_TAG_SEP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UTILITIES.GETTAGTOKEN      (
         P_TAGGED_STRING,
         P_FIND_TAG,
         P_FIELD_SEP,
         P_TAG_SEP );
         RETURN ret_value;
   END GETTAGTOKEN;
   FUNCTION ISDATEUPDATED(
      P_OLD IN DATE,
      P_NEW IN DATE)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_UTILITIES.ISDATEUPDATED      (
         P_OLD,
         P_NEW );
         RETURN ret_value;
   END ISDATEUPDATED;
   FUNCTION ISNUMBER(
      P_STRING_REPR IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_UTILITIES.ISNUMBER      (
         P_STRING_REPR );
         RETURN ret_value;
   END ISNUMBER;
   FUNCTION GETNEXTTOKEN(
      P_TOKEN_STRING IN OUT VARCHAR2,
      P_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UTILITIES.GETNEXTTOKEN      (
         P_TOKEN_STRING,
         P_SEPARATOR );
         RETURN ret_value;
   END GETNEXTTOKEN;
   FUNCTION GETVALUE(
      P_IN_STRING IN VARCHAR2,
      P_TAG_SEPARATOR IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UTILITIES.GETVALUE      (
         P_IN_STRING,
         P_TAG_SEPARATOR );
         RETURN ret_value;
   END GETVALUE;

END RPDP_UTILITIES;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_UTILITIES TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.56 AM


