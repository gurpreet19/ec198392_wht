
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.50.53 AM


CREATE or REPLACE PACKAGE RP_CARGO_FCST_TRANSPORT
IS

   FUNCTION DRAUGHT_MARK_ARR_FORWARD(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TUGS_ARR(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PILOT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_ARR_CENTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TUGS_DEP(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VOYAGE_NO(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_DEP_AFT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DRAUGHT_MARK_DEP_CENTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION MASTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_ARR_AFT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION EST_DEPARTURE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         FORECAST_ID VARCHAR2 (32) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CARGO_NAME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION DRAUGHT_MARK_DEP_FORWARD(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION BERTH_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_CARGO_FCST_TRANSPORT;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO_FCST_TRANSPORT
IS

   FUNCTION DRAUGHT_MARK_ARR_FORWARD(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_ARR_FORWARD      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_FORWARD;
   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_3      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_4      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TUGS_ARR(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TUGS_ARR      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TUGS_ARR;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.APPROVAL_BY      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.APPROVAL_STATE      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.CARGO_STATUS      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END CARGO_STATUS;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.CARRIER_ID      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END CARRIER_ID;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.LAYTIME      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END LAYTIME;
   FUNCTION PILOT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.PILOT      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END PILOT;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_5      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_7      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DRAUGHT_MARK_ARR_CENTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_ARR_CENTER      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_CENTER;
   FUNCTION TEXT_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_5      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_6      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TUGS_DEP(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TUGS_DEP      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TUGS_DEP;
   FUNCTION VOYAGE_NO(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VOYAGE_NO      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VOYAGE_NO;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.COMMENTS      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_3      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_5      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DRAUGHT_MARK_DEP_AFT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_DEP_AFT      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_AFT;
   FUNCTION DRAUGHT_MARK_DEP_CENTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_DEP_CENTER      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_CENTER;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.EST_ARRIVAL      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END EST_ARRIVAL;
   FUNCTION MASTER(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.MASTER      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END MASTER;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_6      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_2      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DRAUGHT_MARK_ARR_AFT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_ARR_AFT      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_ARR_AFT;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.RECORD_STATUS      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.SURVEYOR      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END SURVEYOR;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_1      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.AGENT      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END AGENT;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.APPROVAL_DATE      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_6      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_6;
   FUNCTION EST_DEPARTURE(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.EST_DEPARTURE      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END EST_DEPARTURE;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.ROW_BY_PK      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_2      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_3      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_4      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CARGO_NAME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.CARGO_NAME      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END CARGO_NAME;
   FUNCTION DATE_4(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_4      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DRAUGHT_MARK_DEP_FORWARD(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DRAUGHT_MARK_DEP_FORWARD      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DRAUGHT_MARK_DEP_FORWARD;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.REC_ID      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_1      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.TEXT_2      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_7      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_9      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION BERTH_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.BERTH_ID      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END BERTH_ID;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.DATE_1      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.PROD_FCTY_ID      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END PROD_FCTY_ID;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_10      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO_FCST_TRANSPORT.VALUE_8      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO_FCST_TRANSPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO_FCST_TRANSPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.51.04 AM


