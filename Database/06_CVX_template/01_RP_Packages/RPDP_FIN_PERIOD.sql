
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.49 AM


CREATE or REPLACE PACKAGE RPDP_FIN_PERIOD
IS

   FUNCTION GETCOMPANYIDBYAREACODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CHKPERIODEXISTBYOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DOCUMENT_DATE IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING')
      RETURN DATE;
   FUNCTION GETCLOSEDPERIODSTATUS(
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETCLOSEDPERIODSTATUSALL(
      P_DAYTIME IN DATE,
      P_COUNTRY_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCURROPENPERIODBYOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING',
      P_DOC_KEY IN VARCHAR2 DEFAULT NULL,
      P_DOC_DATE IN DATE DEFAULT NULL)
      RETURN DATE;
   FUNCTION GETCURROPENPERIOD(
      P_DAYTIME IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING')
      RETURN DATE;
   FUNCTION GETLATESTFULLYCLOSEDPERIOD(
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETCURRENTOPENPERIOD(
      P_COUNTRY_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING',
      P_DOC_KEY IN VARCHAR2 DEFAULT NULL,
      P_DOC_DATE IN DATE DEFAULT NULL)
      RETURN DATE;

END RPDP_FIN_PERIOD;

/



CREATE or REPLACE PACKAGE BODY RPDP_FIN_PERIOD
IS

   FUNCTION GETCOMPANYIDBYAREACODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCOMPANYIDBYAREACODE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_BOOKING_AREA_CODE );
         RETURN ret_value;
   END GETCOMPANYIDBYAREACODE;
   FUNCTION CHKPERIODEXISTBYOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DOCUMENT_DATE IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.CHKPERIODEXISTBYOBJECT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_DOCUMENT_DATE,
         P_BOOKING_AREA_CODE,
         P_PERIOD_TYPE );
         RETURN ret_value;
   END CHKPERIODEXISTBYOBJECT;
   FUNCTION GETCLOSEDPERIODSTATUS(
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCLOSEDPERIODSTATUS      (
         P_DAYTIME );
         RETURN ret_value;
   END GETCLOSEDPERIODSTATUS;
   FUNCTION GETCLOSEDPERIODSTATUSALL(
      P_DAYTIME IN DATE,
      P_COUNTRY_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCLOSEDPERIODSTATUSALL      (
         P_DAYTIME,
         P_COUNTRY_ID,
         P_COMPANY_ID,
         P_PERIOD_TYPE );
         RETURN ret_value;
   END GETCLOSEDPERIODSTATUSALL;
   FUNCTION GETCURROPENPERIODBYOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING',
      P_DOC_KEY IN VARCHAR2 DEFAULT NULL,
      P_DOC_DATE IN DATE DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCURROPENPERIODBYOBJECT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_BOOKING_AREA_CODE,
         P_PERIOD_TYPE,
         P_DOC_KEY,
         P_DOC_DATE );
         RETURN ret_value;
   END GETCURROPENPERIODBYOBJECT;
   FUNCTION GETCURROPENPERIOD(
      P_DAYTIME IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCURROPENPERIOD      (
         P_DAYTIME,
         P_PERIOD_TYPE );
         RETURN ret_value;
   END GETCURROPENPERIOD;
   FUNCTION GETLATESTFULLYCLOSEDPERIOD(
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETLATESTFULLYCLOSEDPERIOD      (
         P_BOOKING_AREA_CODE,
         P_PERIOD_TYPE );
         RETURN ret_value;
   END GETLATESTFULLYCLOSEDPERIOD;
   FUNCTION GETCURRENTOPENPERIOD(
      P_COUNTRY_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_BOOKING_AREA_CODE IN VARCHAR2,
      P_PERIOD_TYPE IN VARCHAR2 DEFAULT 'BOOKING',
      P_DOC_KEY IN VARCHAR2 DEFAULT NULL,
      P_DOC_DATE IN DATE DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FIN_PERIOD.GETCURRENTOPENPERIOD      (
         P_COUNTRY_ID,
         P_COMPANY_ID,
         P_BOOKING_AREA_CODE,
         P_PERIOD_TYPE,
         P_DOC_KEY,
         P_DOC_DATE );
         RETURN ret_value;
   END GETCURRENTOPENPERIOD;

END RPDP_FIN_PERIOD;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_FIN_PERIOD TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.51 AM


