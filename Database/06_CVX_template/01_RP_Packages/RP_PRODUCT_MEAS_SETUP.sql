
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.21.07 AM


CREATE or REPLACE PACKAGE RP_PRODUCT_MEAS_SETUP
IS

   FUNCTION SORT_ORDER(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BLMR_LIGHT_MAPPING(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_UNIT_IND2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LIFTING_EVENT(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_UNIT_IND3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OBJECT_ID(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_IND(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ITEM_CODE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REV_QTY_MAPPING(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION BALANCE_QTY_TYPE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_UNIT_IND(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PRODUCT_MEAS_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         ITEM_CODE VARCHAR2 (32) ,
         LIFTING_EVENT VARCHAR2 (32) ,
         CALC_IND VARCHAR2 (1) ,
         NOM_UNIT_IND VARCHAR2 (1) ,
         NOM_UNIT_IND2 VARCHAR2 (1) ,
         NOM_UNIT_IND3 VARCHAR2 (1) ,
         REV_QTY_MAPPING VARCHAR2 (32) ,
         BLMR_LIGHT_MAPPING VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         BALANCE_QTY_TYPE VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER;

END RP_PRODUCT_MEAS_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_PRODUCT_MEAS_SETUP
IS

   FUNCTION SORT_ORDER(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.SORT_ORDER      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.TEXT_3      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.TEXT_4      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.APPROVAL_BY      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.APPROVAL_STATE      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BLMR_LIGHT_MAPPING(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.BLMR_LIGHT_MAPPING      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END BLMR_LIGHT_MAPPING;
   FUNCTION NOM_UNIT_IND2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.NOM_UNIT_IND2      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END NOM_UNIT_IND2;
   FUNCTION VALUE_5(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_5      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION LIFTING_EVENT(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.LIFTING_EVENT      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END LIFTING_EVENT;
   FUNCTION NOM_UNIT_IND3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.NOM_UNIT_IND3      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END NOM_UNIT_IND3;
   FUNCTION OBJECT_ID(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.OBJECT_ID      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION CALC_IND(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.CALC_IND      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END CALC_IND;
   FUNCTION ITEM_CODE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.ITEM_CODE      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END ITEM_CODE;
   FUNCTION VALUE_6(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_6      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.RECORD_STATUS      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REV_QTY_MAPPING(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.REV_QTY_MAPPING      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END REV_QTY_MAPPING;
   FUNCTION VALUE_1(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_1      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.APPROVAL_DATE      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION BALANCE_QTY_TYPE(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.BALANCE_QTY_TYPE      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END BALANCE_QTY_TYPE;
   FUNCTION NOM_UNIT_IND(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.NOM_UNIT_IND      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END NOM_UNIT_IND;
   FUNCTION ROW_BY_PK(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.ROW_BY_PK      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_2      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_3      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_4      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.REC_ID      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.TEXT_1      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.TEXT_2      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_7      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_9      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_10      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_PRODUCT_MEAS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_MEAS_SETUP.VALUE_8      (
         P_PRODUCT_MEAS_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_PRODUCT_MEAS_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PRODUCT_MEAS_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.21.14 AM


