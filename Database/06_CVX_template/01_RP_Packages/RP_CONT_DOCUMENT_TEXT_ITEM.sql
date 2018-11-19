
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.23.14 AM


CREATE or REPLACE PACKAGE RP_CONT_DOCUMENT_TEXT_ITEM
IS

   FUNCTION SORT_ORDER(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT_KEY(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COLUMN_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OBJECT_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_ITEM_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COLUMN_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COLUMN_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DOCUMENT_KEY VARCHAR2 (32) ,
         TEXT_ITEM_NO NUMBER ,
         TEXT_ITEM_ID VARCHAR2 (32) ,
         TEXT_ITEM_TYPE VARCHAR2 (32) ,
         TEXT_ITEM_COLUMN_TYPE VARCHAR2 (32) ,
         COLUMN_1 VARCHAR2 (2000) ,
         COLUMN_2 VARCHAR2 (2000) ,
         COLUMN_3 VARCHAR2 (2000) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (240) ,
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
   FUNCTION ROW_BY_PK(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_ITEM_COLUMN_TYPE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_ITEM_TYPE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER;

END RP_CONT_DOCUMENT_TEXT_ITEM;

/



CREATE or REPLACE PACKAGE BODY RP_CONT_DOCUMENT_TEXT_ITEM
IS

   FUNCTION SORT_ORDER(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.SORT_ORDER      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_3      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_4      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.APPROVAL_BY      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.APPROVAL_STATE      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DOCUMENT_KEY(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DOCUMENT_KEY      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DOCUMENT_KEY;
   FUNCTION VALUE_5(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_5      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COLUMN_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.COLUMN_1      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END COLUMN_1;
   FUNCTION OBJECT_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.OBJECT_ID      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION COMMENTS(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.COMMENTS      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DATE_3      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DATE_5      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_ITEM_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_ITEM_ID      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_ITEM_ID;
   FUNCTION VALUE_6(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_6      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COLUMN_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.COLUMN_2      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END COLUMN_2;
   FUNCTION COLUMN_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.COLUMN_3      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END COLUMN_3;
   FUNCTION DATE_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DATE_2      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.RECORD_STATUS      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_1      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.APPROVAL_DATE      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DESCRIPTION      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.ROW_BY_PK      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_2      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_3      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_4      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DATE_4      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.REC_ID      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_1      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_2      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_ITEM_COLUMN_TYPE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_ITEM_COLUMN_TYPE      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_ITEM_COLUMN_TYPE;
   FUNCTION TEXT_ITEM_TYPE(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.TEXT_ITEM_TYPE      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END TEXT_ITEM_TYPE;
   FUNCTION VALUE_7(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_7      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_9      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.DATE_1      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_10      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TEXT_ITEM_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOCUMENT_TEXT_ITEM.VALUE_8      (
         P_TEXT_ITEM_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CONT_DOCUMENT_TEXT_ITEM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONT_DOCUMENT_TEXT_ITEM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.23.22 AM


