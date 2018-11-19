
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.41.03 AM


CREATE or REPLACE PACKAGE RP_STRM_DPT_CONVERSION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION BG(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION BO(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION SP_GRAV(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VCF(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DENSITY NUMBER ,
         PRESS NUMBER ,
         TEMP NUMBER ,
         BO NUMBER ,
         BG NUMBER ,
         BW NUMBER ,
         RS NUMBER ,
         SP_GRAV NUMBER ,
         VCF NUMBER ,
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
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DENSITY NUMBER ,
         PRESS NUMBER ,
         TEMP NUMBER ,
         BO NUMBER ,
         BG NUMBER ,
         BW NUMBER ,
         RS NUMBER ,
         SP_GRAV NUMBER ,
         VCF NUMBER ,
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
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION RS(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION BW(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_STRM_DPT_CONVERSION;

/



CREATE or REPLACE PACKAGE BODY RP_STRM_DPT_CONVERSION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.TEXT_3      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.TEXT_4      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BG(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.BG      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END BG;
   FUNCTION BO(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.BO      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END BO;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_5      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION SP_GRAV(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.SP_GRAV      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SP_GRAV;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_6      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION VCF(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VCF      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VCF;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_1      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION RS(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.RS      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RS;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_2      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_3      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_4      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BW(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.BW      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END BW;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.REC_ID      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.TEXT_1      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.TEXT_2      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_7      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_9      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_10      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DENSITY IN NUMBER,
      P_PRESS IN NUMBER,
      P_TEMP IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_DPT_CONVERSION.VALUE_8      (
         P_OBJECT_ID,
         P_DENSITY,
         P_PRESS,
         P_TEMP,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_STRM_DPT_CONVERSION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STRM_DPT_CONVERSION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.41.10 AM


