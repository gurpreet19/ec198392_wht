
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.07.08 AM


CREATE or REPLACE PACKAGE RP_EC_JBPM_LOG
IS

   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CODE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VARIABLES_ADDED(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VARIABLES_REMOVED(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION COLOR(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PROCESS_ID NUMBER ,
         NODE_NAME VARCHAR2 (1024) ,
         ENTER  DATE ,
         LEAVE  DATE ,
         CODE NUMBER ,
         STATUS VARCHAR2 (1024) ,
         COLOR VARCHAR2 (1024) ,
         NODE_TYPE VARCHAR2 (1024) ,
         VARIABLES_ADDED VARCHAR2 (3072) ,
         VARIABLES_REMOVED VARCHAR2 (3072) ,
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
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ENTER(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION LEAVE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION NODE_TYPE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_EC_JBPM_LOG;

/



CREATE or REPLACE PACKAGE BODY RP_EC_JBPM_LOG
IS

   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.APPROVAL_BY      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.APPROVAL_STATE      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CODE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.CODE      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END CODE;
   FUNCTION VARIABLES_ADDED(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3072) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.VARIABLES_ADDED      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END VARIABLES_ADDED;
   FUNCTION VARIABLES_REMOVED(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3072) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.VARIABLES_REMOVED      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END VARIABLES_REMOVED;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.RECORD_STATUS      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.APPROVAL_DATE      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION COLOR(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1024) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.COLOR      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END COLOR;
   FUNCTION ROW_BY_PK(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.ROW_BY_PK      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.REC_ID      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION STATUS(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1024) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.STATUS      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END STATUS;
   FUNCTION ENTER(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.ENTER      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END ENTER;
   FUNCTION LEAVE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.LEAVE      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END LEAVE;
   FUNCTION NODE_TYPE(
      P_PROCESS_ID IN NUMBER,
      P_NODE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1024) ;
   BEGIN
      ret_value := EC_EC_JBPM_LOG.NODE_TYPE      (
         P_PROCESS_ID,
         P_NODE_NAME );
         RETURN ret_value;
   END NODE_TYPE;

END RP_EC_JBPM_LOG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_EC_JBPM_LOG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.07.11 AM


