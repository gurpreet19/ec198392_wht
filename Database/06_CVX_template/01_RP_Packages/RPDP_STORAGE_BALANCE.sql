
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.47 AM


CREATE or REPLACE PACKAGE RPDP_STORAGE_BALANCE
IS

   FUNCTION GETACCESTLIFTEDQTYSUBDAY(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_STARTDATE IN DATE,
      P_ENDDATE IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N',
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETACCLIFTEDQTYMTH(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDIP(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CONDITION IN VARCHAR2,
      P_GROUP IN VARCHAR2,
      P_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSTORAGELOADVERIFSTATUSVALUE(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CALCSTORAGELEVELSUBDAY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_IGNORE_CACHE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETACCESTLIFTEDQTYDAY(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGELOADSTATUS(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSTORAGELOADVERIFTEXTVALUE(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETESTLIFTEDQTYMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION GETACCESTLIFTEDQTYMTH(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETESTLIFTEDQTYDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION GETLIFTEDQTYMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION CALCSTORAGELEVEL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PLAN IN VARCHAR2 DEFAULT 'PO',
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_IGNORE_CACHE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;

END RPDP_STORAGE_BALANCE;

/



CREATE or REPLACE PACKAGE BODY RPDP_STORAGE_BALANCE
IS

   FUNCTION GETACCESTLIFTEDQTYSUBDAY(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_STARTDATE IN DATE,
      P_ENDDATE IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N',
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETACCESTLIFTEDQTYSUBDAY      (
         P_LIFTING_ACCOUNT_ID,
         P_STARTDATE,
         P_ENDDATE,
         P_XTRA_QTY,
         P_INCL_DELTA,
         P_SUMMER_TIME );
         RETURN ret_value;
   END GETACCESTLIFTEDQTYSUBDAY;
   FUNCTION GETACCLIFTEDQTYMTH(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETACCLIFTEDQTYMTH      (
         P_LIFTING_ACCOUNT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETACCLIFTEDQTYMTH;
   FUNCTION GETSTORAGEDIP(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CONDITION IN VARCHAR2,
      P_GROUP IN VARCHAR2,
      P_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETSTORAGEDIP      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_CONDITION,
         P_GROUP,
         P_TYPE );
         RETURN ret_value;
   END GETSTORAGEDIP;
   FUNCTION GETSTORAGELOADVERIFSTATUSVALUE(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETSTORAGELOADVERIFSTATUSVALUE      (
         P_QTY,
         P_NOM_DATE,
         P_LOADTYPE,
         P_CARGO_STATUS );
         RETURN ret_value;
   END GETSTORAGELOADVERIFSTATUSVALUE;
   FUNCTION CALCSTORAGELEVELSUBDAY(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_IGNORE_CACHE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.CALCSTORAGELEVELSUBDAY      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_SUMMER_TIME,
         P_XTRA_QTY,
         P_IGNORE_CACHE );
         RETURN ret_value;
   END CALCSTORAGELEVELSUBDAY;
   FUNCTION GETACCESTLIFTEDQTYDAY(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETACCESTLIFTEDQTYDAY      (
         P_LIFTING_ACCOUNT_ID,
         P_DAYTIME,
         P_XTRA_QTY,
         P_INCL_DELTA );
         RETURN ret_value;
   END GETACCESTLIFTEDQTYDAY;
   FUNCTION GETSTORAGELOADSTATUS(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETSTORAGELOADSTATUS      (
         P_QTY,
         P_NOM_DATE,
         P_LOADTYPE,
         P_CARGO_STATUS );
         RETURN ret_value;
   END GETSTORAGELOADSTATUS;
   FUNCTION GETSTORAGELOADVERIFTEXTVALUE(
      P_QTY IN NUMBER,
      P_NOM_DATE IN DATE,
      P_LOADTYPE IN VARCHAR2,
      P_CARGO_STATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETSTORAGELOADVERIFTEXTVALUE      (
         P_QTY,
         P_NOM_DATE,
         P_LOADTYPE,
         P_CARGO_STATUS );
         RETURN ret_value;
   END GETSTORAGELOADVERIFTEXTVALUE;
   FUNCTION GETESTLIFTEDQTYMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETESTLIFTEDQTYMTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETESTLIFTEDQTYMTH;
   FUNCTION GETACCESTLIFTEDQTYMTH(
      P_LIFTING_ACCOUNT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_INCL_DELTA IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETACCESTLIFTEDQTYMTH      (
         P_LIFTING_ACCOUNT_ID,
         P_DAYTIME,
         P_XTRA_QTY,
         P_INCL_DELTA );
         RETURN ret_value;
   END GETACCESTLIFTEDQTYMTH;
   FUNCTION GETESTLIFTEDQTYDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETESTLIFTEDQTYDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETESTLIFTEDQTYDAY;
   FUNCTION GETLIFTEDQTYMTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.GETLIFTEDQTYMTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETLIFTEDQTYMTH;
   FUNCTION CALCSTORAGELEVEL(
      P_STORAGE_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PLAN IN VARCHAR2 DEFAULT 'PO',
      P_XTRA_QTY IN NUMBER DEFAULT 0,
      P_IGNORE_CACHE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_STORAGE_BALANCE.CALCSTORAGELEVEL      (
         P_STORAGE_ID,
         P_DAYTIME,
         P_PLAN,
         P_XTRA_QTY,
         P_IGNORE_CACHE );
         RETURN ret_value;
   END CALCSTORAGELEVEL;

END RPDP_STORAGE_BALANCE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STORAGE_BALANCE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.50 AM


