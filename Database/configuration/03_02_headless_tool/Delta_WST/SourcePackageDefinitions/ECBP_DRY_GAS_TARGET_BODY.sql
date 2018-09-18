CREATE OR REPLACE PACKAGE BODY EcBp_Dry_Gas_Target IS
/****************************************************************
** Package        :  EcBp_Dry_Gas_Target
**
** $Revision: 1.13 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Stian Skj?tad
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
** 21.10.13			leeeewei		ECPD-25002: Added function getNomLocTargetQty and createNomLocTarget
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
	ln_uom			:= EcDp_ClassMeta_Cnfg.getUomCode(p_source_class,p_source_attr);

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
	ln_uom			:= EcDp_ClassMeta_Cnfg.getUomCode('SCTR_DAY_NOM_WITHIN_TARG','PROJECTED_QTY');

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

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getNomLocTargetQty
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
FUNCTION getNomLocTargetQty(p_nominated_qty NUMBER,
                            p_desired_pct NUMBER)

RETURN NUMBER
--</EC-DOC>
IS

  ln_desired_qty NUMBER;

BEGIN

  ln_desired_qty := p_nominated_qty * p_desired_pct/100;

  RETURN ln_desired_qty;

END getNomLocTargetQty;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : createNomLocTarget
-- Description    : The function insert a new row into OBJLOC_DAY_TARGET
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : OBJLOC_DAY_TARGET
--
--
-- Using functions: getNomLocTargetQty
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------

PROCEDURE createNomLocTarget(p_nomloc_id     VARCHAR2,
                             p_daytime       DATE,
                             p_change_reason VARCHAR2,
                             p_valid_from    DATE,
                             p_user          VARCHAR2 DEFAULT NULL)
--</EC-DOC>
 IS
  CURSOR c_exists(cp_valid_from DATE, cp_end DATE, cp_object_id VARCHAR2) IS
    SELECT o.valid_from_date
      FROM objloc_day_target o
     WHERE o.valid_from_date >= cp_valid_from
       AND o.valid_from_date < cp_end
       and object_id = cp_object_id;

  CURSOR c_total(cp_nom_loc_id VARCHAR2, cp_daytime DATE) IS
    SELECT sum(nvl(ecbp_dry_gas_target.getNomLocTargetQty(n.scheduled_qty,n.desired_pct),0)) target_qty
      FROM nompnt_day_nomination n
     where n.nomination_type = 'SALE_NOM'
       and (n.exit_location_id = cp_nom_loc_id or
           n.entry_location_id = cp_nom_loc_id)
       and n.daytime = trunc(cp_daytime);

  CURSOR c_subday_exist(cp_object_id VARCHAR2, cp_valid_from DATE, cp_summer_time VARCHAR2, cp_production_day DATE) IS
	SELECT 1
	  FROM objloc_sub_day_target
	 WHERE object_id = cp_object_id
		 AND daytime = cp_valid_from
		 AND summer_time = cp_summer_time
     AND production_day = cp_production_day;

  ld_offset_date DATE;
  ld_target_date DATE;
  ln_target      NUMBER;
  lv_exist       VARCHAR2(1);
  lv_insert         VARCHAR(1);
  lv_summer_time VARCHAR2(1);
  ld_production_day DATE;
  ld_daytimes EcDp_Date_Time.Ec_Unique_Daytimes;
  ld_prod_daytime DATE;

BEGIN

  -- If valid from is blank, the time for the valid from is same as production day start
  IF p_valid_from IS NULL THEN
    ld_target_date := Ecdp_Contractday.getProductionDayStart('NOMINATION_LOCATION',p_nomloc_id,p_daytime);
  ELSE
	ld_target_date := p_valid_from + (p_daytime - trunc(p_valid_from));  -- Target date is the same as input date (p_daytime + valid from hours)
  END IF;

  ld_offset_date := getOffset(p_daytime);

  IF ld_target_date < ld_offset_date THEN
    ld_target_date := ld_target_date + 1; -- target day is applied to next day if input date is less than production day start
  END IF;

  --validate if any other targets exists later in the day
  FOR curExists IN c_exists(ld_target_date, ld_offset_date + 1, p_nomloc_id) LOOP
    IF curExists.valid_from_date = ld_target_date THEN
      lv_exist := 'Y';
    ELSE
      RAISE_APPLICATION_ERROR(-20523,
                              'A target cannot be created when there are other targets later in the day');
    END IF;
  END LOOP;

  -- sum find target
  FOR curValidate IN c_total(p_nomloc_id, ld_offset_date) LOOP
    ln_target := curValidate.target_qty;
  END LOOP;

  -- update or insert new target
  IF lv_exist = 'Y' THEN
    UPDATE objloc_day_target
       SET target_qty      = ln_target,
           change_reason   = p_change_reason,
           last_updated_by = p_user,
           rev_no          = rev_no + 1
     WHERE daytime = p_daytime
       and object_id = p_nomloc_id
       and valid_from_date = ld_target_date;
  ELSE
    INSERT INTO objloc_day_target
      (object_id,
       daytime,
       valid_from_date,
       target_qty,
       change_reason,
       created_by)
    VALUES
      (p_nomloc_id,
       p_daytime,
       ld_target_date,
       ln_target,
       p_change_reason,
       p_user);
  END IF;

  ld_production_day := p_daytime;
  ld_daytimes := ecdp_contractday.getProductionDayDaytimes('NOMINATION_LOCATION', p_nomloc_id, ld_production_day);  	-- Retrieves system attribute production day start

  -- Check if sub daily records exists when new target is created, if not, these should be created
  FOR i in 1..ld_daytimes.COUNT LOOP
    EXIT WHEN lv_exist = 'Y';
    lv_insert := 'Y';
    ld_prod_daytime := ld_daytimes(i).daytime;
    lv_summer_time := ld_daytimes(i).summertime_flag;

      FOR cur_exist IN c_subday_exist(p_nomloc_id, ld_prod_daytime, lv_summer_time, ld_production_day) LOOP

  	      lv_insert := 'N';

      END LOOP;

      IF lv_insert = 'Y' THEN
         insert into objloc_sub_day_target
           (OBJECT_ID, DAYTIME, SUMMER_TIME, PRODUCTION_DAY)
         VALUES
           (p_nomloc_id, ld_prod_daytime, lv_summer_time, ld_production_day);
      END IF;

  END LOOP;

  ue_dry_gas_target.createNomLocTarget(p_nomloc_id, p_daytime, p_valid_from);

END createNomLocTarget;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getEndDayTargetQty
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : OBJLOC_DAY_TARGET
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Returns End of Day Target Quantity.
--
--------------------------------------------------------------------------------------------------
FUNCTION getEndDayTargetQty(p_object_id       VARCHAR2,
                            p_daytime         DATE,
                            p_production_day DATE) RETURN NUMBER
--</EC-DOC>
 IS
  CURSOR c_get_target(cp_object_id       varchar2,
                      cp_daytime         DATE,
                      cp_production_day DATE) IS
    SELECT target_qty
      FROM OBJLOC_DAY_TARGET
     WHERE object_id = cp_object_id
       AND daytime = cp_production_day
       AND valid_from_date =
           (SELECT max(valid_from_date)
              FROM OBJLOC_DAY_TARGET
             WHERE object_id = cp_object_id
               AND valid_from_date <= cp_daytime
               AND daytime = cp_production_day);

  ln_target NUMBER := 0;
BEGIN
  FOR c_target IN c_get_target(p_object_id, p_daytime, p_production_day) LOOP
    ln_target := c_target.target_qty;
  END LOOP;

  RETURN ln_target;

END getEndDayTargetQty;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getNomLocProfile
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--				        :
--                :
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getNomLocProfile(p_object_id varchar2, p_daytime DATE, p_production_day DATE)
RETURN NUMBER
--</EC-DOC>

IS
CURSOR c_target (cp_object_id varchar2, cp_daytime DATE) IS
	SELECT 	valid_from_date, target_qty
	FROM  	objloc_day_target
	WHERE  	valid_from_date = cp_daytime AND
          object_id = cp_object_id;

  ld_daytimes EcDp_Date_Time.Ec_Unique_Daytimes;
	ld_prod_day_start	DATE;

	lb_first_target BOOLEAN := TRUE;
	ln_first_target NUMBER;
	ln_current_target NUMBER;
	ld_current_date DATE;

	ln_gas_so_far NUMBER;
	li_hrs_so_far INTEGER;

	ln_total_gas NUMBER;
	li_last_target_hrs INTEGER;

	ln_return_value NUMBER;
	li_hours_in_day	INTEGER;

BEGIN
  --get production day
	ld_prod_day_start := Ecdp_Contractday.getProductionDayStart('NOMINATION_LOCATION', p_object_id, p_production_day);

	IF p_daytime < ld_prod_day_start THEN
	   ld_prod_day_start := ld_prod_day_start - 1;
	END IF;

  ld_daytimes := Ecdp_Contractday.getProductionDayDaytimes('NOMINATION_LOCATION', p_object_id, p_production_day);

	-- Handeling summer/winter time.
  li_hours_in_day := ld_daytimes.count;

	IF li_hours_in_day  = 0 THEN
	   RETURN NULL;
	END IF;

	-- get first target
	FOR curTarget IN c_target (p_object_id, ld_prod_day_start) LOOP
		ln_first_target := curTarget.target_qty;
	END LOOP;

  FOR li_hrs_so_far IN 1..ld_daytimes.count LOOP

   IF (p_daytime>= ld_daytimes(li_hrs_so_far).daytime) THEN

      --get new date target by productionDayDaytimes
      ld_current_date := ld_daytimes(li_hrs_so_far).daytime;
      FOR curCurrentTarget IN c_target (p_object_id, ld_current_date) LOOP
        IF (curCurrentTarget.valid_from_date > ld_prod_day_start) THEN
          ln_current_target := curCurrentTarget.target_qty;

          lb_first_target := FALSE;
          ln_total_gas := Nvl(ln_gas_so_far,0);
          li_last_target_hrs := li_hrs_so_far-1;
        END IF;
      END LOOP;

      IF lb_first_target THEN
         ln_return_value := ln_first_target ;
         ln_gas_so_far := Nvl(ln_gas_so_far,0) + Nvl(ln_return_value,0);
      ELSE

        ln_return_value := ((ln_current_target * li_hours_in_day) - Nvl(ln_total_gas,0))/(li_hours_in_day-li_last_target_hrs);
        ln_gas_so_far:= Nvl(ln_gas_so_far,0) + ln_return_value;
      END IF;
   ELSE
     RETURN ln_return_value;
   END IF;
	END LOOP;

	RETURN ln_return_value;

END getNomLocProfile;

END EcBp_Dry_Gas_Target;