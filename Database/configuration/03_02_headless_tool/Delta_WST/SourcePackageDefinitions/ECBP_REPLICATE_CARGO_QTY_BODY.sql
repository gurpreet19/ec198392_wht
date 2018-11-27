CREATE OR REPLACE PACKAGE BODY EcBp_Replicate_Cargo_Qty IS
/******************************************************************************
** Package        :  EcBp_Replicate_Cargo_Qty, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Replicate quantities from sale into ifac_quantities
**
** Documentation  :  www.energy-components.com
**
** Created  		:	09.03.2006 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 09.03.2006		Jean Ferr�nitial version
** 04.04.2006	Kari Sandvik	Updated
** 07.04.2006	Arild Vervik	Added Exportparselsplit and replicateMeL, checked in redesigned package
** 18.04.2006 Arild Vervik  Replaced hardcoded tablereferences with placeholders for install script.
** 06.10.2006 Jerome Chong  Tracker 4490 - Updated replicateMeL to use stor_period_export_status table
********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : insertQty
-- Description    : Inserts a row into the ifac_quantities table
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
PROCEDURE insertQty(p_product_code VARCHAR2,
					p_company_code VARCHAR2,
					p_profit_centre_code VARCHAR2,
					p_daytime DATE,
					p_qty_type VARCHAR2,
					p_qty NUMBER,
					p_uom VARCHAR2)
--</EC-DOC>
IS
	CURSOR c_exist (cp_daytime DATE, cp_product_code VARCHAR2, cp_company_code VARCHAR2, cp_profit_centre_code VARCHAR2, cp_qty_type VARCHAR2)IS
	  SELECT daytime
	  FROM ifac_qty
	  WHERE daytime = cp_daytime
      AND  stream_item_category = cp_qty_type
      AND  product = cp_product_code
      AND  company = cp_company_code
      AND  profit_center = cp_profit_centre_code
      AND  day_mth = 'M';

      lv_update VARCHAR2(1) := 'N';
BEGIN
	FOR curExist IN c_exist (p_daytime, p_product_code, p_company_code, p_profit_centre_code, p_qty_type)LOOP
    	lv_update := 'Y';
    END LOOP;

	IF lv_update = 'N' THEN
		INSERT INTO ifac_qty(daytime, day_mth,stream_item_category, product, company ,profit_center, qty1, uom1_code, status)
		VALUES (p_daytime, 'M', p_qty_type, p_product_code, p_company_code, p_profit_centre_code, p_qty, p_uom, 'NEW');
	ELSE
		UPDATE ifac_qty SET qty1 = p_qty
		WHERE daytime = p_daytime
			AND day_mth = 'M'
			AND stream_item_category = p_qty_type
			AND product = p_product_code
			AND company = p_company_code
			AND profit_center = p_profit_centre_code;
	END IF;
END insertQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicatePROD
-- Description    : This procedure inserts/updates the monthly production on product, company and profit centre
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : stor_day_pc_cpy_receipt, storage, product
--
-- Using functions: ecbp_lifting_entitlement.IsMissingProdNumbers ,ecbp_storage_lift_nomination.getNomUnit
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE replicatePROD(p_DAYTIME DATE)

--</EC-DOC>
IS
	CURSOR c_prod (cp_daytime DATE) IS
		SELECT a.object_id,
			ec_company.object_code(a.company_id) company_code,
			ecdp_objects.GetObjCode(a.profit_centre_id) profit_centre_code,
			ec_product.object_code(v.product_id) product_code,
			li.unit,
			ec_ctrl_unit.uom_group(li.unit) uom_group,
			li.item_condition,
			sum(o.official_qty) qty
		FROM lifting_account a,
			lift_acc_day_official o,
			storage s,
			stor_version v,
			product_meas_setup ms,
			lifting_measurement_item li
		WHERE a.object_id = o.object_id
			AND o.daytime BETWEEN cp_daytime AND LAST_DAY(cp_daytime)
			AND a.storage_id = s.object_id
			AND s.object_id = v.object_id
			AND v.daytime <= o.daytime AND nvl(v.end_date, o.daytime+1) > o.daytime
			AND a.company_id is not null
			AND a.profit_centre_id is not null
			AND o.official_type = 'OFFICIAL'
			AND v.product_id = ms.object_id
			AND ms.item_code = li.item_code
			AND ms.lifting_event = 'LOAD'
			AND ms.nom_unit_ind = 'Y'
		GROUP BY a.object_id, v.product_id, a.company_id, a.profit_centre_id, li.unit, li.item_condition;

	ld_daytime	DATE;
BEGIN
	ld_daytime := TRUNC(p_DAYTIME, 'mm');

	-- loop
	FOR cProd IN c_prod(ld_daytime) LOOP
		IF EcDp_Lift_Acc_Official.IsMissingOfficialNumbers(cProd.object_id, ld_daytime) = 'N' THEN
			insertQty(cProd.product_code, cProd.company_code, cProd.profit_centre_code,  ld_daytime, 'PROD', cProd.qty, cProd.unit);
		ELSE
		  NULL; -- NOTYET -- Raise_Application_Error(-20318,'');
		END IF;
	END LOOP;

END replicatePROD;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateGIT
-- Description    : This procedure inserts/updates the monthly Gods in Transit on product, company and profit centre
--
-- Preconditions  :
--
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
PROCEDURE replicateGIT(p_DAYTIME DATE)

--</EC-DOC>
IS
	CURSOR c_git(cp_daytime DATE) IS
	    SELECT ec_product.object_code(ms.object_id) product_code,
			ec_company.object_code(a.company_id) company_code,
			ecdp_objects.GetObjCode(a.profit_centre_id) profit_centre_code,
			li.unit,
			ec_ctrl_unit.uom_group(li.unit) uom_group,
			li.item_condition,
			sum(l.load_value) qty
		FROM lifting_account a,
		     storage_lift_nomination n,
		     storage_lifting l,
		     product_meas_setup ms,
      		lifting_measurement_item li
		WHERE
		     a.object_id = n.lifting_account_id
		     and n.parcel_no = l.parcel_no
		     and l.product_meas_no = ms.product_meas_no
		     and ms.lifting_event = 'LOAD'
		     and ms.nom_unit_ind = 'Y'
         	and ms.item_code = li.item_code
		     and n.incoterm = 'CIF'
		     and n.bl_date <= LAST_DAY(cp_DAYTIME)
		     and (n.unload_date is null or n.unload_date > LAST_DAY(cp_DAYTIME))
		GROUP BY ms.object_id,a.company_id, a.profit_centre_id, li.unit, li.item_condition;

	ld_daytime	DATE;

BEGIN
	ld_daytime := TRUNC(p_DAYTIME, 'mm');

	-- loop
	FOR cGit IN c_git(ld_daytime) LOOP
		insertQty(cGit.product_code, cGit.company_code, cGit.profit_centre_code, ld_daytime, 'GIT', cGit.qty, cGit.unit);
	END LOOP;

END replicateGIT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateLoss
-- Description    : This procedure inserts/updates the monthly Loss on product, company and profit centre
--
-- Preconditions  :
--
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
PROCEDURE replicateLoss(p_DAYTIME DATE)

--</EC-DOC>
IS
	CURSOR c_loss(cp_daytime DATE) IS
	SELECT ec_product.object_code(m.object_id) product_code,
			ec_company.object_code(a.company_id) company_code,
			ecdp_objects.GetObjCode(a.profit_centre_id) profit_centre_code,
	         li.unit,
		     ec_ctrl_unit.uom_group(li.unit) uom_group,
		     li.item_condition,
	         sum (abs(l.load_value - EcBP_Storage_Lifting.getLiftedValueByUnloadItem(n.parcel_no, m.product_meas_no))) qty --   sum(abs(unload_value - load_value))
	  FROM lifting_account a,
	       storage_lift_nomination n,
	       storage_lifting l,
	       product_meas_setup m ,
      	   lifting_measurement_item li
	  WHERE a.object_id = n.lifting_account_id
	       AND n.parcel_no = l.parcel_no
	       AND l.product_meas_no = m.product_meas_no
           AND m.item_code = li.item_code
	       AND m.lifting_event = 'UNLOAD'
	       AND m.nom_unit_ind = 'Y'
	       AND n.incoterm = 'CIF'
	       AND n.unload_date BETWEEN TRUNC(cp_daytime,'mm') AND LAST_DAY(cp_daytime)
	  GROUP BY m.object_id, a.company_id, a.profit_centre_id, li.unit, li.item_condition;

	ld_daytime	DATE;

BEGIN
	ld_daytime := TRUNC(p_DAYTIME, 'mm');

	-- loop
	FOR cLoss IN c_loss(ld_daytime) LOOP
		insertQty(cLoss.product_code, cLoss.company_code, cLoss.profit_centre_code,  ld_daytime, 'LOSS', cLoss.qty, cLoss.unit);
	END LOOP;

END replicateLoss;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateInv
-- Description    : This procedure inserts/updates the monthly Inventory on product, company and profit centre
--
-- Preconditions  :
--
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
PROCEDURE replicateInv(p_DAYTIME DATE)

--</EC-DOC>
IS
	CURSOR c_inv(cp_daytime DATE) IS
		SELECT ec_product.object_code(v.product_id) product_code,
			ec_company.object_code(a.company_id) company_code,
			ecdp_objects.GetObjCode(a.profit_centre_id) profit_centre_code,
			li.unit,
		      ec_ctrl_unit.uom_group(li.unit) uom_group,
		      li.item_condition,
			ecbp_lift_acc_balance.getOpeningBalanceMth(a.object_id, cp_daytime) opening_qty,
			ecbp_lift_acc_balance.getOpeningBalanceMth(a.object_id, add_months(cp_daytime,1)) closing_qty
		FROM lifting_account a,
			storage s,
			stor_version v,
	      product_meas_setup ms,
	      lifting_measurement_item li
		WHERE a.company_id is not null
			AND a.profit_centre_id is not null
			AND a.storage_id = s.object_id
			AND s.object_id = v.object_id
			AND v.daytime <= cp_daytime
      		AND nvl(v.end_date, cp_daytime+1) > cp_daytime
	      AND v.product_id = ms.object_id
	      AND ms.item_code = li.item_code
	      AND ms.lifting_event = 'LOAD'
	      AND ms.nom_unit_ind = 'Y';

	ld_daytime	DATE;
BEGIN
	ld_daytime := TRUNC(p_DAYTIME, 'mm');

	-- loop
	FOR cInv IN c_inv(ld_daytime) LOOP
		insertQty(cInv.product_code, cInv.company_code, cInv.profit_centre_code,  ld_daytime, 'INV', cInv.opening_qty - cInv.closing_qty, cInv.unit);
	END LOOP;

END replicateInv;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateMeL
-- Description    : This procedure inserts/updates the monthly MEL (Month end liftings) on product, company and profit centre
-- Preconditions  :
--
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
PROCEDURE replicateMeL(p_DAYTIME DATE)

--</EC-DOC>
IS
	CURSOR c_MeL(cp_daytime DATE) IS
		SELECT ec_product.object_code(v.product_id) product_code,
			ec_company.object_code(a.company_id) company_code,
			ecdp_objects.GetObjCode(a.profit_centre_id) profit_centre_code,
			li.unit,
			ec_ctrl_unit.uom_group(li.unit) uom_group,
			li.item_condition,
			sum(ecbp_storage_lift_nomination.getProratedMonthEnd(n.parcel_no)) mel_qty
		FROM 	lifting_account a,
			stor_period_export_status e,
			storage_lift_nomination n,
			storage s,
			stor_version v,
			product_meas_setup ms,
			lifting_measurement_item li
		WHERE 	a.object_id = n.lifting_account_id
			AND e.cargo_no = n.cargo_no
			AND e.daytime = cp_daytime
			AND e.time_span = 'MTH'
			AND a.profit_centre_id is not null
			AND n.object_id = s.object_id
			AND s.object_id = v.object_id
			AND v.daytime <= e.daytime AND nvl(v.end_date, e.daytime+1) > e.daytime
			AND v.product_id = ms.object_id
			AND ms.item_code = li.item_code
			AND ms.lifting_event = 'LOAD'
			AND ms.nom_unit_ind = 'Y'
		GROUP BY v.product_id, a.company_id, a.profit_centre_id,li.unit, li.item_condition;

	ld_daytime	DATE;

BEGIN
	ld_daytime := TRUNC(p_DAYTIME, 'mm');

	-- loop
	FOR cmel IN c_mel(ld_daytime) LOOP
		insertQty(cmel.product_code, cmel.company_code, cmel.profit_centre_code,  ld_daytime, 'MEL', cmel.mel_qty, cmel.unit);
	END LOOP;

END replicateMel;

END EcBp_Replicate_Cargo_Qty;