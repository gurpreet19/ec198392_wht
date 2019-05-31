
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.03.19 AM


CREATE or REPLACE PACKAGE RP_FCST_MEMBER
IS

   FUNCTION MEMBER_TYPE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_COLLECTION_TYPE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION INVENTORY4_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INVENTORY5_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SWAP_STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION INVENTORY3_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         MEMBER_NO NUMBER ,
         MEMBER_TYPE VARCHAR2 (32) ,
         FIELD_ID VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         STREAM_ITEM_ID VARCHAR2 (32) ,
         SWAP_STREAM_ITEM_ID VARCHAR2 (32) ,
         ADJ_STREAM_ITEM_ID VARCHAR2 (32) ,
         SPLIT_KEY_ID VARCHAR2 (32) ,
         PRODUCT_COLLECTION_TYPE VARCHAR2 (32) ,
         PRODUCT_CONTEXT VARCHAR2 (32) ,
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
         INVENTORY1_ID VARCHAR2 (32) ,
         INVENTORY2_ID VARCHAR2 (32) ,
         INVENTORY3_ID VARCHAR2 (32) ,
         INVENTORY4_ID VARCHAR2 (32) ,
         INVENTORY5_ID VARCHAR2 (32) ,
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
      P_MEMBER_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ADJ_STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCT_CONTEXT(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FIELD_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INVENTORY1_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INVENTORY2_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPLIT_KEY_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER;

END RP_FCST_MEMBER;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_MEMBER
IS

   FUNCTION MEMBER_TYPE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.MEMBER_TYPE      (
         P_MEMBER_NO );
         RETURN ret_value;
   END MEMBER_TYPE;
   FUNCTION TEXT_3(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.TEXT_3      (
         P_MEMBER_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.TEXT_4      (
         P_MEMBER_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.APPROVAL_BY      (
         P_MEMBER_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.APPROVAL_STATE      (
         P_MEMBER_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_5      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION OBJECT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.OBJECT_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PRODUCT_COLLECTION_TYPE(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.PRODUCT_COLLECTION_TYPE      (
         P_MEMBER_NO );
         RETURN ret_value;
   END PRODUCT_COLLECTION_TYPE;
   FUNCTION PRODUCT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.PRODUCT_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION COMMENTS(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.COMMENTS      (
         P_MEMBER_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.DATE_3      (
         P_MEMBER_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.DATE_5      (
         P_MEMBER_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION INVENTORY4_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.INVENTORY4_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END INVENTORY4_ID;
   FUNCTION INVENTORY5_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.INVENTORY5_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END INVENTORY5_ID;
   FUNCTION SWAP_STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.SWAP_STREAM_ITEM_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END SWAP_STREAM_ITEM_ID;
   FUNCTION VALUE_6(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_6      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.CONTRACT_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.DATE_2      (
         P_MEMBER_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.RECORD_STATUS      (
         P_MEMBER_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_1      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.APPROVAL_DATE      (
         P_MEMBER_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION INVENTORY3_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.INVENTORY3_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END INVENTORY3_ID;
   FUNCTION ROW_BY_PK(
      P_MEMBER_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_MEMBER.ROW_BY_PK      (
         P_MEMBER_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_2      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_3      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_4      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ADJ_STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.ADJ_STREAM_ITEM_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END ADJ_STREAM_ITEM_ID;
   FUNCTION DATE_4(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.DATE_4      (
         P_MEMBER_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PRODUCT_CONTEXT(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.PRODUCT_CONTEXT      (
         P_MEMBER_NO );
         RETURN ret_value;
   END PRODUCT_CONTEXT;
   FUNCTION REC_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.REC_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.TEXT_1      (
         P_MEMBER_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.TEXT_2      (
         P_MEMBER_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_7      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_9      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_MEMBER_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_MEMBER.DATE_1      (
         P_MEMBER_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION FIELD_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.FIELD_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END FIELD_ID;
   FUNCTION INVENTORY1_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.INVENTORY1_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END INVENTORY1_ID;
   FUNCTION INVENTORY2_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.INVENTORY2_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END INVENTORY2_ID;
   FUNCTION SPLIT_KEY_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.SPLIT_KEY_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END SPLIT_KEY_ID;
   FUNCTION STREAM_ITEM_ID(
      P_MEMBER_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_MEMBER.STREAM_ITEM_ID      (
         P_MEMBER_NO );
         RETURN ret_value;
   END STREAM_ITEM_ID;
   FUNCTION VALUE_10(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_10      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_MEMBER_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_MEMBER.VALUE_8      (
         P_MEMBER_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_MEMBER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_MEMBER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.03.28 AM


