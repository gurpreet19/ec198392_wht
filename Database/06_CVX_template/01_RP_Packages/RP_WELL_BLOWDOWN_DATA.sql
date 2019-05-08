
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.21.48 AM


CREATE or REPLACE PACKAGE RP_WELL_BLOWDOWN_DATA
IS

   FUNCTION AVG_SEP_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AVG_COND_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COND_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OIL_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AVG_SEP_TEMP(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ANNULUS_PRESS_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ANNULUS_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANNULUS_PRESS_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AVG_CHOKE_SIZE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AVG_WATER_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OTHER_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         EVENT_NO NUMBER ,
         PARENT_EVENT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         AVG_CHOKE_SIZE NUMBER ,
         AVG_WH_PRESS NUMBER ,
         AVG_WH_TEMP NUMBER ,
         AVG_SEP_PRESS NUMBER ,
         AVG_SEP_TEMP NUMBER ,
         ANNULUS_PRESS NUMBER ,
         ANNULUS_PRESS_2 NUMBER ,
         ANNULUS_PRESS_3 NUMBER ,
         AVG_OIL_RATE NUMBER ,
         AVG_COND_RATE NUMBER ,
         AVG_WATER_RATE NUMBER ,
         OIL_SAMPLE NUMBER ,
         COND_SAMPLE NUMBER ,
         WATER_SAMPLE NUMBER ,
         OTHER_SAMPLE NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
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
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AVG_WH_TEMP(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PARENT_EVENT_NO(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AVG_OIL_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION AVG_WH_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;

END RP_WELL_BLOWDOWN_DATA;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_BLOWDOWN_DATA
IS

   FUNCTION AVG_SEP_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_SEP_PRESS      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_SEP_PRESS;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.TEXT_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.TEXT_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.APPROVAL_BY      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.APPROVAL_STATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION AVG_COND_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_COND_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_COND_RATE;
   FUNCTION COND_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.COND_SAMPLE      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_SAMPLE;
   FUNCTION OIL_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.OIL_SAMPLE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_SAMPLE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.VALUE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION AVG_SEP_TEMP(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_SEP_TEMP      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_SEP_TEMP;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.NEXT_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION ANNULUS_PRESS_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.ANNULUS_PRESS_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END ANNULUS_PRESS_3;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.COMMENTS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DATE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DATE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.NEXT_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION ANNULUS_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.ANNULUS_PRESS      (
         P_EVENT_NO );
         RETURN ret_value;
   END ANNULUS_PRESS;
   FUNCTION ANNULUS_PRESS_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.ANNULUS_PRESS_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END ANNULUS_PRESS_2;
   FUNCTION AVG_CHOKE_SIZE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_CHOKE_SIZE      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_CHOKE_SIZE;
   FUNCTION AVG_WATER_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_WATER_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_WATER_RATE;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DATE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION OTHER_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.OTHER_SAMPLE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OTHER_SAMPLE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.PREV_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.RECORD_STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.VALUE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.APPROVAL_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.ROW_BY_PK      (
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.TEXT_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.VALUE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.VALUE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.VALUE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WATER_SAMPLE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.WATER_SAMPLE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_SAMPLE;
   FUNCTION AVG_WH_TEMP(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_WH_TEMP      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_WH_TEMP;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DATE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PARENT_EVENT_NO(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.PARENT_EVENT_NO      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_EVENT_NO;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.REC_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.TEXT_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.TEXT_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION AVG_OIL_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_OIL_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_OIL_RATE;
   FUNCTION AVG_WH_PRESS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.AVG_WH_PRESS      (
         P_EVENT_NO );
         RETURN ret_value;
   END AVG_WH_PRESS;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DATE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_BLOWDOWN_DATA.DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;

END RP_WELL_BLOWDOWN_DATA;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_BLOWDOWN_DATA TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.21.58 AM


