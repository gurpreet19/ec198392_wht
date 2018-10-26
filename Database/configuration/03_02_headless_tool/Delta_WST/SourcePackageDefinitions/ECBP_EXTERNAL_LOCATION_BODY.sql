CREATE OR REPLACE PACKAGE BODY EcBp_External_Location IS
/****************************************************************
** Package        :  EcBp_External_Location, body part.
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to external location.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.07.2012  Mawaddah Abdul Latif
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 10.07.2012 abdulmaw ECPD-21450: Added checkExtLocReferenceValueLock()
** 16.07.2012 limmmchu ECPD-21448: Added checkIfPeriodOverlaps()
** 10.08.2012 limmmchu ECPD-21449: Modified checkIfPeriodOverlaps() to include fcty_object_id
** 18.07.2017 kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkExtLocReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated external location reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_ext_loc_reference_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkExtLocReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
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

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_ext_loc_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_ext_loc_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_ext_loc_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_ext_loc_reference_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

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

      ld_old_next_valid := ec_ext_loc_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkExtLocReferenceValueLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkIfPeriodOverlaps
-- Description    :  This procedure checks validity of child and parent period.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_EXT_LOCATION_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE checkIfPeriodOverlaps(p_object_id VARCHAR2,p_parent_start_date DATE, p_end_date DATE, p_fcty_object_id VARCHAR2)

IS
  CURSOR c_validate3 IS
    SELECT object_id, start_date, end_date
      FROM FCTY_EXT_LOCATION_CONN
     WHERE object_id = p_object_id
	   AND fcty_object_id = p_fcty_object_id
       AND (p_parent_start_date BETWEEN start_date AND Nvl(end_date, Ecdp_Timestamp.getCurrentSysdate)
       OR  p_parent_start_date < (select max(g1.start_date)
                                    FROM FCTY_EXT_LOCATION_CONN g1
                                   WHERE g1.object_id = p_object_id))
       AND start_date <> p_parent_start_date;

BEGIN

  IF p_object_id IS NOT NULL THEN
    FOR cur_Validate3 IN c_validate3 LOOP
      Raise_Application_Error(-20121,'Start Date overlaps with another object group period.');
      Exit;
    END LOOP;

  END IF;

END checkIfPeriodOverlaps;

END EcBp_External_Location;