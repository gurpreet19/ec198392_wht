
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.36 AM


CREATE or REPLACE PACKAGE RP_IMP_SOURCE_MAPPING
IS

   FUNCTION COLUMN_SIZE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION KEY_1(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_3(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_7(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PATH_ORIGIN(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRE_UE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_6(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRANSACTION_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION POST_UE_PATH(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_4(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_5(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_8(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION EC_KEY(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_2(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAVIGATION_METHOD(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         IMP_SOURCE_MAPPING_NO NUMBER ,
         CODE VARCHAR2 (32) ,
         INTERFACE_CODE VARCHAR2 (240) ,
         SORT_ORDER NUMBER ,
         NAME VARCHAR2 (240) ,
         NAVIGATION_METHOD VARCHAR2 (32) ,
         PATH_ORIGIN VARCHAR2 (2000) ,
         TYPE VARCHAR2 (32) ,
         VALUE_TYPE VARCHAR2 (32) ,
         STAGING_GROUP VARCHAR2 (32) ,
         EC_KEY VARCHAR2 (240) ,
         KEY_1 VARCHAR2 (240) ,
         KEY_2 VARCHAR2 (240) ,
         KEY_3 VARCHAR2 (240) ,
         KEY_4 VARCHAR2 (240) ,
         KEY_5 VARCHAR2 (240) ,
         KEY_6 VARCHAR2 (240) ,
         KEY_7 VARCHAR2 (240) ,
         KEY_8 VARCHAR2 (240) ,
         KEY_9 VARCHAR2 (240) ,
         KEY_10 VARCHAR2 (240) ,
         POST_UE_PATH VARCHAR2 (240) ,
         POST_UE_TYPE VARCHAR2 (32) ,
         PRE_UE_PATH VARCHAR2 (240) ,
         PRE_UE_TYPE VARCHAR2 (32) ,
         COLUMN_SIZE NUMBER ,
         TRANSACTION_TYPE VARCHAR2 (32) ,
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
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION STAGING_GROUP(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_10(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION KEY_9(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION POST_UE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRE_UE_PATH(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_IMP_SOURCE_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RP_IMP_SOURCE_MAPPING
IS

   FUNCTION COLUMN_SIZE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.COLUMN_SIZE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END COLUMN_SIZE;
   FUNCTION KEY_1(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_1      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_1;
   FUNCTION KEY_3(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_3      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_3;
   FUNCTION KEY_7(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_7      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_7;
   FUNCTION PATH_ORIGIN(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.PATH_ORIGIN      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END PATH_ORIGIN;
   FUNCTION PRE_UE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.PRE_UE_TYPE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END PRE_UE_TYPE;
   FUNCTION SORT_ORDER(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.SORT_ORDER      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION VALUE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.VALUE_TYPE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END VALUE_TYPE;
   FUNCTION APPROVAL_BY(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.APPROVAL_BY      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.APPROVAL_STATE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION KEY_6(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_6      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_6;
   FUNCTION TRANSACTION_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.TRANSACTION_TYPE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END TRANSACTION_TYPE;
   FUNCTION POST_UE_PATH(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.POST_UE_PATH      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END POST_UE_PATH;
   FUNCTION KEY_4(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_4      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_4;
   FUNCTION KEY_5(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_5      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_5;
   FUNCTION KEY_8(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_8      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_8;
   FUNCTION RECORD_STATUS(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.RECORD_STATUS      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.APPROVAL_DATE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION EC_KEY(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.EC_KEY      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END EC_KEY;
   FUNCTION KEY_2(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_2      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_2;
   FUNCTION NAME(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.NAME      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION NAVIGATION_METHOD(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.NAVIGATION_METHOD      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END NAVIGATION_METHOD;
   FUNCTION ROW_BY_PK(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.ROW_BY_PK      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STAGING_GROUP(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.STAGING_GROUP      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END STAGING_GROUP;
   FUNCTION TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.TYPE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END TYPE;
   FUNCTION REC_ID(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.REC_ID      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION KEY_10(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_10      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_10;
   FUNCTION KEY_9(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.KEY_9      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END KEY_9;
   FUNCTION POST_UE_TYPE(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.POST_UE_TYPE      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END POST_UE_TYPE;
   FUNCTION PRE_UE_PATH(
      P_IMP_SOURCE_MAPPING_NO IN NUMBER,
      P_CODE IN VARCHAR2,
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_MAPPING.PRE_UE_PATH      (
         P_IMP_SOURCE_MAPPING_NO,
         P_CODE,
         P_INTERFACE_CODE );
         RETURN ret_value;
   END PRE_UE_PATH;

END RP_IMP_SOURCE_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IMP_SOURCE_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.43 AM


