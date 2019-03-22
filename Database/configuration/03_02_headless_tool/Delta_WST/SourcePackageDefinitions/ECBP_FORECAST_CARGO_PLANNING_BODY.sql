CREATE OR REPLACE PACKAGE BODY EcBp_Forecast_Cargo_Planning IS
/****************************************************************
** Package        :  EcBp_Forecast_Cargo_Planning; body part
**
** $Revision: 1.26 $
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
** 24.01.2013  meisihil         ECPD-20962: Included Sub daily lifting nomination table when copy from original, copy from forecast, copy to original and delete forecast and remove date_time columns.
** 31/01/2013  chooysie         ECPD-22957 Initialize Lifting Account and Lifting Account Adjustments should join to lifting account
** 06/02/2013  hassakha         ECPD-22671 Includes Carrier Acailability when copy from original, copy from forecast, copy to original
** 08/03/2013  chooysie         ECPD-23227 Include summer_time and production_day when perform copy for Lifting Account Adjustments
** 08/05/2013  farhaann			ECPD-19505 Includes Forecast Recovery Factor when copy from original, copy from forecast, copy to original and deleteForecastCascade
** 18/11/2013  muhammah			ECPD-25921 update procedure deleteForecastCascade to call ue function
** 12/03/2014  chooysie  		ECPD-26914: Include Forecast Period Process Train Storage Yield when copy from original, copy from forecast, copy to original and deleteForecastCascade
** 22/08/2014  leeeewei			ECPD-28347: Include Forecast Period Product Component Recovery Factor in copy from original, copy from forecast, copy to original and deleteForecastCascade
** 12/01/2016  sharawan     	ECPD-33109: Include copy maintenance data into copy forecast procedures. Added parameter for copyFromOriginal and copyFromForecast used in Forecast Manager screen.
** 13/05/2016  thotesan     	ECPD-34758: EcBp_Forecast_Cargo_Planning.copyToOriginal misses columns in update.
** 21/10/2016  baratmah         ECPD-39195: Modified copyToOriginal,copyFromOriginal and copyFromForecast. Added Text_x columns to storage_lift_nomination and STOR_FCST_LIFT_NOM.
** 21/11/2016  asareswi         ECPD-39403: Added Delete from FCST_OPLOC_PERIOD_RESTR statement in deleteForecastCascade(). This will delete all records for the forecast which get inserted from Period Operational Restriction section of schedule tab of Forecast Manager screen.
** 05/12/2016  asareswi			ECPD-34770: Added ValidateStorage procedure to validate the storage assign to forecasts in forecast manager.
** 01/03/2017  xxwaghmp			ECPD-42307: Modified Procedure createForecast to refresh acl tables when ringfencing is On.
** 01/03/2017  sharawan         ECPD-35546: Modified copyToOriginal to check for deleted data in forecast and delete related sub daily lifting when the sub daily liftings records are merged.
** 13/03/2017  farhaann         ECPD-40982: Modified copyFromOriginal, copyFromForecast, copyToOriginal and deleteForecastCascade
** 22/03/2017  farhaann         ECPD-44120: Modified copyFromOriginal, copyFromForecast and copyToOriginal
** 30/03/2017  sharawan         ECPD-42248: Modified copyToOriginal to rearrange delete child records query in storage_lift_nom_split and adding filter for deleted_ind = Y when nomination split records are merged.
** 25/04/2017  asareswi         ECPD-35628: Modified copyToOriginal to generate revision info record for those record which modified in forecast. Added rev_no+1 in update statement.
** 07/04/2017  sharawan         ECPD-44803: Modified deleteForecastCascade to rearrange delete child records query in FCST_STOR_LIFT_CPY_SPLIT
** 14/06/2017  royyypur         ECPD-46043: Modified copyFromOriginal, copyFromForecast and copyToOriginal to include coolddown_ind and purge_ind
** 14/06/2017  sharawan         ECPD-45674: Modified ValidateStorage to return info message if the storage are mismatch for comparison in Forecast Manager - Compare tab.
** 20/06/2017  baratmah         ECPD-45666: Modified copyToOriginal,copyFromOriginal and copyFromForecast to add missing generic columns.
** 06/10/2017  xxwaghmp         ECPD-42316: Added condition in copyToOriginal(cargo_transport and storage_lift_nomination table) to copy forecast back to original only when cargo status='T'.
** 08/11/2017  sharawan         ECPD-50442: Modified copyToOriginal to add missing condition to check on cargo_status of cargo_fcst_transport table.
** 16/11/2017  prashwag         ECPD-50600: Modified copyToOriginal(storage_lift_nomination, stor_sub_day_lift_nom and storage_lift_nom_split tables) to copy back forecast to original only when cargo status is 'T'.
** 01/06/2018  asareswi         ECPD-56285: Modified copyToOriginal, copyFromOriginal, copyFromForecast. Added split_no in them.
** 11/10/2018  thotesan         ECPD-59768: Modified copyFromOriginal, copyFromForecast. removed INSERT statement for fcst_oploc_day_restrict which was causing duplicate insert in table.
** 17/10/2018  baratmah         ECPD-59768: Modified procedure copyToOriginal. Added MERGE statement to copy the restriction data from forecast to original.
** 30/10/2018  prashwag         ECPD-59526: Added generic coloums in cargo_fcst_transport and cargo_fcst_transport.
** 15/11/2018  thotesan         ECPD-59863: Modified copyToOriginal to accomodate flexible status coming from ue for Copy to origional functionality.
********************************************************************/

PROCEDURE createForecast(p_new_forecast_code VARCHAR2
                         , p_start_date DATE
                         , p_end_date DATE
                         , p_storage_id VARCHAR2 DEFAULT NULL
                         , p_new_forecast_id OUT VARCHAR2)
IS

BEGIN
	p_new_forecast_id:= EcDp_objects.GetInsertedObjectID(p_new_forecast_id);

	INSERT INTO FORECAST(object_id, CLASS_NAME, OBJECT_CODE, START_DATE, END_DATE, STORAGE_ID, created_by)
    VALUES(p_new_forecast_id, 'FORECAST_TRAN_CP', p_new_forecast_code, p_start_date, p_end_date, p_storage_id, ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by)
    VALUES(p_new_forecast_id, p_start_date, p_end_date, p_new_forecast_code, ecdp_context.getAppUser);

    -- refresh acl tables if access indicator is turn on
    IF NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('FORECAST_TRAN_CP'),'N') = 'Y' THEN
       ecdp_acl.RefreshObject(p_new_forecast_id, 'FORECAST_TRAN_CP', 'INSERTING');
    END IF;

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
PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2
                           , p_start_date DATE
                           , p_end_date DATE
                           , p_storage_id VARCHAR2 DEFAULT NULL)
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
	SELECT p_new_forecast_id, F.OBJECT_ID, F.PROFIT_CENTRE_ID, F.DAYTIME, NVL(O.GRS_VOL, F.GRS_VOL),
       f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
       f.text_1, f.text_2, f.text_3, f.text_4,
       ecdp_context.getAppUser
	FROM STOR_DAY_PC_FORECAST F,
       (SELECT daytime, object_id, profit_centre_id, sum(grs_vol) grs_vol
          FROM STOR_DAY_PC_CPY_RECEIPT
         WHERE daytime >= p_start_date
           AND daytime < p_end_date
         GROUP BY daytime, object_id, profit_centre_id) O
	WHERE o.object_id (+)= f.object_id
      AND o.profit_centre_id (+)= f.profit_centre_id
      AND o.daytime (+)= f.daytime
      AND f.daytime >= p_start_date
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
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,value_31,value_32,value_33,value_34,value_35,value_36,value_37,value_38,value_39,value_40,value_41,value_42,value_43,value_44,value_45,value_46,value_47,value_48,value_49,value_50,value_51,value_52,value_53,value_54,value_55,date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,date_11,date_12,date_13,date_14,date_15,
    	created_by)
    SELECT p_new_forecast_id, cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,value_31,value_32,value_33,value_34,value_35,value_36,value_37,value_38,value_39,value_40,value_41,value_42,value_43,value_44,value_45,value_46,value_47,value_48,value_49,value_50,value_51,value_52,value_53,value_54,value_55,date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,date_11,date_12,date_13,date_14,date_15,
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
	    start_lifting_date,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,cooldown_ind,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_ind,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
    	created_by)
	SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
	    start_lifting_date,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,cooldown_ind,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_ind,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
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

	INSERT INTO FCST_RECOVERY_FACTOR (forecast_id, object_id, daytime, component_no, class_name, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, 'FCST_RECOVERY_FACTOR', frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM OBJ_EVENT_CP_TRAN_FACTOR o
	WHERE o.daytime >= p_start_date
		AND o.daytime < p_end_date;

	INSERT INTO FCST_OBJ_EVT_DIM1_CP_FAC (forecast_id, object_id, daytime, component_no, class_name, dim1_key, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15, date_1, date_2, date_3, date_4, date_5)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, 'FCST_TRNL_PRD_CP_REC_FAC', dim1_key, frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15, date_1, date_2, date_3, date_4, date_5
	FROM OBJ_EVENT_DIM1_CP_TRAN_FAC o
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

  -- Copy maintenance
	INSERT INTO FCST_OPLOC_PERIOD_RESTR a(a.forecast_id, a.object_id, a.start_date, a.end_date, a.restricted_capacity, a.restriction_type, a.comments,
				a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
				a.text_1, a.text_2, a.text_3, a.text_4, created_by)
			SELECT p_new_forecast_id, r.object_id, r.start_date, r.end_date, r.restricted_capacity, r.restriction_type, r.comments,
				r.value_1, r.value_2, r.value_3, r.value_4, r.value_5, r.value_6, r.value_7, r.value_8, r.value_9, r.value_10,
				r.text_1, r.text_2, r.text_3, r.text_4, ecdp_context.getAppUser
		   FROM OPLOC_PERIOD_RESTRICTION r
		  WHERE r.end_date >= p_start_date
		    AND r.start_date < p_end_date;

	INSERT INTO FCST_OPLOC_DAY_RESTRICT a(a.forecast_id, a.object_id, a.daytime, a.restricted_capacity, a.restriction_type, a.comments,
				a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
				a.text_1, a.text_2, a.text_3, a.text_4, created_by)
			SELECT p_new_forecast_id, r.object_id, r.daytime, r.restricted_capacity, r.restriction_type, r.comments,
				r.value_1, r.value_2, r.value_3, r.value_4, r.value_5, r.value_6, r.value_7, r.value_8, r.value_9, r.value_10,
				r.text_1, r.text_2, r.text_3, r.text_4, ecdp_context.getAppUser
		   FROM OPLOC_DAILY_RESTRICTION r
		  WHERE r.daytime >= p_start_date
		    AND r.daytime < p_end_date;

    INSERT INTO FCST_STOR_LIFT_CPY_SPLIT (forecast_id,parcel_no,company_id,lifting_account_id,split_no,split_pct,comments,
		        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,
		        text_11,text_12,text_13,text_14,text_15,
		        value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,
                value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,
                value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,
		        date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,
                created_by)
	     SELECT p_new_forecast_id,n.parcel_no,n.company_id,n.lifting_account_id,n.split_no,n.split_pct,n.comments,
		        n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,
		        n.text_11,n.text_12,n.text_13,n.text_14,n.text_15,
		        n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8,n.value_9,n.value_10,
                n.value_11,n.value_12,n.value_13,n.value_14,n.value_15,n.value_16,n.value_17,n.value_18,n.value_19,n.value_20,
                n.value_21,n.value_22,n.value_23,n.value_24,n.value_25,n.value_26,n.value_27,n.value_28,n.value_29,n.value_30,
		        n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.date_8,n.date_9,n.date_10,
		        ecdp_context.getAppUser
	       FROM STORAGE_LIFT_NOM_SPLIT n
	      WHERE parcel_no IN (SELECT parcel_no FROM storage_lift_nomination n
		                       WHERE n.nom_firm_date >= p_start_date
		                         AND n.nom_firm_date < p_end_date
		                         AND n.object_id = nvl(p_storage_id, n.object_id));
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
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2
                           , p_new_forecast_code VARCHAR2
                           , p_start_date DATE
                           , p_end_date DATE
                           , p_storage_id VARCHAR2 DEFAULT NULL)
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
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,value_31,value_32,value_33,value_34,value_35,value_36,value_37,value_38,value_39,value_40,value_41,value_42,value_43,value_44,value_45,value_46,value_47,value_48,value_49,value_50,value_51,value_52,value_53,value_54,value_55,date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,date_11,date_12,date_13,date_14,date_15,
    	created_by)
    SELECT p_new_forecast_id, cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,value_31,value_32,value_33,value_34,value_35,value_36,value_37,value_38,value_39,value_40,value_41,value_42,value_43,value_44,value_45,value_46,value_47,value_48,value_49,value_50,value_51,value_52,value_53,value_54,value_55,date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,date_11,date_12,date_13,date_14,date_15,
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
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,cooldown_ind,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_ind,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
    	created_by, start_lifting_date, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3)
	SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,
	    lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,cooldown_ind,
	    cooldown_qty,cooldown_qty2,cooldown_qty3,purge_ind,purge_qty,purge_qty2,purge_qty3,vapour_return_qty,vapour_return_qty2,vapour_return_qty3,lauf_qty,lauf_qty2,lauf_qty3,balance_delta_qty,balance_delta_qty2,balance_delta_qty3,
		text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,text_16,text_17,text_18,text_19,text_20,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
		ecdp_context.getAppUser, start_lifting_date, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3
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

	INSERT INTO FCST_RECOVERY_FACTOR (forecast_id, object_id, daytime, component_no, class_name, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, class_name, frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, text_1, text_2, text_3, text_4
	FROM FCST_RECOVERY_FACTOR o
	WHERE o.forecast_id = p_forecast_id
    AND o.daytime >= p_start_date
		AND o.daytime < p_end_date;

	INSERT INTO FCST_OBJ_EVT_DIM1_CP_FAC (forecast_id, object_id, daytime, component_no, class_name, dim1_key, frac, created_by,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15, date_1, date_2, date_3, date_4, date_5)
	SELECT p_new_forecast_id, o.object_id, daytime, component_no, class_name, dim1_key, frac, ecdp_context.getAppUser,value_1,value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12, text_13, text_14, text_15, date_1, date_2, date_3, date_4, date_5
	FROM FCST_OBJ_EVT_DIM1_CP_FAC o
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

	-- Copy maintenance
	INSERT INTO fcst_oploc_period_restr a(a.forecast_id, a.object_id, a.start_date, a.end_date, a.restricted_capacity, a.restriction_type, a.comments,
				a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
				a.text_1, a.text_2, a.text_3, a.text_4, created_by)
			SELECT p_new_forecast_id, r.object_id, r.start_date, r.end_date, r.restricted_capacity, r.restriction_type, r.comments,
				r.value_1, r.value_2, r.value_3, r.value_4, r.value_5, r.value_6, r.value_7, r.value_8, r.value_9, r.value_10,
				r.text_1, r.text_2, r.text_3, r.text_4, ecdp_context.getAppUser
		   FROM fcst_oploc_period_restr r
		  WHERE r.forecast_id = p_forecast_id
		    AND r.end_date >= p_start_date
		    AND r.start_date < p_end_date;

	INSERT INTO fcst_oploc_day_restrict a(a.forecast_id, a.object_id, a.daytime, a.restricted_capacity, a.restriction_type, a.comments,
				a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,
				a.text_1, a.text_2, a.text_3, a.text_4, created_by)
			SELECT p_new_forecast_id, r.object_id, r.daytime, r.restricted_capacity, r.restriction_type, r.comments,
				r.value_1, r.value_2, r.value_3, r.value_4, r.value_5, r.value_6, r.value_7, r.value_8, r.value_9, r.value_10,
				r.text_1, r.text_2, r.text_3, r.text_4, ecdp_context.getAppUser
		   FROM fcst_oploc_day_restrict r
		  WHERE r.forecast_id = p_forecast_id
		    AND r.daytime >= p_start_date
		    AND r.daytime < p_end_date;

	INSERT INTO FCST_STOR_LIFT_CPY_SPLIT (forecast_id,parcel_no,company_id,lifting_account_id,split_pct,split_no,comments,
		        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,
		        value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,
		        value_11,value_12,value_13,value_14,value_15,value_16,value_17,value_18,value_19,value_20,
		        value_21,value_22,value_23,value_24,value_25,value_26,value_27,value_28,value_29,value_30,
		        date_1,date_2,date_3,date_4,date_5,date_6,date_7,date_8,date_9,date_10,
    	        created_by)
	     SELECT p_new_forecast_id,n.parcel_no,n.company_id,n.lifting_account_id,n.split_pct,n.split_no,n.comments,
		        n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,n.text_11,n.text_12,n.text_13,n.text_14,n.text_15,
		        n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8,n.value_9,n.value_10,
		        n.value_11,n.value_12,n.value_13,n.value_14,n.value_15,n.value_16,n.value_17,n.value_18,n.value_19,n.value_20,
		        n.value_21,n.value_22,n.value_23,n.value_24,n.value_25,n.value_26,n.value_27,n.value_28,n.value_29,n.value_30,
		        n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.date_8,n.date_9,n.date_10,
		        ecdp_context.getAppUser
	       FROM FCST_STOR_LIFT_CPY_SPLIT n
	      WHERE n.forecast_id = p_forecast_id
            AND parcel_no IN (SELECT parcel_no FROM stor_fcst_lift_nom s
                               WHERE s.forecast_id = p_forecast_id
							     AND s.nom_firm_date >= p_start_date
							     AND s.nom_firm_date < p_end_date
							     AND s.object_id = nvl(p_storage_id, s.object_id));
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
			a.text_1, a.text_2, a.text_3, a.text_4, a.rev_no
		FROM stor_day_fcst_fcast a,
		     forecast c
		WHERE a.forecast_id = p_forecast_id
		      AND a.forecast_id = c.object_id
		      AND a.daytime >= c.start_date
		      AND a.daytime < c.end_date
		      AND Nvl(c.storage_id, a.object_id) = a.object_id ) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
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
			a.text_1, a.text_2, a.text_3, a.text_4, a.rev_no
		FROM stor_sub_day_fcst_fcast a,
		     forecast c
		WHERE a.forecast_id = p_forecast_id
		      AND a.forecast_id = c.object_id
		      AND a.production_day >= c.start_date
		      AND a.production_day < c.end_date
		      AND Nvl(c.storage_id, a.object_id) = a.object_id ) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.summer_time = f.summer_time)
	WHEN MATCHED THEN
		UPDATE SET o.forecast_qty  = f.forecast_qty, o.forecast_qty2 = f.forecast_qty2, o.forecast_qty3 = f.forecast_qty3, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3, o.production_day, o.summer_time,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- STOR_MTH_PC_FORECAST
	MERGE INTO stor_mth_pc_forecast o
	USING (SELECT f.object_id, f.daytime, f.profit_centre_id, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, f.rev_no
		FROM stor_mth_fcst_pc_fcast f,
		     forecast c
		WHERE f.forecast_id = p_forecast_id
		      AND f.forecast_id = c.object_id
		      AND f.daytime >= c.start_date
		      AND f.daytime < c.end_date
		      AND Nvl(c.storage_id, f.object_id) = f.object_id ) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.profit_centre_id = f.profit_centre_id)
	WHEN MATCHED THEN
		UPDATE SET o.GRS_VOL  = f.forecast_qty, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.profit_centre_id, o.daytime, o.GRS_VOL,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.profit_centre_id, f.daytime, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- STOR_DAY_PC_FORECAST
	MERGE INTO stor_day_pc_forecast o
	USING (SELECT f.object_id, f.daytime, f.profit_centre_id, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, f.rev_no
		FROM stor_day_fcst_pc_fcast f,
		     forecast c
		WHERE f.forecast_id = p_forecast_id
		      AND f.forecast_id = c.object_id
		      AND f.daytime >= c.start_date
		      AND f.daytime < c.end_date
		      AND Nvl(c.storage_id, f.object_id) = f.object_id ) f
	ON (o.object_id = f.object_id AND o.daytime = f.daytime AND o.profit_centre_id = f.profit_centre_id)
	WHEN MATCHED THEN
		UPDATE SET o.GRS_VOL  = f.forecast_qty, o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.profit_centre_id, o.daytime, o.GRS_VOL,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.profit_centre_id, f.daytime, f.forecast_qty, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- lift account forecast
	MERGE INTO 	lift_acc_day_forecast o
	USING (SELECT l.object_id, l.daytime, l.forecast_qty, l.forecast_qty2, l.forecast_qty3,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4, l.rev_no
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
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);


		-- lift_acc_sub_day_forecast
	MERGE INTO 	lift_acc_sub_day_forecast o
	USING (SELECT l.object_id, l.daytime, l.forecast_qty, l.forecast_qty2, l.forecast_qty3, l.production_day, l.summer_time,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4, l.rev_no
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
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.forecast_qty, o.forecast_qty2, o.forecast_qty3, o.production_day, o.summer_time,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.daytime, f.forecast_qty, f.forecast_qty2, f.forecast_qty3, f.production_day, f.summer_time, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	-- cargo transport
	MERGE INTO cargo_transport o
	USING (SELECT t.cargo_no, t.cargo_name, t.carrier_id, t.agent, t.surveyor, t.laytime,
	nvl(co.est_arrival, t.EST_ARRIVAL) est_arrival,
	nvl(co.est_departure, t.EST_DEPARTURE) est_departure,
	t.CARGO_STATUS,t.PROD_FCTY_ID,t.MASTER,t.PILOT,t.TUGS_ARR,t.TUGS_DEP,t.DRAUGHT_MARK_ARR_AFT,t.DRAUGHT_MARK_ARR_CENTER,t.DRAUGHT_MARK_ARR_FORWARD,t.DRAUGHT_MARK_DEP_AFT,t.DRAUGHT_MARK_DEP_CENTER,t.DRAUGHT_MARK_DEP_FORWARD,t.VOYAGE_NO,t.BERTH_ID,
		    t.text_1,t.text_2,t.text_3,t.text_4,t.text_5,t.text_6,t.text_7,t.text_8,t.text_9,t.text_10,t.text_11,t.text_12,t.text_13,t.text_14,t.text_15,t.text_16,t.text_17,t.text_18,t.text_19,t.text_20,t.value_1,t.value_2,t.value_3,t.value_4,t.value_5,t.value_6,t.value_7,t.value_8,t.value_9,t.value_10,t.value_11,t.value_12,t.value_13,t.value_14,t.value_15,t.value_16,t.value_17,t.value_18,t.value_19,t.value_20,t.value_21,t.value_22,t.value_23,t.value_24,t.value_25,t.value_26,t.value_27,t.value_28,t.value_29,t.value_30,t.value_31,t.value_32,t.value_33,t.value_34,t.value_35,t.value_36,t.value_37,t.value_38,t.value_39,t.value_40,t.value_41,t.value_42,t.value_43,t.value_44,t.value_45,t.value_46,t.value_47,t.value_48,t.value_49,t.value_50,t.value_51,t.value_52,t.value_53,t.value_54,t.value_55,t.date_1,t.date_2,t.date_3,t.date_4,t.date_5,t.date_6,t.date_7,t.date_8,t.date_9,t.date_10,t.date_11,t.date_12,t.date_13,t.date_14,t.date_15,t.rev_no
		FROM cargo_fcst_transport t,
		     forecast c,
			 cargo_transport co
		WHERE t.forecast_id = p_forecast_id
		      AND co.cargo_no(+) = t.cargo_no
		      AND t.forecast_id = c.object_id
			  AND ue_forecast_cargo_planning.includeInCopy(t.forecast_id,t.cargo_no,NULL,co.cargo_status,t.cargo_status)='Y'
		      AND t.cargo_no in (select cargo_no
		              FROM  stor_fcst_lift_nom n
		              WHERE n.forecast_id = c.object_id
		                    AND n.nom_firm_date >= c.start_date
		                    AND n.nom_firm_date < c.end_date
		                    AND n.object_id = nvl(c.storage_id, n.object_id)))f
	ON (o.cargo_no = f.cargo_no)
	WHEN MATCHED THEN
		UPDATE SET o.cargo_name = f.cargo_name, o.carrier_id = f.carrier_id, o.agent = f.agent, o.surveyor = f.surveyor, o.laytime = f.laytime,
		o.EST_ARRIVAL = f.EST_ARRIVAL,o.EST_DEPARTURE = f.EST_DEPARTURE,
		o.PROD_FCTY_ID = f.PROD_FCTY_ID,o.MASTER = f.MASTER,o.PILOT = f.PILOT,o.TUGS_ARR = f.TUGS_ARR,o.TUGS_DEP = f.TUGS_DEP,o.DRAUGHT_MARK_ARR_AFT = f.DRAUGHT_MARK_ARR_AFT,o.DRAUGHT_MARK_ARR_CENTER = f.DRAUGHT_MARK_ARR_CENTER,o.DRAUGHT_MARK_ARR_FORWARD = f.DRAUGHT_MARK_ARR_FORWARD,o.DRAUGHT_MARK_DEP_AFT = f.DRAUGHT_MARK_DEP_AFT,o.DRAUGHT_MARK_DEP_CENTER = f.DRAUGHT_MARK_DEP_CENTER,o.DRAUGHT_MARK_DEP_FORWARD = f.DRAUGHT_MARK_DEP_FORWARD,o.VOYAGE_NO = f.VOYAGE_NO,o.BERTH_ID = f.BERTH_ID,o.CARGO_STATUS=f.CARGO_STATUS,
		o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,o.value_11 = f.value_11, o.value_12 = f.value_12, o.value_13 = f.value_13, o.value_14 = f.value_14, o.value_15 = f.value_15, o.value_16 = f.value_16, o.value_17 = f.value_17, o.value_18 = f.value_18, o.value_19 = f.value_19, o.value_20 = f.value_20,o.value_21 = f.value_21, o.value_22 = f.value_22, o.value_23 = f.value_23, o.value_24 = f.value_24, o.value_25 = f.value_25, o.value_26 = f.value_26, o.value_27 = f.value_27, o.value_28 = f.value_28, o.value_29 = f.value_29, o.value_30 = f.value_30,o.value_31 = f.value_31, o.value_32 = f.value_32, o.value_33 = f.value_33, o.value_34 = f.value_34, o.value_35 = f.value_35, o.value_36 = f.value_36, o.value_37 = f.value_37, o.value_38 = f.value_38, o.value_39 = f.value_39, o.value_40 = f.value_40,o.value_41 = f.value_41, o.value_42 = f.value_42, o.value_43 = f.value_43, o.value_44 = f.value_44, o.value_45 = f.value_45, o.value_46 = f.value_46, o.value_47 = f.value_47, o.value_48 = f.value_48, o.value_49 = f.value_49, o.value_50 = f.value_50,o.value_51 = f.value_51, o.value_52 = f.value_52, o.value_53 = f.value_53, o.value_54 = f.value_54, o.value_55 = f.value_55,
		o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4,o.text_5 = f.text_5, o.text_6 = f.text_6,
		o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10,o.text_11 = f.text_11, o.text_12 = f.text_12,
		o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15, o.text_16 = f.text_16,o.text_17 = f.text_17, o.text_18 = f.text_18,o.text_19 = f.text_19, o.text_20 = f.text_20,o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3, o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 =f.date_7,o.date_8 = f.date_8, o.date_9 =f.date_9, o.date_10 = f.date_10, o.date_11 = f.date_11, o.date_12 = f.date_12,o.date_13 = f.date_13,o.date_14 =f.date_14,o.date_15 =f.date_15,last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.cargo_no, o.cargo_name, o.carrier_id, o.agent, o.surveyor, o.laytime,o.EST_ARRIVAL,o.EST_DEPARTURE,o.CARGO_STATUS,o.PROD_FCTY_ID,o.MASTER,o.PILOT,o.TUGS_ARR,o.TUGS_DEP,o.DRAUGHT_MARK_ARR_AFT,o.DRAUGHT_MARK_ARR_CENTER,o.DRAUGHT_MARK_ARR_FORWARD,o.DRAUGHT_MARK_DEP_AFT,o.DRAUGHT_MARK_DEP_CENTER,o.DRAUGHT_MARK_DEP_FORWARD,o.VOYAGE_NO,o.BERTH_ID,
		    o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10,o.text_11,o.text_12,o.text_13,o.text_14,o.text_15,o.text_16,o.text_17,o.text_18,o.text_19,o.text_20,o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,o.value_11,o.value_12,o.value_13,o.value_14,o.value_15,o.value_16,o.value_17,o.value_18,o.value_19,o.value_20,o.value_21,o.value_22,o.value_23,o.value_24,o.value_25,o.value_26,o.value_27,o.value_28,o.value_29,o.value_30,o.value_31,o.value_32,o.value_33,o.value_34,o.value_35,o.value_36,o.value_37,o.value_38,o.value_39,o.value_40,o.value_41,o.value_42,o.value_43,o.value_44,o.value_45,o.value_46,o.value_47,o.value_48,o.value_49,o.value_50,o.value_51,o.value_52,o.value_53,o.value_54,o.value_55,o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,o.date_6,o.date_7,o.date_8,o.date_9,o.date_10,o.date_11,o.date_12,o.date_13,o.date_14,o.date_15,created_by)
		VALUES (f.cargo_no, f.cargo_name, f.carrier_id, f.agent, f.surveyor, f.laytime,f.EST_ARRIVAL,f.EST_DEPARTURE,f.CARGO_STATUS,f.PROD_FCTY_ID,f.MASTER,f.PILOT,f.TUGS_ARR,f.TUGS_DEP,f.DRAUGHT_MARK_ARR_AFT,f.DRAUGHT_MARK_ARR_CENTER,f.DRAUGHT_MARK_ARR_FORWARD,f.DRAUGHT_MARK_DEP_AFT,f.DRAUGHT_MARK_DEP_CENTER,f.DRAUGHT_MARK_DEP_FORWARD,f.VOYAGE_NO,f.BERTH_ID,
		    f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10,f.text_11,f.text_12,f.text_13,f.text_14,f.text_15,f.text_16,f.text_17,f.text_18,f.text_19,f.text_20,f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,f.value_11,f.value_12,f.value_13,f.value_14,f.value_15,f.value_16,f.value_17,f.value_18,f.value_19,f.value_20,f.value_21,f.value_22,f.value_23,f.value_24,f.value_25,f.value_26,f.value_27,f.value_28,f.value_29,f.value_30,f.value_31,f.value_32,f.value_33,f.value_34,f.value_35,f.value_36,f.value_37,f.value_38,f.value_39,f.value_40,f.value_41,f.value_42,f.value_43,f.value_44,f.value_45,f.value_46,f.value_47,f.value_48,f.value_49,f.value_50,f.value_51,f.value_52,f.value_53,f.value_54,f.value_55,f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,f.date_6,f.date_7,f.date_8,f.date_9,f.date_10,f.date_11,f.date_12,f.date_13,f.date_14,f.date_15,ecdp_context.getAppUser);

	-- delete nominations
	FOR curDelNom IN c_del_nom(p_forecast_id) LOOP
		DELETE storage_lifting WHERE parcel_no = curDelNom.parcel_no;
		DELETE lift_doc_instruction WHERE parcel_no = curDelNom.parcel_no;
		DELETE lifting_doc_receiver WHERE parcel_no = curDelNom.parcel_no;
		DELETE lifting_doc_set WHERE parcel_no = curDelNom.parcel_no;
		DELETE storage_lift_nom_split WHERE parcel_no = curDelNom.parcel_no;
		DELETE storage_lift_nomination WHERE parcel_no = curDelNom.parcel_no;
	END LOOP;

	--insert update nominations
	MERGE INTO storage_lift_nomination o
	USING (SELECT n.parcel_no,n.object_id,n.cargo_no,n.lifting_account_id,n.carrier_id,n.consignor_id,n.consignee_id,n.requested_date,n.requested_date_range,n.requested_tolerance_type,n.grs_vol_requested,n.nom_firm_date,n.nom_firm_date_range,n.nom_sequence,n.grs_vol_nominated,
			n.lifting_split_pct,n.lifting_split_vol,n.lifting_code,n.incoterm,n.contract_id,n.telex_ref,n.graph_value,n.balance_ind,n.grs_vol_schedule,n.schedule_tolerance_type,n.bl_number,n.port_id,n.doc_instr_received_ind,n.fixed_ind,n.bol_comments,n.charter_party,n.comments,
			n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,n.text_11,n.text_12,n.text_13,n.text_14,n.text_15,n.text_16,n.text_17,n.text_18,n.text_19,n.text_20,
			n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8,n.value_9,n.value_10,n.value_11,n.value_12,n.value_13,n.value_14,n.value_15,n.value_16,n.value_17,n.value_18,n.value_19,n.value_20,n.value_21,n.value_22,n.value_23,n.value_24,n.value_25,n.value_26,n.value_27,n.value_28,n.value_29,n.value_30,
			n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.grs_vol_scheduled2, n.grs_vol_requested2, n.grs_vol_nominated2, n.grs_vol_scheduled3, n.grs_vol_requested3, n.grs_vol_nominated3, n.start_lifting_date,n.cooldown_ind,
	        n.cooldown_qty,n.cooldown_qty2,n.cooldown_qty3,n.purge_ind,n.purge_qty,n.purge_qty2,n.purge_qty3,n.vapour_return_qty,n.vapour_return_qty2,n.vapour_return_qty3,n.lauf_qty,n.lauf_qty2,n.lauf_qty3,n.balance_delta_qty,n.balance_delta_qty2,n.balance_delta_qty3,
			n.ref_object_id_1,n.ref_object_id_2,n.ref_object_id_3,n.ref_object_id_4,n.ref_object_id_5,n.rev_no
		FROM  stor_fcst_lift_nom n,
		     forecast c,
			 cargo_transport co,
			 cargo_fcst_transport t
		WHERE t.forecast_id = n.forecast_id
			AND n.cargo_no = t.cargo_no
			AND n.forecast_id = p_forecast_id
			AND n.forecast_id = c.object_id
		    AND co.cargo_no (+) = n.cargo_no
			AND ue_forecast_cargo_planning.includeInCopy(n.forecast_id,n.cargo_no,n.parcel_no,co.cargo_status,t.cargo_status)='Y'
			AND Nvl(n.DELETED_IND, 'N') <> 'Y'
			AND n.nom_firm_date >= c.start_date
		    AND n.nom_firm_date < c.end_date
		    AND n.object_id = nvl(c.storage_id, n.object_id))f
	ON (o.parcel_no = f.parcel_no)
	WHEN MATCHED THEN
		UPDATE SET o.object_id = f.object_id,o.cargo_no = f.cargo_no,o.lifting_account_id = f.lifting_account_id,o.carrier_id = f.carrier_id,o.consignor_id = f.consignor_id,o.consignee_id = f.consignee_id,o.requested_date = f.requested_date,o.requested_date_range = f.requested_date_range,o.requested_tolerance_type = f.requested_tolerance_type,o.grs_vol_requested = f.grs_vol_requested,o.nom_firm_date = f.nom_firm_date,o.nom_firm_date_range = f.nom_firm_date_range,o.nom_sequence = f.nom_sequence,o.grs_vol_nominated = f.grs_vol_nominated,
			o.lifting_split_pct = f.lifting_split_pct,o.lifting_split_vol = f.lifting_split_vol,o.lifting_code = f.lifting_code,o.incoterm = f.incoterm,o.contract_id = f.contract_id,o.telex_ref = f.telex_ref,o.graph_value = f.graph_value,o.balance_ind = f.balance_ind,o.grs_vol_schedule = f.grs_vol_schedule,o.schedule_tolerance_type = f.schedule_tolerance_type,o.bl_number = f.bl_number,o.port_id = f.port_id,o.doc_instr_received_ind = f.doc_instr_received_ind,o.fixed_ind = f.fixed_ind,o.charter_party = f.charter_party,o.comments = f.comments,
			o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,o.value_11 = f.value_11, o.value_12 = f.value_12, o.value_13 = f.value_13, o.value_14 = f.value_14, o.value_15 = f.value_15, o.value_16 = f.value_16, o.value_17 = f.value_17, o.value_18 = f.value_18, o.value_19 = f.value_19, o.value_20 = f.value_20,o.value_21 = f.value_21, o.value_22 = f.value_22, o.value_23 = f.value_23, o.value_24 = f.value_24, o.value_25 = f.value_25, o.value_26 = f.value_26, o.value_27 = f.value_27, o.value_28 = f.value_28, o.value_29 = f.value_29, o.value_30 = f.value_30,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5, o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10,
			o.text_11 = f.text_11, o.text_12 = f.text_12, o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15, o.text_16 = f.text_16, o.text_17 = f.text_17, o.text_18 = f.text_18, o.text_19 = f.text_19, o.text_20 = f.text_20,
			o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3, o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 = f.date_7, o.grs_vol_scheduled2 = f.grs_vol_scheduled2, o.grs_vol_requested2 = f.grs_vol_requested2, o.grs_vol_nominated2 = f.grs_vol_nominated2, o.grs_vol_scheduled3 = f.grs_vol_scheduled3, o.grs_vol_requested3 = f.grs_vol_requested3, o.grs_vol_nominated3 = f.grs_vol_nominated3, o.start_lifting_date = f.start_lifting_date,o.cooldown_ind=f.cooldown_ind,
	        o.cooldown_qty = f.cooldown_qty, o.cooldown_qty2 = f.cooldown_qty2,o.cooldown_qty3 = f.cooldown_qty3,o.purge_ind=f.purge_ind,o.purge_qty = f.purge_qty,o.purge_qty2 = f.purge_qty2,o.purge_qty3 = f.purge_qty3,o.vapour_return_qty = f.vapour_return_qty,o.vapour_return_qty2 = f.vapour_return_qty2,o.vapour_return_qty3 = f.vapour_return_qty3,o.lauf_qty = f.lauf_qty,o.lauf_qty2 = f.lauf_qty2,o.lauf_qty3 = f.lauf_qty3,o.balance_delta_qty = f.balance_delta_qty,o.balance_delta_qty2 = f.balance_delta_qty2,o.balance_delta_qty3 = f.balance_delta_qty3,
			o.ref_object_id_1 = f.ref_object_id_1,o.ref_object_id_2 = f.ref_object_id_2,o.ref_object_id_3 = f.ref_object_id_3,o.ref_object_id_4 = f.ref_object_id_4,o.ref_object_id_5 = f.ref_object_id_5, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.parcel_no,o.object_id,o.cargo_no,o.lifting_account_id,o.carrier_id,o.consignor_id,o.consignee_id,o.requested_date,o.requested_date_range,o.requested_tolerance_type,o.grs_vol_requested,o.nom_firm_date,o.nom_firm_date_range,o.nom_sequence,o.grs_vol_nominated,o.lifting_split_pct,o.lifting_split_vol,o.lifting_code,o.incoterm,o.contract_id,o.telex_ref,o.graph_value,o.balance_ind,o.grs_vol_schedule,o.schedule_tolerance_type,o.bl_number,o.port_id,o.doc_instr_received_ind,o.fixed_ind,o.charter_party,o.comments,
			o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10, o.text_11,o.text_12,o.text_13,o.text_14,o.text_15,o.text_16,o.text_17,o.text_18,o.text_19,o.text_20,
			o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,o.value_11,o.value_12,o.value_13,o.value_14,o.value_15,o.value_16,o.value_17,o.value_18,o.value_19,o.value_20,o.value_21,o.value_22,o.value_23,o.value_24,o.value_25,o.value_26,o.value_27,o.value_28,o.value_29,o.value_30,
			o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,o.date_6,o.date_7, o.grs_vol_scheduled2, o.grs_vol_requested2, o.grs_vol_nominated2, o.grs_vol_scheduled3, o.grs_vol_requested3, o.grs_vol_nominated3, o.start_lifting_date,o.cooldown_ind,
	        o.cooldown_qty,o.cooldown_qty2,o.cooldown_qty3,o.purge_ind,o.purge_qty,o.purge_qty2,o.purge_qty3,o.vapour_return_qty,o.vapour_return_qty2,o.vapour_return_qty3,o.lauf_qty,o.lauf_qty2,o.lauf_qty3,o.balance_delta_qty,o.balance_delta_qty2,o.balance_delta_qty3,
			o.ref_object_id_1,o.ref_object_id_2,o.ref_object_id_3,o.ref_object_id_4,o.ref_object_id_5, o.created_by)
		VALUES (f.parcel_no,f.object_id,f.cargo_no,f.lifting_account_id,f.carrier_id,f.consignor_id,f.consignee_id,f.requested_date,f.requested_date_range,f.requested_tolerance_type,f.grs_vol_requested,f.nom_firm_date,f.nom_firm_date_range,f.nom_sequence,f.grs_vol_nominated,f.lifting_split_pct,f.lifting_split_vol,f.lifting_code,f.incoterm,f.contract_id,f.telex_ref,f.graph_value,f.balance_ind,f.grs_vol_schedule,f.schedule_tolerance_type,f.bl_number,f.port_id,f.doc_instr_received_ind,f.fixed_ind,f.charter_party,f.comments,
			f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10, f.text_11,f.text_12,f.text_13,f.text_14,f.text_15,f.text_16,f.text_17,f.text_18,f.text_19,f.text_20,
			f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,f.value_11,f.value_12,f.value_13,f.value_14,f.value_15,f.value_16,f.value_17,f.value_18,f.value_19,f.value_20,f.value_21,f.value_22,f.value_23,f.value_24,f.value_25,f.value_26,f.value_27,f.value_28,f.value_29,f.value_30,
			f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,f.date_6,f.date_7, f.grs_vol_scheduled2, f.grs_vol_requested2, f.grs_vol_nominated2, f.grs_vol_scheduled3, f.grs_vol_requested3, f.grs_vol_nominated3, f.start_lifting_date,f.cooldown_ind,
	        f.cooldown_qty,f.cooldown_qty2,f.cooldown_qty3,f.purge_ind,f.purge_qty,f.purge_qty2,f.purge_qty3,f.vapour_return_qty,f.vapour_return_qty2,f.vapour_return_qty3,f.lauf_qty,f.lauf_qty2,f.lauf_qty3,f.balance_delta_qty,f.balance_delta_qty2,f.balance_delta_qty3,
			f.ref_object_id_1,f.ref_object_id_2,f.ref_object_id_3,f.ref_object_id_4,f.ref_object_id_5,ecdp_context.getAppUser);


	MERGE INTO stor_sub_day_lift_nom o
	USING (SELECT ns.forecast_id,ns.parcel_no,ns.object_id,ns.daytime,ns.summer_time,ns.production_day,ns.grs_vol_requested,ns.grs_vol_nominated,ns.grs_vol_schedule,ns.grs_vol_requested2,ns.grs_vol_nominated2,ns.grs_vol_scheduled2,ns.grs_vol_requested3,ns.grs_vol_nominated3,ns.grs_vol_scheduled3,
                ns.cooldown_qty,ns.cooldown_qty2,ns.cooldown_qty3,ns.purge_qty,ns.purge_qty2,ns.purge_qty3,ns.vapour_return_qty,ns.vapour_return_qty2,ns.vapour_return_qty3,ns.lauf_qty,ns.lauf_qty2,ns.lauf_qty3,ns.balance_delta_qty,ns.balance_delta_qty2,ns.balance_delta_qty3,
                ns.text_1,ns.text_2,ns.text_3,ns.text_4,ns.text_5,ns.text_6,ns.text_7,ns.text_8,ns.text_9,ns.text_10,ns.text_11,ns.text_12,ns.text_13,ns.text_14,ns.text_15,ns.value_1,ns.value_2,ns.value_3,ns.value_4,ns.value_5,ns.value_6,ns.value_7,ns.value_8,ns.value_9,ns.value_10,ns.date_1,ns.date_2,ns.date_3,ns.date_4,ns.date_5, ns.rev_no
          FROM  stor_fcst_sub_day_lift_nom ns,
                forecast c
          WHERE ns.forecast_id = p_forecast_id
            AND ns.forecast_id = c.object_id
            AND ns.parcel_no IN
                 (select parcel_no
                    FROM  stor_fcst_lift_nom n,
						  cargo_fcst_transport t,
                          cargo_transport co
                    WHERE t.forecast_id = n.forecast_id
                    AND n.cargo_no = t.cargo_no
                    AND n.forecast_id = p_forecast_id
                    AND co.cargo_no (+) = n.cargo_no
					AND n.forecast_id = c.object_id
					AND ue_forecast_cargo_planning.includeInCopy(n.forecast_id,n.cargo_no,n.parcel_no,co.cargo_status,t.cargo_status)='Y'
                    AND n.nom_firm_date >= c.start_date
                    AND n.nom_firm_date < c.end_date
                    AND n.object_id = nvl(c.storage_id, n.object_id))
         UNION
         -- Combine with records that has been deleted in Forecast
         SELECT NULL as forecast_id,k.parcel_no,k.object_id,k.daytime,k.summer_time,k.production_day,k.grs_vol_requested,k.grs_vol_nominated,k.grs_vol_schedule,k.grs_vol_requested2,k.grs_vol_nominated2,k.grs_vol_scheduled2,k.grs_vol_requested3,k.grs_vol_nominated3,k.grs_vol_scheduled3,
                k.cooldown_qty,k.cooldown_qty2,k.cooldown_qty3,k.purge_qty,k.purge_qty2,k.purge_qty3,k.vapour_return_qty,k.vapour_return_qty2,k.vapour_return_qty3,k.lauf_qty,k.lauf_qty2,k.lauf_qty3,k.balance_delta_qty,k.balance_delta_qty2,k.balance_delta_qty3,
                k.text_1,k.text_2,k.text_3,k.text_4,k.text_5,k.text_6,k.text_7,k.text_8,k.text_9,k.text_10,k.text_11,k.text_12,k.text_13,k.text_14,k.text_15,k.value_1,k.value_2,k.value_3,k.value_4,k.value_5,k.value_6,k.value_7,k.value_8,k.value_9,k.value_10,k.date_1,k.date_2,k.date_3,k.date_4,k.date_5, k.rev_no
           FROM stor_sub_day_lift_nom k
          WHERE k.parcel_no IN
                  (SELECT parcel_no
                     FROM stor_fcst_lift_nom n,
						  cargo_fcst_transport t,
                          cargo_transport co
                    WHERE t.forecast_id = n.forecast_id
                    AND n.cargo_no = t.cargo_no
                    AND n.forecast_id = p_forecast_id
                    AND co.cargo_no (+) = n.cargo_no
                    AND ue_forecast_cargo_planning.includeInCopy(n.forecast_id,n.cargo_no,n.parcel_no,co.cargo_status,t.cargo_status)='Y')
                      AND NOT EXISTS (SELECT *
                                        FROM stor_fcst_sub_day_lift_nom sc
                                       WHERE sc.forecast_id = p_forecast_id
                                         AND k.parcel_no = sc.parcel_no
                                         AND k.daytime = sc.daytime))f
	ON (o.parcel_no = f.parcel_no AND o.daytime = f.daytime AND o.summer_time = f.summer_time)
	WHEN MATCHED THEN
		UPDATE SET o.object_id = f.object_id,o.production_day = f.production_day, o.grs_vol_requested = f.grs_vol_requested,o.grs_vol_nominated = f.grs_vol_nominated,o.grs_vol_schedule = f.grs_vol_schedule,
	        o.grs_vol_requested2 = f.grs_vol_requested2,o.grs_vol_nominated2 = f.grs_vol_nominated2,o.grs_vol_scheduled2 = f.grs_vol_scheduled2,o.grs_vol_nominated3 = f.grs_vol_nominated3, o.grs_vol_scheduled3 = f.grs_vol_scheduled3,
	        o.cooldown_qty = f.cooldown_qty, o.cooldown_qty2 = f.cooldown_qty2,o.cooldown_qty3 = f.cooldown_qty3,o.purge_qty = f.purge_qty,o.purge_qty2 = f.purge_qty2,o.purge_qty3 = f.purge_qty3,o.vapour_return_qty = f.vapour_return_qty,o.vapour_return_qty2 = f.vapour_return_qty2,o.vapour_return_qty3 = f.vapour_return_qty3,o.lauf_qty = f.lauf_qty,o.lauf_qty2 = f.lauf_qty2,o.lauf_qty3 = f.lauf_qty3,o.balance_delta_qty = f.balance_delta_qty,o.balance_delta_qty2 = f.balance_delta_qty2,o.balance_delta_qty3 = f.balance_delta_qty3,
			o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5, o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10, o.text_11 = f.text_11, o.text_12 = f.text_12, o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15,
			o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3, o.date_4 = f.date_4, o.date_5 = f.date_5,
			last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
  DELETE WHERE f.forecast_id IS NULL
	WHEN NOT MATCHED THEN
	INSERT (o.parcel_no,o.object_id,o.daytime,o.summer_time,o.production_day,o.grs_vol_requested,o.grs_vol_nominated,o.grs_vol_schedule,o.grs_vol_requested2,o.grs_vol_nominated2,o.grs_vol_scheduled2,o.grs_vol_requested3,o.grs_vol_nominated3,o.grs_vol_scheduled3,
	    o.cooldown_qty,o.cooldown_qty2,o.cooldown_qty3,o.purge_qty,o.purge_qty2,o.purge_qty3,o.vapour_return_qty,o.vapour_return_qty2,o.vapour_return_qty3,o.lauf_qty,o.lauf_qty2,o.lauf_qty3,o.balance_delta_qty,o.balance_delta_qty2,o.balance_delta_qty3,
		o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10,o.text_11,o.text_12,o.text_13,o.text_14,o.text_15,o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10,o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,created_by)
	VALUES (f.parcel_no,f.object_id,f.daytime,f.summer_time,f.production_day,f.grs_vol_requested,f.grs_vol_nominated,f.grs_vol_schedule,f.grs_vol_requested2,f.grs_vol_nominated2,f.grs_vol_scheduled2,f.grs_vol_requested3,f.grs_vol_nominated3,f.grs_vol_scheduled3,
	    f.cooldown_qty,f.cooldown_qty2,f.cooldown_qty3,f.purge_qty,f.purge_qty2,f.purge_qty3,f.vapour_return_qty,f.vapour_return_qty2,f.vapour_return_qty3,f.lauf_qty,f.lauf_qty2,f.lauf_qty3,f.balance_delta_qty,f.balance_delta_qty2,f.balance_delta_qty3,
		f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10,f.text_11,f.text_12,f.text_13,f.text_14,f.text_15,f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10,f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,
		ecdp_context.getAppUser);

	ecbp_cargo_transport.cleanLonesomeCargoes;

	--lifting account adjustement
	MERGE INTO 	lift_account_adjustment o
	USING (SELECT l.object_id, l.to_object_id, l.daytime, l.summer_time, l.production_day, l.adj_qty, l.adj_qty2, l.adj_qty3, l.comments,  l.value_1, l.value_2, l.value_3, l.value_4, l.value_5, l.value_6, l.value_7, l.value_8, l.value_9, l.value_10,
			l.text_1, l.text_2, l.text_3, l.text_4, l.rev_no
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
			o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.to_object_id, o.daytime, o.summer_time, o.production_day, o.adj_qty, o.adj_qty2, o.adj_qty3, o.comments,
			o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
			o.text_1, o.text_2, o.text_3, o.text_4, o.created_by)
		VALUES (f.object_id, f.to_object_id, f.daytime, f.summer_time, f.production_day, f.adj_qty, f.adj_qty2, f.adj_qty3, f.comments, f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
			f.text_1, f.text_2, f.text_3, f.text_4, ecdp_context.getAppUser);

	MERGE INTO 	lift_account_adj_single o
	USING (SELECT l.object_id, l.daytime, l.summer_time, l.production_day, l.adj_qty, l.adj_qty2, l.adj_qty3, l.adj_reason, l.comments, l.rev_no
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
		UPDATE SET o.summer_time  = f.summer_time, o.production_day = f.production_day, o.adj_qty  = f.adj_qty, o.adj_qty2 = f.adj_qty2, o.adj_qty3 = f.adj_qty3, o.adj_reason = f.adj_reason, o.comments = f.comments, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.summer_time, o.production_day, o.adj_qty, o.adj_qty2, o.adj_qty3, o.adj_reason, o.comments, o.created_by)
		VALUES (f.object_id, f.daytime, f.summer_time, f.production_day, f.adj_qty, f.adj_qty2, f.adj_qty3, f.adj_reason, f.comments, ecdp_context.getAppUser);

	MERGE INTO OPLOC_DAILY_RESTRICTION o
	USING (SELECT f.object_id, f.daytime, f.restricted_capacity, f.restriction_type, f.comments, f.rev_no
		FROM FCST_OPLOC_DAY_RESTRICT f,
			 forecast c
		WHERE f.forecast_id = p_forecast_id
			  AND f.forecast_id = c.object_id
			  AND f.daytime >= c.start_date
			  AND f.daytime < c.end_date) t
	ON (o.object_id = t.object_id AND o.daytime = t.daytime)
	WHEN MATCHED THEN
		UPDATE SET o.restricted_capacity  = t.restricted_capacity, o.restriction_type = t.restriction_type, o.comments = t.comments, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.restricted_capacity, o.restriction_type, o.comments, o.created_by)
		VALUES (t.object_id, t.daytime, t.restricted_capacity, t.restriction_type, t.comments, ecdp_context.getAppUser);

	MERGE INTO OPLOC_PERIOD_RESTRICTION o
    USING (SELECT r.object_id, r.start_date, r.end_date, r.restricted_capacity, r.restriction_type, r.comments,
        r.value_1, r.value_2, r.value_3, r.value_4, r.value_5, r.value_6, r.value_7, r.value_8, r.value_9, r.value_10,
        r.text_1, r.text_2, r.text_3, r.text_4, ecdp_context.getAppUser,r.rev_no
            FROM FCST_OPLOC_PERIOD_RESTR r
            WHERE r.forecast_id = p_forecast_id ) t
      ON (o.object_id = t.object_id AND t.end_date >= o.start_date
        AND t.start_date < o.end_date)
  WHEN MATCHED THEN
    UPDATE SET o.restricted_capacity  = t.restricted_capacity, o.restriction_type = t.restriction_type, o.comments = t.comments, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
  WHEN NOT MATCHED THEN
    INSERT (o.object_id, o.start_date,o.end_date, o.restricted_capacity, o.restriction_type, o.comments, o.created_by)
    VALUES (t.object_id, t.start_date,t.end_date, t.restricted_capacity, t.restriction_type, t.comments, ecdp_context.getAppUser);


MERGE INTO OBJ_EVENT_CP_TRAN_FACTOR o
	USING (SELECT f.object_id, f.daytime, f.component_no, f.class_name, f.frac, f.rev_no
		FROM FCST_RECOVERY_FACTOR f,
			 forecast c
		WHERE f.forecast_id = p_forecast_id
			  AND f.forecast_id = c.object_id
			  AND f.daytime >= c.start_date
			  AND f.daytime < c.end_date ) t
	ON (o.object_id = t.object_id AND o.daytime = t.daytime AND o.component_no = t.component_no)
	WHEN MATCHED THEN
		UPDATE SET o.class_name = 'TRNP_EVENT_CP_TRAN_FAC', o.frac = t.frac, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.component_no, o.class_name, o.frac, o.created_by)
		VALUES (t.object_id, t.daytime, t.component_no, 'TRNP_EVENT_CP_TRAN_FAC', t.frac, ecdp_context.getAppUser);

MERGE INTO OBJ_EVENT_DIM1_CP_TRAN_FAC o
	USING (SELECT f.object_id, f.daytime, f.component_no, f.class_name, f.dim1_key, f.frac, f.value_1, f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_7,f.value_8,f.value_9,f.value_10, f.value_11,f.value_12,f.value_13,f.value_14,f.value_15,f.value_16,f.value_17,f.value_18,f.value_19,f.value_20,f.value_21, f.value_22, f.value_23,f.value_24, f.value_25,f.value_26,f.value_27,f.value_28,f.value_29, f.value_30, f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15, f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, f.rev_no
		FROM FCST_OBJ_EVT_DIM1_CP_FAC f,
			 forecast c
		WHERE f.forecast_id = p_forecast_id
			  AND f.forecast_id = c.object_id
			  AND f.daytime >= c.start_date
			  AND f.daytime < c.end_date ) t
	ON (o.object_id = t.object_id AND o.daytime = t.daytime AND o.component_no = t.component_no AND o.dim1_key = t.dim1_key)
	WHEN MATCHED THEN
		UPDATE SET o.class_name = 'TRNL_EVENT_PROD_CP_FAC', o.frac = t.frac, last_updated_by = ecdp_context.getAppUser, o.value_1 = t.value_1 , o.value_2 = t.value_2, o.value_3=t.value_3,o.value_4=t.value_4, o.value_5=t.value_5, o.value_6=t.value_6, o.value_7=t.value_7, o.value_8=t.value_8, o.value_9= t.value_9, o.value_10=t.value_10, o.value_11=t.value_11, o.value_12=t.value_12, o.value_13=t.value_13, o.value_14=t.value_14,o.value_15=t.value_15, o.value_16=t.value_16, o.value_17=t.value_17, o.value_18=t.value_18, o.value_19=t.value_19, o.value_20=t.value_20, o.value_21=t.value_21, o.value_22=t.value_22, o.value_23=t.value_23, o.value_24=t.value_24, o.value_25=t.value_25, o.value_26=t.value_26, o.value_27=t.value_27, o.value_28=t.value_28, o.value_29=t.value_29, o.value_30=t.value_30, o.text_1=t.text_1, o.text_2=t.text_2, o.text_3=t.text_3, o.text_4=t.text_4, o.text_5=t.text_5, o.text_6=t.text_6, o.text_7=t.text_7, o.text_8=t.text_8, o.text_9=t.text_9, o.text_10=t.text_10, o.text_11=t.text_11, o.text_12=t.text_12, o.text_13=t.text_13, o.text_14=t.text_14, o.text_15=t.text_15,o.date_1=t.date_1, o.date_2=t.date_2, o.date_3=t.date_3, o.date_4=t.date_4, o.date_5=t.date_5, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
	WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.daytime, o.component_no, o.class_name, o.dim1_key, o.frac, o.created_by,o.value_1, o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,o.value_10, o.value_11,o.value_12,o.value_13,o.value_14,o.value_15,o.value_16,o.value_17, o.value_18,o.value_19,o.value_20,o.value_21, o.value_22, o.value_23,o.value_24, o.value_25,o.value_26,o.value_27,o.value_28,o.value_29, o.value_30, o.text_1, o.text_2, o.text_3, o.text_4, o.text_5, o.text_6, o.text_7,o.text_8, o.text_9, o.text_10, o.text_11, o.text_12, o.text_13, o.text_14, o.text_15, o.date_1, o.date_2, o.date_3, o.date_4, o.date_5)
		VALUES (t.object_id, t.daytime, t.component_no, 'TRNL_EVENT_PROD_CP_FAC', t.dim1_key, t.frac, ecdp_context.getAppUser, t.value_1, t.value_2,t.value_3,t.value_4,t.value_5,t.value_6,t.value_7,t.value_8,t.value_9,t.value_10, t.value_11,t.value_12,t.value_13,t.value_14,t.value_15,t.value_16,t.value_17,t.value_18,t.value_19,t.value_20,t.value_21, t.value_22, t.value_23,t.value_24, t.value_25,t.value_26,t.value_27,t.value_28,t.value_29, t.value_30, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7,t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5);

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
	  , f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30, f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, f.rev_no
		FROM FCST_TRAIN_INLET_GAS f, forecast c
		WHERE f.forecast_id = p_forecast_id
			AND f.forecast_id = c.object_id
			AND f.daytime >= c.start_date
			AND f.daytime < c.end_date ) t
	  ON (o.object_id = t.object_id AND o.daytime = t.daytime)
	  WHEN MATCHED THEN
		UPDATE SET o.end_date=t.end_date, o.inlet_gas=t.inlet_gas, o.uom=t.uom, o.text_1=t.text_1, o.text_2=t.text_2, o.text_3=t.text_3, o.text_4=t.text_4, o.text_5=t.text_5, o.text_6=t.text_6, o.text_7=t.text_7, o.text_8=t.text_8, o.text_9=t.text_9, o.text_10=t.text_10
		, o.text_11=t.text_11, o.text_12=t.text_12, o.text_13=t.text_13, o.text_14=t.text_14, o.text_15=t.text_15, o.value_1=t.value_1, o.value_2=t.value_2, o.value_3=t.value_3, o.value_4=t.value_4, o.value_5=t.value_5
		, o.value_6=t.value_6, o.value_7=t.value_7, o.value_8=t.value_8, o.value_9=t.value_9, o.value_10=t.value_10, o.value_11=t.value_11, o.value_12=t.value_12, o.value_13=t.value_13, o.value_14=t.value_14
		, o.value_15=t.value_15, o.value_16=t.value_16, o.value_17=t.value_17, o.value_18=t.value_18, o.value_19=t.value_19, o.value_20=t.value_20, o.value_21=t.value_21, o.value_22=t.value_22, o.value_23=t.value_23
		, o.value_24=t.value_24, o.value_25=t.value_25, o.value_26=t.value_26, o.value_27=t.value_27, o.value_28=t.value_28, o.value_29=t.value_29, o.value_30=t.value_30, o.date_1=t.date_1, o.date_2=t.date_2
		, o.date_3=t.date_3, o.date_4=t.date_4, o.date_5=t.date_5
		, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
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
	  , f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30, f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, f.rev_no
		FROM FCST_TRAIN_STORAGE_YIELD f, forecast c
		WHERE f.forecast_id = p_forecast_id
			AND f.forecast_id = c.object_id
			AND f.daytime >= c.start_date
			AND f.daytime < c.end_date ) t
	  ON (o.object_id = t.object_id AND o.storage_id=t.storage_id AND o.daytime = t.daytime)
	  WHEN MATCHED THEN
		UPDATE SET o.yield_factor=t.yield_factor, o.text_1=t.text_1, o.text_2=t.text_2, o.text_3=t.text_3, o.text_4=t.text_4, o.text_5=t.text_5, o.text_6=t.text_6, o.text_7=t.text_7, o.text_8=t.text_8, o.text_9=t.text_9, o.text_10=t.text_10
		, o.text_11=t.text_11, o.text_12=t.text_12, o.text_13=t.text_13, o.text_14=t.text_14, o.text_15=t.text_15, o.value_1=t.value_1, o.value_2=t.value_2, o.value_3=t.value_3, o.value_4=t.value_4, o.value_5=t.value_5
		, o.value_6=t.value_6, o.value_7=t.value_7, o.value_8=t.value_8, o.value_9=t.value_9, o.value_10=t.value_10, o.value_11=t.value_11, o.value_12=t.value_12, o.value_13=t.value_13, o.value_14=t.value_14
		, o.value_15=t.value_15, o.value_16=t.value_16, o.value_17=t.value_17, o.value_18=t.value_18, o.value_19=t.value_19, o.value_20=t.value_20, o.value_21=t.value_21, o.value_22=t.value_22, o.value_23=t.value_23
		, o.value_24=t.value_24, o.value_25=t.value_25, o.value_26=t.value_26, o.value_27=t.value_27, o.value_28=t.value_28, o.value_29=t.value_29, o.value_30=t.value_30, o.date_1=t.date_1, o.date_2=t.date_2
		, o.date_3=t.date_3, o.date_4=t.date_4, o.date_5=t.date_5
		, last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(t.rev_no, 0, o.rev_no, o.rev_no + 1)
	  WHEN NOT MATCHED THEN
		INSERT (o.object_id, o.storage_id, o.daytime, o.yield_factor, o.text_1, o.text_2, o.text_3, o.text_4, o.text_5, o.text_6, o.text_7, o.text_8, o.text_9, o.text_10, o.text_11, o.text_12, o.text_13, o.text_14, o.text_15, o.value_1, o.value_2
		, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10, o.value_11, o.value_12, o.value_13, o.value_14, o.value_15, o.value_16, o.value_17, o.value_18, o.value_19
		, o.value_20, o.value_21, o.value_22, o.value_23, o.value_24, o.value_25, o.value_26, o.value_27, o.value_28, o.value_29, o.value_30, o.date_1, o.date_2, o.date_3, o.date_4, o.date_5, o.created_by)
		VALUES (t.object_id, t.storage_id, t.daytime, t.yield_factor, t.text_1, t.text_2, t.text_3, t.text_4, t.text_5, t.text_6, t.text_7, t.text_8, t.text_9, t.text_10, t.text_11, t.text_12, t.text_13, t.text_14, t.text_15, t.value_1, t.value_2
		, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10, t.value_11, t.value_12, t.value_13, t.value_14, t.value_15, t.value_16, t.value_17, t.value_18, t.value_19
		, t.value_20, t.value_21, t.value_22, t.value_23, t.value_24, t.value_25, t.value_26, t.value_27, t.value_28, t.value_29, t.value_30, t.date_1, t.date_2, t.date_3, t.date_4, t.date_5, ecdp_context.getAppUser);
      MERGE INTO storage_lift_nom_split o
	  USING (SELECT n.parcel_no, n.lifting_account_id, n.company_id, n.forecast_id, n.split_pct ,n.split_no, n.comments,
			n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,n.text_11,n.text_12,n.text_13,n.text_14,n.text_15,			n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8,n.value_9,n.value_10,
			n.value_11,n.value_12,n.value_13,n.value_14,n.value_15,n.value_16,n.value_17,n.value_18,n.value_19,n.value_20,
			n.value_21,n.value_22,n.value_23,n.value_24,n.value_25,n.value_26,n.value_27,n.value_28,n.value_29,n.value_30,
			n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.date_8,n.date_9,n.date_10, n.rev_no
	     FROM fcst_stor_lift_cpy_split n,
	       forecast c
	   WHERE n.forecast_id = p_forecast_id
	   AND n.forecast_id = c.object_id
	   AND n.parcel_no IN (select parcel_no
		                     FROM stor_fcst_lift_nom sf,
							      cargo_fcst_transport t,
								  cargo_transport co
		                    WHERE sf.forecast_id = t.forecast_id
                              AND sf.cargo_no = t.cargo_no
                              AND sf.forecast_id = p_forecast_id
							  AND sf.forecast_id = c.object_id
							  AND co.cargo_no (+) = sf.cargo_no
							  AND ue_forecast_cargo_planning.includeInCopy(sf.forecast_id,sf.cargo_no,sf.parcel_no,co.cargo_status,t.cargo_status)='Y'
			                  AND Nvl(sf.DELETED_IND, 'N') <> 'Y'
		                      AND sf.nom_firm_date >= c.start_date
		                      AND sf.nom_firm_date < c.end_date
		                      AND sf.object_id = nvl(c.storage_id, sf.object_id)))f
	  ON (o.parcel_no = f.parcel_no and o.company_id = f.company_id and o.lifting_account_id = f.lifting_account_id and o.split_no=f.split_no)
	  WHEN MATCHED THEN
		UPDATE SET o.split_pct = f.split_pct,
		           o.comments = f.comments,
			       o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5,
				   o.value_6 = f.value_6, o.value_7 = f.value_7, o.value_8 = f.value_8, o.value_9 = f.value_9, o.value_10 = f.value_10,
				   o.value_11 = f.value_11, o.value_12 = f.value_12, o.value_13 = f.value_13, o.value_14 = f.value_14, o.value_15 = f.value_15,
				   o.value_16 = f.value_16, o.value_17 = f.value_17, o.value_18 = f.value_18, o.value_19 = f.value_19, o.value_20 = f.value_20,
				   o.value_21 = f.value_21, o.value_22 = f.value_22, o.value_23 = f.value_23, o.value_24 = f.value_24, o.value_25 = f.value_25,
				   o.value_26 = f.value_26, o.value_27 = f.value_27, o.value_28 = f.value_28, o.value_29 = f.value_29, o.value_30 = f.value_30,
			       o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5,
				   o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10,
				   o.text_11 = f.text_11, o.text_12 = f.text_12, o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15,
                   o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3, o.date_4 = f.date_4, o.date_5 = f.date_5,
				   o.date_6 = f.date_6, o.date_7 =f.date_7, o.date_8 = f.date_8, o.date_9 = f.date_9, o.date_10 = f.date_10,
                   last_updated_by = ecdp_context.getAppUser, o.rev_no= decode(f.rev_no, 0, o.rev_no, o.rev_no + 1)
	  WHEN NOT MATCHED THEN
		INSERT (o.parcel_no, o.company_id, o.lifting_account_id, o.split_pct,o.split_no, o.comments,
			    o.value_1, o.value_2, o.value_3, o.value_4, o.value_5, o.value_6, o.value_7, o.value_8, o.value_9, o.value_10,
				o.value_11, o.value_12, o.value_13, o.value_14, o.value_15, o.value_16, o.value_17, o.value_18, o.value_19, o.value_20,
				o.value_21, o.value_22, o.value_23, o.value_24, o.value_25, o.value_26, o.value_27, o.value_28, o.value_29, o.value_30,
			    o.text_1, o.text_2, o.text_3, o.text_4, o.text_5, o.text_6, o.text_7, o.text_8, o.text_9, o.text_10,
				o.text_11, o.text_12, o.text_13, o.text_14, o.text_15,
			    o.date_1, o.date_2, o.date_3, o.date_4, o.date_5, o.date_6, o.date_7, o.date_8, o.date_9, o.date_10,
	            created_by)
		VALUES (f.parcel_no, f.company_id, f.lifting_account_id, f.split_pct, f.split_no,f.comments,
			    f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,
				f.value_11, f.value_12, f.value_13, f.value_14, f.value_15, f.value_16, f.value_17, f.value_18, f.value_19, f.value_20,
			    f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30,
			    f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10,
				f.text_11, f.text_12, f.text_13, f.text_14, f.text_15,
			    f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, f.date_6, f.date_7, f.date_8, f.date_9, f.date_10,
	            ecdp_context.getAppUser);

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

	DELETE FCST_STOR_LIFT_CPY_SPLIT where forecast_id = p_forecast_id;
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
	DELETE FCST_OBJ_EVT_DIM1_CP_FAC where forecast_id = p_forecast_id;

	DELETE FCST_OPLOC_PERIOD_RESTR where forecast_id = p_forecast_id;

	ue_Forecast_Cargo_Planning.deleteForecastCascade(p_forecast_id,p_start_date,p_end_date);

  END IF;

END deleteForecastCascade;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateStorage
-- Description    : Validates the storage assign to forecasts in forecast manager-Compare Tab.
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
PROCEDURE ValidateStorage(p_forecast_storage VARCHAR2, p_compare_storage VARCHAR2)
IS
BEGIN
    IF (p_compare_storage <> p_forecast_storage) THEN
      Raise_Application_Error(-20584,'Not allowed to compare different storage.');
    END IF;
END ValidateStorage;

END EcBp_Forecast_Cargo_Planning;