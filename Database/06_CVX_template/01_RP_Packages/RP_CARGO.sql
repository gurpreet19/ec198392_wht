
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.51.55 AM


CREATE or REPLACE PACKAGE RP_CARGO
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARGO_CODE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION START_LOADING(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TO_FIELD(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_CODE_NUMERIC(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_NO_SUFFIX(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DELAY_REASON_TEXT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_LOADING(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EST_ARRIVAL_TO(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GROSS_QUANTITY(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SHIPMENT_NO(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CAPTAIN(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NOON_IND(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CARGO_NO_EXTENSION(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CARGO_NO NUMBER ,
         CARGO_NO_SUFFIX VARCHAR2 (30) ,
         CARGO_NO_EXTENSION VARCHAR2 (30) ,
         CAPTAIN VARCHAR2 (30) ,
         AGENT VARCHAR2 (16) ,
         SURVEYOR VARCHAR2 (16) ,
         LAYTIME VARCHAR2 (16) ,
         START_LOADING  DATE ,
         END_LOADING  DATE ,
         GROSS_QUANTITY NUMBER ,
         NET_QUANTITY NUMBER ,
         CARGO_CODE VARCHAR2 (16) ,
         CARGO_CODE_NUMERIC NUMBER ,
         PLANNED_BUOY VARCHAR2 (20) ,
         EST_ARRIVAL  DATE ,
         EST_ARRIVAL_TO  DATE ,
         SHIPMENT_NO VARCHAR2 (16) ,
         CARGO_TYPE VARCHAR2 (16) ,
         TO_FIELD VARCHAR2 (30) ,
         CARRIER_ID VARCHAR2 (32) ,
         SPECIAL_INSTRUCTIONS VARCHAR2 (2000) ,
         DELAY_REASON_TEXT VARCHAR2 (2000) ,
         EXPORT_TYPE VARCHAR2 (16) ,
         CARGO_STATUS VARCHAR2 (1) ,
         NOON_IND VARCHAR2 (1) ,
         PROD_FCTY_ID VARCHAR2 (32) ,
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
      P_CARGO_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_TYPE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EXPORT_TYPE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NET_QUANTITY(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PLANNED_BUOY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER;

END RP_CARGO;

/



CREATE or REPLACE PACKAGE BODY RP_CARGO
IS

   FUNCTION TEXT_3(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARGO.TEXT_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO.TEXT_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO.APPROVAL_BY      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO.APPROVAL_STATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CARGO_CODE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.CARGO_CODE      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_CODE;
   FUNCTION CARGO_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO.CARGO_STATUS      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_STATUS;
   FUNCTION CARRIER_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO.CARRIER_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARRIER_ID;
   FUNCTION LAYTIME(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.LAYTIME      (
         P_CARGO_NO );
         RETURN ret_value;
   END LAYTIME;
   FUNCTION START_LOADING(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.START_LOADING      (
         P_CARGO_NO );
         RETURN ret_value;
   END START_LOADING;
   FUNCTION TO_FIELD(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO.TO_FIELD      (
         P_CARGO_NO );
         RETURN ret_value;
   END TO_FIELD;
   FUNCTION VALUE_5(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_5      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION CARGO_CODE_NUMERIC(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.CARGO_CODE_NUMERIC      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_CODE_NUMERIC;
   FUNCTION CARGO_NO_SUFFIX(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO.CARGO_NO_SUFFIX      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_NO_SUFFIX;
   FUNCTION DELAY_REASON_TEXT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO.DELAY_REASON_TEXT      (
         P_CARGO_NO );
         RETURN ret_value;
   END DELAY_REASON_TEXT;
   FUNCTION END_LOADING(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.END_LOADING      (
         P_CARGO_NO );
         RETURN ret_value;
   END END_LOADING;
   FUNCTION EST_ARRIVAL_TO(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.EST_ARRIVAL_TO      (
         P_CARGO_NO );
         RETURN ret_value;
   END EST_ARRIVAL_TO;
   FUNCTION GROSS_QUANTITY(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.GROSS_QUANTITY      (
         P_CARGO_NO );
         RETURN ret_value;
   END GROSS_QUANTITY;
   FUNCTION SHIPMENT_NO(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.SHIPMENT_NO      (
         P_CARGO_NO );
         RETURN ret_value;
   END SHIPMENT_NO;
   FUNCTION AGENT(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.AGENT      (
         P_CARGO_NO );
         RETURN ret_value;
   END AGENT;
   FUNCTION CAPTAIN(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO.CAPTAIN      (
         P_CARGO_NO );
         RETURN ret_value;
   END CAPTAIN;
   FUNCTION COMMENTS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO.COMMENTS      (
         P_CARGO_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION EST_ARRIVAL(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.EST_ARRIVAL      (
         P_CARGO_NO );
         RETURN ret_value;
   END EST_ARRIVAL;
   FUNCTION VALUE_6(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_6      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.DATE_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION NOON_IND(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO.NOON_IND      (
         P_CARGO_NO );
         RETURN ret_value;
   END NOON_IND;
   FUNCTION RECORD_STATUS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARGO.RECORD_STATUS      (
         P_CARGO_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARGO.SPECIAL_INSTRUCTIONS      (
         P_CARGO_NO );
         RETURN ret_value;
   END SPECIAL_INSTRUCTIONS;
   FUNCTION VALUE_1(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.APPROVAL_DATE      (
         P_CARGO_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CARGO_NO_EXTENSION(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARGO.CARGO_NO_EXTENSION      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_NO_EXTENSION;
   FUNCTION ROW_BY_PK(
      P_CARGO_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARGO.ROW_BY_PK      (
         P_CARGO_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SURVEYOR(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.SURVEYOR      (
         P_CARGO_NO );
         RETURN ret_value;
   END SURVEYOR;
   FUNCTION VALUE_2(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_3      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_4      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CARGO_TYPE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.CARGO_TYPE      (
         P_CARGO_NO );
         RETURN ret_value;
   END CARGO_TYPE;
   FUNCTION EXPORT_TYPE(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.EXPORT_TYPE      (
         P_CARGO_NO );
         RETURN ret_value;
   END EXPORT_TYPE;
   FUNCTION NET_QUANTITY(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.NET_QUANTITY      (
         P_CARGO_NO );
         RETURN ret_value;
   END NET_QUANTITY;
   FUNCTION PLANNED_BUOY(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (20) ;
   BEGIN
      ret_value := EC_CARGO.PLANNED_BUOY      (
         P_CARGO_NO );
         RETURN ret_value;
   END PLANNED_BUOY;
   FUNCTION REC_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO.REC_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARGO.TEXT_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO.TEXT_2      (
         P_CARGO_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_7      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_9      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_CARGO_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARGO.DATE_1      (
         P_CARGO_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION PROD_FCTY_ID(
      P_CARGO_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARGO.PROD_FCTY_ID      (
         P_CARGO_NO );
         RETURN ret_value;
   END PROD_FCTY_ID;
   FUNCTION VALUE_10(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_10      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CARGO_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARGO.VALUE_8      (
         P_CARGO_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CARGO;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARGO TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.52.05 AM


