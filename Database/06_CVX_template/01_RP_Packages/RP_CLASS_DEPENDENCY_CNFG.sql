
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.38 AM


CREATE or REPLACE PACKAGE RP_CLASS_DEPENDENCY_CNFG
IS

   FUNCTION APPROVAL_BY(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PARENT_CLASS VARCHAR2 (24) ,
         CHILD_CLASS VARCHAR2 (24) ,
         DEPENDENCY_TYPE VARCHAR2 (32) ,
         APP_SPACE_CNTX VARCHAR2 (32) ,
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
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION APP_SPACE_CNTX(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_DEPENDENCY_CNFG;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_DEPENDENCY_CNFG
IS

   FUNCTION APPROVAL_BY(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.APPROVAL_BY      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.APPROVAL_STATE      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.RECORD_STATUS      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.APPROVAL_DATE      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.ROW_BY_PK      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION APP_SPACE_CNTX(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.APP_SPACE_CNTX      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END APP_SPACE_CNTX;
   FUNCTION REC_ID(
      P_PARENT_CLASS IN VARCHAR2,
      P_CHILD_CLASS IN VARCHAR2,
      P_DEPENDENCY_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_DEPENDENCY_CNFG.REC_ID      (
         P_PARENT_CLASS,
         P_CHILD_CLASS,
         P_DEPENDENCY_TYPE );
         RETURN ret_value;
   END REC_ID;

END RP_CLASS_DEPENDENCY_CNFG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_DEPENDENCY_CNFG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.40 AM


