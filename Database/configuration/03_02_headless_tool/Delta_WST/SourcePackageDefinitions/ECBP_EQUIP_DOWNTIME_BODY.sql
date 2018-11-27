CREATE OR REPLACE PACKAGE BODY EcBp_Equip_Downtime IS
/****************************************************************
** Package        :  EcBp_Equip_Downtime, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment downtime.
** Documentation  :  www.energy-components.com
**
** Created  : 21.04.2017  chaudgau
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 21.04.2017 chaudgau ECPD-44611: Inital version
** 14.11.2017 chaudgau ECPD-50458: checkValidChildPeriod has been modified to handle NULL value input
*****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfChildEventExists
-- Description    : Checks if child events exist for the parent event id when deleteing.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if child records found when deleting a parent.
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkIfChildEventExists(p_event_no NUMBER)
--</EC-DOC>
IS

  CURSOR c_child_event  IS
  SELECT count(object_id) totalrecord
    FROM equip_downtime wde
   WHERE parent_event_no = p_event_no;

   ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  IF p_event_no IS NOT NULL AND ln_child_record > 0   THEN
    RAISE_APPLICATION_ERROR(-20216, 'It was attempted to delete a row that has child records. In order to delete this row, all child records must be deleted first.');
  END IF;

END checkIfChildEventExists;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_no NUMBER)
--</EC-DOC>
IS
  -- overlapping period can't exist in eqpm downtime
    CURSOR c_equip_dt_event  IS
    SELECT *
      FROM equip_downtime ed
     WHERE ed.object_id = p_object_id
       AND ed.event_no <> p_event_no
       AND (ed.end_date > p_daytime OR ed.end_date IS NULL)
       AND (ed.daytime < p_end_date OR p_end_date IS NULL);

    lv_message VARCHAR2(4000);

BEGIN

  lv_message := NULL;

  FOR cur_equip_dt_event IN c_equip_dt_event LOOP
    lv_message := cur_equip_dt_event.object_id;
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlaps with existing event period.');
  END IF;

END checkIfEventOverlaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkValidChildPeriod
-- Description    : Checks if child period are valid based on the Parent Start date/time and End Date/Tie
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if child's period is not valid.
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER, p_daytime DATE)
--</EC-DOC>
IS

   CURSOR c_outside_event_wed  IS
   SELECT *
     FROM equip_downtime ed
    WHERE (ed.daytime > p_daytime
          OR NVL(ed.end_date,p_daytime) < p_daytime
          OR (ed.end_date IS NOT NULL AND p_daytime IS NULL))
      AND ed.event_no = p_parent_event_no;

    lv_outside_message VARCHAR2(4000);

  BEGIN

  lv_outside_message := null;

  FOR cur_outside_event_wed IN c_outside_event_wed LOOP
    lv_outside_message := lv_outside_message || cur_outside_event_wed.object_id || ' ';
  END LOOP;

  IF lv_outside_message is not null THEN
    RAISE_APPLICATION_ERROR(-20222, 'This time period are outside the parent event period.');
  END IF;

END checkValidChildPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_event_no NUMBER)
--</EC-DOC>
IS

BEGIN

    DELETE FROM equip_downtime
    WHERE parent_event_no = p_event_no;

END deleteChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent event id.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

 ln_child_record NUMBER;

BEGIN
   SELECT count(ed.object_id) INTO ln_child_record
     FROM equip_downtime ed
    WHERE ed.parent_event_no = p_event_no;

  return ln_child_record;

END countChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : VerifyActionsEquip
-- Description    : This procedure checks that we don't have any overlapping actions on events for Equipment downtime
--                : and deferment corrective actions
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : deferment_corr_action, equip_downtime
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

PROCEDURE VerifyActionsEquip(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2)

IS
    CURSOR c_overlapping_actions  IS
    SELECT *
      FROM deferment_corr_action  dca
     WHERE (dca.end_date > p_daytime OR dca.end_date IS NULL)
       AND (dca.daytime < p_end_date OR p_end_date IS NULL)
       AND dca.event_no = p_event_no
       AND dca.action != p_action;

  CURSOR c_outside_event  IS
  SELECT *
    FROM equip_downtime  ed
   WHERE (ed.daytime > p_daytime
         OR ed.end_date < p_daytime
         OR ed.end_date < p_end_date)
     AND ed.event_no = p_event_no;

    lv_overlapping_message VARCHAR2(4000);
    lv_outside_message VARCHAR2(4000);

BEGIN

  lv_overlapping_message := null;
  lv_outside_message := null;

  FOR cur_overlapping_action IN c_overlapping_actions LOOP
    lv_overlapping_message := lv_overlapping_message || cur_overlapping_action.event_no || ' ';
  END LOOP;

  IF lv_overlapping_message IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20625, 'This action overlaps with existing action');
  END IF;

  FOR cur_outside_event IN c_outside_event LOOP
    lv_outside_message := lv_outside_message || cur_outside_event.event_no || ' ';
  END LOOP;

  IF lv_outside_message IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20626, 'This action time period are outside event time period.');
  END IF;

END VerifyActionsEquip;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : chkDowntimeConstraintLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated Well Downtime, Well Downtime by Well and Well Constraint record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_equip_downtime,
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
PROCEDURE chkDowntimeConstraintLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_o_obj_id VARCHAR2(32);
lv2_n_obj_id VARCHAR2(32);

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

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis
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
   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);
   END IF;

END chkDowntimeConstraintLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkChildEndDate
-- Description    : Checks child end date
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if new start date exceed child end date.
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkChildEndDate(p_parent_event_no NUMBER, p_daytime DATE)
--</EC-DOC>
IS
   ld_chk_child date := null;

  BEGIN

    SELECT min(ed.end_date) INTO ld_chk_child
      FROM equip_downtime ed
     WHERE ed.parent_event_no = p_parent_event_no;

  IF ld_chk_child < p_daytime THEN
       RAISE_APPLICATION_ERROR(-20667, 'Parent event start date is invalid as it is after child event end date.');
  END IF;

END checkChildEndDate;

END EcBp_Equip_Downtime;