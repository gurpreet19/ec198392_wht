
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.13.41 AM


CREATE or REPLACE PACKAGE RP_SUMMARY_SET_SETUP
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CONTRACT_GROUP_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION INVENTORY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         SUMMARY_SETUP_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         CONTRACT_GROUP_CODE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (240) ,
         SORT_ORDER NUMBER ,
         INVENTORY_ID VARCHAR2 (32) ,
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
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         SUMMARY_SETUP_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         CONTRACT_GROUP_CODE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (240) ,
         SORT_ORDER NUMBER ,
         INVENTORY_ID VARCHAR2 (32) ,
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
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_SUMMARY_SET_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_SUMMARY_SET_SETUP
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.COMMENTS      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION CONTRACT_GROUP_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.CONTRACT_GROUP_CODE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CONTRACT_GROUP_CODE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.END_DATE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION INVENTORY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.INVENTORY_ID      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END INVENTORY_ID;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2,
      P_CONTRACT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SORT_ORDER IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SUMMARY_SET_SETUP.REC_ID      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID,
         P_CONTRACT_ID,
         P_DAYTIME,
         P_SORT_ORDER,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;

END RP_SUMMARY_SET_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_SUMMARY_SET_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.13.55 AM


