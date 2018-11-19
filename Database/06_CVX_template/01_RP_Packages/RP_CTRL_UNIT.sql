
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.17.33 AM


CREATE or REPLACE PACKAGE RP_CTRL_UNIT
IS

   FUNCTION FIN_CODE(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION BASE_UNIT_IND(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREFIX_FACTOR(
      P_UNIT IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREFIX(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UOM_SUBGROUP(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION BASE_UNIT(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_UNIT IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         UNIT VARCHAR2 (16) ,
         LABEL VARCHAR2 (64) ,
         FIN_CODE VARCHAR2 (32) ,
         UOM_GROUP VARCHAR2 (32) ,
         UOM_SUBGROUP VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
         BASE_UNIT VARCHAR2 (16) ,
         BASE_UNIT_IND VARCHAR2 (1) ,
         PREFIX VARCHAR2 (16) ,
         PREFIX_FACTOR NUMBER ,
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
      P_UNIT IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UOM_GROUP(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_UNIT;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_UNIT
IS

   FUNCTION FIN_CODE(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.FIN_CODE      (
         P_UNIT );
         RETURN ret_value;
   END FIN_CODE;
   FUNCTION TEXT_3(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_3      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.APPROVAL_BY      (
         P_UNIT );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.APPROVAL_STATE      (
         P_UNIT );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BASE_UNIT_IND(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.BASE_UNIT_IND      (
         P_UNIT );
         RETURN ret_value;
   END BASE_UNIT_IND;
   FUNCTION PREFIX_FACTOR(
      P_UNIT IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CTRL_UNIT.PREFIX_FACTOR      (
         P_UNIT );
         RETURN ret_value;
   END PREFIX_FACTOR;
   FUNCTION TEXT_7(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_7      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_8      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION PREFIX(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.PREFIX      (
         P_UNIT );
         RETURN ret_value;
   END PREFIX;
   FUNCTION TEXT_1(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_1      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_6      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_9      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UOM_SUBGROUP(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.UOM_SUBGROUP      (
         P_UNIT );
         RETURN ret_value;
   END UOM_SUBGROUP;
   FUNCTION BASE_UNIT(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.BASE_UNIT      (
         P_UNIT );
         RETURN ret_value;
   END BASE_UNIT;
   FUNCTION RECORD_STATUS(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.RECORD_STATUS      (
         P_UNIT );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_UNIT IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_UNIT.APPROVAL_DATE      (
         P_UNIT );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.DESCRIPTION      (
         P_UNIT );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_UNIT IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_UNIT.ROW_BY_PK      (
         P_UNIT );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_2      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_4      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_5      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION REC_ID(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.REC_ID      (
         P_UNIT );
         RETURN ret_value;
   END REC_ID;
   FUNCTION LABEL(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.LABEL      (
         P_UNIT );
         RETURN ret_value;
   END LABEL;
   FUNCTION TEXT_10(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.TEXT_10      (
         P_UNIT );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION UOM_GROUP(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_UNIT.UOM_GROUP      (
         P_UNIT );
         RETURN ret_value;
   END UOM_GROUP;

END RP_CTRL_UNIT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_UNIT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.17.38 AM


