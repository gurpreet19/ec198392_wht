
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.07.34 AM


CREATE or REPLACE PACKAGE RP_MESSAGE_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION SUBJECT(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEMPLATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN CLOB;
   FUNCTION VALUE_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEMPLATE_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         SUBJECT VARCHAR2 (240) ,
         TEMPLATE  CLOB ,
         DESCRIPTION VARCHAR2 (240) ,
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
      P_TEMPLATE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_MESSAGE_TEMPLATE;

/



CREATE or REPLACE PACKAGE BODY RP_MESSAGE_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_3      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.APPROVAL_BY      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.APPROVAL_STATE      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.VALUE_5      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION OBJECT_ID(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.OBJECT_ID      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION TEXT_7(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_7      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_8      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DATE_3      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DATE_5      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION SUBJECT(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.SUBJECT      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END SUBJECT;
   FUNCTION TEXT_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_1      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_6      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_9      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DATE_2      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.RECORD_STATUS      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TEMPLATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEMPLATE      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEMPLATE;
   FUNCTION VALUE_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.VALUE_1      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.APPROVAL_DATE      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DESCRIPTION      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_TEMPLATE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.ROW_BY_PK      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_2      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_4      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_5      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.VALUE_2      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.VALUE_3      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.VALUE_4      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DATE_4      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.REC_ID      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_TEMPLATE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.DATE_1      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_TEMPLATE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_MESSAGE_TEMPLATE.TEXT_10      (
         P_TEMPLATE_NO );
         RETURN ret_value;
   END TEXT_10;

END RP_MESSAGE_TEMPLATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_MESSAGE_TEMPLATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.07.40 AM


