
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.02.54 AM


CREATE or REPLACE PACKAGE RP_REPT_SET
IS

   FUNCTION SORT_BY_SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REPT_SET_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRODUCTION_DAY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPT_SET_SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPT_SET_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TIME_SCOPE_CODE_ELEMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TIME_SCOPE_CODE_SET(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION ELEMENT_TIME_SCOPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         REPT_OBJECT_TYPE_CODE VARCHAR2 (32) ,
         REPT_SET_TYPE VARCHAR2 (32) ,
         REPT_SET_SORT_ORDER VARCHAR2 (32) ,
         SORT_BY_SQL_SYNTAX VARCHAR2 (32) ,
         DESCRIPTION_OVERRIDE VARCHAR2 (2000) ,
         REPT_SET_OPERATOR VARCHAR2 (32) ,
         BASE_REPT_SET_NAME VARCHAR2 (240) ,
         TIME_SCOPE_CODE_SET VARCHAR2 (32) ,
         TIME_SCOPE_CODE_ELEMENTS VARCHAR2 (32) ,
         PRODUCTION_DAY_OFFSET NUMBER ,
         ELEMENT_TIME_SCOPE_CODE VARCHAR2 (32) ,
         PRODUCTION_DAY_ID VARCHAR2 (32) ,
         SET_TIME_SCOPE_CODE VARCHAR2 (32) ,
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
      P_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION BASE_REPT_SET_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION PRODUCTION_DAY_OFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPT_OBJECT_TYPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION SET_TIME_SCOPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_REPT_SET;

/



CREATE or REPLACE PACKAGE BODY RP_REPT_SET
IS

   FUNCTION SORT_BY_SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.SORT_BY_SQL_SYNTAX      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END SORT_BY_SQL_SYNTAX;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_3      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPT_SET.APPROVAL_BY      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPT_SET.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REF_OBJECT_ID_4      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.VALUE_5      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION REPT_SET_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REPT_SET_OPERATOR      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REPT_SET_OPERATOR;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_7      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_8      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.DATE_3      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.DATE_5      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DESCRIPTION_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPT_SET.DESCRIPTION_OVERRIDE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DESCRIPTION_OVERRIDE;
   FUNCTION PRODUCTION_DAY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.PRODUCTION_DAY_ID      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END PRODUCTION_DAY_ID;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REF_OBJECT_ID_2      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REF_OBJECT_ID_3      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REPT_SET_SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REPT_SET_SORT_ORDER      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REPT_SET_SORT_ORDER;
   FUNCTION REPT_SET_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REPT_SET_TYPE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REPT_SET_TYPE;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_1      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_6      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_9      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.DATE_2      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPT_SET.RECORD_STATUS      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REF_OBJECT_ID_5      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION TIME_SCOPE_CODE_ELEMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.TIME_SCOPE_CODE_ELEMENTS      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TIME_SCOPE_CODE_ELEMENTS;
   FUNCTION TIME_SCOPE_CODE_SET(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.TIME_SCOPE_CODE_SET      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TIME_SCOPE_CODE_SET;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.VALUE_1      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ELEMENT_TIME_SCOPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.ELEMENT_TIME_SCOPE_CODE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END ELEMENT_TIME_SCOPE_CODE;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REF_OBJECT_ID_1      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPT_SET.ROW_BY_PK      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_2      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_4      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_5      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.VALUE_2      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.VALUE_3      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.VALUE_4      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BASE_REPT_SET_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.BASE_REPT_SET_NAME      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END BASE_REPT_SET_NAME;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.DATE_4      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PRODUCTION_DAY_OFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET.PRODUCTION_DAY_OFFSET      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END PRODUCTION_DAY_OFFSET;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REC_ID      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REPT_OBJECT_TYPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.REPT_OBJECT_TYPE_CODE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END REPT_OBJECT_TYPE_CODE;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET.DATE_1      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END DATE_1;
   FUNCTION SET_TIME_SCOPE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET.SET_TIME_SCOPE_CODE      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END SET_TIME_SCOPE_CODE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET.TEXT_10      (
         P_OBJECT_ID,
         P_NAME );
         RETURN ret_value;
   END TEXT_10;

END RP_REPT_SET;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPT_SET TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.03.03 AM


