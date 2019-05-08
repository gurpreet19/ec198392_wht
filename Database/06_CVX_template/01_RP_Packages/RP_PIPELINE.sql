
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.23.34 AM


CREATE or REPLACE PACKAGE RP_PIPELINE
IS

   FUNCTION TO_NODE_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DIAMETER(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FLUID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FROM_NODE_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
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
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LENGTH(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         TO_NODE_ID VARCHAR2 (32) ,
         FROM_NODE_ID VARCHAR2 (32) ,
         DIAMETER NUMBER ,
         FLUID NUMBER ,
         LENGTH NUMBER ,
         VOLUME NUMBER ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         TO_NODE_ID VARCHAR2 (32) ,
         FROM_NODE_ID VARCHAR2 (32) ,
         DIAMETER NUMBER ,
         FLUID NUMBER ,
         LENGTH NUMBER ,
         VOLUME NUMBER ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VOLUME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_PIPELINE;

/



CREATE or REPLACE PACKAGE BODY RP_PIPELINE
IS

   FUNCTION TO_NODE_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PIPELINE.TO_NODE_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TO_NODE_ID;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PIPELINE.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PIPELINE.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DIAMETER(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PIPELINE.DIAMETER      (
         P_OBJECT_ID );
         RETURN ret_value;
   END DIAMETER;
   FUNCTION FLUID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PIPELINE.FLUID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END FLUID;
   FUNCTION FROM_NODE_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PIPELINE.FROM_NODE_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END FROM_NODE_ID;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PIPELINE.END_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION OBJECT_CODE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PIPELINE.OBJECT_CODE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_CODE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PIPELINE.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PIPELINE.START_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END START_DATE;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PIPELINE.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PIPELINE.DESCRIPTION      (
         P_OBJECT_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION LENGTH(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PIPELINE.LENGTH      (
         P_OBJECT_ID );
         RETURN ret_value;
   END LENGTH;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_PIPELINE.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PIPELINE.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION OBJECT_ID_BY_UK(
      P_OBJECT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PIPELINE.OBJECT_ID_BY_UK      (
         P_OBJECT_CODE );
         RETURN ret_value;
   END OBJECT_ID_BY_UK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PIPELINE.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VOLUME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PIPELINE.VOLUME      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VOLUME;

END RP_PIPELINE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PIPELINE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.23.41 AM


