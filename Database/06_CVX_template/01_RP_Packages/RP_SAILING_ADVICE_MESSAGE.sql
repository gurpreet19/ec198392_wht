
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.39.53 AM


CREATE or REPLACE PACKAGE RP_SAILING_ADVICE_MESSAGE
IS

   FUNCTION DOC_CODE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MESSAGE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN CLOB;
   FUNCTION PARCEL_NO(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECEIVER_ID(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SAILING_MESSAGE_NO NUMBER ,
         DOC_CODE VARCHAR2 (32) ,
         PARCEL_NO NUMBER ,
         RECEIVER_ID VARCHAR2 (32) ,
         DISTRIBUTION_METHOD VARCHAR2 (32) ,
         MESSAGE  CLOB ,
         SENT  DATE ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         TEXT_1 VARCHAR2 (32) ,
         TEXT_2 VARCHAR2 (240) ,
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
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SENT(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DISTRIBUTION_METHOD(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_SAILING_ADVICE_MESSAGE;

/



CREATE or REPLACE PACKAGE BODY RP_SAILING_ADVICE_MESSAGE
IS

   FUNCTION DOC_CODE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DOC_CODE      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DOC_CODE;
   FUNCTION MESSAGE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.MESSAGE      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END MESSAGE;
   FUNCTION PARCEL_NO(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.PARCEL_NO      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END PARCEL_NO;
   FUNCTION TEXT_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_3      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_4      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.APPROVAL_BY      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.APPROVAL_STATE      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_5      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_5      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_6      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION DATE_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_3      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_5      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION RECEIVER_ID(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.RECEIVER_ID      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END RECEIVER_ID;
   FUNCTION TEXT_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_1      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION VALUE_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_6      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_2      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.RECORD_STATUS      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_1      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.APPROVAL_DATE      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_6      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION ROW_BY_PK(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.ROW_BY_PK      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.TEXT_2      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_2(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_2      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_3      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.VALUE_4      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_4      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.REC_ID      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SENT(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.SENT      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END SENT;
   FUNCTION DATE_1(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DATE_1      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DISTRIBUTION_METHOD(
      P_SAILING_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SAILING_ADVICE_MESSAGE.DISTRIBUTION_METHOD      (
         P_SAILING_MESSAGE_NO );
         RETURN ret_value;
   END DISTRIBUTION_METHOD;

END RP_SAILING_ADVICE_MESSAGE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_SAILING_ADVICE_MESSAGE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.40.03 AM


