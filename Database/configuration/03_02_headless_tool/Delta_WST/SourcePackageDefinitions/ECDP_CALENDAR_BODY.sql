CREATE OR REPLACE PACKAGE BODY EcDp_Calendar IS
/****************************************************************
** Package        :  EcDp_Calendar, body part
**
** $Revision: 1.17 $
**
** Purpose        :  Provide special functions for Calendar objects.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.10.2003  Trond-Arne Brattli
**
** Modification history:
**
** Version  Date         Whom  Change description:
** -------  ----------   ----- --------------------------------------
** 1.2      27.10.2003   TRA   Change in paragraph AddYear. Year cannot be negative.
** 1.5      11.11.2003   TRA   GetWorkingDaysDate. More informative error message when uninstantiated holes are discovered.
** 1.6      13.11.2003   TRA   GetWorkingDaysDate. Added new error message (an informative on). AddYear. Able to re-instantiate a year if end_date is set to later the same year.
**          09.10.2006   DN    Migrated to EC Kernel. Removed SetObjEndDate procedure.
** 1.3      26.04.2007   CK    Added several new functions to handle Calendar Collection
******************************************************************/

-- Procedure which instantiates p_year for the given calendar object
-- based on the attribute set valid on p_daytime.
PROCEDURE AddYear (p_object_id VARCHAR2,
                   p_daytime   DATE,
                   p_year      NUMBER,
                   p_user      VARCHAR2,
                   p_message   OUT VARCHAR2
                  )
IS

ld_year DATE;
ld_start_date DATE;
ld_end_date DATE;
ld_cal_start_date DATE := ec_calendar.start_date(p_object_id);
ld_cal_end_date DATE := ec_calendar.end_date(p_object_id);
ld_max_instantiated_year DATE;
ln_no_of_days INTEGER;
ln_iterator INTEGER;
ld_current DATE;
ld_daytime DATE := p_daytime;
lv2_weekday VARCHAR2(16);
lv2_holiday VARCHAR2(1) := 'N';
ln_already_exists NUMBER := 0;
-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

already_added EXCEPTION;
too_early_year EXCEPTION;
mid_year_start EXCEPTION;
too_late_year EXCEPTION;
not_valid_year EXCEPTION;

CURSOR c_recur_holiday(p_object_id varchar2, p_daytime date, p_year number) IS
SELECT recurring_holiday_name
  FROM calendar_recurring_holidays
 WHERE object_id = p_object_id
   AND (
        ((fixed_holiday_day || '-' || fixed_holiday_month || '-' || EXTRACT(YEAR FROM p_daytime) = p_daytime AND date_function_holiday IS NULL) AND
            ((fixed_holiday_day || fixed_holiday_month != '29FEB') OR ((fixed_holiday_day || fixed_holiday_month = '29FEB') AND ECDP_CALENDAR.IsLeapYear(p_year) = 'TRUE')))
        OR
        (GetFunctionHolidayDate(date_function_holiday, p_year) = p_daytime AND date_function_holiday IS NOT NULL)
        );

lv_recurring_holiday_name calendar_recurring_holidays.recurring_holiday_name%TYPE;
lv_end_user_message       VARCHAR2(1024);

BEGIN
     -- Checks if p_year is a four digit number.
     IF (length(p_year) <> 4) THEN

       RAISE not_valid_year;

     END IF;

     IF (p_year < 0) THEN

        RAISE not_valid_year;

     END IF;

     ld_year := to_date(p_year,'yyyy');

     -- Start date is initially set to January 1st of year p_year.
     ld_start_date := trunc(ld_year,'YYYY');

     -- End date is initially set to December 31st of year p_year.
     ld_end_date := trunc(add_months(ld_year,12),'YYYY')-1;

     -- If calendar object is not valid on ld_start_date, but is valid later the same year,
     -- ld_start_date is set to the object's start_date.
     IF ((ld_cal_start_date > ld_start_date) AND (trunc(ld_cal_start_date,'yyyy') = ld_start_date)) THEN

       RAISE mid_year_start;

     -- If calendar object does not start later the same year as ld_start_date,
     -- Exception is raised.
     ELSIF (trunc(ld_cal_start_date,'yyyy') > ld_start_date) THEN

       RAISE too_early_year;

     END IF;

     -- Corresponding checks for end_date.
     IF ((ld_cal_end_date < ld_end_date) AND (trunc(ld_cal_end_date-1,'yyyy') = trunc(ld_end_date,'yyyy'))) THEN

       ld_end_date := ld_end_date;

     ELSIF (trunc(ld_cal_end_date-1,'yyyy') < trunc(ld_end_date,'yyyy')) THEN

       RAISE too_late_year;

     END IF;

     -- If no attributes are valid on p_daytime,
     -- the calendar object's start_date is used.
     IF (ld_daytime < ld_cal_start_date) THEN

       ld_daytime := ld_cal_start_date;

     END IF;

     -- Checks if p_year is already instantiated.
     SELECT count(*)
     INTO ln_already_exists
     FROM calendar_day
     WHERE year = p_year
     and object_id = p_object_id;

     -- Checks if new days should be added even if year already instantiated
     SELECT max(daytime)
     INTO ld_max_instantiated_year
     FROM calendar_day
     WHERE year = p_year
     AND object_id = p_object_id;

     -- right of and: checks if instantiated until end_date of object and checks if instantiated until last day of year inclusive.
     IF ln_already_exists > 0 AND (ld_max_instantiated_year = ld_cal_end_date OR (ld_max_instantiated_year = trunc(add_months(to_date(p_year,'yyyy'),12),'yyyy')-1)) THEN

        RAISE already_added;

     END IF;

     -- If last test was passed, new days should be instantiated.
     IF ld_max_instantiated_year is not null THEN

        ld_start_date := ld_max_instantiated_year+1;

     END IF;

     ln_no_of_days := ld_end_date-ld_start_date+1;

     -- Inserts the correct number of days with holiday mode for each weekday fetched from calendar object.
     FOR ln_iterator in 0..ln_no_of_days-1 LOOP

        ld_current := ld_start_date + ln_iterator;
        lv2_weekday := ltrim(rtrim(to_char(ld_current,'DAY','NLS_DATE_LANGUAGE = English'),' '),' ');

        OPEN c_recur_holiday(p_object_id, ld_current, p_year);
        FETCH c_recur_holiday INTO lv_recurring_holiday_name;
        CLOSE c_recur_holiday;

        IF  (IsHoliday(p_object_id, ld_current, lv2_weekday) = TRUE
           OR lv_recurring_holiday_name IS NOT NULL) THEN

           lv2_holiday := 'Y';

        END IF;

        INSERT INTO calendar_day (
              OBJECT_ID,
              DAYTIME,
              YEAR,
              NAME,
              HOLIDAY_IND,
              CREATED_BY
            )
        VALUES (
             p_object_id,
             ld_current,
             p_year,
             lv2_weekday,
             lv2_holiday,
             p_user
         );

        lv2_holiday := 'N';

          -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CALENDAR_DAY'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
           lv2_4e_recid:= SYS_GUID();

          -- Set approval info on new record.
          UPDATE calendar_day
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = p_object_id
             AND daytime = ld_current;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CALENDAR_DAY',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --
        IF lv_recurring_holiday_name IS NOT NULL THEN
          INSERT INTO calendar_day_comment(
                      COMMENT_NO,
                      OBJECT_ID,
                      DAYTIME,
                      COMMENTS,
                      CREATED_BY,
                      CREATED_DATE)
          VALUES
                     (EcDp_System_Key.assignNextNumber('CALENDAR_DAY_COMMENT'),
                     p_object_id,
                     ld_current,
                     lv_recurring_holiday_name,
                     p_user,
                     Ecdp_Timestamp.getCurrentSysdate);
        END IF;
        lv_recurring_holiday_name := '';
     END LOOP;

    p_message := 'Success!' || chr(10) || 'Calendar generated for year ' || p_year;

EXCEPTION

  WHEN already_added THEN

    lv_end_user_message := 'Error!' || chr(10) || 'Year ' || p_year || ' is already added to calendar ' || ec_calendar_version.name(p_object_id, p_daytime, '<=') || '.';
    p_message := lv_end_user_message;

  WHEN too_early_year THEN

    lv_end_user_message := 'Error!' || chr(10) || ec_calendar_version.name(p_object_id, p_daytime, '<=') || ' is not valid before ' || TO_CHAR(ld_cal_start_date, 'yyyy-mm-dd') || '.';
    p_message := lv_end_user_message;

  WHEN mid_year_start THEN

    lv_end_user_message := 'Error!' || chr(10) || ec_calendar_version.name(p_object_id, p_daytime, '<=') || ' is not valid for year ' || p_year || ' as it is starting from ' ||  TO_CHAR(ld_cal_start_date, 'yyyy-mm-dd')
                                               || '. To generate Calendar for year ' || p_year || ' it must be effective on ' ||  TO_CHAR(TRUNC(ld_cal_start_date, 'YEAR'), 'yyyy-mm-dd') || '.';
    p_message := lv_end_user_message;

  WHEN too_late_year THEN

    lv_end_user_message := 'Error!' || chr(10) || ec_calendar_version.name(p_object_id, p_daytime, '<=') || ' is not valid after ' || TO_CHAR(ld_cal_end_date, 'yyyy-mm-dd') || '.';
    p_message := lv_end_user_message;

  WHEN not_valid_year THEN

    lv_end_user_message := 'Error!' || chr(10) || p_year || ' is not a valid year.';
    p_message := lv_end_user_message;
END AddYear;

-------------------------------------------------------------------------------------------------
-- Function       : GenerateYear
-- Description    : Instantiates a calendar year for the given calendar object.
-------------------------------------------------------------------------------------------------

FUNCTION GenerateYear (p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_cal_year  DATE,
                       p_user      VARCHAR2
                      )
RETURN VARCHAR2
IS

ln_year           NUMBER;
lv_message        VARCHAR2(1024);
no_year_selected  EXCEPTION;

BEGIN

  IF p_cal_year IS NULL THEN
    RAISE no_year_selected;
  END IF;

  ln_year := EXTRACT(YEAR FROM p_cal_year);

  EcDp_Calendar.AddYear(p_object_id,
                        p_daytime,
                        ln_year,
                        p_user,
                        lv_message
                        );

  RETURN lv_message;

EXCEPTION
  WHEN no_year_selected THEN
    lv_message := 'Error!' || chr(10) || 'Please select a year to generate Calendar.';
    RETURN lv_message;

END GenerateYear;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : IsHoliday
-- Description    : Checks which mode the given weekday has in the calendar object attributes.
--
-- Preconditions  : Based on the records in calendar_day.
--
-- Postconditions :
--
-- Using tables   : calendar_day
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns TRUE if HOLIDAY_IND, FALSE otherwise.
--
-------------------------------------------------------------------------------------------------
FUNCTION IsHoliday (p_object_id VARCHAR2,
                    p_daytime DATE,
                    p_weekday VARCHAR2
                   )
RETURN BOOLEAN
--</EC-DOC>
IS

lb_retval BOOLEAN := FALSE;
lr_calendar calendar_version%ROWTYPE;
lv2_day_mode VARCHAR2(1);

BEGIN

  lr_calendar := ec_calendar_version.row_by_pk(p_object_id, p_daytime, '<=');

  IF p_weekday = 'MONDAY' THEN
     lv2_day_mode := NVL(lr_calendar.monday_ind,'N');
  ELSIF  p_weekday = 'TUESDAY' THEN
     lv2_day_mode := NVL(lr_calendar.tuesday_ind,'N');
  ELSIF  p_weekday = 'WEDNESDAY' THEN
     lv2_day_mode := NVL(lr_calendar.wednesday_ind,'N');
  ELSIF  p_weekday = 'THURSDAY' THEN
     lv2_day_mode := NVL(lr_calendar.thursday_ind,'N');
  ELSIF  p_weekday = 'FRIDAY' THEN
     lv2_day_mode := NVL(lr_calendar.friday_ind,'N');
  ELSIF  p_weekday = 'SATURDAY' THEN
     lv2_day_mode := NVL(lr_calendar.saturday_ind,'N');
  ELSIF  p_weekday = 'SUNDAY' THEN
     lv2_day_mode := NVL(lr_calendar.sunday_ind,'N');
  END IF;

  IF (lv2_day_mode = 'N') THEN

    lb_retval := TRUE;

  ELSE

    lb_retval := FALSE;

  END IF;

  RETURN lb_retval;

END IsHoliday;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : IsCollHoliday
-- Description    : Checks the given date either is holiday or not.
--
-- Preconditions  : Based on the records in calendar_day.
--
-- Postconditions :
--
-- Using tables   : calendar_day
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns TRUE if HOLIDAY_IND, FALSE otherwise.
--
-------------------------------------------------------------------------------------------------
FUNCTION IsCollHoliday (p_object_id VARCHAR2, -- Calendar Collection Id
                    p_daytime DATE --current date
                   )
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_holiday_ind VARCHAR2(1) := 'N';

CURSOR c_cal IS
SELECT ccs.object_id object_id, ccs.daytime
FROM calendar_coll_setup ccs
WHERE ccs.calendar_collection_id = p_object_id
--AND ccs.daytime = p_daytime
AND ccs.daytime = (SELECT MAX(daytime) FROM calendar_coll_setup WHERE calendar_collection_id = p_object_id AND daytime <= p_daytime )
;

BEGIN

    FOR CurCal IN c_cal LOOP

        lv2_holiday_ind := ec_calendar_day.holiday_ind(CurCal.Object_Id, p_daytime);
        IF (lv2_holiday_ind = 'Y') THEN
            RETURN 'Y';
        END IF;
    END LOOP;

    RETURN 'N';

END IsCollHoliday;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetWorkingDaysDate
-- Description    : Returns the date of p_offset working days later than p_daytime for calendar object p_object_id.
--
-- Preconditions  : Based on the records in calendar_day.
--
-- Postconditions :
--
-- Using tables   : calendar_day
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Valid type of method:
-- 'CALENDAR','CALENDAR_FORWARD','CALENDAR_BACKWARD','CALENDAR_CLOSEST_FORWARD','CALENDAR_CLOSEST_BACKWARD'
--
-------------------------------------------------------------------------------------------------
FUNCTION GetWorkingDaysDate (p_object_id VARCHAR2,
                             p_daytime DATE,
                             p_offset NUMBER,
                             p_method VARCHAR2
                             )
RETURN DATE
--</EC-DOC>
IS

ln_exists NUMBER := 0;
ln_invoicing_delay NUMBER := 1; -- The delay period from the invoice is created to the customer receives it.
ld_maxdaytime DATE;
ld_mindaytime DATE;
ld_daytime DATE := p_daytime + ln_invoicing_delay;
ld_current_date DATE := ld_daytime;
ld_not_instantiated_on DATE;

not_instantiated    EXCEPTION;
not_instantiated_on EXCEPTION;
instantiated_to     EXCEPTION;
instantiated_from   EXCEPTION;
not_valid_before    EXCEPTION;
not_valid_after     EXCEPTION;
not_valid_method    EXCEPTION;

BEGIN

  -- Some checks to make sure calendar is instantiated.
  SELECT min(daytime)
  INTO ld_mindaytime
  FROM calendar_day
  WHERE object_id = p_object_id;

  SELECT max(daytime)
  INTO ld_maxdaytime
  FROM calendar_day
  WHERE object_id = p_object_id;

  IF (ld_mindaytime is null or ld_maxdaytime is null) THEN

    RAISE not_instantiated;

  ELSIF (ld_daytime < ec_calendar.start_date(p_object_id)) THEN

    RAISE not_valid_before;

  ELSIF (ld_daytime > nvl(ec_calendar.end_date(p_object_id), ld_daytime+1)) THEN

    RAISE not_valid_after;

  ELSIF (ld_daytime + p_offset > nvl(ec_calendar.end_date(p_object_id),To_date('9999','yyyy'))) THEN

    RAISE not_valid_after;

  ELSIF (ld_daytime < ld_mindaytime) THEN

    RAISE instantiated_from;

  ELSIF (ld_daytime + p_offset > ld_maxdaytime) THEN

    RAISE instantiated_to;

  ELSE
    -- Final check
    SELECT count(*)
    INTO ln_exists
    FROM calendar_day
    WHERE object_id = p_object_id
    AND daytime = ld_current_date;

    IF (ln_exists = 0) THEN

      ld_not_instantiated_on := ld_current_date + 1;

      RAISE not_instantiated_on;

    END IF;

  END IF;

  IF (p_method = 'CALENDAR') THEN -- Only count working days
      ld_current_date := ecdp_calendar.getMaxWorkingDayDate(p_object_id, p_daytime, p_offset);
  ELSIF (p_method = 'CALENDAR_FORWARD') THEN -- Calendard days, and picks first working day if end on HOLIDAY_IND
      ld_current_date := getClosestForward(p_object_id, p_daytime + p_offset);
  ELSIF (p_method = 'CALENDAR_BACKWARD') THEN -- Calendard days, and picks first previous working day if end on HOLIDAY_IND
      ld_current_date := getClosestBackward(p_object_id, p_daytime + p_offset);
  ELSIF (p_method = 'CALENDAR_CLOSEST_FORWARD') THEN -- Calendard days, and picks closest working day, if equal days forward and back then chose next working day
      ld_maxdaytime := getClosestForward(p_object_id, p_daytime + p_offset);
      ld_mindaytime := getClosestBackward(p_object_id, p_daytime + p_offset);
      IF (ld_maxdaytime-(p_daytime+p_offset) <= (p_daytime+p_offset)-ld_mindaytime) THEN
          ld_current_date := ld_maxdaytime;
      ELSE
          ld_current_date := ld_mindaytime;
      END IF;
  ELSIF (p_method = 'CALENDAR_CLOSEST_BACKWARD') THEN -- Calendard days, and picks closest working day, if equal days forward and back then chose previous working day
      ld_maxdaytime := getClosestForward(p_object_id, p_daytime + p_offset);
      ld_mindaytime := getClosestBackward(p_object_id, p_daytime + p_offset);
      IF (ld_maxdaytime-(p_daytime+p_offset) < (p_daytime+p_offset)-ld_mindaytime) THEN
          ld_current_date := ld_maxdaytime;
      ELSE
          ld_current_date := ld_mindaytime;
      END IF;
  ELSE
      RAISE not_valid_method;
  END IF;

  RETURN ld_current_date;

EXCEPTION
         WHEN instantiated_to THEN
              Raise_Application_Error(-20000,ec_calendar_version.name(p_object_id, ld_daytime,'<=') || ' is only instantiated to '|| to_char(ld_maxdaytime,'DD.MM.YYYY') ||'.');

         WHEN instantiated_from THEN
              Raise_Application_Error(-20000, ec_calendar_version.name(p_object_id, ld_daytime,'<=') || ' is instantiated from '|| to_char(ld_mindaytime,'DD.MM.YYYY') ||'.');

         WHEN not_instantiated THEN
              Raise_Application_Error(-20000, ec_calendar_version.name(p_object_id, ld_daytime,'<=') || ' is not instantiated.');

         WHEN not_instantiated_on THEN
              Raise_Application_Error(-20000, ec_calendar_version.name(p_object_id, ld_daytime,'<=') || ' is not instantiated on '|| p_offset || ' working days from ' || to_char(ld_not_instantiated_on,'DD.MM.YYYY') ||'.');

         WHEN not_valid_before THEN
              Raise_Application_Error(-20000, ec_calendar_version.name(p_object_id, ec_calendar.start_date(p_object_id),'<=') || ' is not valid before ' || to_char(ec_calendar.start_date(p_object_id),'DD.MM.YYYY') || '.');

         WHEN not_valid_after THEN
              Raise_Application_Error(-20000,'Cannot calculate payment date as ' || ec_calendar_version.name(p_object_id, ec_calendar.end_date(p_object_id),'<=') || ' is not valid after ' || to_char(ec_calendar.end_date(p_object_id),'DD.MM.YYYY') || '.');

         WHEN not_valid_method THEN
              Raise_Application_Error(-20000,'Cannot calculate payment date, method is wrong. Method is : ' || p_method);


END Getworkingdaysdate;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetDayMode
-- Description    : Function returning the 'HOLIDAY_IND' attribute of calendar_day for the given calendar object and date.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns either 'BUSINESS' or 'HOLIDAY_IND'.
--
-------------------------------------------------------------------------------------------------
FUNCTION GetDayMode (p_object_id VARCHAR2,
                     p_daytime DATE
                     )
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_holiday IS
SELECT holiday_ind
FROM calendar_day
WHERE object_id = p_object_id
AND daytime = p_daytime;

lv2_ret_val VARCHAR2(1);

BEGIN

   FOR cur_rec IN c_holiday LOOP
      lv2_ret_val := cur_rec.holiday_ind;
   END LOOP;

   RETURN lv2_ret_val;

END GetDayMode;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : DelCalendar
-- Description    : Deletes the entire calendar objects an its associated days.
--
-- Preconditions  :
--
-- Postconditions : Uncommited changes
--
-- Using tables   : calendar_day, calendar_version, calendar
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE DelCalendar (p_object_id VARCHAR2,
                       p_user VARCHAR2
                       )

IS
--</EC-DOC>
BEGIN

  -- If not records in calendar_day are deleted
  DELETE FROM calendar_day
  WHERE object_id = p_object_id;

  -- Calendar object is deleted.
  DELETE calendar_version
  WHERE object_id = p_object_id;

  DELETE calendar
  WHERE object_id = p_object_id;

EXCEPTION
  WHEN OTHERS THEN
     Raise_Application_Error(-20000, ec_calendar_version.name(p_object_id, ec_calendar.start_date(p_object_id),'<=') || ' is in use and cannot be deleted.');

END DelCalendar;


FUNCTION getMaxWorkingDayDate(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER) RETURN DATE
IS
CURSOR c_days IS
SELECT daytime
FROM calendar_day
WHERE daytime >= p_daytime
AND object_id = p_object_id
AND HOLIDAY_IND = 'N'
AND rownum <= (p_offset + 1)
ORDER BY daytime
;
ld_date DATE;
BEGIN
    ld_date := p_daytime;
    FOR dCur IN c_days LOOP
        ld_date := dCur.Daytime;
    END LOOP;
    RETURN ld_date;
END getMaxWorkingDayDate;

FUNCTION getMinWorkingDayDate(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
IS
CURSOR c_mindays IS
SELECT MAX(daytime) daytime
FROM calendar_day
WHERE daytime < p_daytime
AND object_id = p_object_id
AND HOLIDAY_IND = 'N'
;
ld_date DATE;
BEGIN
    ld_date := p_daytime;
    FOR dCur IN c_mindays LOOP
        ld_date := dCur.Daytime;
    END LOOP;
    IF (p_daytime-1 = ld_date) THEN
        ld_date := p_daytime;
    END IF;
    RETURN ld_date;
END getMinWorkingDayDate;

FUNCTION getActualOffset(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER, p_mindate DATE) RETURN NUMBER
IS
ln_min_offset NUMBER;
BEGIN
    ln_min_offset := 0;

    SELECT count(*)
    INTO ln_min_offset
    FROM calendar_day
    WHERE HOLIDAY_IND = 'N'
    AND object_id = p_object_id
    AND daytime >= p_daytime
    AND daytime < p_mindate;

    RETURN p_offset - ln_min_offset;
END getActualOffset;

FUNCTION getClosestBackward(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
IS
CURSOR c_mindays IS
SELECT MAX(daytime) daytime
FROM calendar_day
WHERE daytime <= p_daytime
AND object_id = p_object_id
AND HOLIDAY_IND = 'N'
;
ld_date DATE;
BEGIN
    ld_date := p_daytime;
    FOR dCur IN c_mindays LOOP
        ld_date := dCur.Daytime;
    END LOOP;
    RETURN ld_date;
END getClosestBackward;

FUNCTION getClosestForward(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
IS
CURSOR c_mindays IS
SELECT MIN(daytime) daytime
FROM calendar_day
WHERE daytime >= p_daytime
AND object_id = p_object_id
AND HOLIDAY_IND = 'N'
;
ld_date DATE;
BEGIN
    ld_date := p_daytime;
    FOR dCur IN c_mindays LOOP
        ld_date := dCur.Daytime;
    END LOOP;
    RETURN ld_date;
END getClosestForward;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollForward
-- Description    : Calendar days, and picks next working day if end on HOLIDAY_IND
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date closest forward to the holiday based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollForward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE

IS
  ld_end_date DATE;
BEGIN

   ld_end_date := p_daytime + p_offset;

     LOOP
         EXIT WHEN IsCollHoliday(p_object_id, ld_end_date) = 'N';
         ld_end_date := ld_end_date +  1;

     END LOOP;

   RETURN ld_end_date;

END getCollForward;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollBack
-- Description    : Calendard days, and picks previous day before if end on HOLIDAY_IND
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date closest backword to the holiday based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollBackward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE

IS
  ld_end_date DATE;
BEGIN

   ld_end_date := p_daytime + p_offset;

     LOOP
         EXIT WHEN IsCollHoliday(p_object_id, ld_end_date) = 'N';
         ld_end_date := ld_end_date -  1;

     END LOOP;

   RETURN ld_end_date;

END getCollBackward;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollClosestForward
-- Description    : Calendard days, and picks closest working day, if equal days forward and back then chose next working day
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date closest forward to the holiday based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollClosestForward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE

IS
  ld_maxdaytime DATE;
  ld_mindaytime DATE;
  ld_current_date DATE;
BEGIN

  ld_maxdaytime := getCollForward(p_object_id, p_daytime, p_offset);
  ld_mindaytime := getCollBackward(p_object_id, p_daytime, p_offset);

    IF (ld_maxdaytime-(p_daytime+p_offset) <= (p_daytime+p_offset)-ld_mindaytime) THEN
        ld_current_date := ld_maxdaytime;
    ELSE
        ld_current_date := ld_mindaytime;
    END IF;

  return ld_current_date;

END getCollClosestForward;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollClosestBackward
-- Description    : Calendard days, and picks closest working day, if equal days forward and back then chose previous working day
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date closest backward to the holiday based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollClosestBackward(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE

IS
  ld_maxdaytime DATE;
  ld_mindaytime DATE;
  ld_current_date DATE;
BEGIN

  ld_maxdaytime := getCollForward(p_object_id, p_daytime, p_offset);
  ld_mindaytime := getCollBackward(p_object_id, p_daytime, p_offset);

    IF (ld_maxdaytime-(p_daytime+p_offset) < (p_daytime+p_offset)-ld_mindaytime) THEN
        ld_current_date := ld_maxdaytime;
    ELSE
        ld_current_date := ld_mindaytime;
    END IF;

  return ld_current_date;

END getCollClosestBackward;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollWorkingDaysDate
-- Description    : get the date from calendar collection object based on working days.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollWorkingDaysDate(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE, --starting point of date
   p_offset NUMBER -- number of days /offset
)
RETURN DATE

IS
  ld_current DATE;
  ln_counter NUMBER := 0;
  ln_offset NUMBER := 0;
BEGIN

 ld_current := p_daytime;


  IF (IsCollHoliday(p_object_id, ld_current) = 'Y' ) THEN
      ln_offset := getBaseOffset(p_offset);
  ELSE
      ln_offset := p_offset;
  END IF;

IF SIGN(p_offset) >= 0 THEN


     -- This loop is counting p_days from p_source_date and adding it to the p_source_date
     LOOP

         IF (IsCollHoliday(p_object_id, ld_current) = 'N') THEN
             ln_counter := ln_counter + 1;
         END IF;

         EXIT WHEN ln_counter > ln_offset;

         ld_current := ld_current +  1;

     END LOOP;


ELSIF SIGN(p_offset) < 0 THEN

     -- This loop is counting p_days from p_source_date and adding it to the p_source_date
     LOOP

         IF (IsCollHoliday(p_object_id, ld_current) = 'N') THEN
             ln_counter := ln_counter - 1;
         END IF;

         EXIT WHEN ln_counter < ln_offset;

         ld_current := ld_current -  1;

     END LOOP;

END IF;

   RETURN ld_current;

END getCollWorkingDaysDate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollWorkingDaysDate
-- Description    : get the date from calendar collection object based on working days.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return proper working date based on given source date plus offset
--
-------------------------------------------------------------------------------------------------
FUNCTION getCollActualDate(
  p_object_id VARCHAR2, --calendar coll id
  p_daytime DATE, --starting point of date
  p_offset NUMBER, -- number of days /offset
  p_method VARCHAR2 -- method to determine the actual date
)
RETURN DATE

IS
  ld_return_val DATE;
  ln_base_offset NUMBER := getBaseOffset(p_offset);
  ln_num_of_days NUMBER := 0;
BEGIN

  --UserExit - Instead of
  IF ue_Calendar.isGetCollActualDateUEE = 'TRUE' THEN
    ld_return_val := ue_Calendar.GetCollActualDate(p_object_id, p_daytime, p_offset, p_method);
  ELSE
    --UserExit - Pre
    IF ue_Calendar.isGetCollActualDatePreUEE = 'TRUE' THEN
      ld_return_val := ue_Calendar.GetCollActualDatePre(p_object_id, p_daytime, p_offset, p_method);
    END IF;

    IF p_method = 'MANUAL' THEN
      ld_return_val := p_daytime;

    ELSIF p_method = 'SYSDATE' THEN
      ld_return_val := trunc(Ecdp_Timestamp.getCurrentSysdate,'DD');

    ELSIF p_method = 'CAL_PREV_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id,  Add_Months(trunc(p_daytime, 'MONTH'), -1) , ln_base_offset);

    ELSIF p_method = 'CAL_CURRENT_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id,  trunc(p_daytime, 'MONTH') , ln_base_offset);

    ELSIF p_method = 'CAL_NEXT_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id,  Add_Months(trunc(p_daytime, 'MONTH'), 1) , ln_base_offset);

    ELSIF p_method = 'FIXED_PREV_MTH' THEN

      ln_num_of_days := getNumOfDaysOfMonth(Add_Months(trunc(p_daytime, 'MONTH'), -1));

        IF p_offset > ln_num_of_days THEN
          ld_return_val := Add_Months(trunc(p_daytime, 'MONTH'), -1) + ln_num_of_days - 1;
        ELSE
          ld_return_val := Add_Months(trunc(p_daytime, 'MONTH'), -1) + ln_base_offset;
        END IF;

    ELSIF p_method = 'FIXED_CURR_MTH' THEN

      ln_num_of_days := getNumOfDaysOfMonth(trunc(p_daytime, 'MONTH'));

      IF p_offset > ln_num_of_days THEN
        ld_return_val := trunc(p_daytime, 'MONTH') + ln_num_of_days - 1;
      ELSE
        ld_return_val := trunc(p_daytime, 'MONTH') + ln_base_offset;
      END IF;

    ELSIF p_method = 'FIXED_NEXT_MTH' THEN

      ln_num_of_days := getNumOfDaysOfMonth(Add_Months(trunc(p_daytime, 'MONTH'), 1));

      IF p_offset > ln_num_of_days THEN
        ld_return_val := Add_Months(trunc(p_daytime, 'MONTH'), 1)  + ln_num_of_days - 1;
      ELSE
        ld_return_val := Add_Months(trunc(p_daytime, 'MONTH'), 1)  + ln_base_offset;
      END IF;

    ELSIF p_method = 'FIXED_DAYS' THEN
      ld_return_val := p_daytime + p_offset;

    ELSIF p_method = 'CALENDAR' THEN
      ld_return_val := getCollWorkingDaysDate(p_object_id, p_daytime , p_offset);

    ELSIF p_method = 'CALENDAR_FORWARD' THEN
      ld_return_val := getCollForward(p_object_id, p_daytime , p_offset);

    ELSIF p_method = 'CALENDAR_BACKWARD' THEN
      ld_return_val := getCollBackward(p_object_id, p_daytime , p_offset);

    ELSIF p_method = 'CALENDAR_CLOSEST_FORWARD' THEN
      ld_return_val := getCollClosestForward(p_object_id, p_daytime , p_offset);

    ELSIF p_method = 'CALENDAR_CLOSEST_BACKWARD' THEN
      ld_return_val := getCollClosestBackward(p_object_id, p_daytime , p_offset);

    ELSIF p_method = 'CALENDAR_CLOSEST_FORWARD_NM' THEN
      ld_return_val := getCollClosestForward(p_object_id, Add_Months(trunc(p_daytime,'MONTH'), 1) , ln_base_offset);

    ELSIF p_method = 'CALENDAR_CLOSEST_BACKWARD_NM' THEN
      ld_return_val := getCollClosestBackward(p_object_id, Add_Months(trunc(p_daytime,'MONTH'), 1) , ln_base_offset);

    ELSIF p_method = 'XTH_LAST_PREV_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id, getCollLastWorkingDay(p_object_id, Add_Months(trunc(p_daytime, 'MONTH'), -1)), p_offset);

    ELSIF p_method = 'XTH_LAST_CURR_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id, getCollLastWorkingDay(p_object_id, trunc(p_daytime, 'MONTH')), p_offset);

    ELSIF p_method = 'XTH_LAST_NEXT_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id, getCollLastWorkingDay(p_object_id, Add_Months(trunc(p_daytime, 'MONTH'), 1)), p_offset);

    ELSIF p_method = 'XTH_LAST_NEXTNEXT_MTH' THEN
      ld_return_val := ecdp_calendar.getCollWorkingDaysDate(p_object_id, getCollLastWorkingDay(p_object_id, Add_Months(trunc(p_daytime, 'MONTH'), 2)), p_offset);

    ELSIF p_method = 'CAL_XTH_LAST_PREV_MTH' THEN
      ld_return_val := Last_Day(Add_Months(trunc(p_daytime, 'MONTH'), -1))+ p_offset;

    ELSIF p_method = 'CAL_XTH_LAST_CURR_MTH' THEN
      ld_return_val := Last_Day(trunc(p_daytime, 'MONTH'))+ p_offset;

    ELSIF p_method = 'CAL_XTH_LAST_NEXT_MTH' THEN
      ld_return_val := Last_Day(Add_Months(trunc(p_daytime, 'MONTH'), 1))+ p_offset;

    ELSIF p_method = 'CAL_XTH_LAST_NEXTNEXT_MTH' THEN
      ld_return_val := Last_Day(Add_Months(trunc(p_daytime, 'MONTH'), 2))+ p_offset;

    ELSIF p_method = 'CALC_RULE' THEN
      ld_return_val := p_daytime;

    ELSIF p_method = 'NO_DATE' THEN
      ld_return_val := NULL;

    ELSE
      ld_return_val := p_daytime;

    END IF;

    --UserExit - Post
    IF ue_Calendar.isGetCollActualDatePostUEE = 'TRUE' THEN
      ld_return_val := ue_Calendar.GetCollActualDatePost(p_object_id, p_daytime, p_offset, p_method, ld_return_val);
    END IF;

  END IF;

  RETURN ld_return_val;

END getCollActualDate;

--function to include base date into offset for the calculation based on the terms
FUNCTION getBaseOffset(p_offset NUMBER --get the correct offset.
                       ) RETURN NUMBER IS
  ln_result NUMBER;
BEGIN

  --if offset > 0 then return the result equals to offset - 1
  if p_offset > 0 then
     ln_result := p_offset - 1;
  --if offset < 0 then return the result equals to offset + 1
  elsif p_offset < 0 then
     ln_result := p_offset + 1;
  else --return 0
     ln_result :=0;
  end if;

  return ln_result;

END getBaseOffset;

--function to get the number of days of that given month
FUNCTION getNumOfDaysOfMonth(p_daytime DATE
                       ) RETURN NUMBER IS
  ln_result NUMBER;
BEGIN

  select to_number(to_char(last_day(p_daytime),'DD')) into ln_result from dual;
  return ln_result;

END getNumOfDaysOfMonth;


--function to validate the valid input offset for given method
PROCEDURE validateOffset (
                   p_offset NUMBER,
                   p_method VARCHAR2
                  )
IS
BEGIN

  IF p_method = 'CAL_PREV_MTH' OR p_method = 'CAL_CURRENT_MTH' OR p_method = 'CAL_NEXT_MTH' THEN

    IF p_offset <= 0 THEN
      RAISE_APPLICATION_ERROR(-20000,'Offset for ' || p_method || ' must be greater than 0');
    END IF;

  ELSIF p_method = 'FIXED_PREV_MTH' OR p_method = 'FIXED_CURR_MTH' OR p_method = 'FIXED_NEXT_MTH' THEN

    IF p_offset <= 0 OR p_offset > 31 THEN
      RAISE_APPLICATION_ERROR(-20000,'Offset for ' || p_method || ' must be greater than 0 and less than 31');
    END IF;

  END IF;

END validateOffset;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getCollLastWorkingDay
-- Description    : get the last working day of given month from calendar collection object based on given date.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : calendar_day, calendar_version, calendar, calendar_collection, calendar_coll_version
--
-- Using functions: Last_Day, IsCollHoliday
--
-- Configuration
-- required       :
--
-- Behaviour      : return last working day based on given source date
--
-------------------------------------------------------------------------------------------------

FUNCTION getCollLastWorkingDay(
   p_object_id VARCHAR2, --calendar coll id
   p_daytime DATE --starting point of date
)
RETURN DATE

IS
  ld_end_date DATE;
BEGIN

   ld_end_date :=  Last_Day(p_daytime);

     LOOP
         EXIT WHEN IsCollHoliday(p_object_id, ld_end_date) = 'N';
         ld_end_date := ld_end_date -  1;

     END LOOP;

   RETURN ld_end_date;

END getCollLastWorkingDay;

-------------------------------------------------------------------------------------------------
-- Function       : CopyCalendar
-- Description    : Copy Calendar object and its related linked data to new
-------------------------------------------------------------------------------------------------
FUNCTION copyCalendar(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)
RETURN VARCHAR2
IS
  ld_calendar_start_date DATE := ec_calendar.start_date(p_object_id);
  ld_calendar_end_date DATE := ec_calendar.end_date(p_object_id);

  no_date_arguments  EXCEPTION;
  start_date_out_of_timespan EXCEPTION;
  invalid_new_dates EXCEPTION;

  lv2_default_code      VARCHAR2(100) := p_code||'_COPY';
  lv2_object_id         calendar.object_id%TYPE;
  lrec_calendar         calendar%ROWTYPE;
  lrec_calendar_version calendar_version%ROWTYPE;
  lv_end_user_message   VARCHAR2(1024);

BEGIN

   -- Not allowed to continue if start date is not passed from the business function
   IF p_new_startdate IS NULL THEN
     RAISE no_date_arguments;
   END IF;

   -- check that the new start date is within the copied calendar lifespan
   IF p_new_startdate <  ld_calendar_start_date OR p_new_startdate >= ld_calendar_end_date then
     RAISE start_date_out_of_timespan;
   END IF;

   --new object dates should not be the same
   IF p_new_startdate >= p_new_enddate THEN
     RAISE invalid_new_dates;
   END IF;

   -- Resetting these variables to be the new calendar' start date and end date
   ld_calendar_start_date := p_new_startdate;
   ld_calendar_end_date := p_new_enddate;

   lv2_default_code := Ecdp_Object_Copy.GetCopyObjectCode('CALENDAR',lv2_default_code);

   lrec_calendar := ec_calendar.row_by_pk(p_object_id);

   -- Insert new calendar record
   INSERT INTO calendar
              (object_code,
              start_date,
              end_date,
              created_by)
   VALUES (lv2_default_code,
           p_new_startdate,
           p_new_enddate,
           p_user)
   RETURNING object_id INTO lv2_object_id;

   -- Update new calendar record
   UPDATE calendar
      SET description     = lrec_calendar.description,
          last_updated_by = p_user
    WHERE object_id = lv2_object_id;

   lrec_calendar_version := ec_calendar_version.row_by_pk(p_object_id, ld_calendar_start_date,'<=');

   -- Insert new calendar version record
   INSERT INTO calendar_version
               (object_id,
                daytime,
                end_date,
                created_by)
   VALUES (lv2_object_id,
           p_new_startdate,
           p_new_enddate,
           p_user);

   -- Update new calendar version record
   UPDATE calendar_version
      SET name = lrec_calendar_version.name,
          monday_ind = lrec_calendar_version.monday_ind,
          tuesday_ind = lrec_calendar_version.tuesday_ind,
          wednesday_ind = lrec_calendar_version.wednesday_ind,
          thursday_ind = lrec_calendar_version.thursday_ind,
          friday_ind = lrec_calendar_version.friday_ind,
          saturday_ind = lrec_calendar_version.saturday_ind,
          sunday_ind = lrec_calendar_version.sunday_ind,
          comments = lrec_calendar_version.comments,
          last_updated_by = p_user
    WHERE object_id = lv2_object_id
      AND daytime = ld_calendar_start_date;

   -- Insert yearly recurring holidays to the new calendar object
  INSERT INTO dv_calendar_recur_holidays
              (object_id,
               recurring_holiday_name,
               fixed_holiday_month,
               fixed_holiday_day,
               date_func_holiday,
               comments)
       SELECT lv2_object_id,
              c.recurring_holiday_name,
              c.fixed_holiday_month,
              c.fixed_holiday_day,
              c.date_function_holiday,
              c.comments
         FROM calendar_recurring_holidays c
        WHERE object_id = p_object_id;

  lv_end_user_message := 'Success!' || chr(10) || 'Calendar ''' || ec_calendar.object_code(lv2_object_id) || ''' starting from ''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' is created.';
  RETURN lv_end_user_message;

EXCEPTION
  WHEN start_date_out_of_timespan THEN
    lv_end_user_message := 'Error!' || chr(10) || 'New Start Date:''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' must be within the selected calendar''s time span';
    RETURN lv_end_user_message;
  WHEN invalid_new_dates THEN
    lv_end_user_message := 'Error!' || chr(10) || 'New Start Date:''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' should not be the same as New End Date:''' || to_char(p_new_enddate,'yyyy-mm-dd') || '''';
    RETURN lv_end_user_message;
  WHEN no_date_arguments THEN
    lv_end_user_message := 'Error!' || chr(10) || 'Start date is missing';
    RETURN lv_end_user_message;

END copyCalendar;

-------------------------------------------------------------------------------------------------
-- Procedure      : ValidateCalRecurringHoliday
-- Description    : to validate calendar recurring holidays record before inserting or updating
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateCalRecurringHoliday(
   p_object_id                VARCHAR2,
   p_fixed_holiday_month      VARCHAR2,
   p_fixed_holiday_day        NUMBER,
   p_date_function_holiday    VARCHAR2)
IS
  n_count NUMBER;
  fixed_or_function_holiday  EXCEPTION;
  fixed_day_not_selected     EXCEPTION;
  fixed_holiday_exists       EXCEPTION;
  date_func_holiday_exists   EXCEPTION;

BEGIN

  IF (p_fixed_holiday_month IS NULL AND p_fixed_holiday_day IS NULL AND p_date_function_holiday IS NULL) OR
      (p_fixed_holiday_month IS NOT NULL AND p_fixed_holiday_day IS NOT NULL AND p_date_function_holiday IS NOT NULL) THEN
    RAISE fixed_or_function_holiday;
  END IF;

  IF p_fixed_holiday_month IS NOT NULL AND p_fixed_holiday_day IS NULL THEN
    RAISE fixed_day_not_selected;
  END IF;

  IF p_fixed_holiday_month IS NOT NULL AND p_fixed_holiday_day IS NOT NULL THEN
    SELECT COUNT(1)
    INTO n_count
    FROM calendar_recurring_holidays
    WHERE object_id = p_object_id
    AND fixed_holiday_month = p_fixed_holiday_month
    AND fixed_holiday_day = p_fixed_holiday_day;

    IF n_count > 1 THEN
      RAISE fixed_holiday_exists;
    END IF;
  END IF;

  IF p_date_function_holiday IS NOT NULL THEN
    SELECT COUNT(1)
    INTO n_count
    FROM calendar_recurring_holidays
    WHERE object_id = p_object_id
    AND date_function_holiday = p_date_function_holiday;

    IF n_count > 1 THEN
      RAISE date_func_holiday_exists;
    END IF;
  END IF;

EXCEPTION
  WHEN fixed_or_function_holiday THEN
    Raise_Application_Error(-20001,'Please select either Fixed Holiday Month/Day OR Date Function as a Recurring Holiday.');
  WHEN fixed_day_not_selected THEN
    Raise_Application_Error(-20002,'Please select a Day for Fixed Holiday Month '|| ec_prosty_codes.code_text(p_fixed_holiday_month,'CALENDAR_MONTHS'));
  WHEN fixed_holiday_exists THEN
    Raise_Application_Error(-20003,'Fixed Holiday ''' || ec_prosty_codes.code_text(p_fixed_holiday_month,'CALENDAR_MONTHS') || '-' || p_fixed_holiday_day || ''' already exists for calendar ' || ec_calendar.object_code(p_object_id));
  WHEN date_func_holiday_exists THEN
    Raise_Application_Error(-20004,'Date Function Holiday ''' || ec_prosty_codes.code_text(p_date_function_holiday,'CAL_RECUR_HOLIDAY_FUNC') || ''' already exists for calendar ' || ec_calendar.object_code(p_object_id));
END ValidateCalRecurringHoliday;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function       : CopyCalendarColl
-- Description    : Copy Calendar Collection object and its related linked data to new
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION copyCalendarColl(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)

RETURN VARCHAR2

IS
  ld_calendar_start_date DATE := ec_calendar_collection.start_date(p_object_id);
  ld_calendar_end_date DATE := ec_calendar_collection.end_date(p_object_id);

  no_date_arguments  EXCEPTION;
  start_date_out_of_timespan EXCEPTION;
  invalid_new_dates EXCEPTION;

  lv2_default_code      VARCHAR2(100) := p_code||'_COPY';
  lv2_object_id         calendar_collection.object_id%TYPE;
  lrec_calendar_coll    calendar_collection%ROWTYPE;
  lrec_cal_coll_version calendar_coll_version%ROWTYPE;
  lrec_cal_coll_setup   calendar_coll_setup%ROWTYPE;
  lv_end_user_message   VARCHAR2(1024);

  CURSOR c_calcoll(cp_calcol_id VARCHAR2) IS
  SELECT object_id,calendar_collection_id
  FROM calendar_coll_setup cs
  WHERE cs.calendar_collection_id = cp_calcol_id
  ORDER BY daytime ASC;

BEGIN

   -- Not allowed to continue if start date is not passed from the business function
   IF p_new_startdate IS NULL THEN
     RAISE no_date_arguments;
   END IF;

   -- check that the new start date is within the copied calendar_collection lifespan
   IF p_new_startdate <  ld_calendar_start_date OR p_new_startdate >= ld_calendar_end_date then
     RAISE start_date_out_of_timespan;
   END IF;

   --new object dates should not be the same
   IF p_new_startdate >= p_new_enddate THEN
     RAISE invalid_new_dates;
   END IF;

   -- Resetting these variables to be the new calendar_collection' start date and end date
   ld_calendar_start_date := p_new_startdate;
   ld_calendar_end_date := p_new_enddate;

   lv2_default_code := Ecdp_Object_Copy.GetCopyObjectCode('CALENDAR_COLLECTION',lv2_default_code);

   lrec_calendar_coll := ec_calendar_collection.row_by_object_id(p_object_id);

   -- Insert new calendar_collection record
   INSERT INTO calendar_collection
              (object_code,
              start_date,
              end_date,
              created_by)
   VALUES (lv2_default_code,
           p_new_startdate,
           p_new_enddate,
           p_user)
   RETURNING object_id INTO lv2_object_id;

   -- Update new calendar_collection record
   UPDATE calendar_collection
      SET description     = lrec_calendar_coll.description,
          last_updated_by = p_user
    WHERE object_id = lv2_object_id;

   lrec_cal_coll_version := ec_calendar_coll_version.row_by_pk(p_object_id, ld_calendar_start_date,'<=');

   -- Insert new calendar_collection version record
   INSERT INTO calendar_coll_version
               (object_id,
                daytime,
                end_date,
                created_by)
   VALUES (lv2_object_id,
           p_new_startdate,
           p_new_enddate,
           p_user);

   -- Update new calendar_collection version record
   UPDATE calendar_coll_version
      SET name = lrec_cal_coll_version.name,
          comments = lrec_cal_coll_version.comments,
          last_updated_by = p_user
    WHERE object_id = lv2_object_id
      AND daytime = ld_calendar_start_date;



   FOR cur2 IN c_calcoll(p_object_id) LOOP

        lrec_cal_coll_setup := ec_calendar_coll_setup.row_by_pk(cur2.object_id,cur2.calendar_collection_id, ld_calendar_start_date,'<=');
        lrec_cal_coll_setup.object_id := cur2.object_id;
        lrec_cal_coll_setup.calendar_collection_id := lv2_object_id;
        lrec_cal_coll_setup.daytime := ld_calendar_start_date;
        lrec_cal_coll_setup.record_status := NULL;
        lrec_cal_coll_setup.created_by := Nvl(EcDp_Context.getAppUser,User);
        lrec_cal_coll_setup.last_updated_by :=NULL;
        lrec_cal_coll_setup.last_updated_date :=NULL;
        lrec_cal_coll_setup.rev_no :=NULL;
        lrec_cal_coll_setup.rev_text :=NULL;
        lrec_cal_coll_setup.approval_state :=NULL;
        lrec_cal_coll_setup.approval_by :=NULL;
        lrec_cal_coll_setup.approval_date :=NULL;
        lrec_cal_coll_setup.rec_id := SYS_GUID();

        INSERT INTO calendar_coll_setup VALUES lrec_cal_coll_setup;
   END LOOP;

   lv_end_user_message := 'Success!' || chr(10) || 'Calendar Collection ''' || ec_calendar_collection.object_code(lv2_object_id) || ''' starting from ''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' is created.';
   RETURN lv_end_user_message;

EXCEPTION
  WHEN start_date_out_of_timespan THEN
    lv_end_user_message := 'Error!' || chr(10) || 'New Start Date:''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' must be within the selected calendar collection''s time span';
    RETURN lv_end_user_message;
  WHEN invalid_new_dates THEN
    lv_end_user_message := 'Error!' || chr(10) || 'New Start Date:''' || to_char(p_new_startdate,'yyyy-mm-dd') || ''' should not be the same as New End Date:''' || to_char(p_new_enddate,'yyyy-mm-dd') || '''';
    RETURN lv_end_user_message;
  WHEN no_date_arguments THEN
    lv_end_user_message := 'Error!' || chr(10) || 'Start date is missing';
    RETURN lv_end_user_message;


END copyCalendarColl;

-------------------------------------------------------------------------------------------------
-- Function      : GetEasterSunday
-- Description   : Determines date of Easter Sunday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetEasterSunday(p_year INTEGER)
RETURN DATE
IS
  AA INTEGER DEFAULT MOD(p_year, 19);                          -- A=YEAR%19
  BB INTEGER DEFAULT FLOOR(p_year / 100);                      -- B=YEAR/100
  CC INTEGER DEFAULT MOD(p_year, 100);                         -- C=YEAR%100
  DD INTEGER DEFAULT FLOOR(BB / 4);                            -- D=B/4
  EE INTEGER DEFAULT MOD(BB, 4);                               -- E=B%4
  FF INTEGER DEFAULT FLOOR((BB + 8) / 25);                     -- F=(B+8)/25
  GG INTEGER DEFAULT FLOOR((BB - FF + 1) / 3);                 -- G=(B-F+1)/3
  HH INTEGER DEFAULT MOD((19 * AA + BB - DD - GG + 15), 30);   -- H=(19*A+B-D-G+15)%30
  II INTEGER DEFAULT FLOOR(CC / 4);                            -- I=C/4
  KK INTEGER DEFAULT MOD(CC, 4);                               -- K=C%4
  LL INTEGER DEFAULT MOD((32 + 2 * EE + 2 * II - HH - KK), 7); -- L=(32+2*E+2*I-H-K)%7
  MM INTEGER DEFAULT FLOOR((AA + 11 * HH + 22 * LL) / 451);    -- M=(A+11*H+22*L)/451
  NN INTEGER DEFAULT FLOOR((HH + LL - 7 * MM + 114) / 31);     -- N=(H+L-7*M+114)/31
  OO INTEGER DEFAULT MOD((HH + LL - 7 * MM + 114), 31);        -- O=(H+L-7*M+114)%31
  EM INTEGER;                                                  -- Easter month [3, 4]
  ED INTEGER;                                                  -- Easter date (within the month)

BEGIN
  EM := NN; -- Easter Month [3=March, 4=April]
  ED := OO + 1;

  RETURN to_date(ED || '.' || EM || '.' || p_year, 'dd.mm.yyyy');
END GetEasterSunday;

-------------------------------------------------------------------------------------------------
-- Function      : GetEasterMonday
-- Description   : Determines date of Easter Monday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetEasterMonday(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) + 1;
END GetEasterMonday;

-------------------------------------------------------------------------------------------------
-- Function      : GetMaundyThursday
-- Description   : Determines date of Maundy Thursday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetMaundyThursday(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) - 3;
END GetMaundyThursday;

-------------------------------------------------------------------------------------------------
-- Function      : GetGoodFriday
-- Description   : Determines date of Good Friday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetGoodFriday(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) - 2;
END GetGoodFriday;

-------------------------------------------------------------------------------------------------
-- Function      : GetWhitSunday
-- Description   : Determines date of Whit Sunday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetWhitSunday(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) + 49;
END GetWhitSunday;

-------------------------------------------------------------------------------------------------
-- Function      : GetWhitMonday
-- Description   : Determines date of Whit Monday for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetWhitMonday(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) + 50;
END GetWhitMonday;

-------------------------------------------------------------------------------------------------
-- Function      : GetAscensionDay
-- Description   : Determines date of  Ascension Day for the year
-------------------------------------------------------------------------------------------------
FUNCTION GetAscensionDay(p_year INTEGER)
RETURN DATE
IS
BEGIN
  RETURN GetEasterSunday(p_year) + 39;
END GetAscensionDay;

-------------------------------------------------------------------------------------------------
-- Function      : IsLeapYear
-- Description   : Determines whether the year is a Leap year or not
-------------------------------------------------------------------------------------------------
FUNCTION IsLeapYear(p_year IN NUMBER)
RETURN VARCHAR2
IS
BEGIN

  IF TO_CHAR(LAST_DAY(TO_DATE('01-FEB-'||p_year, 'DD-MON-YYYY')), 'DD') = 29 THEN
    RETURN 'TRUE'; -- leap year
  ELSE
    RETURN 'FALSE'; -- not a leap year
  END IF;

END IsLeapYear;

-------------------------------------------------------------------------------------------------
-- Function      : GetFunctionHolidayDate
-- Description   : Retrieves the date of a specified Date Function holiday for the Calendar year
-------------------------------------------------------------------------------------------------
FUNCTION GetFunctionHolidayDate(p_date_function VARCHAR2, p_year NUMBER)
RETURN DATE
IS
  d_holiday_date  DATE;
  v_sql_statement VARCHAR2(500);
BEGIN
  v_sql_statement := 'SELECT '|| 'EcDp_Calendar.' ||p_date_function|| '(''' || p_year ||''') FROM DUAL' ;

  EXECUTE IMMEDIATE v_sql_statement INTO d_holiday_date;
  RETURN d_holiday_date;

END GetFunctionHolidayDate;
-------------------------------------------------------------------------------------------------

FUNCTION SetToBusinessDay(p_object_id     VARCHAR2,
                          p_daytime       DATE,
                          p_selected_date DATE,
                          p_cal_year      DATE,
                          p_user          VARCHAR2
                      ) RETURN VARCHAR2
IS

  ln_year                NUMBER;
  lv_holiday             calendar_day.holiday_ind%TYPE;
  lv_message             VARCHAR2(1024);
  not_calendar_year      EXCEPTION;
  already_a_business_day EXCEPTION;

BEGIN

  IF nvl(p_selected_date, to_date('1900-01-01','yyyy-mm-dd')) NOT BETWEEN TRUNC(p_cal_year, 'YEAR') AND ADD_MONTHS(TRUNC(p_cal_year, 'YEAR'), 12) - 1 THEN
    RAISE not_calendar_year;
  END IF;

  SELECT d.holiday_ind
    INTO lv_holiday
    FROM calendar_day d
   WHERE d.object_id = p_object_id
     AND d.daytime = p_selected_date;

  IF lv_holiday = 'Y' THEN
    UPDATE calendar_day d
       SET holiday_ind = 'N',
           d.last_updated_by = p_user,
           d.last_updated_date = ecdp_date_time.getCurrentSysdate
     WHERE object_id = p_object_id
     AND daytime = p_selected_date;
  ELSE
    RAISE already_a_business_day;
  END IF;

  RETURN '';

EXCEPTION
  WHEN not_calendar_year THEN
    lv_message := '[ErrMsg]Please select a date within year ' || EXTRACT( YEAR FROM p_cal_year) || '.';
    RETURN lv_message;
  WHEN already_a_business_day THEN
    lv_message := '[ErrMsg]' || TO_CHAR(p_selected_date,'yyyy-mm-dd') || ' is already a business day.';
    RETURN lv_message;

END SetToBusinessDay;

-------------------------------------------------------------------------------------------------

FUNCTION SetToHoliday(p_object_id     VARCHAR2,
                      p_daytime       DATE,
                      p_selected_date DATE,
                      p_cal_year      DATE,
                      p_user          VARCHAR2
                      ) RETURN VARCHAR2
IS

  ln_year                NUMBER;
  lv_holiday             calendar_day.holiday_ind%TYPE;
  lv_message             VARCHAR2(1024);
  not_calendar_year      EXCEPTION;
  already_a_holiday      EXCEPTION;

BEGIN

  IF nvl(p_selected_date, to_date('1900-01-01','yyyy-mm-dd')) NOT BETWEEN TRUNC(p_cal_year, 'YEAR') AND ADD_MONTHS(TRUNC(p_cal_year, 'YEAR'), 12) - 1 THEN
    RAISE not_calendar_year;
  END IF;

  SELECT d.holiday_ind
    INTO lv_holiday
    FROM calendar_day d
   WHERE d.object_id = p_object_id
     AND d.daytime = p_selected_date;

  IF lv_holiday = 'N' THEN
    UPDATE calendar_day d
       SET holiday_ind = 'Y',
           d.last_updated_by = p_user,
           d.last_updated_date = ecdp_date_time.getCurrentSysdate
     WHERE object_id = p_object_id
     AND daytime = p_selected_date;
  ELSE
    RAISE already_a_holiday;
  END IF;

  RETURN '';

EXCEPTION
  WHEN not_calendar_year THEN
    lv_message := '[ErrMsg]Please select a date within year ' || EXTRACT( YEAR FROM p_cal_year) || '.';
    RETURN lv_message;
  WHEN already_a_holiday THEN
    lv_message := '[ErrMsg]' || TO_CHAR(p_selected_date,'yyyy-mm-dd') || ' is already a Holiday.';
    RETURN lv_message;

END SetToHoliday;

-------------------------------------------------------------------------------------------------

FUNCTION GetLatestGeneratedYear(p_object_id VARCHAR2)
RETURN VARCHAR2
IS
  ld_date calendar_day.year%TYPE;
BEGIN

  SELECT MAX(year)
    INTO ld_date
    FROM calendar_day
   WHERE object_id = p_object_id
  GROUP BY object_id;

  RETURN ld_date;

END GetLatestGeneratedYear;

-------------------------------------------------------------------------------------------------

FUNCTION GetLatestGeneratedYearDaytime(p_object_id VARCHAR2)
RETURN DATE
IS
  ld_date calendar_day.daytime%TYPE;

BEGIN

  SELECT TRUNC(MAX(daytime), 'YEAR')
    INTO ld_date
    FROM calendar_day
   WHERE object_id = p_object_id
  GROUP BY object_id;

  RETURN ld_date;

END GetLatestGeneratedYearDaytime;

-------------------------------------------------------------------------------------------------

PROCEDURE ValidateCommentDate(p_object_id      VARCHAR2,
                              p_selected_date  DATE,
                              p_comment_date   DATE
                            )
IS
  lv_message         VARCHAR2(1000);
  not_calendar_year  EXCEPTION;

BEGIN

  IF EXTRACT(YEAR FROM p_selected_date) != EXTRACT(YEAR FROM p_comment_date) THEN
    RAISE not_calendar_year;
  END IF;

EXCEPTION
  WHEN not_calendar_year THEN
    lv_message := 'Please select a date within year ' || EXTRACT(YEAR FROM p_selected_date);
    Raise_Application_Error(-20000, lv_message);

END ValidateCommentDate;

-------------------------------------------------------------------------------------------------

FUNCTION getCurrentYearDaytime(p_object_id VARCHAR2,
                               p_daytime   DATE,
                               p_task      VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_current(cp_object_id varchar2, cp_daytime date) IS
        SELECT *
        FROM (
            SELECT year, daytime
            FROM tv_calendar_year
            WHERE object_id = cp_object_id
            AND daytime <= cp_daytime
            ORDER BY daytime DESC)
        WHERE rownum <= 1;

    CURSOR c_first(cp_object_id varchar2) IS
        SELECT *
        FROM (
            SELECT year, daytime
            FROM tv_calendar_year
            WHERE object_id = cp_object_id
            ORDER BY daytime ASC)
        WHERE rownum <= 1;

    lv_ReturnValue VARCHAR2(30) := '';
BEGIN
    -- Step 1/2: Get current year and daytime.
    FOR cRow IN c_current(p_object_id, p_daytime) LOOP
        IF p_task = 'YEAR' THEN
            lv_ReturnValue := cRow.Year;
        ELSIF p_task = 'DAYTIME' THEN
            lv_ReturnValue := to_char(cRow.DayTime, 'YYYY-MM-DD"T"HH24:MI:SS');
        END IF;
    END LOOP;

    -- Step 2/2: If no hit, get the first year and daytime.
    IF (nvl(lv_ReturnValue,'NULL') = 'NULL') THEN
        FOR cRow IN c_first(p_object_id) LOOP
            IF p_task = 'YEAR' THEN
                lv_ReturnValue := cRow.Year;
            ELSIF p_task = 'DAYTIME' THEN
                lv_ReturnValue := to_char(cRow.DayTime, 'YYYY-MM-DD"T"HH24:MI:SS');
            END IF;
        END LOOP;
    END IF;

    RETURN lv_ReturnValue;
END getCurrentYearDaytime;

-------------------------------------------------------------------------------------------------

FUNCTION CreateComment(p_object_id VARCHAR2,
                       p_daytime   VARCHAR2,
                       p_comment   VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_current(cp_object_id varchar2, cp_daytime date) IS
        SELECT *
        FROM calendar_day_comment
        WHERE object_id = cp_object_id
        AND daytime = cp_daytime;

    lv_return_value       VARCHAR2(500) := '';
    lv_comment_exists_ind VARCHAR2(1) := 'N';
    ld_daytime            DATE;
BEGIN
    IF (nvl(p_daytime,'$NULL$') != '$NULL$') THEN
        -- Resolve the given date.
        ld_daytime := to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

        -- Check if a comment exists on the given date.
        FOR cRow IN c_current(p_object_id, ld_daytime) LOOP
            lv_comment_exists_ind := 'Y';
        END LOOP;
    END IF;

    IF (nvl(p_daytime,'$NULL$') = '$NULL$') THEN
        -- A date is mandatory.
        lv_return_value := '[ErrMsg]Please select a date.';
    ELSIF lv_comment_exists_ind = 'Y' THEN
        -- A comment already exists on given date.
        lv_return_value := '[ErrMsg]The selected date has already a ''Holidays and Observances'' entry.\nPlease make any changes needed in the section below the Calendar.';
    ELSIF (nvl(p_comment,'$NULL$') = '$NULL$') THEN
        -- A comment is mandatory.
        lv_return_value := '[ErrMsg]Please enter a comment.';
    ELSE
        -- Insert a new comment.
        INSERT INTO TV_CALENDAR_DAY_COMMENT (object_id, daytime, comments)
        VALUES (p_object_id, ld_daytime, p_comment);
    END IF;

    RETURN lv_return_value;
END;

-------------------------------------------------------------------------------------------------

END EcDp_Calendar;