
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.50 AM


CREATE or REPLACE PACKAGE RPDP_VIEWLAYER_UTILS
IS

   FUNCTION RESOLVEPRIORITY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2,
      P_ROOT_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TABLEEXISTS(
      P_NAME IN VARCHAR2,
      P_OWNER IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION JNCOLUMNLIST(
      P_UE_USER_FUNCTION IN VARCHAR2,
      P_ALIAS IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION COUNTDIRTYCLASSES(
      P_CLASS_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2 DEFAULT 'VIEWLAYER',
      P_APP_SPACE_CNTX IN VARCHAR2 DEFAULT NULL)
      RETURN INTEGER;
   FUNCTION GETDIRTYCLASSES(
      P_CLASS_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2 DEFAULT 'VIEWLAYER',
      P_APP_SPACE_CNTX IN VARCHAR2 DEFAULT NULL)
      RETURN ECDP_VIEWLAYER_UTILS.DIRTYMAP_T;
   FUNCTION HASAPPSPACEFOOTPRINT(
      P_CLASS_NAME IN VARCHAR2,
      P_APP_SPACE_CNTX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION INSTALLORDER(
      P_APP_SPACE_CNTX IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VIEWEXISTS(
      P_NAME IN VARCHAR2,
      P_OWNER IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION COLUMNEXISTS(
      P_TABLE_NAME IN VARCHAR2,
      P_COLUMN_NAME IN VARCHAR2,
      P_TABLE_OWNER IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION IS_DIRTY(
      P_OBJECT_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2)
      RETURN BOOLEAN;

END RPDP_VIEWLAYER_UTILS;

/



CREATE or REPLACE PACKAGE BODY RPDP_VIEWLAYER_UTILS
IS

   FUNCTION RESOLVEPRIORITY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2,
      P_ROOT_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.RESOLVEPRIORITY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME,
         P_ROOT_CLASS_NAME,
         P_PROPERTY_CODE );
         RETURN ret_value;
   END RESOLVEPRIORITY;
   FUNCTION TABLEEXISTS(
      P_NAME IN VARCHAR2,
      P_OWNER IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.TABLEEXISTS      (
         P_NAME,
         P_OWNER );
         RETURN ret_value;
   END TABLEEXISTS;
   FUNCTION JNCOLUMNLIST(
      P_UE_USER_FUNCTION IN VARCHAR2,
      P_ALIAS IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.JNCOLUMNLIST      (
         P_UE_USER_FUNCTION,
         P_ALIAS );
         RETURN ret_value;
   END JNCOLUMNLIST;
   FUNCTION COUNTDIRTYCLASSES(
      P_CLASS_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2 DEFAULT 'VIEWLAYER',
      P_APP_SPACE_CNTX IN VARCHAR2 DEFAULT NULL)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.COUNTDIRTYCLASSES      (
         P_CLASS_NAME,
         P_DIRTY_TYPE,
         P_APP_SPACE_CNTX );
         RETURN ret_value;
   END COUNTDIRTYCLASSES;
   FUNCTION GETDIRTYCLASSES(
      P_CLASS_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2 DEFAULT 'VIEWLAYER',
      P_APP_SPACE_CNTX IN VARCHAR2 DEFAULT NULL)
      RETURN ECDP_VIEWLAYER_UTILS.DIRTYMAP_T
   IS
      ret_value    ECDP_VIEWLAYER_UTILS.DIRTYMAP_T ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.GETDIRTYCLASSES      (
         P_CLASS_NAME,
         P_DIRTY_TYPE,
         P_APP_SPACE_CNTX );
         RETURN ret_value;
   END GETDIRTYCLASSES;
   FUNCTION HASAPPSPACEFOOTPRINT(
      P_CLASS_NAME IN VARCHAR2,
      P_APP_SPACE_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.HASAPPSPACEFOOTPRINT      (
         P_CLASS_NAME,
         P_APP_SPACE_CNTX );
         RETURN ret_value;
   END HASAPPSPACEFOOTPRINT;
   FUNCTION INSTALLORDER(
      P_APP_SPACE_CNTX IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.INSTALLORDER      (
         P_APP_SPACE_CNTX );
         RETURN ret_value;
   END INSTALLORDER;
   FUNCTION VIEWEXISTS(
      P_NAME IN VARCHAR2,
      P_OWNER IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.VIEWEXISTS      (
         P_NAME,
         P_OWNER );
         RETURN ret_value;
   END VIEWEXISTS;
   FUNCTION COLUMNEXISTS(
      P_TABLE_NAME IN VARCHAR2,
      P_COLUMN_NAME IN VARCHAR2,
      P_TABLE_OWNER IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.COLUMNEXISTS      (
         P_TABLE_NAME,
         P_COLUMN_NAME,
         P_TABLE_OWNER );
         RETURN ret_value;
   END COLUMNEXISTS;
   FUNCTION IS_DIRTY(
      P_OBJECT_NAME IN VARCHAR2,
      P_DIRTY_TYPE IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_VIEWLAYER_UTILS.IS_DIRTY      (
         P_OBJECT_NAME,
         P_DIRTY_TYPE );
         RETURN ret_value;
   END IS_DIRTY;

END RPDP_VIEWLAYER_UTILS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_VIEWLAYER_UTILS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.53 AM

