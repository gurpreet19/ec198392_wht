
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.55.54 AM


CREATE or REPLACE PACKAGE RP_CALC_VAR_WRITE_MAPPING
IS

   FUNCTION PROD_DAY_ATTR_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ALWAYS_INSERT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DIM5_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DIM4_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CALC_VAR_SIGNATURE VARCHAR2 (240) ,
         CALC_DATASET VARCHAR2 (32) ,
         CLS_NAME VARCHAR2 (24) ,
         SQL_SYNTAX VARCHAR2 (32) ,
         ALWAYS_INSERT_IND VARCHAR2 (1) ,
         DIM3_TRIGGER_IND VARCHAR2 (1) ,
         DIM4_TRIGGER_IND VARCHAR2 (1) ,
         DIM5_TRIGGER_IND VARCHAR2 (1) ,
         PROD_DAY_ATTR_NAME VARCHAR2 (24) ,
         SUB_DAILY_IND VARCHAR2 (1) ,
         SUMMER_TIME_ATTR_NAME VARCHAR2 (24) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
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
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION SUB_DAILY_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DIM3_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION SUMMER_TIME_ATTR_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CALC_VAR_WRITE_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_VAR_WRITE_MAPPING
IS

   FUNCTION PROD_DAY_ATTR_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.PROD_DAY_ATTR_NAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END PROD_DAY_ATTR_NAME;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_3      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.APPROVAL_BY      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REF_OBJECT_ID_4      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.VALUE_5      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ALWAYS_INSERT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.ALWAYS_INSERT_IND      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END ALWAYS_INSERT_IND;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_7      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_8      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DATE_3      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DATE_5      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REF_OBJECT_ID_2      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REF_OBJECT_ID_3      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_1      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_6      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_9      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DATE_2      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DIM5_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DIM5_TRIGGER_IND      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DIM5_TRIGGER_IND;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.RECORD_STATUS      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REF_OBJECT_ID_5      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.SQL_SYNTAX      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END SQL_SYNTAX;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.VALUE_1      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DIM4_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DIM4_TRIGGER_IND      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DIM4_TRIGGER_IND;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REF_OBJECT_ID_1      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.ROW_BY_PK      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SUB_DAILY_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.SUB_DAILY_IND      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END SUB_DAILY_IND;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_2      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_4      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_5      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.VALUE_2      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.VALUE_3      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.VALUE_4      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DATE_4      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DIM3_TRIGGER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DIM3_TRIGGER_IND      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DIM3_TRIGGER_IND;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.REC_ID      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.DATE_1      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END DATE_1;
   FUNCTION SUMMER_TIME_ATTR_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.SUMMER_TIME_ATTR_NAME      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END SUMMER_TIME_ATTR_NAME;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CALC_VAR_SIGNATURE IN VARCHAR2,
      P_CALC_DATASET IN VARCHAR2,
      P_CLS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_VAR_WRITE_MAPPING.TEXT_10      (
         P_OBJECT_ID,
         P_CALC_VAR_SIGNATURE,
         P_CALC_DATASET,
         P_CLS_NAME );
         RETURN ret_value;
   END TEXT_10;

END RP_CALC_VAR_WRITE_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_VAR_WRITE_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.56.03 AM


