
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.42.47 AM


CREATE or REPLACE PACKAGE RP_CONTRACT_CAPACITY
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION LOCATION_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION CAPACITY_TYPE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         LOCATION_ID VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         CAPACITY_TYPE VARCHAR2 (32)  );
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         LOCATION_ID VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         CAPACITY_TYPE VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CONTRACT_CAPACITY;

/



CREATE or REPLACE PACKAGE BODY RP_CONTRACT_CAPACITY
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CONTRACT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.CONTRACT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.END_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION LOCATION_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.LOCATION_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END LOCATION_ID;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.OBJECT_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_CODE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.START_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END START_DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CAPACITY_TYPE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.CAPACITY_TYPE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END CAPACITY_TYPE;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.OBJECT_ID_BY_UK      (
         P_OBJECT_CODE );
         RETURN ret_value;
   END OBJECT_ID_BY_UK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_CAPACITY.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;

END RP_CONTRACT_CAPACITY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONTRACT_CAPACITY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.42.51 AM


