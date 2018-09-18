CREATE OR REPLACE PACKAGE BODY ecdp_scheduler IS
/****************************************************************
** Package        :  EcDp_Client_Schedulere
**
** $Revision: 1.21 $
**
** Purpose        :  Functions used to Deal with the Scheduler
**
** Documentation  :
**
** Created        :  08.12.2005  Micah Rupersburg
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
   21-12-2005  Rupermic  Changed timezone lookup to come from T_PREFERANSE
   28-12-2005  Rupermic   Changed Syntax for Complex Schedule type in Month and DOM
   28-12-2005  Rupermic  Changed Schedule Type detection
   06-01-2006  Rupermic   Added PAUSED_BLOCKED '' and null to list to determine if a schedule is disabled and added isJobExecuting
   09-01-2006  Rupermic   Added EXPIRED to triggerStatus when it would otherwise return null
   09-01-2006  Rupermic   Added Check for enabled in statusOrPinStatus
******************************************************************/

-- 1 based indexing
CRON_SEC_INDEX constant INTEGER := 1;
CRON_MIN_INDEX constant INTEGER := 2;
CRON_HOUR_INDEX constant INTEGER := 3;
CRON_DOM_INDEX constant INTEGER := 4;
CRON_MONTH_INDEX constant INTEGER := 5;
CRON_DOW_INDEX constant INTEGER := 6;
CRON_YEAR_INDEX constant INTEGER := 7;

SCHED_TYPE_DAILY constant VARCHAR2(10) := 'DAILY';
SCHED_TYPE_WEEKLY constant VARCHAR2(10) := 'WEEKLY';
SCHED_TYPE_MONTHLY constant VARCHAR2(10) := 'MONTHLY';
SCHED_TYPE_COMPLEX constant VARCHAR2(10) := 'COMPLEX';
SCHED_TYPE_CRON constant VARCHAR2(10) := 'CRON';
SCHED_TYPE_ONCE constant VARCHAR2(10) := 'ONCE';

SCHEDULE_PIN_TO CONSTANT VARCHAR(30) := 'EC_SCHEDULE_PIN_TO';


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPinnedToNode
-- Description    : Gets the value of the current pinning
--
---------------------------------------------------------------------------------------------------
FUNCTION getPinnedToNode RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN EcDp_User_Session.getUserSessionParameter(SCHEDULE_PIN_TO);
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : statusOrPinStatus
-- Description    : Returns 'PAUSED' if the schedule is pinned to another node(or partition), Otherwise the real status
--
---------------------------------------------------------------------------------------------------
FUNCTION statusOrPinStatus(sNAME VARCHAR2, sgroup VARCHAR2, realStatus VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  ret VARCHAR2(100);
  CURSOR c_col_val IS
    SELECT pin_to pin, EcDp_User_Session.getUserSessionParameter(SCHEDULE_PIN_TO) sess, enabled_ind en
    FROM schedule
    WHERE ((sname = NAME) OR (sname like NAME || '--!##RERUN##!%'))
    AND schedule_group = sgroup;
BEGIN
  ret := 'PAUSED';
  FOR cur_row IN c_col_val LOOP
    IF(cur_row.pin = cur_row.sess) THEN
      ret := realStatus;
    END IF;
    IF(cur_row.en != 'Y') THEN
      ret := 'PAUSED';
    END IF;
  END LOOP;
  RETURN ret;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isJobExecuting
-- Description    : Gets the Whether or not the job is currrently executing
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isJobExecuting(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT state col
   FROM qrtz_fired_triggers
  WHERE trigger_name = NAME AND trigger_group = sgroup AND  state = 'EXECUTING';
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;

IF(v_return_val = 'EXECUTING') THEN
  RETURN 'Y';
END IF;
  RETURN 'N';

END;
/*
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : FiredStatus
-- Description    : Gets the State from the qrtz_fired_triggers table
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION FiredStatus(NAME VARCHAR2, sgroup VARCHAR2, firetime DATE) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT state col
   FROM qrtz_fired_triggers
  WHERE job_name = NAME AND job_group = sgroup AND ecdp_scheduler.QuartLongTimeToDate(fired_time) = firetime;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
RETURN v_return_val;
END;
*/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ScheduleType
-- Description    : Figures out the schedule type for the given cron expression
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: CronPart
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION ScheduleType(cron VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
IF(cron IS NULL) THEN
  RETURN SCHED_TYPE_ONCE;
END IF;

/*
IF(INSTR(cron, '/') != 0) THEN RETURN '1'; END IF;
IF(INSTR(cron, '#') != 0 ) THEN RETURN '2'; END IF;
IF(INSTR(cron, 'L') != 0 ) THEN RETURN '3'; END IF;
IF(INSTR(cron, '-') != 0 ) THEN RETURN '4'; END IF;
IF(INSTR(cron, '#') != 0 ) THEN RETURN '5'; END IF;
*/

IF(INSTR(cron, '/') != 0
  OR   INSTR(cron, '#') != 0
  OR   INSTR(cron, 'L') != 0
  OR   INSTR(cron, '-') != 0
  OR  CronPart(cron, CRON_SEC_INDEX) != '0'
  OR (CronPart(cron, CRON_YEAR_INDEX) != '*'
    AND CronPart(cron, CRON_YEAR_INDEX) IS NOT NULL
    )
) THEN

RETURN SCHED_TYPE_CRON;
END IF;
/*
IF(CronPart(cron, CRON_MIN_INDEX) = '*'
  OR CronPart(cron, CRON_HOUR_INDEX) = '*'
) THEN
  RETURN SCHED_TYPE_COMPLEX;
END IF;
*/
IF(CronPart(cron, CRON_DOW_INDEX) = '*'
AND CronPart(cron, CRON_DOM_INDEX) = '?'
AND  CronPart(cron, CRON_MONTH_INDEX) = '*'
) THEN
  RETURN SCHED_TYPE_DAILY;
END IF;

IF(CronPart(cron, CRON_DOW_INDEX) != '*'
AND CronPart(cron, CRON_DOM_INDEX) = '?'
AND  CronPart(cron, CRON_MONTH_INDEX) = '*'
) THEN
  RETURN SCHED_TYPE_WEEKLY;
END IF;

IF(CronPart(cron, CRON_DOW_INDEX) = '?'
AND CronPart(cron, CRON_DOM_INDEX) != '*'
AND  CronPart(cron, CRON_MONTH_INDEX) = '*'
) THEN
  RETURN SCHED_TYPE_MONTHLY;
END IF;

RETURN SCHED_TYPE_COMPLEX;

END ScheduleType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CronPart
-- Description    : Returns the cron part given for the index,
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION CronPart(cronExpression VARCHAR2, part INTEGER) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
IF(cronExpression IS NULL OR part IS NULL) THEN
RETURN NULL;
END IF;
RETURN  SUBSTR(cronExpression,
CASE WHEN part = 1 THEN 1 ELSE (INSTR(cronExpression, ' ', 1, part -1) +1) END ,
INSTR(cronExpression, ' ', 1, part) -
CASE WHEN part = 1 THEN 1 ELSE INSTR(cronExpression, ' ', 1, part -1)  END
-1
);
END CronPart;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : QuartLongTimeToDate
-- Description    : Converts millis to a date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION QuartLongTimeToDate(longtime NUMBER) RETURN DATE
--</EC-DOC>
IS
BEGIN
IF(longtime = 0 OR longtime IS NULL) THEN
RETURN NULL;
END IF;
RETURN  --to_char(
to_date('01011970 00:00:00','ddmmyyyy HH24:MI:ss')
+ (longtime * (1/24/60/60/1000)); --,
--'YYYY-MM-DD HH24:MI:SS');
END QuartLongTimeToDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : QuartLongTimeToEcDate
-- Description    : Converts millis to a date and adds the timezone offset
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION QuartLongTimeToEcDate(longtime NUMBER) RETURN DATE
--</EC-DOC>
IS
BEGIN
IF(longtime = 0 OR longtime IS NULL) THEN
RETURN NULL;
END IF;
  RETURN DateToEcDate(QuartLongTimeToDate(longtime));
END QuartLongTimeToEcDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : DateToEcDate
-- Description    : Adds timezone offset to date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION DateToEcDate(theDate DATE) RETURN DATE
IS
--</EC-DOC>
CURSOR c_ts IS
  SELECT ECDP_DATE_TIME.getTZoffsetInDays(tz_offset(pref_verdi)) AS x FROM t_preferanse WHERE pref_id = 'TIME_ZONE_REGION';
  offset NUMBER;
BEGIN
    offset := 0;  -- Default value used if no valid entries found.
  FOR cur IN  c_ts LOOP
    offset := cur.x;
  END LOOP;
  RETURN theDate + (offset);
END DateToEcDate;

--These are all the same the just call CronPart with the appropriate index
FUNCTION CronPartMonth(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_MONTH_INDEX);
END;

FUNCTION CronPartSec(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_SEC_INDEX);
END;

FUNCTION CronPartMin(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_MIN_INDEX);
END;

FUNCTION CronPartDOW(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_DOW_INDEX);
END;

FUNCTION CronPartDOMDay(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartDOM(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;
  RETURN lv_result;
END;

FUNCTION CronPartDOM(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_DOM_INDEX);
END;

FUNCTION CronPartYear(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_YEAR_INDEX);
END;

FUNCTION CronPartHour(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
RETURN CronPart(cronexpression, CRON_HOUR_INDEX);
END;

FUNCTION CronPartSubDailyOp1(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
BEGIN

     lv_result:= CronPartSubDailyMin(cronexpression);
     IF lv_result='*' OR lv_result>0 THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartSubDailyOp2(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
     IF CronPartSubDailyOp1(cronExpression)='N' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartSubDailyMin(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartMin(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;
  RETURN lv_result;
END;

FUNCTION CronPartSubDailyHour(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartHour(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;
  RETURN lv_result;
END;

FUNCTION CronPartDailyOp1(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
  lv_return_value VARCHAR(1);

BEGIN

     lv_result:= CronPartDOMDay(cronexpression);

     IF lv_result='*'THEN
        RETURN 'Y';
     ELSIF lv_result='?' THEN
        RETURN 'N';
     ELSIF lv_result>0 THEN
        RETURN 'Y';
     END IF;
END;

FUNCTION CronPartDailyOp2(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
     IF CronPartDailyOp1(cronExpression)='N' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerDescription
-- Description    : Gets the description for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION TriggerDescription(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT description col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerCronExpression
-- Description    : Gets the Cron Expression for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerCronExpression(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT cron_expression col
   FROM qrtz_cron_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerStartDate
-- Description    : Gets the Start Date for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerStartDate(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE
IS
--</EC-DOC>
 return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT start_time col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      return_val := cur_row.col;
   END LOOP;
  RETURN QuartLongTimeToEcDate(return_val);
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerEndDate
-- Description    : Gets the End Date for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerEndDate(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE
--</EC-DOC>
IS
 return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT end_time col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      return_val := cur_row.col;
   END LOOP;
   RETURN QuartLongTimeToEcDate(return_val);
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTriggerEnabled
-- Description    : Gets the Whether or not the trigger is enabled
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isTriggerEnabled(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT trigger_state col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;

IF(v_return_val = 'PAUSED' or v_return_val = 'PAUSED_BLOCKED' or v_return_val is null) THEN
  RETURN 'N';
END IF;
  RETURN 'Y';

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerStatus
-- Description    : Gets the Status for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerStatus(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 v_return_val VARCHAR2(500);
   CURSOR c_col_val IS
   SELECT trigger_state col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   IF(v_return_val IS NULL) THEN
  RETURN 'EXPIRED';
END IF;
   RETURN v_return_val;
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isJobStateful
-- Description    : Gets the Whether or no the given job is stateful
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isJobStateful(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
 return_val NUMBER;
   CURSOR c_col_val IS
   SELECT is_stateful col
   FROM qrtz_job_details
WHERE job_name = NAME AND job_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      return_val := cur_row.col;
   END LOOP;

IF(return_val = 0) THEN
RETURN 'N';
END IF;
  RETURN 'Y';
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerScheduleType
-- Description    : Gets the Schedule type for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerScheduleType(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
RETURN ScheduleType(TriggerCronExpression(NAME, sgroup));
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TriggerNextFireTime
-- Description    : Gets the next Fire time for the given trigger
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION TriggerNextFireTime(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE
--</EC-DOC>
IS
return_val NUMBER;
   CURSOR c_col_val IS
   SELECT next_fire_Time col
   FROM qrtz_triggers
WHERE trigger_name = NAME AND trigger_group = sgroup;

BEGIN
   FOR cur_row IN c_col_val LOOP
      return_val := cur_row.col;
   END LOOP;
   RETURN QuartLongTimeToEcDate(return_val);
END;

--All these syntax functions do special logic for the given cron part
FUNCTION CronPartSyntaxMonth(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype ='COMPLEX') THEN
    RETURN 'viewhidden=true;viewrow=4;viewcol=2;viewgroup=2';
  END IF;
    RETURN 'viewhidden=true';
END;

FUNCTION CronPartSyntaxMin(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype = 'CRON' OR stype = 'ONCE') THEN
    RETURN 'viewhidden=true';
  END IF;
    RETURN 'viewhidden=false;viewrow=1;viewcol=2;viewgroup=2';
END;
FUNCTION CronPartSyntaxDOW(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype = 'COMPLEX' OR stype = 'WEEKLY') THEN
    RETURN 'viewhidden=false;viewrow=3;viewcol=2;viewgroup=2';
  END IF;
    RETURN 'viewhidden=true';
END;
FUNCTION CronPartSyntaxDOM(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype = 'MONTHLY') THEN
    RETURN 'viewhidden=false;viewrow=3;viewcol=2;viewgroup=2';
  END IF;
    RETURN 'viewhidden=true';
END;
FUNCTION CronPartSyntaxHour(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype = 'CRON' OR stype = 'ONCE') THEN
    RETURN 'viewhidden=true';
  END IF;
    RETURN 'viewhidden=false;viewrow=2;viewcol=2;viewgroup=2';
END;

FUNCTION CronExpressionSyntax(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  stype := ScheduleType(cronExpression);
  IF(stype = 'CRON') THEN
    RETURN 'viewrow=1;viewcol=2;viewgroup=2;viewhidden=false';
  END IF;
    RETURN 'viewhidden=true';
END;

FUNCTION ReadyToRun(p_shcedule_no NUMBER) RETURN VARCHAR2
IS
  ln_count_ai NUMBER;
BEGIN

   SELECT count(*) INTO ln_count_ai
   FROM tv_action_instance ai, tv_schedule s
   WHERE ai.SCHEDULE_NO = s.SCHEDULE_NO
--     AND s.START_DATE IS NOT NULL
     AND ai.SCHEDULE_NO = p_shcedule_no;

   IF ln_count_ai>0 THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
END;

FUNCTION getUniqueName(p_name VARCHAR) RETURN VARCHAR2
IS
 lv_name VARCHAR2(2000);
 ln_pos NUMBER;

BEGIN

   ln_pos := INSTR(p_name, '.AUTOGEN');

   IF ln_pos != 0 AND (ln_pos-15>0)THEN
      lv_name := SUBSTR(p_name,1,ln_pos-15);
   ELSE
      lv_name := p_name;
   END IF;

   RETURN lv_name;
END;


FUNCTION CronPartNthWeek(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);

BEGIN
   lv_result := CronPartDOW(cronExpression);

   IF InStr(lv_result,'/')>0 THEN
      return substr(lv_result,1,InStr(lv_result,'/')-1);
   ELSE
      RETURN '?';
   END IF;
END;
FUNCTION CronPartSyntaxNthWeek(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN 'viewhidden=false;viewrow=1;viewcol=1;viewgroup=2';
END;

FUNCTION CronPartMonday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);

BEGIN

   ln_index := InStr(cronExpression,'MON');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/2';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxMonday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=2;viewcol=1;viewgroup=2';
END;


FUNCTION CronPartTuesday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'TUE');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/3';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxTuesday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=2;viewcol=2;viewgroup=2';
END;

FUNCTION CronPartWednesday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'WED');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/4';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxWednesday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=2;viewcol=3;viewgroup=2';
END;

FUNCTION CronPartThursday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'THU');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/5';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxThursday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=2;viewcol=4;viewgroup=2';
END;

FUNCTION CronPartFriday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'FRI');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/6';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxFriday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=3;viewcol=1;viewgroup=2';
END;

FUNCTION CronPartSaturday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'SAT');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      lv_result := CronPartNthWeek(cronExpression) || '/7';

      IF (InStr(cronExpression,lv_result)>0) THEN
            RETURN 'Y';
      ELSE
            RETURN 'N';
      END IF;
   END IF;
END;
FUNCTION CronPartSyntaxSaturday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=3;viewcol=2;viewgroup=2';
END;

FUNCTION CronPartSunday(cronExpression VARCHAR2) RETURN VARCHAR2
IS

  ln_index NUMBER;
  lv_result VARCHAR2(32);
BEGIN
   ln_index := InStr(cronExpression,'SUN');

   IF (ln_index>0) THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
END;
FUNCTION CronPartSyntaxSunday(cronExpression VARCHAR2) RETURN VARCHAR2
IS
stype VARCHAR(50);

BEGIN
  RETURN 'viewhidden=false;viewrow=3;viewcol=3;viewgroup=2';
END;

FUNCTION CronPartMonthlyOp1(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
BEGIN

     lv_result:= CronPartDOMDay(cronexpression);
     IF lv_result<>'?' and lv_result>0 THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartMonthlyOp2(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
     IF CronPartDailyOp1(cronExpression)='N' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartMonthlyDay(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartDOM(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;
  RETURN lv_result;
END;

FUNCTION CronPartMonthlyEveryMonth(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartMonth(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;
  RETURN lv_result;
END;

FUNCTION CronPartMonthlyWeekDay(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
  lv_weekday VARCHAR2(10);

BEGIN
  lv_result:= CronPartDow(cronexpression);

  IF InStr(lv_result,'#')>0 THEN
     lv_result := substr(lv_result,1,InStr(lv_result,'#')-1);
  END IF;

  CASE  lv_result
  WHEN  '1' THEN lv_weekday := 'SUNDAY';
  WHEN  '2' THEN lv_weekday := 'MONDAY';
  WHEN  '3' THEN lv_weekday := 'TUESDAY';
  WHEN  '4' THEN lv_weekday := 'WEDNESDAY';
  WHEN  '5' THEN lv_weekday := 'THURSDAY';
  WHEN  '6' THEN lv_weekday := 'FRIDAY';
  WHEN  '7' THEN lv_weekday := 'SATURDAY';
  ELSE
        lv_weekday := 'MONDAY';
  END CASE;

  RETURN lv_weekday;
END;

FUNCTION CronPartMonthlyDayRecurring(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
  lv_day_recurring VARCHAR2(10);

BEGIN
  lv_result:= CronPartDow(cronexpression);

  IF InStr(lv_result,'#')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'#')+1);
  ELSIF InStr(lv_result,'L')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'L'));
  END IF;

  CASE  lv_result
  WHEN  '1' THEN lv_day_recurring := 'FIRST';
  WHEN  '2' THEN lv_day_recurring := 'SECOND';
  WHEN  '3' THEN lv_day_recurring := 'THIRD';
  WHEN  '4' THEN lv_day_recurring := 'FOURTH';
  WHEN  'L' THEN lv_day_recurring := 'LAST';
  ELSE
        lv_day_recurring := 'FIRST';
  END CASE;

  RETURN lv_day_recurring;
END;

FUNCTION CronPartMonthlyEveryMonthOp2(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN CronPartMonthlyEveryMonth(cronExpression);
END;


FUNCTION CronPartYearlyOp1(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
BEGIN

     lv_result:= CronPartDOMDay(cronexpression);
     IF lv_result<>'?' and lv_result>0 THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartYearlyOp2(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
     IF CronPartDailyOp1(cronExpression)='N' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION CronPartYearlyDay(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);

BEGIN
  lv_result:= CronPartMonthlyDay(cronexpression);
  RETURN lv_result;
END;

FUNCTION CronPartYearlyWeekDay(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
 RETURN CronPartMonthlyWeekDay(cronExpression);
END;

FUNCTION CronPartYearlyDayRecurring(cronExpression VARCHAR2) RETURN VARCHAR2
IS
BEGIN
 RETURN CronPartMonthlyDayRecurring(cronExpression);
END;

FUNCTION CronPartYearlyMonthRecurring(cronExpression VARCHAR2) RETURN VARCHAR2
IS
  lv_result VARCHAR2(10);
  lv_recurring VARCHAR2(10);

BEGIN
  lv_result:= CronPartMonth(cronexpression);

  IF InStr(lv_result,'/')>0 THEN
     lv_result := substr(lv_result,InStr(lv_result,'/')+1);
  END IF;

  CASE  lv_result
  WHEN  '1' THEN lv_recurring := 'JANUARY';
  WHEN  '2' THEN lv_recurring := 'FEBRUARY';
  WHEN  '3' THEN lv_recurring := 'MARCH';
  WHEN  '4' THEN lv_recurring := 'APRIL';
  WHEN  '5' THEN lv_recurring := 'MAY';
  WHEN  '6' THEN lv_recurring := 'JUNE';
  WHEN  '7' THEN lv_recurring := 'JULY';
  WHEN  '8' THEN lv_recurring := 'AUGUST';
  WHEN  '9' THEN lv_recurring := 'SEPTEMBER';
  WHEN  '10' THEN lv_recurring := 'OCTOBER';
  WHEN  '11' THEN lv_recurring := 'NOVEMBER';
  WHEN  '12' THEN lv_recurring := 'DECEMBER';
  ELSE
        lv_recurring := 'JANUARY';
  END CASE;

  RETURN lv_recurring;
END;
END ecdp_scheduler;