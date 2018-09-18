CREATE OR REPLACE PACKAGE BODY ue_alloc_method IS
/******************************************************************************
** Package        :  ue_alloc_method, body part
**
** $Revision: 1.1.2.6 $
**
** Purpose        :  Includes user-exit functionality for Meter Allocation Method screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.05.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** ------      -----    -----------------------------------------------------------------------------------------------
** 06-06-2012  farhaann ECPD-20855: Added checkNomPoint and validateAllocMethod procedure
** 12-07-2012  farhaann ECPD-21466: Added validateMeterLoc and validateOverlappingPeriod
** 25-07-2012  sharawan ECPD-21464:Added getMeterFromCntrInv to get meter id that is connected to the contract inventory
** 01-08-2012  farhaann ECPD-21466: Modified validateMeterLoc and validateOverlappingPeriod
*/

---------------------------------------------------------------------------------------------------
-- Procedure      : checkNomPoint
-- Description    : This procedure will check if there is any record exists in METER_ALLOC_METHOD_NP table per alloc_method_seq.
--                  If yes, then other record cannot be saved.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : METER_ALLOC_METHOD_NP
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE checkNomPoint(p_alloc_method_seq NUMBER) IS

  CURSOR c_exists IS
    select 1 one
      from METER_ALLOC_METHOD_NP
     where alloc_method_seq = p_alloc_method_seq;

BEGIN

  FOR mycur IN c_exists LOOP
    RAISE_APPLICATION_ERROR(-20568,
                            'Only one nomination point per meter can be inserted.');
  END LOOP;

END checkNomPoint;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateAllocMethod
-- Description    : This procedure will check if there is any record exists in METER_ALLOC_METHOD table per alloc_method_seq
--                  and have alloc method, Prorata.
--                  If yes, then no record can be saved in nomination point configuration section.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : METER_ALLOC_METHOD
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateAllocMethod(p_alloc_method_seq NUMBER) IS

  ln_cnt NUMBER := 0;
BEGIN

  select count(*)
    into ln_cnt
    from METER_ALLOC_METHOD a
   where a.alloc_method_seq = p_alloc_method_seq
     and a.alloc_method = 'PRORATA';

  IF ln_cnt = 1 THEN
    RAISE_APPLICATION_ERROR(-20569,
                            'Only meter with alloc method Swing or OBA can insert the nomination point.');

  END IF;

END validateAllocMethod;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateMeterLoc
-- Description    : This procedure will check for overlapping period for different meter
--                  in the same location (delivery stream or delivery point)
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : METER_ALLOC_METHOD, METER_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateMeterLoc(p_object_id  VARCHAR2,
                           p_daytime    DATE,
                           p_end_date   DATE
                           )
IS

  CURSOR c_meter(cp_location VARCHAR2) IS
   SELECT *
    FROM meter_alloc_method a
     WHERE a.daytime <> p_daytime
     AND (a.end_date >= p_daytime OR a.end_date IS NULL)
     AND (a.daytime < p_end_date OR p_end_date IS NULL)
     AND a.object_id in
                     (SELECT object_id
                        FROM meter_version b
                       WHERE b.delivery_point_id = cp_location
                          OR b.delivery_stream_id = cp_location)
     AND a.object_id != p_object_id;

  lv_location VARCHAR2(32);
  lv_meter VARCHAR2(240);
  ln_cnt NUMBER;

BEGIN
  lv_location := nvl(ec_meter_version.delivery_stream_id(p_object_id,p_daytime,'<='),ec_meter_version.delivery_point_id(p_object_id,p_daytime,'<='));

  FOR cur_meter IN c_meter(lv_location) LOOP
    lv_meter := ecdp_objects.GetObjName(cur_meter.object_id, cur_meter.daytime);
  END LOOP;

  SELECT count(*) into ln_cnt
    FROM meter_alloc_method a
   WHERE a.daytime <> p_daytime
     AND (a.end_date >= p_daytime OR a.end_date IS NULL)
     AND (a.daytime < p_end_date OR p_end_date IS NULL)
     AND a.object_id in
                     (SELECT object_id
                        FROM meter_version b
                       WHERE b.delivery_point_id = lv_location
                          OR b.delivery_stream_id = lv_location)
     AND a.object_id != p_object_id;

  IF ln_cnt > 0 THEN
	RAISE_APPLICATION_ERROR(-20000, 'Meter/location overlaps with meter/location '|| lv_meter || ' for given date.\n\n');
  END IF;

END validateMeterLoc;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : This procedure will check for overlapping period for
--                  same meter, method and level
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : METER_ALLOC_METHOD
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_end_date   DATE,
                                    p_alloc_level VARCHAR2
                                    )
IS
    CURSOR c_meter IS
    SELECT *
      FROM meter_alloc_method a
     WHERE a.object_id = p_object_id
       AND a.daytime <> p_daytime
       AND (a.end_date >= p_daytime OR a.end_date is null)
       AND (a.daytime < p_end_date OR p_end_date IS NULL)
       AND a.alloc_level = p_alloc_level;

  lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_meter IN c_meter LOOP
    lv_message := lv_message || cur_meter.object_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
	  RAISE_APPLICATION_ERROR(-20000, 'Meter/location overlaps with meter/location '|| EcDp_Objects.GetObjName(p_object_id,p_daytime) || ' for given date.\n\n');
  END IF;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeterFromCntrInv
-- Description    : To get meter id that is connected to the contract inventory
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : meter_alloc_method_np, meter_alloc_method
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMeterFromCntrInv(
  p_object_id VARCHAR2,
  p_daytime DATE
)
RETURN VARCHAR2
--</EC-DOC>
IS
    lv_meter_id   VARCHAR2(32);

    CURSOR c_inv_meter IS
    SELECT distinct(m.object_id) METER_ID
    FROM meter_alloc_method_np n, meter_alloc_method m
    WHERE n.alloc_method_seq = m.alloc_method_seq
    AND n.contract_inventory = p_object_id
    AND p_daytime BETWEEN m.DAYTIME AND nvl(m.end_date, p_daytime + 1);

BEGIN

    FOR curInvMeter IN c_inv_meter LOOP
		    lv_meter_id := curInvMeter.METER_ID;
    END LOOP;

    IF lv_meter_id IS NULL THEN
       return null;
    else
       return lv_meter_id;
    END IF;

END getMeterFromCntrInv;

END ue_alloc_method;