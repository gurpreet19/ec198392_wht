
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.46 AM


CREATE or REPLACE PACKAGE RP_DATASET_FLOW_DETAIL
IS

   FUNCTION APPROVAL_BY(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PARAMETERS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ATTRIBUTE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         TYPE VARCHAR2 (32) ,
         ID VARCHAR2 (100) ,
         REF_ID VARCHAR2 (2000) ,
         DAYTIME  DATE ,
         CLASS VARCHAR2 (32) ,
         ATTRIBUTE VARCHAR2 (32) ,
         VALUE NUMBER ,
         OBJECT_ID VARCHAR2 (100) ,
         PARAMETERS VARCHAR2 (4000) ,
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
      P_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TYPE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE(
      P_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_ID IN VARCHAR2)
      RETURN DATE;

END RP_DATASET_FLOW_DETAIL;

/



CREATE or REPLACE PACKAGE BODY RP_DATASET_FLOW_DETAIL
IS

   FUNCTION APPROVAL_BY(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.APPROVAL_BY      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.APPROVAL_STATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLASS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.CLASS      (
         P_ID );
         RETURN ret_value;
   END CLASS;
   FUNCTION NEXT_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.NEXT_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.OBJECT_ID      (
         P_ID );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PARAMETERS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.PARAMETERS      (
         P_ID );
         RETURN ret_value;
   END PARAMETERS;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.PREV_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION ATTRIBUTE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.ATTRIBUTE      (
         P_ID );
         RETURN ret_value;
   END ATTRIBUTE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.NEXT_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.PREV_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.RECORD_STATUS      (
         P_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.APPROVAL_DATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.ROW_BY_PK      (
         P_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TYPE(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.TYPE      (
         P_ID );
         RETURN ret_value;
   END TYPE;
   FUNCTION REC_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.REC_ID      (
         P_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_ID(
      P_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.REF_ID      (
         P_ID );
         RETURN ret_value;
   END REF_ID;
   FUNCTION VALUE(
      P_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.VALUE      (
         P_ID );
         RETURN ret_value;
   END VALUE;
   FUNCTION DAYTIME(
      P_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DETAIL.DAYTIME      (
         P_ID );
         RETURN ret_value;
   END DAYTIME;

END RP_DATASET_FLOW_DETAIL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DATASET_FLOW_DETAIL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.50 AM


