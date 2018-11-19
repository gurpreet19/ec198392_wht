
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.02.47 AM


CREATE or REPLACE PACKAGE RP_REPT_SET_COMBINATION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OP_REPT_SET_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         SEQ_NO NUMBER ,
         OP_REPT_SET_NAME VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_REPT_SET_COMBINATION;

/



CREATE or REPLACE PACKAGE BODY RP_REPT_SET_COMBINATION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_3      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REF_OBJECT_ID_4      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.VALUE_5      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_7      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_8      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.DATE_3      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.DATE_5      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION OP_REPT_SET_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.OP_REPT_SET_NAME      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END OP_REPT_SET_NAME;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REF_OBJECT_ID_2      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REF_OBJECT_ID_3      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_1      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_6      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_9      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.DATE_2      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REF_OBJECT_ID_5      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.VALUE_1      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REF_OBJECT_ID_1      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_2      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_4      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_5      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.VALUE_2      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.VALUE_3      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.VALUE_4      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.DATE_4      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.REC_ID      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.DATE_1      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPT_SET_COMBINATION.TEXT_10      (
         P_OBJECT_ID,
         P_NAME,
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_REPT_SET_COMBINATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPT_SET_COMBINATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.02.54 AM


