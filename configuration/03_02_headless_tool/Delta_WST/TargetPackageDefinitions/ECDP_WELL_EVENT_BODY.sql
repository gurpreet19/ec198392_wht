CREATE OR REPLACE PACKAGE BODY EcDp_Well_Event IS

/****************************************************************
** Package        :  EcDp_Well_Event, body part
**
** $Revision: 1.21.12.3 $
**
** Purpose        :  General pupose functionality on top of table well_event
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.12.2005  Roar Vika
**
** Modification history:
**
** Date         Whom          Change description:
** ------       -----         --------------------------------------
** 27.03.2006   Roar Vika     TI 3299: Added new functions getLastPwelEstimateDaytime and
**                            getNextPwelEstimateDaytime. Removed validate_estimate_dates
**
** 21.03.2007   Jailunur      ECDP-2282: Added 4 new functions validateOverlappingPeriod,
**                            getLastClosingDaytime, verifyPeriodTotalizer and approvePeriodTotalizer
** 02.08.2007   kaurrnar      ECPD5562 - Added insertEventDetail and deleteEventDetail procedure
** 08.08.2008   chongviv      ECPD-6170: Updated both approve/verify period totalizer procedures
** 09.08.2007   rajarsar      ECPD5562: Updated insertEventDetail
** 20.11.2007   rajarsar      ECPD6834: Updated insertEventDetail
** 24.01.2008   oonnnng		  ECPD-6774: Added acceptEventAlloc, acceptEventNoAlloc, and rejectEvent procedures.
** 28.01.2008  rajarsar		  ECPD-6783: Added updateRateSource and getChildClassName, updated insertEventDetail and deleteEventDetail
** 27.06.2008  farhaann       ECPD-8939: Updated ORA number for error messages
** 23.02.2011  madondin       ECPD-16316: Modified insertEventDetail to get the override value from well reference value
**                                        if rate calc method is meter reading
** 14.01.2015  dhavaalo		 ECPD-28604: Added new functions getLastWellEventSingleDaytime() and getNextWellEventSingleDaytime()
** 26.02.2015  dhavaalo 	 ECPD-30114: Modified getNextWellEventSingleDaytime to calculate theoretical values correctly.
** 28.05.2015  abdulmaw    ECPD-31002: Updated getChildClassName
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastPwelEstimateDaytime
-- Description    : Returns the last production well estimate for a well on or prior to a given
--                  daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastPwelEstimateDaytime(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_pwel_estimate(cp_object_id well.object_id%TYPE, cp_daytime DATE) IS
  SELECT *
  FROM well_event we
  WHERE we.event_type = 'PWEL_ESTIMATE'
  AND we.object_id = cp_object_id
  AND we.daytime <= cp_daytime
  ORDER BY we.daytime DESC;

  ld_daytime  DATE;

BEGIN

   FOR curRec IN c_pwel_estimate(p_object_id, p_daytime) LOOP

     ld_daytime := curRec.daytime;
     EXIT;

   END LOOP;

   RETURN ld_daytime;

END getLastPwelEstimateDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextPwelEstimateDaytime
-- Description    : Returns the next production well estimate for a well after a given
--                  daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getNextPwelEstimateDaytime(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_pwel_estimate(cp_object_id well.object_id%TYPE, cp_daytime DATE) IS
 SELECT *
 FROM well_event we
 WHERE we.event_type = 'PWEL_ESTIMATE'
 AND we.object_id = cp_object_id
 AND we.daytime >= cp_daytime
 ORDER BY we.daytime ASC;

 ld_daytime  DATE;

BEGIN

   FOR curRec IN c_pwel_estimate(p_object_id, p_daytime) LOOP
      ld_daytime := curRec.daytime;
      EXIT;

   END LOOP;

   RETURN ld_daytime;

END getNextPwelEstimateDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
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
PROCEDURE validateOverlappingPeriod (
   p_object_id       IN well_period_totalizer.object_id%TYPE,
   p_class_name      IN well_period_totalizer.class_name%TYPE,
   p_opening_daytime IN well_period_totalizer.daytime%TYPE,
   p_closing_daytime IN well_period_totalizer.end_date%TYPE)

--</EC-DOC>
IS

  CURSOR c_overlapping_period (cp_object_id well_period_totalizer.object_id%TYPE, cp_class_name well_period_totalizer.class_name%TYPE, cp_open_date well_period_totalizer.daytime%TYPE, cp_close_date well_period_totalizer.end_date%TYPE) IS
    SELECT 'X' FROM well_period_totalizer t
    WHERE t.object_id = cp_object_id AND
          t.class_name = cp_class_name AND
          (
            (t.daytime <= cp_open_date AND cp_open_date < nvl(t.end_date,t.daytime+1)) OR
            (t.daytime < cp_close_date AND cp_close_date < nvl(t.end_date,t.daytime+1)) OR
            (cp_open_date < nvl(t.end_date,t.daytime+1) and nvl(t.end_date,t.daytime+1) < cp_close_date)
          );

BEGIN

  FOR curStream IN c_overlapping_period(p_object_id, p_class_name, p_opening_daytime, nvl(p_closing_daytime,p_opening_daytime+1)) LOOP
    RAISE_APPLICATION_ERROR(-20000, 'Overlapping period is not allowed.');
  END LOOP;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getLastClosingDaytime
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
FUNCTION getLastClosingDaytime (
   p_object_id       IN well_period_totalizer.object_id%TYPE,
   p_class_name      IN well_period_totalizer.class_name%TYPE,
   p_to_daytime      IN DATE
)

RETURN DATE
--</EC-DOC>
IS
  ld_return          DATE;

  CURSOR c_last_closing (cp_object_id well_period_totalizer.object_id%TYPE, cp_class_name well_period_totalizer.class_name%TYPE, cp_to_daytime DATE) IS
    SELECT se.daytime, se.end_date FROM well_period_totalizer se
    WHERE se.object_id = cp_object_id AND
          se.class_name = cp_class_name AND
          se.daytime = (SELECT MAX(t.daytime) FROM well_period_totalizer t WHERE t.object_id=cp_object_id AND t.class_name=cp_class_name AND t.daytime <= cp_to_daytime);

BEGIN

  FOR cur_closing IN c_last_closing(p_object_id,p_class_name,p_to_daytime) LOOP
    IF cur_closing.end_date IS NULL THEN
      ld_return := cur_closing.daytime + 1;
    ELSE
      ld_return := cur_closing.end_date;
    END IF;
  END LOOP;

  IF ld_return IS NULL THEN
    ld_return := to_date(to_char(ecdp_date_time.getCurrentSysdate,'yyyy/mm/dd hh:mi:am'), 'yyyy/mm/dd hh:mi:am');
  END IF;

  RETURN ld_return;

END getLastClosingDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyPeriodTotalizer
-- Description    : The Procedure verify the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_period_totalizer
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyPeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS

ln_exists NUMBER;

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    SELECT COUNT(*) INTO ln_exists FROM well_period_totalizer WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND daytime = p_daytime
    AND end_date = p_end_date
    AND record_status='A';

    IF ln_exists = 0 THEN
       UPDATE well_period_totalizer
          SET record_status='V',
              last_updated_by = p_user,
              last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
              rev_text = 'Verified at ' ||  lv2_last_update_date
       WHERE object_id = p_object_id
       AND class_name = p_class_name
       AND daytime = p_daytime
       AND end_date = p_end_date;
    ELSE
       RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
    END IF;

END verifyPeriodTotalizer;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approvePeriodTotalizer
-- Description    : The Procedure approve the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_period_totalizer
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approvePeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    UPDATE well_period_totalizer
       SET record_status='A',
           last_updated_by = p_user,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND daytime = p_daytime
    AND end_date = p_end_date;

END approvePeriodTotalizer;


---------------------------------------------------------------------------------------------------
-- Procedure      : validatePeriodTotalizer
-- Description    : Used to validate well totalizer periods.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   : WELL_PERIOD_TOTALIZER
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validatePeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE
                         )
--</EC-DOC>
IS

CURSOR c_exists(cp_object_id well.object_id%TYPE,
                cp_class_name VARCHAR2,
                cp_daytime DATE,
                cp_end_date DATE) IS
  SELECT 1 one FROM well_period_totalizer e
   WHERE e.object_id = cp_object_id
     AND e.class_name = cp_class_name
     AND e.daytime <> cp_daytime
     AND ((e.daytime <= cp_end_date AND e.end_date > cp_daytime)
          OR (e.end_date <= cp_end_date AND e.daytime >= cp_daytime))
;

BEGIN

  FOR mycur IN c_exists(p_object_id, p_class_name, p_daytime, p_end_date) LOOP
    RAISE_APPLICATION_ERROR(-20000, 'This event overlaps with existing period for the well');
  END LOOP;

END validatePeriodTotalizer;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateTotalizerMax
-- Description    : The Procedure validate the overwrite and closing < totalizer max count
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_REFERENCE_VALUE
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateTotalizerMax(p_object_id well.object_id%TYPE,
                               p_daytime DATE,
                               p_overwrite NUMBER,
                               p_closing NUMBER)

IS
ln_totalizermax NUMBER;

BEGIN

ln_totalizermax := ec_well_reference_value.totalizer_max_count(p_object_id,p_daytime,'<=');


 IF ln_totalizermax IS NOT NULL THEN

      IF (p_overwrite IS NOT NULL AND p_closing IS NOT NULL) THEN
         IF (p_overwrite >= ln_totalizermax AND p_closing >= ln_totalizermax) THEN
            RAISE_APPLICATION_ERROR('-20000','Overwrite value and Closing value must be less than Totalizer Max Count');
         END IF;
      END IF;

      IF p_overwrite IS NOT NULL THEN
         IF p_overwrite >= ln_totalizermax THEN
            RAISE_APPLICATION_ERROR('-20000','Overwrite value must be less than Totalizer Max Count');
         END IF;
      END IF;
      IF p_closing IS NOT NULL THEN
         IF p_closing >= ln_totalizermax THEN
            RAISE_APPLICATION_ERROR('-20000','Closing value must be less than Totalizer Max Count');
         END IF;
      END IF;
 END IF;


END validateTotalizerMax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertEventDetail
-- Description    : Used to insert row an event details
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT_DETAIL
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE insertEventDetail(p_object_id well.object_id%TYPE,
                            p_daytime DATE,
                            p_event_type VARCHAR2,
                            p_rate_calc_method VARCHAR2,
                            p_user VARCHAR2,
                            p_operation VARCHAR2)
--</EC-DOC>
IS
	ld_opening_daytime  DATE;
    lv2_class_name VARCHAR2(32);
	ln_override NUMBER;
BEGIN
  IF (p_event_type = 'IWEL_EVENT_GAS') THEN
    IF (p_rate_calc_method = 'METER_READING' ) THEN
      lv2_class_name := 'IWEL_EVENT_GAS_TOTALIZER';
    ELSIF (p_rate_calc_method = 'VOLUME_DURATION' ) THEN
      lv2_class_name := 'IWEL_EVENT_GAS_VOLUME';
    ELSIF (p_rate_calc_method = 'USER_EXIT' ) THEN
      lv2_class_name := 'IWEL_EVENT_GAS_UE';
    ELSE
       lv2_class_name := NULL;
    END IF;
 ELSIF (p_event_type = 'IWEL_EVENT_WATER') THEN
    IF (p_rate_calc_method = 'METER_READING' ) THEN
      lv2_class_name := 'IWEL_EVENT_WAT_TOTALIZER';
    ELSIF (p_rate_calc_method = 'VOLUME_DURATION' ) THEN
      lv2_class_name := 'IWEL_EVENT_WAT_VOLUME';
    ELSIF (p_rate_calc_method = 'USER_EXIT' ) THEN
      lv2_class_name := 'IWEL_EVENT_WAT_UE';
    ELSE
       lv2_class_name := NULL;
    END IF;
 ELSIF (p_event_type = 'IWEL_EVENT_STEAM') THEN
    IF (p_rate_calc_method = 'METER_READING' ) THEN
      lv2_class_name := 'IWEL_EVENT_STM_TOTALIZER';
    ELSIF (p_rate_calc_method = 'VOLUME_DURATION' ) THEN
      lv2_class_name := 'IWEL_EVENT_STM_VOLUME';
    ELSIF (p_rate_calc_method = 'USER_EXIT' ) THEN
      lv2_class_name := 'IWEL_EVENT_STM_UE';
    ELSE
       lv2_class_name := NULL;
    END IF ;

  END IF;

     -- get last closing daytime
     ld_opening_daytime := ecbp_well_event_detail.getLastClosingDaytime(p_object_id, lv2_class_name, p_daytime);

      -- volume override functionality is enable
     IF (p_rate_calc_method = 'METER_READING' ) THEN
         ln_override := ec_well_reference_value.default_override(p_object_id, p_daytime, '<=');
     END IF;

     -- Insert a new record in well_event_detail table

     IF p_operation = 'INSERTING' THEN
       INSERT INTO well_event_detail(object_id, daytime, opening_daytime, end_date, event_type, class_name, opening_override, created_by) VALUES (p_object_id, p_daytime, ld_opening_daytime, p_daytime,p_event_type, lv2_class_name, ln_override, p_user);
     ELSIF p_operation = 'UPDATING' THEN
       UPDATE well_event_detail set class_name = lv2_class_name
       WHERE object_id = p_object_id
       AND   daytime = p_daytime
       AND   event_type = p_event_type;
     END IF;
END insertEventDetail;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteEventDetail
-- Description    : Used to delete row an event details
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT_DETAIL
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE deleteEventDetail(p_object_id well.object_id%TYPE,
                            p_daytime DATE,
                            p_event_type VARCHAR2)
--</EC-DOC>
IS

BEGIN

    -- Delete the calculation parameters in Well_Event_Detail table
    DELETE well_event_detail where object_id = p_object_id and daytime = p_daytime and event_type = p_event_type;

END deleteEventDetail;

--</EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : acceptEventAlloc
-- Description    : This procedure updates status on well event to be ACCEPTED, use_in_alloc = Y, and
--                        alt_code from prosty_codes
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptEventAlloc(p_object_id well_event.object_id%TYPE,
						   p_daytime DATE,
                           p_event_type well_event.event_type%TYPE,
						   p_summer_time VARCHAR2,
						   p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv2_alt_code prosty_codes.alt_code%TYPE;

BEGIN
  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_EVENT_STATUS');

  IF (NVL(lv2_alt_code,'0') NOT IN ('V','A')) THEN
     RAISE_APPLICATION_ERROR(-20544,'Well Event must be Verified first');
  END IF;

  UPDATE well_event SET status = 'ACCEPTED', use_in_alloc ='Y', record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type
  AND summer_time =  p_summer_time;

  UPDATE well_event_detail SET record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type;

END acceptEventAlloc;

--</EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : acceptEventNoAlloc
-- Description    : This procedure updates status on well event to be ACCEPTED, use_in_alloc = N, and
--                        alt_code from prosty_codes
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptEventNoAlloc(p_object_id well_event.object_id%TYPE,
							 p_daytime DATE,
							 p_event_type well_event.event_type%TYPE,
							 p_summer_time VARCHAR2,
							 p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv2_alt_code prosty_codes.alt_code%TYPE;

BEGIN

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_EVENT_STATUS');

  IF (NVL(lv2_alt_code,'0') NOT IN ('V','A')) THEN
     RAISE_APPLICATION_ERROR(-20544,'Well Event must be Verified first');
  END IF;

  UPDATE well_event SET status = 'ACCEPTED', use_in_alloc ='N', record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type
  AND summer_time = p_summer_time;

  UPDATE well_event_detail SET  record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type;

END acceptEventNoAlloc;

--</EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : rejectEvent
-- Description    : This procedure updates status on well event to be REJECTED, use_in_alloc = N, and
--                        alt_code from prosty_codes
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE rejectEvent(p_object_id well_event.object_id%TYPE,
                      p_daytime DATE,
                      p_event_type well_event.event_type%TYPE,
					  p_summer_time VARCHAR2,
					  p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv2_alt_code prosty_codes.alt_code%TYPE;

BEGIN

  lv2_alt_code := ec_prosty_codes.alt_code('REJECTED','WELL_EVENT_STATUS');

  IF (NVL(lv2_alt_code,'0') NOT IN ('V','A')) THEN
     RAISE_APPLICATION_ERROR(-20544,'Well Event must be Verified first');
  END IF;

  UPDATE well_event SET status = 'REJECTED', use_in_alloc ='N', record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type
  AND summer_time = p_summer_time;

  UPDATE well_event_detail SET  record_status = lv2_alt_code,
  last_updated_by = p_user_id,
  last_updated_date = to_date(to_char(Ecdp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS')
  WHERE object_id = p_object_id
  AND daytime = p_daytime
  AND event_type = p_event_type;


END rejectEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateRateSource
-- Description    : Update Rate Source when user manual updates AVG_INJ_RATE
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_EVENT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE updateRateSource(p_object_id well.object_id%TYPE,
                           p_daytime DATE,
                           p_event_type VARCHAR2,
                           p_o_avg_inj_rate NUMBER,
						   p_n_avg_inj_rate NUMBER,
						   p_summer_time VARCHAR2,
                           p_user VARCHAR2,
                           p_operation VARCHAR2
                           )
--</EC-DOC>
IS
  lv_update BOOLEAN := FALSE;  -- BOOLEAN literal set to FALSE

BEGIN
  IF p_operation = 'UPDATING' THEN
       --check all other parameters when update's
    IF (nvl(p_o_avg_inj_rate,0) <> nvl(p_n_avg_inj_rate,0))THEN
      lv_update := TRUE;
    END IF;

    IF (lv_update = TRUE) THEN
      --update pwel_result
      UPDATE well_event we SET we.rate_source = 'MANUAL', we.last_updated_by = p_user
      WHERE we.object_id = p_object_id AND we.daytime = p_daytime AND we.event_type = p_event_type AND we.summer_time = p_summer_time;
    END IF;

   ELSIF p_operation = 'INSERTING' THEN

     IF (p_n_avg_inj_rate IS NOT NULL)THEN
       lv_update := TRUE;
     END IF;

     IF (lv_update = TRUE) THEN
      --update pwel_result
       UPDATE well_event we SET we.rate_source = 'MANUAL', we.last_updated_by = p_user
       WHERE we.object_id = p_object_id AND we.daytime = p_daytime AND we.event_type = p_event_type;
     END IF;
   END IF;
END updateRateSource;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getLastRateCalcMethod
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
FUNCTION  getLastRateCalcMethod (
          p_object_id       well.object_id%TYPE,
          p_daytime         DATE,
          p_event_type      VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_rate_calc_method VARCHAR2(32);

    CURSOR c_last_calc_method (cp_object_id well.object_id%TYPE, cp_event_type VARCHAR2, cp_daytime DATE) IS
    SELECT wet.daytime, wet.rate_calc_method FROM well_event wet
    WHERE wet.object_id = cp_object_id AND
          wet.event_type = cp_event_type AND
          wet.daytime = (SELECT MAX(wet2.daytime) FROM well_event wet2
          WHERE wet2.object_id=cp_object_id
          AND wet2.event_type = cp_event_type
          AND wet2.rate_calc_method is not null
          AND wet2.daytime <= cp_daytime);

BEGIN

    FOR cur_rate_calc_method IN c_last_calc_method(p_object_id,p_event_type,p_daytime) LOOP
      lv2_rate_calc_method := cur_rate_calc_method.rate_calc_method;
    END LOOP;

 RETURN   lv2_rate_calc_method;
END  getLastRateCalcMethod;

---------------------------------------------------------------------------------------------------
-- Function       : getChildClassName
-- Description    : Retrieves the associated child class name based on Rate Calc Method
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_well_event_detail.class_name
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getChildClassName(p_object_id VARCHAR2, p_daytime DATE, p_event_type VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS


	lv2_return_value 	VARCHAR2(32);
	lv2_class_name		VARCHAR2(32);

BEGIN
	  lv2_class_name       := ec_well_event_detail.class_name(p_object_id,p_daytime,p_event_type,'<=');
		IF lv2_class_name is NULL THEN
			lv2_return_value := 'IWEL_EVENT_GAS_TOTALIZER';
		ELSE lv2_return_value := lv2_class_name;
    END IF;

  RETURN lv2_return_value;
END getChildClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastWellEventSingleDaytime
-- Description    : Returns the last single well event for a well on or prior to a given
--                  daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastWellEventSingleDaytime(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_well_single_evt(cp_object_id well.object_id%TYPE, cp_daytime DATE) IS
  SELECT *
  FROM well_event we
  WHERE we.event_type = 'WELL_EVENT_SINGLE'
  AND we.object_id = cp_object_id
  AND we.daytime <= cp_daytime
  ORDER BY we.daytime DESC;

  ld_daytime  DATE;

BEGIN

   FOR curRec IN c_well_single_evt(p_object_id, p_daytime) LOOP

     ld_daytime := curRec.daytime;
     EXIT;

   END LOOP;

   RETURN ld_daytime;

END getLastWellEventSingleDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextWellEventSingleDaytime
-- Description    : Returns the next single well event for a well after a given
--                  daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getNextWellEventSingleDaytime(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_well_single_evt(cp_object_id well.object_id%TYPE, cp_daytime DATE) IS
 SELECT *
 FROM well_event we
 WHERE we.event_type = 'WELL_EVENT_SINGLE'
 AND we.object_id = cp_object_id
 AND we.daytime > cp_daytime
 AND we.daytime < cp_daytime + 1
 ORDER BY we.daytime ASC;

 ld_daytime  DATE;

BEGIN

   FOR curRec IN c_well_single_evt(p_object_id, p_daytime) LOOP
      ld_daytime := curRec.daytime;
      EXIT;

   END LOOP;

   RETURN ld_daytime;

END getNextWellEventSingleDaytime;

END EcDp_Well_Event;