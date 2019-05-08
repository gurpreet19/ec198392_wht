
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.17.02 AM


CREATE or REPLACE PACKAGE RP_STOR_MTH_STATUS
IS

   FUNCTION CLOSING_MASS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CLOSING_VOL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NET_VOL_CHANGE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION CLOSING_VOL_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NET_VOL_CHANGE_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TOT_CLOSING_VOL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION TOT_CLOSING_VOL_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TOT_CLOSING_MASS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DENSITY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         STORAGE_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CLOSING_VOL NUMBER ,
         CLOSING_MASS NUMBER ,
         TOT_CLOSING_VOL NUMBER ,
         TOT_CLOSING_MASS NUMBER ,
         NET_MASS_CHANGE NUMBER ,
         NET_VOL_CHANGE NUMBER ,
         DENSITY NUMBER ,
         NET_VOL_CHANGE_60 NUMBER ,
         CLOSING_VOL_60 NUMBER ,
         DENSITY_60 NUMBER ,
         TOT_CLOSING_VOL_60 NUMBER ,
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
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         STORAGE_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CLOSING_VOL NUMBER ,
         CLOSING_MASS NUMBER ,
         TOT_CLOSING_VOL NUMBER ,
         TOT_CLOSING_MASS NUMBER ,
         NET_MASS_CHANGE NUMBER ,
         NET_VOL_CHANGE NUMBER ,
         DENSITY NUMBER ,
         NET_VOL_CHANGE_60 NUMBER ,
         CLOSING_VOL_60 NUMBER ,
         DENSITY_60 NUMBER ,
         TOT_CLOSING_VOL_60 NUMBER ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION DENSITY_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NET_MASS_CHANGE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_STOR_MTH_STATUS;

/



CREATE or REPLACE PACKAGE BODY RP_STOR_MTH_STATUS
IS

   FUNCTION CLOSING_MASS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.CLOSING_MASS      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLOSING_MASS;
   FUNCTION APPROVAL_BY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.APPROVAL_BY      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.APPROVAL_STATE      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLOSING_VOL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.CLOSING_VOL      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLOSING_VOL;
   FUNCTION NET_VOL_CHANGE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.NET_VOL_CHANGE      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END NET_VOL_CHANGE;
   FUNCTION CLOSING_VOL_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.CLOSING_VOL_60      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLOSING_VOL_60;
   FUNCTION NET_VOL_CHANGE_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.NET_VOL_CHANGE_60      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END NET_VOL_CHANGE_60;
   FUNCTION NEXT_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.NEXT_DAYTIME      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.PREV_EQUAL_DAYTIME      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TOT_CLOSING_VOL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.TOT_CLOSING_VOL      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TOT_CLOSING_VOL;
   FUNCTION TOT_CLOSING_VOL_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.TOT_CLOSING_VOL_60      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TOT_CLOSING_VOL_60;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.NEXT_EQUAL_DAYTIME      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.PREV_DAYTIME      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.RECORD_STATUS      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TOT_CLOSING_MASS(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.TOT_CLOSING_MASS      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TOT_CLOSING_MASS;
   FUNCTION APPROVAL_DATE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.APPROVAL_DATE      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DENSITY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.DENSITY      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DENSITY;
   FUNCTION ROW_BY_PK(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.ROW_BY_PK      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.ROW_BY_REL_OPERATOR      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION DENSITY_60(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.DENSITY_60      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DENSITY_60;
   FUNCTION REC_ID(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.REC_ID      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION NET_MASS_CHANGE(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STOR_MTH_STATUS.NET_MASS_CHANGE      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END NET_MASS_CHANGE;

END RP_STOR_MTH_STATUS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STOR_MTH_STATUS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.17.09 AM


