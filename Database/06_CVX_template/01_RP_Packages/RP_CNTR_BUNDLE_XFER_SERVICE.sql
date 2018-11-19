
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.41.02 AM


CREATE or REPLACE PACKAGE RP_CNTR_BUNDLE_XFER_SERVICE
IS

   FUNCTION SERVICE_UOM(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SERVICE_VALUE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_5(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         XFER_NO NUMBER ,
         SERVICE_CODE VARCHAR2 (32) ,
         SERVICE_VALUE NUMBER ,
         SERVICE_UOM VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
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
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE;

END RP_CNTR_BUNDLE_XFER_SERVICE;

/



CREATE or REPLACE PACKAGE BODY RP_CNTR_BUNDLE_XFER_SERVICE
IS

   FUNCTION SERVICE_UOM(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.SERVICE_UOM      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END SERVICE_UOM;
   FUNCTION SERVICE_VALUE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.SERVICE_VALUE      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END SERVICE_VALUE;
   FUNCTION TEXT_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.TEXT_3      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.TEXT_4      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.APPROVAL_BY      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.APPROVAL_STATE      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.VALUE_5      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_5(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.TEXT_5      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION COMMENTS(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.COMMENTS      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.DATE_3      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION TEXT_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.TEXT_1      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.DATE_2      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.RECORD_STATUS      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.VALUE_1      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.APPROVAL_DATE      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.ROW_BY_PK      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.TEXT_2      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_2(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.VALUE_2      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.VALUE_3      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.VALUE_4      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.REC_ID      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_XFER_NO IN NUMBER,
      P_SERVICE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTR_BUNDLE_XFER_SERVICE.DATE_1      (
         P_XFER_NO,
         P_SERVICE_CODE );
         RETURN ret_value;
   END DATE_1;

END RP_CNTR_BUNDLE_XFER_SERVICE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTR_BUNDLE_XFER_SERVICE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.41.07 AM


