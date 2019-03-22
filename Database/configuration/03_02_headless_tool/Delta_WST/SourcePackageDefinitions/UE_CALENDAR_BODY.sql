CREATE OR REPLACE PACKAGE BODY ue_Calendar IS
/****************************************************************
** Package        :  ue_Calendar, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions for EcDp_Calendar
**
** Documentation  :  www.energy-components.com
**
** Created        : 12.12.2011  EnergyComponents Team
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.0	    12.12.2011 HOIENGEO   Initial version
************************************************************************************************************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetCollActualDate
-- Description    : This is an INSTEAD OF user-exit addon to the standard EcDp_Calendar.GetCollActualDate.
-- Preconditions  : Must be enabled using global variable isGetCollActualDateUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDate(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_offset NUMBER,
                           p_method VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  GetCollActualDatePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Calendar.GetCollActualDatePre.
-- Preconditions  : Must be enabled using global variable isGetCollActualDatePreUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDatePre(p_object_id VARCHAR2,
                              p_daytime DATE,
                              p_offset NUMBER,
                              p_method VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDatePre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetCollActualDatePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Calendar.GetCollActualDatePost.
-- Preconditions  : Must be enabled using global variable isGetCollActualDatePostUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDatePost(p_object_id VARCHAR2,
                               p_daytime DATE,
                               p_offset NUMBER,
                               p_method VARCHAR2,
                               p_tentative_ret_val DATE)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDatePost;

-------------------------------------------------------------------------------------------------
-- Function       : GetRecurringHoliday
-- Description    : This is a POST user-exit addon to the standard EcDp_Calendar.GetRecurringHoliday.
-- Preconditions  : Must be enabled using global variable isGetRecurringHolidayPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------

FUNCTION GetRecurringHoliday(p_recurring_holiday_code VARCHAR2,
                             p_year                   NUMBER)
RETURN DATE
IS
 ld_retval DATE;
 ld_month  DATE;
 ld_year   DATE;
BEGIN
  ld_retval := NULL;

  ld_year := trunc(to_date(p_year,'yyyy'),'YYYY');
    -- This is an example of how to use the user exit functionality
    -- No guarantee for future support of these specific examples.
  CASE
    WHEN p_recurring_holiday_code = 'UK_SPRING_BANK_HOLIDAY' THEN
      --Find the last Monday of May
      ld_month := add_months(ld_year, +4);  --To get to May
      ld_retval := ecdp_calendar.GetLastDayofMonth(ld_month,'Monday');
    WHEN p_recurring_holiday_code = 'UK_EARLY_MAY_BANK_HOLIDAY' THEN
      --Find the first Monday of May
      ld_month := add_months(ld_year,+4); --To get to May
      ld_retval := ecdp_calendar.GetNthDayofMonth(ld_month,'Monday',1);
    ELSE
      ld_retval := NULL;
  END CASE;
  RETURN ld_retval;
END GetRecurringHoliday;

-------------------------------------------------------------------------------------------------
END ue_Calendar;