
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.49.53 AM


CREATE or REPLACE PACKAGE RP_QBL_EXPORT_QUERY
IS

   FUNCTION TEXT_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION QUERY_NAME(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OWNER_ID(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         QBL_EXPORT_QUERY_NO NUMBER ,
         QUERY_NAME VARCHAR2 (240) ,
         GLOBAL_IND VARCHAR2 (1) ,
         OWNER_ID VARCHAR2 (30) ,
         REPORT_VIEW VARCHAR2 (32) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GLOBAL_IND(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REPORT_VIEW(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_QBL_EXPORT_QUERY;

/



CREATE or REPLACE PACKAGE BODY RP_QBL_EXPORT_QUERY
IS

   FUNCTION TEXT_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_3      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.APPROVAL_BY      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.APPROVAL_STATE      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION QUERY_NAME(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.QUERY_NAME      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END QUERY_NAME;
   FUNCTION REF_OBJECT_ID_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REF_OBJECT_ID_4      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.VALUE_5      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_7      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_8      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.DATE_3      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.DATE_5      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REF_OBJECT_ID_2      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REF_OBJECT_ID_3      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_1      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_6      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_9      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.DATE_2      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION OWNER_ID(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.OWNER_ID      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END OWNER_ID;
   FUNCTION RECORD_STATUS(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.RECORD_STATUS      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REF_OBJECT_ID_5      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.VALUE_1      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.APPROVAL_DATE      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REF_OBJECT_ID_1      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.ROW_BY_PK      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_2      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_4      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_5      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.VALUE_2      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.VALUE_3      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.VALUE_4      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.DATE_4      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION GLOBAL_IND(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.GLOBAL_IND      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END GLOBAL_IND;
   FUNCTION REC_ID(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REC_ID      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.DATE_1      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION REPORT_VIEW(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.REPORT_VIEW      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END REPORT_VIEW;
   FUNCTION TEXT_10(
      P_QBL_EXPORT_QUERY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_QBL_EXPORT_QUERY.TEXT_10      (
         P_QBL_EXPORT_QUERY_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_QBL_EXPORT_QUERY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_QBL_EXPORT_QUERY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.50.04 AM


