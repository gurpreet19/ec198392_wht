
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.13.52 AM


CREATE or REPLACE PACKAGE RP_LAYTIME_LIMIT
IS

   FUNCTION TEXT_3(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION MAX_VOL(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LAYTIME IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         LAYTIME VARCHAR2 (16) ,
         MAX_VOL NUMBER ,
         MIN_VOL NUMBER ,
         MAX_LAYTIME NUMBER ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_LAYTIME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MIN_VOL(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION MAX_LAYTIME(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER;

END RP_LAYTIME_LIMIT;

/



CREATE or REPLACE PACKAGE BODY RP_LAYTIME_LIMIT
IS

   FUNCTION TEXT_3(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.TEXT_3      (
         P_LAYTIME );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.TEXT_4      (
         P_LAYTIME );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.APPROVAL_BY      (
         P_LAYTIME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.APPROVAL_STATE      (
         P_LAYTIME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION MAX_VOL(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.MAX_VOL      (
         P_LAYTIME );
         RETURN ret_value;
   END MAX_VOL;
   FUNCTION VALUE_5(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_5      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_6      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.RECORD_STATUS      (
         P_LAYTIME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_1      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_LAYTIME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.APPROVAL_DATE      (
         P_LAYTIME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_LAYTIME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.ROW_BY_PK      (
         P_LAYTIME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_2      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_3      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_4      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION MIN_VOL(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.MIN_VOL      (
         P_LAYTIME );
         RETURN ret_value;
   END MIN_VOL;
   FUNCTION REC_ID(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.REC_ID      (
         P_LAYTIME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.TEXT_1      (
         P_LAYTIME );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_LAYTIME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.TEXT_2      (
         P_LAYTIME );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_7      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_9      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION MAX_LAYTIME(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.MAX_LAYTIME      (
         P_LAYTIME );
         RETURN ret_value;
   END MAX_LAYTIME;
   FUNCTION VALUE_10(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_10      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_LAYTIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LAYTIME_LIMIT.VALUE_8      (
         P_LAYTIME );
         RETURN ret_value;
   END VALUE_8;

END RP_LAYTIME_LIMIT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LAYTIME_LIMIT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.13.57 AM


