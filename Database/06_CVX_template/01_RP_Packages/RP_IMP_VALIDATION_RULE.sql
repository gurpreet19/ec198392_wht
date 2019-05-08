
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.37 AM


CREATE or REPLACE PACKAGE RP_IMP_VALIDATION_RULE
IS

   FUNCTION SORT_ORDER(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_BOOLEAN(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_STRING(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION IMP_SOURCE_MAPPING_NO(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         IMP_VALIDATION_RULE_NO NUMBER ,
         IMP_SOURCE_MAPPING_NO NUMBER ,
         SORT_ORDER NUMBER ,
         NAME VARCHAR2 (2000) ,
         EXCEPTION_LEVEL VARCHAR2 (32) ,
         VALUE_STRING VARCHAR2 (2000) ,
         VALUE_DATE  DATE ,
         VALUE_NUMBER NUMBER ,
         VALUE_BOOLEAN VARCHAR2 (3) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_DATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_NUMBER(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXCEPTION_LEVEL(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_IMP_VALIDATION_RULE;

/



CREATE or REPLACE PACKAGE BODY RP_IMP_VALIDATION_RULE
IS

   FUNCTION SORT_ORDER(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.SORT_ORDER      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.APPROVAL_BY      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.APPROVAL_STATE      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.NAME      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION VALUE_BOOLEAN(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.VALUE_BOOLEAN      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END VALUE_BOOLEAN;
   FUNCTION VALUE_STRING(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.VALUE_STRING      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END VALUE_STRING;
   FUNCTION IMP_SOURCE_MAPPING_NO(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.IMP_SOURCE_MAPPING_NO      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END IMP_SOURCE_MAPPING_NO;
   FUNCTION RECORD_STATUS(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.RECORD_STATUS      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.APPROVAL_DATE      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.ROW_BY_PK      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.REC_ID      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_DATE(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.VALUE_DATE      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END VALUE_DATE;
   FUNCTION VALUE_NUMBER(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.VALUE_NUMBER      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END VALUE_NUMBER;
   FUNCTION EXCEPTION_LEVEL(
      P_IMP_VALIDATION_RULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_VALIDATION_RULE.EXCEPTION_LEVEL      (
         P_IMP_VALIDATION_RULE_NO );
         RETURN ret_value;
   END EXCEPTION_LEVEL;

END RP_IMP_VALIDATION_RULE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IMP_VALIDATION_RULE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.40 AM


