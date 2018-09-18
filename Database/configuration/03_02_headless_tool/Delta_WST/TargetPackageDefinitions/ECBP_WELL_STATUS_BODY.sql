CREATE OR REPLACE PACKAGE BODY EcBp_Well_Status IS
/****************************************************************
** Package        :  EcBp_Well_Status, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Provides business functions related to well status.
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.01.2006  Dagfinn Njå
**
** Modification history:
**
** Date         Whom     Change description:
** ------       -----    --------------------------------------
** 13.04.2007   LAU      ECPD-5253: Add INJ_TYPE for IWEL_PERIOD_STATUS
** 22.11.2008   oonnnng  ECPD-6067: Added local month lock checking in checkWellStatusLock function.
** 17.02.2009   oonnnng  ECPD-6067: Add new parameter p_object_id to validatePeriodForLockOverlap() and checkUpdateOfLDOForLock()
**                       in checkWellStatusLock() function.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkWellStatusLock
-- Description    : Checks whether a last dated well status record affects a locked month.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Well.getFacility,
--                  EcDp_Facility.getProductionDayOffset,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      : Supports the tables PWEL_PERIOD_STATUS and IWEL_PERIOD_STATUS
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkWellStatusLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
ln_prod_day_offset NUMBER; -- offset in decimal days
lv2_facility production_facility.object_id%TYPE;
lv2_table_name VARCHAR2(30);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);


BEGIN

   -- Get production day offset to use in date test.

   IF p_operation = 'DELETING' THEN

      lv2_facility := EcDp_Well.getFacility(p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2, p_old_lock_columns('DAYTIME').column_data.AccessDate);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_old_lock_columns('DAYTIME').column_data.AccessDate) / 24;
      lv2_table_name := p_old_lock_columns('TABLE_NAME').column_name;
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

   ELSE

      lv2_facility := EcDp_Well.getFacility(p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2, p_new_lock_columns('DAYTIME').column_data.AccessDate);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_new_lock_columns('DAYTIME').column_data.AccessDate) / 24;
      lv2_table_name := p_new_lock_columns('TABLE_NAME').column_name;
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

   END IF;

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_pwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_iwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid - ln_prod_day_offset, ld_new_next_valid - ln_prod_day_offset, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      -- get the next valid daytime

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_pwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         ld_old_next_valid := ec_pwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         IF ld_new_next_valid = ld_old_current_valid THEN
            ld_new_next_valid := ld_old_next_valid;
         END IF;

          -- Get previous record
          ld_old_prev_valid := ec_pwel_period_status.prev_daytime(
                                      p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                      ld_old_current_valid,
                                      p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_iwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         ld_old_next_valid := ec_iwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         IF ld_new_next_valid = ld_old_current_valid THEN
            ld_new_next_valid := ld_old_next_valid;
         END IF;

         ld_old_prev_valid := ec_iwel_period_status.prev_daytime(
                                      p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                      ld_old_current_valid,
                                      p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                                      p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      ld_new_current_valid := ld_new_current_valid - ln_prod_day_offset;
      ld_old_current_valid := ld_old_current_valid - ln_prod_day_offset;
      ld_new_next_valid := ld_new_next_valid - ln_prod_day_offset;
      ld_old_next_valid := ld_old_next_valid - ln_prod_day_offset;
      ld_old_prev_valid := ld_old_prev_valid - ln_prod_day_offset;

      p_old_lock_columns('DAYTIME').is_checked := 'Y';
      p_old_lock_columns('PRODUCTION_DAY').is_checked := 'Y';

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

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_old_next_valid := ec_pwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_old_next_valid := ec_iwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid - ln_prod_day_offset, ld_old_next_valid - ln_prod_day_offset, lv2_id, lv2_o_obj_id);

   END IF;

END checkWellStatusLock;

END EcBp_Well_Status;