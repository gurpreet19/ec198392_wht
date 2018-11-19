
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.55.40 AM


CREATE or REPLACE PACKAGE RP_MESSAGE_OUT
IS

   FUNCTION MESSAGE(
      P_MESSAGE_NO IN NUMBER)
      RETURN CLOB;
   FUNCTION SUBJECT_DRAFT(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMPANY_CONTACT_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FORMAT_CODE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REVISION(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION MESSAGE_DISTRIBUTION_NO(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUBJECT(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         MESSAGE_NO NUMBER ,
         COMPANY_CONTACT_ID VARCHAR2 (32) ,
         FORMAT_CODE VARCHAR2 (32) ,
         SUBJECT_DRAFT VARCHAR2 (240) ,
         SUBJECT VARCHAR2 (240) ,
         MESSAGE_DRAFT  CLOB ,
         MESSAGE  CLOB ,
         VALID_FROM_DATE  DATE ,
         VALID_TO_DATE  DATE ,
         ACKNOWLEDGE_IND VARCHAR2 (1) ,
         TRANSMIT_STATUS VARCHAR2 (32) ,
         EDI_ADDRESS_CODE VARCHAR2 (32) ,
         REVISION NUMBER ,
         STATUS VARCHAR2 (32) ,
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
         MESSAGE_DISTRIBUTION_NO NUMBER  );
   FUNCTION ROW_BY_PK(
      P_MESSAGE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EDI_ADDRESS_CODE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MESSAGE_DRAFT(
      P_MESSAGE_NO IN NUMBER)
      RETURN CLOB;
   FUNCTION REC_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_TO_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION ACKNOWLEDGE_IND(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSMIT_STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_MESSAGE_OUT;

/



CREATE or REPLACE PACKAGE BODY RP_MESSAGE_OUT
IS

   FUNCTION MESSAGE(
      P_MESSAGE_NO IN NUMBER)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.MESSAGE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END MESSAGE;
   FUNCTION SUBJECT_DRAFT(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.SUBJECT_DRAFT      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END SUBJECT_DRAFT;
   FUNCTION TEXT_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_3      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.APPROVAL_BY      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.APPROVAL_STATE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMPANY_CONTACT_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.COMPANY_CONTACT_ID      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END COMPANY_CONTACT_ID;
   FUNCTION FORMAT_CODE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.FORMAT_CODE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END FORMAT_CODE;
   FUNCTION REF_OBJECT_ID_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REF_OBJECT_ID_4      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REVISION(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REVISION      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REVISION;
   FUNCTION STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.STATUS      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALUE_5      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION OBJECT_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.OBJECT_ID      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION TEXT_7(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_7      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_8      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.COMMENTS      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.DATE_3      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.DATE_5      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION MESSAGE_DISTRIBUTION_NO(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.MESSAGE_DISTRIBUTION_NO      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END MESSAGE_DISTRIBUTION_NO;
   FUNCTION REF_OBJECT_ID_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REF_OBJECT_ID_2      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REF_OBJECT_ID_3      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION SUBJECT(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.SUBJECT      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END SUBJECT;
   FUNCTION TEXT_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_1      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_6      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_9      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.DATE_2      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.RECORD_STATUS      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REF_OBJECT_ID_5      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALUE_1      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.APPROVAL_DATE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REF_OBJECT_ID_1      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_MESSAGE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.ROW_BY_PK      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_2      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_4      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_5      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALUE_2      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALUE_3      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALUE_4      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.DATE_4      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION EDI_ADDRESS_CODE(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.EDI_ADDRESS_CODE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END EDI_ADDRESS_CODE;
   FUNCTION MESSAGE_DRAFT(
      P_MESSAGE_NO IN NUMBER)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.MESSAGE_DRAFT      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END MESSAGE_DRAFT;
   FUNCTION REC_ID(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.REC_ID      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALID_FROM_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALID_FROM_DATE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALID_TO_DATE(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.VALID_TO_DATE      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END VALID_TO_DATE;
   FUNCTION ACKNOWLEDGE_IND(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.ACKNOWLEDGE_IND      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END ACKNOWLEDGE_IND;
   FUNCTION DATE_1(
      P_MESSAGE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.DATE_1      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TEXT_10      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TRANSMIT_STATUS(
      P_MESSAGE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_OUT.TRANSMIT_STATUS      (
         P_MESSAGE_NO );
         RETURN ret_value;
   END TRANSMIT_STATUS;

END RP_MESSAGE_OUT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_MESSAGE_OUT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.55.50 AM


