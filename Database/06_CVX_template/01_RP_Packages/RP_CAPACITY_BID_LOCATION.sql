
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.53.32 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_BID_LOCATION
IS

   FUNCTION TEXT_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_18(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         BID_NO NUMBER ,
         LOCATION_ID VARCHAR2 (32) ,
         BID_QTY NUMBER ,
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
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         TEXT_16 VARCHAR2 (2000) ,
         TEXT_17 VARCHAR2 (2000) ,
         TEXT_18 VARCHAR2 (2000) ,
         TEXT_19 VARCHAR2 (2000) ,
         TEXT_20 VARCHAR2 (2000) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         AWARDED_QTY NUMBER ,
         COMMENTS VARCHAR2 (2000)  );
   FUNCTION ROW_BY_PK(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_12(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION AWARDED_QTY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION BID_QTY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_CAPACITY_BID_LOCATION;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_BID_LOCATION
IS

   FUNCTION TEXT_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_3      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.APPROVAL_BY      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.APPROVAL_STATE      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REF_OBJECT_ID_4      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION TEXT_15(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_15      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_5      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_18(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_18      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_19      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_7(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_7      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_8      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.COMMENTS      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.DATE_3      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.DATE_5      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REF_OBJECT_ID_2      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REF_OBJECT_ID_3      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_1      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_11(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_11      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_17(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_17      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_20      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_6(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_6      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_9      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_6      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.DATE_2      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.RECORD_STATUS      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REF_OBJECT_ID_5      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION TEXT_16(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_16      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_1      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.APPROVAL_DATE      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REF_OBJECT_ID_1      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.ROW_BY_PK      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_12      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_2      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_4      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_5      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_2      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_3      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_4      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION AWARDED_QTY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.AWARDED_QTY      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END AWARDED_QTY;
   FUNCTION DATE_4(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.DATE_4      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.REC_ID      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_13(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_13      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION VALUE_7(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_7      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_9      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION BID_QTY(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.BID_QTY      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END BID_QTY;
   FUNCTION DATE_1(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.DATE_1      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_10      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.TEXT_14      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_10(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_10      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_BID_NO IN NUMBER,
      P_LOCATION_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_LOCATION.VALUE_8      (
         P_BID_NO,
         P_LOCATION_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_BID_LOCATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_BID_LOCATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.53.42 AM


