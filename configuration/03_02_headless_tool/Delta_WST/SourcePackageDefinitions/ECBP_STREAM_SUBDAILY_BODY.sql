CREATE OR REPLACE PACKAGE BODY EcBp_Stream_SubDaily IS
/**************************************************************
** Package:    EcBp_Stream_SubDaily
**
** $Revision: 1.29 $
**
** Filename:   EcBp_Stream_SubDaily.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	26.04.2005  Roar Vika
**
**
** Modification history:
**
**
** Date:         Whom:            Change description:
** --------      -----            ------------------------------------------------------------------------------------------------------
** 26.04.2205    Roar Vika        Initial version based on EcBp_Well_SubDaily
** 03.05.2005    DN               Added execution operator at the end.
** 10.05.2005    Roar Vika        Updated findNewPeriodValue to look maximum one day ahead when looking for future values
** 25.05.2005    Jerome Chong     Updated findNewPeriodValue to have correct time conversion when looking for previous and future values
** 09.06.2005    Magnus Otter?  Fixed bug in 'Next date' select in Copy Backeard in findNewPeriodValue (TD3834)
** 17.06.2005    Magnus Otter?  Fixed previous_date and next_date SQLs in COPY_FORWARD and COPY_BACKWARD. Also fixing a bug in generateMissing
                                  where the ec_strm_version.op_fcty_class_1_id method received a daytime = NULL.
** 21.06.2005    DN               TI 2374: Removed wrong and obsolete cursor c_streams.
** 16.08.2005    Darren           TI 2395: Fix defects in generateMissing(), instantiatePeriods() and findNewPeriodValue()
** 21.12.2005    Lau              TI 3124: Restrict only NUMBER attribute to be included in interpolation by correction in c_updateable_columns cursor.
** 03.04.2006    Jerome Chong     TI 2351: Added procedure aggregateAllSubDaily
** 12.05.2006    Roar Vika        TI 3704: Updated getPeriodHrs to reflect modification in way of defining length of sub daily period
**                                         Updated calls to EcDp_ProductionDay.getProductionDayOffset to pass STREAM as class name (instead of FCTY_CLASS_1)
** 23.06.2006    Jerome Chong     TI 3887: Added p_facility_id to aggregateAllSubDaily
** 08.11.2006    Narinder Kaur    TI 4730: Modify aggregateSubDaily and aggregateAllSubDaily function to aggregate subdaily streams with AGGREGATE_FLAG = 'Y'
** 15.08.2007    embonhaf         ECPD-5809 Modified the lv2_sql statement in setPeriodValue
** 21.11.2008    oonnnng          ECPD-6067: Added local month lock checking in generateMissing function.
** 02.08.2008    Toha             ECPD-4606 Enhanced performance by moving generateMissing logic to EcDp_Subdaily_Utility
** 04.08.2008    Toha             ECPD-4606 Adds user_id for generateMissing
** 17.02.2008    leongsei         ECPD-6067: Modified function generateMissing for new parameter p_local_lock
** 10.04.2009    oonnnng          ECPD-6067: Update local lock checking function in generateMissing() function with the new design.
** 05.05.2010    Leongwen         ECPD-10821: Misc sub daily improvements.
** 27.02.2013    abdulmaw         ECPD-22552: Updated aggregateSubDaily and aggregateAllSubDaily
** 05.04.2013    limmmchu         ECPD-23164: Modified aggregateAllSubDaily
** 03.09.2015    leongwen         ECPD-30939: Added aggregateSubDailyInPeriod and aggregateAllSubDailyInPeriod to loop the dates in the period for aggregate current and facility all functions
*********************************************************************************************************************************/

-- local function
FUNCTION getPeriodHrs(
  p_object_id         VARCHAR2,
  p_daytime           DATE
)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;
  ln_period           VARCHAR2(32);

BEGIN
  IF p_daytime >= EcDp_System.getSystemStartDate THEN
    ln_period := ec_prosty_codes.alt_code(EcDp_ProductionDay.findSubDailyFreq('STREAM', p_object_id, p_daytime),'METER_FREQ');

    ln_retval := TO_NUMBER(ln_period)/60;

  END IF;

  RETURN ln_retval;
END;

PROCEDURE chkObjSubDayFreq(p_on_strm_hrs NUMBER, p_classname VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
  lv_Freq NUMBER;
BEGIN

  lv_Freq := TO_NUMBER(ec_prosty_codes.alt_code(EcDp_ProductionDay.findSubDailyFreq( p_classname, p_object_id, p_daytime),'METER_FREQ')) / 60;

  IF NVL(p_on_strm_hrs,0) > nvl(lv_Freq,0) THEN
    RAISE_APPLICATION_ERROR(-20615, 'On Strm value must be less or equal to the sub daily period definition set at object level.');
  END IF;

END chkObjSubDayFreq;

PROCEDURE aggregateSubDaily(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS

  ln_period_hrs        NUMBER;
  lv2_aggregate_flag   VARCHAR2(2);
  lv2_result           VARCHAR2(4000);
  ln_access_level      NUMBER;
  lv_record_status     VARCHAR2(10);

BEGIN

	IF p_stream_object_id is NULL THEN
		RAISE_APPLICATION_ERROR(-20610, 'Stream Object ID is NULL, please select a valid record with Stream Name in the data section.');
	END IF;

	lv_record_status := EcDp_Subdaily_Utilities.checkRecordStatus(p_daytime,p_stream_object_id,p_daily_class) ;

	ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;

	IF lv_record_status = 'A' THEN
     -- must have access to modify 'A'
		IF ln_access_level  >= 60 THEN
			ln_period_hrs := getPeriodHrs(p_stream_object_id,p_daytime);
			lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_stream_object_id, p_daytime, '<='),'NA');

			IF lv2_aggregate_flag = 'Y' THEN
				lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_stream_object_id, p_daytime,ln_period_hrs, p_aggr_method);
			END IF;
		ELSE
			RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Approved record. The Daily screen requires higher access.');
		END IF;

    ELSIF lv_record_status = 'V' THEN
      -- must have access to modify 'V'
		IF ln_access_level >= 50 THEN
			ln_period_hrs := getPeriodHrs(p_stream_object_id,p_daytime);
			lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_stream_object_id, p_daytime, '<='),'NA');

			IF lv2_aggregate_flag = 'Y' THEN
				lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_stream_object_id, p_daytime,ln_period_hrs, p_aggr_method);
			END IF;
		ELSE
			RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Verified record. The Daily screen requires higher access.');
		END IF;

    ELSIF (lv_record_status = 'P') OR (lv_record_status IS NULL) THEN
      -- must have access to modify 'P'
		IF ln_access_level >= 40 THEN
			ln_period_hrs := getPeriodHrs(p_stream_object_id,p_daytime);
			lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_stream_object_id, p_daytime, '<='),'NA');

			IF lv2_aggregate_flag = 'Y' THEN
				lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_stream_object_id, p_daytime,ln_period_hrs, p_aggr_method);
			END IF;
		ELSE
			RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Provisional record. The Daily screen requires higher access.');
		END IF;
	END IF;
END;


PROCEDURE aggregateAllSubDaily(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2,
  p_strm_set           VARCHAR2  DEFAULT NULL
)
IS

  ln_period_hrs        NUMBER;
  lv2_aggregate_flag   VARCHAR2(2);
  lv2_result           VARCHAR2(4000);
  lv2_facility_id      VARCHAR2(32);
  ln_access_level      NUMBER;

BEGIN

	IF p_stream_object_id is NULL THEN
		RAISE_APPLICATION_ERROR(-20610, 'Stream Object ID is NULL, please select a valid record with Stream Name in the data section.');
	END IF;

	IF p_facility_id is NULL THEN
		lv2_facility_id  := Nvl(ec_strm_version.op_fcty_class_1_id(p_stream_object_id, p_daytime, '<='),
                             ec_strm_version.op_fcty_class_2_id(p_stream_object_id, p_daytime, '<='));
		IF lv2_facility_id is NULL THEN
			RAISE_APPLICATION_ERROR(-20611, 'The facility ID is NULL, please verify the Facility being configured with the selected Stream Name in the data section.');
		END IF;
	END IF;

	ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;

	ln_period_hrs := getPeriodHrs(p_stream_object_id,p_daytime);
    lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_stream_object_id, p_daytime, '<='),'NA');

    IF lv2_aggregate_flag = 'Y' THEN
	  IF p_facility_id is NOT NULL THEN
        lv2_result := EcBp_Aggregate.aggregateAllSubDaily(p_subdaily_class, p_daily_class, p_stream_object_id, p_facility_id, p_daytime, ln_period_hrs, p_aggr_method, ln_access_level, p_strm_set);
	  ELSE
        lv2_result := EcBp_Aggregate.aggregateAllSubDaily(p_subdaily_class, p_daily_class, p_stream_object_id, lv2_facility_id, p_daytime, ln_period_hrs, p_aggr_method, ln_access_level, p_strm_set);
	  END IF;
    END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : generateMissing
-- Description    : This function creates missing sub daily stream records for a given stream and
--                  production day using specified aggregation method.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE generateMissing(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_subday_class       VARCHAR2,
  p_generate_method    VARCHAR2  DEFAULT 'INTERPOLATE',
  p_user_id            VARCHAR2  DEFAULT NULL
)
--</EC-DOC>
IS
  ll_pkeys ecdp_subdaily_utilities.t_pkey_list; -- required attribute
  lv_parent_object_id         VARCHAR2(32);
  lv_local_lock               VARCHAR2(32);

BEGIN

    -- lock check, only allowed if not in a locked month
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ecBp_Stream_subdaily.generateMissing: Can not add missing in a locked month');

    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_stream_object_id,
                                   p_daytime, p_daytime,
                                   'INSERTING', 'ecBp_Stream_subdaily.generateMissing: Can not add missing rows in a local locked month');

    IF p_generate_method IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Generate Method cannot be NULL!');
    END IF;

    ECDP_SUBDAILY_UTILITIES.generateMissingRecords(
      p_stream_object_id,
      p_daytime,
      p_subday_class,
      p_generate_method,
      ll_pkeys,
      p_user_id);

END generateMissing;

PROCEDURE aggregateSubDailyPeriod(
  p_from_daytime       DATE,
	p_to_daytime				 DATE,
  p_stream_object_id   VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS
  ln_from_date  NUMBER;
	ln_to_date  	NUMBER;
	ld_loop_date 	DATE;
BEGIN
  ln_from_date   := TO_NUMBER(TO_CHAR(p_from_daytime, 'j'));
	ln_to_date     := TO_NUMBER(TO_CHAR(p_to_daytime, 'j'));
	ld_loop_date   := p_from_daytime;

  FOR cur_r IN  ln_from_date..ln_to_date LOOP
    EcBp_Stream_SubDaily.aggregateSubDaily(
      ld_loop_date,
			p_stream_object_id,
			p_subdaily_class,
			p_daily_class,
			p_aggr_method,
			p_objecturl);
			ld_loop_date := ld_loop_date + 1;
			ld_loop_date := EcDp_ProductionDay.getProductionDayStart('STREAM', p_stream_object_id, ld_loop_date);
	END LOOP;
END aggregateSubDailyPeriod;

PROCEDURE aggregateAllSubDailyPeriod(
  p_from_daytime       DATE,
	p_to_daytime				 DATE,
  p_stream_object_id   VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2,
  p_strm_set           VARCHAR2  DEFAULT NULL
)
IS
  ln_from_date  NUMBER;
	ln_to_date  	NUMBER;
	ld_loop_date 	DATE;
BEGIN
  ln_from_date := TO_NUMBER(TO_CHAR(p_from_daytime, 'j'));
	ln_to_date   := TO_NUMBER(TO_CHAR(p_to_daytime, 'j'));
	ld_loop_date := p_from_daytime;

  FOR cur_r IN  ln_from_date..ln_to_date LOOP
    EcBp_Stream_SubDaily.aggregateAllSubDaily(
      ld_loop_date,
			p_stream_object_id,
			p_facility_id,
			p_subdaily_class,
			p_daily_class,
			p_aggr_method,
			p_objecturl,
			p_strm_set);
			ld_loop_date := ld_loop_date + 1;
			ld_loop_date := EcDp_ProductionDay.getProductionDayStart('STREAM', p_stream_object_id, ld_loop_date);
	END LOOP;
END aggregateAllSubDailyPeriod;

END EcBp_stream_SubDaily;