
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.55.06 AM


CREATE or REPLACE PACKAGE RP_STIM_PENDING_ITEM
IS

   FUNCTION CASCADE_MSG(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STIM_PENDING_NO(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION DATE_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FORECAST_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PERIOD(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         STIM_PENDING_ITEM_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         STIM_PENDING_NO NUMBER ,
         PERIOD VARCHAR2 (32) ,
         FORECAST_ID VARCHAR2 (32) ,
         STATUS_CODE VARCHAR2 (32) ,
         CASCADE_MSG VARCHAR2 (2000) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE;

END RP_STIM_PENDING_ITEM;

/



CREATE or REPLACE PACKAGE BODY RP_STIM_PENDING_ITEM
IS

   FUNCTION CASCADE_MSG(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.CASCADE_MSG      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END CASCADE_MSG;
   FUNCTION TEXT_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.TEXT_3      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.APPROVAL_BY      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.APPROVAL_STATE      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REF_OBJECT_ID_4      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION STIM_PENDING_NO(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.STIM_PENDING_NO      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END STIM_PENDING_NO;
   FUNCTION VALUE_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.VALUE_5      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.NEXT_DAYTIME      (
         P_STIM_PENDING_ITEM_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.OBJECT_ID      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.PREV_EQUAL_DAYTIME      (
         P_STIM_PENDING_ITEM_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION DATE_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DATE_3      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DATE_5      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.NEXT_EQUAL_DAYTIME      (
         P_STIM_PENDING_ITEM_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REF_OBJECT_ID_2      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REF_OBJECT_ID_3      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.TEXT_1      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DATE_2      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.PREV_DAYTIME      (
         P_STIM_PENDING_ITEM_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.RECORD_STATUS      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REF_OBJECT_ID_5      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.VALUE_1      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.APPROVAL_DATE      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION FORECAST_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.FORECAST_ID      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION PERIOD(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.PERIOD      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END PERIOD;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REF_OBJECT_ID_1      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.ROW_BY_PK      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.STATUS_CODE      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END STATUS_CODE;
   FUNCTION TEXT_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.TEXT_2      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.TEXT_4      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.TEXT_5      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.VALUE_2      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.VALUE_3      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.VALUE_4      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DATE_4      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.REC_ID      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DATE_1      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_STIM_PENDING_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING_ITEM.DAYTIME      (
         P_STIM_PENDING_ITEM_NO );
         RETURN ret_value;
   END DAYTIME;

END RP_STIM_PENDING_ITEM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STIM_PENDING_ITEM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.55.14 AM


