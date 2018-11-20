
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.18.16 AM


CREATE or REPLACE PACKAGE RP_FCTY_EXT_LOCATION_CONN
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         FCTY_OBJECT_ID VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         SORT_ORDER NUMBER (3) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER;

END RP_FCTY_EXT_LOCATION_CONN;

/



CREATE or REPLACE PACKAGE BODY RP_FCTY_EXT_LOCATION_CONN
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.APPROVAL_BY      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.END_DATE      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.RECORD_STATUS      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.ROW_BY_PK      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.REC_ID      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_FCTY_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER (3) ;
   BEGIN
      ret_value := EC_FCTY_EXT_LOCATION_CONN.SORT_ORDER      (
         P_OBJECT_ID,
         P_FCTY_OBJECT_ID,
         P_START_DATE );
         RETURN ret_value;
   END SORT_ORDER;

END RP_FCTY_EXT_LOCATION_CONN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCTY_EXT_LOCATION_CONN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.18.19 AM

