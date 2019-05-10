
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.09 AM


CREATE or REPLACE PACKAGE RPDP_DATE_TIME
IS

   FUNCTION LOCAL2UTC(
      P_DATETIME IN DATE,
      P_SUMMERTIME_FLAG IN VARCHAR2 DEFAULT 'N',
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION GETCURRENTDBSYSDATE(
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETCURRENTSYSDATE
      RETURN DATE;
   FUNCTION GETNUMHOURS(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN INTEGER;
   FUNCTION GETPRODUCTIONDAYSTARTTIME(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME;
   FUNCTION GETPRODUCTIONDAYDAYTIMES(
      PDD_OBJECT_ID IN VARCHAR2,
      P_SUB_DAY_FREQ_CODE IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES;
   FUNCTION GETPRODUCTIONDAY(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2)
      RETURN DATE;
   FUNCTION UTC2LOCAL(
      P_DATETIME IN DATE,
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
      TYPE EC_UNIQUE_DAYTIME IS RECORD (
         DAYTIME  DATE ,
         SUMMERTIME_FLAG VARCHAR2 (1)  );
   FUNCTION GETNEXTHOUR(
      P_DATE IN DATE,
      P_SUMMER_TIME IN VARCHAR2)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME;
   FUNCTION SUMMERTIME_FLAG(
      P_DATE IN DATE,
      P_DEFAULT_UTC_OFFSET IN NUMBER DEFAULT NULL,
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETPRODUCTIONDAYFRACTION(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_FROM_SUMMER_TIME IN VARCHAR2,
      P_TO_DAYTIME IN DATE,
      P_TO_SUMMER_TIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPRODUCTIONDAYOFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETDATEDIFF(
      P_WHAT IN VARCHAR2,
      P_DT1 IN DATE,
      P_DT2 IN DATE)
      RETURN NUMBER;
   FUNCTION GETTZOFFSETINDAYS(
      P_TIME_ZONE_OFFSET IN VARCHAR2)
      RETURN NUMBER;

END RPDP_DATE_TIME;

/



CREATE or REPLACE PACKAGE BODY RPDP_DATE_TIME
IS

   FUNCTION LOCAL2UTC(
      P_DATETIME IN DATE,
      P_SUMMERTIME_FLAG IN VARCHAR2 DEFAULT 'N',
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_DATE_TIME.LOCAL2UTC      (
         P_DATETIME,
         P_SUMMERTIME_FLAG,
         P_PDAY_OBJECT_ID );
         RETURN ret_value;
   END LOCAL2UTC;
   FUNCTION GETCURRENTDBSYSDATE(
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETCURRENTDBSYSDATE      (
         P_DAYTIME );
         RETURN ret_value;
   END GETCURRENTDBSYSDATE;
   FUNCTION GETCURRENTSYSDATE
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN

         ret_value := ECDP_DATE_TIME.GETCURRENTSYSDATE ;
         RETURN ret_value;
   END GETCURRENTSYSDATE;
   FUNCTION GETNUMHOURS(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETNUMHOURS      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETNUMHOURS;
   FUNCTION GETPRODUCTIONDAYSTARTTIME(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME
   IS
      ret_value    ECDP_DATE_TIME.EC_UNIQUE_DAYTIME ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETPRODUCTIONDAYSTARTTIME      (
         PDD_OBJECT_ID,
         P_DAY );
         RETURN ret_value;
   END GETPRODUCTIONDAYSTARTTIME;
   FUNCTION GETPRODUCTIONDAYDAYTIMES(
      PDD_OBJECT_ID IN VARCHAR2,
      P_SUB_DAY_FREQ_CODE IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES
   IS
      ret_value    ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETPRODUCTIONDAYDAYTIMES      (
         PDD_OBJECT_ID,
         P_SUB_DAY_FREQ_CODE,
         P_DAY );
         RETURN ret_value;
   END GETPRODUCTIONDAYDAYTIMES;
   FUNCTION GETPRODUCTIONDAY(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETPRODUCTIONDAY      (
         PDD_OBJECT_ID,
         P_DAYTIME,
         P_SUMMER_TIME );
         RETURN ret_value;
   END GETPRODUCTIONDAY;
   FUNCTION UTC2LOCAL(
      P_DATETIME IN DATE,
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_DATE_TIME.UTC2LOCAL      (
         P_DATETIME,
         P_PDAY_OBJECT_ID );
         RETURN ret_value;
   END UTC2LOCAL;
   FUNCTION GETNEXTHOUR(
      P_DATE IN DATE,
      P_SUMMER_TIME IN VARCHAR2)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME
   IS
      ret_value    ECDP_DATE_TIME.EC_UNIQUE_DAYTIME ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETNEXTHOUR      (
         P_DATE,
         P_SUMMER_TIME );
         RETURN ret_value;
   END GETNEXTHOUR;
   FUNCTION SUMMERTIME_FLAG(
      P_DATE IN DATE,
      P_DEFAULT_UTC_OFFSET IN NUMBER DEFAULT NULL,
      P_PDAY_OBJECT_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_DATE_TIME.SUMMERTIME_FLAG      (
         P_DATE,
         P_DEFAULT_UTC_OFFSET,
         P_PDAY_OBJECT_ID );
         RETURN ret_value;
   END SUMMERTIME_FLAG;
   FUNCTION GETPRODUCTIONDAYFRACTION(
      PDD_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_FROM_SUMMER_TIME IN VARCHAR2,
      P_TO_DAYTIME IN DATE,
      P_TO_SUMMER_TIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETPRODUCTIONDAYFRACTION      (
         PDD_OBJECT_ID,
         P_DAY,
         P_FROM_DAYTIME,
         P_FROM_SUMMER_TIME,
         P_TO_DAYTIME,
         P_TO_SUMMER_TIME );
         RETURN ret_value;
   END GETPRODUCTIONDAYFRACTION;
   FUNCTION GETPRODUCTIONDAYOFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETPRODUCTIONDAYOFFSET      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SUMMER_TIME );
         RETURN ret_value;
   END GETPRODUCTIONDAYOFFSET;
   FUNCTION GETDATEDIFF(
      P_WHAT IN VARCHAR2,
      P_DT1 IN DATE,
      P_DT2 IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETDATEDIFF      (
         P_WHAT,
         P_DT1,
         P_DT2 );
         RETURN ret_value;
   END GETDATEDIFF;
   FUNCTION GETTZOFFSETINDAYS(
      P_TIME_ZONE_OFFSET IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DATE_TIME.GETTZOFFSETINDAYS      (
         P_TIME_ZONE_OFFSET );
         RETURN ret_value;
   END GETTZOFFSETINDAYS;

END RPDP_DATE_TIME;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_DATE_TIME TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.12 AM

