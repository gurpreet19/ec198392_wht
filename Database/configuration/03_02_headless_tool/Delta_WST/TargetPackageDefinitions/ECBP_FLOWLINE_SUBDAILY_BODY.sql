CREATE OR REPLACE PACKAGE BODY EcBp_Flowline_SubDaily IS
/**************************************************************
** Package:    EcBp_Flowline_SubDaily
**
** $Revision: 1.19.30.4 $
**
** Filename:   EcBp_Flowline_SubDaily.sql
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
** 01.05.2005    Roar Vika        Updated findNewPeriodValue to look to the end of next production day when looking for next value
** 03.05.2005    DN               Added execution operator at the end.
** 17.06.2005 	 MOT		 	        Fixed bug in 'Next date' select in Copy Backward in findNewPeriodValue (TD3834)
** 17.06.2005 	 MOT    	 	      Fixed previous_date and next_date SQLs in COPY_FORWARD and COPY_BACKWARD. Also fixing a bug in generateMissing
**                                where the ec_strm_version.op_fcty_class_1_id method received a daytime = NULL.
** 21.06.2005    DN               TI 2374: Removed wrong and obsolete cursor c_flowlines.
** 16.08.2005    Darren           TI 2395: Fix defects in generateMissing(), instantiatePeriods() and findNewPeriodValue()
** 16.08.2005    Darren           TI 2395: Fix defects in generateMissing(), instantiatePeriods() and findNewPeriodValue()
** 21.12.2005    Lau              TI 3124: Restrict only NUMBER attribute to be included in interpolation by correction in c_updateable_columns cursor.
** 03.04.2006    Jerome Chong     TI 2351: Added aggregateAllSubDaily
** 15.05.2006    Roar Vika        TI 3704: Updated getPeriodHrs to reflect modification in way of defining length of sub daily period
**                                         Updated all calls to EcDp_ProductionDay.getProductionDayOffset to pass 'FLOWLINE' as parameter instead of FCTY_CLASS_1
** 06.06.2006    Zakiiari         TI 4000: Removed un-used lv_fcty_id variable and used flowline object id for findNewPeriodValue instead of using facility object id
** 26.06.2006    Jerome Chong     TI 3887: Added p_facility_id to aggregateAllSubDaily
** 2008-11-21    oonnnng             ECPD-6067: Added local month lock checking in generateMissing function.
** 02.08.2008    Toha             ECPD-4606 Enhanced performance by moving generateMissing logic to EcDp_Subdaily_Utility
** 04.08.2008    Toha             ECPD-4606 Adds user_id for generateMissing
** 17.02.2009    leongsei         ECPD-6067: Modified function generateMissing for new parameter p_local_lock
** 11.12.2012    musthram         ECPD-22832: Modified aggregateSubDaily and aggregateAllSubDaily
** 15.02.2012	 abdulmaw		  ECPD-22832: Modified aggregateAllSubDaily
** 26.07.2013    musthram         ECPD-24737: Modified aggregateSubDaily and aggregateAllSubDaily
** 11.11.2013    musthram         ECPD-26019: Updated aggregateSubDaily and aggregateAllSubDaily to include flowline_type = GP
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
    ln_period := ec_prosty_codes.alt_code(EcDp_ProductionDay.findSubDailyFreq('FLOWLINE', p_object_id, p_daytime),'METER_FREQ');

    ln_retval := TO_NUMBER(ln_period)/60;

  END IF;

  RETURN ln_retval;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDaily
-- Description    : This function aggregates record for a given flowline and
--                  production day using specified aggregation method and based on user access level vs record status.
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
PROCEDURE aggregateSubDaily(
  p_daytime            DATE,
  p_flowline_object_id VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2       DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS

  ln_period_hrs   NUMBER;
  lv2_result      VARCHAR2(4000);
  ln_access_level     NUMBER;
  lv_record_status VARCHAR2(10);

BEGIN

   lv_record_status := EcDp_Subdaily_Utilities.checkRecordStatus(p_daytime,p_flowline_object_id,p_daily_class) ;
   ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;

   IF lv_record_status = 'A' THEN
     -- must have access to modify 'A'
      IF ln_access_level  >= 60 THEN
          ln_period_hrs := getPeriodHrs(p_flowline_object_id, p_daytime);

          IF EcDp_Flowline.getFlowlineType(p_flowline_object_id, p_daytime) in ('OP','WI','GI','GP') THEN
             lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_flowline_object_id, p_daytime,ln_period_hrs, p_aggr_method);
          END IF;
      ELSE
         RAISE_APPLICATION_ERROR(-20641,
                              'You do not have enough access to run aggregate current for Approved record. The Daily screen requires higher access.');
      END IF;

    ELSIF lv_record_status = 'V' THEN
      -- must have access to modify 'V'
      IF ln_access_level >= 50 THEN
       ln_period_hrs := getPeriodHrs(p_flowline_object_id, p_daytime);

          IF EcDp_Flowline.getFlowlineType(p_flowline_object_id, p_daytime) in ('OP','WI','GI','GP') THEN
             lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_flowline_object_id, p_daytime,ln_period_hrs, p_aggr_method);
          END IF;
      ELSE
         RAISE_APPLICATION_ERROR(-20641,
                              'You do not have enough access to run aggregate current for Verified record. The Daily screen requires higher access.');
      END IF;

     ELSIF (lv_record_status = 'P') OR (lv_record_status IS NULL) THEN
      -- must have access to modify 'P'
      IF ln_access_level >= 40 THEN
       ln_period_hrs := getPeriodHrs(p_flowline_object_id, p_daytime);

          IF EcDp_Flowline.getFlowlineType(p_flowline_object_id, p_daytime) in ('OP','WI','GI','GP') THEN
             lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_flowline_object_id, p_daytime,ln_period_hrs, p_aggr_method);
          END IF;
      ELSE
         RAISE_APPLICATION_ERROR(-20641,
                              'You do not have enough access to run aggregate current for Provisional record. The Daily screen requires higher access.');
      END IF;
   END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateAllSubDaily
-- Description    : This function aggregates record for a given facility's flowline objects and
--                  production day using specified aggregation method and based on user access level vs record status.
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
---------------------------------------------------------------------------------------------------v
PROCEDURE aggregateAllSubDaily(
  p_daytime            DATE,
  p_flowline_object_id VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2       DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS

  ln_period_hrs   NUMBER;
  lv2_result      VARCHAR2(4000);
  ln_access_level NUMBER;

BEGIN

   ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;
   ln_period_hrs := getPeriodHrs(p_flowline_object_id, p_daytime);

   IF EcDp_Flowline.getFlowlineType(p_flowline_object_id, p_daytime) in ('OP','WI','GI','GP') THEN
     lv2_result := EcBp_Aggregate.aggregateAllSubDaily(p_subdaily_class, p_daily_class, p_flowline_object_id, p_facility_id, p_daytime,ln_period_hrs, p_aggr_method, ln_access_level);
   END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : generateMissing
-- Description    : This function creates missing sub daily flowline records for a given flowline and
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
  p_daytime              DATE,
  p_flowline_object_id   VARCHAR2,
  p_subday_class         VARCHAR2,
  p_generate_method      VARCHAR2      DEFAULT 'INTERPOLATE',
  p_user_id              VARCHAR2      DEFAULT NULL
)
--</EC-DOC>
IS
  ll_pkeys ecdp_subdaily_utilities.t_pkey_list; -- required attribute

BEGIN

  -- lock check, only allowed if not in a locked month
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ecBp_Flowline_subdaily.generateMissing: Can not add missing in a locked month');

    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_flowline_object_id,
                                   p_daytime, p_daytime,
                                   'PROCEDURE', 'ecBp_Flowline_subdaily.generateMissing: Can not add missing in a local locked month (' || p_flowline_object_id || ').');

    IF p_generate_method IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Generate Method cannot be NULL!');
    END IF;

    IF p_subday_class = 'IFLW_SUB_DAY_STATUS_GAS' THEN
      ll_pkeys(1).name := 'INJ_TYPE';
      ll_pkeys(1).value := 'GI';
    ELSIF p_subday_class = 'IFLW_SUB_DAY_STATUS_WAT' THEN
      ll_pkeys(1).name := 'INJ_TYPE';
      ll_pkeys(1).value := 'WI';
    END IF; -- pflw = null

    ECDP_SUBDAILY_UTILITIES.generateMissingRecords(
      p_flowline_object_id,
      p_daytime,
      p_subday_class,
      p_generate_method,
      ll_pkeys,
      p_user_id);

END generateMissing;


END EcBp_Flowline_SubDaily;