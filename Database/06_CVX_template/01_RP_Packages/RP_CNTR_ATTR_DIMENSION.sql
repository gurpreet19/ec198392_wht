
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.57.49 AM


CREATE or REPLACE PACKAGE RP_CNTR_ATTR_DIMENSION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION ATTRIBUTE_STRING(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ATTRIBUTE_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION ATTRIBUTE_NUMBER(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         ATTRIBUTE_NAME VARCHAR2 (24) ,
         DIM_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         ATTRIBUTE_STRING VARCHAR2 (240) ,
         ATTRIBUTE_DATE  DATE ,
         ATTRIBUTE_NUMBER NUMBER ,
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
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         ATTRIBUTE_NAME VARCHAR2 (24) ,
         DIM_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         ATTRIBUTE_STRING VARCHAR2 (240) ,
         ATTRIBUTE_DATE  DATE ,
         ATTRIBUTE_NUMBER NUMBER ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_CNTR_ATTR_DIMENSION;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_ATTR_DIMENSION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.TEXT_3      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.TEXT_4      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_5      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ATTRIBUTE_STRING(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.ATTRIBUTE_STRING      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ATTRIBUTE_STRING;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION ATTRIBUTE_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.ATTRIBUTE_DATE      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ATTRIBUTE_DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_6      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ATTRIBUTE_NUMBER(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.ATTRIBUTE_NUMBER      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ATTRIBUTE_NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.DATE_2      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.END_DATE      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_1      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_2      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_3      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_4      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.REC_ID      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.TEXT_1      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.TEXT_2      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_7      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_9      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.DATE_1      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_10      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_DIM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_ATTR_DIMENSION.VALUE_8      (
         P_OBJECT_ID,
         P_ATTRIBUTE_NAME,
         P_DIM_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_CNTR_ATTR_DIMENSION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_ATTR_DIMENSION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.57.55 AM


