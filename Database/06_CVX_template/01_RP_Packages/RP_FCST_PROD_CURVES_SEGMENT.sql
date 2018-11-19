
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.41.54 AM


CREATE or REPLACE PACKAGE RP_FCST_PROD_CURVES_SEGMENT
IS

   FUNCTION INPUT_TF(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PHASE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION FCST_CURVE_ID(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_QF(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CURVE_SHAPE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION INPUT_DI(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION INPUT_B(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION RATIO(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION INPUT_QI(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         FCST_SEGMENT_ID NUMBER ,
         FCST_CURVE_ID NUMBER ,
         SEGMENT NUMBER ,
         PHASE VARCHAR2 (32) ,
         CURVE_SHAPE VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         RATIO NUMBER ,
         INPUT_QI NUMBER ,
         INPUT_B NUMBER ,
         INPUT_DI NUMBER ,
         INPUT_TF NUMBER ,
         CALC_QF NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SEGMENT(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;

END RP_FCST_PROD_CURVES_SEGMENT;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_PROD_CURVES_SEGMENT
IS

   FUNCTION INPUT_TF(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.INPUT_TF      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END INPUT_TF;
   FUNCTION PHASE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.PHASE      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END PHASE;
   FUNCTION TEXT_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.TEXT_3      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.TEXT_4      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.APPROVAL_BY      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.APPROVAL_STATE      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_5      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION FCST_CURVE_ID(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.FCST_CURVE_ID      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END FCST_CURVE_ID;
   FUNCTION CALC_QF(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.CALC_QF      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END CALC_QF;
   FUNCTION COMMENTS(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.COMMENTS      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION CURVE_SHAPE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.CURVE_SHAPE      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END CURVE_SHAPE;
   FUNCTION DATE_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.DATE_3      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.DATE_5      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION INPUT_DI(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.INPUT_DI      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END INPUT_DI;
   FUNCTION VALUE_6(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_6      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.DATE_2      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION INPUT_B(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.INPUT_B      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END INPUT_B;
   FUNCTION RATIO(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.RATIO      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END RATIO;
   FUNCTION RECORD_STATUS(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.RECORD_STATUS      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_1      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.APPROVAL_DATE      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION INPUT_QI(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.INPUT_QI      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END INPUT_QI;
   FUNCTION ROW_BY_PK(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.ROW_BY_PK      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SEGMENT(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.SEGMENT      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END SEGMENT;
   FUNCTION VALUE_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_2      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_3      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_4      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CLASS_NAME(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.CLASS_NAME      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION DATE_4(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.DATE_4      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.REC_ID      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.TEXT_1      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.TEXT_2      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_7      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_9      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.DATE_1      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_10      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES_SEGMENT.VALUE_8      (
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_PROD_CURVES_SEGMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_PROD_CURVES_SEGMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.42.02 AM


