
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.55.18 AM


CREATE or REPLACE PACKAGE RP_CALENDAR_RECURRING_HOLIDAYS
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FIXED_HOLIDAY_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECURRING_HOLIDAY_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_FUNCTION_HOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         RECURRING_HOLIDAY_NO NUMBER ,
         RECURRING_HOLIDAY_NAME VARCHAR2 (240) ,
         FIXED_HOLIDAY_MONTH VARCHAR2 (3) ,
         FIXED_HOLIDAY_DAY NUMBER (2) ,
         DATE_FUNCTION_HOLIDAY VARCHAR2 (20) ,
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
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION FIXED_HOLIDAY_MONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_CALENDAR_RECURRING_HOLIDAYS;

/



CREATE or REPLACE PACKAGE BODY RP_CALENDAR_RECURRING_HOLIDAYS
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.APPROVAL_BY      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FIXED_HOLIDAY_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER (2) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.FIXED_HOLIDAY_DAY      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END FIXED_HOLIDAY_DAY;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.COMMENTS      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION RECURRING_HOLIDAY_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.RECURRING_HOLIDAY_NAME      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END RECURRING_HOLIDAY_NAME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.RECORD_STATUS      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_FUNCTION_HOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (20) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.DATE_FUNCTION_HOLIDAY      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END DATE_FUNCTION_HOLIDAY;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.ROW_BY_PK      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION FIXED_HOLIDAY_MONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.FIXED_HOLIDAY_MONTH      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END FIXED_HOLIDAY_MONTH;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RECURRING_HOLIDAY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALENDAR_RECURRING_HOLIDAYS.REC_ID      (
         P_OBJECT_ID,
         P_RECURRING_HOLIDAY_NO );
         RETURN ret_value;
   END REC_ID;

END RP_CALENDAR_RECURRING_HOLIDAYS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALENDAR_RECURRING_HOLIDAYS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.55.20 AM


