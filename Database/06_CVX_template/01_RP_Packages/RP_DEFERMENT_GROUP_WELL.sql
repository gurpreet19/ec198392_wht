
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.26.21 AM


CREATE or REPLACE PACKAGE RP_DEFERMENT_GROUP_WELL
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         WELL_ID VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;

END RP_DEFERMENT_GROUP_WELL;

/



CREATE or REPLACE PACKAGE BODY RP_DEFERMENT_GROUP_WELL
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.APPROVAL_BY      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.COMMENTS      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.END_DATE      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.RECORD_STATUS      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.ROW_BY_PK      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_WELL_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_GROUP_WELL.REC_ID      (
         P_OBJECT_ID,
         P_WELL_ID,
         P_START_DATE );
         RETURN ret_value;
   END REC_ID;

END RP_DEFERMENT_GROUP_WELL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DEFERMENT_GROUP_WELL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.26.23 AM

