
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.08.37 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_REL_RECALL_LOC
IS

   FUNCTION TEXT_3(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECALL_CAPACITY(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         LOCATION_ID VARCHAR2 (32) ,
         RECALL_NO NUMBER ,
         RECALL_CAPACITY NUMBER ,
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
         VALUE_11 NUMBER ,
         VALUE_12 NUMBER ,
         VALUE_13 NUMBER ,
         VALUE_14 NUMBER ,
         VALUE_15 NUMBER ,
         VALUE_16 NUMBER ,
         VALUE_17 NUMBER ,
         VALUE_18 NUMBER ,
         VALUE_19 NUMBER ,
         VALUE_20 NUMBER ,
         VALUE_21 NUMBER ,
         VALUE_22 NUMBER ,
         VALUE_23 NUMBER ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         TEXT_10 VARCHAR2 (2000) ,
         TEXT_11 VARCHAR2 (2000) ,
         TEXT_12 VARCHAR2 (2000) ,
         TEXT_13 VARCHAR2 (2000) ,
         TEXT_14 VARCHAR2 (2000) ,
         TEXT_15 VARCHAR2 (2000) ,
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
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_11(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER;

END RP_CAPACITY_REL_RECALL_LOC;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_REL_RECALL_LOC
IS

   FUNCTION TEXT_3(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_3      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_7(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_7      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION VALUE_16(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_16      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_18      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_21      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_27      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_30      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.APPROVAL_BY      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.APPROVAL_STATE      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_23(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_23      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_28      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_5      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_10(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_10      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_6(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_6      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION VALUE_29(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_29      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION TEXT_1(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_1      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_14      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_12(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_12      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_22      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_26      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_6      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECALL_CAPACITY(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.RECALL_CAPACITY      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END RECALL_CAPACITY;
   FUNCTION RECORD_STATUS(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.RECORD_STATUS      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_1      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_15      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_19      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.APPROVAL_DATE      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.ROW_BY_PK      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_13      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_2      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_4      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_5      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_9(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_9      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_13(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_13      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_17      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_2      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_20      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_25      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_3      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_4      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.REC_ID      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_7      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_9      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION TEXT_11(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_11      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_12      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_15      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TEXT_8(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.TEXT_8      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_10(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_10      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_11      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_14      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_24      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_LOCATION_ID IN VARCHAR2,
      P_RECALL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_RECALL_LOC.VALUE_8      (
         P_LOCATION_ID,
         P_RECALL_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_REL_RECALL_LOC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_REL_RECALL_LOC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.08.48 AM


