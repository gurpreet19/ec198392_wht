
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.52.05 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_REL_REPUT
IS

   FUNCTION TEXT_3(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REPUT_DATE(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REPUT_NOTE(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECALL_NO(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPUT_CAPACITY(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPUT_NO NUMBER ,
         RECALL_NO NUMBER ,
         REPUT_NOTE VARCHAR2 (2000) ,
         REPUT_DATE  DATE ,
         REPUT_CAPACITY NUMBER ,
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
      P_REPUT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_REPUT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER;

END RP_CAPACITY_REL_REPUT;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_REL_REPUT
IS

   FUNCTION TEXT_3(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_3      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.APPROVAL_BY      (
         P_REPUT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.APPROVAL_STATE      (
         P_REPUT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_5      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_7      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_8      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.DATE_3      (
         P_REPUT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.DATE_5      (
         P_REPUT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REPUT_DATE(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.REPUT_DATE      (
         P_REPUT_NO );
         RETURN ret_value;
   END REPUT_DATE;
   FUNCTION REPUT_NOTE(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.REPUT_NOTE      (
         P_REPUT_NO );
         RETURN ret_value;
   END REPUT_NOTE;
   FUNCTION TEXT_1(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_1      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_6      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_9      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_6      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.DATE_2      (
         P_REPUT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECALL_NO(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.RECALL_NO      (
         P_REPUT_NO );
         RETURN ret_value;
   END RECALL_NO;
   FUNCTION RECORD_STATUS(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.RECORD_STATUS      (
         P_REPUT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REPUT_CAPACITY(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.REPUT_CAPACITY      (
         P_REPUT_NO );
         RETURN ret_value;
   END REPUT_CAPACITY;
   FUNCTION VALUE_1(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_1      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.APPROVAL_DATE      (
         P_REPUT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_REPUT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.ROW_BY_PK      (
         P_REPUT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_2      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_4      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_5      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_2      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_3      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_4      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.DATE_4      (
         P_REPUT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.REC_ID      (
         P_REPUT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_7      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_9      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_REPUT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.DATE_1      (
         P_REPUT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_REPUT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.TEXT_10      (
         P_REPUT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_10      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_REPUT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_REL_REPUT.VALUE_8      (
         P_REPUT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_REL_REPUT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_REL_REPUT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.52.12 AM


