create or replace PACKAGE BODY ue_Forecast_Cargo_Planning IS
/****************************************************************
** Package        :  ue_Forecast_Cargo_Planning; body part
**
** $Revision: 1.2 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  		Change description:
** ----------  	----- 		-------------------------------------------
** 18/11/2013	muhammah	ECPD-25921: add procedure deleteForecastCascade
** 15/01/2016   sharawan  	ECPD-33109: added parameter for copyFromOriginal and copyFromForecast used in Forecast Manager screen
** 27/09/2016   asareswi    ECPD-39168: Added procedure PopulateStorage to pouplate PROD stream data into TRAN table
** 14/12/2016   thotesan    ECPD-41647: Modified procedure deleteForecastFM to remove Forecast and opportunity linking.
** 07/04/2017   sharawan    ECPD-44803: Modified deleteForecastFM to delete child records query in FCST_STOR_LIFT_CPY_SPLIT
** 15/08/2017   sharawan    ECPD-47293: Added procedure validateDate to validate End Date when creating Forecast in Forecast Manager screen.
** 17/08/2017   sharawan    ECPD-47293: Modified copyFromForecastFcstMngr to get the reference forecast end_date if the End Date field is empty.
** 22-Jan-2018	prtu changes made in ValidateForecastByType (line number 27) , condition changes to ensure scenario accept the current data as start date.
** 15/11/2018   thotesan    ECPD-59863: Added function includeInCopy to get cargo status for Copy to orgional plan.

********************************************************************/
PROCEDURE ValidateForecastByType(p_start_date DATE, p_end_date DATE, p_fcast_tran_cp_Type VARCHAR2 DEFAULT NULL)
IS
BEGIN

--TLXT: 25-NOV-2015:
--A flag to facilitate creation of scenarios prior to system date for testing purposes. there u go
	IF NVL(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(p_start_date,'ENABLE_CP_SCEN_DATE_VAL','<='),'Y') = 'Y' THEN
        -- Item 126288 Begin
		--IF (p_start_date <= trunc(ecdp_date_time.getcurrentsysdate, 'DD')) THEN
		IF (p_start_date < trunc(ecdp_date_time.getcurrentsysdate, 'DD')) THEN
        -- Item 126288 End
			RAISE_APPLICATION_ERROR(-20767, 'Scenarios cannot be created or published if their start date is before the current system date.');
		END IF;
	END IF;

    IF p_fcast_tran_cp_Type = 'PADP' OR p_fcast_tran_cp_Type = 'ADP' THEN
        IF TO_CHAR(p_start_date, 'MON') <> 'APR' OR TO_CHAR(p_start_date, 'DD') <> '01' OR TO_CHAR(p_end_date, 'MON') <> 'APR' OR TO_CHAR(p_end_date, 'DD') <> '01' OR EXTRACT(YEAR FROM p_end_date) - EXTRACT(YEAR FROM p_start_date) <> 1 THEN
            RAISE_APPLICATION_ERROR(-20750, 'PADP/ADP scenarios must span exactly one lifting year (01-APR through 01-APR)');
        END IF;
    END IF;

    IF p_fcast_tran_cp_Type = 'SDS' THEN
        IF p_end_date - p_start_date < 90 THEN
            RAISE_APPLICATION_ERROR(-20751, 'SDS scenarios must span a valid SDS period (90 days)');
        END IF;
    END IF;
	--22/09/2014 LBFK: Commenting until the use of an Extending SDS is confirmed with the business
    /*IF p_fcast_tran_cp_Type = 'EX_SDS' THEN
        IF TO_CHAR(p_end_date, 'MON') <> 'APR' OR TO_CHAR(p_end_date, 'DD') <> '01' THEN
            RAISE_APPLICATION_ERROR(-20775, 'Extended Delivery Schedule scenarios must end at the end of the lifting year.');
        END IF;
    END IF;*/
END ValidateForecastByType;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFromOriginal
-- Description    :
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
PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_fcast_tran_cp_Type VARCHAR2 DEFAULT NULL, p_forecast_name VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS
    v_fcast_Tran_cp_type VARCHAR2(32) := NVL(p_fcast_tran_cp_type, 'AD_HOC');
BEGIN

    -- Check type and make sure the dates make sense
    ValidateForecastByType(p_start_date, p_end_date, v_fcast_Tran_cp_type);

    UE_CT_FCAST_CARGO_PLANNING.copyFromOriginal(p_new_forecast_code, p_start_date, p_end_date, p_storage_id, p_copy_forecast);


    UPDATE ov_forecast_tran_cp
    SET scenario_type = v_fcast_Tran_cp_type,
           name = nvl(p_forecast_name, p_new_forecast_code)
    WHERE code = p_new_forecast_code;

END copyFromOriginal;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFromForecast
-- Description    :
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
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_fcast_tran_cp_Type VARCHAR2 DEFAULT NULL, p_forecast_name VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS
	--TEXT_6 = SCENARIO_TYPE
	--TEXT_8 = PROD_FCST_SCENARIO
	--TEXT_9 = PROD_FCST_TYPE
	--TEXT_10 = FCST_STOR_FCAST_SRC

    v_fcast_Tran_cp_type VARCHAR2(32) := COALESCE(p_fcast_tran_cp_type, ec_forecast_version.text_6(p_forecast_id, sysdate, '<='),ec_forecast_version.text_6(p_forecast_id, sysdate, '>='));
    v_PROD_FCST_SCENARIO VARCHAR2(32) := COALESCE(p_fcast_tran_cp_type, ec_forecast_version.text_8(p_forecast_id, sysdate, '<='),ec_forecast_version.text_8(p_forecast_id, sysdate, '>='));

BEGIN

    -- Check type and make sure the dates make sense
    ValidateForecastByType(p_start_date, p_end_date, v_fcast_Tran_cp_type);

    UE_CT_FCAST_CARGO_PLANNING.copyFromForecast(p_forecast_id, p_new_forecast_code, p_start_date, p_end_date, p_storage_id, p_copy_forecast);

    UPDATE ov_forecast_tran_cp
    SET scenario_type = v_fcast_Tran_cp_type,
           name = nvl(p_forecast_name, p_new_forecast_code),
           FCAST_OPENING_LEVEL = ec_forecast_version.text_7(p_forecast_id, p_start_date, '<='),
           FCST_STOR_FCAST_SRC = 'PROD_PLAN_FCAST',
           PROD_FCST_SCENARIO = DECODE(v_fcast_tran_cp_type,'ADP','REF_PROD','PADP','REF_PROD','R_ADP','REF_PROD',v_PROD_FCST_SCENARIO),
		   FORECAST_OBJECT_ID = ec_forecast_version.ref_object_id_1(p_forecast_id, p_start_date, '<='),
		   PROD_FCST_TYPE = DECODE(v_fcast_tran_cp_type, 'PADP','ADP_PLAN','ADP','ADP_PLAN','SDS','SDS_PLAN','EX_SDS','SDS_PLAN','PLP','SDS_PLAN','ADP_PLAN')
    WHERE code = p_new_forecast_code;

    --select * from forecast_version

END copyFromForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyToOriginal
-- Description    :
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
PROCEDURE copyToOriginal(p_forecast_id VARCHAR2, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS

BEGIN
    UE_CT_FCAST_CARGO_PLANNING.copyToOriginal(p_forecast_id, p_copy_forecast);

END copyToOriginal;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : generatePCYield
-- Description    :
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
PROCEDURE generatePCYield(p_fromdate DATE, p_todate DATE, p_object_id VARCHAR2, p_fcast_id VARCHAR2)
    --</EC-DOC>

    IS

    BEGIN

null;

    END generatePCYield;

---------------------------------------------------------------------------------------------------
-- Procedure      : deleteForecastCascade
-- Description    :
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
PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE)
--</EC-DOC>

IS

BEGIN

     NULL;

END deleteForecastCascade;

PROCEDURE copyFromOriginalFcstMngr(p_new_forecast_code VARCHAR2,
                                     p_start_date        DATE,
                                     p_end_date          DATE,
                                     p_storage_id        VARCHAR2 DEFAULT NULL)
  --</EC-DOC>
   IS
    lv_code            VARCHAR2(32);
    lv_end_date        DATE;
    ln_seq_no          NUMBER;
    lv_new_forecast_id VARCHAR2(32);


  BEGIN
    IF p_end_date IS NULL THEN
      IF p_new_forecast_code = 'LTF' THEN
        lv_end_date := add_months(p_start_date, 12);
      ELSIF p_new_forecast_code = 'MTF' THEN
        lv_end_date := add_months(p_start_date, 3);
      ELSIF p_new_forecast_code = 'STF' THEN
        lv_end_date := add_months(p_start_date, 1);
      END IF;
    ELSE
      lv_end_date := p_end_date;
    END IF;

    EcDp_System_Key.assignNextNumber(p_new_forecast_code,
                                     ln_seq_no);
    lv_code := p_new_forecast_code || '_' || ln_seq_no;

    EcBp_Forecast_Cargo_Planning.copyFromOriginal(lv_code,
                                                  p_start_date,
                                                  lv_end_date,
                                                  p_storage_id);
    lv_new_forecast_id := ec_forecast.object_id_by_uk('FORECAST_TRAN_CP',
                                                      lv_code);

    UPDATE OV_FORECAST_TRAN_CP
       SET PERIOD_TYPE     = p_new_forecast_code,
           FORECAST_STATUS = 'NEW',
           FORECAST_TYPE   = 'DRAFT'
     WHERE CODE = lv_code;

  END copyFromOriginalFcstMngr;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : copyFromForecastFcstMngr
  -- Description    :
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
  PROCEDURE copyFromForecastFcstMngr(p_forecast_id       VARCHAR2,
                                     p_new_forecast_code VARCHAR2,
                                     p_start_date        DATE,
                                     p_end_date          DATE,
                                     p_storage_id        VARCHAR2 DEFAULT NULL)
  --</EC-DOC>
   IS
    lv_code   VARCHAR2(32);
    ln_seq_no NUMBER;
    ld_end_date DATE;

  BEGIN
    EcDp_System_Key.assignNextNumber(p_new_forecast_code,
                                     ln_seq_no);
    lv_code := p_new_forecast_code || '_' || ln_seq_no;

    --Get the reference forecast end_date if the End Date field is empty
    IF p_end_date IS NULL THEN
       ld_end_date := ec_forecast_version.end_date(p_forecast_id, p_start_date, '<=');
    ELSE
       ld_end_date := p_end_date;
    END IF;

    EcBp_Forecast_Cargo_Planning.copyFromForecast(p_forecast_id,
                                                  lv_code,
                                                  p_start_date,
                                                  ld_end_date,
                                                  p_storage_id);

    UPDATE OV_FORECAST_TRAN_CP
       SET PERIOD_TYPE     = p_new_forecast_code,
           FORECAST_STATUS = 'NEW',
           FORECAST_TYPE   = 'DRAFT'
     WHERE CODE = lv_code;

  END copyFromForecastFcstMngr;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : copyToOriginalFcstMngr
  -- Description    :
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
  PROCEDURE copyToOriginalFcstMngr(p_forecast_id VARCHAR2)
  --</EC-DOC>
   IS

  BEGIN
    EcBp_Forecast_Cargo_Planning.copyToOriginal(p_forecast_id);

    UPDATE cargo_transport
       SET cargo_status = 'O'
     WHERE cargo_status = 'T'
       AND cargo_no IN (SELECT cargo_no
                          FROM stor_fcst_lift_nom
                         WHERE forecast_id = p_forecast_id);

    UPDATE OV_FORECAST_TRAN_CP
       SET FORECAST_STATUS = 'APPLIED'
     WHERE object_id = p_forecast_id;

  END copyToOriginalFcstMngr;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteForecastFM
-- Description    :
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
PROCEDURE deleteForecastFM(p_forecast_id VARCHAR2)
--</EC-DOC>

IS

BEGIN

  DELETE stor_day_fcst_pc_fcast WHERE forecast_id = p_forecast_id;
  DELETE stor_mth_fcst_pc_fcast WHERE forecast_id = p_forecast_id;

  DELETE stor_day_fcst_fcast WHERE forecast_id = p_forecast_id;
  DELETE stor_sub_day_fcst_fcast WHERE forecast_id = p_forecast_id;

  DELETE lift_acc_day_fcst_fcast WHERE forecast_id = p_forecast_id;
  DELETE lift_acc_sub_day_fcst_fc WHERE forecast_id = p_forecast_id;

  DELETE FCST_STOR_LIFT_CPY_SPLIT where forecast_id = p_forecast_id;
  DELETE stor_fcst_sub_day_lift_nom WHERE forecast_id = p_forecast_id;
  DELETE stor_fcst_lift_nom WHERE forecast_id = p_forecast_id;
  DELETE cargo_fcst_transport WHERE forecast_id = p_forecast_id;

  DELETE fcst_lift_acc_init_bal WHERE forecast_id = p_forecast_id;
  DELETE fcst_lift_acc_adj WHERE forecast_id = p_forecast_id;
  DELETE fcst_lift_acc_adj_single WHERE forecast_id = p_forecast_id;

  DELETE FCST_OPLOC_DAY_RESTRICT where forecast_id = p_forecast_id;
  DELETE FCST_OPLOC_PERIOD_RESTR where forecast_id = p_forecast_id;
  DELETE FCST_RECOVERY_FACTOR where forecast_id = p_forecast_id;

  DELETE FCST_TRAIN_INLET_GAS where forecast_id = p_forecast_id;
  DELETE FCST_TRAIN_STORAGE_YIELD where forecast_id = p_forecast_id;
  DELETE FCST_OBJ_EVT_DIM1_CP_FAC where forecast_id = p_forecast_id;

  DELETE LIFT_ACC_DAY_FCST_FCAST where forecast_id = p_forecast_id;
  DELETE LIFT_ACC_SUB_DAY_FCST_FC where forecast_id = p_forecast_id;
  UPDATE OPPORTUNITY SET FORECAST_ID = NULL WHERE FORECAST_ID = p_forecast_id;
  UPDATE OPPORTUNITY_GEN_TERM SET FORECAST_ID = NULL , CARGO_NO = NULL WHERE FORECAST_ID = p_forecast_id;

  UPDATE OV_FORECAST_TRAN_CP SET OBJECT_END_DATE=OBJECT_START_DATE where OBJECT_ID = p_forecast_id;

END deleteForecastFM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : PopulateStorage
-- Description    :
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
PROCEDURE PopulateStorage( p_tran_forecast_id VARCHAR2
                           , p_prod_forecast_id VARCHAR2
                           , p_prod_fcst_scenario_id VARCHAR2
                           , p_daytime DATE
                           , p_storage_id VARCHAR2
                           , p_stream_id VARCHAR2)
--</EC-DOC>
IS

BEGIN

	IF (p_tran_forecast_id IS NULL OR p_prod_forecast_id  IS NULL ) THEN
		Raise_Application_Error(-20000,'Missing forecast id');
	END IF;

	MERGE INTO stor_day_fcst_fcast o
	USING ( select d.object_id, d.daytime, d.gas_rate,
				 d.value_1, d.value_2, d.value_3, d.value_4, d.value_5, d.value_6, d.value_7, d.value_8, d.value_9, d.value_10,
				 d.text_1, d.text_2, d.text_3, d.text_4, d.created_by
			from FCST_STREAM_DAY d
		   where d.object_id = p_stream_id
			 and d.forecast_id = p_prod_forecast_id
			 and d.scenario_id = p_prod_fcst_scenario_id
			 and daytime >= ( select daytime from forecast_version where object_id = p_tran_forecast_id and p_daytime >= daytime
							 and p_daytime < nvl(end_date, p_daytime + 1))
			 and daytime < nvl(ec_forecast_version.end_date( p_tran_forecast_id, p_daytime,'<='), p_daytime + 1) ) f
	on (o.object_id = p_storage_id and o.forecast_id = p_tran_forecast_id and o.daytime = f.daytime )
	WHEN MATCHED THEN
	  UPDATE SET o.forecast_qty  = f.gas_rate, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
	  INSERT (o.object_id, o.daytime,o.forecast_id, o.forecast_qty,
		  o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
		  o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (p_storage_id, f.daytime, p_tran_forecast_id, f.gas_rate, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
		  f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

END PopulateStorage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateDate
-- Description    : Validate End Date when creating Forecast in Forecast Manager screen
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
PROCEDURE validateDate(p_from_date DATE, p_to_date DATE)
--</EC-DOC>
IS

BEGIN
	IF (p_from_date >= p_to_date) THEN
		Raise_Application_Error(-20587,'End Date should be later than Date in navigator.');
	END IF;
END validateDate;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : includeInCopy
-- Description    : Function to return Y for the cargo status mentioned in lv_cargo_status variable
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
FUNCTION includeInCopy(p_forecast_id VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER,p_cargo_status VARCHAR2,p_fcst_cargo_status VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
 lv_cargo_status VARCHAR2(32):= 'T,O';
BEGIN
  IF INSTR(lv_cargo_status,p_fcst_cargo_status,1)>=1 AND INSTR(lv_cargo_status,NVL(p_cargo_status,lv_cargo_status),1)>=1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

  END includeInCopy;

END ue_Forecast_Cargo_Planning;
/