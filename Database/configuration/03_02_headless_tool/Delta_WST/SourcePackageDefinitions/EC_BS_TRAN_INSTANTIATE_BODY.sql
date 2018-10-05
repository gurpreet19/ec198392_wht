CREATE OR REPLACE PACKAGE BODY Ec_Bs_Tran_Instantiate IS
/***********************************************************************************************************************************************
** Package        :  Ec_Bs_Tran_Instantiate, body part
**
** $Revision: 1.16 $
**
** Purpose        :  Instantiate records in EC Tran data tables.
**
** Created        :  24.03.2006  Kristin Eide
**
** Documentation  :  www.energy-components.com
**
** Short how-to:
**	Create an instantiate procedure for the table(s) you want to instantiate. In this procedure
**	create a cursor that finds the primary keys for those tables you want to instantiate.
**	Loop this cursor and insert records for the daytime(s) taken as parameter.
**	Add the created procedure to the for loop in new_day_end.
**
** Modification history:
**
** Date        Whom  			Change description:
** ------      ----- 			-----------------------------------------------------------------------------------------------
** 24.03.2006  eideekri   		Initial version
** 24.03.2006  eideekri   		Added procedure new_day_end and i_dp_sub_day_target.
** 28.08.2006  zakiiari			TI#4238: Updated i_dp_sub_day_target to instantiate interval dates
** 06.08.2012  masamken			ECPD-21446 added procedures newMonth, i_contract_inventory_day and i_contract_inventory_mth
** 10.04.2013  limmmchu			ECPD-20005: Modified new_day_end to have the checking of future date for p_to_daytime
** 16.08.2013  leeeewei			ECPD-19773: Added function i_contract_seasonality
** 12.12.2013  farhaann			ECPD-26073: Added procedure i_bu_comment
** 11.09.2015  kashisag     ECPD-28855: Modified the package to allow future date for Initiate Day
** 13.11.2015  abdulmaw     ECPD-32675: Modified the package to fix INITIATE_DAY
************************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : new_day_end
-- Description    : Performs instantiation at day end
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : system_days
--
-- Using functions: Ecdp_Timestamp.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert new rows in system_days as needed. Then calls the individual instantiation
--                  methods that should run on day end. Finally runs procedure newMonth
--
---------------------------------------------------------------------------------------------------
PROCEDURE new_day_end(
   p_daytime      DATE,
   p_to_daytime   DATE DEFAULT NULL
)
--</EC-DOC>
IS
   ld_day         DATE;
   ld_end_date    DATE;
   lr_system_day  system_days%ROWTYPE;
   lv2_initiate_day_flag  varchar2(1);

   CURSOR c_daytime IS
     SELECT daytime
     FROM system_days
     WHERE daytime BETWEEN p_daytime
     AND (CASE WHEN p_to_daytime IS NULL and lv2_initiate_day_flag ='Y' THEN p_daytime
                 WHEN p_to_daytime IS NULL and lv2_initiate_day_flag ='N' THEN TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD')
                   ELSE p_to_daytime END );

BEGIN

  -- ECPD-28855 Check the system property and based on that exclude or include future dates
  lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');

   -- make sure all rows are present in system_days
	IF ( p_to_daytime > Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') AND lv2_initiate_day_flag = 'N') THEN
	   ld_end_date := Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD');

	ELSIF (p_to_daytime IS NULL OR p_to_daytime < p_daytime) THEN
	   ld_end_date := p_daytime;

	ELSE
	   ld_end_date := p_to_daytime;

	END IF;

  IF ( lv2_initiate_day_flag = 'Y' OR ( lv2_initiate_day_flag = 'N' AND p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD')) ) THEN

		FOR ln_day_count IN 0 .. (ld_end_date - p_daytime) LOOP

			ld_day := p_daytime + ln_day_count;
			lr_system_day := ec_system_days.row_by_pk(ld_day);

			IF lr_system_day.daytime IS NULL THEN
			   INSERT INTO system_days (daytime) VALUES (ld_day);
			END IF; -- else skip

		END LOOP;



		FOR mycur IN c_daytime LOOP
			 i_dp_sub_day_target(mycur.daytime);
			 i_contract_inventory_day(mycur.daytime);
			 i_bu_comment(mycur.daytime);
			 newMonth(mycur.daytime);
		END LOOP;
   END IF;
END new_day_end;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_dp_sub_day_target
-- Description    : Performs instantiation of sub daily delivery point targets on d-2
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : DELPNT_VERSION, DELPNT_SUB_DAY_TARGET
--
-- Using functions: EcDp_Delivery_Point_Nomination.getDeliveryPointProductionDay()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_dp_sub_day_target(
   p_daytime      DATE
)
--</EC-DOC>
IS
	ld_daytimes       EcDp_Date_Time.Ec_Unique_Daytimes;
	ld_production_day DATE;
	ld_summer_time    VARCHAR2(1);
	ld_prod_daytime   DATE;
	ln_insert         VARCHAR(1);
	ln_target_qty  NUMBER;
  ld_last_date      DATE;

   CURSOR cur_exit_delivery_point(cp_daytime DATE) IS
   SELECT object_id
   FROM DELPNT_VERSION t
   WHERE cp_daytime between t.daytime and nvl(t.end_date,cp_daytime+1)
   AND t.delpnt_type = 'EXIT';

	CURSOR cur_exist_test(cp_delivery_point_id VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2, cp_production_day DATE) IS
	SELECT 1
	FROM DELPNT_SUB_DAY_TARGET
	WHERE object_id = cp_delivery_point_id
		AND daytime = cp_daytime
		AND summer_time = cp_summer_time;


BEGIN

	ld_production_day := p_daytime;
  ld_last_date := p_daytime + 2;

  WHILE ld_production_day < ld_last_date +1 LOOP

  	FOR index_cur IN cur_exit_delivery_point(ld_production_day) LOOP

        	ld_daytimes := ecdp_productionday.getProductionDayDaytimes(NULL, index_cur.object_id, ld_production_day);

  		FOR li_pointer in 1..ld_daytimes.COUNT LOOP

  			ln_insert := 'Y';
  			ld_prod_daytime := ld_daytimes(li_pointer).daytime;
  			ld_summer_time := ld_daytimes(li_pointer).summertime_flag;


  			FOR cur_exist IN cur_exist_test(index_cur.object_id, ld_prod_daytime, ld_summer_time, ld_production_day) LOOP
  				ln_insert := 'N';
  			END LOOP;

  			IF ln_insert = 'Y' THEN
  				--get the sum of the output nomination at a given time and exit delivery point eg. the initital value of the target.
  				ln_target_qty := Nvl(EcDp_Delivery_Point_Nomination.getSubDayDelpntNomination(index_cur.object_id, ld_prod_daytime, 'DP_SUB_DAY_TARGET_EXIT'), 0);

  				INSERT INTO DELPNT_SUB_DAY_TARGET (OBJECT_ID, DAYTIME, SUMMER_TIME, PRODUCTION_DAY, TARGET_QTY)
  				VALUES (index_cur.object_id, ld_prod_daytime, ld_summer_time, ld_production_day, ln_target_qty);
  			END IF;
  		END LOOP;
  	END LOOP;
    ld_production_day := ld_production_day + 1;

  END LOOP;

END i_dp_sub_day_target;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :  newMonth
-- Description    :  Do instantiations on first day of each month
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  When called, check if date is first of month, and then call listed procedures.
--
---------------------------------------------------------------------------------------------------
PROCEDURE newMonth(p_daytime DATE)
--</EC-DOC>
IS

  lv2_initiate_day_flag  varchar2(1);

BEGIN

  -- ECPD-28855  Check the system property and based on that exclude or include future months and make sure date is the first in the month.
  lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');

  IF (TO_CHAR(p_daytime, 'DD') = '01' AND (( lv2_initiate_day_flag = 'Y') OR (lv2_initiate_day_flag ='N' AND p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD')))) THEN
	   -- procedures to call:
	   i_contract_inventory_mth(p_daytime);
	   i_contract_seasonality(p_daytime);
  END IF;

END newMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_contract_inventory_day
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : contract_inventory
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts empty records into cntr_day_dp_delivery for p_daytime for all combinations of
--                  gas sale contracts and delivery points extracted from table
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_contract_inventory_day(
   p_daytime DATE
)
--</EC-DOC>
IS

    CURSOR cur_get_keys IS
      SELECT DISTINCT ci.object_id
      FROM contract_inventory ci
      WHERE p_daytime >= ci.start_date
      AND p_daytime < Nvl(ci.end_date, p_daytime + 1)
      AND ci.object_id is not null
      AND NOT EXISTS
      (
       select 1
       from cntr_day_loc_inventory x
       where ci.object_id = x.object_id AND p_daytime = x.daytime
      );

BEGIN

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/tran/gd/instantiate/CNTR_INV_DAY', p_daytime) ='Y' THEN
       FOR mycur IN cur_get_keys LOOP
          INSERT INTO cntr_day_loc_inventory(object_id, daytime)
            VALUES(mycur.object_id,p_daytime);
      END LOOP;
  END IF;
END i_contract_inventory_day;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_contract_inventory_mth
-- Description    :
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
-- Behaviour      : Inserts empty records into cntr_mth_dp_delivery for p_daytime for all combinations of
--                  gas sale contracts and delivery points extracted from table
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_contract_inventory_mth(
p_daytime DATE)
--<EC-DOC>

IS

ld_daytime DATE := TRUNC (TO_DATE (p_daytime), 'MONTH');

   CURSOR cur_get_keys IS
      SELECT DISTINCT ci.object_id
      FROM contract_inventory ci
      WHERE ld_daytime >= ci.start_date
      AND ld_daytime < Nvl(ci.end_date, LAST_DAY(ld_daytime))
      AND ci.object_id is not null
      AND NOT EXISTS
      (
         SELECT 1
         from CNTR_INV_MTH_BAL  x
         where ci.object_id = x.object_id AND p_daytime = x.daytime
      );

BEGIN
  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/tran/gd/instantiate/CNTR_INV_MTH', p_daytime) ='Y' THEN
       FOR mycur IN cur_get_keys LOOP
          INSERT INTO cntr_inv_mth_bal(object_id, daytime)
            VALUES(mycur.object_id,p_daytime);
      END LOOP;
  END IF;
END i_contract_inventory_mth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_contract_seasonality
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CONTRACT_SEASONALITY
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts empty records into contract_seasonality. Instantiate records for 2 years ahead
--
---------------------------------------------------------------------------------------------------

PROCEDURE i_contract_seasonality(p_daytime DATE)
--<EC-DOC>
 IS

  ld_cur_daytime DATE;

  CURSOR cur_get_keys(cp_daytime DATE) IS
    SELECT DISTINCT c.object_id
      FROM contract c, bf_profile_setup b
     WHERE cp_daytime >= c.start_date
       AND cp_daytime < c.end_date
       AND c.tran_ind = 'Y'
       AND b.bf_code = 'CO.2071'
       AND b.profile_code = c.bf_profile
       AND NOT EXISTS (SELECT 1
              from contract_seasonality x
             where c.object_id = x.object_id
               AND cp_daytime = x.daytime
               AND c.tran_ind = 'Y'
               AND b.bf_code = 'CO.2071'
               AND b.profile_code = c.bf_profile);

BEGIN

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/tran/co/instantiate/CONTRACT_SEASONALITY',
                                          p_daytime) = 'Y' THEN

    FOR ln_mth_count IN 0 .. 24 LOOP
      ld_cur_daytime := add_months(p_daytime, ln_mth_count);
      FOR mycur IN cur_get_keys(ld_cur_daytime) LOOP
        INSERT INTO contract_seasonality
          (object_id, daytime, contract_year)
        VALUES
          (mycur.object_id,
           ld_cur_daytime,
           ecdp_contract.getContractYear(mycur.object_id, ld_cur_daytime));
      END LOOP;
    END LOOP;

  END IF;

END i_contract_seasonality;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_bu_comment
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : log_entry,business_unit
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts empty records into LOG_ENTRY for GD.0115 on daily basis
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_bu_comment(p_daytime DATE)
--</EC-DOC>
 IS

 CURSOR cur_log_entry IS
      SELECT DISTINCT bu.object_id
      FROM business_unit bu
      WHERE p_daytime >= bu.start_date
      AND p_daytime < Nvl(bu.end_date, p_daytime + 1)
      AND bu.object_id is not null
      AND NOT EXISTS
      (
       select 1
       from log_entry le
       where bu.object_id = le.object_id AND p_daytime = le.daytime
       and le.bf_code = 'GD.0115'
      );

BEGIN

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/tran/gd/instantiate/TRBU_DAY_COMMENT', p_daytime) ='Y' THEN
       FOR mycur IN cur_log_entry LOOP
          INSERT INTO log_entry(object_id, daytime, log_entry_comment, bf_code)
            VALUES(mycur.object_id, p_daytime, NULL, 'GD.0115' );
      END LOOP;
  END IF;

END i_bu_comment;

END ec_bs_tran_instantiate;