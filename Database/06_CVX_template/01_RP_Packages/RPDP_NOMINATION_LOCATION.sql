
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.52 AM


CREATE or REPLACE PACKAGE RPDP_NOMINATION_LOCATION
IS

   FUNCTION GETTOTALEXTACCQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETLOCATIONNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETLOCATIONTYPE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETTOTALADJQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALADJTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALCONFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALEXTCONFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALREQTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION LESSERRULE(
      P_QTY_ONE IN NUMBER,
      P_QTY_TWO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETTOTALACCQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALCONFQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALREQQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALEXTACCQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALSCHTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION CONVERTEQTY(
      P_QTY IN NUMBER,
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_FROM_CONDITION IN VARCHAR2,
      P_TO_CONDITION IN VARCHAR2,
      P_PCT IN NUMBER,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETFIRSTCONTRACTID(
      P_COMPANY_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETTOTALACCQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALREQQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETFCSTSUMFRACCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_DIM1_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETSUMFRACCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALEXTADJQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALSCHEDQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETDELSTRMLOCATIONTYPE(
      P_DELSTRM_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSUMFRACPRODUCTCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALACCTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALADJQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALEXTCONFQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALEXTADJQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETTOTALSCHEDQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER;

END RPDP_NOMINATION_LOCATION;

/



CREATE or REPLACE PACKAGE BODY RPDP_NOMINATION_LOCATION
IS

   FUNCTION GETTOTALEXTACCQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTACCQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTACCQTYPRCOMPANY;
   FUNCTION GETLOCATIONNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETLOCATIONNAME      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETLOCATIONNAME;
   FUNCTION GETLOCATIONTYPE(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETLOCATIONTYPE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END GETLOCATIONTYPE;
   FUNCTION GETTOTALADJQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALADJQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALADJQTYPRCOMPANY;
   FUNCTION GETTOTALADJTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALADJTRANSFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALADJTRANSFQTYPRCONTRACT;
   FUNCTION GETTOTALCONFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALCONFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALCONFQTYPRCONTRACT;
   FUNCTION GETTOTALEXTCONFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTCONFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTCONFQTYPRCONTRACT;
   FUNCTION GETTOTALREQTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALREQTRANSFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALREQTRANSFQTYPRCONTRACT;
   FUNCTION LESSERRULE(
      P_QTY_ONE IN NUMBER,
      P_QTY_TWO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.LESSERRULE      (
         P_QTY_ONE,
         P_QTY_TWO );
         RETURN ret_value;
   END LESSERRULE;
   FUNCTION GETTOTALACCQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALACCQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALACCQTYPRCONTRACT;
   FUNCTION GETTOTALCONFQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALCONFQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALCONFQTYPRCOMPANY;
   FUNCTION GETTOTALREQQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALREQQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALREQQTYPRCOMPANY;
   FUNCTION GETTOTALEXTACCQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTACCQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTACCQTYPRCONTRACT;
   FUNCTION GETTOTALSCHTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALSCHTRANSFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALSCHTRANSFQTYPRCONTRACT;
   FUNCTION CONVERTEQTY(
      P_QTY IN NUMBER,
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_FROM_CONDITION IN VARCHAR2,
      P_TO_CONDITION IN VARCHAR2,
      P_PCT IN NUMBER,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.CONVERTEQTY      (
         P_QTY,
         P_FROM_UNIT,
         P_TO_UNIT,
         P_FROM_CONDITION,
         P_TO_CONDITION,
         P_PCT,
         P_DAYTIME );
         RETURN ret_value;
   END CONVERTEQTY;
   FUNCTION GETFIRSTCONTRACTID(
      P_COMPANY_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETFIRSTCONTRACTID      (
         P_COMPANY_ID );
         RETURN ret_value;
   END GETFIRSTCONTRACTID;
   FUNCTION GETTOTALACCQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALACCQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALACCQTYPRCOMPANY;
   FUNCTION GETTOTALREQQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALREQQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALREQQTYPRCONTRACT;
   FUNCTION GETFCSTSUMFRACCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_DIM1_KEY IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETFCSTSUMFRACCOMPRECFAC      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_DIM1_KEY );
         RETURN ret_value;
   END GETFCSTSUMFRACCOMPRECFAC;
   FUNCTION GETSUMFRACCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETSUMFRACCOMPRECFAC      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSUMFRACCOMPRECFAC;
   FUNCTION GETTOTALEXTADJQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTADJQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTADJQTYPRCOMPANY;
   FUNCTION GETTOTALSCHEDQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALSCHEDQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALSCHEDQTYPRCONTRACT;
   FUNCTION GETDELSTRMLOCATIONTYPE(
      P_DELSTRM_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETDELSTRMLOCATIONTYPE      (
         P_DELSTRM_ID );
         RETURN ret_value;
   END GETDELSTRMLOCATIONTYPE;
   FUNCTION GETSUMFRACPRODUCTCOMPRECFAC(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETSUMFRACPRODUCTCOMPRECFAC      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_PRODUCT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSUMFRACPRODUCTCOMPRECFAC;
   FUNCTION GETTOTALACCTRANSFQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALACCTRANSFQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALACCTRANSFQTYPRCONTRACT;
   FUNCTION GETTOTALADJQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALADJQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALADJQTYPRCONTRACT;
   FUNCTION GETTOTALEXTCONFQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTCONFQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTCONFQTYPRCOMPANY;
   FUNCTION GETTOTALEXTADJQTYPRCONTRACT(
      P_LOCATION_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALEXTADJQTYPRCONTRACT      (
         P_LOCATION_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALEXTADJQTYPRCONTRACT;
   FUNCTION GETTOTALSCHEDQTYPRCOMPANY(
      P_COMPANY_ID IN VARCHAR2,
      P_NOM_CYCLE IN VARCHAR2,
      P_NOM_TYPE IN VARCHAR2,
      P_OPER_NOM_IND IN VARCHAR2,
      P_DATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_NOMINATION_LOCATION.GETTOTALSCHEDQTYPRCOMPANY      (
         P_COMPANY_ID,
         P_NOM_CYCLE,
         P_NOM_TYPE,
         P_OPER_NOM_IND,
         P_DATE );
         RETURN ret_value;
   END GETTOTALSCHEDQTYPRCOMPANY;

END RPDP_NOMINATION_LOCATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_NOMINATION_LOCATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.58 AM


