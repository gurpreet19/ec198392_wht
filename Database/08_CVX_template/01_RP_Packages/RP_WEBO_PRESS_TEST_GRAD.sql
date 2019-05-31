
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.22.42 AM


CREATE or REPLACE PACKAGE RP_WEBO_PRESS_TEST_GRAD
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRADIENT(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION FROM_DEPTH(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         EVENT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         GRADIENT_SEQ NUMBER ,
         FROM_DEPTH NUMBER ,
         TO_DEPTH NUMBER ,
         GRADIENT NUMBER ,
         TO_DEPTH_PRESS NUMBER ,
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
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_DEPTH(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TO_DEPTH_PRESS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_WEBO_PRESS_TEST_GRAD;

/



CREATE or REPLACE PACKAGE BODY RP_WEBO_PRESS_TEST_GRAD
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TEXT_3      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TEXT_4      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.APPROVAL_BY      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.APPROVAL_STATE      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_5      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION GRADIENT(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.GRADIENT      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END GRADIENT;
   FUNCTION FROM_DEPTH(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.FROM_DEPTH      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END FROM_DEPTH;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_6      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.RECORD_STATUS      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_1      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.APPROVAL_DATE      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.ROW_BY_PK      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_2      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_3      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_4      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.REC_ID      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TEXT_1      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TEXT_2      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TO_DEPTH(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TO_DEPTH      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TO_DEPTH;
   FUNCTION TO_DEPTH_PRESS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.TO_DEPTH_PRESS      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END TO_DEPTH_PRESS;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_7      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_9      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_10      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRADIENT_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WEBO_PRESS_TEST_GRAD.VALUE_8      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRADIENT_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_WEBO_PRESS_TEST_GRAD;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WEBO_PRESS_TEST_GRAD TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.22.48 AM


