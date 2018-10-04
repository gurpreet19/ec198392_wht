CREATE OR REPLACE PACKAGE BODY UE_STORAGE_LIFTING IS
/******************************************************************************
** Package        :  UE_STORAGE_LIFTING, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2005 Stian Skj?tad
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 1.0   13.10.2005  skjorsti	Added procedure calcUnloadValue
** 1.5   12.09.2012  meisihil   ECPD-20962: Added function setBalanceDeltaQty
** -------  ------   ----- -----------------------------------------------------------------------------------------------
*/

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcExpUnload
-- Description    : Calculate expected unload. User exit function.
--
-- Preconditions  : product_meas_no used as input must be checked if it is LOAD or UNLOAD
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  FUNCTION calcExpUnload(
  	ceu_parcel_no NUMBER,
  	ceu_product_meas_no NUMBER)

RETURN NUMBER
--</EC-DOC>
IS
BEGIN

RETURN NULL;
END calcExpUnload;


  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcUnloadValue
-- Description    : Calculate unload value. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  PROCEDURE calcUnloadValue(
  	cuv_parcel_no NUMBER)

--</EC-DOC>
IS
BEGIN

NULL;
END calcUnloadValue;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcLiftedValue
-- Description    : Calculate lifted value. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------


PROCEDURE calcLiftedValue (
	clv_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN



NULL;
END calcLiftedValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setBalanceDeltaQty
-- Description    : Will sum all the seperate delta quantities and store it on the BALANCE_DELTA_QTY measurement item.
--					User exit function
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setBalanceDeltaQty(
	p_parcel_no NUMBER,
	p_lifting_event VARCHAR2 DEFAULT 'LOAD',
	p_xtra_qty NUMBER DEFAULT 0)
IS
	CURSOR c_inventory_delta(cp_parcel_no NUMBER, cp_lifting_event VARCHAR2, cp_unit VARCHAR2)
	IS
		SELECT sl.load_value, src.balance_qty_type, src.product_meas_no
		  FROM product_meas_setup src, storage_lifting sl, lifting_measurement_item i
		 WHERE src.balance_qty_type IS NOT NULL
		   AND src.lifting_event = cp_lifting_event
		   AND sl.parcel_no = cp_parcel_no
		   AND sl.product_meas_no = src.product_meas_no
		   and i.item_code = src.item_code
		   AND i.unit = cp_unit;

	CURSOR c_unit(p_parcel_no NUMBER, cp_event VARCHAR2, cp_xtra_qty NUMBER)
	IS
        SELECT m.unit
          FROM lifting_measurement_item m, product_meas_setup s, stor_version sv, storage_lift_nomination n
         WHERE sv.object_id = n.object_id
           AND n.parcel_no = p_parcel_no
           AND s.object_id = sv.product_id
           AND m.item_code = s.item_code
           AND s.lifting_event = cp_event
           AND ((s.nom_unit_ind = 'Y' and 0 = cp_xtra_qty) or (s.nom_unit_ind2 = 'Y' and 1 = cp_xtra_qty) or (s.nom_unit_ind3 = 'Y' and 2 = cp_xtra_qty));

	ln_result NUMBER;
	ln_balance_meas_no NUMBER;
	lv_balance_delta_qty VARCHAR2(32);
BEGIN
	IF p_xtra_qty = 1 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY2';
	ELSIF p_xtra_qty = 2 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY3';
	ELSE
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY';
	END IF;

	FOR c_cur_unit IN c_unit(p_parcel_no, p_lifting_event, p_xtra_qty) LOOP
		FOR c_cur IN c_inventory_delta(p_parcel_no, p_lifting_event, c_cur_unit.unit) LOOP
			IF c_cur.balance_qty_type = lv_balance_delta_qty THEN
				ln_balance_meas_no := c_cur.product_meas_no;
			ELSIF c_cur.load_value IS NOT NULL THEN
				ln_result := Nvl(ln_result, 0) + c_cur.load_value;
			END IF;
		END LOOP;
	END LOOP;

	IF ln_balance_meas_no IS NOT NULL THEN
		UPDATE storage_lifting SET load_value = ln_result WHERE parcel_no = p_parcel_no AND product_meas_no = ln_balance_meas_no;
	END IF;
END setBalanceDeltaQty;

END UE_STORAGE_LIFTING;

