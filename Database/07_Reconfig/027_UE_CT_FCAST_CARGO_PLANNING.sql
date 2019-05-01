create or replace PACKAGE UE_CT_FCAST_CARGO_PLANNING IS
/****************************************************************
** Package        :  UE_CT_FCAST_CARGO_PLANNING; head part
**
** $Revision: 1.2 $
**
** Purpose        :  Cargo Planning Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 31/5/2010   lauuufus    ECPD-14514 Modify deleteForecastCascade
*************************************************************************/

PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES');

PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES');

PROCEDURE copyToOriginal(p_forecast_id VARCHAR2, p_copy_forecast VARCHAR2 DEFAULT 'YES');

PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE);

PROCEDURE mergeForecast(p_from_forecast_code VARCHAR2, p_to_forecast_code VARCHAR2, p_start_date DATE , p_end_date DATE , p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES');

END UE_CT_FCAST_CARGO_PLANNING;
/

create or replace PACKAGE BODY UE_CT_FCAST_CARGO_PLANNING IS
/****************************************************************
** Package        :  UE_CT_FCAST_CARGO_PLANNING; body part
**
** $Revision: 1.16 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Modification history:
**
** Date        Whom  Change description:
** 02-feb-2017 KOIJ Cool Purge Duration  Qty columns are being crossed when copying from Original to Scenario. Duration is being copied to Qty and vice versa
** 25-sep-2017 KOIJ 124172 RAT and ETD Override fixed bug date_3 si equal to date_4 to date_3 equal to date_3
********************************************************************/

PROCEDURE createForecast(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_base_scenario_type VARCHAR2 DEFAULT NULL, p_new_forecast_id OUT VARCHAR2)
IS
    v_scenario_type VARCHAR2(32) := p_base_scenario_type;
BEGIN

    IF (v_scenario_type IS NULL) THEN
        v_scenario_type := 'ORIGINAL';
    END IF;

    p_new_forecast_id:= EcDp_objects.GetInsertedObjectID(p_new_forecast_id);

    INSERT INTO FORECAST(object_id,CLASS_NAME,OBJECT_CODE,START_DATE,END_DATE, STORAGE_ID, created_by)
    VALUES(p_new_forecast_id,'FORECAST_TRAN_CP',p_new_forecast_code,p_start_date,p_end_date,p_storage_id,ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by, text_4)
    VALUES(p_new_forecast_id, p_start_date, p_end_date, p_new_forecast_code, ecdp_context.getAppUser, v_scenario_type);

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
PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS
    p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
    createForecast(p_new_forecast_code, p_start_date, p_end_date, p_storage_id, 'ORIGINAL', p_new_forecast_id);

    -- copy storage forecast tables

    IF (p_copy_forecast = 'YES') THEN

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
    END IF;

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
    -- SWGN
    -- Value_10 is skipped and is handled differently!
    --Tlxt
    --TEXT_15 is used to indicate whether it is copied from original
    --TLXT: ADDED TEXT_20 to indicate Excess Lifting Approval Flag
    INSERT INTO stor_fcst_lift_nom (forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,START_LIFTING_DATE,date_9,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_11,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,cooldown_ind,cooldown_qty,purge_ind,purge_qty,
        text_16,text_17,text_18,text_19,text_20,
    created_by)
    /* KOIJ Cool Purge Duration  Qty columns are being crossed when copying from Original to Scenario. Duration is being copied to Qty and vice versa*/
    /*--------------------value_7 from storage lift nomination need to be inserted into value_8 stor_fcst_lift_nom------------------------------------*/
    /*--------------------value_8 from storage lift nomination need to be inserted into value_7 stor_fcst_lift_nom------------------------------------*/
    SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,START_LIFTING_DATE,date_9,grs_vol_requested2,grs_vol_nominated2,grs_vol_scheduled2,grs_vol_requested3,grs_vol_nominated3,grs_vol_scheduled3,
        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,'Y',value_1,value_2,value_3,value_4,value_5,value_6,value_8,value_7,value_9,value_11,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,cooldown_ind,cooldown_qty,purge_ind,purge_qty,
        text_16,text_17,text_18,text_19,text_20,
    ecdp_context.getAppUser
    FROM  storage_lift_nomination n
    WHERE n.nom_firm_date >= p_start_date
          AND n.nom_firm_date < p_end_date
          AND n.object_id = nvl(p_storage_id, n.object_id);

    -- Value_10 maps to "Resolved Cargo Number." On STORAGE_LIFT_NOMINATION it gives the cargo number that resolved a priority one or two event that affected that lifting.
    -- I.e., if Parcel_No 565 was canceled for failure to supply, VALUE_10 will be populated when that lifter receives their priority one cargo.
    -- In the Forecast Tables, it works slightly differently. VALUE_10 now gets populated for liftings which fix other cargoes; e.g., it is the opposite of the way it works for STORAGE_LIFT_NOMINATION.
    -- LBFK: Need to revise this logic
    UPDATE stor_fcst_lift_nom fnom
    SET fnom.value_10 =
    (
        SELECT max(nom.parcel_no)
        FROM storage_lift_nomination nom
        WHERE nom.value_10 = fnom.cargo_no
    )
    WHERE fnom.forecast_id = p_new_forecast_id
    AND
    (
        SELECT COUNT(*)
        FROM storage_lift_nomination nom2
        WHERE nom2.value_10 = fnom.cargo_no
    ) > 0;

    --Work Item 102393:
    --Update the Forecast Nom date time to include the RAT entered in the Cargo Info for mthe Official.
    UPDATE stor_fcst_lift_nom
    SET START_LIFTING_DATE =  (ec_cargo_transport.date_1(CARGO_NO)) + nvl(UE_CT_LEADTIME.calc_ETA_LT(OBJECT_ID,PARCEL_NO,NULL,'STOR') ,0)
    WHERE forecast_id = p_new_forecast_id AND (ec_cargo_transport.date_1(CARGO_NO)) IS NOT NULL;

    --UPDATE OVERWRITE LOADING FROM OFFICIAL CARGO INFO VALUE_6 TO SCENARIO VALUE_1. ONCE SCENARIO GETS APPROVED, THIS VALUE_1 WILL BE COPIED OVER TO THE OFFICIAL TO BE CALCULATED/USED IN UE_CT_LEADTIME
    UPDATE CARGO_FCST_TRANSPORT
    SET VALUE_1 = ec_cargo_transport.VALUE_6(CARGO_NO)
    WHERE forecast_id = p_new_forecast_id AND ec_cargo_transport.VALUE_6(CARGO_NO) IS NOT NULL;

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
--PROCEDURE mergeForecast(p_from_forecast_code VARCHAR2, p_to_forecast_code VARCHAR2, p_start_date DATE DEFAULT NULL, p_end_date DATE DEFAULT NULL, p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES');

---------------------------------------------------------------------------------------------------
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS

    p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
    IF (p_forecast_id IS NULL) THEN
        Raise_Application_Error(-20000,'Missing copy from forecast id');
    END IF;

    createForecast(p_new_forecast_code, p_start_date, p_end_date, p_storage_id, ec_forecast_version.text_6(p_forecast_id, p_start_date, '<='), p_new_forecast_id);

    -- copy storage forecast tables

    if (p_copy_forecast = 'YES') THEN

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

    END IF;

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
    INSERT INTO stor_fcst_lift_nom (forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,cooldown_ind,cooldown_qty,purge_ind,purge_qty,
        text_16,text_17,text_18,text_19,text_20,
    created_by, START_LIFTING_DATE, date_9, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3)
    SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
        text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,cooldown_ind,cooldown_qty,purge_ind,purge_qty,
        text_16,text_17,text_18,text_19,text_20,
    ecdp_context.getAppUser, START_LIFTING_DATE, date_9, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3
    FROM  stor_fcst_lift_nom n
    WHERE n.forecast_id = p_forecast_id
        AND n.nom_firm_date >= p_start_date
        AND n.nom_firm_date < p_end_date
        AND n.object_id = nvl(p_storage_id, n.object_id);

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


    CURSOR c_value_10_flip (cp_forecast_id VARCHAR2) IS
        SELECT n.parcel_no, n.cargo_no, n.value_10, n.lifting_account_id
        FROM stor_fcst_lift_nom n
        WHERE n.forecast_id = cp_forecast_id
        AND NVL(n.DELETED_IND, 'N') <> 'Y'
        AND n.value_10 IS NOT NULL;

BEGIN
    IF (p_forecast_id IS NULL) THEN
        Raise_Application_Error(-20000,'Missing forecast id');
    END IF;

    IF (p_copy_forecast = 'YES') THEN

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
        MERGE INTO     lift_acc_day_forecast o
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
        MERGE INTO     lift_acc_sub_day_forecast o
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


    END IF;
       --124172 RAT and ETD Override fixed bug date_3 si equal to date_4 to date_3 equal to date_3
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
        o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3,o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 =f.date_7, last_updated_by = ecdp_context.getAppUser
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
    --124172 RAT and ETD Override fixed bug date_3 si equal to date_4 to date_3 equal to date_3
    --insert update nominations
    MERGE INTO storage_lift_nomination o
    USING (SELECT n.parcel_no,n.object_id,n.cargo_no,n.lifting_account_id,n.carrier_id,n.consignor_id,n.consignee_id,n.requested_date,n.requested_date_range,n.requested_tolerance_type,n.grs_vol_requested,n.nom_firm_date,n.nom_firm_date_range,n.nom_sequence,n.grs_vol_nominated,
            n.lifting_split_pct,n.lifting_split_vol,n.lifting_code,n.incoterm,n.contract_id,n.telex_ref,n.graph_value,n.balance_ind,n.grs_vol_schedule,n.schedule_tolerance_type,n.bl_number,n.bl_date,n.unload_date,n.port_id,n.doc_instr_received_ind,n.fixed_ind,n.bol_comments,n.charter_party,n.comments,n.date_9,
            n.text_1,n.text_2,n.text_3,n.text_4,n.text_5,n.text_6,n.text_7,n.text_8,n.text_9,n.text_10,n.text_11,n.text_12,n.text_13,n.text_14,n.text_15,n.cooldown_ind, n.cooldown_qty, n.purge_ind, n.purge_qty,
            n.value_1,n.value_2,n.value_3,n.value_4,n.value_5,n.value_6,n.value_7,n.value_8, n.value_9,--n.value_10,
        n.value_11,n.text_16,n.text_17,n.text_18,n.text_19,n.text_20,
            n.ref_object_id_1,n.ref_object_id_2,n.ref_object_id_3,n.ref_object_id_4,n.ref_object_id_5,
            n.date_1,n.date_2,n.date_3,n.date_4,n.date_5,n.date_6,n.date_7,n.grs_vol_scheduled2, n.grs_vol_requested2, n.grs_vol_nominated2, n.grs_vol_scheduled3, n.grs_vol_requested3, n.grs_vol_nominated3, n.START_LIFTING_DATE
        FROM  stor_fcst_lift_nom n,
             forecast c
        WHERE n.forecast_id = p_forecast_id
            AND Nvl(n.DELETED_IND, 'N') <> 'Y'
            AND n.forecast_id = c.object_id
            AND n.nom_firm_date >= c.start_date
            AND n.nom_firm_date < c.end_date
            AND n.object_id = nvl(c.storage_id, n.object_id)) f
    ON (o.parcel_no = f.parcel_no)
    WHEN MATCHED THEN
        UPDATE SET o.object_id = f.object_id,o.cargo_no = f.cargo_no,o.lifting_account_id = f.lifting_account_id,o.carrier_id = f.carrier_id,o.consignor_id = f.consignor_id,o.consignee_id = f.consignee_id,o.requested_date = f.requested_date,o.requested_date_range = f.requested_date_range,o.requested_tolerance_type = f.requested_tolerance_type,o.grs_vol_requested = f.grs_vol_requested,o.nom_firm_date = f.nom_firm_date,o.nom_firm_date_range = f.nom_firm_date_range,o.nom_sequence = f.nom_sequence,o.grs_vol_nominated = f.grs_vol_nominated,
            o.lifting_split_pct = f.lifting_split_pct,o.lifting_split_vol = f.lifting_split_vol,o.lifting_code = f.lifting_code,o.incoterm = f.incoterm,o.contract_id = f.contract_id,o.telex_ref = f.telex_ref,o.graph_value = f.graph_value,o.balance_ind = f.balance_ind,o.grs_vol_schedule = f.grs_vol_schedule,o.schedule_tolerance_type = f.schedule_tolerance_type,o.bl_number = f.bl_number,o.bl_date = f.bl_date,o.unload_date = f.unload_date,o.port_id = f.port_id,o.doc_instr_received_ind = f.doc_instr_received_ind,o.fixed_ind = f.fixed_ind,o.bol_comments = f.bol_comments,o.charter_party = f.charter_party,o.comments = f.comments,o.date_9 = f.date_9,
            o.value_1 = f.value_1, o.value_2 = f.value_2, o.value_3 = f.value_3, o.value_4 = f.value_4, o.value_5 = f.value_5, o.value_6 = f.value_6, o.value_7 = f.value_8, o.value_8 = f.value_7, o.value_9 = DECODE(NVL(EC_CARGO_TRANSPORT.TEXT_1(F.CARGO_NO),'N'),'N',F.GRS_VOL_NOMINATED,f.value_9),--f.value_9, --o.value_10 = f.value_10,
            o.value_11 = f.value_11,o.ref_object_id_1 = f.ref_object_id_1, o.ref_object_id_2 = f.ref_object_id_2, o.ref_object_id_3 = f.ref_object_id_3, o.ref_object_id_4 = f.ref_object_id_4, o.ref_object_id_5 = f.ref_object_id_5,
            o.text_1 = f.text_1, o.text_2 = f.text_2, o.text_3 = f.text_3, o.text_4 = f.text_4, o.text_5 = f.text_5, o.text_6 = f.text_6, o.text_7 = f.text_7, o.text_8 = f.text_8, o.text_9 = f.text_9, o.text_10 = f.text_10,
            o.text_11 = f.text_11, o.text_12 = f.text_12, o.text_13 = f.text_13, o.text_14 = f.text_14, o.text_15 = f.text_15, o.cooldown_ind = f.cooldown_ind, o.cooldown_qty = f.cooldown_qty, o.purge_ind = f.purge_ind, o.purge_qty = f.purge_qty,
            o.text_16 = f.text_16, o.text_17 = f.text_17, o.text_18 = f.text_18, o.text_19 = f.text_19, o.text_20 = f.text_20,
        o.date_1 = f.date_1, o.date_2 =f.date_2, o.date_3 = f.date_3, o.date_4 = f.date_4, o.date_5 = f.date_5,o.date_6 = f.date_6,o.date_7 = f.date_7, o.grs_vol_scheduled2 = f.grs_vol_scheduled2, o.grs_vol_requested2 = f.grs_vol_requested2, o.grs_vol_nominated2 = f.grs_vol_nominated2, o.grs_vol_scheduled3 = f.grs_vol_scheduled3, o.grs_vol_requested3 = f.grs_vol_requested3, o.grs_vol_nominated3 = f.grs_vol_nominated3, o.START_LIFTING_DATE = f.START_LIFTING_DATE,
            o.last_updated_by = ecdp_context.getAppUser
    WHEN NOT MATCHED THEN
        INSERT (o.parcel_no,o.object_id,o.cargo_no,o.lifting_account_id,o.carrier_id,o.consignor_id,o.consignee_id,o.requested_date,o.requested_date_range,o.requested_tolerance_type,o.grs_vol_requested,o.nom_firm_date,o.nom_firm_date_range,o.nom_sequence,o.grs_vol_nominated,o.lifting_split_pct,o.lifting_split_vol,o.lifting_code,o.incoterm,o.contract_id,o.telex_ref,o.graph_value,o.balance_ind,o.grs_vol_schedule,o.schedule_tolerance_type,o.bl_number,o.bl_date,o.unload_date,o.port_id,o.doc_instr_received_ind,o.fixed_ind,o.bol_comments,o.charter_party,o.comments,o.date_9,
            o.text_1,o.text_2,o.text_3,o.text_4,o.text_5,o.text_6,o.text_7,o.text_8,o.text_9,o.text_10,o.text_11,o.text_12,o.text_13,o.text_14,o.text_15,o.cooldown_ind,o.cooldown_qty,o.purge_ind,o.purge_qty,
            o.value_1,o.value_2,o.value_3,o.value_4,o.value_5,o.value_6,o.value_7,o.value_8,o.value_9,--o.value_10,
            o.value_11,o.ref_object_id_1,o.ref_object_id_2,o.ref_object_id_3,o.ref_object_id_4,o.ref_object_id_5,
            o.text_16,o.text_17,o.text_18,o.text_19,o.text_20,
        o.date_1,o.date_2,o.date_3,o.date_4,o.date_5,o.date_6,o.date_7, o.grs_vol_scheduled2, o.grs_vol_requested2, o.grs_vol_nominated2, o.grs_vol_scheduled3, o.grs_vol_requested3, o.grs_vol_nominated3, o.START_LIFTING_DATE,
            created_by)
        VALUES (f.parcel_no,f.object_id,f.cargo_no,f.lifting_account_id,f.carrier_id,f.consignor_id,f.consignee_id,f.requested_date,f.requested_date_range,f.requested_tolerance_type,f.grs_vol_requested,f.nom_firm_date,f.nom_firm_date_range,f.nom_sequence,f.grs_vol_nominated,f.lifting_split_pct,f.lifting_split_vol,f.lifting_code,f.incoterm,f.contract_id,f.telex_ref,f.graph_value,f.balance_ind,f.grs_vol_schedule,f.schedule_tolerance_type,f.bl_number,f.bl_date,f.unload_date,f.port_id,f.doc_instr_received_ind,f.fixed_ind,f.bol_comments,f.charter_party,f.comments,f.date_9,
            f.text_1,f.text_2,f.text_3,f.text_4,f.text_5,f.text_6,f.text_7,f.text_8,f.text_9,f.text_10,f.text_11,f.text_12,f.text_13,f.text_14,f.text_15,f.cooldown_ind,f.cooldown_qty,f.purge_ind,f.purge_qty,
            f.value_1,f.value_2,f.value_3,f.value_4,f.value_5,f.value_6,f.value_8,f.value_7,DECODE(NVL(EC_CARGO_TRANSPORT.TEXT_1(F.CARGO_NO),'N'),'N',F.GRS_VOL_NOMINATED,f.value_9),--f.value_9,--f.value_10,
            f.value_11,f.ref_object_id_1,f.ref_object_id_2,f.ref_object_id_3,f.ref_object_id_4,f.ref_object_id_5,
            f.text_16,f.text_17,f.text_18,f.text_19,f.text_20,
        f.date_1,f.date_2,f.date_3,f.date_4,f.date_5,f.date_6,f.date_7, f.grs_vol_scheduled2, f.grs_vol_requested2, f.grs_vol_nominated2, f.grs_vol_scheduled3, f.grs_vol_requested3, f.grs_vol_nominated3, f.START_LIFTING_DATE,
            ecdp_context.getAppUser);

    FOR item IN c_value_10_flip(p_forecast_id) LOOP
        UPDATE storage_lift_nomination
        SET value_10 = item.cargo_no
        WHERE parcel_no IN
        (
            SELECT x.parcel_no
            FROM storage_lift_nomination x
            WHERE x.lifting_account_id = item.lifting_account_id
            AND x.cargo_no = (select y.cargo_no from storage_lift_nomination y where y.parcel_no = item.value_10)
        );
    END LOOP;

    ecbp_cargo_transport.cleanLonesomeCargoes;

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

    --ECDP_DYNSQL.WRITETEMPTEXT('deleteForecastCascade','here');

    DELETE stor_day_fcst_pc_fcast WHERE forecast_id = p_forecast_id;
    DELETE stor_mth_fcst_pc_fcast WHERE forecast_id = p_forecast_id;

    DELETE stor_day_fcst_fcast WHERE forecast_id = p_forecast_id;
    DELETE stor_sub_day_fcst_fcast WHERE forecast_id = p_forecast_id;

    DELETE lift_acc_day_fcst_fcast WHERE forecast_id = p_forecast_id;
    DELETE lift_acc_sub_day_fcst_fc WHERE forecast_id = p_forecast_id;

    DELETE stor_fcst_lift_nom WHERE forecast_id = p_forecast_id;
    DELETE cargo_fcst_transport WHERE forecast_id = p_forecast_id;

  END IF;

END deleteForecastCascade;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : mergeForecast
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
PROCEDURE mergeForecast(p_from_forecast_code VARCHAR2, p_to_forecast_code VARCHAR2, p_start_date DATE , p_end_date DATE , p_storage_id VARCHAR2 DEFAULT NULL, p_copy_forecast VARCHAR2 DEFAULT 'YES')
--</EC-DOC>
IS
    --Get the forecast that want to copy to
    --if there isnt any forecast id , then we need to create a new forecast
    p_forecast_id VARCHAR2(32) := ECDP_OBJECTS.GETOBJIDFROMCODE('FORECAST_TRAN_CP',p_from_forecast_code);
    p_new_forecast_id VARCHAR2(32) := ECDP_OBJECTS.GETOBJIDFROMCODE('FORECAST_TRAN_CP',p_to_forecast_code);
    --If Start date of the From_forecast is not same as the To_forecast, what should we do?

BEGIN

    --ECDP_DynSql.WriteTempText('Merge', 'From: ' || p_from_forecast_code || ', To: ' || p_to_forecast_code);

    IF (p_to_forecast_code IS NULL) THEN
        copyFromForecast(p_forecast_id , 'PPADP' , p_start_date, p_end_date, p_storage_id , p_copy_forecast );
    ELSE
    --This means there were already a scenario
    --We dont have to copy the Storage Forecast table because it should be already exists in the to_forecast scenario
    -- copy cargo
       MERGE INTO cargo_fcst_transport O
        USING(
        SELECT forecast_id, cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
        text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
        ecdp_context.getAppUser
        FROM cargo_fcst_transport t
        WHERE t.forecast_id = p_forecast_id
        AND cargo_no in (select cargo_no
        FROM  stor_fcst_lift_nom n
        WHERE n.forecast_id = p_forecast_id
              AND n.nom_firm_date >= p_start_date
              AND n.nom_firm_date < p_end_date
              AND COALESCE(n.object_id,'WST') = COALESCE(p_storage_id, n.object_id,'WST'))
        ) N
        ON (O.CARGO_NO = N.CARGO_NO AND O.FORECAST_ID = p_new_forecast_id )
        WHEN MATCHED THEN
        UPDATE SET O.CARGO_NAME = N.CARGO_NAME,
        O.CARRIER_ID = N.CARRIER_ID,
        O.AGENT =N.AGENT,
        O.SURVEYOR =N.SURVEYOR,
        O.LAYTIME = N.LAYTIME,
        O.EST_ARRIVAL = N.EST_ARRIVAL,
        O.EST_DEPARTURE=N.EST_DEPARTURE,
        O.CARGO_STATUS=N.CARGO_STATUS,
        O.PROD_FCTY_ID=N.PROD_FCTY_ID,
        O.MASTER=N.MASTER,
        O.PILOT=N.PILOT,
        O.TUGS_ARR=N.TUGS_ARR,
        O.TUGS_DEP=N.TUGS_DEP,
        O.DRAUGHT_MARK_ARR_AFT=N.DRAUGHT_MARK_ARR_AFT,
        O.DRAUGHT_MARK_ARR_CENTER=N.DRAUGHT_MARK_ARR_CENTER,
        O.DRAUGHT_MARK_ARR_FORWARD=N.DRAUGHT_MARK_ARR_FORWARD,
        O.DRAUGHT_MARK_DEP_AFT=N.DRAUGHT_MARK_DEP_AFT,
        O.DRAUGHT_MARK_DEP_CENTER=N.DRAUGHT_MARK_DEP_CENTER,
        O.DRAUGHT_MARK_DEP_FORWARD=N.DRAUGHT_MARK_DEP_FORWARD,
        O.VOYAGE_NO=N.VOYAGE_NO,
        O.BERTH_ID=N.BERTH_ID,
        O.text_1=N.text_1,
        O.text_2=N.text_2,
        O.text_3=N.text_3,
        O.text_4=N.text_4,
        O.text_5=N.text_5,
        O.text_6=N.text_6,
        O.value_1=N.value_1,
        O.value_2=N.value_2,
        O.value_3=N.value_3,
        O.value_4=N.value_4,
        O.value_5=N.value_5,
        O.value_6=N.value_6,
        O.value_7=N.value_7,
        O.value_8=N.value_8,
        O.value_9=N.value_9,
        O.value_10=N.value_10,
        O.date_1=N.date_1,
        O.date_2=N.date_2,
        O.date_3=N.date_3,
        O.date_4=N.date_4,
        O.date_5=N.date_5,
        O.date_6=N.date_6,
        O.date_7=N.date_7
        WHERE O.FORECAST_ID = p_new_forecast_id AND O.CARGO_NO = N.CARGO_NO
        WHEN NOT MATCHED THEN
        INSERT(forecast_id,cargo_no,CARGO_NAME,CARRIER_ID,AGENT,SURVEYOR,LAYTIME,EST_ARRIVAL,EST_DEPARTURE,CARGO_STATUS,PROD_FCTY_ID,MASTER,PILOT,TUGS_ARR,TUGS_DEP,DRAUGHT_MARK_ARR_AFT,DRAUGHT_MARK_ARR_CENTER,DRAUGHT_MARK_ARR_FORWARD,DRAUGHT_MARK_DEP_AFT,DRAUGHT_MARK_DEP_CENTER,DRAUGHT_MARK_DEP_FORWARD,VOYAGE_NO,BERTH_ID,
        text_1,text_2,text_3,text_4,text_5,text_6,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,
        created_by)
        VALUES( p_new_forecast_id, N.cargo_no,N.CARGO_NAME,N.CARRIER_ID,N.AGENT,N.SURVEYOR,N.LAYTIME,N.EST_ARRIVAL,N.EST_DEPARTURE,N.CARGO_STATUS,N.PROD_FCTY_ID,N.MASTER,N.PILOT,N.TUGS_ARR,N.TUGS_DEP,N.DRAUGHT_MARK_ARR_AFT,N.DRAUGHT_MARK_ARR_CENTER,N.DRAUGHT_MARK_ARR_FORWARD,N.DRAUGHT_MARK_DEP_AFT,N.DRAUGHT_MARK_DEP_CENTER,N.DRAUGHT_MARK_DEP_FORWARD,N.VOYAGE_NO,N.BERTH_ID,
        N.text_1,N.text_2,N.text_3,N.text_4,N.text_5,N.text_6,N.value_1,N.value_2,N.value_3,N.value_4,N.value_5,N.value_6,N.value_7,N.value_8,N.value_9,N.value_10,N.date_1,N.date_2,N.date_3,N.date_4,N.date_5,N.date_6,N.date_7,
        ecdp_context.getAppUser)
      ;

    -- copy nomination
        MERGE INTO stor_fcst_lift_nom AA
        USING(
        SELECT forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
            text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,cooldown_ind,cooldown_qty,purge_ind,purge_qty,
            ecdp_context.getAppUser, START_LIFTING_DATE, date_9, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3
        FROM  stor_fcst_lift_nom n
        WHERE n.forecast_id = p_forecast_id
            AND n.nom_firm_date >= p_start_date
            AND n.nom_firm_date < p_end_date
            AND COALESCE(n.object_id,'WST') = COALESCE(p_storage_id, n.object_id,'WST')
        ) A
        ON (AA.parcel_no = A.parcel_no and AA.FORECAST_ID = p_new_forecast_id )
        WHEN MATCHED THEN
            UPDATE SET
            AA.cargo_no = A.CARGO_NO,
            AA.lifting_account_id= A.lifting_account_id,
            AA.carrier_id = A.carrier_id,
            AA.consignor_id =A.consignor_id,
            AA.consignee_id = a.consignee_id,
            AA.requested_date = A.requested_date,
            AA.requested_date_range = A.requested_date_range,
            AA.requested_tolerance_type = A.requested_tolerance_type,
            AA.grs_vol_requested = A.grs_vol_requested,
            AA.nom_firm_date = A.nom_firm_date,
            AA.nom_firm_date_range = A.nom_firm_date_range,
            AA.nom_sequence = A.nom_sequence,
            AA.grs_vol_nominated = A.grs_vol_nominated,
            AA.lifting_split_pct = A.lifting_split_pct,
            AA.lifting_split_vol = A.lifting_split_vol,
            AA.lifting_code =A.lifting_code,
            AA.incoterm = A.incoterm,
            AA.contract_id = A.contract_id,
            AA.telex_ref = A.telex_ref,
            AA.graph_value = A.graph_value,
            AA.balance_ind=A.balance_ind,
            AA.grs_vol_schedule=A.grs_vol_schedule,
            AA.schedule_tolerance_type=A.schedule_tolerance_type,
            AA.bl_number=A.bl_number,
            AA.bl_date=A.bl_date,
            AA.unload_date=A.unload_date,
            AA.port_id=A.port_id,
            AA.doc_instr_received_ind=A.doc_instr_received_ind,
            AA.fixed_ind=A.fixed_ind,
            AA.bol_comments=A.bol_comments,
            AA.charter_party=A.charter_party,
            AA.comments=A.comments,
            AA.text_1=A.text_1,
            AA.text_2=A.text_2,
            AA.text_3=A.text_3,
            AA.text_4=A.text_4,
            AA.text_5=A.text_5,
            AA.text_6=A.text_6,
            AA.text_7=A.text_7,
            AA.text_8=A.text_8,
            AA.text_9=A.text_9,
            AA.text_10=A.text_10,
            AA.text_11=A.text_11,
            AA.text_12=A.text_12,
            AA.text_13=A.text_13,
            AA.text_14=A.text_14,
            AA.text_15=A.text_15,
            AA.value_1=A.value_1,
            AA.value_2=A.value_2,
            AA.value_3=A.value_3,
            AA.value_4=A.value_4,
            AA.value_5=A.value_5,
            AA.value_6=A.value_6,
            AA.value_7=A.value_7,
            AA.value_8=A.value_8,
            AA.value_9=A.value_9,
            AA.value_10=A.value_10,
            AA.value_11=A.value_11,
            AA.date_1=A.date_1,
            AA.date_2=A.date_2,
            AA.date_3=A.date_3,
            AA.date_4=A.date_4,
            AA.date_5=A.date_5,
            AA.date_6=A.date_6,
            AA.date_7=A.date_7,
            AA.ref_object_id_1=A.ref_object_id_1,
            AA.ref_object_id_2=A.ref_object_id_2,
            AA.ref_object_id_3=A.ref_object_id_3,
            AA.ref_object_id_4=A.ref_object_id_4,
            AA.ref_object_id_5=A.ref_object_id_5,
            AA.cooldown_ind = A.cooldown_ind,
            AA.cooldown_qty = A.cooldown_qty,
            AA.purge_ind = A.purge_ind,
            AA.purge_qty = A.purge_qty,
            AA.START_LIFTING_DATE=A.START_LIFTING_DATE,
            AA.date_9=A.date_9,
            AA.grs_vol_requested2=A.grs_vol_requested2,
            AA.grs_vol_nominated2=A.grs_vol_nominated2,
            AA.grs_vol_scheduled2=A.grs_vol_scheduled2,
            AA.grs_vol_requested3=A.grs_vol_requested3,
            AA.grs_vol_nominated3=A.grs_vol_nominated3,
            AA.grs_vol_scheduled3=A.grs_vol_scheduled3
            WHERE AA.FORECAST_ID = p_new_forecast_id AND AA.PARCEL_NO = A.PARCEL_NO
        WHEN NOT MATCHED THEN
        INSERT (AA.forecast_id,
            AA.parcel_no,
            AA.object_id,
            AA.cargo_no,
            AA.lifting_account_id,
            AA.carrier_id,
            AA.consignor_id,
            AA.consignee_id,
            AA.requested_date,
            AA.requested_date_range,
            AA.requested_tolerance_type,
            AA.grs_vol_requested,
            AA.nom_firm_date,
            AA.nom_firm_date_range,
            AA.nom_sequence,
            AA.grs_vol_nominated,
            AA.lifting_split_pct,
            AA.lifting_split_vol,
            AA.lifting_code,
            AA.incoterm,
            AA.contract_id,
            AA.telex_ref,
            AA.graph_value,
            AA.balance_ind,
            AA.grs_vol_schedule,
            AA.schedule_tolerance_type,
            AA.bl_number,
            AA.bl_date,
            AA.unload_date,
            AA.port_id,
            AA.doc_instr_received_ind,
            AA.fixed_ind,
            AA.bol_comments,
            AA.charter_party,
            AA.comments,
            AA.text_1,
            AA.text_2,
            AA.text_3,
            AA.text_4,
            AA.text_5,
            AA.text_6,
            AA.text_7,
            AA.text_8,
            AA.text_9,
            AA.text_10,
            AA.text_11,
            AA.text_12,
            AA.text_13,
            AA.text_14,
            AA.text_15,
            AA.value_1,
            AA.value_2,
            AA.value_3,
            AA.value_4,
            AA.value_5,
            AA.value_6,
            AA.value_7,
            AA.value_8,
            AA.value_9,
            AA.value_10,
            AA.value_11,
            AA.date_1,
            AA.date_2,
            AA.date_3,
            AA.date_4,
            AA.date_5,
            AA.date_6,
            AA.date_7,
            AA.ref_object_id_1,
            AA.ref_object_id_2,
            AA.ref_object_id_3,
            AA.ref_object_id_4,
            AA.ref_object_id_5,
            AA.cooldown_ind,
            AA.cooldown_qty,
            AA.purge_ind,
            AA.purge_qty,
            AA.created_by,
            AA.START_LIFTING_DATE,
            AA.date_9,
            AA.grs_vol_requested2,
            AA.grs_vol_nominated2,
            AA.grs_vol_scheduled2,
            AA.grs_vol_requested3,
            AA.grs_vol_nominated3,
            AA.grs_vol_scheduled3
            )
        VALUES (
            p_new_forecast_id,
            A.parcel_no,
            A.object_id,
            A.cargo_no,
            A.lifting_account_id,
            A.carrier_id,
            A.consignor_id,
            A.consignee_id,
            A.requested_date,
            A.requested_date_range,
            A.requested_tolerance_type,
            A.grs_vol_requested,
            A.nom_firm_date,
            A.nom_firm_date_range,
            A.nom_sequence,
            A.grs_vol_nominated,
            A.lifting_split_pct,
            A.lifting_split_vol,
            A.lifting_code,
            A.incoterm,
            A.contract_id,
            A.telex_ref,
            A.graph_value,
            A.balance_ind,
            A.grs_vol_schedule,
            A.schedule_tolerance_type,
            A.bl_number,
            A.bl_date,
            A.unload_date,
            A.port_id,
            A.doc_instr_received_ind,
            A.fixed_ind,
            A.bol_comments,
            A.charter_party,
            A.comments,
            A.text_1,
            A.text_2,
            A.text_3,
            A.text_4,
            A.text_5,
            A.text_6,
            A.text_7,
            A.text_8,
            A.text_9,
            A.text_10,
            A.text_11,
            A.text_12,
            A.text_13,
            A.text_14,
            A.text_15,
            A.value_1,
            A.value_2,
            A.value_3,
            A.value_4,
            A.value_5,
            A.value_6,
            A.value_7,
            A.value_8,
            A.value_9,
            A.value_10,
            A.value_11,
            A.date_1,
            A.date_2,
            A.date_3,
            A.date_4,
            A.date_5,
            A.date_6,
            A.date_7,
            A.ref_object_id_1,
            A.ref_object_id_2,
            A.ref_object_id_3,
            A.ref_object_id_4,
            A.ref_object_id_5,
            A.cooldown_ind,
            A.cooldown_qty,
            A.purge_ind,
            A.purge_qty,
            ecdp_context.getAppUser,
            A.START_LIFTING_DATE,
            A.date_9,
            A.grs_vol_requested2,
            A.grs_vol_nominated2,
            A.grs_vol_scheduled2,
            A.grs_vol_requested3,
            A.grs_vol_nominated3,
            A.grs_vol_scheduled3
            )
            ;

    END IF;
/* --Maybe we can use just insert statement instead of Merge into
    --keep this code
        INSERT INTO stor_fcst_lift_nom (forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
            text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
            created_by, START_LIFTING_DATE, date_9, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3)
        SELECT p_new_forecast_id,parcel_no,object_id,cargo_no,lifting_account_id,carrier_id,consignor_id,consignee_id,requested_date,requested_date_range,requested_tolerance_type,grs_vol_requested,nom_firm_date,nom_firm_date_range,nom_sequence,grs_vol_nominated,lifting_split_pct,lifting_split_vol,lifting_code,incoterm,contract_id,telex_ref,graph_value,balance_ind,grs_vol_schedule,schedule_tolerance_type,bl_number,bl_date,unload_date,port_id,doc_instr_received_ind,fixed_ind,bol_comments,charter_party,comments,
            text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10,text_11,text_12,text_13,text_14,text_15,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,date_1,date_2,date_3,date_4,date_5,date_6,date_7,ref_object_id_1,ref_object_id_2,ref_object_id_3,ref_object_id_4,ref_object_id_5,
            ecdp_context.getAppUser, START_LIFTING_DATE, date_9, grs_vol_requested2, grs_vol_nominated2, grs_vol_scheduled2, grs_vol_requested3, grs_vol_nominated3, grs_vol_scheduled3
        FROM  stor_fcst_lift_nom n
        WHERE n.forecast_id = p_forecast_id
            AND n.nom_firm_date >= p_start_date
            AND n.nom_firm_date < p_end_date
            AND n.object_id = nvl(p_storage_id, n.object_id);
*/

END mergeForecast;

END UE_CT_FCAST_CARGO_PLANNING;
/