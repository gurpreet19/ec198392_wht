
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.55.14 AM


CREATE or REPLACE PACKAGE RP_STIM_PENDING
IS

   FUNCTION DESCRIPTION(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UPDATE_JOB_STATUS(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION BF_REFERENCE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         STIM_PENDING_NO NUMBER ,
         PERIOD VARCHAR2 (32) ,
         BF_REFERENCE VARCHAR2 (240) ,
         DESCRIPTION VARCHAR2 (2000) ,
         UPDATE_JOB_STATUS VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
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
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE;

END RP_STIM_PENDING;

/



CREATE or REPLACE PACKAGE BODY RP_STIM_PENDING
IS

   FUNCTION DESCRIPTION(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STIM_PENDING.DESCRIPTION      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION TEXT_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.TEXT_3      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION UPDATE_JOB_STATUS(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.UPDATE_JOB_STATUS      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END UPDATE_JOB_STATUS;
   FUNCTION APPROVAL_BY(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STIM_PENDING.APPROVAL_BY      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_PENDING.APPROVAL_STATE      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REF_OBJECT_ID_4      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING.VALUE_5      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION BF_REFERENCE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.BF_REFERENCE      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END BF_REFERENCE;
   FUNCTION DATE_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.DATE_3      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.DATE_5      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REF_OBJECT_ID_2      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REF_OBJECT_ID_3      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.TEXT_1      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.DATE_2      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STIM_PENDING.RECORD_STATUS      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REF_OBJECT_ID_5      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING.VALUE_1      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.APPROVAL_DATE      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REF_OBJECT_ID_1      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STIM_PENDING.ROW_BY_PK      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.TEXT_2      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.TEXT_4      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STIM_PENDING.TEXT_5      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING.VALUE_2      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING.VALUE_3      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STIM_PENDING.VALUE_4      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.DATE_4      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STIM_PENDING.REC_ID      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_STIM_PENDING_NO IN NUMBER,
      P_PERIOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STIM_PENDING.DATE_1      (
         P_STIM_PENDING_NO,
         P_PERIOD );
         RETURN ret_value;
   END DATE_1;

END RP_STIM_PENDING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STIM_PENDING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.55.20 AM


