CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Nomination IS
/******************************************************************************
** Package        :  EcBp_Contract_Nomination, body part
**
** $Revision: 1.11 $
**
** Purpose        :  Find and work with nomination data
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.08.2005 Narinder Kaur Man Singh
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     -----------------------------------------------------------------------------------------------
** 11.06.10    lauuufus  Added procedure for overlapping period validation.
** 21.09.10    leongwen  ECPD-15636 Adjusted Nomination calculation is not correct.
** 28.01.11    lauuufus  ECPD-16765 Added procedure for overlapping period validation for Nomination Point Connection.
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRenomQty
-- Description    : The calculated daily rate from the original nomination and any further adjustment.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_dp_event
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getRenomQty(
	p_contract_id	VARCHAR2,
	p_delivery_point_id	VARCHAR2,
	p_daytime	DATE,
	p_renom_qty NUMBER,
	p_next_daytime DATE DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS

	CURSOR 	c_prev_renom (cp_contract_id STRING, cp_dp_id STRING, cp_start_date DATE, cp_end_date DATE, cp_daytime DATE ) IS
	SELECT 	daytime, qty
	FROM 	cntr_dp_event
	WHERE  	object_id = cp_contract_id
			AND delivery_point_id = cp_dp_id
			AND daytime >= cp_start_date
			AND daytime < cp_end_date
			AND daytime = (	SELECT  max(daytime)
								FROM cntr_dp_event
								WHERE object_id = cp_contract_id
								AND delivery_point_id =cp_dp_id
    							AND daytime < cp_daytime
    		);


	ln_original_nom        NUMBER	:= NULL;
	ln_prev_renom	NUMBER := NULL;
	ln_renom_qty NUMBER := NULL;
	ln_prev_adj		NUMBER := NULL;
	ld_prev_date	DATE := NULL;

	ld_gas_start_day	DATE;
	ld_gas_end_day	DATE;

	ln_done 		NUMBER;
	ln_left			NUMBER;

BEGIN

	ld_gas_start_day := EcDp_ContractDay.getProductionDayStart('CONTRACT',p_contract_id, trunc(p_daytime));
	IF (ld_gas_start_day > p_daytime) THEN
		-- Need to do this when input daytime is after midnigth
		ld_gas_start_day := ld_gas_start_day -1;
	END IF;

	ld_gas_end_day := ld_gas_start_day + 1;


	-- Get prevoius renom
	FOR c_renom IN c_prev_renom (p_contract_id, p_delivery_point_id, ld_gas_start_day, ld_gas_end_day, p_daytime) LOOP
		ln_prev_renom := c_renom.qty;
		ld_prev_date := c_renom.daytime;
	END LOOP;


	IF (ln_prev_renom IS NULL AND ld_prev_date IS NULL) THEN
		ln_original_nom := ec_cntr_day_dp_nom.nominated_qty(p_contract_id, p_delivery_point_id, trunc(p_daytime));

		ln_done := (p_daytime - ld_gas_start_day) * 1440;
		ln_left := (nvl(p_next_daytime, ld_gas_end_day) - p_daytime) * 1440; -- use next date if any

		IF (ln_original_nom IS NULL) THEN
			ln_renom_qty := 0;
		ELSE
			ln_renom_qty := (ln_original_nom * (ln_done / 1440)) + (p_renom_qty * (ln_left / 1440));
		END IF;
	ELSE
		--get prev calculated nomination
		ln_prev_adj := EcBp_Contract_Nomination.getRenomQty(p_contract_id, p_delivery_point_id, ld_prev_date, ln_prev_renom, p_daytime);

		ln_done := (p_daytime - ld_prev_date) * 1440;
		ln_left := (nvl(p_next_daytime, ld_gas_end_day) - p_daytime) * 1440;-- use next date if any


		ln_renom_qty := ln_prev_adj + (p_renom_qty * (ln_left / 1440));
	END IF;

	RETURN ln_renom_qty;

END getRenomQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfPcListOverlaps
-- Description    : Checks if overlapping period exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping period exists.
--
-- Using tables   : NOMPNT_PROFIT_CENTRE
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
PROCEDURE checkIfPcListOverlaps(p_object_id VARCHAR2,p_profit_centre_id VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS
  -- overlapping period can't exist in lifting account connection
	CURSOR c_pc_list IS
	  SELECT *
	  FROM NOMPNT_PROFIT_CENTRE npc
	  WHERE npc.object_id = p_object_id
    AND npc.profit_centre_id = p_profit_centre_id
    AND npc.daytime <> p_daytime
    AND (npc.end_date > p_daytime OR npc.end_date IS NULL)
    AND (npc.daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);


BEGIN

  lv_message := null;

  FOR cur_nompnt_pc_list IN c_pc_list LOOP
    lv_message := lv_message ||cur_nompnt_pc_list.object_id|| ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20403, 'A record must not overlaps with an existing record period.');
  END IF;

END checkIfPcListOverlaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkProfitCentreOverlaps
-- Description    : Checks if overlapping connection exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping connection exists.
--
-- Using tables   : CNTR_LIFT_ACC_CONN
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
PROCEDURE checkProfitCentreOverlaps(p_object_id VARCHAR2,p_profit_centre_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS
  -- overlapping period can't exist in lifting account connection
	CURSOR c_pc_list IS
	  SELECT *
	  FROM NOMPNT_PC_COMPANY n
	  WHERE n.object_id = p_object_id
    AND n.profit_centre_id = p_profit_centre_id
    AND n.company_id = p_company_id
    AND n.daytime <> p_daytime
    AND (n.end_date > p_daytime OR n.end_date IS NULL)
    AND (n.daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);


BEGIN

  lv_message := null;

  FOR cur_nompnt_pc_list IN c_pc_list LOOP
    lv_message := lv_message ||cur_nompnt_pc_list.object_id|| ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20403, 'A record must not overlaps with an existing record period.');
  END IF;

END checkProfitCentreOverlaps;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkNomPntOverlaps
-- Description    : Checks if overlapping connection exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping connection exists.
--
-- Using tables   : NOMPNT_CONNECTION
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
PROCEDURE checkNomPntOverlaps(p_object_id VARCHAR2,p_nompnt_id VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS
  -- overlapping period can't exist in nomination point connection
	CURSOR c_nompnt_list IS
	  SELECT *
	  FROM NOMPNT_CONNECTION n
	  WHERE n.object_id = p_object_id
    AND n.nompnt_id = p_nompnt_id
    AND n.daytime <> p_daytime
    AND (n.end_date > p_daytime OR n.end_date IS NULL)
    AND (n.daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);


BEGIN

  lv_message := null;

  FOR cur_nompnt_list IN c_nompnt_list LOOP
    lv_message := lv_message ||cur_nompnt_list.object_id|| ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20403, 'A record must not overlaps with an existing record period.');
  END IF;

END checkNomPntOverlaps;

END EcBp_Contract_Nomination;