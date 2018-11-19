
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.59.41 AM


CREATE or REPLACE PACKAGE RP_LIFT_ACC_ANALYSIS_ITEM
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PAI_NO NUMBER ,
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
      P_PAI_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER;

END RP_LIFT_ACC_ANALYSIS_ITEM;

/



CREATE or REPLACE PACKAGE BODY RP_LIFT_ACC_ANALYSIS_ITEM
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.TEXT_3      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.TEXT_4      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.APPROVAL_BY      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_5      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_6      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.RECORD_STATUS      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_1      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.ROW_BY_PK      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_2      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_3      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_4      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.REC_ID      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.TEXT_1      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.TEXT_2      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_7      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_9      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_10      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PAI_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_ANALYSIS_ITEM.VALUE_8      (
         P_OBJECT_ID,
         P_PAI_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFT_ACC_ANALYSIS_ITEM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFT_ACC_ANALYSIS_ITEM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.59.46 AM


