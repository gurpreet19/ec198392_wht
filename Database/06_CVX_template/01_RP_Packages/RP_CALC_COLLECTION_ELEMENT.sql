
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.17.20 AM


CREATE or REPLACE PACKAGE RP_CALC_COLLECTION_ELEMENT
IS

   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION DIAGRAM_LAYOUT_INFO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         DATA_CLASS_NAME VARCHAR2 (24) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         ELEMENT_ID VARCHAR2 (32) ,
         END_DATE  DATE ,
         DIAGRAM_LAYOUT_INFO VARCHAR2 (1000) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         DATA_CLASS_NAME VARCHAR2 (24) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         ELEMENT_ID VARCHAR2 (32) ,
         END_DATE  DATE ,
         DIAGRAM_LAYOUT_INFO VARCHAR2 (1000) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CALC_COLLECTION_ELEMENT;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_COLLECTION_ELEMENT
IS

   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.SORT_ORDER      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION DIAGRAM_LAYOUT_INFO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.DIAGRAM_LAYOUT_INFO      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DIAGRAM_LAYOUT_INFO;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.END_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ELEMENT_ID IN VARCHAR2,
      P_DATA_CLASS_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COLLECTION_ELEMENT.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ELEMENT_ID,
         P_DATA_CLASS_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;

END RP_CALC_COLLECTION_ELEMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_COLLECTION_ELEMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.17.24 AM

