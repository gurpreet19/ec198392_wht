CREATE OR REPLACE PACKAGE BODY EcBP_Storage_Lifting IS
/******************************************************************************
** Package        :  EcBP_Storage_Lifting, body part
**
** $Revision: 1.16 $
**
** Purpose        :  Business logic for storage liftings
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.10.2004 Kari Sandvik
**
** Modification history:
**
** Date       Whom      Change description:
** ------     -----     -----------------------------------------------------------------------------------------------
** 01.03.2005 kaurrnar	Removed references to ec_xxx_attribute packages
** 11.10.2005 skjorsti	Modified function getProdMeasNo, added function calcExpUnload, and procedure calcLiftedValue
** 12.10.2005 skjorsti  Added function getLiftedValue
** 02.11.2005 DN        Function getLiftedValue: Better cursor-select.
** 14.01.2012 meisihil  Added function getHourlyLiftedValue
** 03.07.2017 asareswi  ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
** 23.10.2018 asareswi  ECPD-59464: Fixed issue in getHourlyLiftedValue
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcExpUnload
-- Description    : Calculate expected unload
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

FUNCTION calcExpUnload (p_parcel_no NUMBER,
                       p_product_meas_no NUMBER)

RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN ue_storage_lifting.calcExpUnload(p_parcel_no, p_product_meas_no);

END calcExpUnload;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcLiftedValue
-- Description    : Calculate lifted value
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


PROCEDURE calcLiftedValue (p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN

   ue_storage_lifting.calcLiftedValue(p_parcel_no);

END calcLiftedValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcUnloadValue
-- Description    : Calculate unload value
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
PROCEDURE calcUnloadValue (p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN

   ue_storage_lifting.calcUnloadValue(p_parcel_no);

END calcUnloadValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftedValueByUnloadItem
-- Description    : Returns the lifted value for the by means of the corresponding unload product item.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : product_meas_setup, storage_lifting
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftedValueByUnloadItem (p_parcel_no NUMBER, p_product_meas_no NUMBER) RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_value (cp_parcel_no NUMBER, cp_product_meas_no NUMBER) IS
SELECT sl.load_value
FROM product_meas_setup src, product_meas_setup tar, storage_lifting sl
WHERE src.product_meas_no = cp_product_meas_no
AND src.lifting_event = 'UNLOAD'
AND tar.item_code = src.item_code
AND tar.object_id = src.object_id
AND tar.lifting_event = 'LOAD'
AND sl.parcel_no = cp_parcel_no
AND sl.product_meas_no = tar.product_meas_no
;

ln_value NUMBER;

BEGIN

   FOR curValue IN c_value (p_parcel_no, p_product_meas_no) LOOP

      ln_value := curValue.load_value;

   END LOOP;

   RETURN ln_value;

END getLiftedValueByUnloadItem;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProdMeasNo
-- Description    : Gets product meas no for the nominated unit set for product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : product_meas_setup
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProdMeasNo(	p_parcel_no NUMBER, p_lifting_event VARCHAR2 DEFAULT 'LOAD')
RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_product_meas (cp_parcel_no NUMBER, cp_lifting_event VARCHAR2)
IS
SELECT 	d.product_meas_no
FROM 	storage_lift_nomination a,
      storage b,
     	product c,
     	product_meas_setup d
WHERE 	a.parcel_no = cp_parcel_no AND
        a.object_id = b.object_id AND
      	ec_stor_version.product_id(b.object_id, Ecdp_Timestamp.getCurrentSysdate, '<=') = c.object_id AND -- obs Ecdp_Timestamp.getCurrentSysdate(but better than object start date)
      	c.object_id = d.object_id AND
        d.nom_unit_ind = 'Y' AND
        d.lifting_event = cp_lifting_event;

ln_prod_meas_no		NUMBER;

BEGIN

   FOR curNo IN c_product_meas (p_parcel_no, p_lifting_event) LOOP
   	ln_prod_meas_no := curNo.product_meas_no;
   END LOOP;

   RETURN ln_prod_meas_no;

END getProdMeasNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getHourlyLiftedValue
-- Description    : Gets hourly measurement based on lifting start and lifting end and storage lifting
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
FUNCTION getHourlyLiftedValue(p_parcel_no NUMBER, p_daytime DATE, p_product_meas_no NUMBER, p_activity_type VARCHAR2 DEFAULT 'LOAD')
RETURN NUMBER
--</EC-DOC>
IS
	ln_unload NUMBER;
	ln_hours NUMBER;
	lv_summertime VARCHAR2(1);
	lv_to_summertime VARCHAR2(1);

	CURSOR c_noms(cp_parcel_no NUMBER, cp_daytime DATE, cp_product_meas_no NUMBER)
	IS
		SELECT parcel_no,
		       ec_storage_lifting.load_value(parcel_no, cp_product_meas_no) meas_qty,
               EcBp_Cargo_Activity.getLiftingStartDate(cargo_no, p_activity_type) lifting_start_date,
               EcBp_Cargo_Activity.getLiftingEndDate(cargo_no, p_activity_type) lifting_end_date
	      FROM storage_lift_nomination s
	     WHERE parcel_no = cp_parcel_no;
BEGIN
	FOR c_cur IN c_noms(p_parcel_no, p_daytime, p_product_meas_no) LOOP
		IF c_cur.lifting_start_date IS NOT NULL AND c_cur.lifting_end_date IS NOT NULL AND c_cur.lifting_end_date > c_cur.lifting_start_date AND c_cur.meas_qty IS NOT NULL THEN
			IF trunc(c_cur.lifting_start_date,'HH') > p_daytime OR c_cur.lifting_end_date <= p_daytime THEN
				ln_unload := 0;
			ELSE
				-- Measurement exists
				ln_hours := (c_cur.lifting_end_date - c_cur.lifting_start_date) * 24;
				lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(c_cur.lifting_start_date));
				lv_to_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(c_cur.lifting_end_date));
				IF lv_summertime = 'Y' AND lv_to_summertime = 'N' THEN
					ln_hours := ln_hours + 1;
				ELSIF lv_summertime = 'N' AND lv_to_summertime = 'Y' THEN
					ln_hours := ln_hours - 1;
				END IF;
				ln_unload := c_cur.meas_qty / ln_hours;
			END IF;

			-- Check if current hour is full unload hour
			IF TRUNC(c_cur.lifting_start_date, 'HH') = p_daytime AND c_cur.lifting_start_date != TRUNC(c_cur.lifting_start_date, 'HH') THEN
				ln_unload := ln_unload * (1/24 - c_cur.lifting_start_date - p_daytime) * - 24;
			ELSIF TRUNC(c_cur.lifting_end_date, 'HH') = p_daytime AND c_cur.lifting_end_date != TRUNC(c_cur.lifting_end_date, 'HH') THEN
				ln_unload := ln_unload * (c_cur.lifting_end_date - p_daytime) * 24;
			END IF;
		END IF;
	END LOOP;

	RETURN ln_unload;
END getHourlyLiftedValue;

END EcBP_Storage_Lifting;