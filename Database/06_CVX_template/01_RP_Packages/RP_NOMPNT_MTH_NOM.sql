
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.51.03 AM


CREATE or REPLACE PACKAGE RP_NOMPNT_MTH_NOM
IS

   FUNCTION CONFIRMED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION ENTRY_LOCATION_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EXT_ADJUSTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_CONFIRMED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NOM_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRIORITY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_NOMINATION_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION REQUESTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COUNTER_NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EXT_ACCEPTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_CONFIRMED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION OPER_NOM_IND(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHIPPER_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSACTION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_ACCEPTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONFIRMED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_ADJUSTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXT_CONFIRMED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NOMINATION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_ADJUSTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUPPLIER_NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXIT_LOCATION_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REQUESTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REQUESTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         NOMINATION_SEQ NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         NOMINATION_TYPE VARCHAR2 (32) ,
         NOM_CYCLE_CODE VARCHAR2 (32) ,
         OPER_NOM_IND VARCHAR2 (1) ,
         REF_NOMINATION_SEQ NUMBER ,
         REQUESTED_QTY NUMBER ,
         REQUESTED_DATE  DATE ,
         REQUESTED_MHM_REF VARCHAR2 (240) ,
         ACCEPTED_QTY NUMBER ,
         ACCEPTED_DATE  DATE ,
         EXT_ACCEPTED_QTY NUMBER ,
         EXT_ACCEPTED_DATE  DATE ,
         EXT_ACCEPTED_MHM_REF VARCHAR2 (240) ,
         ADJUSTED_QTY NUMBER ,
         ADJUSTED_DATE  DATE ,
         EXT_ADJUSTED_QTY NUMBER ,
         EXT_ADJUSTED_DATE  DATE ,
         EXT_ADJUSTED_MHM_REF VARCHAR2 (240) ,
         CONFIRMED_QTY NUMBER ,
         CONFIRMED_DATE  DATE ,
         EXT_CONFIRMED_QTY NUMBER ,
         EXT_CONFIRMED_DATE  DATE ,
         EXT_CONFIRMED_MHM_REF VARCHAR2 (240) ,
         SCHEDULED_QTY NUMBER ,
         SCHEDULED_DATE  DATE ,
         NOM_STATUS VARCHAR2 (32) ,
         SHIPPER_CODE VARCHAR2 (240) ,
         TRANSACTION_TYPE VARCHAR2 (32) ,
         PRIORITY NUMBER ,
         CONTRACT_ID VARCHAR2 (32) ,
         ENTRY_LOCATION_ID VARCHAR2 (32) ,
         EXIT_LOCATION_ID VARCHAR2 (32) ,
         COUNTER_NOMPNT_ID VARCHAR2 (32) ,
         SUPPLIER_NOMPNT_ID VARCHAR2 (32) ,
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
         TEXT_11 VARCHAR2 (2000) ,
         TEXT_12 VARCHAR2 (2000) ,
         TEXT_13 VARCHAR2 (2000) ,
         TEXT_14 VARCHAR2 (2000) ,
         TEXT_15 VARCHAR2 (2000) ,
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
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
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
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION ADJUSTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION ADJUSTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION EXT_ACCEPTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NOM_CYCLE_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_NOMPNT_MTH_NOM;

/



CREATE or REPLACE PACKAGE BODY RP_NOMPNT_MTH_NOM
IS

   FUNCTION CONFIRMED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.CONFIRMED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CONFIRMED_DATE;
   FUNCTION DATE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_10;
   FUNCTION ENTRY_LOCATION_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ENTRY_LOCATION_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ENTRY_LOCATION_ID;
   FUNCTION EXT_ADJUSTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ADJUSTED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ADJUSTED_DATE;
   FUNCTION EXT_CONFIRMED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_CONFIRMED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_CONFIRMED_QTY;
   FUNCTION NOM_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.NOM_STATUS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOM_STATUS;
   FUNCTION PRIORITY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.PRIORITY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END PRIORITY;
   FUNCTION REF_NOMINATION_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.REF_NOMINATION_SEQ      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REF_NOMINATION_SEQ;
   FUNCTION REQUESTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.REQUESTED_MHM_REF      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REQUESTED_MHM_REF;
   FUNCTION SCHEDULED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.SCHEDULED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SCHEDULED_QTY;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_16      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_18      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.APPROVAL_BY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.APPROVAL_STATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COUNTER_NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.COUNTER_NOMPNT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END COUNTER_NOMPNT_ID;
   FUNCTION EXT_ACCEPTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ACCEPTED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ACCEPTED_DATE;
   FUNCTION EXT_CONFIRMED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_CONFIRMED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_CONFIRMED_DATE;
   FUNCTION OPER_NOM_IND(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.OPER_NOM_IND      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END OPER_NOM_IND;
   FUNCTION SHIPPER_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.SHIPPER_CODE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SHIPPER_CODE;
   FUNCTION TRANSACTION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TRANSACTION_TYPE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TRANSACTION_TYPE;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_9;
   FUNCTION EXT_ACCEPTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ACCEPTED_MHM_REF      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ACCEPTED_MHM_REF;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.NEXT_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.OBJECT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.PREV_EQUAL_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_18      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_19      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.COMMENTS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION CONFIRMED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.CONFIRMED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CONFIRMED_QTY;
   FUNCTION DATE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_5;
   FUNCTION EXT_ADJUSTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ADJUSTED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ADJUSTED_QTY;
   FUNCTION EXT_CONFIRMED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_CONFIRMED_MHM_REF      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_CONFIRMED_MHM_REF;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.NEXT_EQUAL_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION NOMINATION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.NOMINATION_TYPE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOMINATION_TYPE;
   FUNCTION SCHEDULED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.SCHEDULED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SCHEDULED_DATE;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_14      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_17      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_20      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_12      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ACCEPTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ACCEPTED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ACCEPTED_QTY;
   FUNCTION CONTRACT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.CONTRACT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION EXT_ADJUSTED_MHM_REF(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ADJUSTED_MHM_REF      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ADJUSTED_MHM_REF;
   FUNCTION PREV_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.PREV_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.RECORD_STATUS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SUPPLIER_NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.SUPPLIER_NOMPNT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SUPPLIER_NOMPNT_ID;
   FUNCTION TEXT_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_16      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_15      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_19      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.APPROVAL_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_6;
   FUNCTION EXIT_LOCATION_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXIT_LOCATION_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXIT_LOCATION_ID;
   FUNCTION REQUESTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.REQUESTED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REQUESTED_DATE;
   FUNCTION REQUESTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.REQUESTED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REQUESTED_QTY;
   FUNCTION ROW_BY_PK(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ROW_BY_PK      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_13      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_13      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_17      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_20      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.REC_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ACCEPTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ACCEPTED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ACCEPTED_DATE;
   FUNCTION ADJUSTED_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ADJUSTED_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ADJUSTED_DATE;
   FUNCTION ADJUSTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.ADJUSTED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ADJUSTED_QTY;
   FUNCTION DATE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DATE_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.DAYTIME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION EXT_ACCEPTED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.EXT_ACCEPTED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END EXT_ACCEPTED_QTY;
   FUNCTION NOM_CYCLE_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.NOM_CYCLE_CODE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOM_CYCLE_CODE;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_11      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_12      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.TEXT_15      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_11      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_14      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_MTH_NOM.VALUE_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_NOMPNT_MTH_NOM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_NOMPNT_MTH_NOM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.51.22 AM


