
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.57.48 AM


CREATE or REPLACE PACKAGE RP_FCST_PRODUCT_SETUP
IS

   FUNCTION PRODUCT_PRICE_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION SWAP_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CURRENCY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FULL_ADJ_STREAM_ITEM_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMMERCIAL_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION PCT_ADJ_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION PRODUCT_LABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         PRODUCT_COLLECTION_TYPE VARCHAR2 (32) ,
         PRODUCT_UOM VARCHAR2 (16) ,
         PRODUCT_LABEL VARCHAR2 (64) ,
         COMMERCIAL_ADJ_TYPE VARCHAR2 (32) ,
         SWAP_ADJ_TYPE VARCHAR2 (32) ,
         VALUE_ADJ_TYPE VARCHAR2 (32) ,
         PCT_ADJ_IND VARCHAR2 (1) ,
         PRODUCT_PRICE_ID VARCHAR2 (32) ,
         PRODUCT_CONTEXT VARCHAR2 (32) ,
         CURRENCY_ID VARCHAR2 (32) ,
         CPY_ADJ_STREAM_ITEM_ID VARCHAR2 (32) ,
         FULL_ADJ_STREAM_ITEM_ID VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CPY_ADJ_STREAM_ITEM_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER;

END RP_FCST_PRODUCT_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_PRODUCT_SETUP
IS

   FUNCTION PRODUCT_PRICE_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.PRODUCT_PRICE_ID      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END PRODUCT_PRICE_ID;
   FUNCTION PRODUCT_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.PRODUCT_UOM      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END PRODUCT_UOM;
   FUNCTION SORT_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.SORT_ORDER      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION SWAP_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.SWAP_ADJ_TYPE      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END SWAP_ADJ_TYPE;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.TEXT_3      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.TEXT_4      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CURRENCY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.CURRENCY_ID      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END CURRENCY_ID;
   FUNCTION FULL_ADJ_STREAM_ITEM_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.FULL_ADJ_STREAM_ITEM_ID      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END FULL_ADJ_STREAM_ITEM_ID;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_5      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMERCIAL_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.COMMERCIAL_ADJ_TYPE      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END COMMERCIAL_ADJ_TYPE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.COMMENTS      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.DATE_3      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.DATE_5      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION PCT_ADJ_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.PCT_ADJ_IND      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END PCT_ADJ_IND;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_6      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.DATE_2      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PRODUCT_LABEL(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.PRODUCT_LABEL      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END PRODUCT_LABEL;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_1      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_2      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_3      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_4      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION VALUE_ADJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_ADJ_TYPE      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_ADJ_TYPE;
   FUNCTION CPY_ADJ_STREAM_ITEM_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.CPY_ADJ_STREAM_ITEM_ID      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END CPY_ADJ_STREAM_ITEM_ID;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.DATE_4      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.REC_ID      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.TEXT_1      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.TEXT_2      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_7      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_9      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.DATE_1      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_10      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_PRODUCT_CONTEXT IN VARCHAR2,
      P_PRODUCT_COLLECTION_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PRODUCT_SETUP.VALUE_8      (
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_PRODUCT_CONTEXT,
         P_PRODUCT_COLLECTION_TYPE );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_PRODUCT_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_PRODUCT_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.57.56 AM


