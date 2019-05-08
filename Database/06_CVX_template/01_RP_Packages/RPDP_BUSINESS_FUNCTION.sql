
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.30 AM


CREATE or REPLACE PACKAGE RPDP_BUSINESS_FUNCTION
IS

   FUNCTION GETBUSINESSFUNCTIONNO(
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCOMPCODEFROMBFCA(
      P_BF_COMPONENT_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CREATEBFCOMPONENTACTION(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2,
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETBFCODEFROMBFCA(
      P_BF_COMPONENT_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETBF_COMPONENTNO(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCMI_BFCOMPONENTACTION(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2,
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;

END RPDP_BUSINESS_FUNCTION;

/



CREATE or REPLACE PACKAGE BODY RPDP_BUSINESS_FUNCTION
IS

   FUNCTION GETBUSINESSFUNCTIONNO(
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.GETBUSINESSFUNCTIONNO      (
         P_BF_CODE );
         RETURN ret_value;
   END GETBUSINESSFUNCTIONNO;
   FUNCTION GETCOMPCODEFROMBFCA(
      P_BF_COMPONENT_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.GETCOMPCODEFROMBFCA      (
         P_BF_COMPONENT_ACTION_NO );
         RETURN ret_value;
   END GETCOMPCODEFROMBFCA;
   FUNCTION CREATEBFCOMPONENTACTION(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2,
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.CREATEBFCOMPONENTACTION      (
         P_BF_CODE,
         P_COMP_CODE,
         P_ITEM_CODE );
         RETURN ret_value;
   END CREATEBFCOMPONENTACTION;
   FUNCTION GETBFCODEFROMBFCA(
      P_BF_COMPONENT_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.GETBFCODEFROMBFCA      (
         P_BF_COMPONENT_ACTION_NO );
         RETURN ret_value;
   END GETBFCODEFROMBFCA;
   FUNCTION GETBF_COMPONENTNO(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.GETBF_COMPONENTNO      (
         P_BF_CODE,
         P_COMP_CODE );
         RETURN ret_value;
   END GETBF_COMPONENTNO;
   FUNCTION GETCMI_BFCOMPONENTACTION(
      P_BF_CODE IN VARCHAR2,
      P_COMP_CODE IN VARCHAR2,
      P_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BUSINESS_FUNCTION.GETCMI_BFCOMPONENTACTION      (
         P_BF_CODE,
         P_COMP_CODE,
         P_ITEM_CODE );
         RETURN ret_value;
   END GETCMI_BFCOMPONENTACTION;

END RPDP_BUSINESS_FUNCTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_BUSINESS_FUNCTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.31 AM


