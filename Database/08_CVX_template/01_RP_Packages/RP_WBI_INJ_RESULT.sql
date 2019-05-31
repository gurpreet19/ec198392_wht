
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.25.26 AM


CREATE or REPLACE PACKAGE RP_WBI_INJ_RESULT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ANNULUS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TUBING_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANNULUS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         RESULT_NO NUMBER ,
         SLEEVE_POS NUMBER ,
         ANNULUS_PRESS NUMBER ,
         TUBING_PRESS NUMBER ,
         ANNULUS_TEMP NUMBER ,
         TUBING_TEMP NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TUBING_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SLEEVE_POS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;

END RP_WBI_INJ_RESULT;

/



CREATE or REPLACE PACKAGE BODY RP_WBI_INJ_RESULT
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TEXT_3      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TEXT_4      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION ANNULUS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.ANNULUS_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ANNULUS_TEMP;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TUBING_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TUBING_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TUBING_TEMP;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_5      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.COMMENTS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_6      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ANNULUS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.ANNULUS_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ANNULUS_PRESS;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TUBING_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TUBING_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TUBING_PRESS;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_3      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_4      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.REC_ID      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SLEEVE_POS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.SLEEVE_POS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END SLEEVE_POS;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TEXT_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.TEXT_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_7      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_9      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_10      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WBI_INJ_RESULT.VALUE_8      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_WBI_INJ_RESULT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WBI_INJ_RESULT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.25.32 AM


