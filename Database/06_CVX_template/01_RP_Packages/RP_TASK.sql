
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.26.51 AM


CREATE or REPLACE PACKAGE RP_TASK
IS

   FUNCTION SORT_ORDER(
      P_TASK_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TASK_DUE_DATE(
      P_TASK_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TASK_PROCESS_ID(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BUSINESS_FUNCTION_NO(
      P_TASK_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RESPONSIBLE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TASK_DESCRIPTION(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TASK_STATUS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_TASK_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         TASK_NO NUMBER ,
         TASK_TYPE VARCHAR2 (32) ,
         TASK_PROCESS_ID VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         TASK_DESCRIPTION VARCHAR2 (2000) ,
         TASK_DUE_DATE  DATE ,
         TASK_STATUS VARCHAR2 (32) ,
         RESPONSIBLE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         BUSINESS_FUNCTION_NO NUMBER  );
   FUNCTION ROW_BY_PK(
      P_TASK_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TASK_TYPE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_TASK;

/



CREATE or REPLACE PACKAGE BODY RP_TASK
IS

   FUNCTION SORT_ORDER(
      P_TASK_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TASK.SORT_ORDER      (
         P_TASK_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TASK.APPROVAL_BY      (
         P_TASK_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TASK.APPROVAL_STATE      (
         P_TASK_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TASK_DUE_DATE(
      P_TASK_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TASK.TASK_DUE_DATE      (
         P_TASK_NO );
         RETURN ret_value;
   END TASK_DUE_DATE;
   FUNCTION TASK_PROCESS_ID(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TASK.TASK_PROCESS_ID      (
         P_TASK_NO );
         RETURN ret_value;
   END TASK_PROCESS_ID;
   FUNCTION BUSINESS_FUNCTION_NO(
      P_TASK_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TASK.BUSINESS_FUNCTION_NO      (
         P_TASK_NO );
         RETURN ret_value;
   END BUSINESS_FUNCTION_NO;
   FUNCTION RESPONSIBLE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TASK.RESPONSIBLE      (
         P_TASK_NO );
         RETURN ret_value;
   END RESPONSIBLE;
   FUNCTION COMMENTS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TASK.COMMENTS      (
         P_TASK_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION TASK_DESCRIPTION(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TASK.TASK_DESCRIPTION      (
         P_TASK_NO );
         RETURN ret_value;
   END TASK_DESCRIPTION;
   FUNCTION TASK_STATUS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TASK.TASK_STATUS      (
         P_TASK_NO );
         RETURN ret_value;
   END TASK_STATUS;
   FUNCTION RECORD_STATUS(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TASK.RECORD_STATUS      (
         P_TASK_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_TASK_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TASK.APPROVAL_DATE      (
         P_TASK_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_TASK_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TASK.ROW_BY_PK      (
         P_TASK_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TASK.REC_ID      (
         P_TASK_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TASK_TYPE(
      P_TASK_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TASK.TASK_TYPE      (
         P_TASK_NO );
         RETURN ret_value;
   END TASK_TYPE;

END RP_TASK;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TASK TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.26.55 AM


