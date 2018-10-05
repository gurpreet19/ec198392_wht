CREATE OR REPLACE PACKAGE BODY EcBp_Shift IS
/****************************************************************
** Package        :  EcDp_Shift, body part
**
** $Revision: 1.5.2.1 $
**
** Purpose        :  Retrieve the Shift information and provides general procedures on Shift object
**
** Created  : 14-09-2011  Leong Weng Onn
**
** Modification history:
**
** Date        Whom       Change description:
** ------      -----      -----------------------------------
** 14-09-2011  Leongwen   ECPD-18473: Added getWorkingShiftCode()
** 09-12-2011  Leongwen   ECPD-18890: Modified the getWorkingShiftCode() function to fix the formula problem.
** 04-01-2012  leongwen   ECPD-19358: Modified the getWorkingShiftCode() function to handle the DST rather than using the fixed values for European
**                        and North American.
** 17-01-2012  leongwen   ECPD-19377: Shift Object enhancements with Cycle.
** 05-04-2012  leongwen   ECPD-20412: Use the Oracle Collection for Shift Object enhancements with Versioning.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWorkingShiftCode
-- Description    :
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
FUNCTION getWorkingShiftCode(p_fcty_obj_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

  CURSOR c_getAllShiftVersions (cp_fcty_obj_id VARCHAR2) IS
    SELECT OBJECT_ID, CODE, DAYTIME, START_TIME, DURATION, SHIFT_ON_DURATION, SHIFT_OFF_DURATION, CYCLE
    FROM OV_SHIFT
    WHERE OP_FCTY_1_ID = cp_fcty_obj_id
    AND OBJECT_END_DATE IS NULL
    ORDER BY DAYTIME, START_TIME;

  CURSOR c_getShiftStartDaytime (cp_object_id VARCHAR2, cp_fcty_obj_id VARCHAR2, cp_daytime DATE) IS
    SELECT DAYTIME, START_TIME
    FROM OV_SHIFT
    WHERE OBJECT_ID = cp_object_id
    AND OP_FCTY_1_ID = cp_fcty_obj_id
    AND OBJECT_END_DATE IS NULL
    AND cp_daytime + (1/86400)
      BETWEEN (DAYTIME + (to_number(substr(START_TIME,1,2) * (3600/86400)) + to_number(substr(START_TIME,4,2) * (60/86400))))
      AND NVL(Ecbp_Shift.getShiftEndExtraTime(OP_FCTY_1_ID, OBJECT_ID, END_DATE), cp_daytime + 1)
    ORDER BY DAYTIME, START_TIME;

  lv2_ObjectID                  SHIFT_VERSION.OBJECT_ID%TYPE;
  lv2_ShiftCode                 SHIFT.OBJECT_CODE%TYPE;
  lv2_daytime                   DATE;
  lv2_start_time                SHIFT_VERSION.START_TIME%TYPE;
  lv2_duration_day              SHIFT_VERSION.DURATION_DAY%TYPE;
  lv2_shift_on_duration         SHIFT_VERSION.SHIFT_ON_DURATION%TYPE;
  lv2_shift_off_duration        SHIFT_VERSION.SHIFT_OFF_DURATION%TYPE;
  lv2_shift_cycle               SHIFT_VERSION.CYCLE%TYPE;

  lv2_shift_stdaytime           DATE;
  lv2_shift_enddaytime          DATE;
  ln_start_time                 NUMBER;
  ln_duration_day               NUMBER;
  lb_found                      BOOLEAN;
  lv2_TotPrdDuration            NUMBER;
  lv2_daysDiff                  NUMBER;
  lv2_modulus                   NUMBER;
  lv2_rotate_date               DATE;
  lv2_Shift_PrdStDaytime        DATE;
  lv2_Shift_PrdEndDaytime       DATE;
  lv2_cycle                     NUMBER;
  lv2_ShiftStDaytime            DATE;
  lv2_SwappedShift              SHIFT.OBJECT_CODE%TYPE;

  lv2_CTRLObjID                 VARCHAR2(32);
  lv2_CntShiftVersion           NUMBER;
  lv2_TargetShiftStDate         DATE;
  lv2_TargerShiftStTime         SHIFT_VERSION.START_TIME%TYPE;
  lv2_Fetched_shift             BOOLEAN;
  lv2_CTRLObj_Saved             BOOLEAN;
  lv2_counter                   NUMBER;

  typ_object_id                 t_object_id          := t_object_id();
  typ_code                      t_code               := t_code();
  typ_daytime                   t_daytime            := t_daytime();
  typ_start_time                t_start_time         := t_start_time();
  typ_duration                  t_duration           := t_duration();
  typ_shift_on_duration         t_shift_on_duration  := t_shift_on_duration();
  typ_shift_off_duration        t_shift_off_duration := t_shift_off_duration();
  typ_cycle                     t_shift_cycle        := t_shift_cycle();

BEGIN

  lv2_CntShiftVersion := 0;
  lv2_Fetched_shift := FALSE;
  lv2_counter := 0;
  -- Important: to check with no records found in cursor!!!
  OPEN c_getAllShiftVersions(p_fcty_obj_id);
  LOOP
    FETCH c_getAllShiftVersions INTO LV2_ObjectID, LV2_ShiftCode, LV2_Daytime, LV2_Start_Time, LV2_Duration_Day, LV2_Shift_On_Duration, LV2_Shift_Off_Duration, lv2_shift_cycle;
    EXIT WHEN c_getAllShiftVersions%NOTFOUND;
    IF lv2_CTRLObjID IS NULL THEN
      -- to assign the first object_id as Control Object ID as to treat this Control Object ID as the first shift object.
      -- Each different version will start from the same Control Object ID and repeatedly used for all different versions.
      lv2_CTRLObjID := LV2_ObjectID;
    END IF;
    IF c_getAllShiftVersions%ROWCOUNT > 1 and LV2_ObjectID =  lv2_CTRLObjID THEN
      lv2_CntShiftVersion := lv2_CntShiftVersion + 1;
    END IF;
  END LOOP;
  CLOSE c_getAllShiftVersions;

  IF lv2_CTRLObjID IS NOT NULL THEN
    IF lv2_CntShiftVersion = 0 THEN
      -- it found that it only has one CTRLObjID, also mwans it is only with current Shift objects without version.
      OPEN c_getAllShiftVersions(p_fcty_obj_id);
      FETCH c_getAllShiftVersions BULK COLLECT INTO typ_object_id, typ_code, typ_daytime, typ_start_time, typ_duration, typ_shift_on_duration, typ_shift_off_duration, typ_cycle;
      CLOSE c_getAllShiftVersions;
    ELSIF lv2_CntShiftVersion > 0 THEN
      -- it has versions and to check the passed-in daytime falls into which version of shift objects
      OPEN c_getShiftStartDaytime (lv2_CTRLObjID, p_fcty_obj_id, p_daytime);
      LOOP
        FETCH c_getShiftStartDaytime INTO lv2_TargetShiftStDate, lv2_TargerShiftStTime;
        -- assign the target Shift Start Date and Time
        EXIT WHEN c_getShiftStartDaytime%NOTFOUND;
      END LOOP;
      CLOSE c_getShiftStartDaytime;
      IF lv2_TargetShiftStDate IS NOT NULL and lv2_TargerShiftStTime IS NOT NULL THEN
        OPEN c_getAllShiftVersions(p_fcty_obj_id);
        LOOP
          FETCH c_getAllShiftVersions INTO lv2_ObjectID, lv2_ShiftCode, lv2_Daytime, lv2_Start_Time, lv2_Duration_Day, lv2_Shift_On_Duration, lv2_Shift_Off_Duration, lv2_shift_cycle;
          EXIT WHEN c_getAllShiftVersions%NOTFOUND;
          IF lv2_ObjectID =  lv2_CTRLObjID AND lv2_Fetched_shift = TRUE THEN
             EXIT;
          END IF;
          IF (lv2_ObjectID =  lv2_CTRLObjID AND lv2_Daytime  =  lv2_TargetShiftStDate AND lv2_Start_Time = lv2_TargerShiftStTime)
             OR (lv2_CTRLObj_Saved = TRUE) THEN
            lv2_counter := lv2_counter + 1;
            typ_object_id.EXTEND;
            typ_code.EXTEND;
            typ_daytime.EXTEND;
            typ_start_time.EXTEND;
            typ_duration.EXTEND;
            typ_shift_on_duration.EXTEND;
            typ_shift_off_duration.EXTEND;
            typ_cycle.EXTEND;
            typ_object_id(lv2_counter) := lv2_ObjectID;
            typ_code(lv2_counter) := lv2_ShiftCode;
            typ_daytime(lv2_counter) := lv2_Daytime;
            typ_start_time(lv2_counter) := lv2_Start_Time;
            typ_duration(lv2_counter) := lv2_Duration_Day;
            typ_shift_on_duration(lv2_counter) := lv2_Shift_On_Duration;
            typ_shift_off_duration(lv2_counter) := lv2_Shift_Off_Duration;
            typ_cycle(lv2_counter) := lv2_shift_cycle;
            lv2_CTRLObj_Saved := TRUE;
            lv2_Fetched_shift := TRUE;
          END IF;
        END LOOP;
        CLOSE c_getAllShiftVersions;
      ELSIF lv2_TargetShiftStDate IS NULL and lv2_TargerShiftStTime IS NULL THEN
        RETURN NULL;
      END IF;
    END IF;
  END IF;

  lb_found := FALSE;

  FOR i IN typ_object_id.FIRST .. typ_object_id.LAST
  LOOP

    lv2_ObjectID            := typ_object_id(i);
    lv2_ShiftCode           := typ_code(i);
    lv2_daytime             := typ_daytime(i);
    lv2_start_time          := typ_start_time(i);
    lv2_duration_day        := typ_duration(i);
    lv2_shift_on_duration   := typ_shift_on_duration(i);
    lv2_shift_off_duration  := typ_shift_off_duration(i);

    IF lv2_start_time IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'The start time of the shift should not be null.');
    END IF;

    -- Get the info from the first row.
    IF i = 1 THEN
      lv2_ShiftStDaytime := typ_daytime(i) + to_number(substr(typ_start_time(i), 1,2))/24 + to_number(substr(typ_start_time(i), 4,2))/1440;
      lv2_cycle := typ_cycle(i);
    END IF;

    -- To get the minutes from the start time
    lv2_start_time := TO_CHAR(TO_DATE(lv2_start_time,'HH24:MI'),'HH24:MI');
    ln_start_time  := TO_NUMBER(SUBSTR(lv2_start_time,1,2))*60 + TO_NUMBER(SUBSTR(lv2_start_time,4,2));

    IF lv2_shift_stdaytime IS NULL THEN
      -- Variables were assigned once and for all purposes only at the beginning
      -- This is to find the entire shift period start and end daytime based on its period duration.
      lv2_TotPrdDuration := lv2_shift_on_duration + lv2_shift_off_duration;
      lv2_Shift_PrdStDaytime := lv2_daytime + (ln_start_time/(24*60));
      lv2_Shift_PrdEndDaytime := lv2_Shift_PrdStDaytime + lv2_shift_on_duration + lv2_shift_off_duration;

      IF p_daytime >= lv2_Shift_PrdEndDaytime THEN
        lv2_daysDiff := p_daytime - lv2_Shift_PrdEndDaytime;
        lv2_modulus := MOD(lv2_daysDiff, lv2_TotPrdDuration);
        lv2_rotate_date := lv2_Shift_PrdStDaytime + lv2_modulus;
      END IF;
    END IF;

    ln_duration_day := (NVL(lv2_duration_day,0)*60)/(24*60);
    lv2_shift_stdaytime := lv2_daytime + (ln_start_time/(24*60));
    lv2_shift_enddaytime := lv2_shift_stdaytime + ln_duration_day;

    -- loop to check the passed-in daytime is within the working period
    FOR k IN 1..NVl(lv2_shift_on_duration,0) LOOP
      IF p_daytime >= lv2_Shift_PrdEndDaytime THEN
        IF lv2_rotate_date >= lv2_shift_stdaytime AND lv2_rotate_date < lv2_shift_enddaytime THEN
          lb_found := TRUE;
          IF lv2_cycle IS NOT NULL THEN
            -- chk if lv2_rotate_date is equal or after (shift start date + cycle)
            IF p_daytime >= lv2_ShiftStDaytime + lv2_cycle THEN
              lv2_SwappedShift := Ecbp_Shift.SwapShift(p_fcty_obj_id, lv2_ObjectID, p_daytime, lv2_cycle, lv2_ShiftStDaytime,
                                  typ_object_id, typ_code, typ_duration);
              IF lv2_SwappedShift IS NOT NULL THEN
                lv2_ShiftCode := lv2_SwappedShift;
              END IF;
            END IF;
          END IF;
          RETURN lv2_ShiftCode;
        END IF;
      ELSIF p_daytime >= lv2_shift_stdaytime AND p_daytime < lv2_shift_enddaytime THEN
        lb_found := TRUE;
        RETURN lv2_ShiftCode;
      END IF;
      lv2_shift_stdaytime  := lv2_shift_stdaytime  + 1;
      lv2_shift_enddaytime := lv2_shift_enddaytime + 1;

    END LOOP;
  END LOOP;

  IF lb_found = FALSE THEN
    RETURN NULL;
  END IF;

END getWorkingShiftCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SwapShift
-- Description    :
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
-- Behaviour      : Use to swap the shift within its groups based on A,B,C to B,C,A and then to C,A,B and then back to A,B,C
--
---------------------------------------------------------------------------------------------------
FUNCTION SwapShift(p_fcty_obj_id VARCHAR2, p_shift_obj_id VARCHAR2, p_daytime DATE, p_cycle NUMBER, p_Shift_StDaytime DATE,
typ_object_id t_object_id, typ_code t_code, typ_duration t_duration)
RETURN VARCHAR2
IS

  lv2_rownum                    NUMBER;
  lv2_ShiftPerDay               NUMBER;
  lv2_shift_stdaytime           DATE;
  lv2_shift_enddaytime          DATE;
  lv2_SwappedShift              BOOLEAN;
  lv2_ShiftSourceIndex          NUMBER;
  lv2_ShiftTargetIndex          NUMBER;
  lv2_StdaytimeinJulian         NUMBER;
  lv2_EnddaytimeinJulian        NUMBER;
  lv2_Group                     NUMBER;

BEGIN
  -- chk if there is additional shift to extend the previous shift offtime.
  FOR i IN typ_object_id.FIRST .. typ_object_id.LAST LOOP
    IF lv2_ShiftPerDay IS NULL THEN
      IF NVL(typ_duration(i),0) <> 0 THEN
        lv2_ShiftPerDay := 24/typ_duration(i);
      END IF;
    END IF;
    lv2_rownum := nvl(lv2_rownum,0) +1;
  END LOOP;

  -- Validation to prevent divide by zero problem.
  IF lv2_ShiftPerDay = 0 OR lv2_rownum = 0 THEN
    RETURN NULL;
  END IF;

  lv2_SwappedShift := FALSE;
  lv2_shift_stdaytime := p_Shift_StDaytime;
  lv2_shift_enddaytime := p_Shift_StDaytime + p_cycle;
  lv2_StdaytimeinJulian := to_number(to_char(p_Shift_StDaytime, 'J'));
  lv2_EnddaytimeinJulian := to_number(to_char(p_daytime, 'J'));

  FOR j IN lv2_StdaytimeinJulian .. lv2_EnddaytimeinJulian LOOP

    IF lv2_Group IS NULL THEN
      lv2_Group := 1;
    ELSIF lv2_Group > lv2_ShiftPerDay THEN
      lv2_Group := 1;
    END IF;
      IF p_daytime >= lv2_shift_stdaytime AND p_daytime < lv2_shift_enddaytime THEN
        FOR m IN typ_object_id.FIRST .. typ_object_id.LAST LOOP
          IF typ_object_id(m) = p_shift_obj_id THEN
            lv2_ShiftSourceIndex := m;

            IF lv2_ShiftPerDay = 2 THEN
              IF lv2_rownum = 4 OR lv2_rownum = 6 THEN
                IF m = 1 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 1;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 2;
                  END IF;
                ELSIF m = 2 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 2;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 1;
                  END IF;
                ELSIF m = 3 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 3;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 4;
                  END IF;
                ELSIF m = 4 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 4;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 3;
                  END IF;
                ELSIF m = 5 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 5;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 6;
                  END IF;
                ELSIF m = 6 THEN
                  lv2_ShiftTargetIndex := 5;
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 6;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 5;
                  END IF;
                END IF;
              END IF;
            ELSIF lv2_ShiftPerDay = 3 THEN
              IF lv2_rownum = 6 OR lv2_rownum = 9 THEN
                IF m = 1 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 1;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 2;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 3;
                  END IF;
                ELSIF m = 2 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 2;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 3;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 1;
                  END IF;
                ELSIF m = 3 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 3;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 1;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 2;
                  END IF;
                ELSIF m = 4 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 4;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 5;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 6;
                  END IF;
                ELSIF m = 5 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 5;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 6;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 4;
                  END IF;
                ELSIF m = 6 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 6;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 4;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 5;
                  END IF;
                ELSIF m = 7 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 7;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 8;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 9;
                  END IF;
                ELSIF m = 8 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 8;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 9;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 7;
                  END IF;
                ELSIF m = 9 THEN
                  IF lv2_Group = 1 THEN
                    lv2_ShiftTargetIndex := 9;
                  ELSIF lv2_Group = 2 THEN
                    lv2_ShiftTargetIndex := 7;
                  ELSIF lv2_Group = 3 THEN
                    lv2_ShiftTargetIndex := 8;
                  END IF;
                END IF;
              END IF;
            END IF;

            -- to get the Shift swapped with the right one.
            FOR n IN typ_object_id.FIRST .. typ_object_id.LAST LOOP
              IF n = lv2_ShiftTargetIndex THEN
                lv2_SwappedShift := TRUE;
                RETURN typ_code(n);
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END IF;

    lv2_shift_stdaytime := lv2_shift_stdaytime + p_cycle;
    lv2_shift_enddaytime := lv2_shift_enddaytime + p_cycle;
    lv2_Group := lv2_Group + 1;
  END LOOP;

  IF lv2_SwappedShift = FALSE THEN
    RETURN NULL;
  END IF;

END SwapShift;

FUNCTION getShiftEndExtraTime(p_fcty_obj_id VARCHAR2, p_shift_obj_id VARCHAR2, p_enddate DATE)
RETURN DATE
IS
  CURSOR c_getNextVerStTime IS
  SELECT a.START_TIME
  FROM OV_SHIFT a
  WHERE a.OP_FCTY_1_ID = p_fcty_obj_id
  AND a.OBJECT_ID = p_shift_obj_id
  AND a.DAYTIME = p_enddate
  AND object_end_date IS NULL;

  lv2_Start_Time        VARCHAR2(32);
  lv2_EndDateExtraTime  DATE;

BEGIN
  OPEN c_getNextVerStTime;
  LOOP
    FETCH c_getNextVerStTime INTO lv2_Start_Time;
    EXIT WHEN c_getNextVerStTime%NOTFOUND;
  END LOOP;
  CLOSE c_getNextVerStTime;

  IF p_enddate IS NOT NULL THEN
    lv2_EndDateExtraTime := p_enddate +
      nvl((to_number(substr(lv2_Start_Time,1,2) * (3600/86400)) + to_number(substr(lv2_Start_Time,4,2) * (60/86400))),0);
  ELSE
    lv2_EndDateExtraTime := NULL;
  END IF;

  RETURN lv2_EndDateExtraTime;

END getShiftEndExtraTime;

END;