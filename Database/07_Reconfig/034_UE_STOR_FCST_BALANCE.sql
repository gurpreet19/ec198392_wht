create or replace PACKAGE Ue_Stor_Fcst_Balance IS
/****************************************************************
** Package        :  Ue_Stor_Fcst_Balance; head part
**
** Purpose        : Replacement for EcDp_Stor_Fcst_Balance to pull forecasted storage levels
**                       from the planning screens for EC Production
**
** Documentation  :  Attached
**
** Created        :  30-JUL-2012    Samuel Webb
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 26-JAN-2015 SWGN  Added single parcel storage level calculations, and modified the calcStorageLevelTable with a new optional parameter to handle it
*****************************************************************/

FUNCTION calcDailyStorageProduction(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_super_cache_flag VARCHAR2 DEFAULT 'NO') RETURN NUMBER;

FUNCTION calcStorageLevelMod(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN') RETURN NUMBER;

FUNCTION calcStorageLevelTable(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN', p_distinct VARCHAR2 DEFAULT 'DISTINCT') RETURN UE_CT_STOR_FCST_GRAPH_COLL PIPELINED;

FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_forecast_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION adjForLoadingRate(    p_Vol NUMBER,
                            p_Non_Firm_date_time DATE,
                            p_start DATE,
                            p_end DATE,
                            p_rate NUMBER DEFAULT 1,
                            p_storage_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER ;
FUNCTION calcSumOutOrInForADay(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            )
RETURN NUMBER ;
FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

/* LBFK - Need to understand what is this used for
FUNCTION getSumOutInDayMass(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            ) RETURN NUMBER;

FUNCTION getSumOutInDayEnergy(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            ) RETURN NUMBER;
*/
END Ue_Stor_Fcst_Balance;
/
create or replace PACKAGE BODY UE_STOR_FCST_BALANCE IS
/****************************************************************
** Package        :  Ue_Stor_Fcst_Balance; body part
**
** Purpose        : Replacement for EcDp_Stor_Fcst_Balance to pull forecasted storage levels
**                       from the planning screens for EC Production
**
** Documentation  :  Attached
**
** Created        :  30-JUL-2012    Samuel Webb
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 2-JUL-2014  SWGN  Resolved defect for combined cargoes and storage levels (combined cargoes were being calculated in parallel instead of sequentially; used group-by to solve)
** 6-JUL-2014  SWGN  Enhanced coding for forecast storage graphs
** 26-JAN-2015 SWGN  Added single parcel storage level calculations (getSingleStorageLevel), and modified the calcStorageLevelTable procedure to call this when a parcel-level query is made
** 18-JAN-2018 KAWF  126078:Modified calcDailyStorageProduction(), added R_ADP into condition
*****************************************************************/

/**private global session variables **/
gv_prev_forecast_id forecast.object_id%type;
gv_prev_forecast_id2 forecast.object_id%type;
gv_prev_forecast_id3 forecast.object_id%type;
gv_prev_object_id storage.object_id%type;
gv_prev_object_id2 storage.object_id%type;
gv_prev_object_id3 storage.object_id%type;
gv_prev_date DATE;
gv_prev_date2 DATE;
gv_prev_date3 DATE;
gv_prev_qty NUMBER;
gv_prev_qty2 NUMBER;
gv_prev_qty3 NUMBER;
gtv_prev_forecast_id forecast.object_id%type;
gtv_prev_object_id storage.object_id%type;
gtv_prev_level_type VARCHAR2(32);
gtv_prev_item_no NUMBER;
gtv_prev_date DATE;
gtv_prev_qty NUMBER;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyStorageProduction
-- Description    : Gets the daily produced volume of the storage plan, either from EC Prod or the daily storage forecast table
-- Preconditions  : EC Production installation
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDailyStorageProduction(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
IS
    lv2_forecast_fcst_type VARCHAR2(32):= ec_forecast_version.text_10(p_forecast_id, p_daytime, '<=');
    lv2_forecast_type VARCHAR2(32) := ec_forecast_version.text_9(p_forecast_id, p_daytime, '<=');
    lv2_scenario VARCHAR2(32) := ec_forecast_version.text_8(p_forecast_id, p_daytime, '<=');
    lv2_scenario_type VARCHAR2(32):= ec_forecast_version.text_6(p_forecast_id, p_daytime, '<=');
    lv2_forecast_object_id VARCHAR2(32);
    lv2_effective_daytime DATE;
    ln_return_value NUMBER;

BEGIN

    --IF (lv2_scenario_type = 'PADP' OR lv2_scenario_type = 'ADP') THEN
    IF (lv2_scenario_type = 'PADP' OR lv2_scenario_type = 'ADP' OR lv2_scenario_type = 'R_ADP') THEN
        lv2_effective_daytime := ec_forecast.start_date(p_forecast_id);
        lv2_forecast_object_id := ec_forecast_version.ref_object_id_1(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_effective_daytime := sysdate;
        lv2_forecast_object_id := NULL;
    END IF;

    IF lv2_forecast_fcst_type IS NULL OR lv2_forecast_fcst_type = 'TRAN_PCTR_FCAST' THEN
        IF p_xtra_qty = 1 THEN
            ln_return_value := ec_stor_day_fcst_fcast.forecast_qty2(p_storage_id, p_daytime, p_forecast_id);
        ELSIF p_xtra_qty = 2 THEN
            ln_return_value := ec_stor_day_fcst_fcast.forecast_qty3(p_storage_id, p_daytime, p_forecast_id);
        ELSE
            ln_return_value := ec_stor_day_fcst_fcast.forecast_qty(p_storage_id, p_daytime, p_forecast_id);
        END IF;
    ELSE
        ln_return_value := Ue_Storage_Plan.calcDailyStoragePlan(p_storage_id, p_daytime, lv2_effective_daytime, lv2_forecast_type, lv2_scenario, lv2_forecast_object_id);
    END IF;

    return ln_return_value;
END calcDailyStorageProduction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : adjForLoadingRate
-- Description    : Calculate loading for crossing day scenario
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION adjForLoadingRate(    p_Vol NUMBER,
                            p_Non_Firm_date_time DATE,
                            p_start DATE,
                            p_end DATE,
                            p_rate NUMBER DEFAULT 1,
                            p_storage_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS

ln_vol NUMBER :=0;
ld_calc_end_date_time DATE;
lv_FC1 VARCHAR2(32):= EC_STOR_VERSION.OP_FCTY_CLASS_1_ID(p_storage_id,p_Non_Firm_date_time,'<=');
lv_offset NUMBER:= nvl(ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time),0) /24;

ld_adj_start DATE;
ld_adj_end DATE;

ld_adj_nom_start DATE;
ld_adj_nom_end DATE;

BEGIN
--the first time the system is setting the opening DIP, the Start date will be always set to when the last avaialble DIP for the Tank
--then it set the end_date to as per From Date in the screen
--when it gets the first record, then the system will keep on calling this pakcage by passing in the same from and to date from the screen.
--to handle both scenario, we need to check to see whether the passed in p_end same as trunc(p_Non_Firm_date_time)
--if it is same then that means it is NOT the first time to call this package, hence we can safely calculate the cross day rate
--if the p_end is NOt equal to the trunc(p_Non_Firm_date_time), this means that this is the first round to calculate the Tank DIP
--so no need to calculate for the cross day
    ld_calc_end_date_time := ((p_Vol/p_rate)/24) + p_Non_Firm_date_time;

    ld_adj_start := p_start + lv_offset;
    ld_adj_end := p_end + lv_offset + 1;

IF (p_Non_Firm_date_time < ld_adj_start ) THEN
    ld_adj_nom_start := ld_adj_start;
ELSIF (p_Non_Firm_date_time >ld_adj_end) THEN
    ld_adj_nom_start := ld_adj_end;
ELSE
    ld_adj_nom_start := p_Non_Firm_date_time;
END IF ;

IF (ld_calc_end_date_time < ld_adj_start ) THEN
    ld_adj_nom_end := ld_adj_start;
ELSIF (ld_calc_end_date_time >ld_adj_end) THEN
    ld_adj_nom_end := ld_adj_end;
ELSE
    ld_adj_nom_end := ld_calc_end_date_time;
END IF ;

RETURN (ld_adj_nom_end - ld_adj_nom_start) * 24 * p_rate;

--
--    IF (TRUNC(p_end-lv_offset)) = (TRUNC(p_Non_Firm_date_time-lv_offset)) THEN
--        --IF TRUNC(ld_calc_end_date_time) = TRUNC(p_Non_Firm_date_time) THEN
--        IF (TRUNC(ld_calc_end_date_time-lv_offset)) = (TRUNC(p_Non_Firm_date_time-lv_offset)) THEN
--            ln_vol := p_Vol;
--        ELSE
--            --SAME DAY AND ITS GOING TO CROSS OVER TO THE NEXT DAY
--            --ln_vol := ( 24-((p_Non_Firm_date_time-TRUNC(p_Non_Firm_date_time))*24) )*p_rate;
--            --24 - (nom_date_time-off_set)
--            --EC_STOR_VERSION.OP_FCTY_CLASS_1_CODE(p_storage_id,p_Non_Firm_date_time,'<=')
--            --need to handle if end date is more than 2 days
--            IF (TRUNC(ld_calc_end_date_time-lv_offset)) <> (TRUNC(p_end-lv_offset)) THEN
--                --SAME DAY AND CROSS OVER TO THE NEXT DAY.
--                --CHECK WHEN IT START AND WHEN IS THE END OF THE DAY
--                --TAKE THE VALUE MULTIPLEWITH THE RATE
--                --24 - (nom_date_time-off_set)
--                 ln_vol := (24 -
--                                   24* ( p_Non_Firm_date_time-TRUNC(p_Non_Firm_date_time))
--                               )* p_rate;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','127->' || ln_vol ||' p_end=' ||p_end || ' lv_offset=' || lv_offset  || ' (TRUNC(p_end-lv_offset))=' || (TRUNC(p_end-lv_offset)) || ' (TRUNC(p_Non_Firm_date_time-lv_offset))=' ||(TRUNC(p_Non_Firm_date_time-lv_offset)));
--            ELSE
--                --SAME DAY WITH REMAINING TO BE LOADED ON THIS DAY
--                ln_vol := (
--                (ld_calc_end_date_time -
--                ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,ld_calc_end_date_time)
--                 ) * 24 -
--                 NVL(ECDP_PRODUCTIONDAY.getproductiondayoffset('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time),0)
--                 )*p_rate;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','136->' ||ln_vol);
--            END IF;
--        END IF;
--    ELSE IF TRUNC(p_start) = TRUNC(p_end) THEN
--                --IT MEANS THERE IS A CROSS DAY LOADING
--                --CHECK TO SEE WHETHER IT STARTS ON PREVIOUS DAY
--                IF (TRUNC(p_Non_Firm_date_time-lv_offset)) < (TRUNC(ld_calc_end_date_time-lv_offset))THEN
--                    -- this means the actual production loading day is different from the end loading day
--                    --CHECK TO SEE IF END LOADING DATE IS SAME AS END_DAY
--                    --IF YES, ITMEANS THAT THE LOADING IS GOING TO BE COMPLETED ON TODAY AND WE JSUT NEED TO CALCULATE THE LOADING BASED ON
--                    --LOADING END TIME MINUS THE TRUNC(DATE)
--                    IF (TRUNC(ld_calc_end_date_time-lv_offset)) = (TRUNC(p_end))THEN
--                    --THIS IS CROSS DAY AND IT IS GOING TO BE ENDED ON THIS DAY.
--                    --THIS MEANS THE LOADING IS GOING TO BE FINISHED ONTHE SAME DAY
--                        --IDENTIFY HOW MANY HOURS USED TO LOAD
--                        --LOAD HOURS = CALC_END_DATE MINUS OFFSET
--                        --LOAD VOL = LOAD HOURS * RATE
--                         ln_vol := (
--                         (ld_calc_end_date_time-ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,ld_calc_end_date_time)) *24
--                         * p_rate
--                         );
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','156->' ||ln_vol);
--                    ELSE
--                        --THIS IS LOADING MORE THAN 1 DAY
--                        --NEED TO KNOW HOW MUCH LOADED FOR PREVIOUS DAY.
--                        --24 - (LOAD TIME - OFFSET)  TO GET WHEN IS THE ACTUAL LOADING HOUR COMPARE TO A DAY . LIKE HOUR 23 ETC
--                          --ln_vol := p_rate * 24;
--                          IF  (TRUNC(p_Non_Firm_date_time-lv_offset)) = (TRUNC(p_end)) THEN
--                            ln_vol := p_rate * 24 *
--                             (
--                             p_Non_Firm_date_time     -      TRUNC(p_Non_Firm_date_time-lv_offset)  + lv_offset
--                             )
--
--                          ELSE
--                            ln_vol := p_rate * 24;
--                          END IF;
--
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','160->' ||ln_vol);
--                    END IF;
--                ELSE
--                    --SAME DAY WITH REMAINING TO BE LOADED ON THIS DAY
--                    ln_vol := (( (p_Vol/p_rate)-
--                    (
--                    24 - (
--                    (p_Non_Firm_date_time-ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time)
--                    ) * 24)+NVL(ECDP_PRODUCTIONDAY.getproductiondayoffset('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time),0)
--                    )
--                    )*p_rate  )        ;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','171->' ||ln_vol || ' p_Vol/p_rate=' || p_Vol/p_rate || ' OFFSET='||NVL(ECDP_PRODUCTIONDAY.getproductiondayoffset('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time),0) ||
-- ' DAY=' || (p_Non_Firm_date_time-ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,p_Non_Firm_date_time)) * 24  );
--                END IF;
--            ELSE
--                -- It means it is trying to calculate for the first time
--                ln_vol := p_Vol;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','176->' ||ln_vol);
--            END IF;
--    END IF;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','p_start=' || p_start || ' p_end=' || p_end || ' p_Non_Firm_date_time=' ||p_Non_Firm_date_time || ' ld_calc_end_date_time=' || ld_calc_end_date_time || ' ln_vol=' ||ln_vol);
--    RETURN ln_vol;

END adjForLoadingRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOutOrInForADay
-- Description    : Gets the Sum out or In for storage and forecast in a given day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOutOrInForADay(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            )
RETURN NUMBER
IS
    lv_FC1 VARCHAR2(32):= EC_STOR_VERSION.OP_FCTY_CLASS_1_ID(p_storage_id,p_daytime,'<=');
    lv_offset NUMBER:= nvl(ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET('FCTY_CLASS_1',lv_FC1,p_daytime),0) /24;

CURSOR c_sum_in (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
    SELECT     SUM(f.forecast_qty) forecast_qty,
          SUM(f.forecast_qty2) forecast_qty2,
          SUM(f.forecast_qty3) forecast_qty3
    FROM    stor_day_fcst_fcast f
    WHERE    f.object_id = cp_storage_id
            AND f.forecast_id = cp_forecast_id
              AND f.daytime >= cp_start
              AND f.daytime <= cp_end;

/* LBFK - This cursor will most likely will have to change for PADP/ADP based on forecast object id  */
CURSOR c_forecast_nos (cp_object_id VARCHAR2, cp_forecast_type VARCHAR2, cp_scenario VARCHAR2) IS
    SELECT DISTINCT fcst_scen_no, object_id, forecast_type, effective_daytime
    FROM ct_prod_strm_forecast
    WHERE forecast_type = cp_forecast_type
    AND scenario = cp_scenario
    AND object_id = cp_object_id
    ORDER BY effective_daytime ASC;


    ln_lifted_qty NUMBER :=-0;
    lv2_storage_stream VARCHAR2(32) := ec_stor_version.plan_object_id(p_storage_id, p_daytime, '<=');
    lv2_forecast_source VARCHAR2(32) := ec_forecast_version.text_10(p_forecast_id, p_daytime, '<=');
    lv2_forecast_type VARCHAR2(32) := ec_forecast_version.text_9(p_forecast_id, p_daytime, '<=');
    lv2_scenario VARCHAR2(32) := ec_forecast_version.text_8(p_forecast_id, p_daytime, '<=');
    ln_LoadingRate NUMBER;
    ln_fcst_scen_no NUMBER := 0;

BEGIN

    select ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',p_daytime,'<=') into ln_LoadingRate from dual;

IF p_type = 'OUT' THEN
 SELECT SUM(lifted) lifted_qty INTO ln_lifted_qty
    FROM (
            SELECT  decode(
              p_xtra_qty,1,
              decode(p_cargo_off_qty_ind,'N',n.grs_vol_nominated2,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,1),   n.grs_vol_nominated2)),
              2,decode(p_cargo_off_qty_ind,'N',n.grs_vol_nominated3,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,2),   n.grs_vol_nominated3)),
                decode(p_cargo_off_qty_ind,'N',adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE,  (n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24),p_daytime,COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate) ) ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,null),n.grs_vol_nominated))
              )  lifted
            FROM     stor_fcst_lift_nom n,
                    cargo_fcst_transport c
            WHERE     n.object_id = p_storage_id
                AND n.forecast_id = p_forecast_id
                AND c.cargo_no = n.cargo_no
                AND c.forecast_id = n.forecast_id
                --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                --AND    c.cargo_status <> 'D'
                AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS') <> 'D'
                --end edit
                AND nvl(n.DELETED_IND, 'N') <> 'Y'
AND
                (
                (
                --ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,N.START_LIFTING_DATE)
               TRUNC(N.START_LIFTING_DATE - lv_offset)
                <= p_daytime
                AND
                --TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/cp_LoadingRate)/24))
               TRUNC((N.START_LIFTING_DATE - lv_offset) + ( (N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24))
                >= p_daytime)
                OR
                (
                --TRUNC(N.START_LIFTING_DATE)
               TRUNC(N.START_LIFTING_DATE - lv_offset)
                >= p_daytime
                AND
                --TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/cp_LoadingRate)/24))
                TRUNC((N.START_LIFTING_DATE - lv_offset) + ( (N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24))
                <= p_daytime)
                )
/*
                AND TRUNC(N.START_LIFTING_DATE) <= p_daytime
                AND TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/ln_LoadingRate)/24))>= p_daytime
*/
        UNION ALL
             SELECT  decode(
              p_xtra_qty,1,
              n.grs_vol_nominated2,2,
              n.grs_vol_nominated3,
               adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE, (n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24),p_daytime,COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate) )
            )  lifted
            FROM     stor_fcst_lift_nom n
            WHERE     n.object_id = p_storage_id
                AND n.forecast_id = p_forecast_id
                AND n.cargo_no IS NULL
                AND nvl(n.DELETED_IND, 'N') <> 'Y'
AND
                (
                (
                --ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY('FCTY_CLASS_1',lv_FC1,N.START_LIFTING_DATE)
               TRUNC(N.START_LIFTING_DATE - lv_offset)
                <= p_daytime
                AND
                --TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/cp_LoadingRate)/24))
               TRUNC((N.START_LIFTING_DATE - lv_offset) + ( (N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24))
                >= p_daytime)
                OR
                (
                --TRUNC(N.START_LIFTING_DATE)
               TRUNC(N.START_LIFTING_DATE - lv_offset)
                >= p_daytime
                AND
                --TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/cp_LoadingRate)/24))
                TRUNC((N.START_LIFTING_DATE - lv_offset) + ( (N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(N.CARGO_NO),ln_LoadingRate))/24))
                <= p_daytime)
                )
                ) ;
/*
                AND TRUNC(N.START_LIFTING_DATE) <= p_daytime
                AND TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/ln_LoadingRate)/24))>= p_daytime)
*/

ELSE  IF lv2_forecast_source IS NULL OR lv2_forecast_source = 'TRAN_PCTR_FCAST' THEN
            ln_lifted_qty := EC_STOR_DAY_FCST_FCAST.MATH_FORECAST_QTY(p_storage_id,p_forecast_id,p_daytime,p_daytime);
        /*FOR curIn IN c_sum_in (p_storage_id, p_forecast_id, p_daytime, p_daytime) LOOP
             ln_lifted_qty := curIn.forecast_qty;
        END LOOP;
        */
    ELSE
        FOR item IN c_forecast_nos(lv2_Storage_stream, lv2_forecast_Type, lv2_scenario) LOOP
            ln_fcst_scen_no := item.fcst_scen_no;
        END LOOP;
        --ln_lifted_qty := Ue_Storage_Plan.calcAggregateStoragePlan(p_storage_id, p_daytime, p_daytime+1, lv2_forecast_type, lv2_scenario);
        /* LBFK - This will not work (if needed) for WST for fcst type ADP_PLAN due to the multiple revisions requirement */
        ln_lifted_qty := EC_PROD_STRM_FORECAST.MATH_VALUE_43(ln_fcst_scen_no,lv2_storage_stream,p_daytime,p_daytime);
        --ln_lifted_qty := EC_STOR_DAY_FCST_FCAST.MATH_FORECAST_QTY(p_storage_id,p_forecast_id,p_daytime,p_daytime);
    END IF;

END IF;

RETURN NVL(ln_lifted_qty,0);

END calcSumOutOrInForADay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevel
-- Description    : Gets the storage level for storage and forecast
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevel(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_xtra_qty NUMBER DEFAULT 0,
            p_super_cache_flag VARCHAR2 DEFAULT 'NO')
RETURN NUMBER
--</EC-DOC>
IS
    lv_FC1 VARCHAR2(32):= EC_STOR_VERSION.OP_FCTY_CLASS_1_ID(p_storage_id,p_daytime,'<=');
    lv_offset NUMBER:= nvl(ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET('FCTY_CLASS_1',lv_FC1,p_daytime),0) /24;

--TLXT
/*
let say the scenario start from 14-Jan-2013


the from date = 11-Jan-2013
To date = 15-Jan-2013
Current date = 15-Jan-2013
the loop  will look like below:
ld_StartDate=14-JAN-13p_daytime=11-JAN-13 ld_EndDate=11-JAN-13 ld_today=11-JAN-13
ld_StartDate=14-JAN-13p_daytime=12-JAN-13 ld_EndDate=12-JAN-13 ld_today=12-JAN-13
ld_StartDate=14-JAN-13p_daytime=13-JAN-13 ld_EndDate=13-JAN-13 ld_today=13-JAN-13
ld_StartDate=14-JAN-13p_daytime=14-JAN-13 ld_EndDate=14-JAN-13 ld_today=14-JAN-13
ld_StartDate=15-JAN-13p_daytime=15-JAN-13 ld_EndDate=15-JAN-13 ld_today=15-JAN-13

if the from date = 16-Jan-2013
To date = 19-Jan-2013
Current date = 15-Jan-2013
the loop  will look like below:
ld_StartDate=14-JAN-13p_daytime=16-JAN-13 ld_EndDate=16-JAN-13 ld_today=15-JAN-13
ld_StartDate=17-JAN-13p_daytime=17-JAN-13 ld_EndDate=17-JAN-13 ld_today=15-JAN-13
ld_StartDate=18-JAN-13p_daytime=18-JAN-13 ld_EndDate=18-JAN-13 ld_today=15-JAN-13
ld_StartDate=19-JAN-13p_daytime=19-JAN-13 ld_EndDate=19-JAN-13 ld_today=15-JAN-13

*/

-- Original storage inbound cursor from the EcDp_Stor_Fcst_Balance
CURSOR c_sum_in (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
    SELECT     SUM(f.forecast_qty) forecast_qty,
          SUM(f.forecast_qty2) forecast_qty2,
          SUM(f.forecast_qty3) forecast_qty3
    FROM    stor_day_fcst_fcast f
    WHERE    f.object_id = cp_storage_id
            AND f.forecast_id = cp_forecast_id
              AND f.daytime >= cp_start
              AND f.daytime <= cp_end;

CURSOR c_sum_out (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_cargo_off_qty_ind VARCHAR2, cp_xtra_qty NUMBER, cp_LoadingRate NUMBER ) IS
    SELECT SUM(lifted) lifted_qty
    FROM (
            SELECT  decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',sum(n.grs_vol_nominated2),nvl((SELECT SUM(ecbp_storage_lift_nomination.getLiftedVol(nn.parcel_no,1)) FROM stor_fcst_lift_nom nn WHERE nn.cargo_no = n.cargo_no),   sum(n.grs_vol_nominated2))),
              2,decode(cp_cargo_off_qty_ind,'N',sum(n.grs_vol_nominated3),nvl((SELECT SUM(ecbp_storage_lift_nomination.getLiftedVol(nn.parcel_no,2)) FROM stor_fcst_lift_nom nn WHERE nn.cargo_no = n.cargo_no),   sum(n.grs_vol_nominated3))),
                decode(cp_cargo_off_qty_ind,'N',adjForLoadingRate(sum(n.grs_vol_nominated),max(N.START_LIFTING_DATE), cp_start,cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate),p_storage_id ) ,nvl((SELECT SUM(ecbp_storage_lift_nomination.getLiftedVol(nn.parcel_no,null)) FROM stor_fcst_lift_nom nn WHERE nn.cargo_no = n.cargo_no),sum(n.grs_vol_nominated)))
              )  lifted
            FROM     stor_fcst_lift_nom n,
                    cargo_fcst_transport c
            WHERE     n.object_id = cp_storage_id
                AND n.forecast_id = cp_forecast_id
                AND c.cargo_no = n.cargo_no
                AND c.forecast_id = n.forecast_id
                --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                --AND    c.cargo_status <> 'D'
                AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS') <> 'D'
                --end edit
                AND nvl(n.DELETED_IND, 'N') <> 'Y'
                AND
                -- SWGN
                TRUNC(N.START_LIFTING_DATE - lv_offset) <= cp_end
                GROUP BY n.cargo_no
                HAVING TRUNC(MAX(N.START_LIFTING_DATE) + (SUM(N.grs_vol_nominated)/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24 - lv_offset) >= cp_start
        UNION ALL
            SELECT  decode(
              cp_xtra_qty,1,
              n.grs_vol_nominated2,2,
              n.grs_vol_nominated3,
              adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE, cp_start,cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate) )
              )  lifted
            FROM     stor_fcst_lift_nom n
            WHERE     n.object_id = cp_storage_id
                AND n.forecast_id = cp_forecast_id
                AND n.cargo_no IS NULL
                AND nvl(n.DELETED_IND, 'N') <> 'Y'
                -- SWGN
                AND TRUNC(N.START_LIFTING_DATE - lv_offset) <= cp_end
                AND TRUNC(N.START_LIFTING_DATE + (N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24 - lv_offset) >= cp_start
        ) a;

    ld_StartDate    DATE;
    ld_EndDate        DATE;
    ld_today        DATE;
    ln_Dip             NUMBER;
    lnTotalIn        NUMBER;
    lnTotalOut        NUMBER;
    lv_prev_forecast_id forecast.object_id%type;
    lv_prev_object_id storage.object_id%type;
    lv_prev_qty     NUMBER;
    lv_prev_date    DATE;
    --TLXT
      ln_LoadingRate NUMBER;
  --this needs to be decided later
    --END EDIT TLXT

	v_contract_code VARCHAR2(32);

	lv2_forecast_source VARCHAR2(32) := ec_forecast_version.text_10(p_forecast_id, p_daytime, '<=');
    lv2_forecast_type VARCHAR2(32) := ec_forecast_version.text_9(p_forecast_id, p_daytime, '<=');
    lv2_scenario VARCHAR2(32) := ec_forecast_version.text_8(p_forecast_id, p_daytime, '<=');
    lv2_scenario_type VARCHAR2(32):= ec_forecast_version.text_6(p_forecast_id, p_daytime, '<=');
    lv2_forecast_object_id VARCHAR2(32);
    lv2_opening_storage VARCHAR2(32) := ec_forecast_version.text_7(p_forecast_id, p_daytime, '<=');
    lv2_storage_stream_id VARCHAR2(32) := ec_stor_version.plan_object_id(p_storage_id, p_daytime, '<=');



BEGIN
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre CalcStorageLevel');
    -- Get Loading Rate from contract attributes
    select DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND') into v_contract_code from dual;

    select ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',p_daytime,'<=') into ln_LoadingRate from dual;
    IF (lv2_scenario_type = 'PADP' OR lv2_scenario_type = 'ADP') THEN
        lv2_forecast_object_id := ec_forecast_version.ref_object_id_1(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_forecast_object_id := NULL;
    END IF;

--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','lv_offset=' ||lv_offset ||' p_storage_id=' || p_storage_id || ' p_forecast_id=' || p_forecast_id||' p_daytime=' ||p_daytime);
    IF gv_prev_QTY IS NULL THEN
        gv_prev_forecast_id := '0';
           gv_prev_object_id := '0';
        gv_prev_QTY:=0;
        gv_prev_DATE := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;
    IF gv_prev_QTY2 IS NULL THEN
        gv_prev_forecast_id2 := '0';
           gv_prev_object_id2 := '0';
        gv_prev_QTY2:=0;
        gv_prev_DATE2 := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;
    IF gv_prev_QTY3 IS NULL THEN
        gv_prev_forecast_id3 := '0';
           gv_prev_object_id3 := '0';
        gv_prev_QTY3:=0;
        gv_prev_DATE3 := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;

    --ld_today := COALESCE(TO_DATE(EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_TEXT(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY','CE_BGPA'),SYSDATE,'COMMERCIAL_ENTITY','EFFDAY','<='),'YYYY-MM-DD"T"HH24:MI:SS') ,TRUNC(ecdp_date_time.getCurrentSysdate));
    ld_today := COALESCE(NULL ,TRUNC(ecdp_date_time.getCurrentSysdate));

    IF P_XTRA_QTY=1 THEN
        --use prev_date2 and prev_qty2
        lv_prev_forecast_id := gv_prev_forecast_id2;
        lv_prev_object_id := gv_prev_object_id2;
        lv_prev_date:=gv_prev_date2;
        lv_prev_qty:=gv_prev_qty2;
    ELSIF P_XTRA_QTY=2 THEN
        --use prev_date3 and prev_qty3
        lv_prev_forecast_id := gv_prev_forecast_id3;
        lv_prev_object_id := gv_prev_object_id3;
        lv_prev_date:=gv_prev_date3;
        lv_prev_qty:=gv_prev_qty3;
    ELSE
        --use prev_date and prev_qty
        lv_prev_forecast_id := gv_prev_forecast_id;
        lv_prev_object_id := gv_prev_object_id;
        lv_prev_date:=gv_prev_date;
        lv_prev_qty:=gv_prev_qty;
    END IF;

    -- Get opening balance for forecast period
    ld_StartDate := ec_forecast.start_date(p_forecast_id);
    IF (lv_prev_forecast_id = p_forecast_id) AND (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime, 'DD') = 0) THEN
        --prev_date and p_daytime is identical and in the future
        RETURN NVL(lv_prev_qty, 0); --+0.0001;
    ELSIF (lv_prev_forecast_id = p_forecast_id) AND (lv_prev_object_id = p_storage_id) AND (p_daytime>=ld_today) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime-1,'DD')=0) THEN
        --prev_date is the day before p_daytime and in the future
        ld_StartDate := p_daytime;
        ln_dip := NVL(lv_prev_qty,0); --DEBUG + .01;
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','ln_Dip_A=' ||ln_Dip);
    ELSE
        IF lv2_opening_storage IS NULL OR lv2_opening_storage = 'ESTIMATED_VOL' THEN
			ln_Dip := Ue_Trans_Storage_Balance.calcStorageLevel(p_storage_id, ld_StartDate-1, NULL, p_xtra_qty);
        ELSE
			IF lv2_opening_storage = 'HALF_STORAGE' THEN
				ln_Dip := ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ld_startdate) +
                                (
                                    ue_storage_balance.getMaxSafeLimitVolLevel(p_storage_id, ld_startdate) - ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ld_startdate)
                                ) / 2;
			ELSE
				IF lv2_opening_storage = 'USER_DEFINED' THEN
					ln_Dip := NVL(ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', v_contract_code),'OPN_STORAGE',ld_startdate,'<='),0);
				END IF;
			END IF;
		END IF;
    END IF;
--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','ln_Dip=' ||ln_Dip || 'ld_StartDate=' ||ld_StartDate);

    ld_EndDate := p_daytime;

    -- get official/planned incomming
    IF lv2_forecast_source IS NULL OR lv2_forecast_source = 'TRAN_PCTR_FCAST' THEN
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre in loop 11');
        FOR curIn IN c_sum_in (p_storage_id, p_forecast_id, ld_StartDate, ld_EndDate) LOOP

          IF P_XTRA_QTY = 1 THEN
             lnTotalIn := curIn.forecast_qty2;
          ELSIF P_XTRA_QTY = 2 THEN
             lnTotalIn := curIn.forecast_qty3;
          ELSE
             lnTotalIn := curIn.forecast_qty;
          END IF;

        END LOOP;
    ELSE
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre in Forecast 10');
        lnTotalIn := Ue_Storage_Plan.calcAggregateStoragePlan(p_storage_id, ld_StartDate, ld_EndDate + 1, lv2_forecast_type, lv2_scenario,lv2_forecast_object_id);
    END IF;

    IF ld_today > ld_EndDate THEN
        ld_today := ld_EndDate;
    END IF;

    -- get official/planned lifted
    IF ld_StartDate>p_daytime THEN
        FOR curOut IN c_sum_out (p_storage_id, p_forecast_id, p_daytime, ld_EndDate, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty,ln_LoadingRate) LOOP
              lnTotalOut := curOut.lifted_qty;
        END LOOP;
    ELSE
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre in Forecast 12');
        FOR curOut IN c_sum_out (p_storage_id, p_forecast_id, ld_StartDate, ld_EndDate, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty,ln_LoadingRate) LOOP
              lnTotalOut := curOut.lifted_qty;
        END LOOP;
    END IF;

--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','ld_StartDate=' || ld_StartDate ||'p_daytime=' || p_daytime || ' ld_EndDate=' || ld_EndDate || ' ld_today=' ||ld_today ||' ln_Dip='|| ln_Dip || ' lnTotalIn=' || lnTotalIn || ' lnTotalOut=' ||lnTotalOut);

    IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
        ln_dip := ln_Dip - Nvl(lnTotalIn,0) + Nvl(lnTotalOut,0);
    ELSE
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre in Forecast 13');
        ln_dip := ln_Dip + Nvl(lnTotalIn,0) - Nvl(lnTotalOut,0);
    END IF;

   IF p_xtra_qty=1 THEN
       gv_prev_forecast_id2 := p_forecast_id;
       gv_prev_object_id2 := p_storage_id;
    gv_prev_date2:=p_daytime;
    gv_prev_qty2:=ln_dip;
   ELSIF p_xtra_qty=2 THEN
       gv_prev_forecast_id3 := p_forecast_id;
       gv_prev_object_id3 := p_storage_id;
    gv_prev_date3:=p_daytime;
    gv_prev_qty3:=ln_dip;
   ELSE
       gv_prev_forecast_id := p_forecast_id;
       gv_prev_object_id := p_storage_id;
    gv_prev_date:=p_daytime;
    gv_prev_qty:=ln_dip;
   END IF;

  return ln_dip;
END calcStorageLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSingleStorageLevel
-- Description    : Calculates the storage level graph for a single parcel. Caches the result into a global temporary table to improve performance.
--                  Generally it is advised to avoid global temporary tables; this is done to improve performance (>5 minutes goes down to 10 seconds!!)
---------------------------------------------------------------------------------------------------
FUNCTION getSingleStorageLevel(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_open_close VARCHAR2)
RETURN UE_CT_STOR_FCST_GRAPH_POINT
IS

    PRAGMA AUTONOMOUS_TRANSACTION; -- Necessary to be able to be called within the context of a query

    v_sysdate DATE := sysdate;
    v_item_no NUMBER := nvl(ec_stor_fcst_lift_nom.cargo_no(p_parcel_no, p_forecast_id), p_parcel_no);

    CURSOR CACHED_RESULTS IS
    SELECT *
    FROM T_CT_STORAGE_GRAPH
    WHERE ITEM_NO = v_item_no
    AND EVENT_TYPE = 'CARGO_' || p_open_close
    AND OBJECT_ID = p_storage_id
    AND FORECAST_ID = p_forecast_id
    AND LOADED_DATE > v_sysdate - 10 / (24 * 60 * 60); -- This represents a cache lifespan of 10 seconds; records older than this won't be counted

    v_return_row UE_CT_STOR_FCST_GRAPH_POINT := new UE_CT_STOR_FCST_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);

BEGIN

    -- Look in the cache
    FOR item IN cached_results LOOP
        v_return_row.object_id := item.object_id;
        v_return_row.forecast_id := item.forecast_id;
        v_return_row.daytime := item.daytime;
        v_return_row.storage_level := item.storage_level;
        v_return_row.event_type := item.event_type;
    END LOOP;

    -- If the answer is not in the cache
    IF v_return_row.storage_level IS NULL THEN

        -- Possibly redundant delete; done to make sure that the results aren't just "old"
        DELETE FROM t_ct_storage_graph WHERE object_id = p_storage_id AND forecast_id = p_forecast_id;

        -- Query the entire forecast, put the result into the cache
        INSERT INTO t_ct_storage_graph (OBJECT_ID, FORECAST_ID, DAYTIME, ITEM_NO, EVENT_TYPE, STORAGE_LEVEL, LOADED_DATE)
        SELECT object_id, forecast_id, daytime, item_no, event_type, storage_level, v_sysdate
        FROM table(calcStorageLevelTable(p_storage_id, p_forecast_id, ec_forecast.start_date(p_forecast_id), ec_forecast.end_date(p_forecast_id), NULL, 'OPEN', 'NOT_DISTINCT'));

        -- Get the result from the cache
        FOR item IN cached_results LOOP
            v_return_row.object_id := item.object_id;
            v_return_row.forecast_id := item.forecast_id;
            v_return_row.daytime := item.daytime;
            v_return_row.storage_level := item.storage_level;
            v_return_row.event_type := item.event_type;
			ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','object_id ' || v_return_row.object_id || ' Daytime ' || v_return_row.daytime || ' Storage Level ' || v_return_row.storage_level ||  ' event_type ' || v_return_row.event_type);
        END LOOP;

    END IF;

    -- If we still don't have a result, something went wrong
    IF v_return_row.storage_level IS NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 'Could never retrieve results for parcel ' || p_parcel_no || ', operation ' || p_open_close || ', forecast ' || p_forecast_id);
    END IF;

    COMMIT;
    RETURN v_return_row;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevelTable
-- Description    : Calculates the storage level graph for a period
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevelTable(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN', p_distinct VARCHAR2 DEFAULT 'DISTINCT')
RETURN UE_CT_STOR_FCST_GRAPH_COLL PIPELINED
IS

    -- Three part cursor:
    -- A) All cargo openings, which contribute a drain to storage (LOADING_RATE > 0)                        INDICATOR = "CARGO_OPEN"
    -- B) All cargo closings, which negate a storage drain (LOADING_RATE = 0)                               INDICATOR = "CARGO_CLOSE"
    -- C) The daily production forecast, which contributes production into storage (STORAGE_RATE > 0)       INDICATOR = "DAY_OPEN"
    CURSOR event_storage_graph(cp_start_date DATE, cp_end_date DATE, cp_loading_rate NUMBER) IS
    SELECT OBJECT_ID,
           DAYTIME,
           --ITEM_NO, -- REPLACED BY NEXT LINE SWGN 09-FEB-2015
           LEAD(ITEM_NO, 1, ITEM_NO) OVER (ORDER BY DAYTIME, INDICATOR) AS ITEM_NO, -- SWGN 09-FEB-2015
           LEAD(DAYTIME, 1, DAYTIME) OVER (ORDER BY DAYTIME, INDICATOR) AS NEXT_DAYTIME, -- What is the DAYTIME of the next record (when sorted by date)
           (LEAD(DAYTIME, 1, DAYTIME) OVER (ORDER BY DAYTIME, INDICATOR) - DAYTIME) * 24 AS DURATION_HRS, -- How long does this event last? That's simply equal to (NEXT_DAYTIME - DAYTIME) * 24
           FORECAST_ID,
           LEAD(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS NEXT_INDICATOR, -- What is the "indicator" of the next record?
           INDICATOR,
           LAG(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS PREV_INDICATOR, -- What was the "indicator" of the last record
           STORAGE_RATE + SUM(DECODE(INDICATOR,'DAY_OPEN',0,'CARGO_OPEN',-LOADING_RATE,'CARGO_CLOSE',LOADING_RATE)) OVER (ORDER BY DAYTIME) AS HOURLY_RATE -- What is the net production rate for this record?
           FROM
           (
                -- Query part A (INDICATOR = "CARGO_OPEN")
                SELECT NOM.OBJECT_ID AS OBJECT_ID,
--                CASE WHEN MAX(NOM.START_LIFTING_DATE) < cp_start_date AND MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24) > cp_start_date
                CASE WHEN MAX(NOM.START_LIFTING_DATE) < cp_start_date AND MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24) > cp_start_date
                    THEN cp_start_date ELSE MAX(NOM.START_LIFTING_DATE) END AS DAYTIME,
                FCAST.OBJECT_ID AS FORECAST_ID,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_OPEN' AS INDICATOR,
                DECODE(MAX(FCVER.TEXT_10),'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), MAX(NOM.NOM_FIRM_DATE), MAX(FCAST.START_DATE), MAX(FCVER.TEXT_9), MAX(FCVER.TEXT_8),MAX(FCVER.REF_OBJECT_ID_1)) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(MAX(NOM.OBJECT_ID), MAX(NOM.NOM_FIRM_DATE), p_forecast_id) / 24
                ) AS STORAGE_RATE,
--                NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<=')) AS LOADING_RATE
                COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate) AS LOADING_RATE
                FROM STOR_FCST_LIFT_NOM NOM,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE NOM.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = p_forecast_id
                AND NOM.OBJECT_ID = p_storage_id
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND NOM.NOM_FIRM_DATE >= FCVER.DAYTIME
                AND NOM.NOM_FIRM_DATE <= NVL(FCVER.END_DATE, NOM.NOM_FIRM_DATE + 1)
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_FCST_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO, p_forecast_id), EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, FCAST.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                -- Query part B (INDICATOR = "CARGO_CLOSE")
                SELECT NOM.OBJECT_ID AS OBJECT_ID,
--                MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24) AS DAYTIME,
                MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24) AS DAYTIME,
                FCAST.OBJECT_ID AS FORECAST_ID,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_CLOSE' AS INDICATOR,
--                DECODE(MAX(FCVER.TEXT_10),'PROD_PLAN_FCAST',
--                    ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24)), MAX(FCAST.START_DATE), MAX(FCVER.TEXT_9), MAX(FCVER.TEXT_8),MAX(FCVER.REF_OBJECT_ID_1)) / 24,
--                    ec_stor_day_fcst_fcast.forecast_qty(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24)), p_forecast_id) / 24
--                ) AS STORAGE_RATE,
                DECODE(MAX(FCVER.TEXT_10),'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24)), MAX(FCAST.START_DATE), MAX(FCVER.TEXT_9), MAX(FCVER.TEXT_8),MAX(FCVER.REF_OBJECT_ID_1)) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24)), p_forecast_id) / 24
                ) AS STORAGE_RATE,
--                NVL(EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<=')) AS LOADING_RATE
                COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate) AS LOADING_RATE
                FROM STOR_FCST_LIFT_NOM NOM,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE NOM.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = p_forecast_id
                AND NOM.OBJECT_ID = p_storage_id
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND NOM.NOM_FIRM_DATE >= FCVER.DAYTIME
                AND NOM.NOM_FIRM_DATE <= NVL(FCVER.END_DATE, NOM.NOM_FIRM_DATE + 1)
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_FCST_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO, p_forecast_id), EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, FCAST.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                -- Query part A (INDICATOR = "CARGO_CLOSE")
                SELECT GRAPH.OBJECT_ID,
                GRAPH.DAYTIME,
                GRAPH.FORECAST_ID AS FORECAST_ID,
                NULL AS ITEM_NO,
                'DAY_OPEN' AS INDICATOR,
                DECODE(FCVER.TEXT_10,'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(GRAPH.OBJECT_ID, GRAPH.DAYTIME, FCAST.START_DATE, FCVER.TEXT_9, FCVER.TEXT_8, FCVER.REF_OBJECT_ID_1) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(GRAPH.OBJECT_ID, GRAPH.DAYTIME, p_forecast_id) / 24
                ) AS STORAGE_RATE, --ue_stor_fcst_balance
                NULL AS LOADING_RATE
                FROM CV_FCST_STORAGE_GRAPH GRAPH,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE GRAPH.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = p_forecast_id
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND GRAPH.DAYTIME >= FCVER.DAYTIME
                AND GRAPH.DAYTIME <= NVL(FCVER.END_DATE, GRAPH.DAYTIME + 1)
                AND GRAPH.DAYTIME >= cp_start_date
                AND GRAPH.DAYTIME <= cp_end_date
                )
            WHERE FORECAST_ID = p_forecast_id
            AND OBJECT_ID = p_storage_id
            AND DAYTIME >= cp_start_date
            AND DAYTIME <= cp_end_date + 1
            AND NOT (INDICATOR = 'CARGO_CLOSE' AND DAYTIME = cp_start_date)
            ORDER BY DAYTIME, INDICATOR;

    v_return_row UE_CT_STOR_FCST_GRAPH_POINT;
    v_item_number NUMBER := NVL(ec_stor_fcst_lift_nom.cargo_no(p_parcel_no, p_forecast_id), p_parcel_no);
    v_start_date DATE;
    v_end_date DATE;
    v_loading_rate NUMBER;
    v_contract_code VARCHAR2(32);
	--TLXT
	ln_loading_hours NUMBER;
	ln_loading_hours_prior NUMBER;
	ln_loading_hours_post NUMBER;
	ln_total_nominated NUMBER;
	ln_partial_loaded_prior NUMBER;
	ln_partial_loaded_post NUMBER;
	ln_loading_rate_hrs NUMBER;
	ln_partial_storage_level NUMBER;
    v_ETD_date DATE;
    v_LS_date DATE;
	v_control_date DATE;

	--END TLXT

BEGIN

    -- If a parcel number was passed in, then we want to return the result for a single row only (the parcel's loading or unloading event)
    -- Use a private helper function to get that result for us (from the cache).
    IF p_parcel_no IS NOT NULL THEN
        v_return_row := getSingleStorageLevel(p_storage_id, p_forecast_id, p_parcel_no, p_open_close);
        PIPE ROW (v_return_row);
        RETURN;
    END IF;

    -- Get the return record
    v_return_row := new UE_CT_STOR_FCST_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    v_return_row.object_id := p_storage_id;
    v_return_row.forecast_id := p_forecast_id;
    v_return_row.event_type := 'DAY_OPEN';
    v_return_row.daytime := ec_forecast.start_date(p_forecast_id);
    v_start_date := nvl(p_daytime, ec_forecast.start_date(p_forecast_id));
    v_end_date := nvl(p_end_date, ec_forecast.end_date(p_forecast_id));

    -- LBFK - START
    -- Get Loading Rate from contract attributes
    select DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND') into v_contract_code from dual;
    v_loading_rate := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', v_contract_code),'LOADING_RATE',v_start_date,'<=');
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','contract code ' || v_contract_code || ' Loading Rate ' || v_loading_rate || ' Daytime ' || v_start_date);

    -- LBFK - END

    -- Single lifting? Old Code
--    IF p_parcel_no IS NOT NULL THEN
         --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 1 - Parcel No: ' || p_parcel_no);
--        v_start_date := ec_stor_fcst_lift_nom.nom_firm_date(p_parcel_no, p_forecast_id) - 1;
--        v_end_date := v_start_date + 3;
--        v_return_row.daytime := v_start_date;
--        v_return_row.storage_level := calcStorageLevel(p_storage_id, p_forecast_id, v_start_date - 1);
--    END IF;

    IF v_start_date <= ec_forecast.start_date(p_forecast_id) THEN
        -- Set the initial storage level
        --TLXT: 101023
        --to account any nominated vol from when it start loaded until midnight
        SELECT SUM((EST_DEPARTURE - LOADING_START_TIME)*24),  SUM((v_start_date-LOADING_START_TIME)*24), SUM((EST_DEPARTURE - v_start_date)*24), MAX(EST_DEPARTURE),MAX(LOADING_START_TIME)
        INTO ln_loading_hours,ln_loading_hours_prior,ln_loading_hours_post, v_ETD_date, v_LS_date
        FROM DV_CARGO_INFO
        WHERE DAYTIME = (v_start_date-1)
        AND EXISTS(SELECT 'TRUE' FROM DV_STORAGE_LIFT_NOMINATION A WHERE A.CARGO_NO = DV_CARGO_INFO.CARGO_NO AND OBJECT_ID = p_storage_id);

        SELECT SUM(NOM_GRS_VOL)
        INTO ln_total_nominated
        FROM DV_STORAGE_LIFT_NOMINATION
        WHERE NOM_DATE = (v_start_date-1)
        AND OBJECT_ID = p_storage_id;

        v_control_date := p_daytime-1;
        IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') in ('ESTIMATED_VOL') THEN
            ln_partial_storage_level := Ue_Trans_Storage_Balance.calcStorageLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)-1, NULL, 0) ;
            --ECDP_DYNSQL.WRITETEMPTEXT('TEST','ln_partial_storage_level='||ln_partial_storage_level);
        END IF;
        IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') in ('USER_DEFINED') THEN
            ln_partial_storage_level := NVL(ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', v_contract_code),'OPN_STORAGE',v_start_date,'<='),0);
        END IF;
        IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') in ('HALF_STORAGE') THEN
            ln_partial_storage_level := ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)) +
                            (
                                ue_storage_balance.getMaxSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)) - ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id))
                            ) / 2;
        END IF;


        IF NVL(ln_loading_hours,0) > 0 THEN
            ln_loading_rate_hrs:=v_loading_rate;
            ln_loading_hours := ln_total_nominated/ln_loading_rate_hrs;
            ln_partial_loaded_prior := ln_loading_rate_hrs * ln_loading_hours_prior;
            ln_loading_hours_post :=  (ln_loading_hours - ln_loading_hours_prior);
            ln_partial_loaded_post := ln_loading_rate_hrs * ln_loading_hours_post;

            --ln_partial_storage_level := Ue_Trans_Storage_Balance.calcStorageLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)-1, NULL, 0) ;


            --ECDP_DYNSQL.WRITETEMPTEXT('TEST','ln_partial_loaded_prior='||ln_partial_loaded_prior);
            --ln_partial_storage_level:= ln_partial_storage_level - ln_partial_loaded_prior;
            v_return_row.storage_level := ln_partial_storage_level;

            pipe row(v_return_row); --THIS IS TO PIPE IN THE DAY OPEN
            --NOW CHECK TO SEE IF THERE IS ANY LOADING ACROSS THE START DATE OF THE SCENARIO
            IF NVL(ln_partial_loaded_post,0) > 0 THEN

                --pipe row(v_return_row);
                -- Set the results of the partial lifting
                v_return_row.daytime := ec_forecast.start_date(p_forecast_id) + (ln_loading_hours_post/24);
                v_return_row.storage_level := ln_partial_storage_level+(ue_storage_plan.calcdailystorageplan(p_storage_id, ec_forecast.start_date(p_forecast_id), ec_forecast.start_date(p_forecast_id), NULL, NULL) / 24)*ln_loading_hours_post - nvl(ln_partial_loaded_post,0);
                --v_return_row.storage_level := ln_partial_storage_level+(ue_storage_plan.calcdailystorageplan(p_storage_id, ec_forecast.start_date(p_forecast_id), ec_forecast.start_date(p_forecast_id), NULL, NULL) / 24)*ln_loading_hours_post ;
                v_return_row.event_type := 'CARGO_CLOSE';
                PIPE ROW (v_return_row);
                --this is important to keep the cache value as of the opening of previous day minus of whathas been loaded.
                v_return_row.storage_level := ln_partial_storage_level- nvl(ln_partial_loaded_post,0);
            END IF;

        ELSE
            --ECDP_DYNSQL.WRITETEMPTEXT('TEST','ELSE BLOCK');
            --v_return_row.storage_level := Ue_Trans_Storage_Balance.calcStorageLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)-1, NULL, 0);
            v_return_row.storage_level := ln_partial_storage_level;
            v_control_date := p_daytime;
        END IF;
        --end edit TLXT: 101023
        v_start_date := ec_forecast.start_date(p_forecast_id);
        v_return_row.daytime := v_start_date;
    END IF;

    -- Do we return the opening storage level?
    IF p_daytime = v_control_date THEN
        PIPE ROW (v_return_row);
    END IF;

    -- Iterate through the giant cursor
    FOR item IN event_storage_graph(v_start_date, v_end_date, v_loading_rate) LOOP

        -- Set the results on the return row from the cursor
        v_return_row.daytime := item.next_daytime;
        --the storage level is a cached value from previous record.
        v_return_row.storage_level := v_return_row.storage_level + (item.duration_hrs * item.hourly_rate);
        --v_return_row.event_type := item.INDICATOR; -- REPLACED BY NEXT LINE SWGN 09-FEB-2015
        v_return_row.event_type := item.NEXT_INDICATOR; -- SWGN 09-FEB-2015
        v_return_row.item_no := item.item_no;

        IF p_parcel_no IS NULL THEN
            -- Only return rows within the date range requested, and be careful to return non-distinct dates if necessary
            -- The graph UI chokes if multiple rows with the same date are returned, but the individual record cache needs one record per event regardless of daytime
            IF v_return_row.daytime >= p_daytime AND v_return_row.daytime <= p_end_date+1 AND ((p_distinct = 'DISTINCT' AND item.duration_hrs > 0) OR p_distinct <> 'DISTINCT') THEN
				--ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 5 - v_return_row.daytime: ' || v_return_row.daytime || ' p_daytime: ' || p_daytime || ' p_end_date ' || p_end_date || ' p_distinct ' || p_distinct || ' item.duration_hrs ' || item.duration_hrs || ' v_return_row.event_type ' || v_return_row.event_type || ' item_no ' || v_return_row.item_no);
  --          IF v_return_row.daytime >= p_daytime AND v_return_row.daytime <= p_end_date AND item.duration_hrs > 0 THEN
                PIPE ROW (v_return_row);
            END IF;

        -- SWGN: 26-JAN-2014 - this part of the package is no longer necessary. I have left it commented out as opposed to deletion, for future reference.
--        ELSE
--            ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 5 - Parcel No: ' || p_parcel_no || ' Item No: ' || v_item_number || ' - ' || item.item_no || ' -- ' || v_return_row.event_type || ' --- ' || p_open_close || ' Daytime: ' || item.daytime);
--            IF item.item_no = v_item_number AND v_return_row.event_type = 'CARGO_' || p_open_close THEN
--                ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 6 - Parcel No: ' || p_parcel_no || ' Item No: ' || v_item_number || ' - ' || p_open_close);
--                v_return_row.storage_level := v_return_row.storage_level - (item.duration_hrs * item.hourly_rate);
--                PIPE ROW (v_return_row);
--                EXIT;
--            END IF;
        END IF;
    END LOOP;

END calcStorageLevelTable;

---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevelMod
-- Description    : Calculates the storage level graph for a period. The original version (calcStorageLevelTable) was modified to return a number
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevelMod(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN')
RETURN NUMBER
IS

    -- Three part cursor:
    -- A) All cargo openings, which contribute a drain to storage
    -- B) All cargo closings, which negate a storage drain
    -- C) The daily production forecast, which contributes production into storage
    CURSOR event_storage_graph(cp_start_date DATE, cp_end_date DATE) IS
    SELECT OBJECT_ID,
           DAYTIME,
           ITEM_NO,
           LEAD(DAYTIME, 1, DAYTIME) OVER (ORDER BY DAYTIME, INDICATOR) AS NEXT_DAYTIME,
           (LEAD(DAYTIME, 1, DAYTIME) OVER (ORDER BY DAYTIME, INDICATOR) - DAYTIME) * 24 AS DURATION_HRS,
           FORECAST_ID,
           LEAD(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS NEXT_INDICATOR,
           INDICATOR,
           LAG(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS PREV_INDICATOR,
--           CASE WHEN INDICATOR = 'DAY_OPEN' AND LAG(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) = 'CARGO_OPEN' THEN STORAGE_RATE - LAG(LOADING_RATE, 1, 0) OVER (ORDER BY DAYTIME, INDICATOR)
--                ELSE STORAGE_RATE - NVL(LOADING_RATE, 0) END AS HOURLY_RATE
           STORAGE_RATE + SUM(DECODE(INDICATOR,'DAY_OPEN',0,'CARGO_OPEN',-LOADING_RATE,'CARGO_CLOSE',LOADING_RATE)) OVER (ORDER BY DAYTIME) AS HOURLY_RATE
           FROM
           (
                SELECT NOM.OBJECT_ID AS OBJECT_ID,
                CASE WHEN MAX(NOM.START_LIFTING_DATE) < cp_start_date AND MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24) > cp_start_date
                    THEN cp_start_date ELSE MAX(NOM.START_LIFTING_DATE) END AS DAYTIME,
                FCAST.OBJECT_ID AS FORECAST_ID,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_OPEN' AS INDICATOR,
                DECODE(MAX(FCVER.TEXT_10),'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), MAX(NOM.NOM_FIRM_DATE), MAX(FCAST.START_DATE), MAX(FCVER.TEXT_9), MAX(FCVER.TEXT_8),MAX(FCVER.REF_OBJECT_ID_1)) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(MAX(NOM.OBJECT_ID), MAX(NOM.NOM_FIRM_DATE), p_forecast_id) / 24
                ) AS STORAGE_RATE,
                COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<=')) AS LOADING_RATE
                FROM STOR_FCST_LIFT_NOM NOM,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE NOM.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND NOM.NOM_FIRM_DATE >= FCVER.DAYTIME
                AND NOM.NOM_FIRM_DATE <= NVL(FCVER.END_DATE, NOM.NOM_FIRM_DATE + 1)
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_FCST_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO, p_forecast_id), EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, FCAST.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                SELECT NOM.OBJECT_ID AS OBJECT_ID,
                MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24) AS DAYTIME,
                FCAST.OBJECT_ID AS FORECAST_ID,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_CLOSE' AS INDICATOR,
                DECODE(MAX(FCVER.TEXT_10),'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24)), MAX(FCAST.START_DATE), MAX(FCVER.TEXT_9), MAX(FCVER.TEXT_8),MAX(FCVER.REF_OBJECT_ID_1)) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<='))) / 24)), p_forecast_id) / 24
                ) AS STORAGE_RATE,
                COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(NOM.OBJECT_ID),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',MAX(NOM.START_LIFTING_DATE),'<=')) AS LOADING_RATE
                FROM STOR_FCST_LIFT_NOM NOM,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE NOM.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND NOM.NOM_FIRM_DATE >= FCVER.DAYTIME
                AND NOM.NOM_FIRM_DATE <= NVL(FCVER.END_DATE, NOM.NOM_FIRM_DATE + 1)
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_FCST_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO, p_forecast_id), EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, FCAST.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                SELECT GRAPH.OBJECT_ID,
                GRAPH.DAYTIME,
                GRAPH.FORECAST_ID AS FORECAST_ID,
                NULL AS ITEM_NO,
                'DAY_OPEN' AS INDICATOR,
                DECODE(FCVER.TEXT_10,'PROD_PLAN_FCAST',
                    ue_storage_plan.calcdailystorageplan(GRAPH.OBJECT_ID, GRAPH.DAYTIME, FCAST.START_DATE, FCVER.TEXT_9, FCVER.TEXT_8, FCVER.REF_OBJECT_ID_1) / 24,
                    ec_stor_day_fcst_fcast.forecast_qty(GRAPH.OBJECT_ID, GRAPH.DAYTIME, p_forecast_id) / 24
                ) AS STORAGE_RATE, --ue_stor_fcst_balance
                NULL AS LOADING_RATE
                FROM CV_FCST_STORAGE_GRAPH GRAPH,
                FORECAST FCAST,
                FORECAST_VERSION FCVER
                WHERE GRAPH.FORECAST_ID = FCAST.OBJECT_ID
                AND FCAST.OBJECT_ID = FCVER.OBJECT_ID
                AND GRAPH.DAYTIME >= FCVER.DAYTIME
                AND GRAPH.DAYTIME <= NVL(FCVER.END_DATE, GRAPH.DAYTIME + 1)
                AND GRAPH.DAYTIME >= cp_start_date
                AND GRAPH.DAYTIME <= cp_end_date
                )
            WHERE FORECAST_ID = p_forecast_id
            AND OBJECT_ID = p_storage_id
            AND DAYTIME >= cp_start_date
            AND DAYTIME <= cp_end_date
            AND NOT (INDICATOR = 'CARGO_CLOSE' AND DAYTIME = cp_start_date)
            ORDER BY DAYTIME, INDICATOR;

    v_return_row UE_CT_STOR_FCST_GRAPH_POINT;
    v_item_number NUMBER := NVL(ec_stor_fcst_lift_nom.cargo_no(p_parcel_no, p_forecast_id), p_parcel_no);
    v_storage_level NUMBER;
    v_start_date DATE;
    v_end_date DATE;
	v_contract_code VARCHAR2(32);


BEGIN
    -- Get the return record
    v_return_row := new UE_CT_STOR_FCST_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    v_return_row.object_id := p_storage_id;
    v_return_row.forecast_id := p_forecast_id;
    v_return_row.event_type := 'DAY_OPEN';
    v_return_row.daytime := ec_forecast.start_date(p_forecast_id);
    v_start_date := nvl(p_daytime, ec_forecast.start_date(p_forecast_id));
    v_end_date := nvl(p_end_date, ec_forecast.end_date(p_forecast_id));

    -- Get Loading Rate from contract attributes
    select DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND') into v_contract_code from dual;

    -- Single lifting?
    IF p_parcel_no IS NOT NULL THEN
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 1 - Parcel No: ' || p_parcel_no);
        v_start_date := ec_stor_fcst_lift_nom.nom_firm_date(p_parcel_no, p_forecast_id) - 1;
        v_end_date := v_start_date + 3;
        v_return_row.daytime := v_start_date;
        v_return_row.storage_level := calcStorageLevel(p_storage_id, p_forecast_id, v_start_date - 1);
    END IF;
    IF v_start_date <= ec_forecast.start_date(p_forecast_id) THEN
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 2 - Storage Estimation: ' || ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<='));
        -- Set the initial storage level
        IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') = 'ESTIMATED_VOL' THEN
            v_return_row.storage_level := Ue_Trans_Storage_Balance.calcStorageLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)-1, NULL, 0);
        ELSE
			IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') = 'HALF_STORAGE' THEN
				v_return_row.storage_level := ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)) +
                                (
                                    ue_storage_balance.getMaxSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id)) - ue_storage_balance.getMinSafeLimitVolLevel(p_storage_id, ec_forecast.start_date(p_forecast_id))
                                ) / 2;
			ELSE
				IF ec_forecast_version.text_7(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') = 'USER_DEFINED' THEN
					v_return_row.storage_level := NVL(ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', v_contract_code),'OPN_STORAGE',v_start_date,'<='),0);
				END IF;
			END IF;
		END IF;
        v_start_date := ec_forecast.start_date(p_forecast_id);
        v_return_row.daytime := v_start_date;
    END IF;
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 3 p_daytime: ' || p_daytime || ' Return daytime: ' || v_return_row.daytime);
    -- Do we return the opening storage level?
    IF p_daytime = v_return_row.daytime THEN
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 3.1 - Returning Opening Storage');
        RETURN v_return_row.storage_level;
        --PIPE ROW (v_return_row.storage_level);
    END IF;
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 8 - StartDate: ' || v_start_date || ' EndDate: ' || v_end_date);
    FOR item IN event_storage_graph(v_start_date, v_end_date) LOOP

        v_return_row.daytime := item.next_daytime;
        v_return_row.storage_level := v_return_row.storage_level + (item.duration_hrs * item.hourly_rate);
        v_return_row.event_type := item.INDICATOR;

        IF p_parcel_no IS NULL THEN
            IF v_return_row.daytime >= p_daytime AND v_return_row.daytime <= p_end_date AND item.duration_hrs > 0 THEN
                --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 4 - Parcel No: ' || p_parcel_no);
                RETURN v_return_row.storage_level;
                --PIPE ROW (v_return_row.storage_level);
            END IF;
        ELSE
            --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 5 - Parcel No: ' || p_parcel_no || ' Item No: ' || v_item_number || ' - ' || item.item_no || ' -- ' || v_return_row.event_type || ' --- ' || p_open_close || ' Daytime: ' || item.daytime);
            IF item.item_no = v_item_number AND v_return_row.event_type = 'CARGO_' || p_open_close THEN
                --ECDP_DYNSQL.WRITETEMPTEXT('UE_STOR_FCST_BALANCE','Entre 6 - Parcel No: ' || p_parcel_no || ' Item No: ' || v_item_number || ' - ' || p_open_close);
                v_return_row.storage_level := v_return_row.storage_level - (item.duration_hrs * item.hourly_rate);
                RETURN v_return_row.storage_level;
                --PIPE ROW (v_return_row.storage_level);
                EXIT;
            END IF;
        END IF;
    END LOOP;
    RETURN NULL;
END calcStorageLevelMod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccEstLiftedQtySubDay
-- Description    : Returns the total lifted quantity for the prevoius hours of the day for selected lifting account
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom, cargo_fcst_transport
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_forecast_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR   c_lifting (cp_lifting_account_id VARCHAR2, cp_forecast_id VARCHAR2, cp_cargo_off_qty_ind VARCHAR2, cp_startdate DATE, cp_enddate DATE) IS
    SELECT SUM(grs_vol_nominated) grs_vol_nominated, SUM(grs_vol_nominated2) grs_vol_nominated2, SUM(grs_vol_nominated3) grs_vol_nominated3
        FROM (    SELECT
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,null),n.grs_vol_nominated)) grs_vol_nominated,
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated2,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,1),   n.grs_vol_nominated2)) grs_vol_nominated2,
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated3,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,2),   n.grs_vol_nominated3)) grs_vol_nominated3
          FROM stor_fcst_lift_nom n, cargo_fcst_transport c
         WHERE n.lifting_account_id = cp_lifting_account_id
           AND nvl(n.DATE_9, n.START_LIFTING_DATE) between cp_startdate and cp_enddate
           AND nvl(n.deleted_ind, 'N') <> 'Y'
           AND c.cargo_no = n.cargo_no
           AND c.forecast_id = n.forecast_id
                --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                --AND    c.cargo_status <> 'D'
                AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS') <> 'D'
                --end edit
           AND c.forecast_id = cp_forecast_id
        UNION ALL
        SELECT n.grs_vol_nominated,
               n.grs_vol_nominated2,
               n.grs_vol_nominated3
          FROM stor_fcst_lift_nom n
         WHERE n.lifting_account_id = cp_lifting_account_id
           AND n.forecast_id = cp_forecast_id
           AND nvl(n.DATE_9, n.START_LIFTING_DATE) between cp_startdate and cp_enddate
           AND nvl(n.deleted_ind, 'N') <> 'Y'
           AND n.cargo_no is null) a;

  ln_lifted_qty  NUMBER;

BEGIN

    FOR curLifted IN c_lifting (p_lifting_account_id, p_forecast_id, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_startdate, p_enddate) LOOP
        IF (p_xtra_qty = 1 ) THEN
            ln_lifted_qty := curLifted.grs_vol_nominated2 ;
        ELSIF (p_xtra_qty = 2 ) THEN
            ln_lifted_qty := curLifted.grs_vol_nominated3 ;
        ELSE
            ln_lifted_qty := curLifted.grs_vol_nominated ;
        END IF;
    END LOOP;

  RETURN ln_lifted_qty;

END getAccEstLiftedQtySubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevelSubDay
-- Description    : Gets the storage level for a date based on planned/official production.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_sub_day_fcst_fcast,  stor_sub_day_official, storage_nomination
--
-- Using functions: calcStorageLevel, EcDp_ProductionDay.getProductionDay
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevelSubDay(p_storage_id  VARCHAR2,
                                p_forecast_id VARCHAR2,
                                p_daytime     DATE,
                                p_summer_time VARCHAR2,
                                p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS
    CURSOR c_sum_in(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
        SELECT SUM(f.forecast_qty) OP,
               SUM(f.forecast_qty2) OP2,
               SUM(f.forecast_qty3) OP3
          FROM stor_sub_day_fcst_fcast f
         WHERE f.object_id = cp_storage_id
           AND f.daytime >= cp_start
           AND f.daytime <= cp_end
           AND f.forecast_id = cp_forecast_id;

    CURSOR c_sum_intercept(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_summer_time VARCHAR2) IS
        SELECT SUM(f.forecast_qty) OP,
               SUM(f.forecast_qty2) OP2,
               SUM(f.forecast_qty3) OP3
          FROM stor_sub_day_fcst_fcast f
         WHERE f.object_id = cp_storage_id
           AND f.daytime >= cp_start
           AND f.daytime <= cp_end
           AND f.forecast_id = cp_forecast_id
           AND f.summer_time = cp_summer_time;


    CURSOR c_sumerTime_flag(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE) IS
        SELECT ecdp_date_time.summertime_flag(t.daytime) summerFlag
        from stor_sub_day_fcst_fcast t
        where t.daytime >= cp_start
            AND t.daytime <= cp_end
            AND t.object_id = cp_storage_id;

    CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_cargo_off_qty_ind VARCHAR2, cp_xtra_qty NUMBER) IS
        SELECT SUM(lifted) lifted_qty
          FROM (
                SELECT  decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated2, nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,1),    n.grs_vol_nominated2)),
              2, decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated3, nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,2),    n.grs_vol_nominated3)),
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated,  nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,null), n.grs_vol_nominated))
              )  lifted
                 FROM stor_fcst_lift_nom n, cargo_fcst_transport c
                 WHERE n.object_id = cp_storage_id
                   AND n.forecast_id = c.forecast_id
                   AND n.forecast_id = cp_forecast_id
                   AND nvl(n.deleted_ind, 'N') <> 'Y'
                   AND c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS') <> 'D'
                    --end edit
                   AND nvl(n.DATE_9, n.START_LIFTING_DATE) >= cp_start
                   AND nvl(n.DATE_9, n.START_LIFTING_DATE) <= cp_end
                UNION ALL
                SELECT decode (cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3) lifted
                  FROM stor_fcst_lift_nom n
                 WHERE n.object_id = cp_storage_id
                   AND n.forecast_id = cp_forecast_id
                   AND n.cargo_no IS NULL
                   AND n.START_LIFTING_DATE >= cp_start
                   AND n.START_LIFTING_DATE <= cp_end
                   AND nvl(n.deleted_ind, 'N') <> 'Y') a;

    ld_today          DATE;
    ld_startDate      DATE;
    ln_Dip            NUMBER;
    lnTotalIn         NUMBER;
    lnTotalOut        NUMBER;
    ld_production_day DATE;
    lv_summer_flag   VARCHAR2(32);

BEGIN
    ld_production_day := EcDp_ProductionDay.getProductionDay('STORAGE', p_storage_id, p_daytime, p_summer_time);
    ld_startDate      := EcDp_ProductionDay.getProductionDayStart('STORAGE', p_storage_id, ld_production_day);
    ld_today          := TRUNC(ecdp_date_time.getCurrentSysdate);

    -- get opening balance of the day need to check if production day is required
    ln_Dip := calcStorageLevel(p_storage_id, p_forecast_id, ld_production_day - 1, p_xtra_qty);

    --checking the summer time flag intercept
    FOR curIn IN c_sumerTime_flag(p_storage_id, ld_startDate, p_daytime) LOOP
        lv_summer_flag := curIn.summerFlag;
    END LOOP;

    IF(p_summer_time != lv_summer_flag)THEN
    -- Get forecast/official production during an intercept
    FOR curIn IN c_sum_intercept(p_storage_id, p_forecast_id, ld_startDate, p_daytime, p_summer_time) LOOP
        IF (p_xtra_qty = 1 ) THEN
            lnTotalIn := curIn.op2;
        ELSIF (p_xtra_qty = 2 ) THEN
            lnTotalIn := curIn.op3;
        ELSE
            lnTotalIn := curIn.op;
        END IF;
    END LOOP;
    ELSE        -- Get forecast/official production normal operations
    FOR curIn IN c_sum_in(p_storage_id, p_forecast_id, ld_startDate, p_daytime) LOOP
        IF (p_xtra_qty = 1 ) THEN
            lnTotalIn := curIn.op2;
        ELSIF (p_xtra_qty = 2 ) THEN
            lnTotalIn := curIn.op3;
        ELSE
            lnTotalIn := curIn.op;
        END IF;
    END LOOP;
    END IF;

    -- get all nominations
    FOR curOut IN c_sum_out(p_storage_id, p_forecast_id, ld_StartDate, p_daytime, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty) LOOP
        lnTotalOut := curOut.lifted_qty;
    END LOOP;

    IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
        RETURN ln_Dip - Nvl(lnTotalIn, 0) + Nvl(lnTotalOut, 0);
    ELSE
        RETURN ln_Dip + Nvl(lnTotalIn, 0) - Nvl(lnTotalOut, 0);
    END IF;

END calcStorageLevelSubDay;

/* LBFK - Not sure yet what would be used for
FUNCTION getSumOutInDayMass(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            ) RETURN NUMBER
IS
BEGIN

  RETURN(NVL(calcSumOutOrInForADay(p_storage_id,p_forecast_id,p_daytime,'IN') *
    ec_strm_reference_value.density(ec_stor_version.plan_object_id(p_storage_id,p_daytime,'<='),p_daytime,'<='),0));

END getSumOutInDayMass;*/

/* LBFK - Not sure yet what would be used for
FUNCTION getSumOutInDayEnergy(p_storage_id VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_daytime DATE,
            p_type VARCHAR2 DEFAULT 'OUT',
            p_xtra_qty NUMBER DEFAULT 0,
            p_cargo_off_qty_ind VARCHAR2 DEFAULT 'N'
            ) RETURN NUMBER
IS

BEGIN

  RETURN(NVL(getSumOutInDayMass(p_storage_id,p_forecast_id,p_daytime,'IN') *
    ec_strm_reference_value.gcv(ec_stor_version.plan_object_id(p_storage_id,p_daytime,'<='),p_daytime,'<='),0));


END getSumOutInDayEnergy;*/

END UE_STOR_FCST_BALANCE;
/