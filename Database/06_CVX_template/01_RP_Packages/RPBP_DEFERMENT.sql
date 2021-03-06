
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.08 AM


CREATE or REPLACE PACKAGE RPBP_DEFERMENT
IS

   FUNCTION CALCWELLCORRACTIONVOLUME(
      P_EVENT_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COUNTCHILDEVENT(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSNOCHILDEVENT(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPLANNEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETPOTENTIALMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_POTENTIAL_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPARENTEVENTLOSSMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSMASS(
      P_EVENT_NO IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2 DEFAULT NULL,
      P_CHILD_COUNT IN NUMBER DEFAULT 1)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DEDUCT1SECONDYN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETACTUALPRODUCEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_STRM_SET IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETACTUALVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSMASSNOCHILDEVENT(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSVOLUME(
      P_EVENT_NO IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2 DEFAULT NULL,
      P_CHILD_COUNT IN NUMBER DEFAULT 1)
      RETURN NUMBER;
   FUNCTION GETPARENTCOMMENT(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETPARENTEVENTLOSSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETMTHASSIGNEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCWELLPRODLOSSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETASSIGNEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETCOMMONREASONCODESETTING(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETMTHACTUALVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETEVENTLOSSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPARENTEVENTLOSSMASS(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETMTHPLANNEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETPARENTEVENTLOSSVOLUME(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPOTENTIALRATE(
      P_EVENT_NO IN NUMBER,
      P_POTENTIAL_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSCHEDULEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SCHEDULED IN VARCHAR2)
      RETURN NUMBER;

END RPBP_DEFERMENT;

/



CREATE or REPLACE PACKAGE BODY RPBP_DEFERMENT
IS

   FUNCTION CALCWELLCORRACTIONVOLUME(
      P_EVENT_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.CALCWELLCORRACTIONVOLUME      (
         P_EVENT_NO,
         P_DAYTIME,
         P_END_DATE,
         P_EVENT_ATTRIBUTE );
         RETURN ret_value;
   END CALCWELLCORRACTIONVOLUME;
   FUNCTION COUNTCHILDEVENT(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.COUNTCHILDEVENT      (
         P_EVENT_NO );
         RETURN ret_value;
   END COUNTCHILDEVENT;
   FUNCTION GETEVENTLOSSNOCHILDEVENT(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSNOCHILDEVENT      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE );
         RETURN ret_value;
   END GETEVENTLOSSNOCHILDEVENT;
   FUNCTION GETPLANNEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPLANNEDVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END GETPLANNEDVOLUMES;
   FUNCTION GETPOTENTIALMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_POTENTIAL_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPOTENTIALMASSRATE      (
         P_EVENT_NO,
         P_POTENTIAL_ATTRIBUTE );
         RETURN ret_value;
   END GETPOTENTIALMASSRATE;
   FUNCTION GETPARENTEVENTLOSSMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPARENTEVENTLOSSMASSRATE      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE,
         P_DEFERMENT_TYPE );
         RETURN ret_value;
   END GETPARENTEVENTLOSSMASSRATE;
   FUNCTION GETEVENTLOSSMASS(
      P_EVENT_NO IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2 DEFAULT NULL,
      P_CHILD_COUNT IN NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSMASS      (
         P_EVENT_NO,
         P_PHASE,
         P_OBJECT_ID,
         P_CHILD_COUNT );
         RETURN ret_value;
   END GETEVENTLOSSMASS;
   FUNCTION GETEVENTLOSSMASSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSMASSRATE      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE );
         RETURN ret_value;
   END GETEVENTLOSSMASSRATE;
   FUNCTION DEDUCT1SECONDYN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_DEFERMENT.DEDUCT1SECONDYN      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END DEDUCT1SECONDYN;
   FUNCTION GETACTUALPRODUCEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_STRM_SET IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETACTUALPRODUCEDVOLUMES      (
         P_OBJECT_ID,
         P_STRM_SET,
         P_DAYTIME,
         P_ENDDATE );
         RETURN ret_value;
   END GETACTUALPRODUCEDVOLUMES;
   FUNCTION GETACTUALVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETACTUALVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME,
         P_ENDDATE );
         RETURN ret_value;
   END GETACTUALVOLUMES;
   FUNCTION GETEVENTLOSSMASSNOCHILDEVENT(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSMASSNOCHILDEVENT      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE );
         RETURN ret_value;
   END GETEVENTLOSSMASSNOCHILDEVENT;
   FUNCTION GETEVENTLOSSVOLUME(
      P_EVENT_NO IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2 DEFAULT NULL,
      P_CHILD_COUNT IN NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSVOLUME      (
         P_EVENT_NO,
         P_PHASE,
         P_OBJECT_ID,
         P_CHILD_COUNT );
         RETURN ret_value;
   END GETEVENTLOSSVOLUME;
   FUNCTION GETPARENTCOMMENT(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPARENTCOMMENT      (
         P_EVENT_NO );
         RETURN ret_value;
   END GETPARENTCOMMENT;
   FUNCTION GETPARENTEVENTLOSSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPARENTEVENTLOSSRATE      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE,
         P_DEFERMENT_TYPE );
         RETURN ret_value;
   END GETPARENTEVENTLOSSRATE;
   FUNCTION GETMTHASSIGNEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETMTHASSIGNEDDEFERVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END GETMTHASSIGNEDDEFERVOLUMES;
   FUNCTION CALCWELLPRODLOSSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.CALCWELLPRODLOSSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END CALCWELLPRODLOSSDAY;
   FUNCTION GETASSIGNEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ENDDATE IN DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETASSIGNEDDEFERVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME,
         P_ENDDATE );
         RETURN ret_value;
   END GETASSIGNEDDEFERVOLUMES;
   FUNCTION GETCOMMONREASONCODESETTING(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETCOMMONREASONCODESETTING      (
         P_KEY );
         RETURN ret_value;
   END GETCOMMONREASONCODESETTING;
   FUNCTION GETMTHACTUALVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETMTHACTUALVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END GETMTHACTUALVOLUMES;
   FUNCTION GETEVENTLOSSRATE(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETEVENTLOSSRATE      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE );
         RETURN ret_value;
   END GETEVENTLOSSRATE;
   FUNCTION GETPARENTEVENTLOSSMASS(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPARENTEVENTLOSSMASS      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE,
         P_DEFERMENT_TYPE );
         RETURN ret_value;
   END GETPARENTEVENTLOSSMASS;
   FUNCTION GETMTHPLANNEDVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETMTHPLANNEDVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END GETMTHPLANNEDVOLUMES;
   FUNCTION GETPARENTEVENTLOSSVOLUME(
      P_EVENT_NO IN NUMBER,
      P_EVENT_ATTRIBUTE IN VARCHAR2,
      P_DEFERMENT_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPARENTEVENTLOSSVOLUME      (
         P_EVENT_NO,
         P_EVENT_ATTRIBUTE,
         P_DEFERMENT_TYPE );
         RETURN ret_value;
   END GETPARENTEVENTLOSSVOLUME;
   FUNCTION GETPOTENTIALRATE(
      P_EVENT_NO IN NUMBER,
      P_POTENTIAL_ATTRIBUTE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETPOTENTIALRATE      (
         P_EVENT_NO,
         P_POTENTIAL_ATTRIBUTE );
         RETURN ret_value;
   END GETPOTENTIALRATE;
   FUNCTION GETSCHEDULEDDEFERVOLUMES(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SCHEDULED IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_DEFERMENT.GETSCHEDULEDDEFERVOLUMES      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME,
         P_SCHEDULED );
         RETURN ret_value;
   END GETSCHEDULEDDEFERVOLUMES;

END RPBP_DEFERMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_DEFERMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.13 AM


