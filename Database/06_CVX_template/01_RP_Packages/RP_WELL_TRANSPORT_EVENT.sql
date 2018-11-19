
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.06.47 AM


CREATE or REPLACE PACKAGE RP_WELL_TRANSPORT_EVENT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSPORT_VEHICLE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DILUENT_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DILUENT_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TRANSPORT_COMPANY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATA_CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NET_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DILUENT_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TICKET_NUMBER(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NET_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DATA_CLASS_NAME VARCHAR2 (24) ,
         EVENT_NO NUMBER ,
         PRODUCTION_DAY  DATE ,
         TICKET_NUMBER VARCHAR2 (32) ,
         TRANSPORT_COMPANY VARCHAR2 (32) ,
         TRANSPORT_VEHICLE VARCHAR2 (32) ,
         NET_VOL NUMBER ,
         NET_VOL_ADJ NUMBER ,
         GRS_VOL NUMBER ,
         GRS_VOL_ADJ NUMBER ,
         BS_W NUMBER ,
         WATER_VOL NUMBER ,
         WATER_VOL_ADJ NUMBER ,
         DILUENT_VOL NUMBER ,
         DILUENT_VOL_ADJ NUMBER ,
         BS_W_WT NUMBER ,
         DILUENT_MASS NUMBER ,
         DILUENT_MASS_ADJ NUMBER ,
         GRS_MASS NUMBER ,
         GRS_MASS_ADJ NUMBER ,
         NET_MASS NUMBER ,
         NET_MASS_ADJ NUMBER ,
         WATER_MASS NUMBER ,
         WATER_MASS_ADJ NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BS_W(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BS_W_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DILUENT_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_WELL_TRANSPORT_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_TRANSPORT_EVENT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TEXT_3      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TEXT_4      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TRANSPORT_VEHICLE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TRANSPORT_VEHICLE      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TRANSPORT_VEHICLE;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DILUENT_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DILUENT_VOL      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_VOL;
   FUNCTION DILUENT_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DILUENT_VOL_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_VOL_ADJ;
   FUNCTION TRANSPORT_COMPANY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TRANSPORT_COMPANY      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TRANSPORT_COMPANY;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_5      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NET_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NET_MASS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END NET_MASS;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.COMMENTS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATA_CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DATA_CLASS_NAME      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DATA_CLASS_NAME;
   FUNCTION NET_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NET_VOL      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END NET_VOL;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_6      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DILUENT_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DILUENT_MASS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_MASS;
   FUNCTION GRS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.GRS_VOL_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END GRS_VOL_ADJ;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TICKET_NUMBER(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TICKET_NUMBER      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TICKET_NUMBER;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_1      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION WATER_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.WATER_VOL      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_VOL;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NET_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NET_MASS_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END NET_MASS_ADJ;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_2      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_3      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_4      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION GRS_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.GRS_MASS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END GRS_MASS;
   FUNCTION GRS_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.GRS_VOL      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END GRS_VOL;
   FUNCTION NET_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.NET_VOL_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END NET_VOL_ADJ;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.REC_ID      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TEXT_1      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.TEXT_2      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_7      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_9      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION WATER_MASS(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.WATER_MASS      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_MASS;
   FUNCTION WATER_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.WATER_MASS_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_MASS_ADJ;
   FUNCTION WATER_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.WATER_VOL_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_VOL_ADJ;
   FUNCTION BS_W(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.BS_W      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END BS_W;
   FUNCTION BS_W_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.BS_W_WT      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END BS_W_WT;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DAYTIME      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DILUENT_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.DILUENT_MASS_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_MASS_ADJ;
   FUNCTION GRS_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.GRS_MASS_ADJ      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END GRS_MASS_ADJ;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.PRODUCTION_DAY      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_10      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_TRANSPORT_EVENT.VALUE_8      (
         P_OBJECT_ID,
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_WELL_TRANSPORT_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_TRANSPORT_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.06.58 AM


