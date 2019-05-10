
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.04 AM


CREATE or REPLACE PACKAGE RPDP_CLIENT_PRESENTATION
IS

   FUNCTION GETCOMPONENTFULLNAMELABEL(
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCOMPONENTEXTNAME(
      P_COMPONENT_EXT_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDURATION(
      FROM_DATE IN DATE,
      TO_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPRESENTATIONSYNTAX(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2,
      POPUP_DEPENDENCY IN VARCHAR2 DEFAULT NULL,
      NAVIGATOR_VALUE IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETNAME(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2,
      PARAMETER_VALUE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETNAMEBYTYPE(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_CLIENT_PRESENTATION;

/



CREATE or REPLACE PACKAGE BODY RPDP_CLIENT_PRESENTATION
IS

   FUNCTION GETCOMPONENTFULLNAMELABEL(
      P_COMPONENT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETCOMPONENTFULLNAMELABEL      (
         P_COMPONENT_ID );
         RETURN ret_value;
   END GETCOMPONENTFULLNAMELABEL;
   FUNCTION GETCOMPONENTEXTNAME(
      P_COMPONENT_EXT_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETCOMPONENTEXTNAME      (
         P_COMPONENT_EXT_NAME );
         RETURN ret_value;
   END GETCOMPONENTEXTNAME;
   FUNCTION GETDURATION(
      FROM_DATE IN DATE,
      TO_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETDURATION      (
         FROM_DATE,
         TO_DATE );
         RETURN ret_value;
   END GETDURATION;
   FUNCTION GETPRESENTATIONSYNTAX(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2,
      POPUP_DEPENDENCY IN VARCHAR2 DEFAULT NULL,
      NAVIGATOR_VALUE IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETPRESENTATIONSYNTAX      (
         PARAMETER_TYPE,
         PARAMETER_SUB_TYPE,
         POPUP_DEPENDENCY,
         NAVIGATOR_VALUE );
         RETURN ret_value;
   END GETPRESENTATIONSYNTAX;
   FUNCTION GETNAME(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2,
      PARAMETER_VALUE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETNAME      (
         PARAMETER_TYPE,
         PARAMETER_SUB_TYPE,
         PARAMETER_VALUE );
         RETURN ret_value;
   END GETNAME;
   FUNCTION GETNAMEBYTYPE(
      PARAMETER_TYPE IN VARCHAR2,
      PARAMETER_SUB_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLIENT_PRESENTATION.GETNAMEBYTYPE      (
         PARAMETER_TYPE,
         PARAMETER_SUB_TYPE );
         RETURN ret_value;
   END GETNAMEBYTYPE;

END RPDP_CLIENT_PRESENTATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CLIENT_PRESENTATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.06 AM

