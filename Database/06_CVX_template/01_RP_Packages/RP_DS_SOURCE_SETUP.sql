
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.22.39 AM


CREATE or REPLACE PACKAGE RP_DS_SOURCE_SETUP
IS

   FUNCTION DATE_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION POST_ROUTINE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         DS_SOURCE_SETUP_NO NUMBER ,
         DATASET VARCHAR2 (32) ,
         PRE_ROUTINE VARCHAR2 (240) ,
         POST_ROUTINE VARCHAR2 (240) ,
         COMMENTS VARCHAR2 (2000) ,
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
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
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
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRE_ROUTINE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER;

END RP_DS_SOURCE_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_DS_SOURCE_SETUP
IS

   FUNCTION DATE_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_10      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION REF_OBJECT_ID_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_7      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_7;
   FUNCTION TEXT_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_3      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.APPROVAL_BY      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.APPROVAL_STATE      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATASET      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATASET;
   FUNCTION REF_OBJECT_ID_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_4      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REF_OBJECT_ID_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_8      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_8;
   FUNCTION VALUE_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_5      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_7      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_9      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION TEXT_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_7      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_8      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.COMMENTS      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_3      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_5      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION POST_ROUTINE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.POST_ROUTINE      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END POST_ROUTINE;
   FUNCTION REF_OBJECT_ID_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_2      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_3      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_9      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_9;
   FUNCTION TEXT_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_1      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_6      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_9      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_6      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_2      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.RECORD_STATUS      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_5      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_1      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.APPROVAL_DATE      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_6      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION REF_OBJECT_ID_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_1      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.ROW_BY_PK      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_2      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_4      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_5      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_2      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_3      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_4      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_4      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REC_ID      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_OBJECT_ID_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_10      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_10;
   FUNCTION REF_OBJECT_ID_6(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.REF_OBJECT_ID_6      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_6;
   FUNCTION VALUE_7(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_7      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_9      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_1      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.DATE_8      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION PRE_ROUTINE(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.PRE_ROUTINE      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END PRE_ROUTINE;
   FUNCTION TEXT_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.TEXT_10      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_10      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_DS_SOURCE_SETUP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DS_SOURCE_SETUP.VALUE_8      (
         P_DS_SOURCE_SETUP_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_DS_SOURCE_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DS_SOURCE_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.22.49 AM


