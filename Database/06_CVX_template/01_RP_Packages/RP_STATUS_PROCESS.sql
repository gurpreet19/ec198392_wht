
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.57.59 AM


CREATE or REPLACE PACKAGE RP_STATUS_PROCESS
IS

   FUNCTION FROM_RS_LEVEL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TO_RS_LEVEL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION PARENT_PROCESS_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REVERSE_FLAG(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION PROCESS_TEXT(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PROCESS_ID VARCHAR2 (16) ,
         PARENT_PROCESS_ID VARCHAR2 (16) ,
         FROM_RS_LEVEL VARCHAR2 (1) ,
         TO_RS_LEVEL VARCHAR2 (1) ,
         PROD_FCTY_ID VARCHAR2 (32) ,
         PROCESS_TEXT VARCHAR2 (200) ,
         PROCESS_INTERVAL VARCHAR2 (16) ,
         SORT_ORDER NUMBER ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (4000) ,
         TEXT_7 VARCHAR2 (4000) ,
         TEXT_8 VARCHAR2 (4000) ,
         TEXT_9 VARCHAR2 (4000) ,
         TEXT_10 VARCHAR2 (4000) ,
         REVERSE_FLAG VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_PROCESS_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_10(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION PROCESS_INTERVAL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PROD_FCTY_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_STATUS_PROCESS;

/



CREATE or REPLACE PACKAGE BODY RP_STATUS_PROCESS
IS

   FUNCTION FROM_RS_LEVEL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.FROM_RS_LEVEL      (
         P_PROCESS_ID );
         RETURN ret_value;
   END FROM_RS_LEVEL;
   FUNCTION SORT_ORDER(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.SORT_ORDER      (
         P_PROCESS_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_3      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_9(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_9      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.APPROVAL_BY      (
         P_PROCESS_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.APPROVAL_STATE      (
         P_PROCESS_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REF_OBJECT_ID_4      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION TO_RS_LEVEL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TO_RS_LEVEL      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TO_RS_LEVEL;
   FUNCTION VALUE_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.VALUE_5      (
         P_PROCESS_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION PARENT_PROCESS_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.PARENT_PROCESS_ID      (
         P_PROCESS_ID );
         RETURN ret_value;
   END PARENT_PROCESS_ID;
   FUNCTION REVERSE_FLAG(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REVERSE_FLAG      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REVERSE_FLAG;
   FUNCTION REF_OBJECT_ID_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REF_OBJECT_ID_2      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REF_OBJECT_ID_3      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_1      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_6      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.RECORD_STATUS      (
         P_PROCESS_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REF_OBJECT_ID_5      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.VALUE_1      (
         P_PROCESS_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.APPROVAL_DATE      (
         P_PROCESS_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PROCESS_TEXT(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.PROCESS_TEXT      (
         P_PROCESS_ID );
         RETURN ret_value;
   END PROCESS_TEXT;
   FUNCTION REF_OBJECT_ID_1(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REF_OBJECT_ID_1      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_PROCESS_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.ROW_BY_PK      (
         P_PROCESS_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_10(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_10      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_2      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_4      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_5      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_8(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_8      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_2(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.VALUE_2      (
         P_PROCESS_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.VALUE_3      (
         P_PROCESS_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_PROCESS_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.VALUE_4      (
         P_PROCESS_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION PROCESS_INTERVAL(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.PROCESS_INTERVAL      (
         P_PROCESS_ID );
         RETURN ret_value;
   END PROCESS_INTERVAL;
   FUNCTION REC_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.REC_ID      (
         P_PROCESS_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION PROD_FCTY_ID(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.PROD_FCTY_ID      (
         P_PROCESS_ID );
         RETURN ret_value;
   END PROD_FCTY_ID;
   FUNCTION TEXT_7(
      P_PROCESS_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_STATUS_PROCESS.TEXT_7      (
         P_PROCESS_ID );
         RETURN ret_value;
   END TEXT_7;

END RP_STATUS_PROCESS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STATUS_PROCESS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.58.06 AM


