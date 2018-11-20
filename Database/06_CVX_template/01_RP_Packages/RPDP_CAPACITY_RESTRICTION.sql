
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.04 AM


CREATE or REPLACE PACKAGE RPDP_CAPACITY_RESTRICTION
IS

   FUNCTION GETSUBDAYRATESCHEDVOLPRLOC(
      P_LOCATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_SCHEDULE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETRESTRICTEDCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GETDESIGNCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GETRATESCHEDVOLPRLOC(
      P_LOCATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_SCHEDULE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCAPACITYUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION GETSUBDAYRESTRICTEDCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RPDP_CAPACITY_RESTRICTION;

/



CREATE or REPLACE PACKAGE BODY RPDP_CAPACITY_RESTRICTION
IS

   FUNCTION GETSUBDAYRATESCHEDVOLPRLOC(
      P_LOCATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_SCHEDULE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETSUBDAYRATESCHEDVOLPRLOC      (
         P_LOCATION_ID,
         P_DAYTIME,
         P_RATE_SCHEDULE,
         P_CLASS_NAME );
         RETURN ret_value;
   END GETSUBDAYRATESCHEDVOLPRLOC;
   FUNCTION GETRESTRICTEDCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETRESTRICTEDCAPACITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GETRESTRICTEDCAPACITY;
   FUNCTION GETDESIGNCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETDESIGNCAPACITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GETDESIGNCAPACITY;
   FUNCTION GETRATESCHEDVOLPRLOC(
      P_LOCATION_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RATE_SCHEDULE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETRATESCHEDVOLPRLOC      (
         P_LOCATION_ID,
         P_DAYTIME,
         P_RATE_SCHEDULE,
         P_CLASS_NAME );
         RETURN ret_value;
   END GETRATESCHEDVOLPRLOC;
   FUNCTION GETCAPACITYUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETCAPACITYUOM      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GETCAPACITYUOM;
   FUNCTION GETSUBDAYRESTRICTEDCAPACITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CAPACITY_RESTRICTION.GETSUBDAYRESTRICTEDCAPACITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GETSUBDAYRESTRICTEDCAPACITY;

END RPDP_CAPACITY_RESTRICTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CAPACITY_RESTRICTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.06 AM

