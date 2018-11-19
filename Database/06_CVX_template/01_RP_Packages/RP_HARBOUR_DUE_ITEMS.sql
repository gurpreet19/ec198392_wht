
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.09.57 AM


CREATE or REPLACE PACKAGE RP_HARBOUR_DUE_ITEMS
IS

   FUNCTION SORT_ORDER(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DUE_ITEM_NAME(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         START_DATE  DATE ,
         END_DATE  DATE ,
         DUE_CODE VARCHAR2 (32) ,
         DUE_ITEM_CODE VARCHAR2 (32) ,
         DUE_ITEM_NAME VARCHAR2 (100) ,
         SORT_ORDER NUMBER ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (64) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
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
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_8(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_8(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_HARBOUR_DUE_ITEMS;

/



CREATE or REPLACE PACKAGE BODY RP_HARBOUR_DUE_ITEMS
IS

   FUNCTION SORT_ORDER(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.SORT_ORDER      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_7(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_7      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION APPROVAL_BY(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.APPROVAL_BY      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.APPROVAL_STATE      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_5      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_5      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_6      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION DATE_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DATE_3      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DATE_5      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION VALUE_6(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_6      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DATE_2      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DUE_ITEM_NAME(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DUE_ITEM_NAME      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DUE_ITEM_NAME;
   FUNCTION END_DATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.END_DATE      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.RECORD_STATUS      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TEXT_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_3      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_1      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.APPROVAL_DATE      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.ROW_BY_PK      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_4      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_2      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_3      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_4      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DATE_4      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.REC_ID      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_1      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_2      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_7      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION DATE_1(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.DATE_1      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_8(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.TEXT_8      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_8(
      P_START_DATE IN DATE,
      P_DUE_CODE IN VARCHAR2,
      P_DUE_ITEM_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_DUE_ITEMS.VALUE_8      (
         P_START_DATE,
         P_DUE_CODE,
         P_DUE_ITEM_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_HARBOUR_DUE_ITEMS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_HARBOUR_DUE_ITEMS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.10.03 AM


