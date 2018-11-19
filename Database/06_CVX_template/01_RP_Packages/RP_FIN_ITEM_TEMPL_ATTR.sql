
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.14.58 AM


CREATE or REPLACE PACKAGE RP_FIN_ITEM_TEMPL_ATTR
IS

   FUNCTION DATE_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION SORT_ORDER(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEMPLATE_CODE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UNIT_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATASET_PRIORITY(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FIN_ITEM_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_LINK_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UNIT(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION FIN_ACCT_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FIN_ITEM_NAME(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FORMAT_MASK(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEMPLATE_CODE VARCHAR2 (32) ,
         ATTR_ID VARCHAR2 (32) ,
         FIN_ITEM_ID VARCHAR2 (32) ,
         FIN_ITEM_NAME VARCHAR2 (240) ,
         DAYTIME  DATE ,
         UNIT VARCHAR2 (32) ,
         UNIT_TYPE VARCHAR2 (32) ,
         COST_OBJECT_ID VARCHAR2 (32) ,
         COST_OBJECT_TYPE VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         FIN_ACCT_ID VARCHAR2 (32) ,
         OBJECT_LINK_TYPE VARCHAR2 (32) ,
         OBJECT_LINK_ID VARCHAR2 (32) ,
         DATASET VARCHAR2 (32) ,
         DATASET_PRIORITY VARCHAR2 (32) ,
         FORMAT_MASK VARCHAR2 (32) ,
         DATA_FALLBACK_METHOD VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (240) ,
         COMMENTS VARCHAR2 (240) ,
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
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
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
      P_ATTR_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COST_OBJECT_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COST_OBJECT_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATA_FALLBACK_METHOD(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION OBJECT_LINK_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_FIN_ITEM_TEMPL_ATTR;

/



CREATE or REPLACE PACKAGE BODY RP_FIN_ITEM_TEMPL_ATTR
IS

   FUNCTION DATE_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_10      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_10;
   FUNCTION SORT_ORDER(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.SORT_ORDER      (
         P_ATTR_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEMPLATE_CODE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEMPLATE_CODE      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEMPLATE_CODE;
   FUNCTION TEXT_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_3      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION UNIT_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.UNIT_TYPE      (
         P_ATTR_ID );
         RETURN ret_value;
   END UNIT_TYPE;
   FUNCTION APPROVAL_BY(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.APPROVAL_BY      (
         P_ATTR_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.APPROVAL_STATE      (
         P_ATTR_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATASET      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATASET;
   FUNCTION DATASET_PRIORITY(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATASET_PRIORITY      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATASET_PRIORITY;
   FUNCTION FIN_ITEM_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.FIN_ITEM_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END FIN_ITEM_ID;
   FUNCTION REF_OBJECT_ID_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REF_OBJECT_ID_4      (
         P_ATTR_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_5      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_7      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_9      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.NEXT_DAYTIME      (
         P_ATTR_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_LINK_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.OBJECT_LINK_TYPE      (
         P_ATTR_ID );
         RETURN ret_value;
   END OBJECT_LINK_TYPE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.PREV_EQUAL_DAYTIME      (
         P_ATTR_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_7      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_8      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION UNIT(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.UNIT      (
         P_ATTR_ID );
         RETURN ret_value;
   END UNIT;
   FUNCTION COMMENTS(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.COMMENTS      (
         P_ATTR_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_3      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_5      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.NEXT_EQUAL_DAYTIME      (
         P_ATTR_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REF_OBJECT_ID_2      (
         P_ATTR_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REF_OBJECT_ID_3      (
         P_ATTR_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_1      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_6      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_9      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_6      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.COMPANY_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION DATE_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_2      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION FIN_ACCT_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.FIN_ACCT_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END FIN_ACCT_ID;
   FUNCTION FIN_ITEM_NAME(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.FIN_ITEM_NAME      (
         P_ATTR_ID );
         RETURN ret_value;
   END FIN_ITEM_NAME;
   FUNCTION FORMAT_MASK(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.FORMAT_MASK      (
         P_ATTR_ID );
         RETURN ret_value;
   END FORMAT_MASK;
   FUNCTION PREV_DAYTIME(
      P_ATTR_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.PREV_DAYTIME      (
         P_ATTR_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.RECORD_STATUS      (
         P_ATTR_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REF_OBJECT_ID_5      (
         P_ATTR_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_1      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.APPROVAL_DATE      (
         P_ATTR_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_6      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_6;
   FUNCTION DESCRIPTION(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DESCRIPTION      (
         P_ATTR_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION REF_OBJECT_ID_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REF_OBJECT_ID_1      (
         P_ATTR_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_ATTR_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.ROW_BY_PK      (
         P_ATTR_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_2      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_4      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_5      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_2      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_3      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_4      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION COST_OBJECT_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.COST_OBJECT_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END COST_OBJECT_ID;
   FUNCTION DATE_4(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_4      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.REC_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_7      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_9      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION COST_OBJECT_TYPE(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.COST_OBJECT_TYPE      (
         P_ATTR_ID );
         RETURN ret_value;
   END COST_OBJECT_TYPE;
   FUNCTION DATA_FALLBACK_METHOD(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATA_FALLBACK_METHOD      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATA_FALLBACK_METHOD;
   FUNCTION DATE_1(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_1      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DATE_8      (
         P_ATTR_ID );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_ATTR_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.DAYTIME      (
         P_ATTR_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION OBJECT_LINK_ID(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.OBJECT_LINK_ID      (
         P_ATTR_ID );
         RETURN ret_value;
   END OBJECT_LINK_ID;
   FUNCTION TEXT_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.TEXT_10      (
         P_ATTR_ID );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_10      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ATTR_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FIN_ITEM_TEMPL_ATTR.VALUE_8      (
         P_ATTR_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_FIN_ITEM_TEMPL_ATTR;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FIN_ITEM_TEMPL_ATTR TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.15.12 AM


