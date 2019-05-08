
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.44.03 AM


CREATE or REPLACE PACKAGE RP_REPORT_REF_GRP_SRC_SETUP
IS

   FUNCTION OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION SPLIT_KEY_SOURCE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SRC_TYPE VARCHAR2 (32) ,
         SRC_CODE VARCHAR2 (32) ,
         OPERATOR VARCHAR2 (16) ,
         SPLIT_KEY_SOURCE VARCHAR2 (32) ,
         GROUP_NO NUMBER ,
         OBJECT_TYPE VARCHAR2 (240) ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SRC_TYPE VARCHAR2 (32) ,
         SRC_CODE VARCHAR2 (32) ,
         OPERATOR VARCHAR2 (16) ,
         SPLIT_KEY_SOURCE VARCHAR2 (32) ,
         GROUP_NO NUMBER ,
         OBJECT_TYPE VARCHAR2 (240) ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_REPORT_REF_GRP_SRC_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_REF_GRP_SRC_SETUP
IS

   FUNCTION OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OPERATOR;
   FUNCTION SPLIT_KEY_SOURCE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.SPLIT_KEY_SOURCE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SPLIT_KEY_SOURCE;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.COMMENTS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OBJECT_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.OBJECT_TYPE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SRC_TYPE IN VARCHAR2,
      P_SRC_CODE IN VARCHAR2,
      P_GROUP_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_GRP_SRC_SETUP.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SRC_TYPE,
         P_SRC_CODE,
         P_GROUP_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_REF_GRP_SRC_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_REF_GRP_SRC_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.44.10 AM


