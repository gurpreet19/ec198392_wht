CREATE OR REPLACE PACKAGE BODY EcDp_Production_Lock IS
/****************************************************************
** Package        :  EcDp_Production_Lock, body part
**
** $Revision: 1.18 $
**
** Purpose        :  General Locking procedures dependent on production classes
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.2005 Arild Vervik
**
** Modification history:
**
** Date         Whom    Change description:
** ------       -----   ---------------------------------------------------------------------
** 06.05.2007   Rajarsar Removed lv2_fcty_id := EcDp_Facility.getParentFacility when p_operation = DELETING in CheckAnySimpleProdDayLock
** 31.05.2007   Rajarsar Added Procedure CheckObjConnDataLock
** 29.10.2007   Zakiiari ECPD-3905: Removed checkPlanLock
** 17.02.2009   oonnnng  ECPD-6067: Added local lock check in CheckDirectLock() and CheckProdForecastDataLock() functions.
**                       Add parameter p_object_id to validatePeriodForLockOverlap and checkUpdateEventForLock in
**                       checkAnySimpleEventLock(), validateProdDayPeriodForLock(), CheckAnySimpleProdDayLock() and CheckObjConnDataLock functions.
** 21.04.2009   leongsei ECPD-6067: Modified function checkConstantStdLock to pass in object_id
** 20.05.2009   oonnnng  ECPD-11852: Add new CheckDirectLock() procedure with different arguments pass in.
** 12.07.2017   jainnraj ECPD-45048: Added new procedure CheckOfficialScenarioDataLock to enable local and global monthly locking for official scenarios.
** 26.07.2018   kashisag ECPD-56795: Changed objectid to scenario id, UPDATED CheckOfficialScenarioDataLock procedure
*************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CheckDirectLock
-- Description    : Used for classes where there is only a direct check if PRODUCION_DAY, DAY or DAYTIME is within
--                  a locked month.
--
--
-- Preconditions  : If the class does not have a DAYTIME column it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--                 Logical check order,
--                 1. PRODUCTION_DAY:  Use Facility Production day rule if possible , else Trunc(DAYTIME)
--                 2. DAY:             Trunc(DAYTIME)
--                 3. DAYTIME          Use as is
--
---------------------------------------------------------------------------------------------------
PROCEDURE  CheckDirectLock(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS
  ld_n_dt DATE;
  ld_o_dt DATE;
  ld_locked DATE;
  lv2_id  VARCHAR2(2000);
  lv2_o_obj_id   VARCHAR2(32);
  lv2_n_obj_id   VARCHAR2(32);

BEGIN

  -- Handle the exceptions first
  -- NO Exceptions identified yet


  -- On to the general part, only do this if ld_dt is not set

  IF ld_n_dt IS NULL AND ld_o_dt IS NULL THEN

    IF l_new.EXISTS('PRODUCTION_DAY') THEN

      -- On insert and on daytime update we need to duplicate part of the trigger logic to calculate production day
      --
      IF p_operation = 'INSERTING'
      OR (p_operation = 'UPDATING' AND l_new('DAYTIME').column_data.AccessDate <> l_old('DAYTIME').column_data.AccessDate) THEN

          IF l_new.EXISTS('OBJECT_ID') THEN

            ld_n_dt := Nvl(EcDp_ProductionDay.getProductionDay('FCTY_CLASS_1',
                            EcDp_Facility.getParentFacility(l_new('OBJECT_ID').column_data.AccessVarchar2,
                                                            l_new('DAYTIME').column_data.AccessDate),
                                                            l_new('DAYTIME').column_data.AccessDate),
                         TRUNC(l_new('DAYTIME').column_data.AccessDate));

          ELSE

            ld_n_dt := TRUNC(l_new('DAYTIME').column_data.AccessDate);

          END IF;

          ld_o_dt := l_old('PRODUCTION_DAY').column_data.AccessDate ;  -- So we can check if it is allowed to "delete" the old record

       ELSIF p_operation = 'UPDATING' THEN

          ld_n_dt := l_new('PRODUCTION_DAY').column_data.AccessDate ;

       ELSE  -- Delete

          ld_o_dt := l_old('PRODUCTION_DAY').column_data.AccessDate ;

       END IF;


      ELSIF l_new.EXISTS('DAY') THEN

        IF p_operation = 'INSERTING'
        OR (p_operation = 'UPDATING' AND l_new('DAYTIME').column_data.AccessDate <> l_old('DAYTIME').column_data.AccessDate) THEN

            ld_n_dt := TRUNC(l_new('DAYTIME').column_data.AccessDate);
            ld_o_dt := TRUNC(l_old('DAYTIME').column_data.AccessDate);

         ELSIF p_operation = 'UPDATING' THEN

            ld_n_dt := l_new('DAY').column_data.AccessDate ;

         ELSE  -- Delete

            ld_o_dt := l_old('DAY').column_data.AccessDate ;

         END IF;

      ELSE  -- Use daytime

        IF p_operation = 'INSERTING'
        OR (p_operation = 'UPDATING' AND l_new('DAYTIME').column_data.AccessDate <> l_old('DAYTIME').column_data.AccessDate) THEN

            ld_n_dt := l_new('DAYTIME').column_data.AccessDate;
            ld_o_dt := l_old('DAYTIME').column_data.AccessDate;

         ELSIF p_operation = 'UPDATING' THEN

            ld_n_dt := l_new('DAYTIME').column_data.AccessDate ;

         ELSE  -- Delete

            ld_o_dt := l_old('DAYTIME').column_data.AccessDate ;

         END IF;

      END IF; -- IF exists Production day

  END IF; -- ld_dt IS NULL (general part)

  IF l_old.EXISTS('OBJECT_ID')  THEN
     lv2_o_obj_id := l_old('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF l_new.EXISTS('OBJECT_ID')  THEN
     lv2_n_obj_id := l_new('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF ld_o_dt IS NOT NULL THEN  -- Check if "delete" is allowed

    lv2_id := EcDp_Month_lock.buildIdentifierString(l_old);

    ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_o_dt);

    IF  ld_locked IS NOT NULL THEN

      EcDp_Month_Lock.raiseValidationError(p_operation, ld_o_dt, ld_o_dt, ld_locked, lv2_id);

    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_o_obj_id,
                                   ld_o_dt, ld_o_dt,
                                   p_operation, lv2_id);
  END IF;

  IF ld_n_dt IS NOT NULL THEN  -- Check if "Insert/update" is allowed

    lv2_id := EcDp_Month_lock.buildIdentifierString(l_new);

    ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_n_dt);

    IF ld_locked IS NOT NULL THEN

      EcDp_Month_Lock.raiseValidationError(p_operation, ld_n_dt, ld_n_dt, ld_locked, lv2_id);

    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_n_obj_id,
                                   ld_n_dt, ld_n_dt,
                                   p_operation, lv2_id);
  END IF;


END  CheckDirectLock;



---------------------------------------------------------------------------------------------------
-- Function       : CheckDirectLock
-- Description    : Used for classes where there is only a direct check if PRODUCION_DAY, DAY or DAYTIME is within
--                  a locked month.
--
--
-- Preconditions  : If the class does not have a DAYTIME column it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--                 Logical check order,
--                 1. PRODUCTION_DAY:  Use Facility Production day rule if possible , else Trunc(DAYTIME)
--                 2. DAY:             Trunc(DAYTIME)
--                 3. DAYTIME          Use as is
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckDirectLock(p_class_name VARCHAR2, p_table_name VARCHAR2, p_object_id VARCHAR2, p_measurement_event_type VARCHAR2, p_daytime DATE, p_prod_day DATE)
--</EC-DOC>
IS

  n_lock_columns       EcDp_Month_lock.column_list;

BEGIN

  EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME',p_class_name,'STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME', p_table_name,'STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','Y','N',AnyData.ConvertVarchar2(p_object_id));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','Y','N',AnyData.Convertdate(p_daytime));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'MEASUREMENT_EVENT_TYPE','MEASUREMENT_EVENT_TYPE','VARCHAR2','Y','N',AnyData.ConvertVarchar2(p_measurement_event_type));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'PRODUCTION_DAY','PRODUCTION_DAY','DATE','N','N',AnyData.Convertdate(p_prod_day));

  Ecdp_Production_Lock.CheckDirectLock('UPDATING',n_lock_columns,n_lock_columns);

END  CheckDirectLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkAnySimpleEventLock
-- Description    : Checks whether a simple and independent event record affects a locked month.
--
--
-- Preconditions  : If the class does not have a DAYTIME and END_DATE columns it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Facility.getParentFacility,
--                  EcDp_Facility.getProductionDayOffset,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.checkUpdateEventForLock
--
-- Configuration
-- required       :
--
-- Behavior       : Dates will be adjusted for production day.
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkAnySimpleEventLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_fcty_id production_facility.object_id%TYPE;
ln_prod_day_offset NUMBER;
lv2_o_obj_id   VARCHAR2(32);
lv2_n_obj_id   VARCHAR2(32);

BEGIN

   ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
   ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'DELETING' THEN

      lv2_fcty_id := EcDp_Facility.getParentFacility(p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2, ld_old_daytime, p_old_lock_columns('CLASS_NAME').column_name);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, ld_old_daytime) / 24;

   ELSE

      lv2_fcty_id := EcDp_Facility.getParentFacility(p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2, ld_new_daytime, p_new_lock_columns('CLASS_NAME').column_name);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, ld_new_daytime) / 24;

   END IF;

   ld_new_daytime := ld_new_daytime - ln_prod_day_offset;
   ld_old_daytime := ld_old_daytime - ln_prod_day_offset;

   ld_new_end_date := ld_new_end_date - ln_prod_day_offset;
   ld_old_end_date := ld_old_end_date - ln_prod_day_offset;

   IF p_operation = 'INSERTING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_end_date, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';
      p_old_lock_columns('END_DATE').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);

   END IF;


END checkAnySimpleEventLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateProdDayPeriodForLock
-- Description    : Checks whether a production day adjusted event record affects a locked month.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_Lock.validatePeriodForLockOverlap,
--                  EcDp_Facility.getParentFacility,
--                  EcDp_Facility.getProductionDayOffset
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateProdDayPeriodForLock(p_operation VARCHAR2,
                                       p_from_daytime DATE,
                                       p_to_daytime DATE,
                                       p_object_id VARCHAR2,
                                       p_object_class_name VARCHAR2,
                                       p_context VARCHAR2)
--</EC-DOC>
IS

 lv2_fcty_id VARCHAR2(32);
 ln_prod_day_offset NUMBER;

BEGIN

   IF ec_production_facility.object_code(p_object_id) IS NULL THEN -- The object is not a facility

      lv2_fcty_id := EcDp_Facility.getParentFacility(p_object_id, p_from_daytime, p_object_class_name);

   ELSE

      lv2_fcty_id := p_object_id;

   END IF;

   ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, p_from_daytime) / 24;

   EcDp_month_lock.validatePeriodForLockOverlap(p_operation,
                                                p_from_daytime - ln_prod_day_offset,
                                                p_to_daytime - ln_prod_day_offset,
                                                p_context, p_object_id);

END validateProdDayPeriodForLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckAnySimpleProdDayLock
-- Description    : Checks whether a simple and independent event record affects a locked month.
--
--
-- Preconditions  : If the class does not have a DAYTIME and END_DATE columns it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Facility.getProductionDayOffset,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.checkUpdateEventForLock
--
-- Configuration
-- required       :
--
-- Behavior       : Dates will be adjusted for production day.
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckAnySimpleProdDayLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_fcty_id production_facility.object_id%TYPE;
lv2_o_obj_id   VARCHAR2(32);
lv2_n_obj_id   VARCHAR2(32);

BEGIN

   ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
   ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_end_date, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';
      p_old_lock_columns('END_DATE').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);

   END IF;


END CheckAnySimpleProdDayLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CheckProdForecastDataLock
-- Description    : Checks whether a production forecast data's effective date affects a locked month.
--
--
-- Preconditions  : If the class does not have a EFFECTIVE_DAYTIME column it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_lock.buildIdentifierString
--                  EcDp_Month_Lock.withinLockedMonth
--                  EcDp_Month_Lock.raiseValidationError
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckProdForecastDataLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_month_lock.column_list, p_old_lock_columns IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS
  ld_n_actual_dt     DATE;
  ld_o_actual_dt     DATE;
  ld_locked          DATE;
  lv2_id             VARCHAR2(2000);
  lv2_o_obj_id       VARCHAR2(32);
  lv2_n_obj_id       VARCHAR2(32);

BEGIN
  ld_n_actual_dt := p_new_lock_columns('EFFECTIVE_DAYTIME').column_data.AccessDate;
  ld_o_actual_dt := p_old_lock_columns('EFFECTIVE_DAYTIME').column_data.AccessDate;

  IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
     lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
     lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_operation = 'INSERTING' THEN
    lv2_id := EcDp_Month_lock.buildIdentifierString(p_new_lock_columns);
    ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_n_actual_dt);
    IF ld_locked IS NOT NULL THEN
      EcDp_Month_Lock.raiseValidationError(p_operation, ld_n_actual_dt, ld_n_actual_dt, ld_locked, lv2_id);
    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_n_obj_id,
                                   ld_n_actual_dt, ld_n_actual_dt,
                                   p_operation, lv2_id);

  ELSIF p_operation = 'UPDATING' THEN
    lv2_id := EcDp_Month_lock.buildIdentifierString(p_new_lock_columns);
    ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_n_actual_dt);
    IF ld_locked IS NOT NULL THEN
      EcDp_Month_Lock.raiseValidationError(p_operation, ld_n_actual_dt, ld_n_actual_dt, ld_locked, lv2_id);
    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_n_obj_id,
                                   ld_n_actual_dt, ld_n_actual_dt,
                                   p_operation, lv2_id);

  ELSIF p_operation = 'DELETING' THEN
    lv2_id := EcDp_Month_lock.buildIdentifierString(p_old_lock_columns);
    ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_o_actual_dt);
    IF ld_locked IS NOT NULL THEN
      EcDp_Month_Lock.raiseValidationError(p_operation, ld_o_actual_dt, ld_o_actual_dt, ld_locked, lv2_id);
    END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_o_obj_id,
                                   ld_o_actual_dt, ld_o_actual_dt,
                                   p_operation, lv2_id);

  END IF;

END CheckProdForecastDataLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckObjConnDataLock
-- Description    : Checks whether a simple and independent event record affects a locked month.
--
--
-- Preconditions  : If the class does not have a START_DATE and END_DATE columns it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.checkUpdateEventForLock
--
-- Configuration
-- required       :
--
-- Behavior       : Dates will be adjusted for production day.
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckObjConnDataLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_fcty_id production_facility.object_id%TYPE;
lv2_o_obj_id   VARCHAR2(32);
lv2_n_obj_id   VARCHAR2(32);

BEGIN

   ld_new_daytime := p_new_lock_columns('START_DATE').column_data.AccessDate;
   ld_old_daytime := p_old_lock_columns('START_DATE').column_data.AccessDate;

   ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
   ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_end_date, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      p_old_lock_columns('START_DATE').is_checked := 'Y';
      p_old_lock_columns('END_DATE').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);

   END IF;


END CheckObjConnDataLock;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkConstantStdLock
-- Description    : Checks whether a plan event record affects a locked month.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkConstantStdLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

  ld_new_current_valid DATE;
  ld_old_current_valid DATE;
  ld_new_next_valid DATE;
  ld_old_next_valid DATE;
  ld_old_prev_valid DATE;
  ld_locked_month DATE;
  lv2_id VARCHAR2(2000);
  lv2_columns_updated VARCHAR2(1);
  lv2_o_obj_id VARCHAR2(32);
  lv2_n_obj_id VARCHAR2(32);

BEGIN

  ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
    lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    ld_new_next_valid := ecdp_constant_standard.next_daytime(
                         p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         ld_new_current_valid,
                         p_new_lock_columns('CLASS_NAME').column_name);

    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

  ELSIF p_operation = 'UPDATING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    -- get the next valid daytime
    ld_new_next_valid := ecdp_constant_standard.next_daytime(
                         p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         ld_new_current_valid,
                         p_new_lock_columns('CLASS_NAME').column_name);

    ld_old_next_valid := ecdp_constant_standard.next_daytime(
                         p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         ld_old_current_valid,
                         p_new_lock_columns('CLASS_NAME').column_name);

    IF ld_new_next_valid = ld_old_current_valid THEN
      ld_new_next_valid := ld_old_next_valid;
    END IF;

    -- Get previous record
    ld_old_prev_valid := ecdp_constant_standard.prev_daytime(
                                    p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                    ld_old_current_valid,
                                    p_new_lock_columns('CLASS_NAME').column_name);

    p_old_lock_columns('DAYTIME').is_checked := 'Y';
    IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
      lv2_columns_updated := 'Y';
    ELSE
      lv2_columns_updated := 'N';
    END IF;

    EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                            ld_old_current_valid,
                                            ld_new_next_valid,
                                            ld_old_next_valid,
                                            ld_old_prev_valid,
                                            lv2_columns_updated,
                                            lv2_id,
                                            lv2_n_obj_id);

  ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

    ld_old_next_valid := ecdp_constant_standard.next_daytime(
                         p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         ld_old_current_valid,
                         p_new_lock_columns('CLASS_NAME').column_name);

    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

  END IF;

END checkConstantStdLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CheckOfficialScenarioDataLock
-- Description    : Checks whether official scenario's data affects a locked month.
--
--
-- Preconditions  : If the class does not have DAYTIME column it needs to be handled separately.
--                  Any Forecast class in which scenario_id details are stored in scenario_id and object_id stored in other column it should be listed below in Case1 with their respective class names.
--                  Any Forecast class in which scenario details are stored in scenario id column and object details in object id column it will be handled automatically in Case2.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_lock.buildIdentifierString
--                  EcDp_Month_Lock.withinLockedMonth
--                  EcDp_Month_Lock.raiseValidationError
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckOfficialScenarioDataLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_month_lock.column_list, p_old_lock_columns IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS
  ld_n_actual_dt     DATE;
  ld_o_actual_dt     DATE;
  ld_locked          DATE;
  lv2_id             VARCHAR2(2000);
  lv2_o_obj_id       VARCHAR2(32);
  lv2_n_obj_id       VARCHAR2(32);
  lv2_o_scenario_id  VARCHAR2(32);
  lv2_n_scenario_id  VARCHAR2(32);
  lv2_o_class_name   VARCHAR2(2000);

BEGIN
  ld_n_actual_dt := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_o_actual_dt := p_old_lock_columns('DAYTIME').column_data.AccessDate;
  lv2_o_class_name := p_old_lock_columns('CLASS_NAME').column_name;

   /*Case1: This section is to handle classes where Scenario_id details are stored in scenario_id and Object_id is stored in other object column */

    IF lv2_o_class_name IN ('FCST_WELL_EVENT','FCST_WELL_EVENT_CHILD') THEN
       IF p_old_lock_columns.EXISTS('EVENT_ID')  THEN
           lv2_o_obj_id := p_old_lock_columns('EVENT_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('EVENT_ID')  THEN
           lv2_n_obj_id := p_new_lock_columns('EVENT_ID').column_data.AccessVarchar2;
       END IF;
       IF p_old_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_o_scenario_id := p_old_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_n_scenario_id := p_new_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
   ELSIF lv2_o_class_name = 'FCST_OBJ_CONSTRAINTS' THEN
       IF p_old_lock_columns.EXISTS('CONSTRAINTS_ID')  THEN
           lv2_o_obj_id := p_old_lock_columns('CONSTRAINTS_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('CONSTRAINTS_ID')  THEN
           lv2_n_obj_id := p_new_lock_columns('CONSTRAINTS_ID').column_data.AccessVarchar2;
       END IF;
         IF p_old_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_o_scenario_id := p_old_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_n_scenario_id := p_new_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
   ELSIF lv2_o_class_name = 'FCST_SHORTFALL_FACTORS' THEN
       IF p_old_lock_columns.EXISTS('FACTOR_ID')  THEN
           lv2_o_obj_id := p_old_lock_columns('FACTOR_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('FACTOR_ID')  THEN
           lv2_n_obj_id := p_new_lock_columns('FACTOR_ID').column_data.AccessVarchar2;
       END IF;
       IF p_old_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_o_scenario_id := p_old_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
       IF p_new_lock_columns.EXISTS('SCENARIO_ID') THEN
           lv2_n_scenario_id := p_new_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
       END IF;
   /*Case2: Else section is to handle classes where Scenario_id is stored in scenario_id and object column is stored in object_id*/
   ELSE
      IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
         lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
      END IF;

      IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
         lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
      END IF;

      IF p_old_lock_columns.EXISTS('SCENARIO_ID')  THEN
         lv2_o_scenario_id := p_old_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
      END IF;
      IF p_new_lock_columns.EXISTS('SCENARIO_ID')  THEN
         lv2_n_scenario_id := p_new_lock_columns('SCENARIO_ID').column_data.AccessVarchar2;
      END IF;

   END IF;

  /*Allow user to update and delete record for a locked month, if scenario is not official*/
  IF (p_operation = 'UPDATING' OR p_operation = 'DELETING') AND NVL(Ec_Forecast_Version.official_ind(lv2_o_scenario_id,(Ec_Forecast_Version.prev_daytime(lv2_o_scenario_id,Ecdp_Timestamp.getCurrentSysdate()))),'N') ='N' THEN
         NULL;

  /*Allow user to insert a new record for a locked month, if scenario is not official*/
  ELSIF p_operation = 'INSERTING' AND NVL(Ec_Forecast_Version.official_ind(lv2_n_scenario_id,(Ec_Forecast_Version.prev_daytime(lv2_n_scenario_id,Ecdp_Timestamp.getCurrentSysdate()))),'N') ='N' THEN
         NULL;
  ELSE
        IF p_operation = 'INSERTING' THEN
          lv2_id := EcDp_Month_lock.buildIdentifierString(p_new_lock_columns);
          ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_n_actual_dt);
          IF ld_locked IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError(p_operation, ld_n_actual_dt, ld_n_actual_dt, ld_locked, lv2_id);
          END IF;

          EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_n_obj_id,
                                         ld_n_actual_dt, ld_n_actual_dt,
                                         p_operation, lv2_id);

        ELSIF p_operation = 'UPDATING' THEN
          lv2_id := EcDp_Month_lock.buildIdentifierString(p_new_lock_columns);
          ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_n_actual_dt);
          IF ld_locked IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError(p_operation, ld_n_actual_dt, ld_n_actual_dt, ld_locked, lv2_id);
          END IF;

          EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_n_obj_id,
                                         ld_n_actual_dt, ld_n_actual_dt,
                                         p_operation, lv2_id);

        ELSIF p_operation = 'DELETING' THEN
          lv2_id := EcDp_Month_lock.buildIdentifierString(p_old_lock_columns);
          ld_locked := EcDp_Month_Lock.withinLockedMonth(ld_o_actual_dt);
          IF ld_locked IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError(p_operation, ld_o_actual_dt, ld_o_actual_dt, ld_locked, lv2_id);
          END IF;

          EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_o_obj_id,
                                         ld_o_actual_dt, ld_o_actual_dt,
                                         p_operation, lv2_id);

        END IF;
   END IF;
END CheckOfficialScenarioDataLock;

END EcDp_Production_Lock;