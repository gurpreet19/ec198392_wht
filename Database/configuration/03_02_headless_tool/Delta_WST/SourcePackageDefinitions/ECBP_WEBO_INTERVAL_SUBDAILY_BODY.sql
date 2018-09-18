CREATE OR REPLACE PACKAGE BODY EcBp_Webo_Interval_SubDaily IS
/**************************************************************
** Package:    EcBp_Webo_Interval_SubDaily
**
** $Revision: 1.11 $
**
** Filename:   EcBp_Webo_Interval_SubDaily.sql
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
** Created:     23.03.2006  Arief Zaki
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      ------------------------------------------------------------------------------------------------------
** 23.03.2006 zakiiari   TI#3381-Initial version based on EcBp_Well_SubDaily.
** 03.04.2006 chongjer   TI#2351-added aggregateAllSubDaily
** 12.05.2006 Roar Vika   TI 3704: Updated getPeriodHrs to reflect modification in way of defining length of sub daily period
** 26.06.2006 chongjer   TI 3887: Added p_facility_id to aggregateAllSubDaily
** 23.08.2006 rahmanaz   TI 4426: Modified aggregateAllSubDaily - added condition to check lv2_fcty_1_id = 'WELL_HOOKUP'
** 02.08.2008 Toha       ECPD-4606 Enhanced performance by moving generateMissing logic to EcDp_Subdaily_Utility
** 04.08.2008 Toha       ECPD-4606 Adds user_id for generateMissing
** 05.07.2010 oonnnng    ECPD-14722: Amended code in aggregateAllSubDaily() function.
** 27.02.2013 abdulmaw   ECPD-22552: Updated aggregateSubDaily and aggregateAllSubDaily
** 25.07.2013 musthram   ECPD-23999: Updated aggregateAllSubDaily
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
    ln_period := ec_prosty_codes.alt_code(EcDp_ProductionDay.findSubDailyFreq('WELL', p_object_id, p_daytime),'METER_FREQ');

    ln_retval := TO_NUMBER(ln_period)/60;

  END IF;

  RETURN ln_retval;
END;

PROCEDURE aggregateSubDaily(
  p_daytime                                DATE,
  p_webo_interval_object_id                VARCHAR2,
  p_subdaily_class                         VARCHAR2,
  p_daily_class                            VARCHAR2,
  p_aggr_method                            VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl                              VARCHAR2
)
IS

  ln_period_hrs                            NUMBER;

  lv2_result                               VARCHAR2(4000);
  ln_access_level                          NUMBER;
  lv_record_status                         VARCHAR2(10);

BEGIN


   lv_record_status := EcDp_Subdaily_Utilities.checkRecordStatus(p_daytime,p_webo_interval_object_id,p_daily_class) ;

   ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;

   IF lv_record_status = 'A' THEN
     -- must have access to modify 'A'
      IF ln_access_level  >= 60 THEN
         ln_period_hrs := getPeriodHrs(ec_webo_bore.well_id(ec_webo_interval.well_bore_id(p_webo_interval_object_id)),p_daytime);

         lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_webo_interval_object_id, p_daytime,ln_period_hrs, p_aggr_method);

      ELSE
         RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Approved record. The Daily screen requires higher access.');
      END IF;

    ELSIF lv_record_status = 'V' THEN
      -- must have access to modify 'V'
      IF ln_access_level >= 50 THEN
         ln_period_hrs := getPeriodHrs(ec_webo_bore.well_id(ec_webo_interval.well_bore_id(p_webo_interval_object_id)),p_daytime);

         lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_webo_interval_object_id, p_daytime,ln_period_hrs, p_aggr_method);

      ELSE
         RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Verified record. The Daily screen requires higher access.');
      END IF;

     ELSIF (lv_record_status = 'P') OR (lv_record_status IS NULL) THEN
      -- must have access to modify 'P'
      IF ln_access_level >= 40 THEN
          ln_period_hrs := getPeriodHrs(ec_webo_bore.well_id(ec_webo_interval.well_bore_id(p_webo_interval_object_id)),p_daytime);

          lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_webo_interval_object_id, p_daytime,ln_period_hrs, p_aggr_method);

      ELSE
         RAISE_APPLICATION_ERROR(-20235,
                              'You do not have enough access to run aggregate current for Provisional record. The Daily screen requires higher access.');
      END IF;
   END IF;

END aggregateSubDaily;


PROCEDURE aggregateAllSubDaily(
  p_daytime                                DATE,
  p_webo_interval_object_id                VARCHAR2,
  p_facility_id                            VARCHAR2,
  p_subdaily_class                         VARCHAR2,
  p_daily_class                            VARCHAR2,
  p_aggr_method                            VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl                              VARCHAR2
)
IS

  ln_period_hrs                            NUMBER;
  lv2_result                               VARCHAR2(4000);
  lr_wellboreinterval                      WEBO_INTERVAL%ROWTYPE;
  lr_well                                  WELL%ROWTYPE;
  lv2_fcty_1_id   						   VARCHAR2(32);
  ln_access_level                          NUMBER;

BEGIN


   ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl) ;

   lr_wellboreinterval := ec_webo_interval.row_by_object_id(p_webo_interval_object_id);

   -- Get well record based on given well bore interval ID
   lr_well := ec_well.row_by_object_id(ec_webo_bore.well_id(lr_wellboreinterval.well_bore_id));

   ln_period_hrs := getPeriodHrs(lr_well.object_id,p_daytime);

   lv2_fcty_1_id := p_facility_id;

   IF (Ecdp_Objects.GetObjClassName(lv2_fcty_1_id) = 'WELL_HOOKUP') THEN
     lv2_fcty_1_id := ec_well_version.op_fcty_class_1_id(lr_well.object_id, p_daytime, '<=');
   END IF;

   lv2_result := EcBp_Aggregate.aggregateAllSubDaily(p_subdaily_class, p_daily_class, p_webo_interval_object_id, lv2_fcty_1_id, p_daytime,ln_period_hrs, p_aggr_method, ln_access_level);

END aggregateAllSubDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : generateMissing
-- Description    : This function creates missing sub daily well bore interval records for a given well bore interval and
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
  p_daytime                      DATE,
  p_webo_interval_object_id      VARCHAR2,
  p_subday_class                 VARCHAR2,
  p_generate_method              VARCHAR2      DEFAULT 'INTERPOLATE',
  p_user_id                      VARCHAR2      DEFAULT NULL
)
--</EC-DOC>
IS
  ll_pkeys ecdp_subdaily_utilities.t_pkey_list; -- required attribute
  lv_well_id well.object_id%TYPE;

BEGIN
  -- lock check, only allowed if not in a locked month
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN
      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ecBp_well_subdaily.generateMissing: Can not add missing in a locked month');
    END IF;

  IF p_generate_method IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'Generate Method cannot be NULL!');
  END IF;

  lv_well_id := ec_webo_bore.well_id(ec_webo_interval.well_bore_id(p_webo_interval_object_id));
  ECDP_SUBDAILY_UTILITIES.generateMissingRecords(
    p_webo_interval_object_id,
    p_daytime,
    p_subday_class,
    p_generate_method,
    ll_pkeys,
    p_user_id,
    lv_well_id);

END generateMissing;

END EcBp_Webo_Interval_SubDaily;