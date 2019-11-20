create or replace PACKAGE BODY              UE_CT_CPP_INTERFACE AS

/******************************************************************************
   NAME:       UE_CT_CPP_INTERFACE
   PURPOSE:    Wheatstone CPP Interface Functionality

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7/28/2015      fdsm       1. Created this package.
              Mar-2019       kajy       Item_131778: ISWR02658 WHS CPP - UPG Nomination Process Alignment Changes
******************************************************************************/

    -- Constant to hold portal user string written to .created_by and last_updated by fields
    gvPortalUserUser    t_basis_user.user_id%TYPE := 'WSTPortal';

    -- Constant to hold cpp user string written to .created_by and last_updated by fields. Used in case p_user is null.
    lvCppUser    t_basis_user.user_id%TYPE := 'CPPUser';


/****************************************************************
** Function/Proc  :  fGetJDESettCount
**
** Purpose        :  Re-settlement of the same month may be requried
**                   when a rerun results in a different imbalance
*                    and an unsettled delta at the end of the LY
**
*****************************************************************/
FUNCTION fGetJDESettCount(     p_jde_batch_no IN  cntr_account_event.text_1%TYPE,
                               p_line_no      IN NUMBER,
                               p_curr_sys_mth IN DATE)   RETURN prosty_codes.code%TYPE;

/****************************************************************
** Function/Proc  :  retrieveProductionForecast
**
** Purpose        :  Copy production forecast and availability data
**                   from EC forecast tables that have originated from
**                   Quintiq interfaces WHS-DF-0198 and WHS-DF-0321
**
** Used by        :  called by Retrieve Forecast button on the UPG Nom
**                   volume and energy screens. The retrieved data is also
**                   used by capacity usage.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jun-2015  FDSM      Initial version for Wheatstone implementation
** Apr-2016  FDSM      Removed lng_excess_prod_energy and lng_excess_prod_volume for defect #195
**
*****************************************************************/
PROCEDURE retrieveProductionForecast( p_start_date  in DATE
                                    , p_end_date    in DATE) IS

  lv_plan_type          ctrl_system_attribute.attribute_text%TYPE := ecdp_system.getAttributeText(EcDp_Date_Time.getCurrentSysdate(), 'NQM_FCST_IF_PLAN_TYPE');
  lv_prob_type          ctrl_system_attribute.attribute_text%TYPE := ecdp_system.getAttributeText(EcDp_Date_Time.getCurrentSysdate(), 'NQM_FCST_IF_PROB_TYPE');
  lv_nom_forecast_id    ct_prod_forecast.object_id%TYPE := ecdp_objects.getobjidfromcode('CT_PROD_FORECAST', 'NOM_MC_BASED');

  lv_lng_Strm_id        stream.object_id%TYPE:= ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');
  lv_dg_Strm_id         stream.object_id%TYPE:= ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
  lv_wpt_Strm_id        stream.object_id%TYPE:= ec_stream.object_id_by_uk('SW_PL_NG_FORECAST');

  lv_capl_cntr_id       contract.object_id%TYPE:=  ec_contract.object_id_by_uk('C_CPP_JVP_CVX_CAPL');
  lv_tapl_cntr_id       contract.object_id%TYPE:=  ec_contract.object_id_by_uk('C_CPP_JVP_CVX_TAPL');

  lv_gas_uom            ctrl_unit.unit%TYPE:= ecdp_unit.getUnitFromLogical('STD_GAS_VOL');
  lv_user_id            t_basis_user.user_id%TYPE := EcDp_User_Session.getUserSessionParameter('USERNAME');
  ld_curr_Date          DATE := EcDp_Date_Time.getCurrentSysdate();

BEGIN

    -- AMJ CT_PROD_STRM_PC_FORECAST.VALUE_42 AS LNG_HHV, -- (NettLNGRundownHHVMMBTUM3) potentially required for EQM conversion of Vol to Energy

    -- The Nominations Plan forecast is a continuum, there is no versioning or multiple forecasts
    MERGE INTO nompnt_day_availability nom
    USING(SELECT
             'CT_TRNP_DAY_FCST' AS class_name
            , ue_ct_cpp_util.getDefaultUPGNomPointID(ue_ct_cpp_util.getUPGContractFromField(f.profit_centre_id, f.daytime), f.daytime) AS nompnt_id
            , f.daytime
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.value_36 END)                AS lng_density
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.agrd_cap_lng_export END)     AS agrd_cap_lng_export
            , SUM(CASE WHEN f.object_id = lv_dg_Strm_id  THEN f.domgas_gu_factor_energy END) AS domgas_gu_factor_energy
            , SUM(CASE WHEN f.object_id = lv_dg_Strm_id  THEN f.domgas_gu_factor_volume END) AS domgas_gu_factor_volume
            , SUM(CASE WHEN f.object_id = lv_dg_Strm_id  THEN f.dg_ng_hhv END)               AS dg_ng_hhv
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.train_gu_factor_energy END)  AS train_gu_factor_energy
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.train_gu_factor_volume END)  AS train_gu_factor_volume
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.train_ng_hhv END)            AS train_ng_hhv
            , SUM(CASE WHEN f.object_id = lv_wpt_Strm_id THEN f.wpt_gu_factor_energy END)    AS wpt_gu_factor_energy
            , SUM(CASE WHEN f.object_id = lv_wpt_Strm_id THEN f.wpt_gu_factor_volume END)    AS wpt_gu_factor_volume
            , SUM(CASE WHEN f.object_id = lv_wpt_Strm_id THEN f.wpt_ng_hhv END)              AS wpt_ng_hhv
            , SUM(CASE WHEN f.object_id = lv_wpt_Strm_id THEN ecdp_unit.convertValue(f.forecast_feed_co2, 'MOLPCT', 'MOLFRAC', f.daytime) END) AS forecast_feed_co2
            , SUM(CASE WHEN f.object_id = lv_wpt_Strm_id THEN ecdp_unit.convertValue(f.forecast_feed_n2, 'MOLPCT', 'MOLFRAC', f.daytime) END)  AS forecast_feed_n2
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.lng_bl_volume, 'SM3', lv_gas_uom, f.daytime) END)       AS lng_bl_volume
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.lng_bl_energy END)                                                             AS lng_bl_energy
            , f.ref_object_id_1 AS forecast_object_id
            , f.scenario
            , f.text_10 AS fcst_cpp_id
         FROM ct_prod_strm_pc_forecast f
         WHERE f.daytime >= p_start_date
           AND f.daytime < COALESCE(p_end_date, p_start_date+1)
           AND f.ref_object_id_1 = lv_nom_forecast_id
           AND f.scenario = lv_prob_type
           AND f.forecast_type = lv_plan_type
           AND f.object_id IN (lv_lng_Strm_id, lv_dg_Strm_id, lv_wpt_Strm_id)
         GROUP BY
            ue_ct_cpp_util.getDefaultUPGNomPointID(ue_ct_cpp_util.getUPGContractFromField(f.profit_centre_id, f.daytime), f.daytime)
          , f.daytime
          , f.ref_object_id_1
          , f.scenario
          , f.text_10) fcst
         ON (nom.object_id = fcst.nompnt_id
         AND nom.daytime = fcst.daytime
         AND nom.CLASS_NAME = fcst.class_name)
         WHEN MATCHED THEN
         UPDATE SET
          nom.VALUE_6 = fcst.forecast_feed_n2
        , nom.VALUE_7 = fcst.forecast_feed_co2
        , nom.VALUE_8 = fcst.dg_ng_hhv
        , nom.VALUE_9 = fcst.train_ng_hhv
        , nom.VALUE_11 = fcst.wpt_ng_hhv
        , nom.VALUE_12 = fcst.train_gu_factor_volume
        , nom.VALUE_13 = fcst.train_gu_factor_energy
        , nom.VALUE_14 = fcst.domgas_gu_factor_volume
        , nom.VALUE_15 = fcst.domgas_gu_factor_energy
        , nom.VALUE_16 = fcst.wpt_gu_factor_volume
        , nom.VALUE_17 = fcst.wpt_gu_factor_energy
        , nom.VALUE_20 = fcst.agrd_cap_lng_export
        , nom.VALUE_21 = fcst.lng_density
        , nom.VALUE_18 = fcst.lng_bl_volume
        , nom.VALUE_19 = fcst.lng_bl_energy
        , nom.TEXT_1   = fcst.fcst_cpp_id
        , nom.TEXT_3   = fcst.scenario
        , nom.rev_text = 'Existing forecast data with ID ' || nom.text_1 || ' updated with ID ' || fcst.fcst_cpp_id
        , nom.last_updated_by = COALESCE(lv_user_id, lvCppUser)
       WHEN NOT MATCHED THEN
       INSERT (nom.CLASS_NAME
            , nom.OBJECT_ID
            , nom.DAYTIME
            , nom.VALUE_6
            , nom.VALUE_7
            , nom.VALUE_8
            , nom.VALUE_9
            , nom.VALUE_11
            , nom.VALUE_12
            , nom.VALUE_13
            , nom.VALUE_14
            , nom.VALUE_15
            , nom.VALUE_16
            , nom.VALUE_17
            , nom.VALUE_20
            , nom.VALUE_21
            , nom.VALUE_18        -- Borrow/Loan Volume
            , nom.VALUE_19        -- Borrow/Loan Energy
            , nom.TEXT_1
            , nom.TEXT_3
            , nom.REV_TEXT
            , nom.created_by)
     VALUES ( fcst.class_name
            , fcst.nompnt_id
            , fcst.DAYTIME
            , fcst.forecast_feed_n2
            , fcst.forecast_feed_co2
            , fcst.dg_ng_hhv
            , fcst.train_ng_hhv
            , fcst.wpt_ng_hhv
            , fcst.train_gu_factor_volume
            , fcst.train_gu_factor_energy
            , fcst.domgas_gu_factor_volume
            , fcst.domgas_gu_factor_energy
            , fcst.wpt_gu_factor_volume
            , fcst.wpt_gu_factor_energy
            , fcst.agrd_cap_lng_export
            , fcst.lng_density
            , fcst.lng_bl_volume
            , fcst.lng_bl_energy
            , fcst.fcst_cpp_id
            , fcst.scenario
            , 'New forecast data with ID ' || fcst_cpp_id || ' loaded'
            , COALESCE(lv_user_id, lvCppUser));

    -- Load the availability and the forecast flow data
    -- Aggregate JVP to UPG level
    -- Note that fcst_cpp_id does exist at record level in the source forecast table
    MERGE INTO nompnt_day_availability nom
     USING( SELECT
                 'TRNP_DAY_AVAILABILITY' AS class_name
                , CASE WHEN GROUPING_ID(tv.jvp_nompnt_id) = 1 THEN tv.upg_nompnt_id ELSE tv.jvp_nompnt_id END AS nompnt_id
                , tv.daytime
                , SUM(tv.uom_factor * tv.avail_cap_qty)         AS avail_cap_qty
                , SUM(tv.uom_factor * tv.adj_avail_cap_qty)     AS adj_avail_cap_qty
                , SUM(tv.uom_factor * tv.forecast_flow_qty)     AS forecast_flow_qty
                , SUM(tv.forecast_flow_qty_gj)                  AS forecast_flow_qty_gj
                , tv.fcst_cpp_id
            FROM
               (SELECT
                    ue_ct_Cpp_util.ConvQtyUoMToDelpntDB(ec_nomination_point.delivery_point_id(t.object_id), DECODE(UPPER(t.uom), 'T', 'TONNES', UPPER(t.uom)), t.daytime, 1) AS uom_factor
                  , ue_ct_Cpp_util.getNompntFromCntrDelpnt(ec_contract_version.parent_Contract_id(NVL(NULLIF(ec_nomination_point.contract_id(t.object_id), lv_capl_cntr_id), lv_tapl_cntr_id), t.daytime, '<='), ec_nomination_point.delivery_point_id(t.object_id)) AS upg_nompnt_id
                  , CASE WHEN ec_nomination_point.contract_id(t.object_id) = lv_capl_cntr_id THEN ue_ct_Cpp_util.getNompntFromCntrDelpnt(lv_tapl_cntr_id, ec_nomination_point.delivery_point_id(t.object_id))  ELSE t.object_id END AS jvp_nompnt_id
                  , t.*
                FROM ct_trnp_avail_cap_fcst t
                WHERE t.daytime BETWEEN p_start_date AND COALESCE(p_end_date - 1, p_start_date)
                 AND t.ref_object_id_1 = lv_nom_forecast_id
                 AND t.scenario = lv_prob_type
                 AND t.forecast_type = lv_plan_type) tv
            GROUP BY GROUPING SETS ((tv.upg_nompnt_id, tv.jvp_nompnt_id, tv.daytime, tv.fcst_cpp_id), (tv.upg_nompnt_id, tv.daytime, tv.fcst_cpp_id))) fcst
        ON (nom.object_id = fcst.nompnt_id
        AND nom.daytime = fcst.daytime
        AND nom.class_name = fcst.class_name)
        WHEN MATCHED THEN
        UPDATE SET
              nom.text_2 =  fcst.fcst_cpp_id
            , nom.value_1 = fcst.avail_cap_qty
            , nom.value_5 = NULL    -- cancel out any stored prior 'old' capacity that may have been replaced by a recalculated value by the CU calculations
            , nom.value_2 = fcst.adj_avail_cap_qty
            , nom.value_3 = fcst.forecast_flow_qty
            , nom.value_4 = fcst.forecast_flow_qty_gj
            , nom.rev_no = NVL(nom.rev_no, 0) + 1
            , nom.rev_text = 'Existing forecast data with ID ' || nom.text_1 || ' updated with ID ' || fcst.fcst_cpp_id
            , nom.last_updated_by = COALESCE(lv_user_id, lvCppUser)
        WHEN NOT MATCHED THEN
        INSERT (  nom.object_id
                , nom.daytime
                , nom.class_name
                , nom.text_2
                , nom.value_1
                , nom.value_2
                , nom.value_3
                , nom.value_4
                , nom.rev_text
                , nom.created_by)
        VALUES  ( fcst.nompnt_id
                , fcst.daytime
                , fcst.class_name
                , fcst.fcst_cpp_id
                , fcst.avail_cap_qty
                , fcst.adj_avail_cap_qty
                , fcst.forecast_flow_qty
                , fcst.forecast_flow_qty_gj
                , 'New forecast data with ID ' || fcst.fcst_cpp_id || ' has been loaded'
                , COALESCE(lv_user_id, lvCppUser));

     -- Some values also go directly to the main Nomination table required for ENQ calculation
    MERGE INTO nompnt_day_nomination nom
    USING( SELECT
             'TRAN_INPUT' AS nom_type
            , ue_ct_cpp_util.getDefaultUPGNomPointID(ue_ct_cpp_util.getUPGContractFromField(f.profit_centre_id, f.daytime), f.daytime) AS nompnt_id
            , f.daytime

            -- note Ref Prod is LNG but is stored against the Domgas stream in the source forecast table
            , SUM(CASE WHEN f.object_id = lv_dg_Strm_id  THEN ecdp_unit.convertValue(f.ref_prod_std_volume, 'SM3', lv_gas_uom, f.daytime) END)      AS ref_prod_std_volume
            , SUM(CASE WHEN f.object_id = lv_dg_Strm_id  THEN f.ref_prod_energy END)                                                                AS ref_prod_energy

            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.confirmed_excess_volume, 'SM3', lv_gas_uom, f.daytime) END)  AS confirmed_excess_volume
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.confirmed_excess_energy END)                                                        AS confirmed_excess_energy

            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.lng_regas_req_gas, 'SM3', lv_gas_uom, f.daytime) END)        AS lng_regas_req_gas
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.lng_regas_req_energy END)                                                           AS lng_regas_req_energy

            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.lng_unmet_amt_vol, 'SM3', lv_gas_uom, f.daytime) END)        AS lng_unmet_amt_vol
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.lng_unmet_amt_energy END)                                                           AS lng_unmet_amt_energy

            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.adp_lng_req_volume, 'SM3', lv_gas_uom, f.daytime) END)       AS adp_lng_req_volume
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.adp_lng_req_energy END)                                                             AS adp_lng_req_energy

            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN ecdp_unit.convertValue(f.lng_ngi_adjust_vol, 'SM3', lv_gas_uom, f.daytime) END)       AS lng_ngi_adjust_vol
            , SUM(CASE WHEN f.object_id = lv_lng_Strm_id THEN f.lng_ngi_adjust_energy END)                                                          AS lng_ngi_adjust_energy

            , f.text_10 AS fcst_cpp_id
            , ld_curr_Date AS last_retrieval_date
           FROM ct_prod_strm_pc_forecast f
           WHERE f.daytime >= p_start_date
             AND f.daytime < COALESCE(p_end_date, p_start_date+1)
             AND f.ref_object_id_1 = lv_nom_forecast_id
             AND f.scenario = lv_prob_type
             AND f.forecast_type = lv_plan_type
             AND f.object_id IN (lv_lng_Strm_id, lv_dg_Strm_id)
           GROUP BY
                ue_ct_cpp_util.getDefaultUPGNomPointID(ue_ct_cpp_util.getUPGContractFromField(f.profit_centre_id, f.daytime), f.daytime)
              , f.daytime
              , f.ref_object_id_1
              , f.scenario
              , f.text_10) fcst
      ON (nom.object_id = fcst.nompnt_id
      AND nom.daytime = fcst.daytime
      AND nom.nomination_type = fcst.nom_type)
    WHEN MATCHED THEN
    UPDATE SET
          nom.value_41 = fcst.ref_prod_std_volume       -- Ref prod vol
        , nom.value_48 = fcst.ref_prod_energy           -- Ref prod energy

        , nom.value_42 = fcst.confirmed_excess_volume   -- CEQ Vol
        , nom.value_49 = fcst.confirmed_excess_energy   -- CEQ Energy

        , nom.value_43 = fcst.lng_regas_req_gas         -- Regas Vol
        , nom.value_50 = fcst.lng_regas_req_energy      -- Regas Energy

        , nom.value_45 = fcst.lng_unmet_amt_vol         -- Unmet Vol
        , nom.value_52 = fcst.lng_unmet_amt_energy      -- Unmet Energy

        , nom.value_7  = fcst.adp_lng_req_volume        -- Adj ADP Req vol
        , nom.value_23 = fcst.adp_lng_req_energy        -- Adj ADP Req energy

        , nom.value_46 = fcst.lng_ngi_adjust_vol        -- NGI Adjustment Vol
        , nom.value_53 = fcst.lng_ngi_adjust_energy     -- NGI Adjustment energy

        , nom.text_13 = fcst.fcst_cpp_id
        , nom.nom_status =  'NQM_NOM_PROVISIONAL'
        , nom.DATE_5 =      fcst.LAST_RETRIEVAL_DATE
        , nom.rev_no =      COALESCE(nom.rev_no, 0) + 1
        , nom.rev_text =    'Existing forecast data with ID ' || nom.text_1 || ' updated with ID ' || fcst.fcst_cpp_id
        , nom.last_updated_by = COALESCE(lv_user_id, lvCppUser)
    WHEN NOT MATCHED THEN
    INSERT   (nom.object_id
            , nom.daytime
            , nom.nomination_type

            , nom.value_41 -- Ref prod vol
            , nom.value_48 -- Ref prod energy

            , nom.value_42 -- CEQ vol
            , nom.value_49 -- CEQ energy

            , nom.value_43 -- Regas vol
            , nom.value_50 -- Regas energy

            , nom.value_45 -- Unmet vol
            , nom.value_52 -- Unmet energy

            , nom.value_7  -- Adj ADP Req vol
            , nom.value_23 -- Adj ADP Req energy

            , nom.value_46 -- NGI Adjustment vol
            , nom.value_53 -- NGI Adjustment energy

            , nom.text_13
            , nom.nom_status
            , nom.DATE_5
            , nom.rev_text
            , nom.created_by)

    VALUES (  fcst.nompnt_id
            , fcst.daytime,fcst.nom_type

            , fcst.ref_prod_std_volume      -- Ref prod vol
            , fcst.ref_prod_energy          -- Ref prod energy

            , fcst.confirmed_excess_volume  -- CEQ vol
            , fcst.confirmed_excess_energy  -- CEQ energy

            , fcst.lng_regas_req_gas        -- Regas vol
            , fcst.lng_regas_req_energy     -- Regas energy

            , fcst.lng_unmet_amt_vol        -- Unmet vol
            , fcst.lng_unmet_amt_energy     -- Unmet energy

            , fcst.adp_lng_req_volume       -- Adj ADP Req vol
            , fcst.adp_lng_req_energy       -- Adj ADP Req energy

            , fcst.lng_ngi_adjust_vol       -- NGI Adjustment vol
            , fcst.lng_ngi_adjust_energy    -- NGI Adjustment energy

            , fcst.fcst_cpp_id
            , 'NQM_NOM_PROVISIONAL'
            , fcst.LAST_RETRIEVAL_DATE
            , 'New forecast data with ID ' || fcst.fcst_cpp_id || ' has been loaded'
            , COALESCE(lv_user_id, lvCppUser));

  END retrieveProductionForecast;


/*
* WHS-DF-0927
*   Retrieve the changed DNQ values from domgas.
*   Requires retesting when DOMGAS is fully implemented!
*/
PROCEDURE retrieveDomgasDNQ(p_start_date        in DATE
                          , p_end_date          in DATE
                          , p_nom_cycle_code    in nomination_cycle.NOM_CYCLE_CODE%type) IS

  lv_plan_type          ctrl_system_attribute.attribute_text%TYPE := ecdp_system.getAttributeText(EcDp_Date_Time.getCurrentSysdate(), 'NQM_FCST_IF_PLAN_TYPE');
  lv_prob_type          ctrl_system_attribute.attribute_text%TYPE := ecdp_system.getAttributeText(EcDp_Date_Time.getCurrentSysdate(), 'NQM_FCST_IF_PROB_TYPE');
  lv_nom_forecast_id    ct_prod_forecast.object_id%TYPE := ecdp_objects.getobjidfromcode('CT_PROD_FORECAST', 'NOM_MC_BASED');
  lv_dg_Strm_id         stream.object_id%TYPE:= ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
  lv_delpnt_id          delivery_point.OBJECT_ID%type := ec_delivery_point.object_id_by_uk('DP_WST_DG_NG');
  lv_contract_area_id   contract_area.OBJECT_ID%type := ec_contract_area.object_id_by_uk('CA_WST_DOMGAS_SELLERS');
  lv_cur_year_fcst_id   forecast.OBJECT_ID%type;
  lv_prev_year_fcst_id  forecast.OBJECT_ID%type;
  ld_ly_start_date      DATE := ue_ct_cpp_util.getLiftingYearStartDate(p_start_date);

  --Domgas is using both the pland and the lateral delivery point. We only want the lateral delivery point
  lv_domgas_delpnt_id   delivery_point.OBJECT_ID%type := ec_delivery_point.object_id_by_uk('DP_I3_03_WHEATSTONE');

  lv_user_id            t_basis_user.user_id%TYPE := EcDp_User_Session.getUserSessionParameter('USERNAME');

BEGIN

    /*
    *   get the latest approved forecast id for this year
    *   because of the domgas gasday / productionday conversion  we need the previous year fcst as well
    *
    */
    SELECT MAX(CASE WHEN start_date != ld_ly_start_date THEN object_id END )
         , MAX(CASE WHEN start_date = ld_ly_start_date  THEN object_id END ) INTO lv_prev_year_fcst_id, lv_cur_year_fcst_id
    FROM (SELECT MAX(NVL( f.last_updated_date, f.created_date)) OVER (PARTITION BY start_date) AS max_update_date
               , f.object_id
               , f.start_date
               , NVL( f.last_updated_date, f.created_date) AS forecast_update_date
            FROM forecast f
            JOIN forecast_version v
              ON f.object_id = v.object_id
           /*
           * Awaiting change request to include the R_DGAF as well
           *
           */
       --    WHERE v.text_6 = 'DGAF'
           WHERE v.text_6 IN ('DGAF', 'R_DGAF')     --Item_131778: ISWR02658: R_DGAF included to get latest forecast 
             AND v.text_5 = 'A'
             AND (f.start_date = ld_ly_start_date
              OR f.end_date = ld_ly_start_date))
           WHERE forecast_update_date = max_update_date;

      merge into nompnt_day_nomination jvp_nom
      using (
      with upg as(select contract_id
                       , daytime
                       , 'TRAN_INPUT'
                       , dnq_ene as dnq_gas_day_ene
                       , case when fcst_prod_day = 0 then
                           0
                         when yesterday_fcst_gas_day = yesterday_dnq_ene and fcst_gas_day = dnq_ene then
                            fcst_prod_day
                          when yesterday_fcst_gas_day <> yesterday_dnq_ene or fcst_gas_day <> dnq_ene then
                            fcst_prod_day + (yesterday_dnq_ene - yesterday_fcst_gas_day) * ((fcst_prod_day/3)/nullif((yesterday_fcst_prod_day*(2/3)+fcst_prod_day/3),0)) + (dnq_ene - fcst_gas_day) * ((2/3*fcst_prod_day)/nullif(((2/3*fcst_prod_day)+(tomorrow_fcst_prod_day/3)),0))
                          end as dnq_prod_day_ene
                    from (select cv.parent_contract_id as contract_id
                               , dnq.daytime
                               , sum(dnq_gas_day) as dnq_ene
                               , LAG(sum(dnq_gas_day) , 1, 0) OVER (PARTITION BY cv.parent_contract_id ORDER BY dnq.daytime) AS yesterday_dnq_ene
                               , max(f.value_44) as fcst_prod_day
                               , LAG(max(f.value_44) , 1, 0) OVER (PARTITION BY cv.parent_contract_id ORDER BY dnq.daytime) AS yesterday_fcst_prod_day
                               , LEAD(max(f.value_44) , 1, 0) OVER (PARTITION BY cv.parent_contract_id ORDER BY dnq.daytime) AS tomorrow_fcst_prod_day
                               , max(f.value_47) as fcst_gas_day
                               , LAG(max(f.value_47) , 1, 0) OVER (PARTITION BY cv.parent_contract_id ORDER BY dnq.daytime) AS yesterday_fcst_gas_day
                            from (select y.daytime
                                       , y.object_id
                                       , CASE WHEN p_nom_cycle_code = 'NC_WST_CPP_INTRA_DAY' THEN
                                            COALESCE(i.dnq_gas_day,d.value_5) --dutch i.dnq_gas_day
                                         WHEN p_nom_cycle_code = 'NC_WST_CPP_DAY' THEN
                                            d.value_5
                                         WHEN p_nom_cycle_code = 'NC_WST_CPP_WEEK' THEN
                                            w.value_7
                                         ELSE
                                            y.value_2
                                         END AS dnq_gas_day
                                    from fcst_cntr_day_status y
                                    full outer join cntr_day_dp_forecast w
                                      on y.object_id = w.object_id
                                     and y.daytime = w.daytime
                                     and w.delivery_point_id = lv_domgas_delpnt_id
                                    full outer join cntr_day_dp_nom d
                                      on d.object_id = y.object_id
                                     and d.daytime = y.daytime
                                     and d.delivery_point_id = w.delivery_point_id
                                     full outer join cv_msg_dnq_intra_day i
                                       on d.object_id = i.object_id
                                      and d.daytime = i.gasday
                                      and d.delivery_point_id = i.delivery_point_id
                                   where y.forecast_id in (lv_cur_year_fcst_id, lv_prev_year_fcst_id)
                                     and (i.record_status = 'A'
                                      or  d.record_status = 'A'
                                      or  w.record_status = 'A'
                                      or  y.record_status = 'A')
                                      --DUTCH and ((p_nom_cycle_code = 'NC_WST_CPP_INTRA_DAY' AND i.dnq_gas_day is not null) or (p_nom_cycle_code != 'NC_WST_CPP_INTRA_DAY' AND i.dnq_gas_day is null))
                                      ) dnq
                                       , contract_version cv
                                       , cntr_pc_conn pc
                                       , ct_prod_strm_pc_forecast f
                                   where dnq.daytime >= p_start_date - 2
                                     and dnq.daytime < COALESCE(p_end_date+1, p_start_date+2)
                                     and cv.object_id = dnq.object_id
                                     and cv.parent_contract_id = pc.object_id
                                     and f.profit_centre_id = pc.profit_centre_id
                                     and f.daytime = dnq.daytime
                                     and f.object_id = lv_dg_Strm_id
                                     and f.ref_object_id_1 = lv_nom_forecast_id
                                     and f.scenario = lv_prob_type
                                     and f.forecast_type = lv_plan_type
                                   group by dnq.daytime, cv.parent_contract_id, pc.object_id, f.profit_centre_id)
      )  --end with
      select dnqs.jvp_nompnt_id
           , dnqs.parent_contract_id
           , dnqs.daytime
           , dnqs.parent_nomination_seq
           , dnqs.nomination_type
           , case when upg.dnq_gas_day_ene <> 0 then (upg.dnq_prod_day_ene / nullif(upg.dnq_gas_day_ene,0)) * dnqs.dnq_gas_day_ene else 0 end as jvp_dnq_ene
            --, case when upg.dnq_gas_day_ene <> 0 then ((upg.dnq_prod_day_ene / nullif(upg.dnq_gas_day_ene,0)) * dnqs.dnq_gas_day_ene)/dg_hhv else 0 end as jvp_dnq_vol
           , case WHEN NVL(upg.dnq_prod_day_ene,0)=0 THEN 0 when upg.dnq_gas_day_ene <> 0 then ((upg.dnq_prod_day_ene / nullif(upg.dnq_gas_day_ene,0)) * dnqs.dnq_gas_day_ene)/dg_hhv else 0 end as jvp_dnq_vol
           --, (upg.dnq_prod_day_ene / nullif(upg.dnq_gas_day_ene,0)) * dnqs.dnq_gas_day_ene  as jvp_dnq_ene
           --, ((upg.dnq_prod_day_ene / nullif(upg.dnq_gas_day_ene,0)) * dnqs.dnq_gas_day_ene)/dg_hhv as jvp_dnq_vol
        from (select dnq2.object_id AS jvp_nompnt_id
                   , dnq2.daytime AS daytime
                   , ndn.nomination_seq AS parent_nomination_seq
                   , 'TRAN_INPUT' AS nomination_type
                   , nullif(ec_nompnt_day_availability.value_8(ndn.object_id, ndn.daytime, 'CT_TRNP_DAY_FCST'), 0) AS dg_hhv
                   , dnq2.dnq_gas_day as dnq_gas_day_ene
                   , parent_contract_id
                   , cpp_parent_contract_id
                from (select dnq.daytime
                           , np.object_id
                           , dnq.dnq_gas_day
                           , cv_1.parent_contract_id as parent_contract_id
                           , cv_2.parent_contract_id as cpp_parent_contract_id
                        from  (select y.daytime
                                    , y.object_id
                                    , CASE WHEN p_nom_cycle_code = 'NC_WST_CPP_INTRA_DAY' THEN
                                           COALESCE(i.dnq_gas_day,d.value_5) --dutch i.dnq_gas_day
                                       WHEN p_nom_cycle_code = 'NC_WST_CPP_DAY' THEN
                                           d.value_5
                                       WHEN p_nom_cycle_code = 'NC_WST_CPP_WEEK' THEN
                                            w.value_7
                                       ELSE
                                           y.value_2
                                       END AS dnq_gas_day
                                 from fcst_cntr_day_status y
                                      full outer join cntr_day_dp_forecast w
                                      on y.object_id = w.object_id
                                      and y.daytime = w.daytime
                                      and w.delivery_point_id = lv_domgas_delpnt_id
                                      full outer join cntr_day_dp_nom d
                                      on d.object_id = y.object_id
                                      and d.daytime = y.daytime
                                      and d.delivery_point_id = w.delivery_point_id
                                      full outer join cv_msg_dnq_intra_day i
                                       on d.object_id = i.object_id
                                      and d.daytime = i.gasday
                                      and d.delivery_point_id = i.delivery_point_id
                                      where y.forecast_id in  (lv_cur_year_fcst_id, lv_prev_year_fcst_id)
                                      and (i.record_status = 'A'
                                      or  d.record_status = 'A'
                                      or  w.record_status = 'A'
                                      or  y.record_status = 'A')
                                      --dutch and ((p_nom_cycle_code = 'NC_WST_CPP_INTRA_DAY' AND i.dnq_gas_day is not null) or (p_nom_cycle_code != 'NC_WST_CPP_INTRA_DAY' AND i.dnq_gas_day is null))
                                      ) dnq
                                                                , contract_version cv_1
                                                                , contract_version cv_2
                                                                , nomination_point np
                                                                where dnq.daytime >= p_start_date - 1
                                                                and dnq.daytime < COALESCE(p_end_date, p_start_date+1)
                                                                and dnq.object_id = cv_1.object_id
                                                                and cv_1.contract_area_id = lv_contract_area_id
                                                                and cv_1.company_id = cv_2.company_id
                                                                and cv_2.object_id = np.contract_id
                                                                and np.delivery_point_id = lv_delpnt_id) dnq2
                                                                                                        inner join nompnt_day_nomination ndn
                                                                                                        on dnq2.cpp_parent_contract_id = ndn.contract_id
                                                                                                        and dnq2.daytime = ndn.daytime
                                                                                                        where ndn.nomination_type = 'TRAN_INPUT'
                                                                                                        and ndn.ref_nomination_seq IS NULL) dnqs
                                                                                                        , upg --refer to with clause
                                                                                                        where dnqs.daytime >= p_start_date
                                                                                                          and dnqs.parent_contract_id = upg.contract_id
                                                                                                          and dnqs.daytime = upg.daytime) converted_dnqs
      on (jvp_nom.object_id = converted_dnqs.jvp_nompnt_id --continue merge
      and jvp_nom.daytime = converted_dnqs.daytime
      and jvp_nom.ref_nomination_seq = converted_dnqs.parent_nomination_seq
      and jvp_nom.nomination_type = converted_dnqs.nomination_type)
      when not matched then
      insert (jvp_nom.object_id
           , jvp_nom.daytime
           , jvp_nom.ref_nomination_seq
           , jvp_nom.nomination_type
           , jvp_nom.value_12
           , jvp_nom.value_28
           , jvp_nom.rev_text
           , jvp_nom.last_updated_by)
      values (converted_dnqs.jvp_nompnt_id
           , converted_dnqs.daytime
           , converted_dnqs.parent_nomination_seq
           , converted_dnqs.nomination_type
           , converted_dnqs.jvp_dnq_vol
           , converted_dnqs.jvp_dnq_ene
           , 'New JVP records created and pro rated with DNQ'
           , coalesce(lv_user_id, lvcppuser))
        when matched then
        update set jvp_nom.value_12 = converted_dnqs.jvp_dnq_vol
                 , jvp_nom.value_28 = converted_dnqs.jvp_dnq_ene
                 , jvp_nom.rev_no = coalesce(jvp_nom.rev_no, 0) + 1
                 , jvp_nom.rev_text = 'Update existing DNQ data with new pro rated DNQ.'
                 , jvp_nom.last_updated_by = coalesce(lv_user_id, lvcppuser);



   --Update the last retrieval date for the Last Run Dat esection on the period upg nominatiopn screen
   UPDATE NOMPNT_DAY_NOMINATION
      SET DATE_6 = SYSDATE
        , TEXT_12 = p_nom_cycle_code
    WHERE DAYTIME >= p_start_date
      AND DAYTIME < COALESCE(p_end_date, p_start_date+1)
      AND NOMINATION_TYPE = 'TRAN_INPUT'
      AND REF_NOMINATION_SEQ IS NULL;

END retrieveDomgasDNQ;

/****************************************************************
** Function/Proc  :  LoadJDESettlementConf
**
** Purpose        :  WHS-DF-0359 EC Inbound UPG Capacity Usage <Settled>
**                   Called by ECIS JDE rowadapter to create monthly
*                    contract event records from the incoming files
*
*                    Settlements are loaded with a daytime corresponding
*                    to the current month in which they are received,
*                    unless the override date is supplied which is
*                    used for testing such as rerunning for a past month
*
*                    If running for a past month when testing pass in the
*                    month in which you want the events to be loaded against
*                    via the p_curr_date_override argument
*
*****************************************************************/
PROCEDURE LoadJDESettlementConf( p_jde_batch_no         IN  cntr_account_event.text_1%TYPE,
                                 p_line_no              IN NUMBER,
                                 p_posting_edit_code    IN VARCHAR2,
                                 p_curr_date_override   IN DATE DEFAULT NULL)
IS
    ld_curr_sys_mth    DATE := TRUNC(COALESCE(p_curr_date_override, EcDp_Date_Time.getCurrentSysdate()), 'MON');
    lvSettTypeCode     cntr_account_event.event_type%TYPE;
    lvCurrOraTranID    VARCHAR2(32) := dbms_transaction.local_transaction_id(TRUE);
BEGIN

    -- Return an enumerated 'CU_SETTLEMENT' code to handle multiple settlements for a single month, cannot run in the SQL
    lvSettTypeCode := fGetJDESettCount(p_jde_batch_no, p_line_no, ld_curr_sys_mth);

    ecdp_dynsql.writetemptext('UE_CT_CPP_INTERFACE:JDE', 'LoadJDESettlementConf [' || lvSettTypeCode || ' - ' || TO_CHAR(ld_curr_sys_mth, 'Mon-YYYY') || ' - ' || dbms_transaction.local_transaction_id || '] BatchNo: ''' || p_jde_batch_no|| ''', Line No:'||p_line_no|| ', PostEdtCode:'''||p_posting_edit_code||'''');

     MERGE INTO cntr_account_event sett
     USING( SELECT
                ld_curr_sys_mth AS daytime
              , dv.object_id
              , dv.account_code
              , dv.cuib_eom AS qty
              , dv.jde_batch_no
              , dv.jde_line_no
              , dv.daytime AS invoice_mth
            FROM dv_sctr_acc_mth_cpy_status dv
            WHERE dv.jde_batch_no = p_jde_batch_no
            AND dv.jde_line_no = p_line_no ) inv
     ON (sett.daytime = inv.daytime
     AND sett.object_id = inv.object_id
     AND sett.account_code = inv.account_code
     AND sett.text_1 = inv.jde_batch_no) -- CR#60 batch included in join
    WHEN MATCHED THEN
    UPDATE SET
          sett.accept_ind = sett.accept_ind -- 'N' Do not try to reapply, this should not happen
        , sett.event_qty = CASE WHEN sett.text_4 = lvCurrOraTranID OR sett.accept_ind = 'Y' THEN sett.event_qty ELSE inv.qty END
        , sett.text_3 = CASE WHEN sett.text_4 = lvCurrOraTranID THEN CASE WHEN NVL(INSTR(sett.text_3, inv.jde_line_no),0) = 0 THEN sett.text_3 || ',' || inv.jde_line_no ELSE sett.text_3 END ELSE TO_CHAR(inv.jde_line_no) END
        , sett.text_4 = lvCurrOraTranID
        , sett.text_2 = CASE WHEN sett.text_4 = lvCurrOraTranID OR sett.accept_ind = 'Y' THEN sett.text_2 ELSE p_posting_edit_code END
        , sett.rev_text = CASE WHEN sett.text_4 = lvCurrOraTranID THEN sett.rev_text ELSE
                            CASE WHEN sett.accept_ind = 'Y' THEN 'Existing accepted settlement with posting edit code ''' || p_posting_edit_code || ''' was resent by JDE, no changes were applied due to accepted status'
                                 ELSE 'Existing unaccepted settlement was resent by JDE, values were updated' END END
        , sett.last_updated_by = CASE WHEN sett.text_4 = lvCurrOraTranID THEN sett.last_updated_by ELSE NVL(EcDp_User_Session.getUserSessionParameter('USERNAME'), 'CPP Interface') END
    WHEN NOT MATCHED THEN
    INSERT (  sett.object_id
            , time_span
            , event_type
            , sett.daytime
            , sett.account_code
            , sett.event_qty
            , sett.text_1
            , sett.text_3
            , sett.text_2
            , sett.accept_ind
            , sett.date_1
            , sett.text_4
            , sett.rev_text
            , sett.created_by)
    VALUES  ( inv.object_id
            , 'MTH'
            , lvSettTypeCode
            , inv.daytime
            , inv.account_Code
            , inv.qty
            , inv.jde_batch_no
            , inv.jde_line_no
            , p_posting_edit_code
            , 'N'
            , inv.invoice_mth
            , lvCurrOraTranID
            , 'Settlement confirmation received from JDE with posting edit code: ' || p_posting_edit_code
            , NVL(EcDp_User_Session.getUserSessionParameter('USERNAME'), 'CPP Interface'));

 EXCEPTION
    WHEN OTHERS THEN
    ecdp_dynsql.WRITETEMPTEXT ('UE_CT_CPP_INTERFACE:JDE','Unexpected error for date [' || TO_CHAR(ld_curr_sys_mth, 'YYYY-MON') || '] with BatchNo [' || p_jde_batch_no || '] and LineNo [' || p_line_no || ']:' || SQLERRM );
    RAISE;

END LoadJDESettlementConf;


/****************************************************************
** Function/Proc  :  fGetJDESettCount
**
** Purpose        :  Re-settlement of the same month may be requried
**                   when a rerun results in a different imbalance
*                    and an unsettled delta at the end of the LY
*
*                    Note this cannot be called inline in the SQL
*                    of the merge statement in LoadJDESettlementConf
*                    due to mutating trigger, unfortunately.
*
*****************************************************************/
FUNCTION fGetJDESettCount(     p_jde_batch_no IN  cntr_account_event.text_1%TYPE,
                               p_line_no      IN NUMBER,
                               p_curr_sys_mth IN DATE)   RETURN prosty_codes.code%TYPE
IS
    lvSettTypeCode  prosty_codes.code%TYPE := 'CU_SETTLEMENT';
    lvContract_id   cntracc_per_cpy_status.object_id%TYPE;
    lvCntrAccCode   cntracc_per_cpy_status.account_code%TYPE;
    lnExistingCount NUMBER;
BEGIN

    BEGIN
        -- Need to get the key fields from the non-key batch and line number
        SELECT object_id, account_code INTO lvContract_id, lvCntrAccCode
        FROM cntracc_per_cpy_status inv
        WHERE inv.text_3 = p_jde_batch_no
        AND inv.value_9 = p_line_no
        AND ROWNUM = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20911, 'Could not identify the originating CU invoice record in cntracc_per_cpy_status for this batch_no and line_no');
    END;

    BEGIN

        -- Now get the count of existing settlements using the key fields
        SELECT COUNT(*) INTO lnExistingCount
        FROM cntr_account_event sett
        WHERE sett.object_id = lvContract_id
        AND sett.daytime = p_curr_sys_mth
        AND sett.account_code = lvCntrAccCode
        AND sett.text_1 <> p_jde_batch_no ;

        IF lnExistingCount >= 9 THEN
            RAISE_APPLICATION_ERROR(-20910, 'Maximum number of settlements per contract and capacity point has been reached');
        END IF;

        RETURN lvSettTypeCode || '_' || TO_CHAR(lnExistingCount + 1);
    EXCEPTION
        WHEN OTHERS THEN
            ecdp_dynsql.WRITETEMPTEXT ('UE_CT_CPP_INTERFACE:JDE','fGetJDESettCount: Unexpected error with Contract [' || ec_contract.object_code(lvContract_id) || '] and AccountCode [' || lvCntrAccCode || ']:' || SQLERRM );
            RAISE;
    END;

END fGetJDESettCount;


/****************************************************************
** Function/Proc  :  GetDelpntIDVMapping
**
** Purpose        :  Used by WHS-DF-0323 - CNQ to Quintic
**                   Gets the IDV  / Quintiq Cpacity point value
*                    which is UPG-specific for the WPT inlets
**
*****************************************************************/
FUNCTION GetDelpntIDVMapping(  p_contract_id   IN contract.object_id%TYPE
                           ,   p_delpnt_id     IN delivery_point.object_id%TYPE
                           ,   p_daytime       IN DATE)
                                               RETURN mhm_message_value_mapping.source_value%TYPE
IS
    lvDelpntCode    delivery_point.object_code%TYPE := ec_delivery_point.object_code(p_delpnt_id);
    lvCntrCode      contract.object_Code%TYPE;
    lvValueIDV      mhm_message_value_mapping.source_value%TYPE;
BEGIN

    -- Get the Quintiq value
    SELECT mm.source_value INTO lvValueIDV
    FROM
       (SELECT m.source_value
        FROM mhm_message_value_mapping m
        WHERE m.target_value = lvDelpntCode
        AND m.source_id = 'QUINTIQ_DP_CPP'
        AND m.daytime <= p_daytime
        ORDER BY m.daytime DESC) mm
    WHERE ROWNUM = 1;

    -- Append a UPG specific suffix
    IF lvDelpntCode = 'DP_WST_WPT_NG' THEN
        lvCntrCode := ec_contract.object_code(p_contract_id);
        lvValueIDV := lvValueIDV || CASE lvCntrCode WHEN 'C_CPP_UPG_WST_IAG' THEN 'WI' WHEN 'C_CPP_UPG_JUL_BRU' THEN 'JB' END;
    END IF;

    RETURN lvValueIDV;

    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'NULL';

END GetDelpntIDVMapping;

/****************************************************************
** Function/Proc  :  getMsgSequenceNumber
**
** Purpose        :  Return the sequence number that is used as the message identifier
**
** Used by        :  all outbound message to the portal. Called from the java code.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** May-2017  FDSM      Initial version for Wheatstone implementation
**
*****************************************************************/
FUNCTION getMsgSequenceNumber(p_prefix VARCHAR2) RETURN VARCHAR2
IS

  l_sql varchar2(2000);
  l_val number;

BEGIN


    l_sql := 'select CPP_MSG_SEQ_' || p_prefix || '.nextval from dual';

    execute immediate l_sql into l_val;

    return p_prefix || '-' || LPAD(l_val, 4, '0') ;

END getMsgSequenceNumber;

END UE_CT_CPP_INTERFACE;
/
