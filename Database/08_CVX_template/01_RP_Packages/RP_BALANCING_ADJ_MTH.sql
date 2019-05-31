
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.19.36 AM


CREATE or REPLACE PACKAGE RP_BALANCING_ADJ_MTH
IS

   FUNCTION TEXT_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ENERGY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_MASS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRODUCT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NET_VOL(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STREAM_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_OBJECT_TYPE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         FROM_OBJECT_ID VARCHAR2 (32) ,
         FROM_OBJECT_TYPE VARCHAR2 (32) ,
         TO_OBJECT_ID VARCHAR2 (32) ,
         TO_OBJECT_TYPE VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
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
         NET_VOL NUMBER ,
         NET_MASS NUMBER ,
         ENERGY NUMBER ,
         BLEND NUMBER ,
         BITUMEN NUMBER ,
         DILUENT NUMBER ,
         ADJUSTMENT_NO NUMBER ,
         PRODUCT_GROUP_ID VARCHAR2 (32) ,
         STRM_BAL_CATEGORY VARCHAR2 (32) ,
         STREAM_ID VARCHAR2 (32) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (240) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BITUMEN(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BLEND(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FROM_OBJECT_TYPE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DILUENT(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FROM_OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_GROUP_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STRM_BAL_CATEGORY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_BALANCING_ADJ_MTH;

/



CREATE or REPLACE PACKAGE BODY RP_BALANCING_ADJ_MTH
IS

   FUNCTION TEXT_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TEXT_3      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TEXT_4      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.APPROVAL_BY      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.APPROVAL_STATE      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION ENERGY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.ENERGY      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END ENERGY;
   FUNCTION VALUE_5(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_5      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NET_MASS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.NET_MASS      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END NET_MASS;
   FUNCTION NEXT_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.NEXT_DAYTIME      (
         P_ADJUSTMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.OBJECT_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.PREV_EQUAL_DAYTIME      (
         P_ADJUSTMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRODUCT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.PRODUCT_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION COMMENTS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.COMMENTS      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DATE_3      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DATE_5      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NET_VOL(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.NET_VOL      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END NET_VOL;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.NEXT_EQUAL_DAYTIME      (
         P_ADJUSTMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_6      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DATE_2      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.PREV_DAYTIME      (
         P_ADJUSTMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.RECORD_STATUS      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION STREAM_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.STREAM_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END STREAM_ID;
   FUNCTION TO_OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TO_OBJECT_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TO_OBJECT_ID;
   FUNCTION TO_OBJECT_TYPE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TO_OBJECT_TYPE      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TO_OBJECT_TYPE;
   FUNCTION VALUE_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_1      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.APPROVAL_DATE      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.ROW_BY_PK      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_2      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_3      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_4      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION BITUMEN(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.BITUMEN      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END BITUMEN;
   FUNCTION BLEND(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.BLEND      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END BLEND;
   FUNCTION DATE_4(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DATE_4      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION FROM_OBJECT_TYPE(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.FROM_OBJECT_TYPE      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END FROM_OBJECT_TYPE;
   FUNCTION REC_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.REC_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TEXT_1      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.TEXT_2      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_7      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_9      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DATE_1      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DAYTIME      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DILUENT(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.DILUENT      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END DILUENT;
   FUNCTION FROM_OBJECT_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.FROM_OBJECT_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END FROM_OBJECT_ID;
   FUNCTION PRODUCT_GROUP_ID(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.PRODUCT_GROUP_ID      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END PRODUCT_GROUP_ID;
   FUNCTION STRM_BAL_CATEGORY(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.STRM_BAL_CATEGORY      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END STRM_BAL_CATEGORY;
   FUNCTION VALUE_10(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_10      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ADJUSTMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BALANCING_ADJ_MTH.VALUE_8      (
         P_ADJUSTMENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_BALANCING_ADJ_MTH;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_BALANCING_ADJ_MTH TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.19.45 AM


