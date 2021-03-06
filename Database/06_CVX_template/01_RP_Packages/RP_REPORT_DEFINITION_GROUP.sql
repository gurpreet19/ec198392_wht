
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.46.21 AM


CREATE or REPLACE PACKAGE RP_REPORT_DEFINITION_GROUP
IS

   FUNCTION ARCHIVE_IND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPORT_AREA_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PARENT_REP_GROUP_CODE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REP_DATE_PARAMETER(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION HIDE_IND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION NAME(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         REP_GROUP_CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         PARENT_REP_GROUP_CODE VARCHAR2 (32) ,
         FUNCTIONAL_AREA_ID VARCHAR2 (32) ,
         REP_DATE_PARAMETER VARCHAR2 (32) ,
         ARCHIVE_IND VARCHAR2 (1) ,
         SORT_ORDER NUMBER ,
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
         HIDE_IND VARCHAR2 (1) ,
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
         REPORT_AREA_ID VARCHAR2 (32) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (2000) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER  );
   FUNCTION ROW_BY_PK(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_8(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_REPORT_DEFINITION_GROUP;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_DEFINITION_GROUP
IS

   FUNCTION ARCHIVE_IND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.ARCHIVE_IND      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END ARCHIVE_IND;
   FUNCTION REPORT_AREA_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REPORT_AREA_ID      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REPORT_AREA_ID;
   FUNCTION SORT_ORDER(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.SORT_ORDER      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_3      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_4      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_7(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_7      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION APPROVAL_BY(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.APPROVAL_BY      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.APPROVAL_STATE      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.FUNCTIONAL_AREA_ID      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END FUNCTIONAL_AREA_ID;
   FUNCTION PARENT_REP_GROUP_CODE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.PARENT_REP_GROUP_CODE      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END PARENT_REP_GROUP_CODE;
   FUNCTION REF_OBJECT_ID_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REF_OBJECT_ID_4      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.VALUE_5      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION REP_DATE_PARAMETER(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REP_DATE_PARAMETER      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REP_DATE_PARAMETER;
   FUNCTION TEXT_10(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_10      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_5      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_6      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION DATE_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.DATE_3      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.DATE_5      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION HIDE_IND(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.HIDE_IND      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END HIDE_IND;
   FUNCTION REF_OBJECT_ID_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REF_OBJECT_ID_2      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REF_OBJECT_ID_3      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_1      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION DATE_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.DATE_2      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.RECORD_STATUS      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REF_OBJECT_ID_5      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.VALUE_1      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.APPROVAL_DATE      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.NAME      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION REF_OBJECT_ID_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REF_OBJECT_ID_1      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.ROW_BY_PK      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_2      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_9(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_9      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_2(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.VALUE_2      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.VALUE_3      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.VALUE_4      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.DATE_4      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.REC_ID      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.DATE_1      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_8(
      P_REP_GROUP_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_DEFINITION_GROUP.TEXT_8      (
         P_REP_GROUP_CODE );
         RETURN ret_value;
   END TEXT_8;

END RP_REPORT_DEFINITION_GROUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_DEFINITION_GROUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.46.34 AM


