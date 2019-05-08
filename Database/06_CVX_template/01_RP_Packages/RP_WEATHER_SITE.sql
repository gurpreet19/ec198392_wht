
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.24.38 AM


CREATE or REPLACE PACKAGE RP_WEATHER_SITE
IS

   FUNCTION FACILITY_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         FACILITY_ID VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         FACILITY_ID VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_WEATHER_SITE;

/



CREATE or REPLACE PACKAGE BODY RP_WEATHER_SITE
IS

   FUNCTION FACILITY_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.FACILITY_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END FACILITY_ID;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.TEXT_3      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.TEXT_4      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_5      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_6      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_1      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WEATHER_SITE.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.DESCRIPTION      (
         P_OBJECT_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_WEATHER_SITE.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WEATHER_SITE.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_2      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_3      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_4      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.TEXT_1      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WEATHER_SITE.TEXT_2      (
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_7      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_9      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_10      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEATHER_SITE.VALUE_8      (
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_WEATHER_SITE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WEATHER_SITE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.24.43 AM


