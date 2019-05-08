
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.11.00 AM


CREATE or REPLACE PACKAGE RP_TAB_CONFIG_COMPONENT
IS

   FUNCTION SORT_ORDER(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TAB_ENABLE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION BF_CODE_REF(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         BF_CODE VARCHAR2 (32) ,
         BF_NO_REF NUMBER ,
         BF_CODE_REF VARCHAR2 (32) ,
         TAB_ENABLE VARCHAR2 (1) ,
         SORT_ORDER NUMBER ,
         TAB_LABEL VARCHAR2 (64) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
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
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TAB_LABEL(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_TAB_CONFIG_COMPONENT;

/



CREATE or REPLACE PACKAGE BODY RP_TAB_CONFIG_COMPONENT
IS

   FUNCTION SORT_ORDER(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.SORT_ORDER      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TAB_ENABLE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TAB_ENABLE      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TAB_ENABLE;
   FUNCTION TEXT_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TEXT_3      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TEXT_4      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.APPROVAL_BY      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.APPROVAL_STATE      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TEXT_5(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TEXT_5      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION BF_CODE_REF(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.BF_CODE_REF      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END BF_CODE_REF;
   FUNCTION DATE_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.DATE_3      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.DATE_2      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.RECORD_STATUS      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.VALUE_1      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.APPROVAL_DATE      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.ROW_BY_PK      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.VALUE_2      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.VALUE_3      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.VALUE_4      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.DATE_4      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.REC_ID      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TEXT_1      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TEXT_2      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION DATE_1(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.DATE_1      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TAB_LABEL(
      P_BF_NO_REF IN NUMBER,
      P_BF_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_TAB_CONFIG_COMPONENT.TAB_LABEL      (
         P_BF_NO_REF,
         P_BF_CODE );
         RETURN ret_value;
   END TAB_LABEL;

END RP_TAB_CONFIG_COMPONENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TAB_CONFIG_COMPONENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 06.11.22 AM


