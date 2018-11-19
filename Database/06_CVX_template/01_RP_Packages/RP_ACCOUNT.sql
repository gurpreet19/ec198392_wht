
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.05.07 AM


CREATE or REPLACE PACKAGE RP_ACCOUNT
IS

   FUNCTION SORT_ORDER(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ACCOUNT_CATEGORY(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMERCIAL_ENTITY_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_1(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ACCOUNT_NO VARCHAR2 (16) ,
         ACCOUNT_CATEGORY VARCHAR2 (16) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         COMPANY_ID VARCHAR2 (32) ,
         STORAGE_ID VARCHAR2 (32) ,
         COMMERCIAL_ENTITY_ID VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
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
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION STORAGE_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER;

END RP_ACCOUNT;

/



CREATE or REPLACE PACKAGE BODY RP_ACCOUNT
IS

   FUNCTION SORT_ORDER(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.SORT_ORDER      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT.TEXT_3      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT.TEXT_4      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION ACCOUNT_CATEGORY(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_ACCOUNT.ACCOUNT_CATEGORY      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END ACCOUNT_CATEGORY;
   FUNCTION APPROVAL_BY(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ACCOUNT.APPROVAL_BY      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT.APPROVAL_STATE      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_5      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMENTS(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT.COMMENTS      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION COMMERCIAL_ENTITY_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT.COMMERCIAL_ENTITY_ID      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END COMMERCIAL_ENTITY_ID;
   FUNCTION VALUE_6(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_6      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT.COMPANY_ID      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION END_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT.END_DATE      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT.RECORD_STATUS      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT.START_DATE      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END START_DATE;
   FUNCTION VALUE_1(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_1      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT.APPROVAL_DATE      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ACCOUNT.ROW_BY_PK      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_2      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_3      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_4      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT.REC_ID      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_ACCOUNT.TEXT_1      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT.TEXT_2      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_7      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_9      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION STORAGE_ID(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT.STORAGE_ID      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END STORAGE_ID;
   FUNCTION VALUE_10(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_10      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ACCOUNT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT.VALUE_8      (
         P_ACCOUNT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_ACCOUNT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ACCOUNT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.05.13 AM


