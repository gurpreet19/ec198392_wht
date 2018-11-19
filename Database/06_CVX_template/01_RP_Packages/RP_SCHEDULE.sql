
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.01.44 AM


CREATE or REPLACE PACKAGE RP_SCHEDULE
IS

   FUNCTION LOG_LEVEL(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION IGNORE_MISFIRE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RETAIN_COUNT(
      P_SCHEDULE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION USER_TOKEN(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ENABLED_IND(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PIN_TO(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         SCHEDULE_NO NUMBER ,
         NAME VARCHAR2 (240) ,
         SCHEDULE_GROUP VARCHAR2 (32) ,
         SCHEDULE_TYPE VARCHAR2 (32) ,
         RUN_AS_USER VARCHAR2 (30) ,
         NOTIFY_LEVEL_CODE VARCHAR2 (32) ,
         NOTIFY_USER VARCHAR2 (30) ,
         NOTIFY_ROLE VARCHAR2 (30) ,
         LOG_LEVEL VARCHAR2 (32) ,
         RETAIN_COUNT NUMBER ,
         IGNORE_MISFIRE VARCHAR2 (1) ,
         PIN_TO VARCHAR2 (1000) ,
         ENABLED_IND VARCHAR2 (1) ,
         DESCRIPTION VARCHAR2 (240) ,
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
         USER_TOKEN VARCHAR2 (4000)  );
   FUNCTION ROW_BY_PK(
      P_SCHEDULE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCHEDULE_TYPE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOTIFY_LEVEL_CODE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOTIFY_USER(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RUN_AS_USER(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOTIFY_ROLE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULE_GROUP(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_SCHEDULE;

/



CREATE or REPLACE PACKAGE BODY RP_SCHEDULE
IS

   FUNCTION LOG_LEVEL(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE.LOG_LEVEL      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END LOG_LEVEL;
   FUNCTION APPROVAL_BY(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCHEDULE.APPROVAL_BY      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE.APPROVAL_STATE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION IGNORE_MISFIRE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE.IGNORE_MISFIRE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END IGNORE_MISFIRE;
   FUNCTION RETAIN_COUNT(
      P_SCHEDULE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCHEDULE.RETAIN_COUNT      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END RETAIN_COUNT;
   FUNCTION USER_TOKEN(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_SCHEDULE.USER_TOKEN      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END USER_TOKEN;
   FUNCTION ENABLED_IND(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE.ENABLED_IND      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END ENABLED_IND;
   FUNCTION PIN_TO(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_SCHEDULE.PIN_TO      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END PIN_TO;
   FUNCTION RECORD_STATUS(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE.RECORD_STATUS      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE.APPROVAL_DATE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCHEDULE.DESCRIPTION      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION NAME(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCHEDULE.NAME      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_SCHEDULE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_SCHEDULE.ROW_BY_PK      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCHEDULE_TYPE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE.SCHEDULE_TYPE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END SCHEDULE_TYPE;
   FUNCTION NOTIFY_LEVEL_CODE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE.NOTIFY_LEVEL_CODE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END NOTIFY_LEVEL_CODE;
   FUNCTION NOTIFY_USER(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCHEDULE.NOTIFY_USER      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END NOTIFY_USER;
   FUNCTION REC_ID(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE.REC_ID      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION RUN_AS_USER(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCHEDULE.RUN_AS_USER      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END RUN_AS_USER;
   FUNCTION NOTIFY_ROLE(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCHEDULE.NOTIFY_ROLE      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END NOTIFY_ROLE;
   FUNCTION SCHEDULE_GROUP(
      P_SCHEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE.SCHEDULE_GROUP      (
         P_SCHEDULE_NO );
         RETURN ret_value;
   END SCHEDULE_GROUP;

END RP_SCHEDULE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_SCHEDULE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.01.49 AM


