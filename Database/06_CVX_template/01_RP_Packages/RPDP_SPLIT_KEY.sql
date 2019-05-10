
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.53 AM


CREATE or REPLACE PACKAGE RPDP_SPLIT_KEY
IS

   FUNCTION GETSPLITSHAREMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SOURCE_SPLIT_UOM_CODE IN VARCHAR2 DEFAULT NULL,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY')
      RETURN NUMBER;
   FUNCTION INSNEWSPLITKEYCOPY(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE DEFAULT NULL,
      P_USER IN VARCHAR2,
      P_COPY_FIRST_VERSION_ONLY IN BOOLEAN DEFAULT FALSE)
      RETURN VARCHAR2;
   FUNCTION CHECKSPLITUOMS(
      P_OBJECT_ID IN VARCHAR2,
      P_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSPLITSHAREDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION INSNEWSPLITKEYITEM(
      P_OBJECT_CODE IN VARCHAR2,
      P_OBJECT_NAME IN VARCHAR2 DEFAULT NULL,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETTOTSHAREMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY')
      RETURN NUMBER;
   FUNCTION INSNEWSPLITKEY(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE,
      P_USER IN VARCHAR2,
      P_OBJECT_NAME IN VARCHAR2 DEFAULT NULL,
      P_SPLIT_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SETOBJCODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSPLITVALUEMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY',
      P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT 'SPLIT_VALUE_MTH')
      RETURN NUMBER;

END RPDP_SPLIT_KEY;

/



CREATE or REPLACE PACKAGE BODY RPDP_SPLIT_KEY
IS

   FUNCTION GETSPLITSHAREMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SOURCE_SPLIT_UOM_CODE IN VARCHAR2 DEFAULT NULL,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.GETSPLITSHAREMTH      (
         P_OBJECT_ID,
         P_TARGET_ID,
         P_DAYTIME,
         P_SOURCE_SPLIT_UOM_CODE,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETSPLITSHAREMTH;
   FUNCTION INSNEWSPLITKEYCOPY(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE DEFAULT NULL,
      P_USER IN VARCHAR2,
      P_COPY_FIRST_VERSION_ONLY IN BOOLEAN DEFAULT FALSE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.INSNEWSPLITKEYCOPY      (
         P_OBJECT_ID,
         P_OBJECT_CODE,
         P_START_DATE,
         P_END_DATE,
         P_USER,
         P_COPY_FIRST_VERSION_ONLY );
         RETURN ret_value;
   END INSNEWSPLITKEYCOPY;
   FUNCTION CHECKSPLITUOMS(
      P_OBJECT_ID IN VARCHAR2,
      P_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.CHECKSPLITUOMS      (
         P_OBJECT_ID,
         P_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END CHECKSPLITUOMS;
   FUNCTION GETSPLITSHAREDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.GETSPLITSHAREDAY      (
         P_OBJECT_ID,
         P_TARGET_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSPLITSHAREDAY;
   FUNCTION INSNEWSPLITKEYITEM(
      P_OBJECT_CODE IN VARCHAR2,
      P_OBJECT_NAME IN VARCHAR2 DEFAULT NULL,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.INSNEWSPLITKEYITEM      (
         P_OBJECT_CODE,
         P_OBJECT_NAME,
         P_START_DATE,
         P_END_DATE,
         P_USER );
         RETURN ret_value;
   END INSNEWSPLITKEYITEM;
   FUNCTION GETTOTSHAREMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.GETTOTSHAREMTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETTOTSHAREMTH;
   FUNCTION INSNEWSPLITKEY(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_START_DATE IN DATE,
      P_END_DATE IN DATE,
      P_USER IN VARCHAR2,
      P_OBJECT_NAME IN VARCHAR2 DEFAULT NULL,
      P_SPLIT_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.INSNEWSPLITKEY      (
         P_OBJECT_ID,
         P_OBJECT_CODE,
         P_START_DATE,
         P_END_DATE,
         P_USER,
         P_OBJECT_NAME,
         P_SPLIT_TYPE );
         RETURN ret_value;
   END INSNEWSPLITKEY;
   FUNCTION SETOBJCODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.SETOBJCODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END SETOBJCODE;
   FUNCTION GETSPLITVALUEMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_TARGET_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ROLE_NAME IN VARCHAR2 DEFAULT 'SPLIT_KEY',
      P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT 'SPLIT_VALUE_MTH')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_SPLIT_KEY.GETSPLITVALUEMTH      (
         P_OBJECT_ID,
         P_TARGET_ID,
         P_DAYTIME,
         P_ROLE_NAME,
         P_ATTRIBUTE_TYPE );
         RETURN ret_value;
   END GETSPLITVALUEMTH;

END RPDP_SPLIT_KEY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_SPLIT_KEY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.55 AM

