
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.09.41 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_RELEASE
IS

   FUNCTION TEXT_3(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RELEASE_TYPE(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_18(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RELEASE_NAME(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_16(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         RELEASE_NO NUMBER ,
         RELEASE_NAME VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         CONTRACT_ID VARCHAR2 (32) ,
         RELEASE_STATUS VARCHAR2 (32) ,
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
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         TEXT_16 VARCHAR2 (2000) ,
         TEXT_17 VARCHAR2 (2000) ,
         TEXT_18 VARCHAR2 (2000) ,
         TEXT_19 VARCHAR2 (2000) ,
         TEXT_20 VARCHAR2 (2000) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         RELEASE_TYPE VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_RELEASE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_12(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RELEASE_STATUS(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER;

END RP_CAPACITY_RELEASE;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_RELEASE
IS

   FUNCTION TEXT_3(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_3      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.APPROVAL_BY      (
         P_RELEASE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.APPROVAL_STATE      (
         P_RELEASE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REF_OBJECT_ID_4      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION TEXT_15(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_15      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_5(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_5      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION RELEASE_TYPE(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.RELEASE_TYPE      (
         P_RELEASE_NO );
         RETURN ret_value;
   END RELEASE_TYPE;
   FUNCTION TEXT_18(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_18      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_19      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_7(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_7      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_8      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.DATE_3      (
         P_RELEASE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.DATE_5      (
         P_RELEASE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REF_OBJECT_ID_2      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REF_OBJECT_ID_3      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION RELEASE_NAME(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.RELEASE_NAME      (
         P_RELEASE_NO );
         RETURN ret_value;
   END RELEASE_NAME;
   FUNCTION TEXT_1(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_1      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_11(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_11      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_17(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_17      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_20      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_6(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_6      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_9      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_6      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.CONTRACT_ID      (
         P_RELEASE_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.DATE_2      (
         P_RELEASE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.END_DATE      (
         P_RELEASE_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.RECORD_STATUS      (
         P_RELEASE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REF_OBJECT_ID_5      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION START_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.START_DATE      (
         P_RELEASE_NO );
         RETURN ret_value;
   END START_DATE;
   FUNCTION TEXT_16(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_16      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_1(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_1      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.APPROVAL_DATE      (
         P_RELEASE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REF_OBJECT_ID_1      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_RELEASE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.ROW_BY_PK      (
         P_RELEASE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_12      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_2(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_2      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_4      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_5      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_2      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_3      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_4      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.DATE_4      (
         P_RELEASE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.REC_ID      (
         P_RELEASE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_13(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_13      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION VALUE_7(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_7      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_9      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_RELEASE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.DATE_1      (
         P_RELEASE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION RELEASE_STATUS(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.RELEASE_STATUS      (
         P_RELEASE_NO );
         RETURN ret_value;
   END RELEASE_STATUS;
   FUNCTION TEXT_10(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_10      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_RELEASE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.TEXT_14      (
         P_RELEASE_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_10(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_10      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_RELEASE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_RELEASE.VALUE_8      (
         P_RELEASE_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_RELEASE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_RELEASE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.09.51 AM


