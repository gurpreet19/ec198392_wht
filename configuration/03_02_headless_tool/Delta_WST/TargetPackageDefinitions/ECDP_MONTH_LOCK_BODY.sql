CREATE OR REPLACE PACKAGE BODY EcDp_Month_Lock IS

/****************************************************************
** Package        :  EcDp_Month_Lock, body part
**
** $Revision: 1.12.32.1 $
**
** Purpose        :  Provides lock check methods and structures used by instead of triggers.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.12.2005  Arild Vervik
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  20-Nov-2008  oonnnng  Added localLockedMonthAffected, localWithinLockedMonth, localBuildIdentifierString,
                          localRaiseValidationError, localValidPeriodForLockOverlap, localCheckUpdateOfLDOForLock,
                          and localCheckUpdateEventForLock functions.
**  17-Feb-2009  oonnnng  Removed localValidPeriodForLockOverlap, localCheckUpdateOfLDOForLock,
                          and localCheckUpdateEventForLock functions.
                          Added 2 localLockCheck() function.
                          Add new parameter p_object_id to validatePeriodForLockOverlap, checkUpdateOfLDOForLock() and checkUpdateEventForLock() functions.
                          Modified checkUpdateOfLDOForLock() and checkUpdateEventForLock() functions.
**  10-Apr-2009  oonnnng  Update localLockCheck() function with return DATE.
**                        Change from using ec_ctrl_system_attribute to ecdp_ctrl_property.getSystemProperty function.
**  13-May-2015  deshpadi Modified lockedMonthAffected(), as it can also check the 1st date of the locked month.
****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isUpdating
-- Description    : This function decodes a boolean value to corresponding Y/N indicators.
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
FUNCTION isUpdating(p_updating BOOLEAN) RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
  IF p_updating THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addParameterToList
-- Description    : This procedure adds the given parameter to a internal list structure.
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
PROCEDURE addParameterToList(
    p_update_list       IN OUT  column_list,
    p_id                VARCHAR2,
    p_column_name       VARCHAR2,
    p_data_type         VARCHAR2,
    p_is_key            VARCHAR2,
    p_is_changed        VARCHAR2,
    p_column_data       ANYDATA
)
--</EC-DOC>
IS
  lv2_data_type VARCHAR(50);

BEGIN

    IF LTRIM(RTRIM(UPPER(p_data_type))) = 'DATE' THEN

       lv2_data_type := 'DATE';

    ELSIF  LTRIM(RTRIM(UPPER(p_data_type))) IN ('NUMBER','INTEGER') THEN

       lv2_data_type := 'NUMBER';

    ELSE

       lv2_data_type := 'VARCHAR2';

    END IF;


     IF p_column_name IS NOT NULL AND p_data_type IS NOT NULL THEN

       p_update_list(p_id).column_name  := p_column_name;
       p_update_list(p_id).data_type    := lv2_data_type;
       p_update_list(p_id).column_data  := p_column_data;
       p_update_list(p_id).is_key       := p_is_key;
       p_update_list(p_id).is_changed   := p_is_changed;

     END IF;

END addParameterToList;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : raiseValidationError
-- Description    : Raises an application error with an error message.
--
-- Preconditions  :
-- Postconditions : Exception state
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
PROCEDURE raiseValidationError(p_operation VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_locked_month DATE, p_id VARCHAR2)
--</EC-DOC>
IS

lv2_message_detail VARCHAR2(2000);

BEGIN

   lv2_message_detail := 'OPERATION: ' || p_operation ||
   '; PERIOD: [' || TO_CHAR(p_from_daytime,'DD-MON-YYYY') || ', ' || Nvl(TO_CHAR(p_to_daytime,'DD-MON-YYYY'),'-->') || ']; LOCKED_MONTH: ' ||
   TO_CHAR(p_locked_month,'MON-YYYY') || '; ID: ' || p_id;

   RAISE_APPLICATION_ERROR(-20112, lv2_message_detail);

END raiseValidationError;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : localRaiseValidationError (with p_object_id)
-- Description    : Raises an application error with an local lock error message.
--
-- Preconditions  :
-- Postconditions : Exception state
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
PROCEDURE localRaiseValidationError(p_object_id VARCHAR2, p_operation VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_locked_month DATE, p_id VARCHAR2)
--</EC-DOC>
IS

lv2_message_detail VARCHAR2(2000);

BEGIN

   lv2_message_detail := 'OPERATION: ' || p_operation ||
   '; PERIOD: [' || TO_CHAR(p_from_daytime,'DD-MON-YYYY') || ', ' || Nvl(TO_CHAR(p_to_daytime,'DD-MON-YYYY'),'-->') || ']; LOCAL LOCKED_MONTH: ' ||
   TO_CHAR(p_locked_month,'MON-YYYY') || '; ID: ' || p_id ;

   RAISE_APPLICATION_ERROR(-20124, lv2_message_detail);

END localRaiseValidationError;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Proecdure      : validatePeriodForLockOverlap
-- Description    : Validates if a given period overlaps a locked month and raises an application if that is the case.
--
-- Preconditions  :
-- Postconditions : Exception state
--
-- Using tables   :
--
-- Using functions: lockedMonthAffected, raiseValidationError
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in valid dates if they appear outside locked month and object_id
--                  To allow for global lock check only, use 'N/A' as the parameter value for p_object_id
--
---------------------------------------------------------------------------------------------------
PROCEDURE validatePeriodForLockOverlap(p_operation VARCHAR2,
                                       p_from_daytime DATE,
                                       p_to_daytime DATE,
                                       p_id VARCHAR2,
                                       p_object_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

ld_locked_month DATE;

BEGIN

   ld_locked_month := lockedMonthAffected(p_from_daytime, p_to_daytime);

   IF ld_locked_month IS NOT NULL THEN

      raiseValidationError(p_operation, p_from_daytime, p_to_daytime, ld_locked_month, p_id);

   END IF;

   Ecdp_Month_Lock.localLockCheck('lockedMonthAffected', p_object_id,
                                  p_from_daytime, p_to_daytime,
                                  p_operation, p_id);

END validatePeriodForLockOverlap;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : lockedMonthAffected
-- Description    :
--
-- Preconditions  : Checks whether the period provided by the input parameters affects a locked month.
-- Postconditions :
--
-- Using tables   : system_month
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the first day of month if affected.
--
---------------------------------------------------------------------------------------------------
FUNCTION lockedMonthAffected(p_from_daytime DATE, p_to_daytime DATE) RETURN DATE
--</EC-DOC>
IS

CURSOR c_locked(cp_from_daytime DATE, cp_to_daytime DATE) IS
SELECT daytime
FROM system_month
WHERE lock_ind = 'Y'
AND cp_from_daytime < last_day(daytime) + 1 AND Nvl(cp_to_daytime, daytime + 1) >= daytime
ORDER BY daytime
;

ld_lock DATE := NULL;

BEGIN

   FOR cur_rec IN c_locked(p_from_daytime, p_to_daytime) LOOP

      ld_lock := cur_rec.daytime;
      EXIT;  -- No need to loop further

   END LOOP;

   RETURN ld_lock;

END lockedMonthAffected;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : localLockedMonthAffected
-- Description    :
--
-- Preconditions  : Checks whether the period provided by the input parameters affects a local locked month.
-- Postconditions :
--
-- Using tables   : operational_lock
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the first day of month if affected.
--
---------------------------------------------------------------------------------------------------
FUNCTION localLockedMonthAffected(p_local_lock_level VARCHAR2, p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE) RETURN DATE
--</EC-DOC>
IS

   CURSOR c_local_locked(cp_local_lock_level VARCHAR2, cp_object_id VARCHAR2, cp_from_daytime DATE, cp_to_daytime DATE) IS
   SELECT daytime
   FROM operational_lock
   WHERE object_class = cp_local_lock_level
   AND object_id = cp_object_id
   AND lock_ind = 'Y'
   AND cp_from_daytime < last_day(daytime) + 1 AND Nvl(cp_to_daytime, daytime + 1) > daytime
   ORDER BY daytime;

   ld_lock DATE := NULL;

BEGIN

   FOR cur_rec IN c_local_locked(p_local_lock_level, p_object_id, p_from_daytime, p_to_daytime) LOOP

      ld_lock := cur_rec.daytime;
      EXIT;  -- No need to loop further

   END LOOP;

   RETURN ld_lock;

END localLockedMonthAffected;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : withinLockedMonth
-- Description    :
--
-- Preconditions  : Checks whether the timestamp provided is within a locked month.
-- Postconditions :
--
-- Using tables   : system_month
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION withinLockedMonth(p_daytime DATE) RETURN DATE
--</EC-DOC>
IS

CURSOR c_locked(cp_daytime DATE) IS
SELECT daytime
FROM system_month
WHERE lock_ind = 'Y'
AND daytime  = TRUNC(cp_daytime,'MONTH')
;

ld_lock DATE := NULL;

BEGIN

   FOR cur_rec IN c_locked(p_daytime) LOOP

      ld_lock := cur_rec.daytime;
      EXIT;  -- No need to loop further

   END LOOP;

   RETURN ld_lock;

END withinLockedMonth;


---------------------------------------------------------------------------------------------------
-- Function       : localWithinLockedMonth
-- Description    :
--
-- Preconditions  : Checks whether the timestamp provided is within a local locked month.
-- Postconditions :
--
-- Using tables   : operational_lock
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION localWithinLockedMonth(p_local_lock_level VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
--</EC-DOC>
IS

   CURSOR c_local_locked(cp_local_lock_level VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
   SELECT daytime
   FROM operational_lock
   WHERE object_class = cp_local_lock_level
   AND object_id=cp_object_id
   AND lock_ind = 'Y'
   AND daytime  = TRUNC(cp_daytime,'MONTH');

   ld_lock DATE := NULL;

BEGIN

   FOR cur_rec IN c_local_locked(p_local_lock_level, p_object_id, p_daytime) LOOP

      ld_lock := cur_rec.daytime;
      EXIT;  -- No need to loop further

   END LOOP;

   RETURN ld_lock;

END localWithinLockedMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkIfColumnsUpdated
-- Description    :
--
-- Preconditions  : Checks the old list of unchecked columns have updated columns indicated
--
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
FUNCTION checkIfColumnsUpdated(p_col_list EcDp_month_lock.column_list) RETURN BOOLEAN
--</EC-DOC>
IS

lv2_index VARCHAR2(64);
lb_changed BOOLEAN := FALSE;

BEGIN

   IF p_col_list.count > 0 THEN

      lv2_index := p_col_list.first;

      LOOP

         EXIT WHEN lv2_index IS NULL OR lb_changed;

         IF Nvl(p_col_list(lv2_index).is_checked,'N') <> 'Y' AND Nvl(p_col_list(lv2_index).is_changed,'N') = 'Y' THEN

            lb_changed := TRUE;

         END IF;

         lv2_index := p_col_list.next(lv2_index);

      END LOOP;

   END IF;

   RETURN lb_changed;

END checkIfColumnsUpdated;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : buildIdentifierString
-- Description    :
--
-- Preconditions  : Takes a column list and makes a string with primary key values (except dates) to
--                  present when locking raises application error
--
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
FUNCTION buildIdentifierString(p_col_list EcDp_month_lock.column_list) RETURN VARCHAR2
--</EC-DOC>
IS


  lv2_id     VARCHAR2(2000) ;
  lv2_index  VARCHAR2(30);

BEGIN


   lv2_id := 'CLASS_NAME: '||p_col_list('CLASS_NAME').column_name;
   lv2_index := p_col_list.first;  -- There should always be a t least one

   LOOP

     EXIT WHEN lv2_index IS NULL;

     IF Nvl(p_col_list(lv2_index).is_key,'N') = 'Y' AND p_col_list(lv2_index).data_type <> 'DATE' THEN

       IF p_col_list(lv2_index).data_type IN ('NUMBER','INTEGER') THEN

         lv2_id := lv2_id ||' ; ' ||lv2_index||': '||p_col_list(lv2_index).column_data.AccessNumber;

       ELSE  -- STRING

         IF RTRIM(p_col_list(lv2_index).column_name, '_ID') = p_col_list(lv2_index).column_name  THEN -- Not an internal ID

            lv2_id := lv2_id ||' ; ' ||lv2_index||': '|| p_col_list(lv2_index).column_data.AccessVarchar2;

         END IF;

       END IF;

     END IF;

     lv2_index := p_col_list.next(lv2_index);

   END LOOP;


   RETURN lv2_id;


END; -- buildIdentifierString


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : localBuildIdentifierString
-- Description    :
--
-- Preconditions  : Takes a column list and makes a string with primary key values (except dates) to
--                  present when locking raises application error
--
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
FUNCTION localBuildIdentifierString(p_obj_id VARCHAR2, p_msg VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_id     VARCHAR2(2000) ;

BEGIN

   lv2_id := p_obj_id || ' ' || p_msg;

   RETURN lv2_id;

END; -- localBuildIdentifierString


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkUpdateOfLDOForLock
-- Description    :
--
-- Preconditions  : Checks whether an update of a last dated cccurence record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: raiseValidationError, validatePeriodForLockOverlap, lockedMonthAffected
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in valid dates if they appear outside locked month.
--
-- Updating sample data is not allowed if the period of the current record and the trailing next record (if any)
-- overlap a locked month.
--
-- Updating VALID_FROM_DATE is not allowed if the following situations appear:
--
--   Current or the new date values are within a locked month. Except it should be possible to move the VALID_FROM_DATE for analysis 4 from early April to the 1st of May in order to make the analysis 3 valid throughout April.
--   The period of the new dated analysis and the next trailing analysis (if any) overlap another locked period.
--   The date transition on a locked period passes by a locked month. Moving analysis 3 to June is allowed, but not to move analysis 4 to June.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkUpdateOfLDOForLock(p_new_current_valid DATE,
                                  p_old_current_valid DATE,
                                  p_new_next_valid DATE,
                                  p_old_next_valid DATE,
                                  p_old_prev_valid DATE,
                                  p_columns_updated VARCHAR,
                                  p_id VARCHAR2,
                                  p_object_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

  ld_locked_month DATE;
  lv2_msg                      VARCHAR2(1000);
  lv2_parent_object_id         VARCHAR2(32);
  lv2_local_lock               VARCHAR2(32);
  lv2_class_name               VARCHAR2(32);
  ld_fromdate                  DATE;
  ld_todate                    DATE;
  ld_local_locked_month        DATE;

BEGIN

   IF p_old_current_valid IS NULL AND p_new_current_valid IS NOT NULL THEN

      validatePeriodForLockOverlap('UPDATING', p_new_current_valid, p_new_next_valid, p_id, p_object_id);

   ELSIF p_old_current_valid IS NOT NULL AND p_new_current_valid IS NULL THEN

      validatePeriodForLockOverlap('UPDATING', p_old_current_valid, p_old_next_valid, p_id, p_object_id);

   ELSIF p_new_current_valid = p_old_current_valid THEN -- Not updating daytime

      validatePeriodForLockOverlap('UPDATING', p_new_current_valid, p_new_next_valid, p_id, p_object_id);

   ELSE -- Validate date boundary change

      ld_locked_month := lockedMonthAffected(Least(p_old_current_valid, p_new_current_valid), Greatest(p_old_current_valid, p_new_current_valid));

      ld_local_locked_month := EcDp_Month_lock.localLockCheck('LockedMonthAffected', p_object_id,
                                                              Least(p_old_current_valid, p_new_current_valid), Greatest(p_old_current_valid, p_new_current_valid));

      IF ld_locked_month IS NOT NULL  OR ld_local_locked_month IS NOT NULL THEN

         -- Allow date transition through locked months if it was done from an unlocked period to another unlocked period

         IF lockedMonthAffected(p_old_current_valid, p_old_next_valid) IS NOT NULL OR
            lockedMonthAffected(p_new_current_valid, p_new_next_valid) IS NOT NULL THEN

            raiseValidationError('UPDATING', p_new_current_valid, p_new_next_valid, ld_locked_month, p_id);

         END IF;

         IF EcDp_Month_lock.localLockCheck('LockedMonthAffected', p_object_id, p_old_current_valid, p_old_next_valid) IS NOT NULL OR
            EcDp_Month_lock.localLockCheck('LockedMonthAffected', p_object_id, p_new_current_valid, p_new_next_valid) IS NOT NULL THEN

            EcDp_Month_lock.localRaiseValidationError(lv2_parent_object_id, 'UPDATING', p_new_current_valid, p_new_next_valid, ld_local_locked_month, lv2_msg);

         END IF;

      ELSE -- Check whether dates have been interchanged among locked periods.

         IF p_new_current_valid < p_old_current_valid THEN

            IF (p_new_current_valid <= p_old_prev_valid) THEN

               validatePeriodForLockOverlap('UPDATING', p_old_prev_valid, p_old_next_valid, p_id, p_object_id);

            END IF;

         ELSIF p_new_current_valid > p_old_current_valid THEN

            IF (p_new_current_valid >= p_old_next_valid) THEN

               validatePeriodForLockOverlap('UPDATING', p_new_current_valid, p_new_next_valid, p_id, p_object_id);

            END IF;

         END IF;

      END IF;

      ld_locked_month := lockedMonthAffected(p_old_current_valid, p_old_next_valid);

      IF p_columns_updated = 'Y' AND ld_locked_month IS NOT NULL THEN -- Not only updating valid date

         raiseValidationError('UPDATING', p_new_current_valid, p_new_next_valid, ld_locked_month, p_id);

      END IF;

      ld_local_locked_month := EcDp_Month_lock.localLockCheck('LockedMonthAffected', p_object_id, p_new_current_valid, p_new_next_valid);

      IF p_columns_updated = 'Y' AND ld_local_locked_month IS NOT NULL THEN -- Not only updating valid date
         lv2_msg := EcDp_Month_Lock.localbuildIdentifierString(p_object_id, p_id);

         EcDp_Month_lock.localRaiseValidationError(lv2_parent_object_id, 'UPDATING', ld_fromdate, ld_todate, ld_local_locked_month, lv2_msg);

      END IF;

   END IF;

END checkUpdateOfLDOForLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkUpdateEventForLock
-- Description    :
--
-- Preconditions  : Checks whether an update on an event based record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: raiseValidationError, validatePeriodForLockOverlap, lockedMonthAffected
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in date boundary changes if they appear outside locked month.
--                  Updating data is not allowed if the period of the current record overlap a locked month.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkUpdateEventForLock(p_new_daytime     DATE,
                                  p_old_daytime     DATE,
                                  p_new_end_date    DATE,
                                  p_old_end_date    DATE,
                                  p_columns_updated VARCHAR,
                                  p_id              VARCHAR2,
                                  p_object_id VARCHAR2 DEFAULT NULL)

IS

  ld_old_locked_month DATE;
  ld_old_end_date     DATE;
  ld_new_end_date     DATE;
  lv2_msg                      VARCHAR2(1000);
  lv2_parent_object_id         VARCHAR2(32);
  lv2_local_lock               VARCHAR2(32);
  lv2_class_name               VARCHAR2(32);
  ld_fromdate                  DATE;
  ld_todate                    DATE;
  ld_local_locked_month        DATE;
BEGIN

   IF p_old_daytime IS NULL AND p_new_daytime IS NOT NULL THEN -- Consider as insert

      EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', p_new_daytime, p_new_end_date, p_id, p_object_id);

   ELSIF p_new_daytime IS NULL AND p_old_daytime IS NOT NULL THEN -- Consider as delete

      EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', p_old_daytime, p_old_end_date, p_id, p_object_id);

   ELSE

      ld_old_end_date := Nvl(p_old_end_date, EcDp_System_Constants.FUTURE_DATE);
      ld_new_end_date := Nvl(p_new_end_date, EcDp_System_Constants.FUTURE_DATE);

      IF (p_new_daytime = p_old_daytime) AND (ld_old_end_date = ld_new_end_date) THEN -- Not updating date boundaries

         EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', p_new_daytime, ld_new_end_date, p_id, p_object_id);

      ELSE -- Validate date boundary change

         -- Allow date transition along the given event as long the dates changes involved is not within locked months

         IF p_old_daytime <> p_new_daytime THEN

            EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', Least(p_new_daytime, p_old_daytime), GREATEST(p_new_daytime, p_old_daytime), p_id, p_object_id);

         END IF;

         IF ld_old_end_date <> ld_new_end_date THEN

            EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', Least(ld_new_end_date, ld_old_end_date), GREATEST(ld_new_end_date, ld_old_end_date), p_id, p_object_id);

         END IF;

         ld_old_locked_month := EcDp_Month_Lock.lockedMonthAffected(p_old_daytime, ld_old_end_date);

         IF p_columns_updated = 'Y' AND ld_old_locked_month IS NOT NULL THEN -- Not only updating valid date

            EcDp_Month_Lock.raiseValidationError('UPDATING', p_new_daytime, ld_new_end_date, ld_old_locked_month, p_id);

         END IF;

         ld_local_locked_month := EcDp_Month_lock.localLockCheck('LockedMonthAffected', p_object_id, p_new_daytime, ld_new_end_date);

         IF p_columns_updated = 'Y' AND ld_local_locked_month IS NOT NULL THEN -- Not only updating valid date
            lv2_msg := EcDp_Month_Lock.localbuildIdentifierString(p_object_id, p_id);

            EcDp_Month_lock.localRaiseValidationError(lv2_parent_object_id, 'UPDATING', p_new_daytime, ld_new_end_date, ld_local_locked_month, lv2_msg);
         END IF;

      END IF;

   END IF;

END checkUpdateEventForLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : localLockCheck
-- Description    : Checks local lock
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Month_Lock.localValidPeriodForLockOverlap
--                  EcDp_Month_Lock.localLockedMonthAffected
--                  EcDp_Month_Lock.localWithinLockedMonth
--
-- Configuration
-- required       : p_call_func=VALIDPERIODFORLOCKOVERLAP /
--                  p_call_func=LOCKEDMONTHAFFECTED will call EcDp_Month_Lock.localLockedMonthAffected
--                  p_call_func=WITHINLOCKEDMONTH will call EcDp_Month_Lock.localWithinLockedMonth (p_todate is not being used )
--
-- Behaviour      :
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE localLockCheck( p_call_func    VARCHAR2,
                          p_object_id    VARCHAR2,
                          p_fromdate     DATE,
                          p_todate       DATE,
                          p_operation    VARCHAR2,
                          p_msg          VARCHAR2)
--</EC-DOC>
IS
  lv2_msg                      VARCHAR2(1000);
  lv2_parent_object_id         VARCHAR2(32);
  lv2_local_lock               VARCHAR2(32);
  lv2_class_name               VARCHAR2(32);
  ld_locked_month              DATE;

BEGIN

   lv2_msg := EcDp_Month_Lock.localbuildIdentifierString(p_object_id, p_msg);

   ld_locked_month := localLockCheck(p_call_func, p_object_id, p_fromdate, p_todate);

   IF ld_locked_month IS NOT NULL THEN
      CASE
         -- start p_call_func=LOCKEDMONTHAFFECTED /  p_call_func=VALIDPERIODFORLOCKOVERLAP
         WHEN UPPER(p_call_func) = UPPER('LockedMonthAffected') OR  UPPER(p_call_func) = UPPER('ValidPeriodForLockOverlap') THEN
            EcDp_Month_lock.localRaiseValidationError(lv2_parent_object_id, p_operation, p_fromdate, p_todate, ld_locked_month, lv2_msg);

         -- start p_call_func=WITHINLOCKEDMONTH
         WHEN UPPER(p_call_func) = UPPER('WithinLockedMonth') THEN
            EcDp_Month_lock.localRaiseValidationError(lv2_parent_object_id, p_operation, p_fromdate, p_fromdate, trunc(p_fromdate,'MONTH'), lv2_msg);

         ELSE
             RAISE_APPLICATION_ERROR('-20512', 'Keyword ' || p_call_func || ' not found when perform local lock.');

      END CASE;

   END IF;

END localLockCheck;


FUNCTION localLockCheck( p_call_func    VARCHAR2,
                          p_object_id    VARCHAR2,
                          p_fromdate     DATE,
                          p_todate       DATE)
RETURN DATE
--</EC-DOC>
IS
  lv2_msg                      VARCHAR2(1000);
  lv2_parent_object_id         VARCHAR2(32);
  lv2_local_lock               VARCHAR2(32);
  lv2_class_name               VARCHAR2(32);
  ld_locked_month              DATE;

BEGIN

   lv2_local_lock := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', p_fromdate);
   lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);

   IF upper(lv2_local_lock) <> upper(lv2_class_name) THEN
      lv2_parent_object_id := ecdp_groups.findParentObjectId(lv2_local_lock ,'operational',lv2_class_name,p_object_id,p_fromdate);
   END IF;

   IF lv2_parent_object_id IS NULL THEN
      lv2_parent_object_id := p_object_id;
   END IF;

   CASE
      -- start p_call_func=LOCKEDMONTHAFFECTED /  p_call_func=VALIDPERIODFORLOCKOVERLAP
      WHEN UPPER(p_call_func) = UPPER('LockedMonthAffected') OR  UPPER(p_call_func) = UPPER('ValidPeriodForLockOverlap') THEN
         IF p_object_id IS NULL THEN
           RAISE_APPLICATION_ERROR('-20000', 'Error please contact technical personell and refer to this message : Object Id cannot be blank, please rebuild the view layer.');
         END IF;

         ld_locked_month := EcDp_Month_lock.localLockedMonthAffected(lv2_local_lock, lv2_parent_object_id, p_fromdate, p_todate);

      -- start p_call_func=WITHINLOCKEDMONTH
      WHEN UPPER(p_call_func) = UPPER('WithinLockedMonth') THEN
         ld_locked_month := EcDp_Month_lock.localWithinLockedMonth(lv2_local_lock, lv2_parent_object_id, p_fromdate);

      ELSE
          RAISE_APPLICATION_ERROR('-20512', 'Keyword ' || p_call_func || ' not found when perform local lock.');

   END CASE;

   RETURN ld_locked_month;

END localLockCheck;


END EcDp_Month_Lock;