
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.50.59 AM


CREATE or REPLACE PACKAGE RP_OBJECT_GROUP
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OBJECT_CLASS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         OBJECT_CLASS VARCHAR2 (32) ,
         GROUP_TYPE VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_OBJECT_GROUP;

/



CREATE or REPLACE PACKAGE BODY RP_OBJECT_GROUP
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.TEXT_3      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION OBJECT_CLASS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.OBJECT_CLASS      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END OBJECT_CLASS;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.VALUE_5      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.COMMENTS      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.TEXT_1      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.END_DATE      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.VALUE_1      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.TEXT_2      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.TEXT_4      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.TEXT_5      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.VALUE_2      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.VALUE_3      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.VALUE_4      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DATE IN DATE,
      P_GROUP_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_GROUP.REC_ID      (
         P_OBJECT_ID,
         P_START_DATE,
         P_GROUP_TYPE );
         RETURN ret_value;
   END REC_ID;

END RP_OBJECT_GROUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJECT_GROUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.51.08 AM


