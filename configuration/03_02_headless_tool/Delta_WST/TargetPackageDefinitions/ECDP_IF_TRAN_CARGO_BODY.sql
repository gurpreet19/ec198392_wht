CREATE OR REPLACE PACKAGE BODY ecdp_if_tran_cargo IS
/******************************************************************************
** Package        :  ecdp_if_tran_cargo, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Functions used by EC Production
**
** Documentation  :  www.energy-components.com
**
** Created  : 07.11.2006 Kari Sandvik
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ---------- -------- -------------------------------------------
** 	        09.01.2007 kaurrjes ECPD-4806: Added 6 new functions ie getLiftedGrsVolSM3, getLiftedGrsVolBBLS, getDayExpNotLiftedGrsSM3, getMthExpNotLiftedGrsSM3,
**					                    getDayExpNotLiftedGrsBBLS, getMthExpNotLiftedGrsBBLS
** 10.0     12.12.2008 oonnnng  ECPD-10330: Take away the trunc around daytime in getMthExpNotLiftedNetSM3, getMthExpNotLiftedNetBBLS,
**                              getMthExpNotLiftedGrsSM3 and getMthExpNotLiftedGrsBBLS functions.
**
********************************************************************/

CURSOR c_load_value (cp_storage_id VARCHAR2, cp_daytime DATE, cp_condition VARCHAR2, cp_unit VARCHAR2)
IS
	SELECT SUM(l.load_value) load_value
	FROM storage_lift_nomination n,
	     storage_lifting l,
	     product_meas_setup m,
	     lifting_measurement_item i
	WHERE n.object_id = cp_storage_id
	      AND n.bl_date = cp_daytime
	      AND n.parcel_no = l.parcel_no
	      AND l.product_meas_no = m.product_meas_no
	      AND m.lifting_event = 'LOAD'
	      AND m.item_code = i.item_code
	      AND i.item_condition = cp_condition
      	  AND i.unit = cp_unit;

CURSOR c_item (cp_storage_id VARCHAR2, cp_daytime DATE)
IS
	SELECT 	e.unit, e.item_condition
	FROM 	storage b,
	     	product c,
	     	product_meas_setup d,
	      	LIFTING_MEASUREMENT_ITEM e
	WHERE 	b.object_id = cp_storage_id
		AND	ec_stor_version.product_id(b.object_id, cp_daytime, '<=') = c.object_id
		AND c.object_id = d.object_id
		AND d.nom_unit_ind = 'Y'
		AND d.lifting_event = 'LOAD'
		AND d.item_code = e.item_code;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftedNetVolSM3
-- Description    : Get total lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftedNetVolSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_load_qty	NUMBER;
BEGIN
	FOR curValue IN c_load_value(p_storage_id, p_daytime, 'NET', 'SM3') LOOP
		ln_load_qty := curValue.load_value;
	END LOOP;
	RETURN ln_load_qty;
END getLiftedNetVolSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftedNetVolBBLS
-- Description    : Get total lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftedNetVolBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_load_qty	NUMBER;
BEGIN
	FOR curValue IN c_load_value(p_storage_id, p_daytime, 'NET', 'BBLS') LOOP
		ln_load_qty := curValue.load_value;
	END LOOP;
	RETURN ln_load_qty;

END getLiftedNetVolBBLS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftedGrsVolSM3
-- Description    : Get total lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftedGrsVolSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_load_qty	NUMBER;
BEGIN
	FOR curValue IN c_load_value(p_storage_id, p_daytime, 'GRS', 'SM3') LOOP
		ln_load_qty := curValue.load_value;
	END LOOP;
	RETURN ln_load_qty;
END getLiftedGrsVolSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftedGrsVolBBLS
-- Description    : Get total lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftedGrsVolBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_load_qty	NUMBER;
BEGIN
  FOR curValue IN c_load_value(p_storage_id, p_daytime, 'GRS', 'BBLS') LOOP
    ln_load_qty := curValue.load_value;
  END LOOP;
  RETURN ln_load_qty;

END getLiftedGrsVolBBLS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayExpNotLiftedNetSM3
-- Description    : Get exported not lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'DAY'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'SM3' AND  curItem.item_condition = 'NET' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;

END getDayExpNotLiftedNetSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayExpNotLiftedNetBBLS
-- Description    : Get exported not lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'DAY'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'BBLS' AND  curItem.item_condition = 'NET' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;

END getDayExpNotLiftedNetBBLS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMthExpNotLiftedNetSM3
-- Description    : Get exported not lifted for selected storage and month
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMthExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'MTH'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'SM3' AND  curItem.item_condition = 'NET' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;
END getMthExpNotLiftedNetSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMthExpNotLiftedNetBBLS
-- Description    : Get exported not lifted for selected storage and month
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMthExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'MTH'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'BBLS' AND  curItem.item_condition = 'NET' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;
END getMthExpNotLiftedNetBBLS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayExpNotLiftedGrsSM3
-- Description    : Get exported not lifted for selected storage and day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'DAY'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'SM3' AND  curItem.item_condition = 'GRS' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;

END getDayExpNotLiftedGrsSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMthExpNotLiftedGrsSM3
-- Description    : Get exported not lifted for selected storage and month
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMthExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'MTH'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'SM3' AND  curItem.item_condition = 'GRS' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;
END getMthExpNotLiftedGrsSM3;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayExpNotLiftedGrsBBLS
-- Description    : Get exported not lifted for selected storage
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'DAY'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'BBLS' AND  curItem.item_condition = 'GRS' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;

END getDayExpNotLiftedGrsBBLS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMthExpNotLiftedGrsBBLS
-- Description    : Get exported not lifted for selected storage and month
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMthExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_exp (cp_storage_id VARCHAR2,cp_daytime DATE) IS
  SELECT  sum(e.export_qty) export_qty
  FROM  stor_period_export_status e
  WHERE  e.object_id = cp_storage_id
    AND e.time_span = 'MTH'
    AND  e.daytime = p_daytime;

  ln_exp_qty  NUMBER;
BEGIN
  FOR curItem IN c_item(p_storage_id, p_daytime) LOOP
    IF curItem.unit = 'BBLS' AND  curItem.item_condition = 'GRS' THEN
      FOR curValue IN c_exp(p_storage_id, p_daytime) LOOP
        ln_exp_qty := curValue.export_qty;
      END LOOP;
    END IF;
  END LOOP;

  RETURN ln_exp_qty;
END getMthExpNotLiftedGrsBBLS;


END ecdp_if_tran_cargo;