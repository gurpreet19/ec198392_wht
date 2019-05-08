
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.05.57 AM


CREATE or REPLACE PACKAGE RP_CARGO_TRANSPORT
IS

   FUNCTION DATE_10(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_11(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_ARR_FORWARD(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_7(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TUGS_ARR(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_16(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_37(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_47(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_48(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_51(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_15(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PILOT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_8(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_42(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_46(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_ARR_CENTER(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_18(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TUGS_DEP(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_29(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_31(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_32(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_36(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_54(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VOYAGE_NO(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_12(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_DEP_AFT(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DRAUGHT_MARK_DEP_CENTER(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION MASTER(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_9(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_45(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_49(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_14(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_ARR_AFT(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_33(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_34(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_52(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EST_DEPARTURE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         CARGO_NAME VARCHAR2 (100) ,
         CARRIER_ID VARCHAR2 (32) ,
         AGENT VARCHAR2 (32) ,
         SURVEYOR VARCHAR2 (32) ,
         LAYTIME VARCHAR2 (16) ,
         EST_ARRIVAL  DATE ,
         EST_DEPARTURE  DATE ,
         CARGO_STATUS VARCHAR2 (1) ,
         PROD_FCTY_ID VARCHAR2 (32) ,
         MASTER VARCHAR2 (32) ,
         PILOT VARCHAR2 (32) ,
         TUGS_ARR NUMBER ,
         TUGS_DEP NUMBER ,
         DRAUGHT_MARK_ARR_AFT NUMBER ,
         DRAUGHT_MARK_ARR_CENTER NUMBER ,
         DRAUGHT_MARK_ARR_FORWARD NUMBER ,
         DRAUGHT_MARK_DEP_AFT NUMBER ,
         DRAUGHT_MARK_DEP_CENTER NUMBER ,
         DRAUGHT_MARK_DEP_FORWARD NUMBER ,
         VOYAGE_NO VARCHAR2 (64) ,
         BERTH_ID VARCHAR2 (32) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
         FCTY_CLASS_1_ID_LIGHT VARCHAR2 (32) ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
         VALUE_31 NUMBER ,
         VALUE_32 NUMBER ,
         VALUE_33 NUMBER ,
         VALUE_34 NUMBER ,
         VALUE_35 NUMBER ,
         VALUE_36 NUMBER ,
         VALUE_37 NUMBER ,
         VALUE_38 NUMBER ,
         VALUE_39 NUMBER ,
         VALUE_40 NUMBER ,
         VALUE_41 NUMBER ,
         VALUE_42 NUMBER ,
         VALUE_43 NUMBER ,
         VALUE_44 NUMBER ,
         VALUE_45 NUMBER ,
         VALUE_46 NUMBER ,
         VALUE_47 NUMBER ,
         VALUE_48 NUMBER ,
         VALUE_49 NUMBER ,
         VALUE_50 NUMBER ,
         VALUE_51 NUMBER ,
         VALUE_52 NUMBER ,
         VALUE_53 NUMBER ,
         VALUE_54 NUMBER ,
         VALUE_55 NUMBER ,
         DATE_11  DATE ,
         DATE_12  DATE ,
         DATE_13  DATE ,
         DATE_14  DATE ,
         DATE_15  DATE  );
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_55(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_NAME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_DEP_FORWARD(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FCTY_CLASS_1_ID_LIGHT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_10(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_6(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_38(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_39(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_40(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_43(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_44(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BERTH_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_13(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_35(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_41(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_50(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_53(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;

END RP_CARGO_TRANSPORT;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_TRANSPORT
IS

   FUNCTION DATE_10(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_10      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DATE_11(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_11      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_11;
   FUNCTION DRAUGHT_MARK_ARR_FORWARD(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_ARR_FORWARD      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_FORWARD;
   FUNCTION REF_OBJECT_ID_7(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_7      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_7;
   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_7(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_7      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TUGS_ARR(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TUGS_ARR      (
         P_CARGO_NO );
         RETURN ret_value;
   END TUGS_ARR;
   FUNCTION VALUE_16(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_16      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_18      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_21      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_27      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_30      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION VALUE_37(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_37      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_37;
   FUNCTION VALUE_47(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_47      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_47;
   FUNCTION VALUE_48(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_48      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_48;
   FUNCTION VALUE_51(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_51      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_51;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.APPROVAL_BY      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.APPROVAL_STATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.CARGO_STATUS      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_STATUS;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.CARRIER_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARRIER_ID;
   FUNCTION DATE_15(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_15      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_15;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.LAYTIME      (
         P_CARGO_NO );
         RETURN ret_value;
   END LAYTIME;
   FUNCTION PILOT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.PILOT      (
         P_CARGO_NO );
         RETURN ret_value;
   END PILOT;
   FUNCTION REF_OBJECT_ID_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REF_OBJECT_ID_8(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_8      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_8;
   FUNCTION VALUE_23(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_23      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_28      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_42(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_42      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_42;
   FUNCTION VALUE_46(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_46      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_46;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_5      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_7      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_9      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION DRAUGHT_MARK_ARR_CENTER(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_ARR_CENTER      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_CENTER;
   FUNCTION TEXT_10(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_10      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_18(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_18      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_19      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_5(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_5      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_6      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TUGS_DEP(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TUGS_DEP      (
         P_CARGO_NO );
         RETURN ret_value;
   END TUGS_DEP;
   FUNCTION VALUE_29(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_29      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION VALUE_31(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_31      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_31;
   FUNCTION VALUE_32(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_32      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_32;
   FUNCTION VALUE_36(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_36      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_36;
   FUNCTION VALUE_54(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_54      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_54;
   FUNCTION VOYAGE_NO(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VOYAGE_NO      (
         P_CARGO_NO );
         RETURN ret_value;
   END VOYAGE_NO;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.COMMENTS      (
         P_CARGO_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_12(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_12      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_12;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_5      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DRAUGHT_MARK_DEP_AFT(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_DEP_AFT      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_AFT;
   FUNCTION DRAUGHT_MARK_DEP_CENTER(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_DEP_CENTER      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_CENTER;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.EST_ARRIVAL      (
         P_CARGO_NO );
         RETURN ret_value;
   END EST_ARRIVAL;
   FUNCTION MASTER(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.MASTER      (
         P_CARGO_NO );
         RETURN ret_value;
   END MASTER;
   FUNCTION REF_OBJECT_ID_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_9(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_9      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_9;
   FUNCTION TEXT_14(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_14      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_17(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_17      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_20      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION VALUE_12(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_12      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_22      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_26      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_45(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_45      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_45;
   FUNCTION VALUE_49(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_49      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_49;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_6      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_14(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_14      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_14;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DRAUGHT_MARK_ARR_AFT(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_ARR_AFT      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_AFT;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.RECORD_STATUS      (
         P_CARGO_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_5      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.SURVEYOR      (
         P_CARGO_NO );
         RETURN ret_value;
   END SURVEYOR;
   FUNCTION TEXT_16(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_16      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_15      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_19      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION VALUE_33(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_33      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_33;
   FUNCTION VALUE_34(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_34      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_34;
   FUNCTION VALUE_52(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_52      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_52;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.AGENT      (
         P_CARGO_NO );
         RETURN ret_value;
   END AGENT;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.APPROVAL_DATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_6      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION EST_DEPARTURE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.EST_DEPARTURE      (
         P_CARGO_NO );
         RETURN ret_value;
   END EST_DEPARTURE;
   FUNCTION REF_OBJECT_ID_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.ROW_BY_PK      (
         P_CARGO_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_13      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_9(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_9      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_13(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_13      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_17      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_20      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_25      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION VALUE_55(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_55      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_55;
   FUNCTION CARGO_NAME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.CARGO_NAME      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_NAME;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DRAUGHT_MARK_DEP_FORWARD(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DRAUGHT_MARK_DEP_FORWARD      (
         P_CARGO_NO );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_FORWARD;
   FUNCTION FCTY_CLASS_1_ID_LIGHT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.FCTY_CLASS_1_ID_LIGHT      (
         P_CARGO_NO );
         RETURN ret_value;
   END FCTY_CLASS_1_ID_LIGHT;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REC_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_OBJECT_ID_10(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_10      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_10;
   FUNCTION REF_OBJECT_ID_6(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.REF_OBJECT_ID_6      (
         P_CARGO_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_6;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_38(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_38      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_38;
   FUNCTION VALUE_39(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_39      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_39;
   FUNCTION VALUE_40(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_40      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_40;
   FUNCTION VALUE_43(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_43      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_43;
   FUNCTION VALUE_44(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_44      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_44;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_7      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_9      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION BERTH_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.BERTH_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END BERTH_ID;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_13(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_13      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_13;
   FUNCTION DATE_8(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.DATE_8      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.PROD_FCTY_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END PROD_FCTY_ID;
   FUNCTION TEXT_11(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_11      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_12      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_15      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TEXT_8(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.TEXT_8      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_10      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_11      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_14      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_24      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_35(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_35      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_35;
   FUNCTION VALUE_41(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_41      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_41;
   FUNCTION VALUE_50(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_50      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_50;
   FUNCTION VALUE_53(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_53      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_53;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_TRANSPORT.VALUE_8      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_TRANSPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_TRANSPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.06.23 AM


