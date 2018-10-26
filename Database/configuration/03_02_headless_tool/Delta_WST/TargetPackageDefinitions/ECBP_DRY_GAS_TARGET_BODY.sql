CREATE OR REPLACE PACKAGE BODY EcBp_Dry_Gas_Target IS
/****************************************************************
** Package        :  EcBp_Dry_Gas_Target
**
** $Revision: 1.8 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Stian Skjørestad
**
** Modification history:
**
** Date      		Whom  			Change description:
** --------   		----- 			--------------------------------------
** 06.01.06		Jean Ferre 		Added function getProjectedTargetQty,getWithinTargetQty and procedure createWithinDayTarget
** 10.01.06	 	ssk			Added function getDryGasHourprofile (TI 2734)
** 18.05.06             DN                      TI#3830: Divide by zero problems.
** 30.08.06             Rahmanaz                TI#4452: Modified function getOffset. Added parameter daytime when calling EcDp_ProductionDay.getProductionDayOffset
** 11.09.06             kaurrjes                TI#4469: Updated function getProjectedTargetQy. Changed class to "SCTR_DAY_NOM_WITHIN_TARG".
** 22.03.07             Rahmanaz                ECPD-5148: Added function getProjectedActualPct.
******************************************************************/


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : createBeforeDayTarget
-- Description    : Inserts a new row to table dry_gas_target with sum of target quantities and daytime equal to attribute PROD_DAY_START -> See function getOffset
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------

PROCEDURE createBeforeDayTarget(p_daytime DATE, p_source_class VARCHAR2, p_source_attr VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
	CURSOR c_validate (cp_daytime DATE)
	IS
		SELECT	daytime
		FROM  	dry_gas_target
		WHERE  	daytime >= cp_daytime
		    AND daytime < (cp_daytime + 1);

	CURSOR c_total (cp_daytime DATE)
	IS
		SELECT SUM(Nvl(EcBp_Dry_Gas_Target.getTargetQty(n.object_id, n.daytime,n.delivery_point_id, n.nominated_qty,p_source_class,p_source_attr),0) * nvl(n.desired_pct,100)/100) target
		FROM   cntr_day_dp_nom n
		WHERE  n.daytime = trunc(cp_daytime) and object_id
           in (SELECT object_id from ov_contract where BF_PROFILE in (select profile_code from bf_profile_setup where bf_code = 'SD.0018'));

	ld_date DATE;
	ln_target	NUMBER;
	lv_exist	VARCHAR2(1);
BEGIN
	ld_date := 	getOffset(p_daytime);

	--validate if any other targets exists for the day
	FOR curValidate IN c_validate (ld_date) LOOP
		IF curValidate.daytime = ld_date THEN
			lv_exist := 'Y';
		ELSE
			RAISE_APPLICATION_ERROR(-20523, 'A target cannot be created when there are other targets later in the day');
		END IF;
	END LOOP;

	-- sum find target
	FOR curValidate IN c_total (p_daytime) LOOP
		ln_target := curValidate.target;
	END LOOP;

	-- update or insert new target
	IF lv_exist = 'Y' THEN
		UPDATE dry_gas_target SET target_qty = ln_target, LAST_UPDATED_BY = p_user WHERE daytime = ld_date;
	ELSE
		INSERT INTO dry_gas_target (daytime, target_qty, created_by) VALUES (ld_date, ln_target, p_user);
	END IF;

	-- Calling user-exit procedure for possible additional functionality
	ue_dry_gas_target.createBeforeDayTarget(p_daytime, p_user);

END createBeforeDayTarget;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : createWithinDayTarget
-- Description    : The function insert a new row into DRY_GAS_TARGET
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : DRY_GAS_TARGET
--
--
-- Using functions: getTargetQty
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------

PROCEDURE createWithinDayTarget(p_daytime DATE,
							p_change_reason VARCHAR2,
							p_source_class VARCHAR2,
							p_source_attr VARCHAR2,
							p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
	CURSOR c_validate (cp_daytime DATE, cp_end DATE)
	IS
		SELECT	daytime
		FROM  	dry_gas_target
		WHERE  	daytime >= cp_daytime
		    AND daytime < cp_end;

	CURSOR c_total (cp_daytime DATE)
	IS
		SELECT SUM(Nvl(EcBp_Dry_Gas_Target.getWithinTargetQty(n.object_id, n.delivery_point_id, n.daytime, n.nominated_qty,n.ACK_QTY, n.RENOM_QTY, p_source_class,p_source_attr),0) * nvl(n.desired_pct,100)/100) target
		FROM   cntr_day_dp_nom n
		WHERE  n.daytime = trunc(cp_daytime) and object_id
           in (SELECT object_id from ov_contract where BF_PROFILE in (select profile_code from bf_profile_setup where bf_code = 'SD.0019'));

	ld_date DATE;
	ld_target_date DATE;
	ln_target	NUMBER;
	lv_exist	VARCHAR2(1);

BEGIN
	ld_target_date	:= p_daytime;	-- Initially target date is the same as input date
	ld_date			:= 	getOffset(p_daytime);

	IF 	p_daytime < ld_date THEN
		ld_target_date := p_daytime + 1;	--	target day is applied to next day if input date is less than production day start
	END IF;

	--validate if any other targets exists later in the day
	FOR curValidate IN c_validate (ld_target_date, ld_date+1) LOOP
		IF curValidate.daytime = ld_target_date THEN
			lv_exist := 'Y';
		ELSE
			RAISE_APPLICATION_ERROR(-20523, 'A target cannot be created when there are other targets later in the day');
		END IF;
	END LOOP;

	-- sum find target
	FOR curValidate IN c_total (ld_date) LOOP
		ln_target := curValidate.target;
	END LOOP;

	-- update or insert new target
	IF lv_exist = 'Y' THEN
		UPDATE dry_gas_target SET target_qty = ln_target, change_reason = p_change_reason, LAST_UPDATED_BY = p_user WHERE daytime = ld_target_date;
	ELSE
		INSERT INTO dry_gas_target (daytime, target_qty, change_reason, created_by) VALUES (ld_target_date, ln_target, p_change_reason, p_user);
	END IF;

	-- Calling user-exit procedure for possible additional functionality
	ue_dry_gas_target.createWithinDayTarget(ld_target_date, p_change_reason, p_user);

	NULL;
END createWithinDayTarget;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getTargetQty
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions: ec_class_attr_presentation.uom_code
--				  : ecdp_contract_attribute.getAttributeString
--                : ecdp_Contract_availability.getCalculatedQty
-- Configuration
-- required       :
--
-- Behaviour      : Returns null if calculated value for target UOM or nominated UOM is not present.
--
--------------------------------------------------------------------------------------------------
FUNCTION getTargetQty(
					p_object_id VARCHAR2,
					p_daytime DATE,
					p_delivery_point_id VARCHAR2,
					p_nominated_qty NUMBER,
					p_source_class	VARCHAR2,
					p_source_attr	VARCHAR2
					)
RETURN NUMBER
--</EC-DOC>

IS
	ln_calc_qty 			NUMBER;
	ln_nom_uom_calc_qty 	NUMBER;
	ln_uom 					VARCHAR2(32);
	ln_nom_uom 				VARCHAR2(32);

BEGIN
	-- Retrieving target-UOM for current class/attribute.
	-- As function is used by both before- and within- day target, class-name/attr_name is sent as argument
	ln_uom			:= ec_class_attr_presentation.uom_code(p_source_class,p_source_attr);

	-- Retrieving nominated UOM
	ln_nom_uom		:= ecdp_contract_attribute.getAttributeString(p_object_id,'NOM_UOM',p_daytime);

	-- Calculated quantity with respect to target UOM (Might be null if uom is not present or conversion is not available
	ln_calc_qty		:= ecdp_Contract_availability.getCalculatedQty(p_object_id,p_delivery_point_id,p_daytime,ln_uom);

	-- Calculated quantity with respect to nominated UOM (Might be null if uom is not present or conversion is not available
	ln_nom_uom_calc_qty := ecdp_Contract_availability.getCalculatedQty(p_object_id,p_delivery_point_id,p_daytime,ln_nom_uom);

	IF ln_nom_uom_calc_qty = 0 THEN
	   ln_nom_uom_calc_qty := NULL;
	END IF;

	RETURN ln_calc_qty * (p_nominated_qty/ln_nom_uom_calc_qty);

END getTargetQty;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getWithinTargetQty
-- Description    : checks if nominated_qty ack_qty renom_qty has values
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions: getTargetQty(p_object_id,p_daytime, p_delivery_point_id,p_ack_qty);
--				  :
--                :
-- Configuration
-- required       :
--
-- Behaviour      : Help-function for procedure createBeforeDayTarget
--
--------------------------------------------------------------------------------------------------
FUNCTION getWithinTargetQty(p_object_id VARCHAR2,
									 p_delivery_point_id VARCHAR2,
									 p_daytime DATE,
									 p_nominated_qty NUMBER,
									 p_ack_qty NUMBER,
									 p_renom_qty NUMBER,
									 p_source_class VARCHAR2,
									 p_source_attr VARCHAR2
									 )
RETURN NUMBER
--</EC-DOC>

IS
	ln_value NUMBER := 0;

BEGIN

	IF p_ack_qty IS NOT NULL THEN
		ln_value := getTargetQty(p_object_id,p_daytime, p_delivery_point_id,p_ack_qty,p_source_class,p_source_attr);
	ELSIF p_renom_qty IS NOT NULL THEN
		ln_value := getTargetQty(p_object_id,p_daytime, p_delivery_point_id,p_renom_qty,p_source_class,p_source_attr);
	ELSE
		ln_value := getTargetQty(p_object_id,p_daytime, p_delivery_point_id,p_nominated_qty,p_source_class,p_source_attr);
	END IF;

RETURN ln_value;

END getWithinTargetQty;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getProjectedTargetQty
-- Description    : returns the projected target quantity based on the calculated quantity
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions: ec_class_attr_presentation.uom_code ecdp_Contract_availability.getCalculatedQty
--				  :
--                :
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getProjectedTargetQty(p_object_id VARCHAR2,
										 p_delivery_point_id VARCHAR2,
										 p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
ln_calc_qty NUMBER;
ln_uom VARCHAR(32);

BEGIN
	-- Retrieving target-UOM for current class/attribute
	ln_uom			:= ec_class_attr_presentation.uom_code('SCTR_DAY_NOM_WITHIN_TARG','PROJECTED_QTY');

	-- Calculated quantity with respect to target UOM (Might be null if uom is not present or conversion is not available
	ln_calc_qty		:= ecdp_Contract_availability.getCalculatedQty(p_object_id,p_delivery_point_id,p_daytime,ln_uom);

	IF ln_calc_qty IS NULL THEN
			RETURN NULL;
	END	IF;

	RETURN ln_calc_qty;

END getProjectedTargetQty;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getOffset
-- Description    : Returns the new daytime using PROD_DAY_START in system attributes
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--				  :
--                :
-- Configuration
-- required       :
--
-- Behaviour      : Help-function for procedure createBeforeDayTarget and createWithinDayTarget
--
--------------------------------------------------------------------------------------------------
FUNCTION getOffset(p_daytime DATE)
RETURN DATE
--</EC-DOC>

IS
	ln_day_offset	NUMBER;

BEGIN

    ln_day_offset :=  EcDp_ProductionDay.getProductionDayOffset(NULL,NULL,p_daytime);


	RETURN TRUNC(p_daytime) + ln_day_offset/24;

END getOffset;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getDryGasHourProfile
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--				  :
--                :
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getDryGasHourProfile(p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS

CURSOR 	c_tot_daily_flow (cp_daytime DATE) IS
	SELECT  SUM(Nvl(ecbp_dispatching_mapping.getCellValue('GAS_DAY_HOURLY_PROFILE',r.object_id,'DAILY_FLOW',cp_daytime),0)) sum_daily_flow
	FROM    dispatching_row_mapping r
	WHERE	r.bf_class_name = 'GAS_DAY_HOURLY_PROFILE';

CURSOR	c_hours_in_day (cp_daytime DATE) IS
	SELECT 	count(*) count
	FROM	wet_gas_hourly_profile
	WHERE 	daytime >= 	cp_daytime AND
			daytime <	cp_daytime +1;

CURSOR c_target (cp_daytime DATE) IS
	SELECT 	daytime, target_qty
	FROM  	dry_gas_target
	WHERE  	daytime = cp_daytime;

	ld_date	DATE;
	ln_hours NUMBER;

	lb_first_target BOOLEAN := TRUE;
	ln_first_target NUMBER;
	ln_current_target NUMBER;
	ld_current_date DATE;

	ln_dry_so_far NUMBER;
	ln_wet_so_far NUMBER;
	li_hrs_so_far INTEGER;

	ln_total_dry NUMBER;
	ln_total_wet NUMBER;
	li_last_target_hrs INTEGER;

	ln_return_value NUMBER;
	li_hours_in_day	INTEGER;
	ln_wet_gas_flow_rate NUMBER;


BEGIN
	ld_date := getOffset(TRUNC(p_daytime));

	IF p_daytime < ld_date THEN
	   ld_date := ld_date - 1;
	END IF;

	-- Handelig summer/winter time. Uses wet gas since it is already handled there
	FOR c_val IN c_hours_in_day (ld_date) LOOP
	   li_hours_in_day := c_val.count;
	END LOOP;

	ln_hours := Abs(p_daytime - ld_date) * li_hours_in_day;

	-- get total wet (only used for first target)
	FOR c_total_wet IN c_tot_daily_flow (TRUNC(ld_date)) LOOP
	   ln_total_wet := c_total_wet.sum_daily_flow;
	END LOOP;

	IF Nvl(ln_total_wet,0) = 0 THEN
	   RETURN ln_total_wet;
	END IF;

	IF ln_hours IS NULL OR li_hours_in_day  = 0 THEN
	   RETURN NULL;
	END IF;

	-- get first targe
	FOR curTarget IN c_target (ld_date) LOOP
		ln_first_target := curTarget.target_qty;
	END LOOP;

	FOR li_hrs_so_far IN 0 .. ln_hours LOOP
		-- get wet gas profile for this time in day
		ln_wet_gas_flow_rate := Nvl(ec_WET_GAS_HOURLY_PROFILE.flow_rate(p_daytime), ecbp_wet_gas.getDailyFlowRatePrHour(p_daytime));

		--get new target
		ld_current_date := ld_date + (li_hrs_so_far/li_hours_in_day);

		FOR curCurrentTarget IN c_target (ld_current_date) LOOP
			IF (curCurrentTarget.daytime > ld_date) THEN
				ln_current_target := curCurrentTarget.target_qty;

				lb_first_target := FALSE;
				ln_total_wet := Nvl(ln_wet_so_far, ln_total_wet);
				ln_total_dry := Nvl(ln_dry_so_far,0);
				li_last_target_hrs := li_hrs_so_far;
			END IF;
		END LOOP;

		ln_wet_so_far := Nvl(ln_wet_so_far,0)+ ln_wet_gas_flow_rate;

		IF lb_first_target THEN
		   ln_return_value := (ln_first_target * ln_wet_gas_flow_rate / ln_total_wet);
		   ln_dry_so_far := Nvl(ln_dry_so_far,0) + Nvl(ln_return_value,0);
		ELSE
			ln_return_value := ((ln_current_target * li_hours_in_day - Nvl(ln_total_dry,0))/(li_hours_in_day-li_last_target_hrs) * (ln_wet_gas_flow_rate / ln_total_wet * li_last_target_hrs));
			ln_dry_so_far:= Nvl(ln_dry_so_far,0) + ln_return_value;
		END IF;
	END LOOP;

	RETURN ln_return_value;

END getDryGasHourProfile;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getProjectedActualPct
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--				  :
--                :
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getProjectedActualPct(p_object_id VARCHAR2,
										 p_delivery_point_id VARCHAR2,
										 p_daytime DATE,
                     p_nominated_qty NUMBER)

RETURN NUMBER
--</EC-DOC>
IS
  ln_calc_pct NUMBER;
  ln_target_qty NUMBER;

BEGIN
  ln_target_qty := getTargetQty(p_object_id,p_daytime, p_delivery_point_id,p_nominated_qty,'SCTR_DAY_NOM_WITHIN_TARG','PROJECTED_QTY');

  IF ln_target_qty = 0 THEN
	   RETURN NULL;
  ELSE
     ln_calc_pct := 100 *((ecbp_dry_gas_target.getProjectedTargetQty(p_object_id,p_delivery_point_id,p_daytime))/ln_target_qty);
	END IF;

  RETURN ln_calc_pct;

END getProjectedActualPct;


END EcBp_Dry_Gas_Target;