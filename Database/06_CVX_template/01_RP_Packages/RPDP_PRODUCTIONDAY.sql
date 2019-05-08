
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.08 AM


CREATE or REPLACE PACKAGE RPDP_PRODUCTIONDAY
IS

   FUNCTION FINDSUBDAILYFREQ(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPRODUCTIONDAYSTART(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN DATE;
      TYPE EC_UNIQUE_DAYTIME IS RECORD (
         DAYTIME  DATE ,
         SUMMERTIME_FLAG VARCHAR2 (1)  );
   FUNCTION GETPRODUCTIONDAYSTARTTIME(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME;
   FUNCTION FINDPRODUCTIONDAYDEFINITION(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPRODUCTIONDAYDAYTIMES(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES;
   FUNCTION GETPRODUCTIONDAY(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMERTIME_FLAG IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION GETPRODUCTIONDAYFRACTION(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_FROM_SUMMER_TIME IN VARCHAR2,
      P_TO_DAYTIME IN DATE,
      P_TO_SUMMER_TIME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPRODUCTIONDAYOFFSET(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETTZOFFSETINDAYS(
      P_TIME_ZONE_OFFSET IN VARCHAR2)
      RETURN NUMBER;

END RPDP_PRODUCTIONDAY;

/



CREATE or REPLACE PACKAGE BODY RPDP_PRODUCTIONDAY
IS

   FUNCTION FINDSUBDAILYFREQ(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.FINDSUBDAILYFREQ      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSUBDAILYFREQ;
   FUNCTION GETPRODUCTIONDAYSTART(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYSTART      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAY );
         RETURN ret_value;
   END GETPRODUCTIONDAYSTART;
   FUNCTION GETPRODUCTIONDAYSTARTTIME(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIME
   IS
      ret_value    ECDP_DATE_TIME.EC_UNIQUE_DAYTIME ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYSTARTTIME      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAY );
         RETURN ret_value;
   END GETPRODUCTIONDAYSTARTTIME;
   FUNCTION FINDPRODUCTIONDAYDEFINITION(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.FINDPRODUCTIONDAYDEFINITION      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDPRODUCTIONDAYDEFINITION;
   FUNCTION GETPRODUCTIONDAYDAYTIMES(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE)
      RETURN ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES
   IS
      ret_value    ECDP_DATE_TIME.EC_UNIQUE_DAYTIMES ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYDAYTIMES      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAY );
         RETURN ret_value;
   END GETPRODUCTIONDAYDAYTIMES;
   FUNCTION GETPRODUCTIONDAY(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMERTIME_FLAG IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME,
         P_SUMMERTIME_FLAG );
         RETURN ret_value;
   END GETPRODUCTIONDAY;
   FUNCTION GETPRODUCTIONDAYFRACTION(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAY IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_FROM_SUMMER_TIME IN VARCHAR2,
      P_TO_DAYTIME IN DATE,
      P_TO_SUMMER_TIME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYFRACTION      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAY,
         P_FROM_DAYTIME,
         P_FROM_SUMMER_TIME,
         P_TO_DAYTIME,
         P_TO_SUMMER_TIME );
         RETURN ret_value;
   END GETPRODUCTIONDAYFRACTION;
   FUNCTION GETPRODUCTIONDAYOFFSET(
      P_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SUMMER_TIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET      (
         P_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME,
         P_SUMMER_TIME );
         RETURN ret_value;
   END GETPRODUCTIONDAYOFFSET;
   FUNCTION GETTZOFFSETINDAYS(
      P_TIME_ZONE_OFFSET IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PRODUCTIONDAY.GETTZOFFSETINDAYS      (
         P_TIME_ZONE_OFFSET );
         RETURN ret_value;
   END GETTZOFFSETINDAYS;

END RPDP_PRODUCTIONDAY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PRODUCTIONDAY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.10 AM


