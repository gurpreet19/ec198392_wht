
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.12 AM


CREATE or REPLACE PACKAGE RP_PTST_GRAPH_DEFINE
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RANGE_MIN(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION INC_PLOT(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RANGE_MAX(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN DATE;
   FUNCTION AUTORANGE_IND(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEST_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         PARAMETER VARCHAR2 (32) ,
         RANGE_MAX NUMBER ,
         RANGE_MIN NUMBER ,
         AUTORANGE_IND VARCHAR2 (1) ,
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
         REC_ID VARCHAR2 (32) ,
         INC_PLOT VARCHAR2 (1) ,
         FORCE_SEPARATE_AXIS VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FORCE_SEPARATE_AXIS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER;

END RP_PTST_GRAPH_DEFINE;

/



CREATE or REPLACE PACKAGE BODY RP_PTST_GRAPH_DEFINE
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.TEXT_3      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.TEXT_4      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.APPROVAL_BY      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.APPROVAL_STATE      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_5      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION RANGE_MIN(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.RANGE_MIN      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END RANGE_MIN;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_6      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION INC_PLOT(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.INC_PLOT      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END INC_PLOT;
   FUNCTION RANGE_MAX(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.RANGE_MAX      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END RANGE_MAX;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.RECORD_STATUS      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_1      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.APPROVAL_DATE      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION AUTORANGE_IND(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.AUTORANGE_IND      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END AUTORANGE_IND;
   FUNCTION ROW_BY_PK(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.ROW_BY_PK      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_2      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_3      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_4      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION FORCE_SEPARATE_AXIS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.FORCE_SEPARATE_AXIS      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END FORCE_SEPARATE_AXIS;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.REC_ID      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.TEXT_1      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.TEXT_2      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_7      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_9      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_10      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_GRAPH_DEFINE.VALUE_8      (
         P_TEST_NO,
         P_OBJECT_ID,
         P_PARAMETER );
         RETURN ret_value;
   END VALUE_8;

END RP_PTST_GRAPH_DEFINE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PTST_GRAPH_DEFINE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.17 AM


