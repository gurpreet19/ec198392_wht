
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.50 AM


CREATE or REPLACE PACKAGE RPBP_AGGREGATE
IS

   FUNCTION AGGREGATESUBDAILY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PERIOD_HRS IN NUMBER,
      P_AGGR_METHOD IN VARCHAR2 DEFAULT 'ON_STREAM',
      P_AGGR_DATETIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION AGGREGATEALLSUBDAILY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_FACILITY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PERIOD_HRS IN NUMBER,
      P_AGGR_METHOD IN VARCHAR2 DEFAULT 'ON_STREAM',
      P_ACCESS_LEVEL IN NUMBER,
      P_STRM_SET IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

END RPBP_AGGREGATE;

/



CREATE or REPLACE PACKAGE BODY RPBP_AGGREGATE
IS

   FUNCTION AGGREGATESUBDAILY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PERIOD_HRS IN NUMBER,
      P_AGGR_METHOD IN VARCHAR2 DEFAULT 'ON_STREAM',
      P_AGGR_DATETIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_AGGREGATE.AGGREGATESUBDAILY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_OBJECT_ID,
         P_DAYTIME,
         P_PERIOD_HRS,
         P_AGGR_METHOD,
         P_AGGR_DATETIME );
         RETURN ret_value;
   END AGGREGATESUBDAILY;
   FUNCTION AGGREGATEALLSUBDAILY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_FACILITY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PERIOD_HRS IN NUMBER,
      P_AGGR_METHOD IN VARCHAR2 DEFAULT 'ON_STREAM',
      P_ACCESS_LEVEL IN NUMBER,
      P_STRM_SET IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_AGGREGATE.AGGREGATEALLSUBDAILY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_OBJECT_ID,
         P_FACILITY_ID,
         P_DAYTIME,
         P_PERIOD_HRS,
         P_AGGR_METHOD,
         P_ACCESS_LEVEL,
         P_STRM_SET );
         RETURN ret_value;
   END AGGREGATEALLSUBDAILY;

END RPBP_AGGREGATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_AGGREGATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.51 AM


