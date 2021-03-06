
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.55 AM


CREATE or REPLACE PACKAGE RPDP_CONTRACT_ATTRIBUTE
IS

   FUNCTION GETATTRIBUTESTRING(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETATTRIBUTEDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DATE IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETATTRIBUTEVALUEASSTRING(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OBJECT_EC_CODE IN VARCHAR2 default NULL)
      RETURN VARCHAR2;
   FUNCTION GETATTRIBUTENUMBER(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETSUMCNTRQTY(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION GETATTRIBUTEDATE(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;

END RPDP_CONTRACT_ATTRIBUTE;

/



CREATE or REPLACE PACKAGE BODY RPDP_CONTRACT_ATTRIBUTE
IS

   FUNCTION GETATTRIBUTESTRING(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTESTRING      (
         P_CONTRACT_ID,
         P_ATTRIBUTE_NAME,
         P_DAYTIME,
         P_IS_CONTRACT_DATE,
         P_OBJECT_EC_CODE );
         RETURN ret_value;
   END GETATTRIBUTESTRING;
   FUNCTION GETATTRIBUTEDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DATE IN DATE,
      P_TIME_SPAN IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTEDAYTIME      (
         P_OBJECT_ID,
         P_DATE,
         P_TIME_SPAN );
         RETURN ret_value;
   END GETATTRIBUTEDAYTIME;
   FUNCTION GETATTRIBUTEVALUEASSTRING(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OBJECT_EC_CODE IN VARCHAR2 default NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTEVALUEASSTRING      (
         P_CONTRACT_ID,
         P_ATTRIBUTE_NAME,
         P_DAYTIME,
         P_OBJECT_EC_CODE );
         RETURN ret_value;
   END GETATTRIBUTEVALUEASSTRING;
   FUNCTION GETATTRIBUTENUMBER(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER      (
         P_CONTRACT_ID,
         P_ATTRIBUTE_NAME,
         P_DAYTIME,
         P_IS_CONTRACT_DATE,
         P_OBJECT_EC_CODE );
         RETURN ret_value;
   END GETATTRIBUTENUMBER;
   FUNCTION GETSUMCNTRQTY(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETSUMCNTRQTY      (
         P_OBJECT_ID,
         P_CONTRACT_YEAR );
         RETURN ret_value;
   END GETSUMCNTRQTY;
   FUNCTION GETATTRIBUTEDATE(
      P_CONTRACT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_IS_CONTRACT_DATE IN VARCHAR2 DEFAULT 'N',
      P_OBJECT_EC_CODE IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTEDATE      (
         P_CONTRACT_ID,
         P_ATTRIBUTE_NAME,
         P_DAYTIME,
         P_IS_CONTRACT_DATE,
         P_OBJECT_EC_CODE );
         RETURN ret_value;
   END GETATTRIBUTEDATE;

END RPDP_CONTRACT_ATTRIBUTE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CONTRACT_ATTRIBUTE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.57 AM


