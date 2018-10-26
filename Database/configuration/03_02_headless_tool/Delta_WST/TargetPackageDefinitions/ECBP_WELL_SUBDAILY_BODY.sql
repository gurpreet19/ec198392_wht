CREATE OR REPLACE PACKAGE BODY EcBp_Well_SubDaily IS
/**************************************************************
** Package:    EcBp_Well_SubDaily
**
** $Revision: 1.38.12.3 $
**
** Filename:   EcBp_Well_SubDaily.sql
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
** Created:     11.05.2004  Frode Barstad
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      ------------------------------------------------------------------------------------------------------
** 28.05.2004 FBa        Changed to use EcDp_Facility.getProductionDayStart instead of EcDp_System.
** 02.06.2004 DN         Function getPeriodHrs: Use of system attribute.
** 28.06.2004 KSN        Fixed date sent in as parameter to summertime_flag function on copy backwards in findNewPeriodValue
** 11.08.2004 Toha       Replaced references to sysnam+facility+well_no to well.object_id in function calls.
**                       Removed unnecessary well%rowtype, since functions utilize well.object_id
** 28.01.2005 Darren     Modified checking in instantiatePeriods so that period can be instantiate according to production day
** 31.01.2005 Darren     Modified findNewPeriodValue so that it will only find value in same production day.
** 02.01.2005 SHN        Removed changes done 31.01.2005.
** 02.03.2005 kaurrnar   Changed the number of arguments to be pass to the ecdp_groups.findparentobjectid function
** 03.03.2005 kaurrnar   Changed reference from views to tables
** 23.04.2005 ROV   Tracker #2200,#2178: Modified method generateMissing to support both injection and production wells, removed facility cursor.
                         Removed hardcoded data class names and modified methods generateMissing and aggregateSubDaily to take data classes as parameters.
                         Updated method findNewPeriodValue to only look one production day back/forward in time when looking for existing values.
** 03.05.2005 DN         Added execution operator at the end.
** 06.05.2005 ROV        Added logic deducting injection type based on well_type in instantiatePeriods
** 17.06.2005 MOT     Fixed bug in 'Next date' select in Copy Backward in findNewPeriodValue (TD3834)
** 17.06.2005 MOT       Fixed previous_date and next_date SQLs in COPY_FORWARD and COPY_BACKWARD. Also fixing a bug in generateMissing
**                       where the ec_strm_version.op_fcty_class_1_id method received a daytime = NULL.
** 21.06.2005 DN         TI 2374: Removed wrong and obsolete cursor c_wells.
** 16.08.2005 Darren     TI 2395: Fix defects in generateMissing(), instantiatePeriods() and findNewPeriodValue()
** 25.08.2005 Nazli      TI 2528: Update instantiatePeriods. Insert PWEL_SUB_DAY_STATUS with DATA_CLASS_NAME value.
** 21.12.2005 Lau   TI 3124: Restrict only NUMBER attribute to be included in interpolation by correction in c_updateable_columns cursor.
** 10.03.2006 Seongkok   TI 3266: Update instantiatePeriods with checking on Wells potentially injecting steam.
** 03.04.2006 Jerome     TI 2351: Added procedure aggregateAllSubDaily
** 12.05.2006 Roar Vika   TI 3704: Updated getPeriodHrs to reflect modification in way of defining length of sub daily period
** 26.06.2006 Jerome     TI 3887: Added p_facility_id to aggregateAllSubDaily
** 23.08.2006 rahmanaz   TI 4426: Modified aggregateAllSubDaily - added condition to check lv2_fcty_1_id = 'WELL_HOOKUP'
** 15.08.2007 embonhaf   ECPD-5809 Modified the lv2_sql statement in setPeriodValue
** 15.02.2008 LIZ        ECPD-4848: Modified InstantiatePeriods to remove the use of Well_Type and Well_Class, and replace with the ISflags.
** 21.11.2008 oonnnng    ECPD-6067: Added local month lock checking in generateMissing function.
** 02.08.2008 Toha       ECPD-4606 Enhanced performance by moving generateMissing logic to EcDp_Subdaily_Utility
** 04.08.2008 Toha       ECPD-4606 Adds user_id for generateMissing
** 17.02.2009 leongsei   ECPD-6067: Modified function generateMissing for new parameter p_local_lock
** 10.04.2009 oonnnng    ECPD-6067: Update local lock checking function in generateMissing() function with the new design.
** 05.05.2010 Leongwen   ECPD-10821: Misc sub daily improvements.
** 31.12.2012 musthram   ECPD-22832: Updated aggregateSubDaily and aggregateAllSubDaily
** 26.07.2013 musthram   ECPD-24737: Modified aggregateSubDaily and aggregateAllSubDaily
** 02.12.2013 musthram   ECPD-26246: Updated aggregateSubDaily to prompt message unable to aggregate when well has been closed long term
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDaily
-- Description    : This function aggregates record for a given well and
--                  production day using specified aggregation method and based on user access level vs record status.
--
-- Preconditions  : Well Object Id is not null; Well not Closed Long-Term
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
  p_well_object_id     VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS

  ln_period_hrs        NUMBER;
  lv2_result           VARCHAR2(4000);
  ln_access_level      NUMBER;
  lv_record_status     VARCHAR2(10);

BEGIN

    IF p_well_object_id is NULL THEN
      RAISE_APPLICATION_ERROR(-20612, 'Well Object ID is NULL, please select a valid record with Well Name in the data section.');
    END IF;

	IF Ecdp_Well.IsWellNotClosedLT(p_well_object_id, p_daytime) = 'N' THEN
      RAISE_APPLICATION_ERROR(-20644, 'Unable to aggregate this data. The well has been closed long term.');
    END IF;

    lv_record_status := EcDp_Subdaily_Utilities.checkRecordStatus(p_daytime,p_well_object_id,p_daily_class) ;
    ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl,p_subdaily_class,p_daily_class) ;

	IF lv_record_status = 'A' THEN
     -- must have access to modify 'A'
      IF ln_access_level  >= 60 THEN
           ln_period_hrs := getPeriodHrs(p_well_object_id, p_daytime);

			IF EcDp_Well.getWellClass(p_well_object_id, p_daytime) in ('P','I','PI') THEN
				lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_well_object_id, p_daytime,ln_period_hrs, p_aggr_method);
			END IF;
		ELSE
			RAISE_APPLICATION_ERROR(-20641,
                              'You do not have enough access to run aggregate current for Approved record. The Daily screen requires higher access.');
		END IF;

    ELSIF lv_record_status = 'V' THEN
      -- must have access to modify 'V'
	  IF ln_access_level >= 50 THEN
			ln_period_hrs := getPeriodHrs(p_well_object_id, p_daytime);

        IF EcDp_Well.getWellClass(p_well_object_id, p_daytime) in ('P','I','PI') THEN

          lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_well_object_id, p_daytime,ln_period_hrs, p_aggr_method);

        END IF;
      ELSE
         RAISE_APPLICATION_ERROR(-20641,
                              'You do not have enough access to run aggregate current for Verified record. The Daily screen requires higher access.');
      END IF;

    ELSIF (lv_record_status = 'P') OR (lv_record_status IS NULL) THEN
      -- must have access to modify 'P'
      IF ln_access_level >= 40 THEN
	    ln_period_hrs := getPeriodHrs(p_well_object_id, p_daytime);

		IF EcDp_Well.getWellClass(p_well_object_id, p_daytime) in ('P','I','PI') THEN
		  lv2_result := EcBp_Aggregate.aggregateSubDaily(p_subdaily_class,p_daily_class, p_well_object_id, p_daytime,ln_period_hrs, p_aggr_method);
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
-- Description    : This function aggregates record for a given facility's well objects and
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
PROCEDURE aggregateAllSubDaily(
  p_daytime            DATE,
  p_well_object_id     VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
)
IS

  ln_period_hrs        NUMBER;
  lv2_fcty_1_id        VARCHAR2(32);
  lv2_result           VARCHAR2(4000);
  ln_access_level      NUMBER;

BEGIN

   IF p_well_object_id is NULL THEN
      RAISE_APPLICATION_ERROR(-20612, 'Well Object ID is NULL, please select a valid record with Well Name in the data section.');
   END IF;

   IF p_facility_id is NULL THEN
     lv2_fcty_1_id := ec_well_version.op_fcty_class_1_id(p_well_object_id, p_daytime, '<=');
     IF lv2_fcty_1_id is NULL THEN
        RAISE_APPLICATION_ERROR(-20613, 'The facility ID is NULL, please verify the Facility being configured with the selected Well Name in the data section.');
     END IF;
   ELSE
      lv2_fcty_1_id := p_facility_id;
   END IF;

   ln_access_level := EcDp_Subdaily_Utilities.checkAccessLevel(p_objecturl,p_subdaily_class,p_daily_class);
   ln_period_hrs := getPeriodHrs(p_well_object_id, p_daytime);

   IF (Ecdp_Objects.GetObjClassName(lv2_fcty_1_id) = 'WELL_HOOKUP') THEN
     lv2_fcty_1_id := ec_well_version.op_fcty_class_1_id(p_well_object_id, p_daytime, '<=');
   END IF;

   IF EcDp_Well.getWellClass(p_well_object_id, p_daytime) in ('P','I','PI') THEN
     lv2_result := EcBp_Aggregate.aggregateAllSubDaily(p_subdaily_class, p_daily_class, p_well_object_id, lv2_fcty_1_id, p_daytime, ln_period_hrs, p_aggr_method, ln_access_level);
   END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : generateMissing
-- Description    : This function creates missing sub daily well records for a given well and
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
  p_well_object_id     VARCHAR2,
  p_subday_class       VARCHAR2,
  p_generate_method    VARCHAR2      DEFAULT 'INTERPOLATE',
  p_user_id            VARCHAR2      DEFAULT NULL
)
--</EC-DOC>
IS
  ll_pkeys ecdp_subdaily_utilities.t_pkey_list;

BEGIN
  -- lock check, only allowed if not in a locked month
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN
      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ecBp_well_subdaily.generateMissing: Can not add missing in a locked month');

    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_well_object_id,
                                   p_daytime, p_daytime,
                                   'INSERTING', 'ecBp_well_subdaily.generateMissing: Can not add missing rows in a local locked month');

    IF p_generate_method IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Generate Method cannot be NULL!');
    END IF;

    IF p_subday_class = 'IWEL_SUB_DAY_STATUS_GAS' THEN
      ll_pkeys(1).name := 'INJ_TYPE';
      ll_pkeys(1).value := 'GI';
    ELSIF p_subday_class = 'IWEL_SUB_DAY_STATUS_WAT' THEN
      ll_pkeys(1).name := 'INJ_TYPE';
      ll_pkeys(1).value := 'WI';
    ELSIF p_subday_class = 'IWEL_SUB_DAY_STATUS_STM' THEN
      ll_pkeys(1).name := 'INJ_TYPE';
      ll_pkeys(1).value := 'SI';
    END IF; -- pwel = null

    ECDP_SUBDAILY_UTILITIES.generateMissingRecords(
      p_well_object_id,
      p_daytime,
      p_subday_class,
      p_generate_method,
      ll_pkeys,
      p_user_id);

END generateMissing;

END EcBp_Well_SubDaily;