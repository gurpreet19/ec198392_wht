
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.20.34 AM


CREATE or REPLACE PACKAGE RP_ALLOC_JOB_PASS
IS

   FUNCTION SORT_ORDER(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION METHOD(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_SEQ_ORDERING(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION METHOD_CODE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         JOB_NO NUMBER ,
         JOB_PASS_NO NUMBER ,
         EXEC_FREQ VARCHAR2 (32) ,
         CALC_SEQ_ORDERING VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         METHOD VARCHAR2 (32) ,
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
         METHOD_CODE VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EXEC_FREQ(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_ALLOC_JOB_PASS;

/



CREATE or REPLACE PACKAGE BODY RP_ALLOC_JOB_PASS
IS

   FUNCTION SORT_ORDER(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.SORT_ORDER      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.TEXT_3      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.APPROVAL_BY      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.APPROVAL_STATE      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.VALUE_5      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION METHOD(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.METHOD      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END METHOD;
   FUNCTION DATE_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.DATE_3      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.DATE_5      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.TEXT_1      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.DATE_2      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.RECORD_STATUS      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.VALUE_1      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.APPROVAL_DATE      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CALC_SEQ_ORDERING(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.CALC_SEQ_ORDERING      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END CALC_SEQ_ORDERING;
   FUNCTION METHOD_CODE(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.METHOD_CODE      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END METHOD_CODE;
   FUNCTION ROW_BY_PK(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.ROW_BY_PK      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.TEXT_2      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.TEXT_4      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.TEXT_5      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.VALUE_2      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.VALUE_3      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.VALUE_4      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.DATE_4      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.REC_ID      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.DATE_1      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION EXEC_FREQ(
      P_JOB_NO IN NUMBER,
      P_JOB_PASS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_PASS.EXEC_FREQ      (
         P_JOB_NO,
         P_JOB_PASS_NO );
         RETURN ret_value;
   END EXEC_FREQ;

END RP_ALLOC_JOB_PASS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ALLOC_JOB_PASS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.20.40 AM


