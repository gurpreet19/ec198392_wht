
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.10.49 AM


CREATE or REPLACE PACKAGE RP_WELL_EQPM_MASTER_EVENT
IS

   FUNCTION EVENT_STATUS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OP_AREA_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OP_FCTY_CLASS_2_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION EVENT_TYPE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OP_FCTY_CLASS_1_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OP_SUB_AREA_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION OP_SUB_PU_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         MASTER_EVENT_ID NUMBER ,
         DAYTIME  DATE ,
         OP_PU_ID VARCHAR2 (32) ,
         OP_SUB_PU_ID VARCHAR2 (32) ,
         OP_AREA_ID VARCHAR2 (32) ,
         OP_SUB_AREA_ID VARCHAR2 (32) ,
         OP_FCTY_CLASS_2_ID VARCHAR2 (32) ,
         OP_FCTY_CLASS_1_ID VARCHAR2 (32) ,
         EVENT_ID VARCHAR2 (32) ,
         EVENT_TYPE VARCHAR2 (32) ,
         EVENT_STATUS VARCHAR2 (32) ,
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
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION EVENT_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OP_PU_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER;

END RP_WELL_EQPM_MASTER_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_EQPM_MASTER_EVENT
IS

   FUNCTION EVENT_STATUS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.EVENT_STATUS      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END EVENT_STATUS;
   FUNCTION OP_AREA_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_AREA_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_AREA_ID;
   FUNCTION OP_FCTY_CLASS_2_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_FCTY_CLASS_2_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_FCTY_CLASS_2_ID;
   FUNCTION TEXT_3(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.TEXT_3      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.TEXT_4      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.APPROVAL_BY      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.APPROVAL_STATE      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_5      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION EVENT_TYPE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.EVENT_TYPE      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END EVENT_TYPE;
   FUNCTION NEXT_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.NEXT_DAYTIME      (
         P_MASTER_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.PREV_EQUAL_DAYTIME      (
         P_MASTER_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.COMMENTS      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.NEXT_EQUAL_DAYTIME      (
         P_MASTER_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OP_FCTY_CLASS_1_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_FCTY_CLASS_1_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_FCTY_CLASS_1_ID;
   FUNCTION OP_SUB_AREA_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_SUB_AREA_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_SUB_AREA_ID;
   FUNCTION VALUE_6(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_6      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PREV_DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.PREV_DAYTIME      (
         P_MASTER_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.RECORD_STATUS      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_1      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.APPROVAL_DATE      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION OP_SUB_PU_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_SUB_PU_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_SUB_PU_ID;
   FUNCTION ROW_BY_PK(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.ROW_BY_PK      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_2      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_3      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_4      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION EVENT_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.EVENT_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END EVENT_ID;
   FUNCTION OP_PU_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.OP_PU_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END OP_PU_ID;
   FUNCTION REC_ID(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.REC_ID      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.TEXT_1      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.TEXT_2      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_7      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_9      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.DAYTIME      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION VALUE_10(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_10      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_MASTER_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EQPM_MASTER_EVENT.VALUE_8      (
         P_MASTER_EVENT_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_WELL_EQPM_MASTER_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_EQPM_MASTER_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.10.57 AM


