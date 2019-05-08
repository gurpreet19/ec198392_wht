
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.40 AM


CREATE or REPLACE PACKAGE RPDP_WELL
IS

   FUNCTION CALCONSTRMHRSMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_TYPE IN VARCHAR2,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETIWELPERIODONSTRMFROMSTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_START_DAYTIME IN DATE,
      P_END_DAYTIME IN DATE)
      RETURN NUMBER;
      TYPE REC_GETWELL IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_CODE VARCHAR2 (32) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         TEMPLATE_NO VARCHAR2 (16) ,
         WELL_HOLE_ID VARCHAR2 (32) ,
         MASTER_SYS_CODE VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
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
         REC_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32)  );
   FUNCTION GETWELL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETWELL;
   FUNCTION ISWELLNOTCLOSEDLT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ACTIVEPHASES(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETFIELDFROMNODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETWELLCLASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETWELLTYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISWELLPHASEACTIVESTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_PHASE IN VARCHAR2,
      P_ACTIVE_STATUS IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION CHECKCLOSEDWELLWITHINPERIOD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETDAILYWELLDOWNHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_INJ_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETWELLEQUIPMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION GETPWELFLOWDIRECTION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPWELONSTREAMHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALCONSTRMDAYSINMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALCWELLTYPEFRACDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_WELL_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETIWELONSTREAMHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETPWELEVENTONSTREAMSHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETPWELFRACTOSTRMTONODE(
      P_OBJECT_ID IN VARCHAR2,
      P_STREAM_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETWELLCONNECTEDFACILITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISWELLINJECTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETFLOWLINE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETPWELPERIODONSTRMFROMSTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DAYTIME IN DATE,
      P_END_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION ISDEFERRED(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISWELLOPEN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION COUNTPRODUCINGDAYS(
      P_OBJECT_ID IN VARCHAR2,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSPLITFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2,
      P_TARGET_FACILITY_ID IN VARCHAR2,
      P_TARGET_FLOWLINE_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCURRENTFLOWLINEID(
      P_WELL_ID IN VARCHAR2,
      P_FLOWLINE_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISWELLACTIVESTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ACTIVE_STATUS IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETFACILITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETFIELDFROMWEBO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETWELLSLEEVEUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISPLANNEDWELL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION ISWELLPRODUCER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION WELLONTEST(
      P_WELL_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPDP_WELL;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL
IS

   FUNCTION CALCONSTRMHRSMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_TYPE IN VARCHAR2,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.CALCONSTRMHRSMONTH      (
         P_OBJECT_ID,
         P_INJ_TYPE,
         P_DAYTIME,
         P_CALC_TYPE,
         P_ON_STRM_METHOD );
         RETURN ret_value;
   END CALCONSTRMHRSMONTH;
   FUNCTION GETIWELPERIODONSTRMFROMSTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_START_DAYTIME IN DATE,
      P_END_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETIWELPERIODONSTRMFROMSTATUS      (
         P_OBJECT_ID,
         P_INJ_TYPE,
         P_START_DAYTIME,
         P_END_DAYTIME );
         RETURN ret_value;
   END GETIWELPERIODONSTRMFROMSTATUS;
   FUNCTION GETWELL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETWELL
   IS
      ret_value    REC_GETWELL ;
   BEGIN
      ret_value := ECDP_WELL.GETWELL      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWELL;
   FUNCTION ISWELLNOTCLOSEDLT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLNOTCLOSEDLT      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLNOTCLOSEDLT;
   FUNCTION ACTIVEPHASES(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ACTIVEPHASES      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ACTIVEPHASES;
   FUNCTION GETFIELDFROMNODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := ECDP_WELL.GETFIELDFROMNODE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETFIELDFROMNODE;
   FUNCTION GETWELLCLASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETWELLCLASS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWELLCLASS;
   FUNCTION GETWELLTYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETWELLTYPE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWELLTYPE;
   FUNCTION ISWELLPHASEACTIVESTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_PHASE IN VARCHAR2,
      P_ACTIVE_STATUS IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLPHASEACTIVESTATUS      (
         P_OBJECT_ID,
         P_INJ_PHASE,
         P_ACTIVE_STATUS,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLPHASEACTIVESTATUS;
   FUNCTION CHECKCLOSEDWELLWITHINPERIOD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.CHECKCLOSEDWELLWITHINPERIOD      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_END_DATE );
         RETURN ret_value;
   END CHECKCLOSEDWELLWITHINPERIOD;
   FUNCTION GETDAILYWELLDOWNHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_INJ_TYPE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETDAILYWELLDOWNHRS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_INJ_TYPE );
         RETURN ret_value;
   END GETDAILYWELLDOWNHRS;
   FUNCTION GETWELLEQUIPMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := ECDP_WELL.GETWELLEQUIPMENT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CLASS_NAME );
         RETURN ret_value;
   END GETWELLEQUIPMENT;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_WELL.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION GETPWELFLOWDIRECTION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETPWELFLOWDIRECTION      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPWELFLOWDIRECTION;
   FUNCTION GETPWELONSTREAMHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETPWELONSTREAMHRS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ON_STRM_METHOD );
         RETURN ret_value;
   END GETPWELONSTREAMHRS;
   FUNCTION CALCONSTRMDAYSINMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.CALCONSTRMDAYSINMONTH      (
         P_OBJECT_ID,
         P_INJ_TYPE,
         P_DAYTIME,
         P_ON_STRM_METHOD );
         RETURN ret_value;
   END CALCONSTRMDAYSINMONTH;
   FUNCTION CALCWELLTYPEFRACDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_WELL_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.CALCWELLTYPEFRACDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_WELL_TYPE );
         RETURN ret_value;
   END CALCWELLTYPEFRACDAY;
   FUNCTION GETIWELONSTREAMHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETIWELONSTREAMHRS      (
         P_OBJECT_ID,
         P_INJ_TYPE,
         P_DAYTIME,
         P_ON_STRM_METHOD );
         RETURN ret_value;
   END GETIWELONSTREAMHRS;
   FUNCTION GETPWELEVENTONSTREAMSHRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_ON_STRM_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETPWELEVENTONSTREAMSHRS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_ON_STRM_METHOD );
         RETURN ret_value;
   END GETPWELEVENTONSTREAMSHRS;
   FUNCTION GETPWELFRACTOSTRMTONODE(
      P_OBJECT_ID IN VARCHAR2,
      P_STREAM_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETPWELFRACTOSTRMTONODE      (
         P_OBJECT_ID,
         P_STREAM_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETPWELFRACTOSTRMTONODE;
   FUNCTION GETWELLCONNECTEDFACILITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETWELLCONNECTEDFACILITY      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWELLCONNECTEDFACILITY;
   FUNCTION ISWELLINJECTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLINJECTOR      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLINJECTOR;
   FUNCTION GETFLOWLINE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETFLOWLINE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETFLOWLINE;
   FUNCTION GETPWELPERIODONSTRMFROMSTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_START_DAYTIME IN DATE,
      P_END_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.GETPWELPERIODONSTRMFROMSTATUS      (
         P_OBJECT_ID,
         P_START_DAYTIME,
         P_END_DAYTIME );
         RETURN ret_value;
   END GETPWELPERIODONSTRMFROMSTATUS;
   FUNCTION ISDEFERRED(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISDEFERRED      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISDEFERRED;
   FUNCTION ISWELLOPEN(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLOPEN      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLOPEN;
   FUNCTION COUNTPRODUCINGDAYS(
      P_OBJECT_ID IN VARCHAR2,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.COUNTPRODUCINGDAYS      (
         P_OBJECT_ID,
         P_FROM_DAYTIME,
         P_TO_DAYTIME );
         RETURN ret_value;
   END COUNTPRODUCINGDAYS;
   FUNCTION FINDSPLITFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2,
      P_TARGET_FACILITY_ID IN VARCHAR2,
      P_TARGET_FLOWLINE_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL.FINDSPLITFACTOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PHASE,
         P_TARGET_FACILITY_ID,
         P_TARGET_FLOWLINE_ID );
         RETURN ret_value;
   END FINDSPLITFACTOR;
   FUNCTION GETCURRENTFLOWLINEID(
      P_WELL_ID IN VARCHAR2,
      P_FLOWLINE_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETCURRENTFLOWLINEID      (
         P_WELL_ID,
         P_FLOWLINE_TYPE,
         P_DAYTIME );
         RETURN ret_value;
   END GETCURRENTFLOWLINEID;
   FUNCTION ISWELLACTIVESTATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_ACTIVE_STATUS IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLACTIVESTATUS      (
         P_OBJECT_ID,
         P_ACTIVE_STATUS,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLACTIVESTATUS;
   FUNCTION GETFACILITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETFACILITY      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETFACILITY;
   FUNCTION GETFIELDFROMWEBO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := ECDP_WELL.GETFIELDFROMWEBO      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETFIELDFROMWEBO;
   FUNCTION GETWELLSLEEVEUOM(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.GETWELLSLEEVEUOM      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWELLSLEEVEUOM;
   FUNCTION ISPLANNEDWELL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISPLANNEDWELL      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISPLANNEDWELL;
   FUNCTION ISWELLPRODUCER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.ISWELLPRODUCER      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISWELLPRODUCER;
   FUNCTION WELLONTEST(
      P_WELL_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_WELL.WELLONTEST      (
         P_WELL_ID,
         P_DAYTIME );
         RETURN ret_value;
   END WELLONTEST;

END RPDP_WELL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.47 AM


