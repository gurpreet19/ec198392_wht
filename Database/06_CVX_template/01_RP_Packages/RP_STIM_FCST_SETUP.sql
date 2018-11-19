
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.56.28 AM


CREATE or REPLACE PACKAGE RP_STIM_FCST_SETUP
IS

   FUNCTION DEFAULT_UOM_ENERGY(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEFAULT_UOM_EXTRA2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DEFAULT_UOM_MASS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_ENERGY_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_STREAM_ITEM_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION MASTER_UOM_GROUP(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_METHOD(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DEFAULT_UOM_EXTRA3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_EXTRA2_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_VOLUME_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DEFAULT_UOM_VOLUME(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FORECAST_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         STIM_FCST_NO NUMBER ,
         END_DATE  DATE ,
         FORECAST_ID VARCHAR2 (32) ,
         LABEL VARCHAR2 (240) ,
         CALC_METHOD VARCHAR2 (32) ,
         DEFAULT_UOM_MASS VARCHAR2 (16) ,
         DEFAULT_UOM_VOLUME VARCHAR2 (16) ,
         DEFAULT_UOM_ENERGY VARCHAR2 (16) ,
         DEFAULT_UOM_EXTRA1 VARCHAR2 (16) ,
         DEFAULT_UOM_EXTRA2 VARCHAR2 (16) ,
         DEFAULT_UOM_EXTRA3 VARCHAR2 (16) ,
         MASTER_UOM_GROUP VARCHAR2 (1) ,
         STREAM_ITEM_FORMULA VARCHAR2 (2000) ,
         USE_MASS_IND VARCHAR2 (1) ,
         USE_VOLUME_IND VARCHAR2 (1) ,
         USE_ENERGY_IND VARCHAR2 (1) ,
         USE_EXTRA1_IND VARCHAR2 (1) ,
         USE_EXTRA2_IND VARCHAR2 (1) ,
         USE_EXTRA3_IND VARCHAR2 (1) ,
         SPLIT_KEY_ID VARCHAR2 (32) ,
         SPLIT_COMPANY_ID VARCHAR2 (32) ,
         SPLIT_FIELD_ID VARCHAR2 (32) ,
         SPLIT_PRODUCT_ID VARCHAR2 (32) ,
         SPLIT_STREAM_ITEM_ID VARCHAR2 (32) ,
         SPLIT_ITEM_OTHER_ID VARCHAR2 (32) ,
         SET_TO_ZERO_METHOD_MTH VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_STIM_FCST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SPLIT_COMPANY_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_FIELD_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_ITEM_OTHER_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_PRODUCT_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_EXTRA1_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DEFAULT_UOM_EXTRA1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SET_TO_ZERO_METHOD_MTH(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_KEY_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STREAM_ITEM_FORMULA(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_EXTRA3_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_MASS_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_STIM_FCST_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_STIM_FCST_SETUP
IS

   FUNCTION DEFAULT_UOM_ENERGY(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_ENERGY      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_ENERGY;
   FUNCTION DEFAULT_UOM_EXTRA2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_EXTRA2      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_EXTRA2;
   FUNCTION DEFAULT_UOM_MASS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_MASS      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_MASS;
   FUNCTION TEXT_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_3      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION USE_ENERGY_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_ENERGY_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_ENERGY_IND;
   FUNCTION APPROVAL_BY(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.APPROVAL_BY      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.APPROVAL_STATE      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REF_OBJECT_ID_4      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION SPLIT_STREAM_ITEM_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_STREAM_ITEM_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_STREAM_ITEM_ID;
   FUNCTION VALUE_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.VALUE_5      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION MASTER_UOM_GROUP(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.MASTER_UOM_GROUP      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END MASTER_UOM_GROUP;
   FUNCTION NEXT_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.NEXT_DAYTIME      (
         P_STIM_FCST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.OBJECT_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.PREV_EQUAL_DAYTIME      (
         P_STIM_FCST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_7      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_8      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION CALC_METHOD(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.CALC_METHOD      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END CALC_METHOD;
   FUNCTION COMMENTS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.COMMENTS      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DATE_3      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DATE_5      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DEFAULT_UOM_EXTRA3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_EXTRA3      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_EXTRA3;
   FUNCTION LABEL(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.LABEL      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END LABEL;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.NEXT_EQUAL_DAYTIME      (
         P_STIM_FCST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REF_OBJECT_ID_2      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REF_OBJECT_ID_3      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_1      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_6      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_9      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION USE_EXTRA2_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_EXTRA2_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_EXTRA2_IND;
   FUNCTION USE_VOLUME_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_VOLUME_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_VOLUME_IND;
   FUNCTION DATE_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DATE_2      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DEFAULT_UOM_VOLUME(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_VOLUME      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_VOLUME;
   FUNCTION END_DATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.END_DATE      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_STIM_FCST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.PREV_DAYTIME      (
         P_STIM_FCST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.RECORD_STATUS      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REF_OBJECT_ID_5      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.VALUE_1      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.APPROVAL_DATE      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION FORECAST_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.FORECAST_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REF_OBJECT_ID_1      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_STIM_FCST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.ROW_BY_PK      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SPLIT_COMPANY_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_COMPANY_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_COMPANY_ID;
   FUNCTION SPLIT_FIELD_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_FIELD_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_FIELD_ID;
   FUNCTION SPLIT_ITEM_OTHER_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_ITEM_OTHER_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_ITEM_OTHER_ID;
   FUNCTION SPLIT_PRODUCT_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_PRODUCT_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_PRODUCT_ID;
   FUNCTION TEXT_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_2      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_4      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_5      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION USE_EXTRA1_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_EXTRA1_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_EXTRA1_IND;
   FUNCTION VALUE_2(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.VALUE_2      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.VALUE_3      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.VALUE_4      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DATE_4      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.REC_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DATE_1      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_STIM_FCST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DAYTIME      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DEFAULT_UOM_EXTRA1(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.DEFAULT_UOM_EXTRA1      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END DEFAULT_UOM_EXTRA1;
   FUNCTION SET_TO_ZERO_METHOD_MTH(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SET_TO_ZERO_METHOD_MTH      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SET_TO_ZERO_METHOD_MTH;
   FUNCTION SPLIT_KEY_ID(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.SPLIT_KEY_ID      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END SPLIT_KEY_ID;
   FUNCTION STREAM_ITEM_FORMULA(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.STREAM_ITEM_FORMULA      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END STREAM_ITEM_FORMULA;
   FUNCTION TEXT_10(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.TEXT_10      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION USE_EXTRA3_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_EXTRA3_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_EXTRA3_IND;
   FUNCTION USE_MASS_IND(
      P_STIM_FCST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_FCST_SETUP.USE_MASS_IND      (
         P_STIM_FCST_NO );
         RETURN ret_value;
   END USE_MASS_IND;

END RP_STIM_FCST_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STIM_FCST_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.56.41 AM


