
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.07 AM


CREATE or REPLACE PACKAGE RPDP_CALENDAR
IS

   FUNCTION GENERATEYEAR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCOLLBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;
   FUNCTION GETGOODFRIDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION ISCOLLHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION CREATECOMMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN VARCHAR2,
      P_COMMENT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCOLLLASTWORKINGDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETMINWORKINGDAYDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETNUMOFDAYSOFMONTH(
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION SETTOBUSINESSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SELECTED_DATE IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETACTUALOFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_MINDATE IN DATE)
      RETURN NUMBER;
   FUNCTION GETFUNCTIONHOLIDAYDATE(
      P_DATE_FUNCTION IN VARCHAR2,
      P_YEAR IN NUMBER)
      RETURN DATE;
   FUNCTION GETMAUNDYTHURSDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION GETWHITMONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION ISHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_WEEKDAY IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION COPYCALENDAR(
      P_OBJECT_ID IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_USER IN VARCHAR2,
      P_NEW_STARTDATE IN DATE DEFAULT NULL,
      P_NEW_ENDDATE IN DATE DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETCLOSESTFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETWHITSUNDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION COPYCALENDARCOLL(
      P_OBJECT_ID IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_USER IN VARCHAR2,
      P_NEW_STARTDATE IN DATE DEFAULT NULL,
      P_NEW_ENDDATE IN DATE DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETCLOSESTBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETCOLLCLOSESTFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;
   FUNCTION GETDAYMODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION SETTOHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SELECTED_DATE IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETASCENSIONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION GETCOLLWORKINGDAYSDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;
   FUNCTION GETCURRENTYEARDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TASK IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETEASTERMONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION GETLATESTGENERATEDYEAR(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLATESTGENERATEDYEARDAYTIME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETWORKINGDAYSDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_METHOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION ISLEAPYEAR(
      P_YEAR IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETEASTERSUNDAY(
      P_YEAR IN INTEGER )
      RETURN DATE;
   FUNCTION GETBASEOFFSET(
      P_OFFSET IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETCOLLACTUALDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_METHOD IN VARCHAR2)
      RETURN DATE;
   FUNCTION GETCOLLCLOSESTBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;
   FUNCTION GETCOLLFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;
   FUNCTION GETMAXWORKINGDAYDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE;

END RPDP_CALENDAR;

/



CREATE or REPLACE PACKAGE BODY RPDP_CALENDAR
IS

   FUNCTION GENERATEYEAR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.GENERATEYEAR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CAL_YEAR,
         P_USER );
         RETURN ret_value;
   END GENERATEYEAR;
   FUNCTION GETCOLLBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLBACKWARD      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETCOLLBACKWARD;
   FUNCTION GETGOODFRIDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETGOODFRIDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETGOODFRIDAY;
   FUNCTION ISCOLLHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.ISCOLLHOLIDAY      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISCOLLHOLIDAY;
   FUNCTION CREATECOMMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN VARCHAR2,
      P_COMMENT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.CREATECOMMENT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMMENT );
         RETURN ret_value;
   END CREATECOMMENT;
   FUNCTION GETCOLLLASTWORKINGDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLLASTWORKINGDAY      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETCOLLLASTWORKINGDAY;
   FUNCTION GETMINWORKINGDAYDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETMINWORKINGDAYDATE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETMINWORKINGDAYDATE;
   FUNCTION GETNUMOFDAYSOFMONTH(
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETNUMOFDAYSOFMONTH      (
         P_DAYTIME );
         RETURN ret_value;
   END GETNUMOFDAYSOFMONTH;
   FUNCTION SETTOBUSINESSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SELECTED_DATE IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.SETTOBUSINESSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SELECTED_DATE,
         P_CAL_YEAR,
         P_USER );
         RETURN ret_value;
   END SETTOBUSINESSDAY;
   FUNCTION GETACTUALOFFSET(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_MINDATE IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETACTUALOFFSET      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET,
         P_MINDATE );
         RETURN ret_value;
   END GETACTUALOFFSET;
   FUNCTION GETFUNCTIONHOLIDAYDATE(
      P_DATE_FUNCTION IN VARCHAR2,
      P_YEAR IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETFUNCTIONHOLIDAYDATE      (
         P_DATE_FUNCTION,
         P_YEAR );
         RETURN ret_value;
   END GETFUNCTIONHOLIDAYDATE;
   FUNCTION GETMAUNDYTHURSDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETMAUNDYTHURSDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETMAUNDYTHURSDAY;
   FUNCTION GETWHITMONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETWHITMONDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETWHITMONDAY;
   FUNCTION ISHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_WEEKDAY IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := ECDP_CALENDAR.ISHOLIDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_WEEKDAY );
         RETURN ret_value;
   END ISHOLIDAY;
   FUNCTION COPYCALENDAR(
      P_OBJECT_ID IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_USER IN VARCHAR2,
      P_NEW_STARTDATE IN DATE DEFAULT NULL,
      P_NEW_ENDDATE IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.COPYCALENDAR      (
         P_OBJECT_ID,
         P_CODE,
         P_USER,
         P_NEW_STARTDATE,
         P_NEW_ENDDATE );
         RETURN ret_value;
   END COPYCALENDAR;
   FUNCTION GETCLOSESTFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCLOSESTFORWARD      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETCLOSESTFORWARD;
   FUNCTION GETWHITSUNDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETWHITSUNDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETWHITSUNDAY;
   FUNCTION COPYCALENDARCOLL(
      P_OBJECT_ID IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_USER IN VARCHAR2,
      P_NEW_STARTDATE IN DATE DEFAULT NULL,
      P_NEW_ENDDATE IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.COPYCALENDARCOLL      (
         P_OBJECT_ID,
         P_CODE,
         P_USER,
         P_NEW_STARTDATE,
         P_NEW_ENDDATE );
         RETURN ret_value;
   END COPYCALENDARCOLL;
   FUNCTION GETCLOSESTBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCLOSESTBACKWARD      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETCLOSESTBACKWARD;
   FUNCTION GETCOLLCLOSESTFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLCLOSESTFORWARD      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETCOLLCLOSESTFORWARD;
   FUNCTION GETDAYMODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETDAYMODE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETDAYMODE;
   FUNCTION SETTOHOLIDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SELECTED_DATE IN DATE,
      P_CAL_YEAR IN DATE,
      P_USER IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.SETTOHOLIDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SELECTED_DATE,
         P_CAL_YEAR,
         P_USER );
         RETURN ret_value;
   END SETTOHOLIDAY;
   FUNCTION GETASCENSIONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETASCENSIONDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETASCENSIONDAY;
   FUNCTION GETCOLLWORKINGDAYSDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLWORKINGDAYSDATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETCOLLWORKINGDAYSDATE;
   FUNCTION GETCURRENTYEARDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TASK IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCURRENTYEARDAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TASK );
         RETURN ret_value;
   END GETCURRENTYEARDAYTIME;
   FUNCTION GETEASTERMONDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETEASTERMONDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETEASTERMONDAY;
   FUNCTION GETLATESTGENERATEDYEAR(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETLATESTGENERATEDYEAR      (
         P_OBJECT_ID );
         RETURN ret_value;
   END GETLATESTGENERATEDYEAR;
   FUNCTION GETLATESTGENERATEDYEARDAYTIME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETLATESTGENERATEDYEARDAYTIME      (
         P_OBJECT_ID );
         RETURN ret_value;
   END GETLATESTGENERATEDYEARDAYTIME;
   FUNCTION GETWORKINGDAYSDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_METHOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETWORKINGDAYSDATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET,
         P_METHOD );
         RETURN ret_value;
   END GETWORKINGDAYSDATE;
   FUNCTION ISLEAPYEAR(
      P_YEAR IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CALENDAR.ISLEAPYEAR      (
         P_YEAR );
         RETURN ret_value;
   END ISLEAPYEAR;
   FUNCTION GETEASTERSUNDAY(
      P_YEAR IN INTEGER )
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETEASTERSUNDAY      (
         P_YEAR );
         RETURN ret_value;
   END GETEASTERSUNDAY;
   FUNCTION GETBASEOFFSET(
      P_OFFSET IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETBASEOFFSET      (
         P_OFFSET );
         RETURN ret_value;
   END GETBASEOFFSET;
   FUNCTION GETCOLLACTUALDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER,
      P_METHOD IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLACTUALDATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET,
         P_METHOD );
         RETURN ret_value;
   END GETCOLLACTUALDATE;
   FUNCTION GETCOLLCLOSESTBACKWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLCLOSESTBACKWARD      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETCOLLCLOSESTBACKWARD;
   FUNCTION GETCOLLFORWARD(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETCOLLFORWARD      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETCOLLFORWARD;
   FUNCTION GETMAXWORKINGDAYDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_OFFSET IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CALENDAR.GETMAXWORKINGDAYDATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_OFFSET );
         RETURN ret_value;
   END GETMAXWORKINGDAYDATE;

END RPDP_CALENDAR;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CALENDAR TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.26.14 AM


