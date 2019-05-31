
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.05.32 AM


CREATE or REPLACE PACKAGE RP_NOMINATION_CYCLE
IS

   FUNCTION SORT_ORDER(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NOM_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION SCHED_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GAS_DAY_OFFSET(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION NAME(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         NOM_CYCLE_CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         SORT_ORDER NUMBER ,
         NOM_DEADLINE  DATE ,
         CONFIRM_DEADLINE  DATE ,
         SCHED_DEADLINE  DATE ,
         FLOW_START  DATE ,
         GAS_DAY_OFFSET VARCHAR2 (32) ,
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
         REC_ID VARCHAR2 (32) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5 VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER  );
   FUNCTION ROW_BY_PK(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION FLOW_START(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CONFIRM_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_NOMINATION_CYCLE;

/



CREATE or REPLACE PACKAGE BODY RP_NOMINATION_CYCLE
IS

   FUNCTION SORT_ORDER(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.SORT_ORDER      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.TEXT_3      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.APPROVAL_BY      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.APPROVAL_STATE      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NOM_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.NOM_DEADLINE      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END NOM_DEADLINE;
   FUNCTION SCHED_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.SCHED_DEADLINE      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END SCHED_DEADLINE;
   FUNCTION VALUE_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.VALUE_5      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION GAS_DAY_OFFSET(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.GAS_DAY_OFFSET      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END GAS_DAY_OFFSET;
   FUNCTION DATE_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.DATE_3      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION TEXT_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.TEXT_1      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.DATE_2      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.RECORD_STATUS      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.VALUE_1      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.APPROVAL_DATE      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.NAME      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.ROW_BY_PK      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.TEXT_2      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.TEXT_4      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.TEXT_5      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.VALUE_2      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.VALUE_3      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.VALUE_4      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.DATE_4      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION FLOW_START(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.FLOW_START      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END FLOW_START;
   FUNCTION REC_ID(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.REC_ID      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION CONFIRM_DEADLINE(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.CONFIRM_DEADLINE      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END CONFIRM_DEADLINE;
   FUNCTION DATE_1(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.DATE_1      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_5(
      P_NOM_CYCLE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMINATION_CYCLE.DATE_5      (
         P_NOM_CYCLE_CODE );
         RETURN ret_value;
   END DATE_5;

END RP_NOMINATION_CYCLE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_NOMINATION_CYCLE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.05.38 AM


