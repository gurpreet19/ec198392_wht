
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.36 AM


CREATE or REPLACE PACKAGE RPDP_BPM_EC_EVENT_INBOUND
IS

   FUNCTION CLEAN_UP
      RETURN NUMBER;
   FUNCTION ON_DATASET_DELETED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ON_DATASET_STATE_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_OLD_STATE IN VARCHAR2,
      P_NEW_STATE IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ADD_EVENT(
      P_SOURCE IN VARCHAR2,
      P_TYPE IN NUMBER,
      P_ATTRIBUTES IN OUT T_BPM_TABLE_T_EVENT_ATTRIBUTE)
      RETURN NUMBER;
   FUNCTION ON_DATASET_SOURCE_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_SOURCE IN VARCHAR2,
      P_SOURCE_TYPE IN VARCHAR2,
      P_SOURCE_ID IN VARCHAR2,
      P_SOURCE_DATASET IN VARCHAR2,
      P_SOURCE_DATASET_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ON_GENERIC_EVENT(
      P_NAME IN VARCHAR2,
      P_SOURCE IN VARCHAR2,
      P_ATTRIBUTES IN OUT T_BPM_TABLE_T_EVENT_ATTRIBUTE)
      RETURN NUMBER;
   FUNCTION POP_PENDING_EVENT(
      P_MAX_COUNT IN NUMBER DEFAULT 1)
      RETURN SYS_REFCURSOR;
   FUNCTION ON_DATASET_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER;

END RPDP_BPM_EC_EVENT_INBOUND;

/



CREATE or REPLACE PACKAGE BODY RPDP_BPM_EC_EVENT_INBOUND
IS

   FUNCTION CLEAN_UP
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN

         ret_value := ECDP_BPM_EC_EVENT_INBOUND.CLEAN_UP ;
         RETURN ret_value;
   END CLEAN_UP;
   FUNCTION ON_DATASET_DELETED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ON_DATASET_DELETED      (
         P_DATASET,
         P_DATASET_TYPE,
         P_SOURCE );
         RETURN ret_value;
   END ON_DATASET_DELETED;
   FUNCTION ON_DATASET_STATE_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_OLD_STATE IN VARCHAR2,
      P_NEW_STATE IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ON_DATASET_STATE_UPDATED      (
         P_DATASET,
         P_DATASET_TYPE,
         P_OLD_STATE,
         P_NEW_STATE,
         P_SOURCE );
         RETURN ret_value;
   END ON_DATASET_STATE_UPDATED;
   FUNCTION ADD_EVENT(
      P_SOURCE IN VARCHAR2,
      P_TYPE IN NUMBER,
      P_ATTRIBUTES IN OUT T_BPM_TABLE_T_EVENT_ATTRIBUTE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ADD_EVENT      (
         P_SOURCE,
         P_TYPE,
         P_ATTRIBUTES );
         RETURN ret_value;
   END ADD_EVENT;
   FUNCTION ON_DATASET_SOURCE_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_SOURCE IN VARCHAR2,
      P_SOURCE_TYPE IN VARCHAR2,
      P_SOURCE_ID IN VARCHAR2,
      P_SOURCE_DATASET IN VARCHAR2,
      P_SOURCE_DATASET_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ON_DATASET_SOURCE_UPDATED      (
         P_DATASET,
         P_DATASET_TYPE,
         P_SOURCE,
         P_SOURCE_TYPE,
         P_SOURCE_ID,
         P_SOURCE_DATASET,
         P_SOURCE_DATASET_TYPE );
         RETURN ret_value;
   END ON_DATASET_SOURCE_UPDATED;
   FUNCTION ON_GENERIC_EVENT(
      P_NAME IN VARCHAR2,
      P_SOURCE IN VARCHAR2,
      P_ATTRIBUTES IN OUT T_BPM_TABLE_T_EVENT_ATTRIBUTE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ON_GENERIC_EVENT      (
         P_NAME,
         P_SOURCE,
         P_ATTRIBUTES );
         RETURN ret_value;
   END ON_GENERIC_EVENT;
   FUNCTION POP_PENDING_EVENT(
      P_MAX_COUNT IN NUMBER DEFAULT 1)
      RETURN SYS_REFCURSOR
   IS
      ret_value    SYS_REFCURSOR ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.POP_PENDING_EVENT      (
         P_MAX_COUNT );
         RETURN ret_value;
   END POP_PENDING_EVENT;
   FUNCTION ON_DATASET_UPDATED(
      P_DATASET IN VARCHAR2,
      P_DATASET_TYPE IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_SOURCE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_BPM_EC_EVENT_INBOUND.ON_DATASET_UPDATED      (
         P_DATASET,
         P_DATASET_TYPE,
         P_ATTRIBUTE_NAME,
         P_SOURCE );
         RETURN ret_value;
   END ON_DATASET_UPDATED;

END RPDP_BPM_EC_EVENT_INBOUND;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_BPM_EC_EVENT_INBOUND TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.38 AM


