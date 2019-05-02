CREATE OR REPLACE PACKAGE ue_cntr_attr_dimension IS
/******************************************************************************
** Package        :  ue_cntr_attr_dimension, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for contract attributes screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 03.08.2012  farhaann ECPD-21414: Initial version
*/

FUNCTION getAttributeString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2) RETURN VARCHAR2;

FUNCTION getAttributeDate (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2) RETURN DATE;

FUNCTION getAttributeNumber (p_contract_id VARCHAR2, p_attribute_name VARCHAR2,p_daytime DATE, p_object_ec_code VARCHAR2) RETURN NUMBER;

END ue_cntr_attr_dimension;
/


CREATE OR REPLACE PACKAGE BODY ue_cntr_attr_dimension IS
/******************************************************************************
** Package        :  ue_cntr_attr_dimension, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for contract attributes screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** ------      -----    -----------------------------------------------------------------------------------------------
** 03.08.2012  farhaann ECPD-21414: Initial version
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getAttributeString
-- Description    : Returns a string value for requested attribute
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
FUNCTION getAttributeString (p_contract_id VARCHAR2,
							 p_attribute_name VARCHAR2,
							 p_daytime DATE,
							 p_object_ec_code VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
lv_value	VARCHAR2(240);

BEGIN
RETURN NULL;
END getAttributeString;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeDate
-- Description    : Returns a date value for requested attribute
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
FUNCTION getAttributeDate (p_contract_id VARCHAR2,
						   p_attribute_name VARCHAR2,
						   p_daytime DATE,
						   p_object_ec_code VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
ld_value	DATE;

BEGIN
RETURN NULL;
END getAttributeDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeNumber
-- Description    : Returns a number value for requested attribute
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
FUNCTION getAttributeNumber (p_contract_id VARCHAR2,
							 p_attribute_name VARCHAR2,
						     p_daytime DATE,
							 p_object_ec_code VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR validForecasts(cp_year DATE) IS
    SELECT object_id, FORECAST_OBJECT_ID, CREATED_DATE as ADP_CREATED_DATE
    FROM ov_forecast_tran_cp
    WHERE scenario_type = 'ADP'
    AND scen_approval_date IS NOT NULL
	AND SCEN_APPROVAL_STATUS = 'A'
    AND object_start_date = add_months(trunc(cp_year, 'YYYY'), 3)
	AND CREATED_DATE = (SELECT MAX(CREATED_DATE)
	    FROM ov_forecast_tran_cp
		WHERE scenario_type = 'ADP'
		AND scen_approval_date IS NOT NULL
		AND SCEN_APPROVAL_STATUS = 'A'
		AND object_start_date = add_months(trunc(cp_year, 'YYYY'), 3)
		)
    ORDER BY scen_approval_date DESC;

	CURSOR validRefEnt(cp_year DATE, cp_adp_date DATE, cp_lifting_account_id VARCHAR2, cp_include_recalc VARCHAR2 DEFAULT NULL) IS
	SELECT REF_ENT_VOL,PNC_ALLOWENCE ,PNC_CARRY_OVER
	FROM DV_CT_LA_YR_PC_REF_ENT
	WHERE RECORD_STATUS = 'A'
	AND DAYTIME = cp_year
	AND OBJECT_ID = cp_lifting_account_id
	AND CREATED_DATE = (
	SELECT MAX(CREATED_DATE)FROM DV_CT_LA_YR_PC_REF_ENT
	WHERE RECORD_STATUS = 'A'
	AND DAYTIME = cp_year
	AND OBJECT_ID = cp_lifting_account_id
	AND (cp_include_recalc IS NULL OR (cp_include_recalc = 'Y' AND PNC_CARRY_OVER IS NOT NULL))
	)
	;


    v_target_forecast VARCHAR2(32);
    v_target_forecast_object_id VARCHAR2(32);
	v_target_forecast_created_date VARCHAR2(32);

    v_total_scheduled_ly NUMBER := 0;
    v_yearly_entitlement_ly NUMBER;
    v_adjustment NUMBER;
    v_result NUMBER := 0;
	v_FCLThreshold NUMBER := 0 ;
	v_year DATE;
	v_loaded NUMBER := 0;

    v_total_pnc_events NUMBER := 0;
    v_yearly_lifer_pnc NUMBER := 0;
    v_yearly_CO NUMBER := 0;
    v_pnc_balance NUMBER := 0;


  ld_value date;
  lv_return NUMBER;
  lv_PCAllowance number;
	ln_value	number;
 	lv_prod_mass NUMBER := -9999;
  lv_liftYearStart Date;
  lv_liftYearEnd Date;
  lv_months number;
  lv_FCL_AdjVol NUMBER;
	v_adj_out NUMBER;
	v_adj_in NUMBER;
	v_pnc_adj NUMBER;
	v_FCL_adj NUMBER;


BEGIN


  IF(  p_attribute_name = 'LA_FCL') THEN
   --FCL Adjustment is calculated form the ARE Calculation. This function returns the FCL Adjsutment vol we do not calculate the FCL in the package

      IF((EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))) >= 1 AND EXTRACT(month from (TRUNC(p_daytime,'MONTH'))) < 4 )) THEN
        --Startdate is found by finding month from daytime, and add 8. Subtract the resulting month number from the daytime .
        --Jan Mth  1 + 8 = 9, 01/2014 - 09month = 04/2014
        --Feb Mth  2 + 8 = 10, 02/2015 - 10 month = 04/2014,
        --Mar Mth 3 + 8 = 11, 03/2015 - 11months = 04/2014
        --End Date is found by adding number of days in the year to the startdate
       -- ld_value := TRUNC(p_daytime,'MONTH');
        lv_months := (EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))))+8 ;
        lv_liftYearStart :=  TRUNC(p_daytime,'MONTH')+(ADD_MONTHS(TRUNC(p_daytime,'YEAR'),-lv_months)-TRUNC(p_daytime,'YEAR'));
        lv_liftYearEnd :=  (lv_liftYearStart-1) + (ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),12)-TRUNC(SYSDATE,'YEAR'));

      ELSE
       --Find the month from the daytime, subtract this from 4. Add the resulting months to daytime.
       --Aug Mth 4 - 8 = -4, Aug + (-4)month = April
       --May Mth 4 - 5 = -1, May + (-1)month = April
       --Dec Mth 4 - 12 = -10, Dec + (-8)months = April
        lv_months := 4-EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))) ;
        lv_liftYearStart :=  TRUNC(p_daytime,'MONTH')+(ADD_MONTHS(TRUNC(p_daytime,'YEAR'),lv_months)-TRUNC(p_daytime,'YEAR'))+1;
        lv_liftYearEnd :=  (lv_liftYearStart-1) + (ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),12)-TRUNC(SYSDATE,'YEAR'));
      END IF;

       SELECT FCL_ADJUSTMENT_VOL INTO lv_FCL_AdjVol FROM DV_CT_LA_YR_PC_REF_ENT WHERE OBJECT_ID = p_object_ec_code  AND DAYTIME >= lv_liftYearStart AND DAYTIME <= lv_liftYearEnd ;

    lv_return := lv_FCL_AdjVol;
  END IF;

   IF(  p_attribute_name = 'LA_PC_ALLOWANCE') THEN

      --determine which lifting year that we are looking at. The LY is from 01Apr To 31March
      -- If the date is between 01Jan and 31March then set LiftYearStart to 01-April- p_daytimeYEAR-1
      -- If the date is between 01Apr and 31Dec then set LiftYearStart to 01-April- p_daytimeYEAR

      --ln_value := extract(month from (TRUNC(p_daytime,'MONTH')));

        IF((EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))) >= 1 AND EXTRACT(month from (TRUNC(p_daytime,'MONTH'))) < 4 )) THEN
        --Startdate is found by finding month from daytime, and add 8. Subtract the resulting month number from the daytime .
        --Jan Mth  1 + 8 = 9, 01/2014 - 09month = 04/2014
        --Feb Mth  2 + 8 = 10, 02/2015 - 10 month = 04/2014,
        --Mar Mth 3 + 8 = 11, 03/2015 - 11months = 04/2014
        --End Date is found by adding number of days in the year to the startdate
       -- ld_value := TRUNC(p_daytime,'MONTH');
        lv_months := (EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))))+8 ;
        lv_liftYearStart :=  TRUNC(p_daytime,'MONTH')+(ADD_MONTHS(TRUNC(p_daytime,'YEAR'),-lv_months)-TRUNC(p_daytime,'YEAR'));
        lv_liftYearEnd :=  (lv_liftYearStart-1) + (ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),12)-TRUNC(SYSDATE,'YEAR'));

      ELSE
       --Find the month from the daytime, subtract this from 4. Add the resulting months to daytime.
       --Aug Mth 4 - 8 = -4, Aug + (-4)month = April
       --May Mth 4 - 5 = -1, May + (-1)month = April
       --Dec Mth 4 - 12 = -10, Dec + (-8)months = April
        lv_months := 4-EXTRACT(MONTH FROM (TRUNC(p_daytime,'MONTH'))) ;
        lv_liftYearStart :=  TRUNC(p_daytime,'MONTH')+(ADD_MONTHS(TRUNC(p_daytime,'YEAR'),lv_months)-TRUNC(p_daytime,'YEAR'))+1;
        lv_liftYearEnd :=  (lv_liftYearStart-1) + (ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),12)-TRUNC(SYSDATE,'YEAR'));
      END IF;

        --Find the total production volume for the period from all profit Centres
      --Need to chaneg SQL to sum on mass
      SELECT SUM(REF_ENT_MASS) INTO lv_prod_mass FROM DV_CT_LA_MTH_PC_REF_ENT WHERE OBJECT_ID = p_object_ec_code  AND DAYTIME >= lv_liftYearStart AND DAYTIME <= lv_liftYearEnd ;

      IF(lv_prod_mass IS NULL OR lv_prod_mass =0) THEN
        lv_PCAllowance := 0;
      ELSE
        lv_PCAllowance := lv_prod_mass / 1000000*0.8;
      END IF;

      lv_return := lv_PCAllowance;

  END IF;

--TLXT: 09-OCT-2014: CALCULATE FFCL PER LIFTER
	IF(  p_attribute_name = 'FFCL') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		v_FCLThreshold := EC_CONTRACT_ATTRIBUTE.attribute_number(ecdp_objects.getobjidfromcode('CONTRACT','C_WST_LNG'), 'FCL_LIMIT',v_year, '<=' );

	--tlxt:08-Oct-2014: Claculat FFCL to be used in Reference Entitlement
	--FFCL is the different betweeen Ref Ent and Cargo Request for a given lifting year.
	--the Reference Production used for both must be the same.
	--The key that ties this 2 together is the FORECAST_OBJECT_ID
	--The design is taking the last approved ADP per lifting year.
	--Based on the year parameter, we are able to get the last approved ADP. From there we are able to get the Forecast Object ID in order to get the REF_PROD
		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
		END LOOP;

		IF (v_target_forecast IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT sum(nom_grs_vol) INTO v_total_scheduled_ly
			FROM dv_fcst_stor_lift_nom
			WHERE forecast_id = v_target_forecast
			AND lifting_account_id = p_object_ec_code
			AND object_id = EC_STORAGE.object_id_by_uk('STW_LNG');
		END IF;

		--v_yearly_entitlement_ly := EC_CT_REFERENCE_ENTITLEMENT.REF_ENT_VOL_YR(p_object_ec_code, v_year, 'CT_LA_YR_PC_REF_ENT',v_target_forecast_object_id);
		v_yearly_entitlement_ly := 0;

		FOR item IN validRefEnt(v_year, NULL,p_object_ec_code) LOOP
			v_yearly_entitlement_ly := item.REF_ENT_VOL;
		END LOOP;

		IF (v_yearly_entitlement_ly IS NULL)  THEN
			lv_return := 0;
		ELSE
			v_adjustment := (v_yearly_entitlement_ly - v_total_scheduled_ly);
			IF (v_adjustment < -v_FCLThreshold) THEN
				lv_return := -v_FCLThreshold;
			ELSIF (v_adjustment > v_FCLThreshold) THEN
				lv_return := v_FCLThreshold;
			ELSE
			   lv_return := v_adjustment;
			END IF;
		END IF;
	END IF;

	IF(  p_attribute_name = 'FFCL_1') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-27),'YEAR');
		v_FCLThreshold := EC_CONTRACT_ATTRIBUTE.attribute_number(ecdp_objects.getobjidfromcode('CONTRACT','C_WST_LNG'), 'FCL_LIMIT',v_year, '<=' );

	--tlxt:08-Oct-2014: Claculat FFCL to be used in Reference Entitlement
	--FFCL is the different betweeen Ref Ent and Cargo Request for a given lifting year.
	--the Reference Production used for both must be the same.
	--The key that ties this 2 together is the FORECAST_OBJECT_ID
	--The design is taking the last approved ADP per lifting year.
	--Based on the year parameter, we are able to get the last approved ADP. From there we are able to get the Forecast Object ID in order to get the REF_PROD
		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
		END LOOP;

		IF (v_target_forecast IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT sum(nom_grs_vol) INTO v_total_scheduled_ly
			FROM dv_fcst_stor_lift_nom
			WHERE forecast_id = v_target_forecast
			AND lifting_account_id = p_object_ec_code
			AND object_id = EC_STORAGE.object_id_by_uk('STW_LNG');
		END IF;

		--v_yearly_entitlement_ly := EC_CT_REFERENCE_ENTITLEMENT.REF_ENT_VOL_YR(p_object_ec_code, v_year, 'CT_LA_YR_PC_REF_ENT',v_target_forecast_object_id);
		v_yearly_entitlement_ly := 0;

		FOR item IN validRefEnt(v_year, NULL,p_object_ec_code) LOOP
			v_yearly_entitlement_ly := item.REF_ENT_VOL;
		END LOOP;

		IF (v_yearly_entitlement_ly IS NULL)  THEN
			lv_return := 0;
		ELSE
			v_adjustment := (v_yearly_entitlement_ly - v_total_scheduled_ly);
			IF (v_adjustment < -v_FCLThreshold) THEN
				lv_return := -v_FCLThreshold;
			ELSIF (v_adjustment > v_FCLThreshold) THEN
				lv_return := v_FCLThreshold;
			ELSE
			   lv_return := v_adjustment;
			END IF;

		END IF;
	END IF;

	IF(  p_attribute_name = 'AFCL') THEN
		-- AFCL = last approved Yearly REF_ENT - Actual Lifted + Adjustment from the FTL
		-- by doing this, we don't have to cater the FTL adjustmnet in the Calc rules.
		v_year := TRUNC(ADD_MONTHS(p_daytime,-27),'YEAR');
		--v_FCLThreshold := EC_CONTRACT_ATTRIBUTE.attribute_number(ecdp_objects.getobjidfromcode('CONTRACT','C_WST_LNG'), 'FCL_LIMIT',v_year, '<=' );

		--GET loaded and lifted qty
		--eventhough the actual date to be used in BL_DATE, but in this context, we wouldnt be able to pickup the lifting in the next LY because if the BL_DATE falls off the current Lifting Year.
		-- eg: NOM_DATE = 30-Mar, then load completed on 01-Apr and BL_DATE on 02-Apr.
		-- This typical example showing the possibility of the query didnt pickup the loaded qty  for the LY
		-- This query is meant to pickup the SUM of lifted qty, hence as long as it is belong to current LY, it should be pickup
		SELECT SUM(sl.load_value) INTO v_loaded
			  FROM dv_storage_lift_nom_info slni
		INNER JOIN dv_storage_lifting sl  ON sl.parcel_no = slni.parcel_no
			 WHERE TRUNC(ADD_MONTHS(slni.NOM_DATE,-3),'YEAR') = v_year
			 AND slni.LIFTING_ACCOUNT_ID = p_object_ec_code
			 AND slni.object_id = EC_STORAGE.object_id_by_uk('STW_LNG')
			 AND ec_product_meas_setup.item_code(product_meas_no) IN ('LIFT_NET_M3')
			 AND NVL(EC_STORAGE_LIFT_NOMINATION.TEXT_13(sl.parcel_no),'N') <> 'Y';


		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
			v_target_forecast_created_date := item.ADP_CREATED_DATE;
		END LOOP;

		v_yearly_entitlement_ly := 0;

		FOR item IN validRefEnt(v_year, v_target_forecast_created_date,p_object_ec_code) LOOP
			v_yearly_entitlement_ly := item.REF_ENT_VOL;
		END LOOP;

		--IF NO PREVIOUS APPROVED REF_ENF FOUND, SET RESULT BACK TO ZERO. THIS IS TO ENSURE USER IS AWARE OF THE PROBLEM
		IF v_yearly_entitlement_ly = 0 OR v_loaded = 0 THEN
			v_yearly_entitlement_ly := 0;
			v_loaded := 0;
		END IF;

		--To cater FTL which be inserted into Single Adjustmen BF.
		--if a negative value entered, it means adjut out
		--if a positive value entered, it means adjut in
		v_FCL_adj := nvl(getAttributeNumber(p_contract_id,'FCL_ADJ' ,v_year,p_object_ec_code),0);

		lv_return := ( v_yearly_entitlement_ly - v_loaded + v_FCL_adj);

	END IF;

	IF(  p_attribute_name = 'NOM_PNC_EVENTS') THEN
		--This map to PNC requested Event
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
			v_target_forecast_created_date := item.ADP_CREATED_DATE;
		END LOOP;

		v_total_pnc_events := 0;

		IF (v_target_forecast IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT SUM(EVENTS) INTO v_total_pnc_events FROM
			(
				SELECT A.CARGO_NO,(NULLIF(A.PURGE_COOL_QTY,0)/SUM_OF_COOL_QTY)EVENTS FROM DV_FCST_STOR_LIFT_NOM A,
				(
					SELECT SUM(NVL(PURGE_COOL_QTY,0))SUM_OF_COOL_QTY,CARGO_NO FROM DV_FCST_STOR_LIFT_NOM
					WHERE forecast_id= v_target_forecast
					--AND LIFTING_ACCOUNT_CODE = 'LA_CAPL_LNG'
					AND PURGE_COOL_IND = 'Y'
					AND COMBINE_IND = 'Y'
					GROUP BY CARGO_NO
					)CARGOES
				WHERE A.CARGO_NO =CARGOES.CARGO_NO
				AND A.lifting_account_id = p_object_ec_code
				AND (NULLIF(A.PURGE_COOL_QTY,0)/SUM_OF_COOL_QTY) IS NOT NULL
				AND A.forecast_id= v_target_forecast
				UNION ALL
				SELECT CARGO_NO,COUNT(*)EVENTS FROM DV_FCST_STOR_LIFT_NOM
				WHERE lifting_account_id = p_object_ec_code
				AND forecast_id= v_target_forecast
				AND PURGE_COOL_IND = 'Y'
				AND COMBINE_IND = 'N'
				GROUP BY CARGO_NO
			);
			lv_return := ROUND(NVL(v_total_pnc_events,0),3);
		END IF;
	END IF;

	IF(  p_attribute_name = 'FCL_ADJ') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		--only take Vol
		SELECT SUM(ADJ_QTY3) INTO v_FCL_adj
		FROM DV_LIFT_ACCOUNT_ADJ_SINGLE
		WHERE TRUNC(ADD_MONTHS(DAYTIME,-3),'YEAR') = v_year
		--AND ADJ_REASON = 'FAIL_TO_LIFT'
		AND OBJECT_ID = p_object_ec_code;

		v_FCL_adj := NVL(v_FCL_adj,0) ;
		lv_return := ROUND(v_FCL_adj,3);
	END IF;

	IF(  p_attribute_name = 'TRADE_PNC') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');

		SELECT SUM(ADJ_QTY3) *-1 INTO v_adj_out
		FROM DV_LIFT_ACCOUNT_ADJUSTMENT
		WHERE TRUNC(ADD_MONTHS(DAYTIME,-3),'YEAR') = v_year
		AND OBJECT_ID = p_object_ec_code;

		SELECT SUM(ADJ_QTY3) INTO v_adj_in
		FROM DV_LIFT_ACCOUNT_ADJUSTMENT
		WHERE TRUNC(ADD_MONTHS(DAYTIME,-3),'YEAR') = v_year
		AND to_lifting_account_id = p_object_ec_code;

		v_pnc_adj := NVL(v_adj_in,0) + NVL(v_adj_out,0);
		lv_return := ROUND(v_pnc_adj,3);
	END IF;

	IF(  p_attribute_name = 'TRADE_IN_PNC') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		SELECT SUM(ADJ_QTY3) INTO v_adj_in
		FROM DV_LIFT_ACCOUNT_ADJUSTMENT
		WHERE TRUNC(ADD_MONTHS(DAYTIME,-3),'YEAR') = v_year
		AND to_lifting_account_id = p_object_ec_code;

		v_pnc_adj := NVL(v_adj_in,0) ;
		lv_return := ROUND(v_pnc_adj,3);
	END IF;
	IF(  p_attribute_name = 'TRADE_OUT_PNC') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		SELECT SUM(ADJ_QTY3) *-1 INTO v_adj_out
		FROM DV_LIFT_ACCOUNT_ADJUSTMENT
		WHERE TRUNC(ADD_MONTHS(DAYTIME,-3),'YEAR') = v_year
		AND OBJECT_ID = p_object_ec_code;

		v_pnc_adj :=  NVL(v_adj_out,0);
		lv_return := ROUND(v_pnc_adj,3);
	END IF;

	IF(  p_attribute_name = 'REF_PNC_EVENTS') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
			v_target_forecast_created_date := item.ADP_CREATED_DATE;
		END LOOP;

		v_yearly_lifer_pnc := 0;

		IF (v_target_forecast IS NULL) THEN
            -- NO APPROVED ADP FOUND, NEED TO BASED ON THE YR TO GET THE LATEST APPROVED REF_ENT
            FOR item IN validRefEnt(v_year, v_year,p_object_ec_code) LOOP
                v_yearly_lifer_pnc := item.PNC_ALLOWENCE;
            END LOOP;
            lv_return := NVL(v_yearly_lifer_pnc,0);
			--RETURN 0;
		ELSE
			FOR item IN validRefEnt(v_year, v_target_forecast_created_date,p_object_ec_code,'Y') LOOP
				v_yearly_lifer_pnc := item.PNC_ALLOWENCE;
			END LOOP;
			lv_return := NVL(v_yearly_lifer_pnc,0);
		END IF;
	END IF;

	IF(  p_attribute_name = 'PNC_CARRY_OVER') THEN
		v_year := TRUNC(ADD_MONTHS(p_daytime,-15),'YEAR');
		FOR item IN validForecasts(v_year) LOOP
			v_target_forecast := item.object_id;
			v_target_forecast_object_id := item.FORECAST_OBJECT_ID;
			v_target_forecast_created_date := item.ADP_CREATED_DATE;
		END LOOP;

		v_yearly_lifer_pnc := 0;

		IF (v_target_forecast IS NULL) THEN
            -- NO APPROVED ADP FOUND, NEED TO BASED ON THE YR TO GET THE LATEST APPROVED REF_ENT
            FOR item IN validRefEnt(v_year, v_year,p_object_ec_code) LOOP
                v_yearly_lifer_pnc := item.PNC_CARRY_OVER;
            END LOOP;
            lv_return := NVL(v_yearly_lifer_pnc,0);
            --RETURN 0;
		ELSE
			FOR item IN validRefEnt(v_year, NULL,p_object_ec_code,'Y') LOOP
				v_yearly_lifer_pnc := item.PNC_CARRY_OVER;
			END LOOP;
			lv_return := NVL(v_yearly_lifer_pnc,0);
		END IF;
	END IF;

	IF(  p_attribute_name = 'PNC_ADJ_BALANCE') THEN
		--For Monthly Adjustment
		--REF_PNC_EVENTS(LY) + CO(which is PNC_CARRY_OVER LY) + TRADE_OUT_PNC
		--Monthly adjustment doesn't requred the Nom_PNC_EVENTS because at that time we may not have any scenario yet
		lv_return :=  ROUND((	getAttributeNumber(p_contract_id,'PNC_CARRY_OVER' ,ADD_MONTHS(TRUNC(p_daytime,'YEAR'), 15),p_object_ec_code) +
								getAttributeNumber(p_contract_id,'REF_PNC_EVENTS' ,ADD_MONTHS(TRUNC(p_daytime,'YEAR'), 15),p_object_ec_code) +
								--getAttributeNumber(p_contract_id,'FCL_ADJ' ,ADD_MONTHS(TRUNC(p_daytime,'YEAR'), 15),p_object_ec_code) +
								getAttributeNumber(p_contract_id,'TRADE_OUT_PNC' ,ADD_MONTHS(TRUNC(p_daytime,'YEAR'), 15),p_object_ec_code)
								)
							,3);
	END IF;

	IF(  p_attribute_name = 'PNC_BALANCE') THEN
	--This map to PNC Remaining Event in Excel Model
	-- RETURN PNC BALANCE by getting last approved ADP agaisnt REF ent PNC per lifter and ADP PNC Qty per lifter
	-- This call returns the Balance from previous LY, which forms the value to be used as CO for this LY
	-- R = (X + Y + Z) - L
	-- R = Remaining
	-- X = PnA Allowance -->REF_PNC_EVENTS
	-- Y = CO -->PNC_CARRY_OVER
	-- Z = PnC Trade -->TRADE_PNC
	-- L = Requested PnC -->NOM_PNC_EVENTS
		lv_return :=  ROUND(
		(
		getAttributeNumber(p_contract_id,'REF_PNC_EVENTS' ,p_daytime,p_object_ec_code)
		+ getAttributeNumber(p_contract_id,'PNC_CARRY_OVER' ,p_daytime,p_object_ec_code)
		+ getAttributeNumber(p_contract_id,'TRADE_PNC' ,p_daytime,p_object_ec_code)
		--+ getAttributeNumber(p_contract_id,'FCL_ADJ' ,p_daytime,p_object_ec_code)
		- getAttributeNumber(p_contract_id,'NOM_PNC_EVENTS' ,p_daytime,p_object_ec_code)
		)
		,3);

	END IF;

	IF(  p_attribute_name = 'WHOLE_ALLOW') THEN
	--This map to PNC whole Allowance, used in Reference Entitlement calculation
	-- R = (X + Y + Z) + ADJ
	-- R = Remaining
	-- X = PnA Allowance -->REF_PNC_EVENTS
	-- Y = CO -->PNC_CARRY_OVER
	-- Z = PnC Trade -->TRADE_PNC
	-- ADJ = FCL adjustment --> FCL_ADJ
		lv_return :=  ROUND(
		(
		getAttributeNumber(p_contract_id,'REF_PNC_EVENTS' ,p_daytime,p_object_ec_code)
		+ getAttributeNumber(p_contract_id,'PNC_CARRY_OVER' ,p_daytime,p_object_ec_code)
		+ getAttributeNumber(p_contract_id,'TRADE_PNC' ,p_daytime,p_object_ec_code)
		--+ getAttributeNumber(p_contract_id,'FCL_ADJ' ,p_daytime,p_object_ec_code)
		)
		,3);

	END IF;
	RETURN NVL(lv_return,0);


	
END getAttributeNumber;

END ue_cntr_attr_dimension;
/
