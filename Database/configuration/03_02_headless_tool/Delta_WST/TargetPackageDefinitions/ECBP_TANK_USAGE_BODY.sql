CREATE OR REPLACE PACKAGE BODY EcBp_Tank_Usage IS
/****************************************************************
** Package        :  EcBp_Tank_Usage, body part
**
** $Revision: 1.9 $
**
** Purpose        :  Provides working capasity values for a given
**                   terminal,storage and day.
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.06.2001  Snorre Gulbrandsen
**
** Modification history:
**
** Version  Date       Whom    Change description:
** -------  ------     -----   --------------------------------------
**          29.04.2004 FBa     Moved 2 equal local cursors to package global
**	    11.08.2004 Mazrina removed sysnam and update as necessary
**	    15.02.2005 Narinder  added procedure validatePeriod
**      31.12.2008 sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                           calcTankUsageMax, calcTankUsageMin.
**      17.01.2012 kumarsur  ECPD-18561:Added validateOverlappingPeriod - checking for overlapping events
*****************************************************************/

CURSOR c_tank_usage (p_object_id VARCHAR2, p_daytime DATE) IS
select
  -- tu.TANK_NO,
  -- tu.TANK_TYPE,
  -- tu.TERMINAL_CODE,
  -- tu.STORAGE_CODE,
  tu.DAYTIME,
  tu.CURRENT_MAX_VOL   max_working_capasity,
  tu.CURRENT_MIN_VOL   min_working_capasity
from TANK_USAGE tu, tank t
where
  -- tu.SYSNAM = p_sysnam AND tu.TERMINAL_CODE = p_terminal_code AND tu.STORAGE_CODE = p_storage_code AND
  tu.object_id = p_object_id AND
  -- t.SYSNAM = tu.SYSNAM AND t.TANK_NO = tu.TANK_NO AND t.TANK_TYPE = tu.TANK_TYPE AND
  tu.tank_id = t.object_id AND
  tu.DAYTIME = (SELECT Max(b.DAYTIME) FROM TANK_USAGE B
                WHERE b.object_id = b.object_id
                -- b.SYSNAM = tu.SYSNAM AND b.TANK_NO = tu.TANK_NO AND b.TANK_TYPE = tu.TANK_TYPE AND b.TERMINAL_CODE = tu.TERMINAL_CODE AND b.STORAGE_CODE = tu.STORAGE_CODE AND
                AND b.DAYTIME <= p_daytime);

-------------------------------------------------------------------------------------------------
-- calcTankUsageMax
-- Returns current Max working capasity vol for a given terminal,storage and day.
-------------------------------------------------------------------------------------------------
FUNCTION calcTankUsageMax(
           -- p_sysnam        VARCHAR2,
           -- p_terminal_code VARCHAR2,
           -- p_storage_code  VARCHAR2,
           p_object_id     VARCHAR2,
           p_daytime       DATE)
RETURN NUMBER IS

ln_return_value NUMBER;

BEGIN
   ln_return_value:=0;

   FOR mycur IN c_tank_usage(p_object_id, p_daytime) LOOP

    ln_return_value := ln_return_value + mycur.max_working_capasity;

   END LOOP;

   RETURN ln_return_value;

END calcTankUsageMax;

-------------------------------------------------------------------------------------------------
-- calcTankUsageMin
-- Returns current Min working capasity vol for a given terminal,storage and day.
-------------------------------------------------------------------------------------------------

FUNCTION calcTankUsageMin(
  -- p_sysnam        VARCHAR2,
  -- p_terminal_code VARCHAR2,
  -- p_storage_code  VARCHAR2,
   p_object_id     VARCHAR2,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_value NUMBER;

BEGIN

   ln_return_value:=0;

   FOR mycur IN c_tank_usage(p_object_id, p_daytime) LOOP

    ln_return_value := ln_return_value + mycur.min_working_capasity;

   END LOOP;

  RETURN ln_return_value;

END calcTankUsageMin;

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validatePeriod
-- Description    : Used to validate storage/tank periods.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using functions: EcDp_Objects.getObjStartDate
--                  EcDp_Objects.getObjEndDate
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validatePeriod(p_object_id storage.object_id%TYPE,
                         p_tank_id tank.object_id%TYPE,
                         p_end_date DATE)
--</EC-DOC>
IS

  ln_storage_end_date date;
  ln_tank_end_date date;

BEGIN

  ln_storage_end_date := ecdp_objects.GetObjEndDate(p_object_id);
  ln_tank_end_date := ecdp_objects.GetObjEndDate(p_tank_id);

  if p_end_date > ln_storage_end_date and p_end_date > ln_tank_end_date then
    RAISE_APPLICATION_ERROR(-20634, 'The End Date is after Storage End Date and Tank End Date');

  end if;

  if p_end_date > ln_storage_end_date then
    RAISE_APPLICATION_ERROR(-20635, 'The End Date is after Storage End Date');
  end if;

  if p_end_date > ln_tank_end_date then
    RAISE_APPLICATION_ERROR(-20636, 'The End Date is after Tank End Date');
  end if;

END validatePeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Checking for overlapping events.
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : TANK_USAGE
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_end_date   DATE,
                                    p_tank_id  VARCHAR2)
IS
  CURSOR c_tank IS
    SELECT *
      FROM tank_usage
     WHERE object_id = p_object_id
       AND tank_id = p_tank_id
       AND daytime <> p_daytime
       AND (end_date >= p_daytime OR end_date is null)
       AND (daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_tank IN c_tank LOOP
    lv_message := lv_message || cur_tank.tank_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20606,'A record is overlapping with an existing record.');
  END IF;

END validateOverlappingPeriod;

END EcBp_Tank_Usage;