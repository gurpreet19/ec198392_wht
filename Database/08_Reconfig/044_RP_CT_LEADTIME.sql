create or replace PACKAGE RP_CT_LEADTIME
IS

   FUNCTION CALC_ETA_LT(
      P_STORAGE_ID IN VARCHAR2,
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL,
      P_TYPE IN VARCHAR2 DEFAULT 'FCST')
      RETURN NUMBER;
   FUNCTION CONVERT_CARGO_DURATION(
      P_CARGO_NO IN NUMBER,
      P_DURATION_CODE IN VARCHAR2,
      P_NOM_DATE_TIME IN DATE DEFAULT NULL,
      P_PRIMARY_PARCEL IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CONVERT_CARGO_TIMELINE(
      P_CARGO_NO IN NUMBER,
      P_TIMELINE_CODE IN VARCHAR2,
      P_NOM_DATE_TIME IN DATE DEFAULT NULL,
      P_PRIMARY_PARCEL IN NUMBER DEFAULT NULL)
      RETURN DATE;
   FUNCTION GETLASTTIMESHEETENTRY(
      P_CARGO_NO IN NUMBER,
      P_TIMELINE_CODE IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETFIRSTNOMDATETIME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION CALC_COMBINE_ETD_LT(
      P_STORAGE_ID IN VARCHAR2,
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL,
      P_CARGO_NO IN VARCHAR2 DEFAULT NULL,
      P_TYPE IN VARCHAR2 DEFAULT 'FCST')
      RETURN DATE;
   FUNCTION CALC_SCHED_CARRIER_RTT(
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RP_CT_LEADTIME;
/
create or replace PACKAGE BODY RP_CT_LEADTIME
IS

   FUNCTION CALC_ETA_LT(
      P_STORAGE_ID IN VARCHAR2,
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL,
      P_TYPE IN VARCHAR2 DEFAULT 'FCST')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := UE_CT_LEADTIME.CALC_ETA_LT      (
         P_STORAGE_ID,
         P_PARCEL_NO,
         P_FORECAST_NO,
         P_TYPE );
         RETURN ret_value;
   END CALC_ETA_LT;
   FUNCTION CONVERT_CARGO_DURATION(
      P_CARGO_NO IN NUMBER,
      P_DURATION_CODE IN VARCHAR2,
      P_NOM_DATE_TIME IN DATE DEFAULT NULL,
      P_PRIMARY_PARCEL IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := UE_CT_LEADTIME.CONVERT_CARGO_DURATION      (
         P_CARGO_NO,
         P_DURATION_CODE,
         P_NOM_DATE_TIME,
         P_PRIMARY_PARCEL );
         RETURN ret_value;
   END CONVERT_CARGO_DURATION;
   FUNCTION CONVERT_CARGO_TIMELINE(
      P_CARGO_NO IN NUMBER,
      P_TIMELINE_CODE IN VARCHAR2,
      P_NOM_DATE_TIME IN DATE DEFAULT NULL,
      P_PRIMARY_PARCEL IN NUMBER DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := UE_CT_LEADTIME.CONVERT_CARGO_TIMELINE      (
         P_CARGO_NO,
         P_TIMELINE_CODE,
         P_NOM_DATE_TIME,
         P_PRIMARY_PARCEL );
         RETURN ret_value;
   END CONVERT_CARGO_TIMELINE;
   FUNCTION GETLASTTIMESHEETENTRY(
      P_CARGO_NO IN NUMBER,
      P_TIMELINE_CODE IN VARCHAR2,
      P_PRODUCT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := UE_CT_LEADTIME.GETLASTTIMESHEETENTRY      (
         P_CARGO_NO,
         P_TIMELINE_CODE,
         P_PRODUCT_ID );
         RETURN ret_value;
   END GETLASTTIMESHEETENTRY;
   FUNCTION GETFIRSTNOMDATETIME(
      P_CARGO_NO IN NUMBER,
      P_FORECAST_ID IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := UE_CT_LEADTIME.GETFIRSTNOMDATETIME      (
         P_CARGO_NO,
         P_FORECAST_ID );
         RETURN ret_value;
   END GETFIRSTNOMDATETIME;
   FUNCTION CALC_COMBINE_ETD_LT(
      P_STORAGE_ID IN VARCHAR2,
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL,
      P_CARGO_NO IN VARCHAR2 DEFAULT NULL,
      P_TYPE IN VARCHAR2 DEFAULT 'FCST')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := UE_CT_LEADTIME.CALC_COMBINE_ETD_LT      (
         P_STORAGE_ID,
         P_PARCEL_NO,
         P_FORECAST_NO,
         P_CARGO_NO,
         P_TYPE );
         RETURN ret_value;
   END CALC_COMBINE_ETD_LT;
   FUNCTION CALC_SCHED_CARRIER_RTT(
      P_PARCEL_NO IN NUMBER,
      P_FORECAST_NO IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := UE_CT_LEADTIME.CALC_SCHED_CARRIER_RTT      (
         P_PARCEL_NO,
         P_FORECAST_NO );
         RETURN ret_value;
   END CALC_SCHED_CARRIER_RTT;

END RP_CT_LEADTIME;
/