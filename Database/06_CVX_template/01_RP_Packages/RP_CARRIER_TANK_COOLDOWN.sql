
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.05.18 AM


CREATE or REPLACE PACKAGE RP_CARRIER_TANK_COOLDOWN
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         TANK_NO NUMBER ,
         TEMP NUMBER ,
         QTY NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;

END RP_CARRIER_TANK_COOLDOWN;

/



CREATE or REPLACE PACKAGE BODY RP_CARRIER_TANK_COOLDOWN
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.TEXT_3      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.TEXT_4      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.APPROVAL_BY      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_5      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.DATE_3      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.DATE_5      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END DATE_5;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_6      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.DATE_2      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.RECORD_STATUS      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_1      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.QTY      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END QTY;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.ROW_BY_PK      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_2      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_3      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_4      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.DATE_4      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.REC_ID      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.TEXT_1      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.TEXT_2      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_7      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_9      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.DATE_1      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_10      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TANK_NO IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CARRIER_TANK_COOLDOWN.VALUE_8      (
         P_OBJECT_ID,
         P_TANK_NO,
         P_TEMP );
         RETURN ret_value;
   END VALUE_8;

END RP_CARRIER_TANK_COOLDOWN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CARRIER_TANK_COOLDOWN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.05.24 AM


