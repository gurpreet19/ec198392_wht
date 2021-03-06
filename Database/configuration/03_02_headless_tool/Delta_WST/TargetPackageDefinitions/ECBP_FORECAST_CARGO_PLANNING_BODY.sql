CREATE OR REPLACE PACKAGE BODY EcBp_Forecast_Cargo_Planning IS
/****************************************************************
** Package        :  EcBp_Forecast_Cargo_Planning; body part
**
** $Revision: 1.16.4.12 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  			Change description:
** 13/5/2010   Kenneth Masamba  Add Qty2 column and nom_firm_date_time column when copying to storage_lift_nomination
** 31/5/2010   lauuufus		    ECPD-14514 Modify deleteForecastCascade to include stor_sub_day_fcst_fcast
** 13/10/2010  madondin		    ECPD-15595 Updated package EcBp_Forecast_Cargo_Planning to include the production day when copying for sub daily records.
** 23/11/2011  farhaann		    ECPD-18501 Modified copyToOriginal. Delete nomination direct from table instead of calling EcBp_Storage_Lift_Nomination.bdStorageLiftNomination
** 12.09.2011  meisihil         ECPD-20962: Included balance delta columns
** 26/12/2012  chooysie         ECPD-22957 Includes Initialize Lifting Account and Lifting Account Adjustments when copy from original, copy from forecast, copy to original and delete forecast.
** 24.01.2013  meisihil         ECPD-20962: Included Sub daily lifting nomination table when copy from original, copy from forecast, copy to original and delete forecast.
** 31/01/2013  chooysie         ECPD-22957 Initialize Lifting Account and Lifting Account Adjustments should join to lifting account
** 01/03/2013  hassakha         ECPD-23124 Includes Carrier Acailability when copy from original, copy from forecast, copy to original
** 08/03/2013  chooysie         ECPD-23418 Include summer_time and production_day when perform copy for Lifting Account Adjustments
** 17/05/2013  chooysie		   	ECPD-24142 Includes Forecast Recovery Factor when copy from original, copy from forecast, copy to original and deleteForecastCascade
** 19/11/2013  muhammah			ECPD-26093 update procedure deleteForecastCascade to call ue function
** 12/03/2014  chooysie  		ECPD-27051: Include Forecast Period Process Train Storage Yield when copy from original, copy from forecast, copy to original and deleteForecastCascade
********************************************************************/

PROCEDURE createForecast(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_new_forecast_id OUT VARCHAR2)
IS

BEGIN
	p_new_forecast_id:= EcDp_objects.GetInsertedObjectID(p_new_forecast_id);

	INSERT INTO FORECAST(object_id,CLASS_NAME,OBJECT_CODE,START_DATE,END_DATE, STORAGE_ID, created_by)
    VALUES(p_new_forecast_id,'FORECAST_TRAN_CP',p_new_forecast_code,p_start_date,p_end_date,p_storage_id,ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by)
    VALUES(p_new_forecast_id, p_start_date, p_end_date, p_new_forecast_code, ecdp_context.getAppUser);

END createForecast;


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
PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
	p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
	createForecast(p_new_forecast_code, p_start_date, p_end_date, p_storage_id, p_new_forecast_id);

	-- copy storage forecast tables

	INSERT INTO stor_day_fcst_fcast a (a.forecast_id, a.object_id, a.daytime, a.forecast_qty, a.official_ind,
       a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
       a.text_1, a.text_2, a.text_3, a.text_4,
       created_by, a.forecast_qty2, a.forecast_qty3)
    SELECT p_new_forecast_id, f.object_id, f.daytime, nvl(o.official_qty, f.forecast_qty) forecast_qty, decode(o.official_qty, NULL, NULL, 'Y') official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser, f.forecast_qty2, f.forecast_qty3
	FROM stor_day_forecast f,
	     stor_day_official o
	WHERE o.object_id (+)= f.object_id
		AND o.object_id (+)= f.object_id
	    AND o.daytime (+)= f.daytime
	    AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	INSERT INTO stor_sub_day_fcst_fcast a (a.forecast_id, a.object_id, a.daytime, a.forecast_qty, a.forecast_qty2, a.forecast_qty3, a.production_day, a.summer_time,
       a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
       a.text_1, a.text_2, a.text_3, a.text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, nvl(o.official_qty, f.forecast_qty) forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM stor_sub_day_forecast f,
	     stor_day_official o
	WHERE o.object_id (+)= f.object_id
	    AND o.object_id (+)= f.object_id
	    AND o.daytime (+)= f.daytime
   	    AND f.production_day >= p_start_date
	    AND f.production_day < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	INSERT INTO stor_mth_fcst_pc_fcast (forecast_id, OBJECT_ID, PROFIT_CENTRE_ID, DAYTIME, forecast_qty,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
	SELECT p_new_forecast_id, F.OBJECT_ID, F.PROFIT_CENTRE_ID, F.DAYTIME, F.GRS_VOL,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM STOR_MTH_PC_FORECAST F
	WHERE f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	INSERT INTO stor_day_fcst_pc_fcast (forecast_id, OBJECT_ID, PROFIT_CENTRE_ID, DAYTIME, forecast_qty,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
	SELECT p_new_forecast_id, F.OBJECT_ID, F.PROFIT_CENTRE_ID, F.DAYTIME, F.GRS_VOL,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM STOR_DAY_PC_FORECAST F
	WHERE f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	-- copy lift acc forecast

	INSERT INTO lift_acc_day_fcst_fcast (forecast_id, object_id, daytime, forecast_qty, forecast_qty2, forecast_qty3, official_ind,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, nvl(o.official_qty, f.forecast_qty) forecast_qty, f.forecast_qty2, f.forecast_qty3, decode(o.official_qty, NULL, NULL, 'Y') official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM lift_acc_day_forecast f,
       lift_acc_day_official o,
       lifting_account a
	WHERE o.object_id (+)= f.object_id
		AND o.object_id (+)= f.object_id
	    AND o.daytime (+)= f.daytime
	    AND f.object_id = a.object_id -- could include dates, but there should not be data if not a valid lifting account
	    AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND a.storage_id = nvl(p_storage_id, a.storage_id);


	INSERT INTO lift_acc_sub_day_fcst_fc (forecast_id, object_id, daytime, summer_time, production_day, forecast_qty, forecast_qty2, forecast_qty3, official_ind,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, f.summer_time, f.production_day, nvl(o.official_qty, f.forecast_qty) forecast_qty, f.forecast_qty2, f.forecast_qty3, decode(o.official_qty, NULL, NULL, 'Y') official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM lift_acc_sub_day_forecast f,
       lift_acc_day_official o,
       lifting_account a
	WHERE o.object_id (+)= f.object_id
		AND o.object_id (+)= f.object_id
	    AND o.daytime (+)= f.daytime
	    AND f.object_id = a.object_id -- could include dates, but there should not be data if not a valid lifting account
	    AND f.production_day >= p_start_date
	    AND f.production_day < p_end_date
	    AND a.storage_id = nvl(p_storage_id, a.storage_id);

	-- copy cargo
	INSERT INTO  cargo_fcst_transport(forecast_id,cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
    	created_by)
    SELECT p_new_forecast_id, cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
		ecdp_context.getAppUser
	FROM cargo_transport t
	WHERE cargo_no in (select cargo_no
	FROM  storage_lift_nomination n
	WHERE n.nom_firm_date >= p_start_date
	      AND n.nom_firm_date < p_end_date
	      AND n.object_id = nvl(p_storage_id, n.object_id));

	-- copy nomination midified kenneth 27/01/2009
	INSERT INTO stor_fcst_lift_nom (forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
	    nom_firm_date_time,bl_date_time,start_lifting_date,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,
    	created_by)
	SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
	    nom_firm_date_time,bl_date_time,start_lifting_date,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,
		ecdp_context.getAppUser
	FROM  storage_lift_nomination n
	WHERE n.nom_firm_date >= p_start_date
	      AND n.nom_firm_date < p_end_date
	      AND n.object_id = nvl(p_storage_id, n.object_id);

	INSERT INTO stor_fcst_sub_day_lift_nom (forecast_id,parcel_no,object_id,daytime,summer_time,production_day,grs_vol_requested,grs_vol_nominated,grs_vol_schedule,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,
    	created_by)
	SELECT p_new_forecast_id,parcel_no,object_id,daytime,summer_time,production_day,grs_vol_requested,grs_vol_nominated,grs_vol_schedule,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,
		ecdp_context.getAppUser
	FROM  stor_sub_day_lift_nom ns
	WHERE parcel_no IN (SELECT parcel_no FROM  storage_lift_nomination n
		WHERE n.nom_firm_date >= p_start_date
		      AND n.nom_firm_date < p_end_date
		      AND n.object_id = nvl(p_storage_id, n.object_id));

	-- copy lifting account adjustment
	INSERT INTO fcst_lift_acc_adj (forecast_id, object_id, to_object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, created_by)
	SELECT p_new_forecast_id, n.object_id, to_object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, ecdp_context.getAppUser
	FROM lift_account_adjustment n, lifting_account l
	WHERE n.daytime >= p_start_date
		AND n.daytime < p_end_date
		AND n.object_id = l.object_id
		AND l.storage_id = nvl(p_storage_id, l.storage_id);

	INSERT INTO fcst_lift_acc_adj_single (forecast_id, object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, adj_reason, comments, created_by)
	SELECT p_new_forecast_id, n.object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, adj_reason, comments, ecdp_context.getAppUser
	FROM lift_account_adj_single n, lifting_account l
	WHERE n.daytime >= p_start_date
		AND n.daytime < p_end_date
		AND n.object_id = l.object_id
		AND l.storage_id = nvl(p_storage_id, l.storage_id);

	INSERT INTO FCST_OPLOC_DAY_RESTRICT (forecast_id, object_id, daytime, restricted_capacity, restriction_type, comments, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, restricted_capacity, restriction_type, comments, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM OPLOC_DAILY_RESTRICTION o, carrier c
	WHERE o.daytime >= p_start_date
		AND o.daytime < p_end_date
		AND o.object_id = c.object_id;

	INSERT INTO FCST_RECOVERY_FACTOR (forecast_id, object_id, daytime, component_no, class_name, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, 'FCST_RECOVERY_FACTOR', frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM OBJ_EVENT_CP_TRAN_FACTOR o
	WHERE o.daytime >= p_start_date
		AND o.daytime < p_end_date;

	-- copy period process train storage yield
	INSERT INTO FCST_TRAIN_INLET_GAS (object_id, forecast_id, daytime, end_date, inlet_gas, UOM, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15
	,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,value_11,value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20
	,value_21,value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, date_1, date_2, date_3, date_4, date_5)
	SELECT t.object_id, p_new_forecast_id, t.daytime, t.end_date, t.inlet_gas, t.UOM, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15
	, t.value_1, t.value_2, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19, t.value_20
	, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5
	FROM TRAIN_INLET_GAS t
	WHERE t.daytime >=p_start_date
		AND t.daytime < p_end_date
		AND t.object_id in (SELECT object_id from TRAIN_STORAGE_YIELD where storage_id = nvl(p_storage_id, storage_id));

	INSERT INTO FCST_TRAIN_STORAGE_YIELD (object_id, forecast_id, storage_Id, daytime, yield_factor, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15
	,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,value_11,value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20
	,value_21,value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, date_1, date_2, date_3, date_4, date_5)
	SELECT t.object_id, p_new_forecast_id, t.storage_Id, t.daytime, t.yield_factor, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15
	, t.value_1, t.value_2, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19, t.value_20
	, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5
	FROM TRAIN_STORAGE_YIELD t
	WHERE t.daytime >=p_start_date
		AND t.daytime < p_end_date
		AND t.storage_id = nvl(p_storage_id, t.storage_id);

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
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

	p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
	IF (p_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing copy from forecast id');
	END IF;

	createForecast(p_new_forecast_code, p_start_date, p_end_date, p_storage_id, p_new_forecast_id);

	-- copy storage forecast tables

	INSERT INTO stor_day_fcst_fcast a (a.forecast_id, a.object_id, a.daytime, a.forecast_qty, a.official_ind,
       a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
       a.text_1, a.text_2, a.text_3, a.text_4, created_by, forecast_qty2, forecast_qty3)
    SELECT p_new_forecast_id, f.object_id, f.daytime, f.forecast_qty, f.official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser, forecast_qty2, forecast_qty3
	FROM stor_day_fcst_fcast f
	WHERE f.forecast_id = p_forecast_id
	    AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	INSERT INTO stor_mth_fcst_pc_fcast (forecast_id, OBJECT_ID, PROFIT_CENTRE_ID, DAYTIME, forecast_qty,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
	SELECT p_new_forecast_id, F.OBJECT_ID, F.PROFIT_CENTRE_ID, F.DAYTIME, F.FORECAST_QTY,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM stor_mth_fcst_pc_fcast F
	WHERE f.forecast_id = p_forecast_id
		AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	INSERT INTO stor_day_fcst_pc_fcast (forecast_id, OBJECT_ID, PROFIT_CENTRE_ID, DAYTIME, forecast_qty,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
	SELECT p_new_forecast_id, F.OBJECT_ID, F.PROFIT_CENTRE_ID, F.DAYTIME, F.FORECAST_QTY,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM stor_day_fcst_pc_fcast F
	WHERE f.forecast_id = p_forecast_id
		AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	-- copy lift acc forecast

	INSERT INTO lift_acc_day_fcst_fcast (forecast_id, object_id, daytime, forecast_qty, forecast_qty2, forecast_qty3, official_ind,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM lift_acc_day_fcst_fcast f,
       lifting_account a
	WHERE f.forecast_id = p_forecast_id
	    AND f.object_id = a.object_id -- could include dates, but there should not be data if not a valid lifting account
	    AND f.daytime >= p_start_date
	    AND f.daytime < p_end_date
	    AND a.storage_id = nvl(p_storage_id, a.storage_id);

	--copy subdaily forecast
	INSERT INTO lift_acc_sub_day_fcst_fc (forecast_id, object_id, daytime, summer_time, production_day, forecast_qty, forecast_qty2, forecast_qty3, official_ind,
       value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
       text_1, text_2, text_3, text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, f.summer_time, f.production_day, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM lift_acc_sub_day_fcst_fc f,
       lifting_account a
	WHERE f.forecast_id = p_forecast_id
	    AND f.object_id = a.object_id -- could include dates, but there should not be data if not a valid lifting account
	    AND f.production_day >= p_start_date
	    AND f.production_day < p_end_date
	    AND a.storage_id = nvl(p_storage_id, a.storage_id);


	INSERT INTO stor_sub_day_fcst_fcast a (a.forecast_id, a.object_id, a.daytime, a.forecast_qty, a.forecast_qty2, a.forecast_qty3, a.production_day, a.summer_time, official_ind,
       a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
       a.text_1, a.text_2, a.text_3, a.text_4,
       created_by)
    SELECT p_new_forecast_id, f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time, f.official_ind,
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM stor_sub_day_fcst_fcast f
	WHERE f.forecast_id = p_forecast_id
	    AND f.production_day >= p_start_date
	    AND f.production_day < p_end_date
	    AND f.object_id = nvl(p_storage_id, f.object_id);

	-- copy cargo
	INSERT INTO  cargo_fcst_transport(forecast_id,cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
    	created_by)
    SELECT p_new_forecast_id, cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
		ecdp_context.getAppUser
	FROM cargo_fcst_transport t
	WHERE t.forecast_id = p_forecast_id
		AND cargo_no in (select cargo_no
		FROM  stor_fcst_lift_nom n
		WHERE n.forecast_id = p_forecast_id
	    	  AND n.nom_firm_date >= p_start_date
		      AND n.nom_firm_date < p_end_date
		      AND n.object_id = nvl(p_storage_id, n.object_id));

	-- copy nomination
	INSERT INTO stor_fcst_lift_nom (forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,
    	created_by, nom_firm_date_time, bl_date_time, start_lifting_date, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3)
	SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,
		ecdp_context.getAppUser, nom_firm_date_time, bl_date_time, start_lifting_date, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3
	FROM  stor_fcst_lift_nom n
	WHERE n.forecast_id = p_forecast_id
	    AND n.nom_firm_date >= p_start_date
	    AND n.nom_firm_date < p_end_date
	    AND n.object_id = nvl(p_storage_id, n.object_id);

	INSERT INTO stor_fcst_sub_day_lift_nom (forecast_id,parcel_no,object_id,daytime,summer_time,production_day,grs_vol_requested,grs_vol_nominated,grs_vol_schedule,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,
    	created_by)
	SELECT p_new_forecast_id,parcel_no,object_id,daytime,summer_time,production_day,grs_vol_requested,grs_vol_nominated,grs_vol_schedule,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,
		ecdp_context.getAppUser
	FROM  stor_fcst_sub_day_lift_nom ns
	WHERE ns.forecast_id = p_forecast_id
	  AND parcel_no IN (SELECT parcel_no FROM  stor_fcst_lift_nom n
		WHERE n.forecast_id = p_forecast_id
	    	  AND n.nom_firm_date >= p_start_date
		      AND n.nom_firm_date < p_end_date
		      AND n.object_id = nvl(p_storage_id, n.object_id));
	-- copy initialize lifting account
	INSERT INTO fcst_lift_acc_init_bal (forecast_id, object_id, balance, balance2, balance3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, created_by)
	SELECT p_new_forecast_id, n.object_id, balance, balance2, balance3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, ecdp_context.getAppUser
	FROM fcst_lift_acc_init_bal n, lifting_account l
	WHERE n.forecast_id = p_forecast_id
		AND n.object_id = l.object_id
		AND l.storage_id= nvl(p_storage_id, l.storage_id);

	-- copy lifting account adjustement
	INSERT INTO fcst_lift_acc_adj (forecast_id, object_id, to_object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, created_by)
	SELECT p_new_forecast_id, n.object_id, to_object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, ecdp_context.getAppUser
	FROM fcst_lift_acc_adj n, lifting_account l
	WHERE n.forecast_id = p_forecast_id
		AND n.daytime >= p_start_date
		AND n.daytime < p_end_date
		AND n.object_id = l.object_id
		AND l.storage_id= nvl(p_storage_id, l.storage_id);

	INSERT INTO fcst_lift_acc_adj_single (forecast_id, object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, adj_reason, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, created_by)
	SELECT p_new_forecast_id, n.object_id, daytime, summer_time, production_day, adj_qty, adj_qty2, adj_qty3, adj_reason, comments, value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4, ecdp_context.getAppUser
	FROM fcst_lift_acc_adj_single n, lifting_account l
	WHERE n.forecast_id = p_forecast_id
		AND n.daytime >= p_start_date
		AND n.daytime < p_end_date
		AND n.object_id = l.object_id
		AND l.storage_id= nvl(p_storage_id, l.storage_id);

	INSERT INTO FCST_OPLOC_DAY_RESTRICT (forecast_id,object_id,daytime, restricted_capacity, restriction_type, comments, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, restricted_capacity, restriction_type, comments, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM FCST_OPLOC_DAY_RESTRICT o, carrier c
	WHERE o.forecast_id = p_forecast_id
		AND o.daytime >= p_start_date
		AND o.daytime < p_end_date
		AND o.object_id = c.object_id;

	INSERT INTO FCST_RECOVERY_FACTOR (forecast_id, object_id, daytime, component_no, class_name, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, class_name, frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM FCST_RECOVERY_FACTOR o
	WHERE o.forecast_id = p_forecast_id
    AND o.daytime >= p_start_date
		AND o.daytime < p_end_date;

	-- copy period process train storage yield
	INSERT INTO FCST_TRAIN_INLET_GAS (object_id, forecast_id, daytime, end_date, inlet_gas, UOM, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15
	,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,value_11,value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20
	,value_21,value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, date_1, date_2, date_3, date_4, date_5)
	SELECT t.object_id, p_new_forecast_id, t.daytime, t.end_date, t.inlet_gas, t.UOM, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15
	, t.value_1, t.value_2, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19, t.value_20
	, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5
	FROM FCST_TRAIN_INLET_GAS t
	WHERE t.daytime >=p_start_date
		AND t.daytime < p_end_date
		AND t.forecast_id = p_forecast_id
		AND t.object_id in (SELECT object_id from FCST_TRAIN_STORAGE_YIELD where storage_id = nvl(p_storage_id, storage_id) and forecast_id = p_forecast_id);

	INSERT INTO FCST_TRAIN_STORAGE_YIELD (object_id, forecast_id, storage_Id, daytime, yield_factor, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15
	,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,value_11,value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20
	,value_21,value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, date_1, date_2, date_3, date_4, date_5)
	SELECT t.object_id, p_new_forecast_id, t.storage_Id, t.daytime, t.yield_factor, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15
	, t.value_1, t.value_2, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19, t.value_20
	, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5
	FROM FCST_TRAIN_STORAGE_YIELD t
	WHERE t.daytime >=p_start_date
		AND t.daytime < p_end_date
		AND t.forecast_id = p_forecast_id
		AND t.storage_id = nvl(p_storage_id, t.storage_id);
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
PROCEDURE copyToOriginal(p_forecast_id VARCHAR2)
--</EC-DOC>
IS
	CURSOR c_del_nom (cp_forecast_id VARCHAR2) IS
		SELECT n.parcel_no
		FROM stor_fcst_lift_nom n,
			     forecast c
		WHERE Nvl(n.DELETED_IND, 'N') = 'Y'
			AND n.forecast_id = cp_forecast_id
			AND n.forecast_id = c.object_id
			AND n.nom_firm_date >= c.start_date
		    AND n.nom_firm_date < c.end_date
		    AND n.object_id = nvl(c.storage_id, n.object_id);

    CURSOR c_fcst_train_inlet_gas(cp_forecast_id VARCHAR2) IS
		SELECT OBJECT_ID, DAYTIME, END_DATE FROM FCST_TRAIN_INLET_GAS WHERE FORECAST_ID = cp_forecast_id;

    CURSOR c_train_inlet_gas(cp_object_id VARCHAR2, cp_daytime date, cp_end_date date) IS
		SELECT tig.object_id , tig.daytime , tig.end_date , tig.inlet_gas FROM TRAIN_INLET_GAS tig
		 WHERE OBJECT_ID = cp_object_id
		 AND tig.daytime <> cp_daytime
		 AND (tig.end_date >= cp_daytime OR tig.end_date IS NULL)
		 AND (tig.daytime <= cp_end_date OR cp_end_date IS NULL);

BEGIN
	IF (p_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing forecast id');
	END IF;

	-- STOR_DAY_FORECAST
	MERGE INTO stor_day_forecast o
	USING (SELECT a.object_id, a.daytime, a.forecast_qty, a.forecast_qty2, a.forecast_qty3,
			a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
			a.text_1, a.text_2, a.text_3, a.text_4
		FROM stor_day_fcst_fcast a,
		     forecast c
		WHERE a.forecast_id = p_forecast_id
		      AND a.forecast_id = c.object_id
		      AND a.daytime >= c.start_date
		      AND a.daytime < c.end_date
		      AND Nvl(c.storage_id, a.object_id) = a.object_id) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);


	-- stor_sub_day_forecast
	MERGE INTO stor_sub_day_forecast o
	USING (SELECT a.object_id, a.daytime, a.forecast_qty, a.forecast_qty2, a.forecast_qty3, a.production_day, a.summer_time,
			a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
			a.text_1, a.text_2, a.text_3, a.text_4
		FROM stor_sub_day_fcst_fcast a,
		     forecast c
		WHERE a.forecast_id = p_forecast_id
		      AND a.forecast_id = c.object_id
		      AND a.production_day >= c.start_date
		      AND a.production_day < c.end_date
		      AND Nvl(c.storage_id, a.object_id) = a.object_id) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.summer_time = f.summer_time)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3, o.production_day, o.summer_time,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- STOR_MTH_PC_FORECAST
	MERGE INTO stor_mth_pc_forecast o
	USING (SELECT f.object_id, f.daytime, f.profit_centre_id, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4
		FROM stor_mth_fcst_pc_fcast f,
		     forecast c
		WHERE f.forecast_id = p_forecast_id
		      AND f.forecast_id = c.object_id
		      AND f.daytime >= c.start_date
		      AND f.daytime < c.end_date
		      AND Nvl(c.storage_id, f.object_id) = f.object_id) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.profit_centre_id = f.profit_centre_id)
	WHEN MATCHED THEN
		UPDATE SET o.GRS_VOL  = f.forecast_qty, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.profit_centre_id, o.daytime, o.GRS_VOL,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.profit_centre_id, f.daytime, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- STOR_DAY_PC_FORECAST
	MERGE INTO stor_day_pc_forecast o
	USING (SELECT f.object_id, f.daytime, f.profit_centre_id, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4
		FROM stor_day_fcst_pc_fcast f,
		     forecast c
		WHERE f.forecast_id = p_forecast_id
		      AND f.forecast_id = c.object_id
		      AND f.daytime >= c.start_date
		      AND f.daytime < c.end_date
		      AND Nvl(c.storage_id, f.object_id) = f.object_id) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.profit_centre_id = f.profit_centre_id)
	WHEN MATCHED THEN
		UPDATE SET o.GRS_VOL  = f.forecast_qty, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.profit_centre_id, o.daytime, o.GRS_VOL,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.profit_centre_id, f.daytime, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- lift account forecast
	MERGE INTO 	lift_acc_day_forecast o
	USING (SELECT l.object_id, l.daytime, l.forecast_qty, l.forecast_qty2, l.forecast_qty3,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4
		FROM lift_acc_day_fcst_fcast l,
		     forecast c,
		     lifting_account a
		WHERE l.forecast_id = p_forecast_id
		      AND l.forecast_id = c.object_id
		      AND l.daytime >= c.start_date
		      AND l.daytime < c.end_date
		      AND l.object_id = a.object_id
		      AND a.storage_id = nvl(c.storage_id, a.storage_id)) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);


		-- lift_acc_sub_day_forecast
	MERGE INTO 	lift_acc_sub_day_forecast o
	USING (SELECT l.object_id, l.daytime, l.forecast_qty, l.forecast_qty2, l.forecast_qty3, l.production_day, l.summer_time,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4
		FROM lift_acc_sub_day_fcst_fc l,
		     forecast c,
		     lifting_account a
		WHERE l.forecast_id = p_forecast_id
		      AND l.forecast_id = c.object_id
		      AND l.production_day >= c.start_date
		      AND l.production_day < c.end_date
		      AND l.object_id = a.object_id
		      AND a.storage_id = nvl(c.storage_id, a.storage_id)) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.summer_time = f.summer_time)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3, o.production_day, o.summer_time,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- cargo transport
	MERGE INTO cargo_transport o
	USING (SELECT t.cargo_no, t.cargo_name, t.carrier_id, t.agent, t.surveyor, t.laytime,t.EST_ARRIVAL,t.EST_DEPARTURE,t.CARGO_STATUS,t.PROD_FCTY_ID,t.MASTER,t.PILOT,t.TUGS_ARR,t.TUGS_DEP,t.DRAUGHT_MARK_ARR_AFT,t.DRAUGHT_MARK_ARR_CENTER,t.DRAUGHT_MARK_ARR_FORWARD,t.DRAUGHT_MARK_DEP_AFT,t.DRAUGHT_MARK_DEP_CENTER,t.DRAUGHT_MARK_DEP_FORWARD,t.VOYAGE_NO,t.BERTH_ID,
		    t.text_1,t.text_2,t.text_3,t.text_4,t.text_5,t.text_6,
		    t.value_1,t.value_2,t.value_3,t.value_4,t.value_5,t.value_6,t.value_7,t.value_8,t.value_9,t.value_10,
		    t.date_1,t.date_2,t.date_3,t.date_4,t.date_5,t.date_6,t.date_7
		FROM cargo_fcst_transport t,
		     forecast c
		WHERE t.forecast_id = p_forecast_id
		      AND t.forecast_id = c.object_id
		      AND cargo_no in (select cargo_no
		              FROM  stor_fcst_lift_nom n
		              WHERE n.forecast_id = c.object_id
		                    AND n.nom_firm_date >= c.start_date
		                    AND n.nom_firm_date < c.end_date
		                    AND n.object_id = nvl(c.storage_id, n.object_id)))f
	ON (o.cargo_no = f.cargo_no)
	WHEN MATCHED THEN
		UPDATE SET o.cargo_name = f.cargo_name, o.carrier_id = f.carrier_id, o.agent = f.agent, o.surveyor = f.surveyor, o.laytime = f.laytime,o.EST_ARRIVAL = f.EST_ARRIVAL,o.EST_DEPARTURE = f.EST_DEPARTURE,o.CARGO_STATUS = f.CARGO_STATUS,
		o.PROD_FCTY_ID = f.PROD_FCTY_ID,o.MASTER = f.MASTER,o.PILOT = f.PILOT,o.TUGS_ARR = f.TUGS_ARR,o.TUGS_DEP = f.TUGS_DEP,o.DRAUGHT_MARK_ARR_AFT = f.DRAUGHT_MARK_ARR_AFT,o.DRAUGHT_MARK_ARR_CENTER = f.DRAUGHT_MARK_ARR_CENTER,o.DRAUGHT_MARK_ARR_FORWARD = f.DRAUGHT_MARK_ARR_FORWARD,o.DRAUGHT_MARK_DEP_AFT = f.DRAUGHT_MARK_DEP_AFT,o.DRAUGHT_MARK_DEP_CENTER = f.DRAUGHT_MARK_DEP_CENTER,o.DRAUGHT_MARK_DEP_FORWARD = f.DRAUGHT_MARK_DEP_FORWARD,o.VOYAGE_NO = f.VOYAGE_NO,o.BERTH_ID = f.BERTH_ID,
		o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
		o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4,
		o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_4, o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 =f.date_7, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.cargo_no, o.cargo_name, o.carrier_id, o.agent, o.surveyor, o.laytime,o.EST_ARRIVAL,o.EST_DEPARTURE,o.CARGO_STATUS,o.PROD_FCTY_ID,o.MASTER,o.PILOT,o.TUGS_ARR,o.TUGS_DEP,o.DRAUGHT_MARK_ARR_AFT,o.DRAUGHT_MARK_ARR_CENTER,o.DRAUGHT_MARK_ARR_FORWARD,o.DRAUGHT_MARK_DEP_AFT,o.DRAUGHT_MARK_DEP_CENTER,o.DRAUGHT_MARK_DEP_FORWARD,o.VOYAGE_NO,o.BERTH_ID,
		    o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,
		    o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,
		    o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,o.date_6,o.date_7,
		    created_by)
		VALUES (f.cargo_no, f.cargo_name, f.carrier_id, f.agent, f.surveyor, f.laytime,f.EST_ARRIVAL,f.EST_DEPARTURE,f.CARGO_STATUS,f.PROD_FCTY_ID,f.MASTER,f.PILOT,f.TUGS_ARR,f.TUGS_DEP,f.DRAUGHT_MARK_ARR_AFT,f.DRAUGHT_MARK_ARR_CENTER,f.DRAUGHT_MARK_ARR_FORWARD,f.DRAUGHT_MARK_DEP_AFT,f.DRAUGHT_MARK_DEP_CENTER,f.DRAUGHT_MARK_DEP_FORWARD,f.VOYAGE_NO,f.BERTH_ID,
		    f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,
		    f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,
		    f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,f.date_6,f.date_7, ecdp_context.getAppUser);

	-- delete nominations
	FOR curDelNom IN c_del_nom(p_forecast_id) LOOP
		DELETE storage_lifting WHERE parcel_no = curDelNom.parcel_no;
		DELETE lift_doc_instruction WHERE parcel_no = curDelNom.parcel_no;
		DELETE lifting_doc_receiver WHERE parcel_no = curDelNom.parcel_no;
		DELETE lifting_doc_set WHERE parcel_no = curDelNom.parcel_no;
		DELETE storage_lift_nomination WHERE parcel_no = curDelNom.parcel_no;
	END LOOP;

	--insert update nominations
	MERGE INTO storage_lift_nomination o
	USING (SELECT n.parcel_no,n.object_id,n.cargo_no,n.lifting_account_id,n.carrier_id,n.consignor_id,n.consignee_id,n.requested_date,n.requested_date_range,n.requested_tolerance_type,n.grs_vol_requested,n.nom_firm_date,n.nom_firm_date_range,n.nom_sequence,n.grs_vol_nominated,
			n.lifting_split_pct,n.lifting_split_vol,n.lifting_code,n.incoterm,n.contract_id,n.telex_ref,n.graph_value,n.balance_ind,n.grs_vol_schedule,n.schedule_tolerance_type,n.bl_number,n.port_id,n.doc_instr_received_ind,n.fixed_ind,n.charter_party,n.comments,
			n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,
			n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8,n.value_9,n.value_10,
			n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.grs_vol_scheduled2, n.grs_vol_requested2, n.grs_vol_nominated2, n.grs_vol_scheduled3, n.grs_vol_requested3, n.grs_vol_nominated3, n.nom_firm_date_time, n.start_lifting_date,
	        n.cooldown_qty,n.cooldown_qty2,n.cooldown_qty3,n.purge_qty,n.purge_qty2,n.purge_qty3,n.vapour_return_qty,n.vapour_return_qty2,n.vapour_return_qty3,n.lauf_qty,n.lauf_qty2,n.lauf_qty3,n.balance_delta_qty,n.balance_delta_qty2,n.balance_delta_qty3,
			n.ref_object_id_1
		FROM  stor_fcst_lift_nom n,
		     forecast c
		WHERE n.forecast_id = p_forecast_id
			AND Nvl(n.DELETED_IND, 'N') <> 'Y'
			AND n.forecast_id = c.object_id
			AND n.nom_firm_date >= c.start_date
		    AND n.nom_firm_date < c.end_date
		    AND n.object_id = nvl(c.storage_id, n.object_id))f
	ON (o.parcel_no = f.parcel_no)
	WHEN MATCHED THEN
		UPDATE SET o.object_id = f.object_id,o.cargo_no = f.cargo_no,o.lifting_account_id = f.lifting_account_id,o.carrier_id = f.carrier_id,o.consignor_id = f.consignor_id,o.consignee_id = f.consignee_id,o.requested_date = f.requested_date,o.requested_date_range = f.requested_date_range,o.requested_tolerance_type = f.requested_tolerance_type,o.grs_vol_requested = f.grs_vol_requested,o.nom_firm_date = f.nom_firm_date,o.nom_firm_date_range = f.nom_firm_date_range,o.nom_sequence = f.nom_sequence,o.grs_vol_nominated = f.grs_vol_nominated,
			o.lifting_split_pct = f.lifting_split_pct,o.lifting_split_vol = f.lifting_split_vol,o.lifting_code = f.lifting_code,o.incoterm = f.incoterm,o.contract_id = f.contract_id,o.telex_ref = f.telex_ref,o.graph_value = f.graph_value,o.balance_ind = f.balance_ind,o.grs_vol_schedule = f.grs_vol_schedule,o.schedule_tolerance_type = f.schedule_tolerance_type,o.bl_number = f.bl_number,o.port_id = f.port_id,o.doc_instr_received_ind = f.doc_instr_received_ind,o.fixed_ind = f.fixed_ind,o.charter_party = f.charter_party,o.comments = f.comments,
			o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5, o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10,
			o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_4, o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 = f.date_7, o.grs_vol_scheduled2 = f.grs_vol_scheduled2, o.grs_vol_requested2 = f.grs_vol_requested2, o.grs_vol_nominated2 = f.grs_vol_nominated2, o.grs_vol_scheduled3 = f.grs_vol_scheduled3, o.grs_vol_requested3 = f.grs_vol_requested3, o.grs_vol_nominated3 = f.grs_vol_nominated3, o.nom_firm_date_time = f.nom_firm_date_time, o.start_lifting_date = f.start_lifting_date,
	        o.cooldown_qty = f.cooldown_qty, o.cooldown_qty2 = f.cooldown_qty2,o.cooldown_qty3 = f.cooldown_qty3,o.purge_qty = f.purge_qty,o.purge_qty2 = f.purge_qty2,o.purge_qty3 = f.purge_qty3,o.vapour_return_qty = f.vapour_return_qty,o.vapour_return_qty2 = f.vapour_return_qty2,o.vapour_return_qty3 = f.vapour_return_qty3,o.lauf_qty = f.lauf_qty,o.lauf_qty2 = f.lauf_qty2,o.lauf_qty3 = f.lauf_qty3,o.balance_delta_qty = f.balance_delta_qty,o.balance_delta_qty2 = f.balance_delta_qty2,o.balance_delta_qty3 = f.balance_delta_qty3,
			o.ref_object_id_1 = f.ref_object_id_1, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.parcel_no,o.object_id,o.cargo_no,o.lifting_account_id,o.carrier_id,o.consignor_id,o.consignee_id,o.requested_date,o.requested_date_range,o.requested_tolerance_type,o.grs_vol_requested,o.nom_firm_date,o.nom_firm_date_range,o.nom_sequence,o.grs_vol_nominated,o.lifting_split_pct,o.lifting_split_vol,o.lifting_code,o.incoterm,o.contract_id,o.telex_ref,o.graph_value,o.balance_ind,o.grs_vol_schedule,o.schedule_tolerance_type,o.bl_number,o.port_id,o.doc_instr_received_ind,o.fixed_ind,o.charter_party,o.comments,
			o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10,
			o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,
			o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,o.date_6,o.date_7, o.grs_vol_scheduled2, o.grs_vol_requested2, o.grs_vol_nominated2, o.grs_vol_scheduled3, o.grs_vol_requested3, o.grs_vol_nominated3, o.nom_firm_date_time, o.start_lifting_date,
	        o.cooldown_qty,o.cooldown_qty2,o.cooldown_qty3,o.purge_qty,o.purge_qty2,o.purge_qty3,o.vapour_return_qty,o.vapour_return_qty2,o.vapour_return_qty3,o.lauf_qty,o.lauf_qty2,o.lauf_qty3,o.balance_delta_qty,o.balance_delta_qty2,o.balance_delta_qty3,
			ref_object_id_1, created_by)
		VALUES (f.parcel_no,f.object_id,f.cargo_no,f.lifting_account_id,f.carrier_id,f.consignor_id,f.consignee_id,f.requested_date,f.requested_date_range,f.requested_tolerance_type,f.grs_vol_requested,f.nom_firm_date,f.nom_firm_date_range,f.nom_sequence,f.grs_vol_nominated,f.lifting_split_pct,f.lifting_split_vol,f.lifting_code,f.incoterm,f.contract_id,f.telex_ref,f.graph_value,f.balance_ind,f.grs_vol_schedule,f.schedule_tolerance_type,f.bl_number,f.port_id,f.doc_instr_received_ind,f.fixed_ind,f.charter_party,f.comments,
			f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10,
			f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,
			f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,f.date_6,f.date_7, f.grs_vol_scheduled2, f.grs_vol_requested2, f.grs_vol_nominated2, f.grs_vol_scheduled3, f.grs_vol_requested3, f.grs_vol_nominated3, f.nom_firm_date_time, f.start_lifting_date,
	        f.cooldown_qty,f.cooldown_qty2,f.cooldown_qty3,f.purge_qty,f.purge_qty2,f.purge_qty3,f.vapour_return_qty,f.vapour_return_qty2,f.vapour_return_qty3,f.lauf_qty,f.lauf_qty2,f.lauf_qty3,f.balance_delta_qty,f.balance_delta_qty2,f.balance_delta_qty3,
			f.ref_object_id_1,ecdp_context.getAppUser);


	MERGE INTO stor_sub_day_lift_nom o
	USING (SELECT ns.forecast_id,ns.parcel_no,ns.object_id,ns.daytime,ns.summer_time,ns.production_day,ns.grs_vol_requested,ns.grs_vol_nominated,ns.grs_vol_schedule,ns.grs_vol_requested2,ns.grs_vol_nominated2,ns.grs_vol_scheduled2,ns.grs_vol_requested3,ns.grs_vol_nominated3,ns.grs_vol_scheduled3,
	        ns.cooldown_qty,ns.cooldown_qty2,ns.cooldown_qty3,ns.purge_qty,ns.purge_qty2,ns.purge_qty3,ns.vapour_return_qty,ns.vapour_return_qty2,ns.vapour_return_qty3,ns.lauf_qty,ns.lauf_qty2,ns.lauf_qty3,ns.balance_delta_qty,ns.balance_delta_qty2,ns.balance_delta_qty3,
		    ns.text_1,ns.text_2,ns.text_3,ns.text_4,ns.text_5,ns.text_6,ns.text_7,ns.text_8,ns.text_9,ns.text_10,ns.text_11,ns.text_12,ns.text_13,ns.text_14,ns.text_15,ns.value_1,ns.value_2,ns.value_3,ns.value_4,ns.value_5,ns.value_6,ns.value_7,ns.value_8,ns.value_9,ns.value_10,ns.date_1,ns.date_2,ns.date_3,ns.date_4,ns.date_5
	  FROM  stor_fcst_sub_day_lift_nom ns,
		     forecast c
		WHERE ns.forecast_id = p_forecast_id
			AND ns.forecast_id = c.object_id
	        AND ns.parcel_no IN (select parcel_no
		              FROM  stor_fcst_lift_nom n
		              WHERE n.forecast_id = c.object_id
		                    AND n.nom_firm_date >= c.start_date
		                    AND n.nom_firm_date < c.end_date
		                    AND n.object_id = nvl(c.storage_id, n.object_id)))f
	ON (o.parcel_no = f.parcel_no AND o.daytime = f.daytime AND o.summer_time = f.summer_time)
	WHEN MATCHED THEN
		UPDATE SET o.object_id = f.object_id,o.production_day = f.production_day, o.grs_vol_requested = f.grs_vol_requested,o.grs_vol_nominated = f.grs_vol_nominated,o.grs_vol_schedule = f.grs_vol_schedule,
	        o.grs_vol_requested2 = f.grs_vol_requested2,o.grs_vol_nominated2 = f.grs_vol_nominated2,o.grs_vol_scheduled2 = f.grs_vol_scheduled2,o.grs_vol_nominated3 = f.grs_vol_nominated3, o.grs_vol_scheduled3 = f.grs_vol_scheduled3,
	        o.cooldown_qty = f.cooldown_qty, o.cooldown_qty2 = f.cooldown_qty2,o.cooldown_qty3 = f.cooldown_qty3,o.purge_qty = f.purge_qty,o.purge_qty2 = f.purge_qty2,o.purge_qty3 = f.purge_qty3,o.vapour_return_qty = f.vapour_return_qty,o.vapour_return_qty2 = f.vapour_return_qty2,o.vapour_return_qty3 = f.vapour_return_qty3,o.lauf_qty = f.lauf_qty,o.lauf_qty2 = f.lauf_qty2,o.lauf_qty3 = f.lauf_qty3,o.balance_delta_qty = f.balance_delta_qty,o.balance_delta_qty2 = f.balance_delta_qty2,o.balance_delta_qty3 = f.balance_delta_qty3,
			o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5, o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10, o.text_11 = f.text_11, o.text_12 = f.text_12, o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15,
			o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_4, o.date_4 = f.date_4, o.date_5 = f.date_5,
			last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
	INSERT (o.parcel_no,o.object_id,o.daytime,o.summer_time,o.production_day,o.grs_vol_requested,o.grs_vol_nominated,o.grs_vol_schedule,o.grs_vol_requested2,o.grs_vol_nominated2,o.grs_vol_scheduled2,o.grs_vol_requested3,o.grs_vol_nominated3,o.grs_vol_scheduled3,
	    o.cooldown_qty,o.cooldown_qty2,o.cooldown_qty3,o.purge_qty,o.purge_qty2,o.purge_qty3,o.vapour_return_qty,o.vapour_return_qty2,o.vapour_return_qty3,o.lauf_qty,o.lauf_qty2,o.lauf_qty3,o.balance_delta_qty,o.balance_delta_qty2,o.balance_delta_qty3,
		o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10,o.text_11,o.text_12,o.text_13,o.text_14,o.text_15,o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,
		created_by)
	VALUES (f.parcel_no,f.object_id,f.daytime,f.summer_time,f.production_day,f.grs_vol_requested,f.grs_vol_nominated,f.grs_vol_schedule,f.grs_vol_requested2,f.grs_vol_nominated2,f.grs_vol_scheduled2,f.grs_vol_requested3,f.grs_vol_nominated3,f.grs_vol_scheduled3,
	    f.cooldown_qty,f.cooldown_qty2,f.cooldown_qty3,f.purge_qty,f.purge_qty2,f.purge_qty3,f.vapour_return_qty,f.vapour_return_qty2,f.vapour_return_qty3,f.lauf_qty,f.lauf_qty2,f.lauf_qty3,f.balance_delta_qty,f.balance_delta_qty2,f.balance_delta_qty3,
		f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10,f.text_11,f.text_12,f.text_13,f.text_14,f.text_15,f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,
		ecdp_context.getAppUser);

	ecbp_cargo_transport.cleanLonesomeCargoes;

	--lifting account adjustement
	MERGE INTO 	lift_account_adjustment o
	USING (SELECT l.object_id, l.to_object_id, l.daytime, l.summer_time, l.production_day, l.adj_qty, l.adj_qty2, l.adj_qty3, l.comments,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4
		FROM fcst_lift_acc_adj l,
			 forecast c,
			 lifting_account a
		WHERE l.forecast_id = p_forecast_id
			  AND l.forecast_id = c.object_id
			  AND l.daytime >= c.start_date
			  AND l.daytime < c.end_date
			  AND l.object_id = a.object_id
			  AND a.storage_id = nvl(c.storage_id, a.storage_id)) f
	ON (o.object_id = f.object_id AND o.to_object_id = f.to_object_id AND o.daytime = f.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.summer_time  = f.summer_time, o.production_day = f.production_day, o.adj_qty  = f.adj_qty, o.adj_qty2 = f.adj_qty2, o.adj_qty3 = f.adj_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.to_object_id, o.daytime, o.summer_time, o.production_day, o.adj_qty, o.adj_qty2, o.adj_qty3, o.comments,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.to_object_id, f.daytime, f.summer_time, f.production_day, f.adj_qty, f.adj_qty2, f.adj_qty3, f.comments, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	MERGE INTO 	lift_account_adj_single o
	USING (SELECT l.object_id, l.daytime, l.summer_time, l.production_day, l.adj_qty, l.adj_qty2, l.adj_qty3, l.adj_reason, l.comments
		FROM fcst_lift_acc_adj_single l,
			 forecast c,
			 lifting_account a
		WHERE l.forecast_id = p_forecast_id
			  AND l.forecast_id = c.object_id
			  AND l.daytime >= c.start_date
			  AND l.daytime < c.end_date
			  AND l.object_id = a.object_id
			  AND a.storage_id = nvl(c.storage_id, a.storage_id)) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.summer_time  = f.summer_time, o.production_day = f.production_day, o.adj_qty  = f.adj_qty, o.adj_qty2 = f.adj_qty2, o.adj_qty3 = f.adj_qty3, o.adj_reason = f.adj_reason, o.comments = f.comments, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.summer_time, o.production_day, o.adj_qty, o.adj_qty2, o.adj_qty3, o.adj_reason, o.comments, o.created_by)
		VALUES (f.object_id, f.daytime, f.summer_time, f.production_day, f.adj_qty, f.adj_qty2, f.adj_qty3, f.adj_reason, f.comments, ecdp_context.getAppUser);

	MERGE INTO OPLOC_DAILY_RESTRICTION o
	USING (SELECT f.object_id, f.daytime, f.restricted_capacity, f.restriction_type, f.comments
		FROM FCST_OPLOC_DAY_RESTRICT f,
			 forecast c,
			 carrier a
		WHERE f.forecast_id = p_forecast_id
			  AND f.forecast_id = c.object_id
			  AND f.daytime >= c.start_date
			  AND f.daytime < c.end_date
			  AND f.object_id = a.object_id) t
	ON (o.object_id = t.object_id AND o.daytime = t.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.restricted_capacity  = t.restricted_capacity, o.restriction_type = t.restriction_type, o.comments = t.comments, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.restricted_capacity, o.restriction_type, o.comments, o.created_by)
		VALUES (t.object_id, t.daytime, t.restricted_capacity, t.restriction_type, t.comments, ecdp_context.getAppUser);

	MERGE INTO OBJ_EVENT_CP_TRAN_FACTOR o
	USING (SELECT f.object_id, f.daytime, f.component_no, f.class_name, f.frac
		FROM FCST_RECOVERY_FACTOR f,
			 forecast c
		WHERE f.forecast_id = p_forecast_id
			  AND f.forecast_id = c.object_id
			  AND f.daytime >= c.start_date
			  AND f.daytime < c.end_date) t
	ON (o.object_id = t.object_id AND o.daytime = t.daytime AND o.component_no = t.component_no)
	WHEN MATCHED THEN
		UPDATE SET o.class_name = 'TRNP_EVENT_CP_TRAN_FAC', o.frac = t.frac, last_updated_by = ecdp_context.getAppUser
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.component_no, o.class_name, o.frac, o.created_by)
		VALUES (t.object_id, t.daytime, t.component_no, 'TRNP_EVENT_CP_TRAN_FAC', t.frac, ecdp_context.getAppUser);

	-- copy period process train storage yield

	  --delete records on baseplan that overlap with forecast

	  FOR CUR_FCST_TRAIN_INLET_GAS IN C_FCST_TRAIN_INLET_GAS(p_forecast_id) LOOP
		FOR CUR_TRAIN_INLET_GAS IN C_TRAIN_INLET_GAS(CUR_fcst_train_inlet_gas.OBJECT_ID, CUR_fcst_train_inlet_gas.DAYTIME, CUR_fcst_train_inlet_gas.END_DATE) LOOP
		  DELETE FROM TRAIN_STORAGE_YIELD WHERE OBJECT_ID=CUR_TRAIN_INLET_GAS.OBJECT_ID AND DAYTIME = CUR_TRAIN_INLET_GAS.DAYTIME;
		  DELETE FROM TRAIN_INLET_GAS WHERE object_id=CUR_TRAIN_INLET_GAS.OBJECT_ID AND DAYTIME=CUR_TRAIN_INLET_GAS.DAYTIME;
		END LOOP;
	  END LOOP;

	  MERGE INTO TRAIN_INLET_GAS o
	  USING (SELECT f.object_id, f.forecast_id, f.daytime, f.end_date, f.inlet_gas, f.UOM, f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15
	  , f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10, f.value_11, f.value_12, f.value_13, f.value_14, f.value_15, f.value_16, f.value_17, f.value_18
	  , f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30, f.date_1, f.date_2, f.date_3, f.date_4, f.date_5
		FROM FCST_TRAIN_INLET_GAS f, forecast c
		WHERE f.forecast_id = p_forecast_id
			AND f.forecast_id = c.object_id
			AND f.daytime >= c.start_date
			AND f.daytime < c.end_date) t
	  ON (o.object_id = t.object_id AND o.daytime = t.daytime)
	  WHEN MATCHED THEN
		UPDATE SET o.end_date=t.end_date, o.inlet_gas=t.inlet_gas, o.uom=t.uom, o.text_1=t.text_1, o.text_2=t.text_2, o.text_3=t.text_3, o.text_4=t.text_4, o.text_5=t.text_5, o.text_6=t.text_6, o.text_7=t.text_7, o.text_8=t.text_8, o.text_9=t.text_9, o.text_10=t.text_10
		, o.text_11=t.text_11, o.text_12=t.text_12, o.text_13=t.text_13, o.text_14=t.text_14, o.text_15=t.text_15, o.value_1=t.value_1, o.value_2=t.value_2, o.value_3=t.value_3, o.value_4=t.value_4, o.value_5=t.value_5
		, o.value_6=t.value_6, o.value_7=t.value_7, o.value_8=t.value_8, o.value_9=t.value_9, o.value_10=t.value_10, o.value_11=t.value_11, o.value_12=t.value_12, o.value_13=t.value_13, o.value_14=t.value_14
		, o.value_15=t.value_15, o.value_16=t.value_16, o.value_17=t.value_17, o.value_18=t.value_18, o.value_19=t.value_19, o.value_20=t.value_20, o.value_21=t.value_21, o.value_22=t.value_22, o.value_23=t.value_23
		, o.value_24=t.value_24, o.value_25=t.value_25, o.value_26=t.value_26, o.value_27=t.value_27, o.value_28=t.value_28, o.value_29=t.value_29, o.value_30=t.value_30, o.date_1=t.date_1, o.date_2=t.date_2
		, o.date_3=t.date_3, o.date_4=t.date_4, o.date_5=t.date_5
		, last_updated_by = ecdp_context.getAppUser
	  WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.end_date, o.inlet_gas, o.UOM, o.text_1, o.text_2, o.text_3, o.text_4, o.text_5, o.text_6, o.text_7, o.text_8, o.text_9, o.text_10, o.text_11, o.text_12, o.text_13, o.text_14, o.text_15, o.value_1, o.value_2
		, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10, o.value_11, o.value_12, o.value_13, o.value_14, o.value_15, o.value_16, o.value_17, o.value_18, o.value_19
		, o.value_20, o.value_21, o.value_22, o.value_23, o.value_24, o.value_25, o.value_26, o.value_27, o.value_28, o.value_29, o.value_30, o.date_1, o.date_2, o.date_3, o.date_4, o.date_5, o.created_by)
		VALUES (t.object_id, t.daytime, t.end_date, t.inlet_gas, t.UOM, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15, t.value_1, t.value_2
		, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19
		, t.value_20, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5, ecdp_context.getAppUser);

	  MERGE INTO TRAIN_STORAGE_YIELD o
	  USING (SELECT f.object_id, f.forecast_id, f.storage_id, f.daytime, f.yield_factor, f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15
	  , f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10, f.value_11, f.value_12, f.value_13, f.value_14, f.value_15, f.value_16, f.value_17, f.value_18
	  , f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30, f.date_1, f.date_2, f.date_3, f.date_4, f.date_5
		FROM FCST_TRAIN_STORAGE_YIELD f, forecast c
		WHERE f.forecast_id = p_forecast_id
			AND f.forecast_id = c.object_id
			AND f.daytime >= c.start_date
			AND f.daytime < c.end_date) t
	  ON (o.object_id = t.object_id AND o.storage_id=t.storage_id AND o.daytime = t.daytime)
	  WHEN MATCHED THEN
		UPDATE SET o.yield_factor=t.yield_factor, o.text_1=t.text_1, o.text_2=t.text_2, o.text_3=t.text_3, o.text_4=t.text_4, o.text_5=t.text_5, o.text_6=t.text_6, o.text_7=t.text_7, o.text_8=t.text_8, o.text_9=t.text_9, o.text_10=t.text_10
		, o.text_11=t.text_11, o.text_12=t.text_12, o.text_13=t.text_13, o.text_14=t.text_14, o.text_15=t.text_15, o.value_1=t.value_1, o.value_2=t.value_2, o.value_3=t.value_3, o.value_4=t.value_4, o.value_5=t.value_5
		, o.value_6=t.value_6, o.value_7=t.value_7, o.value_8=t.value_8, o.value_9=t.value_9, o.value_10=t.value_10, o.value_11=t.value_11, o.value_12=t.value_12, o.value_13=t.value_13, o.value_14=t.value_14
		, o.value_15=t.value_15, o.value_16=t.value_16, o.value_17=t.value_17, o.value_18=t.value_18, o.value_19=t.value_19, o.value_20=t.value_20, o.value_21=t.value_21, o.value_22=t.value_22, o.value_23=t.value_23
		, o.value_24=t.value_24, o.value_25=t.value_25, o.value_26=t.value_26, o.value_27=t.value_27, o.value_28=t.value_28, o.value_29=t.value_29, o.value_30=t.value_30, o.date_1=t.date_1, o.date_2=t.date_2
		, o.date_3=t.date_3, o.date_4=t.date_4, o.date_5=t.date_5
		, last_updated_by = ecdp_context.getAppUser
	  WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.storage_id, o.daytime, o.yield_factor, o.text_1, o.text_2, o.text_3, o.text_4, o.text_5, o.text_6, o.text_7, o.text_8, o.text_9, o.text_10, o.text_11, o.text_12, o.text_13, o.text_14, o.text_15, o.value_1, o.value_2
		, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10, o.value_11, o.value_12, o.value_13, o.value_14, o.value_15, o.value_16, o.value_17, o.value_18, o.value_19
		, o.value_20, o.value_21, o.value_22, o.value_23, o.value_24, o.value_25, o.value_26, o.value_27, o.value_28, o.value_29, o.value_30, o.date_1, o.date_2, o.date_3, o.date_4, o.date_5, o.created_by)
		VALUES (t.object_id, t.storage_id, t.daytime, t.yield_factor, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15, t.value_1, t.value_2
		, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19
		, t.value_20, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5, ecdp_context.getAppUser);

END copyToOriginal;


--<EC-DOC>
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
  IF(p_start_date = p_end_date)THEN

	DELETE stor_day_fcst_pc_fcast WHERE forecast_id = p_forecast_id;
	DELETE stor_mth_fcst_pc_fcast WHERE forecast_id = p_forecast_id;

	DELETE stor_day_fcst_fcast WHERE forecast_id = p_forecast_id;
	DELETE stor_sub_day_fcst_fcast WHERE forecast_id = p_forecast_id;

	DELETE lift_acc_day_fcst_fcast WHERE forecast_id = p_forecast_id;
	DELETE lift_acc_sub_day_fcst_fc WHERE forecast_id = p_forecast_id;

	DELETE stor_fcst_sub_day_lift_nom WHERE forecast_id = p_forecast_id;
	DELETE stor_fcst_lift_nom WHERE forecast_id = p_forecast_id;
	DELETE cargo_fcst_transport WHERE forecast_id = p_forecast_id;

	DELETE fcst_lift_acc_init_bal WHERE forecast_id = p_forecast_id;
	DELETE fcst_lift_acc_adj WHERE forecast_id = p_forecast_id;
	DELETE fcst_lift_acc_adj_single WHERE forecast_id = p_forecast_id;

	DELETE FCST_OPLOC_DAY_RESTRICT where forecast_id = p_forecast_id;
	DELETE FCST_RECOVERY_FACTOR where forecast_id = p_forecast_id;

	DELETE FCST_TRAIN_INLET_GAS where forecast_id = p_forecast_id;
	DELETE FCST_TRAIN_STORAGE_YIELD where forecast_id = p_forecast_id;

	ue_Forecast_Cargo_Planning.deleteForecastCascade(p_forecast_id,p_start_date,p_end_date);

  END IF;

END deleteForecastCascade;

END EcBp_Forecast_Cargo_Planning;