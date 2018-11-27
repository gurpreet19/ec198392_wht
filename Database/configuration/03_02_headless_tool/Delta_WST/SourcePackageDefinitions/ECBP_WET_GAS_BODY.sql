CREATE OR REPLACE PACKAGE BODY EcBp_Wet_Gas IS
/****************************************************************
** Package        :  EcBp_Wet_Gas
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.01.2006  Stian Skj�tad
**
** Modification history:
**
** Date      		Whom  			Change description:
** --------   		----- 			--------------------------------------
** 17.05.2006    Lau          Tracker#3800 Modified function getProcessingUnitFlowRatePrHr
** 11.07.2006    Lau          Tracker#4150 Modified function getProcessingUnitFlowRatePrHr
******************************************************************/

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function		  : previousProdDate
-- Description    : Returns start date or end date of production day that argument date belongs to (from system attribute prod_day_start)
--				  : Input argument is date and either 'START' or 'END' which returns start-date or end-date respectively.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions: ecbp_dry_gas_target.getOffset
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION productionDate(p_daytime DATE,
						p_limit	VARCHAR
)
RETURN DATE
--</EC-DOC>
IS
ld_previous_day_start	DATE;
ld_previous_day_end		DATE;
ld_result				DATE;
BEGIN

ld_previous_day_start	:=	ecbp_dry_gas_target.getOffset(TRUNC(p_daytime-1));
ld_previous_day_end		:=	(ld_previous_day_start + 1);


IF p_daytime < ld_previous_day_end THEN
		IF p_limit = 'START' THEN
		ld_result	:=	ld_previous_day_start;
		ELSE
		IF p_limit = 'END' THEN
		ld_result	:=	ld_previous_day_end;
		END IF;
		END IF;

ELSE IF p_daytime >= ld_previous_day_end THEN
		ld_result	:=	ecbp_dry_gas_target.getOffset(TRUNC(p_daytime));
		IF p_limit = 'START' THEN
		 RETURN ld_result;
		ELSE
		IF p_limit = 'END' THEN
		ld_result	:=	(ld_result + 1);
		END IF;
		END IF;
END IF;
END IF;

RETURN ld_result;
END productionDate;



--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function		  : getDailyFlowRatePrHour
-- Description    : Averages the total flow over each hour
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : wet_gas_hourly_profile
--
--
-- Using functions: ecbp_dispatching_mapping.getCellValue, ecbp_dry_gas_target.getOffset
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getDailyFlowRatePrHour(p_daytime DATE
)
RETURN NUMBER
--</EC-DOC>

IS
ln_result				NUMBER	:= 0;
ln_hours				NUMBER	:= 0;
ln_tot_daily_flow		NUMBER	:= 0;
ln_sum_daily_flow_rate	NUMBER	:= 0;
ln_flow_rate_count		NUMBER	:= 0;
ln_source				NUMBER 	:= 0;
ln_divider				NUMBER;


CURSOR 	c_tot_daily_flow (cp_daytime DATE) IS
	SELECT  SUM(Nvl(ecbp_dispatching_mapping.getCellValue('GAS_DAY_HOURLY_PROFILE',r.object_id,'DAILY_FLOW',TRUNC(productionDate(cp_daytime,'START'))),0)) sum_daily_flow
	FROM    dispatching_row_mapping r
	WHERE	r.bf_class_name = 'GAS_DAY_HOURLY_PROFILE';


CURSOR 	c_sum_daily_flow_rate IS
	SELECT  SUM(Nvl(wg.flow_rate,0)) sum_daily_flow_rate
	FROM	wet_gas_hourly_profile wg
	WHERE	daytime >= productionDate(p_daytime,'START') AND
			daytime <  productionDate(p_daytime,'END');

CURSOR 	c_rate_not_null IS
	SELECT  ROWNUM
	FROM	wet_gas_hourly_profile wg
	WHERE	daytime >= productionDate(p_daytime,'START')	AND
			daytime <  productionDate(p_daytime,'END')		AND
			wg.flow_rate IS NOT NULL;

CURSOR c_hours IS
	SELECT 	count(daytime) hours
	FROM	wet_gas_hourly_profile
	WHERE	daytime >= productionDate(p_daytime,'START') AND
			daytime <  productionDate(p_daytime,'END');


BEGIN
	-- Retrieving day hours
	FOR c_val IN c_hours LOOP
		ln_hours := c_val.hours;
	END LOOP;

	-- Summing daily flow into plant
	FOR c_val IN c_tot_daily_flow (p_daytime) LOOP
		ln_tot_daily_flow := c_val.sum_daily_flow;
	END LOOP;

	-- Summing daily flow rates
	FOR c_val IN c_sum_daily_flow_rate LOOP
		ln_sum_daily_flow_rate := c_val.sum_daily_flow_rate;
	END LOOP;

	-- Counting flow rates not null
	FOR c_val IN c_rate_not_null LOOP
		ln_flow_rate_count := c_val.rownum;
	END LOOP;

	ln_source 	:= (ln_hours * ln_tot_daily_flow) - Nvl(ln_sum_daily_flow_rate,0);
	ln_divider	:= (ln_hours - Nvl(ln_flow_rate_count,0));

	-- Avoiding zero-division
	IF ((ln_divider IS NOT NULL) AND (ln_divider != 0)) THEN
		ln_result := Nvl(ln_source,0)/ln_divider;
		RETURN ln_result;

	ELSE -- Zero-division - Assuming divider is equal to 1
		ln_result := Nvl(ln_source,0);
		RETURN ln_result;
	END IF;

END getDailyFlowRatePrHour;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function		  : getProcessingUnitFlowRatePrHr
-- Description    : For each hourly value ("Daily flow rate per hour"),
--				  : the capacities and priorities set for the units involved will be used to route the flow through the units.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : disp_processing_unit
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
FUNCTION getProcessingUnitFlowRatePrHr(p_daytime DATE,
										 p_flow_rate NUMBER,
										 p_processing_unit VARCHAR2
)
RETURN NUMBER
--</EC-DOC>

IS
ln_unit_rate	NUMBER;
ln_flow_rate NUMBER;

CURSOR c_unit IS
	SELECT	d.code, d.capacity, d.priority
	FROM 	disp_processing_unit d
	WHERE	daytime=(SELECT MAX(daytime) FROM disp_processing_unit
	WHERE daytime <= TRUNC(productionDate(p_daytime,'START')))
	ORDER BY Nvl(priority, 9999999);
BEGIN

ln_flow_rate := p_flow_rate;

FOR c_val IN c_unit LOOP

    IF (ln_flow_rate >= Nvl(c_val.capacity, 0)) THEN
        ln_unit_rate := Nvl(c_val.capacity, 0);
    ELSE
        ln_unit_rate := ln_flow_rate;
    END IF;

    ln_flow_rate := ln_flow_rate - Nvl(c_val.capacity, 0);

   IF ln_unit_rate <= 0  THEN
     RETURN 0;
   END IF;

   IF p_processing_unit = c_val.code THEN
	   RETURN Nvl(ln_unit_rate,0);
   END IF;

END LOOP;
RETURN 0;

END getProcessingUnitFlowRatePrHr;


END EcBp_Wet_Gas;