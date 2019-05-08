
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.23.27 AM


CREATE or REPLACE PACKAGE RP_HARBOUR_INTERRUPTION
IS

   FUNCTION TEXT_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FROM_DAYTIME(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REASON_CODE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         HARBOUR_INTERRUPTION_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         REASON_CODE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
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
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TO_DAYTIME(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE;

END RP_HARBOUR_INTERRUPTION;

/



CREATE or REPLACE PACKAGE BODY RP_HARBOUR_INTERRUPTION
IS

   FUNCTION TEXT_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TEXT_3      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TEXT_4      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.APPROVAL_BY      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.APPROVAL_STATE      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FROM_DAYTIME(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.FROM_DAYTIME      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END FROM_DAYTIME;
   FUNCTION REF_OBJECT_ID_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REF_OBJECT_ID_4      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.VALUE_5      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION OBJECT_ID(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.OBJECT_ID      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION TEXT_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TEXT_5      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION COMMENTS(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.COMMENTS      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.DATE_3      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.DATE_5      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REASON_CODE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REASON_CODE      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REASON_CODE;
   FUNCTION REF_OBJECT_ID_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REF_OBJECT_ID_2      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REF_OBJECT_ID_3      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION DATE_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.DATE_2      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.RECORD_STATUS      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REF_OBJECT_ID_5      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.VALUE_1      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.APPROVAL_DATE      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REF_OBJECT_ID_1      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.ROW_BY_PK      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TO_DAYTIME(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TO_DAYTIME      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TO_DAYTIME;
   FUNCTION VALUE_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.VALUE_2      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.VALUE_3      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.VALUE_4      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.DATE_4      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.REC_ID      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TEXT_1      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.TEXT_2      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION DATE_1(
      P_HARBOUR_INTERRUPTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HARBOUR_INTERRUPTION.DATE_1      (
         P_HARBOUR_INTERRUPTION_NO );
         RETURN ret_value;
   END DATE_1;

END RP_HARBOUR_INTERRUPTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_HARBOUR_INTERRUPTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.23.33 AM


