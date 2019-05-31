
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.32.51 AM


CREATE or REPLACE PACKAGE RP_PARCEL_LOAD
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TAX_WAREHOUSE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION METER_SOURCE_CODE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MOVEMENT_CERT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NET_MASS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_MASS_LT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRODUCT_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AAD_ISSUE_NO(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GRS_MASS_LT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_VOL_BBLS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LOAD_EXACT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATE_CODE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN DATE;
   FUNCTION MAXIMUM_GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         PARCEL_LOAD_NO NUMBER ,
         PRODUCT_ID VARCHAR2 (32) ,
         STORAGE_ID VARCHAR2 (32) ,
         STATE_CODE VARCHAR2 (32) ,
         GRS_MASS NUMBER ,
         NET_MASS NUMBER ,
         GRS_VOL NUMBER ,
         NET_VOL NUMBER ,
         GRS_VOL_BBLS NUMBER ,
         NET_VOL_BBLS NUMBER ,
         NET_MASS_LT NUMBER ,
         GRS_MASS_LT NUMBER ,
         MAXIMUM_GRS_VOL NUMBER ,
         MINIMUM_GRS_VOL NUMBER ,
         METER_SOURCE_CODE VARCHAR2 (4) ,
         GOODS_DUES NUMBER ,
         SHIPS_DUES NUMBER ,
         SPECIAL_INSTRUCTIONS VARCHAR2 (2000) ,
         LOAD_EXACT VARCHAR2 (1) ,
         BL_DATE  DATE ,
         TAX_WAREHOUSE VARCHAR2 (20) ,
         MOVEMENT_CERT VARCHAR2 (20) ,
         ATTACHED_LIST VARCHAR2 (1) ,
         AAD_ISSUE_NO NUMBER ,
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
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ATTACHED_LIST(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GRS_MASS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL_BBLS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION MINIMUM_GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHIPS_DUES(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GOODS_DUES(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STORAGE_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER;

END RP_PARCEL_LOAD;

/



CREATE or REPLACE PACKAGE BODY RP_PARCEL_LOAD
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.TEXT_3      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.TEXT_4      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.APPROVAL_BY      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.APPROVAL_STATE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.BL_DATE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END BL_DATE;
   FUNCTION TAX_WAREHOUSE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (20) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.TAX_WAREHOUSE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END TAX_WAREHOUSE;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_5      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION METER_SOURCE_CODE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.METER_SOURCE_CODE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END METER_SOURCE_CODE;
   FUNCTION MOVEMENT_CERT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (20) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.MOVEMENT_CERT      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END MOVEMENT_CERT;
   FUNCTION NET_MASS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.NET_MASS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END NET_MASS;
   FUNCTION NET_MASS_LT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.NET_MASS_LT      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END NET_MASS_LT;
   FUNCTION PRODUCT_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.PRODUCT_ID      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION AAD_ISSUE_NO(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.AAD_ISSUE_NO      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END AAD_ISSUE_NO;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.COMMENTS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION GRS_MASS_LT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.GRS_MASS_LT      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END GRS_MASS_LT;
   FUNCTION NET_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.NET_VOL      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END NET_VOL;
   FUNCTION NET_VOL_BBLS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.NET_VOL_BBLS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END NET_VOL_BBLS;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_6      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION LOAD_EXACT(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.LOAD_EXACT      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END LOAD_EXACT;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.RECORD_STATUS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.SPECIAL_INSTRUCTIONS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END SPECIAL_INSTRUCTIONS;
   FUNCTION STATE_CODE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.STATE_CODE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END STATE_CODE;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_1      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.APPROVAL_DATE      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION MAXIMUM_GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.MAXIMUM_GRS_VOL      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END MAXIMUM_GRS_VOL;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.ROW_BY_PK      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_2      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_3      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_4      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ATTACHED_LIST(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.ATTACHED_LIST      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END ATTACHED_LIST;
   FUNCTION GRS_MASS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.GRS_MASS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END GRS_MASS;
   FUNCTION GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.GRS_VOL      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END GRS_VOL;
   FUNCTION GRS_VOL_BBLS(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.GRS_VOL_BBLS      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END GRS_VOL_BBLS;
   FUNCTION MINIMUM_GRS_VOL(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.MINIMUM_GRS_VOL      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END MINIMUM_GRS_VOL;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.REC_ID      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SHIPS_DUES(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.SHIPS_DUES      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END SHIPS_DUES;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.TEXT_1      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.TEXT_2      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_7      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_9      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION GOODS_DUES(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.GOODS_DUES      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END GOODS_DUES;
   FUNCTION STORAGE_ID(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.STORAGE_ID      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END STORAGE_ID;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_10      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_PARCEL_LOAD_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_LOAD.VALUE_8      (
         P_CARGO_NO,
         P_PARCEL_LOAD_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_PARCEL_LOAD;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PARCEL_LOAD TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.33.06 AM


