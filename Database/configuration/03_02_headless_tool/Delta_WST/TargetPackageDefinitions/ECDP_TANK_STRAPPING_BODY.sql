CREATE OR REPLACE PACKAGE BODY EcDp_Tank_Strapping IS
/****************************************************************
** Package        :  EcDp_Tank_Strapping, body part
**
** $Revision: 1.15 $
**
** Purpose        :  Finds tank volumes
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2001  Harald Vetrhus
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  ------     ----- --------------------------------------
**          18.02.2004 SHN   Added procedure CopyCurrentStrapping
**          29.04.2004 FBa   Removed functions findVolumeByStrappingTable, calcRoofDisplacement, findVolume, findWaterVolume
**                           Added functions findVolumeFromDip, findMassFromDip
**          08.06.2004 HNE   Bugfix. Cursors to find dip_level used daytime <= p_daytime. That could included more than one strapping table.
**                           Calling prosedure finds correct date for strapping table. Changed cursors to daytime = p_daytime.
**          03.08.2004 kaurrnar      removed sysnam and update as necessary
**          10.08.2004 HNE   Bugfix. Cursor in getDipLevelBelow uses MIN function, it should be MAX function.
**                           Cursor in getSumDipLevelsBelow must include p_dip_level
**                           Call to EcBp_MathLib.interpolateLinear from findValueFromDip when lv2_strapping_method = 'STRAP_INCREMENT', must hardcode ln_lower_value to 0.
**          24.05.2005  kaurrnar  Removed deadcodes. Changed TANK_ATTRIBUTE to TANK_VERSION
**          23.09.2008  LeongWen  Added Procedures of (SetPrevEndDate) and (setEnddate) to resolve the problem of TANK STRAPPING (ECPD-6308 and ECPD-7555). Also,
**                                modified the (CopyCurrentStrapping) procedure to adopt the use of IUD triggers that's to refer to DV_TANK_STRAPPING instead of
**                                TANK_STRAPPING for records insertion using DML statement.
**          10.04.2009  oonnnng  ECPD-6067: Add additional paramter 'nvl(p_new_object_id, p_curr_object_id)' in CopyCurrentStrapping function.
*****************************************************************/

-- Local function used by findVolumeFromDip
FUNCTION getDipLevelAbove(p_tank_object_id VARCHAR2, p_dip_level NUMBER, p_daytime DATE)
RETURN NUMBER IS

  ln_retval               NUMBER;

  CURSOR cur_dip_level_above (p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT MIN(dip_level) AS dip_level
  FROM tank_strapping
  WHERE object_id = p_object_id
  AND dip_level >= p_dip_level AND daytime = p_daytime;

BEGIN
  FOR c_upper_dip IN cur_dip_level_above(p_tank_object_id, p_daytime) LOOP
    ln_retval := c_upper_dip.dip_level;
  END LOOP;

  RETURN ln_retval;
END getDipLevelAbove;


-- Local function used by findVolumeFromDip
FUNCTION getDipLevelBelow(p_tank_object_id VARCHAR2, p_dip_level NUMBER, p_daytime DATE)
RETURN NUMBER IS

  ln_retval               NUMBER;

  CURSOR cur_dip_level_below (p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT MAX(dip_level) AS dip_level
  FROM tank_strapping
  WHERE object_id = p_object_id
  AND dip_level <= p_dip_level AND daytime = p_daytime;

BEGIN
  FOR c_lower_dip IN cur_dip_level_below(p_tank_object_id, p_daytime) LOOP
    ln_retval := c_lower_dip.dip_level;
  END LOOP;

  RETURN ln_retval;
END getDipLevelBelow;


-- Local function used by findVolumeFromDip
FUNCTION getSumDipLevelsBelow(p_tank_object_id VARCHAR2, p_dip_level NUMBER, p_daytime DATE)
RETURN NUMBER IS

  ln_retval               NUMBER;

  CURSOR cur_sum_dip_level_below (p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT SUM(storage_value) AS value
  FROM tank_strapping
  WHERE object_id = p_object_id
  AND dip_level <= p_dip_level AND daytime = p_daytime;

BEGIN
  FOR c_lower_dip IN cur_sum_dip_level_below(p_tank_object_id, p_daytime) LOOP
    ln_retval := c_lower_dip.value;
  END LOOP;

  RETURN ln_retval;
END getSumDipLevelsBelow;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findValueFromDip
--
-- Description    : Returns the value matcing the dip level
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
FUNCTION findValueFromDip (
  p_tank_object_id    TANK.OBJECT_ID%TYPE,
  p_dip_level          NUMBER,
  p_daytime           DATE,
    p_strap_value_type  VARCHAR2        -- 'VOLUME' or 'MASS'
  )

RETURN NUMBER
--</EC-DOC>
IS

  lv2_strapping_method    VARCHAR2(300);
  lv2_strap_value_type    VARCHAR2(300);

  ld_strapping_table_date DATE;

  ln_upper_level          NUMBER;
  ln_lower_level          NUMBER;

  ln_return_val           NUMBER;
  ln_upper_value          NUMBER;
  ln_lower_value          NUMBER;
  ln_sum_below_lower      NUMBER;

  ln_value_per_dip_fact   NUMBER;

  CURSOR c_strapping_date IS
  SELECT MAX(daytime) AS daytime
  FROM tank_strapping
  WHERE object_id = p_tank_object_id
  AND daytime <= p_daytime;

BEGIN

  -- Get the last valid strapping table date befor parameter p_daytime.
  FOR c_strapping_table_date IN c_strapping_date LOOP
    ld_strapping_table_date := c_strapping_table_date.daytime;
  END LOOP;

  -- Get current method
  lv2_strapping_method := ec_tank_version.STRAPPING_METHOD(
                                                           p_tank_object_id,
                                                           p_daytime,
                                                           '<=');

  -- Get current strap value type (is tank reading mass or volume)
  lv2_strap_value_type := ec_tank_version.STRAP_VALUE_TYPE(
                                                           p_tank_object_id,
                                                           p_daytime,
                                                           '<=');

  IF p_strap_value_type <> lv2_strap_value_type THEN
    ln_return_val := NULL;                                 -- Asking for mass while tank holds volume or vice versa

  --
  ELSIF lv2_strapping_method IS NULL THEN
    ln_return_val := NULL;                                 -- Unable to determine method for strapping

  --
  ELSIF lv2_strapping_method = 'STRAP_TOTAL_VOL' THEN
    ln_upper_level := getDipLevelAbove(p_tank_object_id, p_dip_level, ld_strapping_table_date);
    ln_lower_level := getDipLevelBelow(p_tank_object_id, p_dip_level, ld_strapping_table_date);

    IF ln_upper_level IS NULL OR ln_lower_level IS NULL THEN
      ln_return_val := NULL;                               -- Out of range
    ELSE
      ln_lower_value := ec_tank_strapping.storage_value(p_tank_object_id, ld_strapping_table_date, ln_lower_level);
      ln_upper_value := ec_tank_strapping.storage_value(p_tank_object_id, ld_strapping_table_date, ln_upper_level);

      ln_return_val := EcBp_MathLib.interpolateLinear(p_dip_level, ln_lower_level, ln_upper_level, ln_lower_value, ln_upper_value);
    END IF;

  --
  ELSIF lv2_strapping_method = 'STRAP_INCREMENT' THEN -- Each dip level gives the volume between this and previous.
    ln_upper_level := getDipLevelAbove(p_tank_object_id, p_dip_level, ld_strapping_table_date);
    ln_lower_level := getDipLevelBelow(p_tank_object_id, p_dip_level, ld_strapping_table_date);

    IF ln_upper_level IS NULL OR ln_lower_level IS NULL THEN
      ln_return_val := NULL;                               -- Out of range
    ELSE
      ln_lower_value := ec_tank_strapping.storage_value(p_tank_object_id, ld_strapping_table_date, ln_lower_level);
      ln_upper_value := ec_tank_strapping.storage_value(p_tank_object_id, ld_strapping_table_date, ln_upper_level);

      -- The lower and upper volume is only WITHIN the current interval. Add previous intervals as well!
      ln_sum_below_lower := getSumDipLevelsBelow(p_tank_object_id, p_dip_level, ld_strapping_table_date);

      ln_return_val := EcBp_MathLib.interpolateLinear(p_dip_level, ln_lower_level, ln_upper_level, 0, ln_upper_value)
                       + ln_sum_below_lower;
    END IF;

  --
  ELSIF lv2_strapping_method = 'FIXED_INCREMENT' THEN -- Not really any strapping, just value = factor * dip
    ln_value_per_dip_fact := ec_tank_version.VAL_PER_DIP_FACT(
                                                               p_tank_object_id, p_daytime,
                                                               '<=');
    ln_return_val := p_dip_level * ln_value_per_dip_fact;

  END IF;

  RETURN ln_return_val;

END findValueFromDip;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findVolumeFromDip
--
-- Description    : Returns the volume matcing the dip level
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: findValueFromDip
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findVolumeFromDip (
  p_tank_object_id    TANK.OBJECT_ID%TYPE,
  p_dip_level          NUMBER,
  p_daytime           DATE
  ) RETURN NUMBER
--</EC-DOC>
IS

  ln_retval           NUMBER;

BEGIN
  ln_retval := findValueFromDip(p_tank_object_id, p_dip_level, p_daytime, 'VOLUME');

  RETURN ln_retval;
END findVolumeFromDip;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findMassFromDip
--
-- Description    : Returns the mass matcing the dip level
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: findValueFromDip
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findMassFromDip (
  p_tank_object_id    TANK.OBJECT_ID%TYPE,
  p_dip_level          NUMBER,
  p_daytime           DATE
  ) RETURN NUMBER
--</EC-DOC>
IS

  ln_retval           NUMBER;

BEGIN
  ln_retval := findValueFromDip(p_tank_object_id, p_dip_level, p_daytime, 'MASS');

  RETURN ln_retval;
END findMassFromDip;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CopyCurrentStrapping
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : - tank_strapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       : Creates a new tank strapping based on current tank strapping.
--                  The strapping is either created on a new tank or on current tank.
--                  If p_new_object_id is null the strapping will be created on current tank.
---------------------------------------------------------------------------------------------------
PROCEDURE CopyCurrentStrapping(p_daytime          DATE,
                               p_curr_object_id    VARCHAR2,
                               p_new_object_id     VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

  -- Locate current tank strapping
  CURSOR c_tank_strapping IS
  SELECT * FROM tank_strapping
  WHERE object_id = p_curr_object_id
  AND daytime = (SELECT MAX(daytime)
                  FROM tank_strapping
                  WHERE object_id = p_curr_object_id);

  CURSOR c_next_tank_strapping IS
  SELECT daytime FROM tank_strapping
  WHERE object_id = Nvl(p_new_object_id,p_curr_object_id)
  AND daytime > (SELECT MIN(daytime)
                  FROM tank_strapping
                  WHERE object_id = p_curr_object_id
                  AND daytime > p_daytime);

  lv2_target_object_id      VARCHAR2(32);
  ld_next_daytime           DATE := NULL;
  lv_inserted               VARCHAR2(1) := 'N';

BEGIN
  lv2_target_object_id := Nvl(p_new_object_id,p_curr_object_id);
  FOR curTankStrapping IN c_tank_strapping LOOP
    IF p_daytime IS NOT NULL THEN

      curTankStrapping.daytime := p_daytime;
      curTankStrapping.object_id := lv2_target_object_id;
      curTankStrapping.last_updated_by := null;
      curTankStrapping.last_updated_date := null;
      curTankStrapping.created_by := user;
      curTankStrapping.created_date := EcDp_Date_Time.getCurrentSysdate;

      FOR curnext IN c_next_tank_strapping LOOP
        ld_next_daytime := curnext.Daytime;
      END LOOP;

      EcDp_Month_Lock.validatePeriodForLockOverlap('PROCEDURE',p_daytime,ld_next_daytime,
        'EcDp_tank_Strapping.CopyCurrentStrapping: Can not do this when there are locked months in the lifespan of these values', nvl(p_new_object_id, p_curr_object_id));

      -- Note: You need to refer to [TANK_STRAPPING] here instead of [DV_TANK_STRAPPING]
      -- This is due to buildmagic will compile the packages before creating the dv classes
      -- so the package will call a view that does not exist.
      -- Commented by: Leongwen based on the maintenance of ECPD-6308 and 7555
      INSERT INTO tank_strapping VALUES curTankStrapping;
      lv_inserted := 'Y';

    END IF;
  END LOOP;

  if lv_inserted = 'Y' then
      EcDp_Tank_Strapping.SetPrevEndDate(lv2_target_object_id, p_daytime, NULL, 'INSERT');
  end if;

END CopyCurrentStrapping;

---------------------------------------------------------------------------------------------------
-- Procedure      : SetPrevEndDate
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : DV_TANK_STRAPPING
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       : Set the end_date of previous day's records with the current new datetime during
--                  new record insertions. Also, it calls another procedure (setEnddate) to update the end_date
--                  of the respective previous day's records during updating or deleting the existing records.
---------------------------------------------------------------------------------------------------
PROCEDURE SetPrevEndDate( p_object_id     VARCHAR2,
                          p_newDaytime    DATE,
                          p_oldDaytime    DATE,
                          p_DML_Type      VARCHAR2)
IS

  ld_mindate tank_strapping.daytime%type := NULL;
  ld_maxdate tank_strapping.daytime%type := NULL;

  --CURSOR c_prevdate IS
  CURSOR c_getMinDate IS
  SELECT Min(daytime)
  FROM TANK_STRAPPING
  WHERE object_id = p_object_id
  AND daytime > p_newDaytime;

  CURSOR c_getMaxDate IS
  SELECT Max(daytime)
  FROM TANK_STRAPPING
  WHERE object_id = p_object_id
  AND daytime < p_newDaytime;

BEGIN
  If upper(p_DML_Type) = 'INSERT' then

    -- update prior end date (if any)
    Open c_getMaxDate;
    Fetch c_getMaxDate into ld_maxdate;
    Close c_getMaxDate;

    if ld_maxdate is NOT null then
      -- Note: Do not use DV_TANK_STRAPPING here as this will trigger the IUD again to further delay the process!
      UPDATE TANK_STRAPPING
      SET end_date = p_newDaytime
      WHERE object_id = p_object_id
      AND nvl(end_date, to_date('01.01.1900', 'dd.mm.yyyy')) <> p_newDaytime
      AND daytime = ld_maxdate;
    end if;

    --update this if any next records
    Open c_getMinDate;
    Fetch c_getMinDate into ld_mindate;
    Close c_getMinDate;

    if ld_mindate is NOT null then
      -- Note: Do not use DV_TANK_STRAPPING here as this will trigger the IUD again to further delay the process!
      UPDATE TANK_STRAPPING
      SET end_date = ld_mindate
      WHERE object_id = p_object_id
      AND daytime = p_newDaytime
      AND nvl(end_date, to_date('01.01.1900', 'dd.mm.yyyy')) <> ld_mindate;
    end if;

  Elsif upper(p_DML_Type) = 'UPDATE' then
    If p_newDaytime <> p_oldDaytime then
      -- update the end_date based on new daytime
      EcDp_TANK_STRAPPING.setEnddate(p_object_id, p_newDaytime,'NEW');
      -- update the end_date based on old daytime
      EcDp_TANK_STRAPPING.setEnddate(p_object_id, p_oldDaytime,'OLD');
    End if;
  Elsif upper(p_DML_Type) = 'DELETE' then
    -- update the end_date based on old daytime
    EcDp_TANK_STRAPPING.setEnddate(p_object_id, p_oldDaytime,'OLD');
  End if;
END SetPrevEndDate;

---------------------------------------------------------------------------------------------------
-- Procedure      : setEnddate
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : DV_TANK_STRAPPING
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       : This procedure was called by PROCEDURE SetPrevEndDate to update the end_date
--                  of the respective previous day's records during updating or deleting the existing records.
---------------------------------------------------------------------------------------------------
PROCEDURE setEnddate(p_object_id VARCHAR2,
                     p_daytime DATE,
                     p_type VARCHAR2)
IS
  ld_nextdate tank_strapping.daytime%type := NULL;
  ld_prevdate tank_strapping.daytime%type := NULL;
  n_last_updated_by VARCHAR2(30) := USER;
  n_last_updated_date DATE := EcDp_Date_Time.getCurrentSysdate;

  CURSOR c_tank_strapping IS
  SELECT distinct daytime FROM tank_strapping ts
  WHERE ts.object_id = p_object_id
  AND DAYTIME between ld_prevdate and ld_nextdate
  ORDER BY daytime DESC;

  CURSOR c_get_nextdate IS
  select min(daytime) result
  from tank_strapping
  where object_id = p_object_id
  and daytime > p_daytime ;

  CURSOR c_get_prevdate IS
  select max(daytime) result
  from tank_strapping
  where object_id = p_object_id
  and daytime < p_daytime;

  ld_last_daytime DATE := NULL;

BEGIN
  for mycur in c_get_nextdate LOOP
    ld_nextdate := mycur.result;
  end loop;
  for mycur in c_get_prevdate LOOP
    ld_prevdate := mycur.result;
  end loop;

  if ld_nextdate is null and ld_prevdate is not null then
    ld_nextdate := p_daytime;
  elsif ld_nextdate is not null and ld_prevdate is null then
    ld_prevdate := p_daytime;
  elsif ld_nextdate is null and ld_prevdate is null then
    ld_prevdate := p_daytime;
    ld_nextdate := p_daytime;
  End if ;

  FOR cur_ts IN c_tank_strapping LOOP
    if cur_ts.daytime <= p_daytime then

      if p_type = 'OLD' and cur_ts.daytime = p_daytime then
         Exit;
      end if;

      -- Note: Do not use DV_TANK_STRAPPING here as this will trigger the IUD again to further delay the process!
      UPDATE TANK_STRAPPING
      SET end_date = ld_last_daytime
      WHERE object_id = p_object_id
      AND   daytime = cur_ts.daytime
      AND   nvl(end_date, to_date('01.01.1900', 'dd.mm.yyyy')) <> nvl(ld_last_daytime, to_date('01.01.1900', 'dd.mm.yyyy'));

    end if;

    if ld_last_daytime is null then
      ld_last_daytime := cur_ts.daytime;
    else
        if ld_last_daytime != cur_ts.daytime then
          ld_last_daytime := cur_ts.daytime;
        end if;
    end if;

  END LOOP;
END setEnddate;

END EcDp_Tank_Strapping;