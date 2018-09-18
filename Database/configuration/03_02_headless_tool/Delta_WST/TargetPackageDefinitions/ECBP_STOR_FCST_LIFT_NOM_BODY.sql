CREATE OR REPLACE PACKAGE BODY EcBP_Stor_Fcst_Lift_Nom IS
/******************************************************************************
** Package        :  EcBP_Stor_Fcst_Lift_Nom, body part
**
** $Revision: 1.6.4.10 $
**
** Purpose        :  Business logic for storage lift nominations
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
**	     24.01.2013 meisihil ECPD-20056: Added functions aggrSubDayLifting, calcSubDayLifting, calcSubDayLiftingCargo
**                                       to support liftings spread over hours
**		 18.12.2013	chooysie ECPD-26389: Added function getLiftedVolByIncoterm
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNomToleranceMinVol
-- Description    : Returns the min volume for nominated tolerence limit for a storage lift nomination
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                         --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNomToleranceMinVol(p_parcel_no NUMBER, p_forecast_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
	RETURN ec_stor_fcst_lift_nom.grs_vol_nominated(p_parcel_no, p_forecast_id) * (1-(ec_tolerance_limit.min_qty_pct(ec_stor_fcst_lift_nom.REQUESTED_TOLERANCE_TYPE(p_parcel_no, p_forecast_id))/100));
END getNomToleranceMinVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNomToleranceMaxVol
-- Description    : Returns the max volume for nominated tolerence limit for a storage lift nomination
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNomToleranceMaxVol(p_parcel_no NUMBER, p_forecast_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
	RETURN ec_stor_fcst_lift_nom.grs_vol_nominated(p_parcel_no, p_forecast_id) * (1+(ec_tolerance_limit.max_qty_pct(ec_stor_fcst_lift_nom.REQUESTED_TOLERANCE_TYPE(p_parcel_no, p_forecast_id))/100));
END getNomToleranceMaxVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiStorageLiftNomination
-- Description    : Instead of using triggers on tables this procedure should be run by
--					instead of triggers on the view layer
--					The trigger instantiate tables described in 'using tables'
--
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   :                                                                                                                       --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiStorageLiftNomination(p_parcel_no          NUMBER,
								  p_forecast_id VARCHAR2,
                                  p_nom_date           DATE,
                                  p_nom_date_range     VARCHAR2,
                                  p_req_date           DATE,
                                  p_REQ_DATE_RANGE     VARCHAR2,
                                  p_REQ_GRS_VOL        NUMBER,
                                  p_REQ_TOLERANCE_TYPE VARCHAR2,
                                  p_nom_grs_vol        NUMBER)
--</EC-DOC>

 IS
  -- define some temp variables
  t_nom_grs_vol    NUMBER;
  t_sch_grs_vol    NUMBER;
  t_nom_date_range VARCHAR2(8);
  t_nom_date       DATE;

BEGIN
  -- check if nominated values are set
  IF p_nom_grs_vol IS NULL THEN
    -- if null, use requested values for nominated and scheduled
    t_nom_grs_vol := p_REQ_GRS_VOL;
    t_sch_grs_vol := p_REQ_GRS_VOL;
  ELSE
    -- else use nominated values for nominated and scheduled
    t_sch_grs_vol := p_nom_grs_vol;
    t_nom_grs_vol := p_nom_grs_vol;
  END IF;

  IF p_nom_date IS NULL THEN
    t_nom_date := p_REQ_DATE;
  ELSE
    t_nom_date := p_nom_date;
  END IF;

  IF p_nom_date_range IS NULL THEN
    t_nom_date_range := p_REQ_DATE_RANGE;
  ELSE
    t_nom_date_range := p_nom_date_range;
  END IF;

  UPDATE stor_fcst_lift_nom
     SET NOM_FIRM_DATE           = t_nom_date,
         NOM_FIRM_DATE_RANGE     = t_nom_date_range,
         GRS_VOL_NOMINATED       = t_nom_grs_vol,
         GRS_VOL_SCHEDULE        = t_sch_grs_vol,
         SCHEDULE_TOLERANCE_TYPE = p_REQ_TOLERANCE_TYPE,
         LAST_UPDATED_BY		 = ecdp_context.getAppUser
   WHERE parcel_no = p_PARCEL_NO AND forecast_id = p_forecast_id;

END aiStorageLiftNomination;







--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiStorageLiftNomination2
-- Description    : Instead of using triggers on tables this procedure should be run by
--					instead of triggers on the view layer
--					The trigger instantiate tables described in 'using tables'
--					This trigger should only be enabled when _QTY2 attribues are enabled.
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   :                                                                                                                       --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiStorageLiftNomination2(p_forecast_id VARCHAR2,
                                  p_parcel_no          NUMBER,
                                  p_REQ_GRS_VOL2        NUMBER,
                                  p_nom_grs_vol2        NUMBER,
                                  p_user               VARCHAR2 DEFAULT NULL)
--</EC-DOC>

 IS
  -- define some temp variables
  t_nom_grs_vol2    NUMBER;
  t_sch_grs_vol2    NUMBER;


BEGIN
  -- check if nominated values are set
  IF p_nom_grs_vol2 IS NULL THEN
    -- if null, use requested values for nominated and scheduled
    t_nom_grs_vol2 := p_REQ_GRS_VOL2;
    t_sch_grs_vol2 := p_REQ_GRS_VOL2;
  ELSE
    -- else use nominated values for nominated and scheduled
    t_sch_grs_vol2 := p_nom_grs_vol2;
    t_nom_grs_vol2 := p_nom_grs_vol2;
  END IF;


  UPDATE stor_fcst_lift_nom
     SET GRS_VOL_NOMINATED2       = t_nom_grs_vol2,
         GRS_VOL_SCHEDULED2        = t_sch_grs_vol2,
         LAST_UPDATED_BY		 = p_user
   WHERE parcel_no = p_PARCEL_NO  AND forecast_id = p_forecast_id;

END aiStorageLiftNomination2;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiStorageLiftNomination3
-- Description    : Instead of using triggers on tables this procedure should be run by
--					instead of triggers on the view layer
--					The trigger instantiate tables described in 'using tables'
--					This trigger should only be enabled when _QTY3 attribues are enabled.
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   :                                                                                                                       --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE aiStorageLiftNomination3(p_forecast_id VARCHAR2,
                                  p_parcel_no          NUMBER,
                                  p_REQ_GRS_VOL3        NUMBER,
                                  p_nom_grs_vol3        NUMBER,
                                  p_user               VARCHAR2 DEFAULT NULL)
--</EC-DOC>

 IS
  -- define some temp variables
  t_nom_grs_vol3    NUMBER;
  t_sch_grs_vol3    NUMBER;


BEGIN
  -- check if nominated values are set
  IF p_nom_grs_vol3 IS NULL THEN
    -- if null, use requested values for nominated and scheduled
    t_nom_grs_vol3 := p_REQ_GRS_VOL3;
    t_sch_grs_vol3 := p_REQ_GRS_VOL3;
  ELSE
    -- else use nominated values for nominated and scheduled
    t_sch_grs_vol3 := p_nom_grs_vol3;
    t_nom_grs_vol3 := p_nom_grs_vol3;
  END IF;


  UPDATE stor_fcst_lift_nom
     SET GRS_VOL_NOMINATED3       = t_nom_grs_vol3,
         GRS_VOL_SCHEDULED3       = t_sch_grs_vol3,
         LAST_UPDATED_BY		 = p_user
   WHERE parcel_no = p_PARCEL_NO  AND forecast_id = p_forecast_id;

END aiStorageLiftNomination3;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateLiftingIndicator
-- Description    : Check thats new lifting indicator is unique in boht original and forecast
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
PROCEDURE validateLiftingIndicator(p_forecast_id VARCHAR2, p_old_lifting_code VARCHAR2, p_new_lifting_code VARCHAR2)
--</EC-DOC>
IS

CURSOR 	c_lifting_ind (cp_lifting_code VARCHAR2, cp_forecast_id VARCHAR2)
IS
SELECT 	lifting_code
FROM 	storage_lift_nomination
WHERE 	lifting_code = cp_lifting_code
UNION
SELECT 	lifting_code
FROM 	stor_fcst_lift_nom
WHERE 	lifting_code = cp_lifting_code
AND		forecast_id = cp_forecast_id
AND 	Nvl(DELETED_IND, 'N') <> 'Y';

BEGIN
	IF (p_new_lifting_code IS NOT NULL AND (p_old_lifting_code IS NULL OR p_old_lifting_code <> p_new_lifting_code)) THEN
		FOR curLiftInd IN c_lifting_ind (p_new_lifting_code, p_forecast_id) LOOP
			Raise_Application_Error(-20323,'The Lifting Indicator is not unique');
		END LOOP;
	END IF;

END validateLiftingIndicator;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteNomination
-- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
-- Using functions: EcBp_Cargo_Transport.cleanLonesomeCargoes;
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteNomination(p_storage_id VARCHAR2,
						p_forecast_id VARCHAR2,
						p_from_date DATE,
						p_to_date DATE)
--</EC-DOC>
IS

BEGIN

    -- User exit function
    ue_Stor_Fcst_Lift_Nom.deleteNomination(p_storage_id, p_forecast_id, p_from_date,p_to_date);

	-- Delete nominations without cargo that doesn't exist in original data
	DELETE stor_fcst_lift_nom
	WHERE (fixed_ind is null or fixed_ind = 'N') AND cargo_no is NULL
	AND NOM_FIRM_DATE >= p_from_date
	AND NOM_FIRM_DATE <= p_to_date
	AND forecast_id = p_forecast_id
	AND object_id = Nvl(p_storage_id, object_id)
	AND parcel_no NOT IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no);

	--delete nominations that are connected to a cargo that doesn't exist in original data
    DELETE stor_fcst_lift_nom WHERE forecast_id = p_forecast_id
	AND parcel_no IN (
    	SELECT n.parcel_no
    	FROM stor_fcst_lift_nom n, cargo_fcst_transport c
		WHERE (fixed_ind is null or fixed_ind = 'N')
      		AND c.cargo_no = n.cargo_no
      		AND c.forecast_id = p_forecast_id
      		AND EcBp_Cargo_Status.getEcCargoStatus(c.cargo_status) in ('T', 'O')
      		AND n.nom_firm_date >= p_from_date
			AND n.nom_firm_date <= p_to_date
			AND n.forecast_id = p_forecast_id
			AND n.object_id = Nvl(p_storage_id, object_id)
			AND parcel_no NOT IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no));

	UPDATE stor_fcst_lift_nom
	SET deleted_ind = 'Y'
	WHERE (fixed_ind is null or fixed_ind = 'N') AND cargo_no is NULL
	AND NOM_FIRM_DATE >= p_from_date
	AND NOM_FIRM_DATE <= p_to_date
	AND forecast_id = p_forecast_id
	AND object_id = Nvl(p_storage_id, object_id)
	AND parcel_no IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no);

    UPDATE stor_fcst_lift_nom
	SET deleted_ind = 'Y'
	WHERE forecast_id = p_forecast_id
    AND parcel_no IN (
    	SELECT n.parcel_no
    	FROM stor_fcst_lift_nom n, cargo_fcst_transport c
		WHERE (fixed_ind is null or fixed_ind = 'N')
      		AND c.cargo_no = n.cargo_no
      		AND c.forecast_id = p_forecast_id
      		AND EcBp_Cargo_Status.getEcCargoStatus(c.cargo_status) in ('T', 'O')
      		AND n.nom_firm_date >= p_from_date
			AND n.nom_firm_date <= p_to_date
			AND n.forecast_id = p_forecast_id
			AND n.object_id = Nvl(p_storage_id, object_id)
			AND parcel_no IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no));


	-- clean cargos that no longer have nominations
	EcBp_Cargo_Fcst_Transport.cleanLonesomeCargoes(p_forecast_id);

END deleteNomination;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertFromLiftProg
-- Description    : additional columns set when inserting a nominations from lifting program
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertFromLiftProg(p_parcel_no NUMBER,
						p_forecast_id VARCHAR2,
						p_nom_qty NUMBER,
						p_nom_date DATE)
--</EC-DOC>
IS

BEGIN
	UPDATE stor_fcst_lift_nom
		SET GRS_VOL_REQUESTED	= p_nom_qty,
			GRS_VOL_SCHEDULE	= p_nom_qty,
			REQUESTED_DATE		= p_nom_date,
			START_LIFTING_DATE  = nvl(START_LIFTING_DATE, p_nom_date),
			LAST_UPDATED_BY		= ecdp_context.getAppUser
	WHERE parcel_no = p_PARCEL_NO AND forecast_id = p_forecast_id;

END insertFromLiftProg;

--<EC-DOC>
  ------------------------------------------------------------------------------------------------------
  -- Function       : aggrSubDayLifting
  -- Description    : Returns the aggregated daily lifting
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
  FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0)
  RETURN NUMBER
  --</EC-DOC>
   IS
	ln_result NUMBER;
	ln_temp NUMBER;

   	CURSOR c_sub_day(cp_forecast_id VARCHAR2, cp_parcel_no NUMBER, cp_daytime DATE, cp_xtra_qty NUMBER DEFAULT 0)
   	IS
   		SELECT object_id,
   			   SUM(DECODE(cp_xtra_qty, 0, n.grs_vol_requested, 1, n.grs_vol_requested2, 2, n.grs_vol_requested3)) grs_vol_requested,
   		       SUM(DECODE(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) grs_vol_nominated,
   		       SUM(DECODE(cp_xtra_qty, 0, n.cooldown_qty, 1, n.cooldown_qty2, 2, n.cooldown_qty3)) cooldown_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.purge_qty, 1, n.purge_qty2, 2, n.purge_qty3)) purge_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.lauf_qty, 1, n.lauf_qty2, 2, n.lauf_qty3)) lauf_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.vapour_return_qty, 1, n.vapour_return_qty2, 2, n.vapour_return_qty3)) vapour_return_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
   		  FROM stor_fcst_sub_day_lift_nom n
   		 WHERE parcel_no = cp_parcel_no
   		   AND production_day = cp_daytime
   		   AND forecast_id = cp_forecast_id
   		GROUP BY object_id;
  BEGIN
  	FOR c_cur IN c_sub_day(p_forecast_id, p_parcel_no, p_daytime, p_xtra_qty) LOOP
  		IF p_column = 'REQUESTED' THEN
  			ln_result := c_cur.grs_vol_requested;
  		ELSIF p_column = 'NOMINATED' THEN
  			ln_result := c_cur.grs_vol_nominated;
  		ELSIF p_column = 'COOLDOWN' THEN
  			ln_result := c_cur.cooldown_qty;
  		ELSIF p_column = 'PURGE' THEN
  			ln_result := c_cur.purge_qty;
  		ELSIF p_column = 'LAUF' THEN
  			ln_result := c_cur.lauf_qty;
  		ELSIF p_column = 'VAPOUR_RETURN' THEN
  			ln_result := c_cur.vapour_return_qty;
  		ELSIF p_column = 'BALANCE_DELTA' THEN
  			ln_result := c_cur.balance_delta_qty;
			IF ec_forecast.cargo_off_qty_ind(p_forecast_id) = 'Y' THEN
				-- Check if actual balance delta quantity is registred
				ln_temp := ecbp_storage_lift_nomination.getLoadBalDeltaVol(p_parcel_no);
				IF ln_temp IS NOT NULL  THEN
					ln_temp := EcBp_Storage_Lift_Nomination.aggrSubDayLifting(p_parcel_no, p_daytime, 'BALANCE_DELTA', p_xtra_qty);
				END IF;
				IF ln_temp IS NOT NULL THEN
					ln_result := ln_temp;
				END IF;
			END IF;
  		ELSE
  			-- If column is not specified, return best quantity
			ln_result := c_cur.grs_vol_nominated;

			IF ec_forecast.cargo_off_qty_ind(p_forecast_id) = 'Y' THEN
				ln_temp := EcBp_Storage_Lift_Nomination.aggrSubDayLifting(p_parcel_no, p_daytime, 'LIFTED', p_xtra_qty);
				IF ln_temp IS NULL AND (ec_stor_version.storage_type(c_cur.object_id, p_daytime, '<=') = 'IMPORT') THEN
					ln_temp := EcBp_Storage_Lift_Nomination.aggrSubDayLifting(p_parcel_no, p_daytime, 'UNLOAD', p_xtra_qty);
				END IF;
				IF ln_temp IS NOT NULL THEN
					ln_result := ln_temp;
				END IF;
			END IF;
		END IF;
  	END LOOP;

  	RETURN ln_result;
  END aggrSubDayLifting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
-- Description    :
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
PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS
	ln_berth_rate NUMBER;
	ln_carrier_rate NUMBER;
	ln_hourly_full_rate NUMBER;
	ln_loop_hours NUMBER;
	ln_tot_loop_hours NUMBER := 0;
	ln_hour_counter NUMBER;
	ln_cum_lifted NUMBER;

	lud_date_time EcDp_Date_Time.Ec_Unique_Daytime;
	ld_date_time DATE;
	ld_start_lifting_date DATE;
	lv_summertime VARCHAR2(1);

	ln_hr_requested_qty NUMBER;
	ln_hr_requested_qty2 NUMBER;
	ln_hr_nominated_qty NUMBER;
	ln_hr_nominated_qty2 NUMBER;
	ln_hr_cooldown_qty NUMBER;
	ln_hr_cooldown_qty2 NUMBER;
	ln_hr_purge_qty NUMBER;
	ln_hr_purge_qty2 NUMBER;

	CURSOR c_nom(cp_forecast_id VARCHAR2, cp_parcel_no NUMBER)
	IS
		SELECT n.cargo_no, n.object_id, n.nom_firm_date, n.nom_firm_date_time, n.start_lifting_date,
		       n.grs_vol_requested, n.grs_vol_requested2, n.grs_vol_nominated, n.grs_vol_nominated2,
		       n.cooldown_qty, n.cooldown_qty2, n.purge_qty, n.purge_qty2,
		       ct.berth_id, ct.carrier_id,
		       c.cooldown_rate, to_char(purge_time,'HH') purge_time, c.loading_rate
		  FROM stor_fcst_lift_nom n, cargo_fcst_transport ct, carrier_version c
		 WHERE parcel_no = cp_parcel_no
		   AND n.forecast_id = cp_forecast_id
		   AND n.cargo_no = ct.cargo_no(+)
		   AND n.forecast_id = ct.forecast_id(+)
		   AND n.carrier_id = c.object_id(+)
		   AND nvl(n.deleted_ind, 'N') <> 'Y'
		   AND NVL(n.start_lifting_date, n.nom_firm_date_time) IS NOT NULL;
BEGIN
	DELETE FROM stor_fcst_sub_day_lift_nom WHERE parcel_no = p_parcel_no AND forecast_id = p_forecast_id;

	FOR c_cur IN c_nom(p_forecast_id, p_parcel_no) LOOP
		ld_start_lifting_date := NVL(c_cur.start_lifting_date, c_cur.nom_firm_date_time);
		ld_date_time := ld_start_lifting_date;
		lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(ld_date_time));

		-- Update purge quantity
		IF c_cur.purge_qty IS NOT NULL AND NVL(c_cur.purge_time, 0) > 0 THEN
			ln_hr_purge_qty := c_cur.purge_qty / c_cur.purge_time;
			IF c_cur.purge_qty2 IS NOT NULL THEN
				ln_hr_purge_qty2 := ln_hr_purge_qty * c_cur.purge_qty2 / c_cur.purge_qty;
			END IF;
			ln_loop_hours := c_cur.purge_time;
			ln_hour_counter := 0;
			WHILE ln_hour_counter < ln_loop_hours LOOP
				INSERT INTO stor_fcst_sub_day_lift_nom(forecast_id, parcel_no, object_id, daytime, summer_time, purge_qty, purge_qty2, balance_delta_qty, balance_delta_qty2)
				VALUES(p_forecast_id, p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_purge_qty, ln_hr_purge_qty2, ln_hr_purge_qty, ln_hr_purge_qty2);

				lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
				ld_date_time := lud_date_time.daytime;
				lv_summertime := lud_date_time.summertime_flag;
				ln_hour_counter := ln_hour_counter + 1;
			END LOOP;
			ln_tot_loop_hours := ln_tot_loop_hours + ln_loop_hours;
		END IF;

		-- Update cooldown quantity
		IF c_cur.cooldown_qty IS NOT NULL AND NVL(c_cur.cooldown_rate, 0) > 0 THEN
			ln_hourly_full_rate := c_cur.cooldown_rate;
			ln_loop_hours := c_cur.cooldown_qty / c_cur.cooldown_rate;
			IF ln_loop_hours > trunc(ln_loop_hours) THEN
				ln_loop_hours := trunc(ln_loop_hours) + 1;
			END IF;
			ln_hour_counter := 0;
			WHILE ln_hour_counter < ln_loop_hours LOOP
				ln_cum_lifted := ln_hourly_full_rate * ln_hour_counter;
				IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.cooldown_qty THEN
					ln_hr_cooldown_qty := c_cur.cooldown_qty - ln_cum_lifted;
					IF ln_hr_cooldown_qty < 0 THEN
						ln_hr_cooldown_qty := 0;
					END IF;
				ELSE
					ln_hr_cooldown_qty := ln_hourly_full_rate;
				END IF;
				IF c_cur.cooldown_qty2 IS NOT NULL THEN
					ln_hr_cooldown_qty2 := ln_hr_cooldown_qty * c_cur.cooldown_qty2 / c_cur.cooldown_qty;
				END IF;

				INSERT INTO stor_fcst_sub_day_lift_nom(forecast_id, parcel_no, object_id, daytime, summer_time, cooldown_qty, cooldown_qty2, balance_delta_qty, balance_delta_qty2)
				VALUES(p_forecast_id, p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_cooldown_qty, ln_hr_cooldown_qty2, ln_hr_cooldown_qty, ln_hr_cooldown_qty2);

				lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
				ld_date_time := lud_date_time.daytime;
				lv_summertime := lud_date_time.summertime_flag;
				ln_hour_counter := ln_hour_counter + 1;
			END LOOP;
			ln_tot_loop_hours := ln_tot_loop_hours + ln_loop_hours;
		END IF;

		-- Update nominated quantity
		ld_start_lifting_date := ld_start_lifting_date + ln_tot_loop_hours/24;
		ln_berth_rate := ec_berth_version.design_capacity(c_cur.berth_id, c_cur.nom_firm_date);
		ln_carrier_rate := c_cur.loading_rate;
		IF ln_berth_rate IS NULL OR ln_carrier_rate < ln_berth_rate THEN
			ln_hourly_full_rate := ln_carrier_rate;
		ELSIF ln_carrier_rate IS NULL OR ln_berth_rate < ln_carrier_rate THEN
			ln_hourly_full_rate := ln_carrier_rate;
		END IF;

		IF ln_hourly_full_rate IS NULL THEN
			ln_hourly_full_rate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/sub_day_lifting_rate');
		END IF;

		IF NVL(ln_hourly_full_rate, 0) = 0 THEN
			ln_loop_hours := 1;
			ln_hourly_full_rate := greatest(c_cur.grs_vol_nominated, c_cur.grs_vol_requested);
		ELSE
			ln_loop_hours := greatest(c_cur.grs_vol_nominated, c_cur.grs_vol_requested) / ln_hourly_full_rate;
		END IF;
		IF ln_loop_hours > trunc(ln_loop_hours) THEN
			ln_loop_hours := trunc(ln_loop_hours) + 1;
		END IF;
		ln_hour_counter := 0;
		ln_cum_lifted := 0;
		WHILE ln_hour_counter < ln_loop_hours LOOP
			IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.grs_vol_requested THEN
				ln_hr_requested_qty := c_cur.grs_vol_requested - ln_cum_lifted;
				IF ln_hr_requested_qty < 0 THEN
					ln_hr_requested_qty := 0;
				END IF;
			ELSE
				ln_hr_requested_qty := ln_hourly_full_rate;
			END IF;
			IF c_cur.grs_vol_requested2 IS NOT NULL THEN
				ln_hr_requested_qty2 := ln_hr_requested_qty * c_cur.grs_vol_requested2 / c_cur.grs_vol_requested;
			END IF;

			IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.grs_vol_nominated THEN
				ln_hr_nominated_qty := c_cur.grs_vol_nominated - ln_cum_lifted;
				IF ln_hr_nominated_qty < 0 THEN
					ln_hr_nominated_qty := 0;
				END IF;
			ELSE
				ln_hr_nominated_qty := ln_hourly_full_rate;
			END IF;
			IF c_cur.grs_vol_nominated2 IS NOT NULL THEN
				ln_hr_nominated_qty2 := ln_hr_nominated_qty * c_cur.grs_vol_nominated2 / c_cur.grs_vol_nominated;
			END IF;

			INSERT INTO stor_fcst_sub_day_lift_nom(forecast_id, parcel_no, object_id, daytime, summer_time, grs_vol_requested, grs_vol_requested2, grs_vol_nominated, grs_vol_nominated2)
			VALUES(p_forecast_id, p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_requested_qty, ln_hr_requested_qty2, ln_hr_nominated_qty, ln_hr_nominated_qty2);

			lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
			ld_date_time := lud_date_time.daytime;
			lv_summertime := lud_date_time.summertime_flag;
			ln_hour_counter := ln_hour_counter + 1;
			ln_cum_lifted := ln_cum_lifted + ln_hourly_full_rate;
		END LOOP;

		createMissingSubDayLift(p_forecast_id, p_parcel_no);
	END LOOP;
END calcSubDayLifting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLiftingCargo
-- Description    : Will call ue_Storage_Lift_Nomination.calcSubDayLifting for each parcel on cargo
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
PROCEDURE calcSubDayLiftingCargo(p_forecast_id VARCHAR2, p_cargo_no NUMBER)
--</EC-DOC>
IS
	CURSOR c_parcel(cp_forecast_id VARCHAR2, cp_cargo_no NUMBER)
	IS
		SELECT parcel_no
		  FROM stor_fcst_lift_nom
		 WHERE cargo_no = cp_cargo_no
		   AND forecast_id = cp_forecast_id;
BEGIN
	FOR c_cur IN c_parcel(p_forecast_id, p_cargo_no) LOOP
		ue_Stor_Fcst_Lift_Nom.calcSubDayLifting(p_forecast_id, c_cur.parcel_no);
	END LOOP;
END calcSubDayLiftingCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createMissingSubDayLift
-- Description    : Will create missing sub day lifting records based on actual
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
PROCEDURE createMissingSubDayLift(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS
	CURSOR c_parcel(cp_parcel_no NUMBER)
	IS
		SELECT object_id, daytime, summer_time
		  FROM stor_sub_day_lift_nom
		 WHERE parcel_no = cp_parcel_no;
BEGIN
	FOR c_cur IN c_parcel(p_parcel_no) LOOP
		IF ec_stor_fcst_sub_day_lift_nom.record_status(p_forecast_id, p_parcel_no, c_cur.daytime) IS NULL THEN
			INSERT INTO stor_fcst_sub_day_lift_nom(forecast_id, parcel_no, object_id, daytime, summer_time)
			VALUES(p_forecast_id, p_parcel_no, c_cur.object_id, c_cur.daytime, c_cur.summer_time);
		END IF;
	END LOOP;
END createMissingSubDayLift;

--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftedVolByIncoterm
  -- Description    : Returns the lifted volume for a parcel based on whether the lifting is FOB or CIF/DES.
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
  FUNCTION getLiftedVolByIncoterm (p_parcel_no NUMBER, p_forecast_id VARCHAR2, p_xtra_qty NUMBER) RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lifting(cp_parcel_no     NUMBER,
                          cp_xtra_qty      NUMBER,
                          cp_lifting_event VARCHAR2) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = cp_lifting_event
         AND ((p.nom_unit_ind = 'Y' and 0 = NVL(p_xtra_qty, 0)) or
             (p.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
             (p.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));

    lnLiftedVol   NUMBER;
	lsContractType varchar2(32);


  BEGIN

	lsContractType := ec_stor_fcst_lift_nom.incoterm(p_parcel_no, p_forecast_id);

	IF lsContractType is null OR lsContractType = 'FOB' THEN
		FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'LOAD') LOOP
			lnLiftedVol := curLifted.load_value;
		END LOOP;
	ELSE IF lsContractType = 'CIF' OR lsContractType = 'DES' THEN
      FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'UNLOAD') LOOP
        lnLiftedVol := curLifted.load_value;
      END LOOP;
    END IF;
	END IF;

 RETURN lnLiftedVol;

 END getLiftedVolByIncoterm ;

END EcBP_Stor_Fcst_Lift_Nom;