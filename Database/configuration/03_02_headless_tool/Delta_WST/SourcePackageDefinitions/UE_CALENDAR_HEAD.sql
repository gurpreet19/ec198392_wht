CREATE OR REPLACE package ue_Calendar IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

** Enable this User Exit by setting variables below to 'TRUE'

** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  ue_Calendar, header part
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
************************************************************************/

-- Enabling User Exits for EcDp_Calendar.GetCollActualDate
isGetCollActualDateUEE     VARCHAR2(32) := 'FALSE'; -- Instead of
isGetCollActualDatePreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isGetCollActualDatePostUEE VARCHAR2(32) := 'FALSE'; -- Post

isGetRecurringHolidayPostUEE  VARCHAR2(32) := 'TRUE'; -- Post

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.TransferQuantitiesRecord

FUNCTION GetCollActualDate(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_offset NUMBER,
                           p_method VARCHAR2
                           ) RETURN DATE;

FUNCTION GetCollActualDatePre(p_object_id VARCHAR2,
                              p_daytime DATE,
                              p_offset NUMBER,
                              p_method VARCHAR2
                              ) RETURN DATE;

FUNCTION GetCollActualDatePost(p_object_id VARCHAR2,
                               p_daytime DATE,
                               p_offset NUMBER,
                               p_method VARCHAR2,
                               p_tentative_ret_val DATE
                               ) RETURN DATE;

FUNCTION GetRecurringHoliday(p_recurring_holiday_code VARCHAR2,
                             p_year                    NUMBER
                             ) RETURN DATE;
-----------------------------------------------------------------------------------------------------------------------------

END ue_Calendar;