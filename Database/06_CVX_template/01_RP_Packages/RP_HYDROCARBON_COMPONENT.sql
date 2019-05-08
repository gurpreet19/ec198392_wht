
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.23.23 AM


CREATE or REPLACE PACKAGE RP_HYDROCARBON_COMPONENT
IS

   FUNCTION SORT_ORDER(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN DATE;
   FUNCTION PART_OF_COMPONENT(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         COMPONENT_NO VARCHAR2 (16) ,
         NAME VARCHAR2 (30) ,
         SORT_ORDER NUMBER ,
         PART_OF_COMPONENT VARCHAR2 (16) ,
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
         REC_ID VARCHAR2 (32) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER  );
   FUNCTION ROW_BY_PK(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER;

END RP_HYDROCARBON_COMPONENT;

/



CREATE or REPLACE PACKAGE BODY RP_HYDROCARBON_COMPONENT
IS

   FUNCTION SORT_ORDER(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.SORT_ORDER      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.APPROVAL_BY      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.APPROVAL_STATE      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.NAME      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION VALUE_5(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_5      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_6(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_6      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.RECORD_STATUS      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_1      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.APPROVAL_DATE      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PART_OF_COMPONENT(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.PART_OF_COMPONENT      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END PART_OF_COMPONENT;
   FUNCTION ROW_BY_PK(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.ROW_BY_PK      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_2      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_3      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_4      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.REC_ID      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_COMPONENT_NO IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_HYDROCARBON_COMPONENT.VALUE_7      (
         P_COMPONENT_NO );
         RETURN ret_value;
   END VALUE_7;

END RP_HYDROCARBON_COMPONENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_HYDROCARBON_COMPONENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.23.27 AM


