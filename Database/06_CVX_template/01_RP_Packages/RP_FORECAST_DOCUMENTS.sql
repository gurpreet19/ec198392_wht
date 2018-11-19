
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.12.53 AM


CREATE or REPLACE PACKAGE RP_FORECAST_DOCUMENTS
IS

   FUNCTION DOCUMENT_TYPE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMPARISON_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT_CONTENT(
      P_DOCUMENT_NO IN NUMBER)
      RETURN BLOB;
   FUNCTION FORECAST_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         DOCUMENT_TYPE VARCHAR2 (24) ,
         DOCUMENT_NO NUMBER ,
         SCENARIO_ID VARCHAR2 (32) ,
         CATEGORY VARCHAR2 (32) ,
         COMPARISON_ID VARCHAR2 (32) ,
         DOCUMENT_NAME VARCHAR2 (240) ,
         DOCUMENT_CONTENT  BLOB ,
         DESCRIPTION VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
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
         REC_ID VARCHAR2 (32) ,
         FORECAST_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_DOCUMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CATEGORY(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DOCUMENT_NAME(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE;

END RP_FORECAST_DOCUMENTS;

/



CREATE or REPLACE PACKAGE BODY RP_FORECAST_DOCUMENTS
IS

   FUNCTION DOCUMENT_TYPE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DOCUMENT_TYPE      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DOCUMENT_TYPE;
   FUNCTION TEXT_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.TEXT_3      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.APPROVAL_BY      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.APPROVAL_STATE      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMPARISON_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.COMPARISON_ID      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END COMPARISON_ID;
   FUNCTION VALUE_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.VALUE_5      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DATE_3      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DATE_5      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.TEXT_1      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DATE_2      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.RECORD_STATUS      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.VALUE_1      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.APPROVAL_DATE      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DESCRIPTION      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION DOCUMENT_CONTENT(
      P_DOCUMENT_NO IN NUMBER)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DOCUMENT_CONTENT      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DOCUMENT_CONTENT;
   FUNCTION FORECAST_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.FORECAST_ID      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_DOCUMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.ROW_BY_PK      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.SCENARIO_ID      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END SCENARIO_ID;
   FUNCTION TEXT_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.TEXT_2      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.TEXT_4      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.TEXT_5      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.VALUE_2      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.VALUE_3      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.VALUE_4      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CATEGORY(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.CATEGORY      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END CATEGORY;
   FUNCTION DATE_4(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DATE_4      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DOCUMENT_NAME(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DOCUMENT_NAME      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DOCUMENT_NAME;
   FUNCTION REC_ID(
      P_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.REC_ID      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FORECAST_DOCUMENTS.DATE_1      (
         P_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_1;

END RP_FORECAST_DOCUMENTS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FORECAST_DOCUMENTS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.12.59 AM


