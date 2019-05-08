
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.43.57 AM


CREATE or REPLACE PACKAGE RP_CONTRACT
IS

   FUNCTION TEMPLATE_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PROJECT_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION BF_PROFILE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_YEAR(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SALE_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         START_YEAR NUMBER ,
         TRAN_IND VARCHAR2 (1) ,
         SALE_IND VARCHAR2 (1) ,
         REVN_IND VARCHAR2 (1) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         BF_PROFILE VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
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
         PROJECT_IND VARCHAR2 (1)  );
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         START_YEAR NUMBER ,
         TRAN_IND VARCHAR2 (1) ,
         SALE_IND VARCHAR2 (1) ,
         REVN_IND VARCHAR2 (1) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         BF_PROFILE VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
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
         PROJECT_IND VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TRAN_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REVN_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CONTRACT;

/



CREATE or REPLACE PACKAGE BODY RP_CONTRACT
IS

   FUNCTION TEMPLATE_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT.TEMPLATE_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TEMPLATE_CODE;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONTRACT.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION PROJECT_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.PROJECT_IND      (
         P_OBJECT_ID );
         RETURN ret_value;
   END PROJECT_IND;
   FUNCTION BF_PROFILE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT.BF_PROFILE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END BF_PROFILE;
   FUNCTION START_YEAR(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT.START_YEAR      (
         P_OBJECT_ID );
         RETURN ret_value;
   END START_YEAR;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT.END_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT.OBJECT_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_CODE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SALE_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.SALE_IND      (
         P_OBJECT_ID );
         RETURN ret_value;
   END SALE_IND;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT.START_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END START_DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONTRACT.DESCRIPTION      (
         P_OBJECT_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_CONTRACT.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONTRACT.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TRAN_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.TRAN_IND      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TRAN_IND;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT.OBJECT_ID_BY_UK      (
         P_OBJECT_CODE );
         RETURN ret_value;
   END OBJECT_ID_BY_UK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REVN_IND(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT.REVN_IND      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REVN_IND;

END RP_CONTRACT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONTRACT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.44.02 AM


