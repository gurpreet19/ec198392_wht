
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.29 AM


CREATE or REPLACE PACKAGE RPDP_CURRENCY
IS

   FUNCTION GETCURR100(
      P_CURRENCY_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION CONVERT(
      P_DAYTIME IN DATE,
      P_AMOUNT IN NUMBER,
      P_FROM_CURRENCY_CODE IN VARCHAR2,
      P_TO_CURRENCY_CODE IN VARCHAR2,
      P_FOREX_SOURCE_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CONVERTVIACURRENCY(
      P_INPUT_VAL IN NUMBER,
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY')
      RETURN NUMBER;
   FUNCTION GETEXRATEVIACURRENCY(
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY',
      P_OPERATOR IN VARCHAR2 DEFAULT '<=')
      RETURN NUMBER;
   FUNCTION GETFOREXDATEVIACURRENCY(
      P_BOOK_CURR_CODE IN VARCHAR2,
      P_LOCAL_CURR_CODE IN VARCHAR2,
      P_GROUP_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY')
      RETURN DATE;
   FUNCTION GETEXCHANGERATE(
      P_DAYTIME IN DATE,
      P_FROM_CURRENCY_CODE IN VARCHAR2,
      P_TO_CURRENCY_CODE IN VARCHAR2,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_TIME_SCOPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
      TYPE REC_GETEXROWVIACURRENCY IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CURRENCY_ID VARCHAR2 (32) ,
         FOREX_SOURCE_ID VARCHAR2 (32) ,
         TIME_SCOPE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RATE NUMBER ,
         PRECISION NUMBER ,
         RATE_TYPE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
   FUNCTION GETEXROWVIACURRENCY(
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY',
      P_OPERATOR IN VARCHAR2 DEFAULT '<=')
      RETURN REC_GETEXROWVIACURRENCY;

END RPDP_CURRENCY;

/



CREATE or REPLACE PACKAGE BODY RPDP_CURRENCY
IS

   FUNCTION GETCURR100(
      P_CURRENCY_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CURRENCY.GETCURR100      (
         P_CURRENCY_CODE,
         P_DAYTIME );
         RETURN ret_value;
   END GETCURR100;
   FUNCTION CONVERT(
      P_DAYTIME IN DATE,
      P_AMOUNT IN NUMBER,
      P_FROM_CURRENCY_CODE IN VARCHAR2,
      P_TO_CURRENCY_CODE IN VARCHAR2,
      P_FOREX_SOURCE_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURRENCY.CONVERT      (
         P_DAYTIME,
         P_AMOUNT,
         P_FROM_CURRENCY_CODE,
         P_TO_CURRENCY_CODE,
         P_FOREX_SOURCE_ID );
         RETURN ret_value;
   END CONVERT;
   FUNCTION CONVERTVIACURRENCY(
      P_INPUT_VAL IN NUMBER,
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURRENCY.CONVERTVIACURRENCY      (
         P_INPUT_VAL,
         P_FROM_CURR_CODE,
         P_TO_CURR_CODE,
         P_VIA_CURR_CODE,
         P_DAYTIME,
         P_FOREX_SOURCE_ID,
         P_DURATION );
         RETURN ret_value;
   END CONVERTVIACURRENCY;
   FUNCTION GETEXRATEVIACURRENCY(
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY',
      P_OPERATOR IN VARCHAR2 DEFAULT '<=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURRENCY.GETEXRATEVIACURRENCY      (
         P_FROM_CURR_CODE,
         P_TO_CURR_CODE,
         P_VIA_CURR_CODE,
         P_DAYTIME,
         P_FOREX_SOURCE_ID,
         P_DURATION,
         P_OPERATOR );
         RETURN ret_value;
   END GETEXRATEVIACURRENCY;
   FUNCTION GETFOREXDATEVIACURRENCY(
      P_BOOK_CURR_CODE IN VARCHAR2,
      P_LOCAL_CURR_CODE IN VARCHAR2,
      P_GROUP_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CURRENCY.GETFOREXDATEVIACURRENCY      (
         P_BOOK_CURR_CODE,
         P_LOCAL_CURR_CODE,
         P_GROUP_CURR_CODE,
         P_DAYTIME,
         P_FOREX_SOURCE_ID,
         P_DURATION );
         RETURN ret_value;
   END GETFOREXDATEVIACURRENCY;
   FUNCTION GETEXCHANGERATE(
      P_DAYTIME IN DATE,
      P_FROM_CURRENCY_CODE IN VARCHAR2,
      P_TO_CURRENCY_CODE IN VARCHAR2,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_TIME_SCOPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURRENCY.GETEXCHANGERATE      (
         P_DAYTIME,
         P_FROM_CURRENCY_CODE,
         P_TO_CURRENCY_CODE,
         P_FOREX_SOURCE_ID,
         P_TIME_SCOPE );
         RETURN ret_value;
   END GETEXCHANGERATE;
   FUNCTION GETEXROWVIACURRENCY(
      P_FROM_CURR_CODE IN VARCHAR2,
      P_TO_CURR_CODE IN VARCHAR2,
      P_VIA_CURR_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FOREX_SOURCE_ID IN VARCHAR2,
      P_DURATION IN VARCHAR2 DEFAULT 'DAILY',
      P_OPERATOR IN VARCHAR2 DEFAULT '<=')
      RETURN REC_GETEXROWVIACURRENCY
   IS
      ret_value    REC_GETEXROWVIACURRENCY ;
   BEGIN
      ret_value := ECDP_CURRENCY.GETEXROWVIACURRENCY      (
         P_FROM_CURR_CODE,
         P_TO_CURR_CODE,
         P_VIA_CURR_CODE,
         P_DAYTIME,
         P_FOREX_SOURCE_ID,
         P_DURATION,
         P_OPERATOR );
         RETURN ret_value;
   END GETEXROWVIACURRENCY;

END RPDP_CURRENCY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CURRENCY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.31 AM


