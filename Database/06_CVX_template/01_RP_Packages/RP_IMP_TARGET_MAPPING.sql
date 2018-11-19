
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.24 AM


CREATE or REPLACE PACKAGE RP_IMP_TARGET_MAPPING
IS

   FUNCTION CLASS_KEY_8(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRE_UE_TYPE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_4(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONDITION_1(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_3(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONSTANT_DATE_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN DATE;
   FUNCTION POST_UE_PATH(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_2(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONDITION_2(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_1(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_5(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONSTANT_STRING_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN DATE;
   FUNCTION CONSTANT_NUMBER_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         EC_KEY VARCHAR2 (240) ,
         ATTRIBUTE VARCHAR2 (240) ,
         CLASS VARCHAR2 (32) ,
         CLASS_KEY_1 VARCHAR2 (240) ,
         CLASS_KEY_2 VARCHAR2 (240) ,
         CLASS_KEY_3 VARCHAR2 (240) ,
         CLASS_KEY_4 VARCHAR2 (240) ,
         CLASS_KEY_5 VARCHAR2 (240) ,
         CLASS_KEY_6 VARCHAR2 (240) ,
         CLASS_KEY_7 VARCHAR2 (240) ,
         CLASS_KEY_8 VARCHAR2 (240) ,
         CLASS_KEY_9 VARCHAR2 (240) ,
         CLASS_KEY_10 VARCHAR2 (240) ,
         CONDITION_1 VARCHAR2 (2000) ,
         CONDITION_2 VARCHAR2 (2000) ,
         CONDITION_3 VARCHAR2 (2000) ,
         FROM_UNIT VARCHAR2 (32) ,
         TO_UNIT VARCHAR2 (32) ,
         POST_UE_PATH VARCHAR2 (240) ,
         POST_UE_TYPE VARCHAR2 (32) ,
         PRE_UE_PATH VARCHAR2 (240) ,
         PRE_UE_TYPE VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         CONSTANT_DATE_VALUE  DATE ,
         CONSTANT_NUMBER_VALUE NUMBER ,
         CONSTANT_STRING_VALUE VARCHAR2 (2000)  );
   FUNCTION ROW_BY_PK(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION CLASS_KEY_9(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONDITION_3(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_10(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_6(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_KEY_7(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FROM_UNIT(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION POST_UE_TYPE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRE_UE_PATH(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TO_UNIT(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_IMP_TARGET_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RP_IMP_TARGET_MAPPING
IS

   FUNCTION CLASS_KEY_8(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_8      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_8;
   FUNCTION PRE_UE_TYPE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.PRE_UE_TYPE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END PRE_UE_TYPE;
   FUNCTION APPROVAL_BY(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.APPROVAL_BY      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.APPROVAL_STATE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLASS_KEY_4(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_4      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_4;
   FUNCTION CONDITION_1(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONDITION_1      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONDITION_1;
   FUNCTION CLASS_KEY_3(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_3      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_3;
   FUNCTION CONSTANT_DATE_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONSTANT_DATE_VALUE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONSTANT_DATE_VALUE;
   FUNCTION POST_UE_PATH(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.POST_UE_PATH      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END POST_UE_PATH;
   FUNCTION CLASS_KEY_2(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_2      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_2;
   FUNCTION CONDITION_2(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONDITION_2      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONDITION_2;
   FUNCTION CLASS_KEY_1(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_1      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_1;
   FUNCTION CLASS_KEY_5(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_5      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_5;
   FUNCTION CONSTANT_STRING_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONSTANT_STRING_VALUE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONSTANT_STRING_VALUE;
   FUNCTION RECORD_STATUS(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.RECORD_STATUS      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.APPROVAL_DATE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CONSTANT_NUMBER_VALUE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONSTANT_NUMBER_VALUE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONSTANT_NUMBER_VALUE;
   FUNCTION ROW_BY_PK(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.ROW_BY_PK      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CLASS_KEY_9(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_9      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_9;
   FUNCTION CONDITION_3(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CONDITION_3      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CONDITION_3;
   FUNCTION REC_ID(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.REC_ID      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION CLASS_KEY_10(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_10      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_10;
   FUNCTION CLASS_KEY_6(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_6      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_6;
   FUNCTION CLASS_KEY_7(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.CLASS_KEY_7      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END CLASS_KEY_7;
   FUNCTION FROM_UNIT(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.FROM_UNIT      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END FROM_UNIT;
   FUNCTION POST_UE_TYPE(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.POST_UE_TYPE      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END POST_UE_TYPE;
   FUNCTION PRE_UE_PATH(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.PRE_UE_PATH      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END PRE_UE_PATH;
   FUNCTION TO_UNIT(
      P_EC_KEY IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_ATTRIBUTE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_TARGET_MAPPING.TO_UNIT      (
         P_EC_KEY,
         P_CLASS,
         P_ATTRIBUTE );
         RETURN ret_value;
   END TO_UNIT;

END RP_IMP_TARGET_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IMP_TARGET_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.30 AM


