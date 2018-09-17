CREATE OR REPLACE PACKAGE EcDp_Calendar IS

  -- Author  : TRA
  -- Created : 09.10.2003
  -- Purpose : Provide functionality to use working days concept when calculating number of days.


PROCEDURE AddYear(p_object_id VARCHAR2,
                    p_daytime   DATE,
                    p_year      NUMBER,
                    p_user      VARCHAR2,
                    p_message   OUT VARCHAR2);

FUNCTION GenerateYear (p_object_id VARCHAR2,
                        p_daytime  DATE,
                        p_cal_year DATE,
                        p_user     VARCHAR2
                      ) RETURN VARCHAR2;

FUNCTION IsHoliday (p_object_id VARCHAR2,
                        p_daytime DATE,
                        p_weekday VARCHAR2
                        )
RETURN BOOLEAN;


FUNCTION IsCollHoliday (p_object_id VARCHAR2, -- Calendar Collection Id
                    p_daytime DATE --current date
                   )
RETURN VARCHAR2;

FUNCTION GetWorkingDaysDate (p_object_id VARCHAR2,
                             p_daytime DATE,
                             p_offset NUMBER,
                             p_method VARCHAR2
                             )
RETURN DATE;

FUNCTION GetDayMode (p_object_id VARCHAR2,
                     p_daytime DATE
                     )
RETURN VARCHAR2;


PROCEDURE DelCalendar (p_object_id VARCHAR2,
                       p_user VARCHAR2
                       );

FUNCTION getMaxWorkingDayDate(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER) RETURN DATE;

FUNCTION getMinWorkingDayDate(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

FUNCTION getActualOffset(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER, p_mindate DATE) RETURN NUMBER;

FUNCTION getClosestForward(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

FUNCTION getClosestBackward(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

FUNCTION getCollForward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE;

FUNCTION getCollBackward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE;

FUNCTION getCollClosestForward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE;

FUNCTION getCollClosestBackward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE;

FUNCTION getCollWorkingDaysDate(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE;

FUNCTION getCollActualDate(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER, -- number of days /offset
   p_method VARCHAR2 -- method to determine the actual date
)
RETURN DATE;

FUNCTION getBaseOffset(p_offset NUMBER --get the correct offset.
                       )
RETURN NUMBER;

FUNCTION getNumOfDaysOfMonth(p_daytime DATE --get the number of days of that give month
                       )
RETURN NUMBER;

PROCEDURE validateOffset (
                   p_offset NUMBER,
                   p_method VARCHAR2
                  );

FUNCTION getCollLastWorkingDay(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE --starting point of date
)
RETURN DATE;

FUNCTION copyCalendar(
   p_object_id     VARCHAR2,
   p_code          VARCHAR2,
   p_user          VARCHAR2,
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate   DATE DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE ValidateCalRecurringHoliday(
   p_object_id                VARCHAR2,
   p_fixed_holiday_month      VARCHAR2,
   p_fixed_holiday_day        NUMBER,
   p_date_function_holiday    VARCHAR2);

FUNCTION copyCalendarColl(
   p_object_id VARCHAR2,
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)

RETURN VARCHAR2;

FUNCTION GetEasterSunday(p_year INTEGER)
RETURN DATE;

FUNCTION GetEasterMonday(p_year INTEGER)
RETURN DATE;

FUNCTION GetMaundyThursday(p_year INTEGER)
RETURN DATE;

FUNCTION GetGoodFriday(p_year INTEGER)
RETURN DATE;

FUNCTION GetWhitSunday(p_year INTEGER)
RETURN DATE;

FUNCTION GetWhitMonday(p_year INTEGER)
RETURN DATE;

FUNCTION GetAscensionDay(p_year INTEGER)
RETURN DATE;

FUNCTION IsLeapYear(p_year IN NUMBER)
RETURN VARCHAR2;

FUNCTION GetFunctionHolidayDate(p_date_function VARCHAR2, p_year NUMBER)
RETURN DATE;

FUNCTION SetToBusinessDay(p_object_id     VARCHAR2,
                          p_daytime       DATE,
                          p_selected_date DATE,
                          p_cal_year      DATE,
                          p_user          VARCHAR2
                        ) RETURN VARCHAR2;

FUNCTION SetToHoliday(p_object_id     VARCHAR2,
                      p_daytime       DATE,
                      p_selected_date DATE,
                      p_cal_year      DATE,
                      p_user          VARCHAR2
                      ) RETURN VARCHAR2;

FUNCTION GetLatestGeneratedYear(p_object_id VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetLatestGeneratedYearDaytime(p_object_id VARCHAR2)
RETURN DATE;

PROCEDURE ValidateCommentDate(p_object_id     VARCHAR2,
                              p_selected_date DATE,
                              p_comment_date  DATE
                            ) ;

FUNCTION getCurrentYearDaytime(p_object_id VARCHAR2,
                               p_daytime   DATE,
                               p_task      VARCHAR2) RETURN VARCHAR2;

FUNCTION CreateComment(p_object_id VARCHAR2,
                       p_daytime   VARCHAR2,
                       p_comment   VARCHAR2) RETURN VARCHAR2;

END EcDp_Calendar;