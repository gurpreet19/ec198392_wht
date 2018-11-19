
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.29.47 AM


CREATE or REPLACE PACKAGE RP_COMPONENT_CONSTANT
IS

   FUNCTION IDEAL_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CONV_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION IDEAL_GCV_MJ_TONNES(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION IDEAL_NCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION IDEAL_NCV_MJ_TONNES(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMP_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REL_CV_FRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION IDEAL_GCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MOL_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GAS_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MOL_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION OIL_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION SPEC_GRAVITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NCVM(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         COMPONENT_NO VARCHAR2 (16) ,
         DAYTIME  DATE ,
         MOL_WT NUMBER ,
         MOL_VOL NUMBER ,
         SPEC_GRAVITY NUMBER ,
         COMP_FACTOR NUMBER ,
         IDEAL_DENSITY NUMBER ,
         SUM_FACTOR NUMBER ,
         IDEAL_GCV NUMBER ,
         IDEAL_NCV_MJ_TONNES NUMBER ,
         IDEAL_GCV_MJ_TONNES NUMBER ,
         IDEAL_NCV NUMBER ,
         OIL_DENSITY NUMBER ,
         GAS_DENSITY NUMBER ,
         ZMW NUMBER ,
         GCV NUMBER ,
         NCV NUMBER ,
         GCVM NUMBER ,
         NCVM NUMBER ,
         REL_CV_FRAC NUMBER ,
         CONV_FACTOR NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         COMPONENT_NO VARCHAR2 (16) ,
         DAYTIME  DATE ,
         MOL_WT NUMBER ,
         MOL_VOL NUMBER ,
         SPEC_GRAVITY NUMBER ,
         COMP_FACTOR NUMBER ,
         IDEAL_DENSITY NUMBER ,
         SUM_FACTOR NUMBER ,
         IDEAL_GCV NUMBER ,
         IDEAL_NCV_MJ_TONNES NUMBER ,
         IDEAL_GCV_MJ_TONNES NUMBER ,
         IDEAL_NCV NUMBER ,
         OIL_DENSITY NUMBER ,
         GAS_DENSITY NUMBER ,
         ZMW NUMBER ,
         GCV NUMBER ,
         NCV NUMBER ,
         GCVM NUMBER ,
         NCVM NUMBER ,
         REL_CV_FRAC NUMBER ,
         CONV_FACTOR NUMBER ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION SUM_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GCVM(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION ZMW(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_COMPONENT_CONSTANT;

/



CREATE or REPLACE PACKAGE BODY RP_COMPONENT_CONSTANT
IS

   FUNCTION IDEAL_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.IDEAL_DENSITY      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END IDEAL_DENSITY;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.TEXT_3      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.TEXT_4      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CONV_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.CONV_FACTOR      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CONV_FACTOR;
   FUNCTION IDEAL_GCV_MJ_TONNES(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.IDEAL_GCV_MJ_TONNES      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END IDEAL_GCV_MJ_TONNES;
   FUNCTION IDEAL_NCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.IDEAL_NCV      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END IDEAL_NCV;
   FUNCTION IDEAL_NCV_MJ_TONNES(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.IDEAL_NCV_MJ_TONNES      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END IDEAL_NCV_MJ_TONNES;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_5      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMP_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.COMP_FACTOR      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMP_FACTOR;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION REL_CV_FRAC(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.REL_CV_FRAC      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REL_CV_FRAC;
   FUNCTION GCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.GCV      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GCV;
   FUNCTION IDEAL_GCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.IDEAL_GCV      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END IDEAL_GCV;
   FUNCTION MOL_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.MOL_VOL      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MOL_VOL;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_6      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION GAS_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.GAS_DENSITY      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GAS_DENSITY;
   FUNCTION MOL_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.MOL_WT      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MOL_WT;
   FUNCTION NCV(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.NCV      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END NCV;
   FUNCTION OIL_DENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.OIL_DENSITY      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OIL_DENSITY;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPEC_GRAVITY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.SPEC_GRAVITY      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SPEC_GRAVITY;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_1      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NCVM(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.NCVM      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END NCVM;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION SUM_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.SUM_FACTOR      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SUM_FACTOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_2      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_3      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_4      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.REC_ID      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.TEXT_1      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.TEXT_2      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_7      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_9      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION GCVM(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.GCVM      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GCVM;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_10      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.VALUE_8      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION ZMW(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPONENT_NO IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_COMPONENT_CONSTANT.ZMW      (
         P_OBJECT_ID,
         P_COMPONENT_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ZMW;

END RP_COMPONENT_CONSTANT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_COMPONENT_CONSTANT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.29.56 AM


