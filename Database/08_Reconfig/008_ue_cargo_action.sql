create or replace PACKAGE ue_cargo_action IS
/******************************************************************************
** Package        :  ue_cargo_action, head part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Created      :
**
** Modification history:
**
** Date          Whom        Change description:
** ------        -----       -----------------------------------------------------------------------------------------------
** 16 Oct 2009  oonnnng       ECPD-12790: Initial version.
********************************************************************************************************************************/

PROCEDURE EXECUTE(
  p_action      VARCHAR2,
  p_cargo_no    NUMBER default -1,
  p_parcel_no   NUMBER default -1,
  p_parameter   VARCHAR2 default ''
);

END ue_cargo_action;
/
create or replace PACKAGE BODY ue_cargo_action IS
/******************************************************************************
** Package        :  ue_cargo_action, body part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created      :
**
** Modification history:
**
** Date          Whom        Change description:
** ------        -----       -----------------------------------------------------------------------------------------------
** 16 Oct 2009  oonnnng       ECPD-13039: Initial version.
** 15 Nov 2016  cvmk          112305: Modified populateMUL()
********************************************************************************************************************************/

-- Global cursors

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : execute
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--tlxt added comment: these were parameters called from the GenericCargoAction.class from com.ec.tran.cp.screens.model.ejb.GenericCargoAction
--    String itemID = this.userEvent.getParameter("itemID");
--    String cargo_no = this.userEvent.getParameter("CARGO_NO");
--    String parcel_no = this.userEvent.getParameter("PARCEL_NO");
--    String param = this.userEvent.getParameter("PARAMETER");
--    String actionSql = "{call ue_cargo_action.execute(?,?,?,?)}";
--  124170 - KOIJ -  Allow more then 4 comingled liftings per cargo - generateCombCargo()
--                   Allow a previously commingled cargo to be assigned additional liftings during the SDS process    - populatecomblist()
--                   Allow multiple liftings, per lifter, per cargo
---------------------------------------------------------------------------------------------------
TYPE noms_type IS TABLE OF DV_FCST_STOR_LIFT_NOM%ROWTYPE;

PROCEDURE adjustPlanAroundCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2,
    p_days            NUMBER)
IS
    CURSOR cargos_to_adjust(c_cargo_date DATE, c_storage_id VARCHAR2) IS
        SELECT nom.*
        FROM STOR_FCST_LIFT_NOM nom
        WHERE nom.forecast_id = p_forecast_id
        AND NVL(NOM.RECORD_STATUS,'P') = 'P'
        and nom.object_id = c_storage_id
        AND (  (nom.CARGO_NO = p_cargo_no AND nom.nom_firm_date = c_cargo_date) OR
         nom.nom_firm_date >
        (
            SELECT nomx.nom_firm_date
            FROM STOR_FCST_LIFT_NOM nomx
            WHERE nomx.forecast_id = p_forecast_id
            and nomx.object_id = c_storage_id
            AND coalesce(nomx.cargo_no, -1) = coalesce(p_cargo_no, nomx.cargo_no, -1)
            AND coalesce(nomx.parcel_no, -1) = coalesce(p_parcel_no, nomx.parcel_no, -1)
            AND NVL(nomx.RECORD_STATUS,'P') = 'P'
        )
        )
        FOR UPDATE OF nom.nom_firm_date, nom.START_LIFTING_DATE,nom.text_9,nom.text_7;

    v_rows_updated NUMBER;
    --13-JAN-2015: TLXT: WORKITEM: 93406
    v_cargo_date DATE := ec_STOR_FCST_LIFT_NOM.nom_firm_date(p_parcel_no, p_forecast_id);
    v_record_status VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_5(p_forecast_id,v_cargo_date,'<=');
    --END EDIT
    v_first_cargo_date DATE ;
    v_last_cargo_date DATE ;
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id) ;



BEGIN
    SELECT MIN(NOM_DATE) + p_days into v_first_cargo_date FROM DV_FCST_STOR_LIFT_NOM WHERE FORECAST_ID = p_forecast_id AND NOM_DATE >=v_cargo_date;
    SELECT MAX(NOM_DATE) + p_days into v_last_cargo_date FROM DV_FCST_STOR_LIFT_NOM WHERE FORECAST_ID = p_forecast_id AND NOM_DATE >=v_cargo_date;
    --ecdp_dynsql.WriteTempText('CargoAction','adjustPlanAroundCargo - p_cargo_no [' || p_cargo_no || '] p_parcel_no [' || p_parcel_no || '] p_forecast_id [' || p_forecast_id || ']');
    IF v_record_status = 'P' THEN
        v_rows_updated := 0;
        IF v_first_cargo_date < EC_FORECAST.START_DATE(p_forecast_id) THEN
            --CANNOT MOVE THE NOMINATION OUT OF THE RANGE
            RAISE_APPLICATION_ERROR('ORA-25137', 'Cannot move a Cargo out of the beginning of the scenario');
        END IF;
        IF v_last_cargo_date >= EC_FORECAST.END_DATE(p_forecast_id) THEN
            --CANNOT MOVE THE NOMINATION OUT OF THE RANGE
            RAISE_APPLICATION_ERROR('ORA-25137', 'Cannot move a Cargo out of the End of the scenario');
        END IF;
        FOR rec IN cargos_to_adjust(v_cargo_date,v_storage_id ) LOOP
            UPDATE STOR_FCST_LIFT_NOM nom
                SET nom.nom_firm_date = nom.nom_firm_date + p_days,
                    nom.START_LIFTING_DATE = nom.START_LIFTING_DATE + p_days,
                    nom.text_9 = null, --EQYP TFS Work Item 91580 (CP -Business Function - Nomination Entry / Schedule Lifting (Scenario)) When nomination details have changed as a result of context menu action, the NOM_VALID attribute is to be reset to null.
                    nom.text_7 = null
            WHERE CURRENT OF cargos_to_adjust;

            v_rows_updated := v_rows_updated + 1;
        END LOOP;

        --EcDp_DynSql.WriteTempText('CARGO_ACTION', v_rows_updated);
    END IF;
END adjustPlanAroundCargo;

PROCEDURE adjustPlanIdealizeCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
    --v_storage_id VARCHAR2(32) := ec_forecast.storage_id(p_forecast_id);
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id) ;
    v_cargo_date DATE := ec_STOR_FCST_LIFT_NOM.nom_firm_date(p_parcel_no, p_forecast_id);
    v_max NUMBER := ecbp_storage.getmaxsafelimitvollevel(v_storage_id, v_cargo_date);
    v_min NUMBER := ecbp_storage.getminsafelimitvollevel(v_storage_id, v_cargo_date);
    v_thres NUMBER := ec_stor_version.lift_prg_threshold_qty(v_storage_id, v_cargo_date, '<=');
    v_nom NUMBER := ec_stor_version.lift_prg_nom_qty(v_storage_id, v_cargo_date, '<=');
    v_new NUMBER := ec_STOR_FCST_LIFT_NOM.grs_vol_nominated(p_parcel_no, p_forecast_id);
    v_adjustedStorageThreshold NUMBER;

    v_dummy NUMBER;
    v_startDate DATE;
    v_endDate DATE;
    v_currentDate DATE;

    v_storageLevel NUMBER;
    v_storageLevel_next_day NUMBER;

    v_current_upp_ratio NUMBER;
    v_current_btm_ratio NUMBER;
    v_TH_Max NUMBER;
    v_TH_Min NUMBER;
    v_upper_ratio NUMBER;
    v_lower_ratio NUMBER;
    v_total_avail NUMBER;

BEGIN

    --get current Storage upper and lower ratio
    v_TH_Min := (v_thres - v_nom);

    v_current_upp_ratio := (v_max - v_thres) ;
    v_current_btm_ratio := (v_TH_Min - v_min);

    v_total_avail := v_nom + v_current_upp_ratio + v_current_btm_ratio;

    --get new adjustmentupper and lower ratio
    v_upper_ratio := v_current_upp_ratio /(v_current_upp_ratio+v_current_btm_ratio)*(v_total_avail-v_new);

    v_lower_ratio := v_current_btm_ratio /(v_current_upp_ratio+v_current_btm_ratio)*(v_total_avail-v_new);

--ECDP_DYNSQL.WRITETEMPTEXT('CARGO_SIOBI' , 'p_cargo_no=' || p_cargo_no || ' p_parcel_no=' || p_parcel_no || ' p_forecast_id='||p_forecast_id || ' v_TH_Min=' ||v_TH_Min || ' v_current_upp_ratio=' || v_current_upp_ratio || 'v_current_btm_ratio=' ||v_current_btm_ratio || ' v_total_avail=' ||v_total_avail || ' v_upper_ratio=' ||v_upper_ratio ||'v_lower_ratio=' ||v_lower_ratio );

-- to ensure the TH didn't get more than the Tank Max.
/*
    IF v_upper_ratio < 0 THEN
        v_lower_ratio := v_lower_ratio + v_upper_ratio;
        v_upper_ratio := 0;
    END IF;
*/
    v_adjustedStorageThreshold := v_max - v_upper_ratio;
    v_TH_Min := v_min + v_lower_ratio;

    --v_adjustedStorageThreshold := v_new + v_min + ( (v_thres - v_nom - v_min) * (v_max - v_min - v_nom) / (v_max - v_min - v_new ) );


    SELECT count(*) INTO v_dummy
    FROM STOR_FCST_LIFT_NOM
    WHERE forecast_id = p_forecast_id
    AND nom_firm_date < v_cargo_date;

    IF (v_dummy > 0) THEN
        SELECT MAX(nom_firm_date) + 1 INTO v_startDate
        FROM STOR_FCST_LIFT_NOM
        WHERE forecast_id = p_forecast_id
        AND nom_firm_date < v_cargo_date;

        LOOP
            SELECT storage_level INTO v_storageLevel
            FROM dv_stor_day_bal_fcst_graph
            WHERE forecast_id = p_forecast_id
            AND object_id = v_storage_id
            AND daytime = v_startDate - 1;

            --check to see is the storage gets lesser? if yes, it means it was a cross day lifting from the previous nomination
            SELECT storage_level INTO v_storageLevel_next_day
            FROM dv_stor_day_bal_fcst_graph
            WHERE forecast_id = p_forecast_id
            AND object_id = v_storage_id
            AND daytime = v_startDate;

            v_startDate := v_startDate + 1;

            EXIT WHEN v_storageLevel_next_day >= v_storageLevel;
        END LOOP;
        v_startDate := v_startDate - 1;

    ELSE
        v_startDate := ec_forecast.start_date(p_forecast_id);

        IF ec_forecast_version.text_7(p_forecast_id, sysdate, '<=') = 'HALF_STORAGE' THEN
            v_storageLevel := v_min + (v_max - v_min) / 2;
        ELSE
            v_storageLevel := Ue_Stor_Fcst_Balance.calcStorageLevel(v_storage_id, p_forecast_id, v_startDate - 1);
        END IF;
    END IF;

    v_endDate := ec_forecast.end_date(p_forecast_id);
    v_currentDate := v_startDate;

    --ecdp_dynsql.writetemptext('IDEALIZE', 'Starting Idealize Cycle: Start Date [' || to_char(v_startDate, 'DD-MON-YYYY') || '] Starting Storage Volume [' || v_storageLevel || '] Target Cargo Volume [' || v_new || '] Threshold [' || v_adjustedStorageThreshold || ']');
-- ENDDATE IS NOT INCLUSIVE BECAUSE THE dv_fcst_stor_day_ent_la ISN'T INCLUDE THE FORECAST END DATE
    WHILE v_currentDate < v_endDate LOOP
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION' , 'p_cargo_no=' || p_cargo_no || ' v_currentDate=' ||v_currentDate || ' v_endDate=' || v_endDate);

        SELECT NVL(v_storageLevel,0) + NVL(prod_qty,0) INTO v_storageLevel
        FROM dv_fcst_stor_day_ent_la
        WHERE forecast_id = p_forecast_id
        AND object_id = v_storage_id
        AND daytime = v_currentDate;
        -- Can the storage support the current cargo size?
        IF (v_storageLevel >= v_adjustedStorageThreshold) THEN

            --ecdp_dynsql.writetemptext('IDEALIZE','Reached threshold on day [' || to_char(v_currentDate, 'DD-MON-YYYY') || '], adjusting cargo');

            adjustPlanAroundCargo(p_cargo_no, p_parcel_no, p_forecast_id, v_currentDate - v_cargo_date);
            RETURN;
        END IF;



        v_currentDate := v_currentDate + 1;

        --ecdp_dynsql.writetemptext('IDEALIZE','Moving to day [' || to_char(v_currentDate, 'DD-MON-YYYY') || '] with storage level [' || v_storageLevel || ']');
    END LOOP;

END adjustPlanIdealizeCargo;

PROCEDURE deleteCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
-- the requirement is to delete the current record and peform an idealised on the next record
    --v_storage_id VARCHAR2(32) := ec_forecast.storage_id(p_forecast_id);
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_cargo_date_time DATE := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_id);
    v_cargo_date DATE := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
    v_record_status VARCHAR(2) := EC_STOR_FCST_LIFT_NOM.RECORD_STATUS(p_parcel_no, p_forecast_id);
    v_EXCESS_LIFTING_IND VARCHAR(2) := EC_STOR_FCST_LIFT_NOM.DELETED_IND(p_parcel_no, p_forecast_id);

    lv_cargo_no NUMBER;
    lv_parcel_no NUMBER;
    lv_forecast_id VARCHAR2(32);

    lv_EXCESS_LIFTING_IND VARCHAR2(1) := EC_STOR_FCST_LIFT_NOM.TEXT_13(p_parcel_no, p_forecast_id);
    lv_STOR_FCST_LIFT_NOM STOR_FCST_LIFT_NOM%ROWTYPE := EC_STOR_FCST_LIFT_NOM.ROW_BY_PK(p_parcel_no, p_forecast_id);
    lv_FORECAST FORECAST%ROWTYPE := EC_FORECAST.ROW_BY_OBJECT_ID(p_forecast_id);

     CURSOR del_cargo(cp_forecast_id VARCHAR2,cp_cargo_date_time DATE) IS
        SELECT a.cargo_no,a.parcel_no,a.forecast_id --into lv_cargo_no, lv_parcel_no, lv_forecast_id
        FROM DV_FCST_STOR_LIFT_NOM A
        WHERE FORECAST_ID = cp_forecast_id
        AND NOM_DATE_TIME = (SELECT MIN(B.NOM_DATE_TIME) FROM DV_FCST_STOR_LIFT_NOM B
        WHERE B.FORECAST_ID = A.FORECAST_ID
        AND B.OBJECT_ID = A.OBJECT_ID
        AND cp_cargo_date_time < B.NOM_DATE_TIME
        AND NVL(A.RECORD_STATUS,'P') = 'P'
        );


BEGIN

        --GET NEXT CARGO INFO BEFORE DELETE
        IF NVL(v_record_status,'P') = 'P' THEN
            FOR cur_delete IN del_cargo(p_forecast_id,v_cargo_date_time) LOOP
                lv_cargo_no := cur_delete.cargo_no;
                lv_parcel_no := cur_delete.parcel_no;
                lv_forecast_id := cur_delete.forecast_id;
            END LOOP;

            IF  NVL(ec_forecast_version.text_6(lv_forecast_id, v_cargo_date_time, '<='),'NULL') IN ('SDS','EX_SDS')
                 AND NVL(ec_stor_fcst_lift_nom.text_15(lv_parcel_no, lv_forecast_id), 'N') = 'Y' -- COPIED_IND
                 AND NVL(lv_EXCESS_LIFTING_IND,'N') <> 'Y' THEN
                    RAISE_APPLICATION_ERROR(-20768, 'Cannot Delete SDS nomination');
           END IF;

            -- DELETE CARGO SELECTED CARGO
           -- Delete nominations without cargo that doesn't exist in original data
                DELETE stor_fcst_lift_nom
                WHERE (fixed_ind is null or fixed_ind = 'N') AND cargo_no is NULL
                AND parcel_no = p_parcel_no
                AND forecast_id = lv_forecast_id
                AND parcel_no NOT IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no);

                --delete nominations that are connected to a cargo that doesn't exist in original data
                DELETE stor_fcst_lift_nom WHERE parcel_no IN (
                    SELECT n.parcel_no
                    FROM stor_fcst_lift_nom n, cargo_fcst_transport c
                    WHERE (fixed_ind is null or fixed_ind = 'N')
                          AND c.cargo_no = n.cargo_no
                          AND c.forecast_id = lv_forecast_id
                          AND EcBp_Cargo_Status.getEcCargoStatus(c.cargo_status) in ('T', 'O')
                        AND n.forecast_id = lv_forecast_id
                        AND n.parcel_no = p_parcel_no
                        AND parcel_no NOT IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no));

                UPDATE stor_fcst_lift_nom
                SET deleted_ind = 'Y'
                WHERE (fixed_ind is null or fixed_ind = 'N') AND cargo_no is NULL
                AND forecast_id = lv_forecast_id
                AND parcel_no = p_parcel_no
                AND parcel_no IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no);

                UPDATE stor_fcst_lift_nom
                SET deleted_ind = 'Y'
                WHERE parcel_no IN (
                    SELECT n.parcel_no
                    FROM stor_fcst_lift_nom n, cargo_fcst_transport c
                    WHERE (fixed_ind is null or fixed_ind = 'N')
                          AND c.cargo_no = n.cargo_no
                          AND c.forecast_id = p_forecast_id
                          AND EcBp_Cargo_Status.getEcCargoStatus(c.cargo_status) in ('T', 'O')
                        AND n.forecast_id = p_forecast_id
                        AND n.parcel_no = p_parcel_no
                        AND parcel_no IN (SELECT storage_lift_nomination.parcel_no FROM storage_lift_nomination WHERE storage_lift_nomination.parcel_no = stor_fcst_lift_nom.parcel_no));


                -- clean cargos that no longer have nominations
                EcBp_Cargo_Fcst_Transport.cleanLonesomeCargoes(p_forecast_id);
            COMMIT;

            IF lv_parcel_no IS NOT NULL THEN
                --IDEALISED
                adjustPlanIdealizeCargo(lv_cargo_no,lv_parcel_no,lv_forecast_id);
            END IF;
        END IF;
        --ecdp_dynsql.WriteTempText('ue_cargo_action','v_storage_id=' || v_storage_id || ' p_forecast_id=' ||p_forecast_id|| ' v_cargo_date_time=' ||v_cargo_date_time);

END deleteCargo;

PROCEDURE insertCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
-- the requirement is to delete the current record and peform an idealised on the next record
    --v_storage_id VARCHAR2(32) := ec_forecast.storage_id(p_forecast_id);
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_cargo_date_time DATE := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_id);
    v_cargo_date DATE := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
    lv_cargo_no NUMBER;
    lv_parcel_no NUMBER;
    lv_forecast_id VARCHAR2(32);
    --lv_REQ_TOLERANCE_TYPE VARCHAR2(32) := 'ACAP';
    lv_nom_vol NUMBER := EC_STOR_VERSION.LIFT_PRG_NOM_QTY(v_storage_id,v_cargo_date,'<=');

BEGIN

 --ADD 1 DAY AND IDEALIZE
    adjustPlanAroundCargo(p_cargo_no,p_parcel_no,p_forecast_id,1);

    v_cargo_date  := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
   --insert a blank record on the selected row and push the selected row down by performing an idealise func.

    INSERT INTO DV_FCST_STOR_LIFT_NOM(OBJECT_ID, REQ_DATE, REQ_GRS_VOL, REQ_TOLERANCE_TYPE, FORECAST_ID,NOM_DATE, NOM_DATE_TIME, NOM_GRS_VOL, LIFTING_ACCOUNT_ID)
     (SELECT OBJECT_ID, REQ_DATE, lv_nom_vol, REQ_TOLERANCE_TYPE, FORECAST_ID,NOM_DATE-1, NOM_DATE_TIME-1, lv_nom_vol, LIFTING_ACCOUNT_ID
     FROM DV_FCST_STOR_LIFT_NOM
    WHERE NOM_DATE = v_cargo_date
    AND OBJECT_ID = v_storage_id
    AND FORECAST_ID = p_forecast_id
    AND PARCEL_NO = p_parcel_no
    );


    --IDEALIZE THE EXISTING (the selected row) nomination
     adjustPlanIdealizeCargo(p_cargo_no,p_parcel_no,p_forecast_id);

END insertCargo;

PROCEDURE insertNewCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
-- the requirement is to insert a new cargo before the selected cargo
    --v_storage_id VARCHAR2(32) := ec_forecast.storage_id(p_forecast_id);
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_cargo_date_time DATE := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_id);
    v_cargo_date DATE := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
    lv_cargo_no NUMBER;
    lv_parcel_no NUMBER;
    lv_forecast_id VARCHAR2(32);
    lv_nom_vol NUMBER := EC_STOR_VERSION.LIFT_PRG_NOM_QTY(v_storage_id,v_cargo_date,'<=');
    --13-JAN-2015: TLXT: WORKITEM: 93406
    --v_cargo_date DATE := ec_STOR_FCST_LIFT_NOM.nom_firm_date(p_parcel_no, p_forecast_id);
    v_record_status VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_5(p_forecast_id,v_cargo_date,'<=');
    --END EDIT
BEGIN
    --ecdp_dynsql.WriteTempText('ue_cargo_action','p_cargo_no=' || p_cargo_no || ' p_forecast_id=' ||p_forecast_id|| ' p_parcel_no=' ||p_parcel_no);
    IF  v_record_status = 'P' THEN
        --adjustPlanAroundCargo(p_cargo_no,p_parcel_no,p_forecast_id,1);

        v_cargo_date  := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
       --insert a blank record on the selected row and push the selected row down by performing an idealise func.

        INSERT INTO DV_FCST_STOR_LIFT_NOM(OBJECT_ID, REQ_DATE, REQ_GRS_VOL, REQ_TOLERANCE_TYPE, FORECAST_ID,NOM_DATE, NOM_DATE_TIME, NOM_GRS_VOL, LIFTING_ACCOUNT_ID)
         (SELECT OBJECT_ID, NOM_DATE-1, lv_nom_vol, REQ_TOLERANCE_TYPE, FORECAST_ID,NOM_DATE-1, NOM_DATE_TIME-1, lv_nom_vol, LIFTING_ACCOUNT_ID
         FROM DV_FCST_STOR_LIFT_NOM
        WHERE NOM_DATE = v_cargo_date
        AND OBJECT_ID = v_storage_id
        AND FORECAST_ID = p_forecast_id
        AND PARCEL_NO = p_parcel_no
        );
    END IF;

END insertNewCargo;

PROCEDURE generateCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
-- the requirement is to delete the current record and peform an idealised on the next record
    --v_storage_id VARCHAR2(32) := ec_forecast.storage_id(p_forecast_id);
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_cargo_date_time DATE := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_id);
    v_records noms_type;
    --13-JAN-2015: TLXT: WORKITEM: 93406
    v_cargo_date DATE := ec_STOR_FCST_LIFT_NOM.nom_firm_date(p_parcel_no, p_forecast_id);
    v_record_status VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_5(p_forecast_id,v_cargo_date,'<=');
    --END EDIT
BEGIN
    IF v_record_status = 'P' THEN
       SELECT * BULK COLLECT INTO v_records
       FROM DV_FCST_STOR_LIFT_NOM A
        WHERE FORECAST_ID = p_forecast_id
        AND A.OBJECT_ID = nvl(v_storage_id, a.object_id)
        --AND  NOM_DATE_TIME >= nvl(v_cargo_date_time, nom_date_time)
        ORDER BY NOM_DATE_TIME;

        FOR cur_gen IN 1 ..  v_records.count LOOP
             UE_CARGO_FCST_TRANSPORT.CONNECTNOMTOCARGO(v_records(cur_gen).cargo_no,'(' || v_records(cur_gen).parcel_no || ')',v_records(cur_gen).forecast_id);
        END LOOP;
    END IF;

END generateCargo;
PROCEDURE generateOfficialCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
-- the requirement is to delete the current record and peform an idealised on the next record
    v_storage_id VARCHAR2(32) := EC_STORAGE_LIFT_NOMINATION.OBJECT_ID(p_parcel_no) ;
    v_cargo_date_time DATE := EC_STORAGE_LIFT_NOMINATION.START_LIFTING_DATE(p_parcel_no);

     CURSOR gen_cargo(cp_storage_id VARCHAR2,cp_cargo_date_time DATE) IS
        SELECT a.cargo_no,a.parcel_no
        FROM DV_STORAGE_LIFT_NOMINATION A
        WHERE (cp_cargo_date_time IS NULL OR NOM_DATE_TIME >= cp_cargo_date_time)
        AND (cp_storage_id IS NULL OR A.OBJECT_ID = cp_storage_id)
        ORDER BY NOM_DATE_TIME;

BEGIN
--ECDP_DYNSQL.WRITETEMPTEXT('SIOBI','v_storage_id=' || v_storage_id );
        FOR cur_gen IN gen_cargo(v_storage_id,v_cargo_date_time) LOOP
             UE_CARGO_TRANSPORT.CONNECTNOMTOCARGO(cur_gen.cargo_no,cur_gen.parcel_no);
        END LOOP;


END generateOfficialCargo;
PROCEDURE generateCombCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2,
    p_action VARCHAR2 DEFAULT NULL)
IS
-- the requirement is to delete the current record and peform an idealised on the next record
    --13-JAN-2015: TLXT: WORKITEM: 93406
    v_REQ_DATE DATE ;
    v_cargo_date DATE := ec_STOR_FCST_LIFT_NOM.nom_firm_date(p_parcel_no, p_forecast_id);
    v_record_status VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_5(p_forecast_id,v_cargo_date,'<=');
    --END EDIT

    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no,p_forecast_id);
    p_storage_code VARCHAR2(32):= ECDP_OBJECTS.GETOBJCODE(EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no,p_forecast_id));

    v_requestingLA_contactCode VARCHAR2(32);
    v_liftaccount_profitcentre VARCHAR2(256);
    v_liftaccount VARCHAR(32);
    v_profit_centre VARCHAR(32);
    v_liftingaccount_resolvedcode VARCHAR2(100);

--124170 Start KOIJ allow more then 4 comingled liftings per cargo
    --v_COMM_LIFTERS_LIST VARCHAR2(100);
    v_COMM_LIFTERS_LIST VARCHAR2(240);
    --124170 Start KOIJ allow more then 4 comingled liftings per cargo
    v_count number;
    v_valide VARCHAR2(4):='Y';
    v_cargo_no number;
    v_cargo_name VARCHAR2(32);
    v_parcel_no VARCHAR2(32);
    v_forecast_id VARCHAR2(32);
    ln_assign_id  NUMBER;
    ls_cargoName  VARCHAR2(100);
    lv_sql            VARCHAR2(1000);

    CURSOR ALL_COMB_NOM_BY_FORECAST(cp_to_forecast_id VARCHAR2, cp_REQ_DATE DATE DEFAULT NULL) IS
    SELECT OBJECT_ID,OBJECT_CODE,CARGO_NO, NOM_DATE,REQ_DATE, PURGE_COOL_IND, PURGE_COOL_QTY, PURGE_COOL_DURATION,CARRIER_CODE,NOM_VALID, VALIDATION_ISSUES
    , PARCEL_NO, COMM_LIFTERS_LIST, LIFTING_ACCOUNT_ID,LIFTING_ACCOUNT_CODE, PROFIT_CENTRE_ID,PROFIT_CENTRE_CODE,FORECAST_ID,FORECAST_CODE
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE NVL(COMBINE_IND,'N') = 'Y'
    AND COMM_LIFTERS_LIST IS NOT NULL
    and cargo_no is null
    AND FORECAST_ID = cp_to_forecast_id
    AND OBJECT_CODE = p_storage_code
    AND (cp_REQ_DATE IS NULL OR REQ_DATE = cp_REQ_DATE)
    ORDER BY PARCEL_NO;

    CURSOR RESOLVED_COMB_NOM_BY_FORECAST(cp_to_forecast_id VARCHAR2) IS
    SELECT OBJECT_ID,OBJECT_CODE,CARGO_NO, NOM_DATE,REQ_DATE, PURGE_COOL_IND, PURGE_COOL_QTY, PURGE_COOL_DURATION,CARRIER_CODE,NOM_VALID, VALIDATION_ISSUES,COMBINE_IND
    , PARCEL_NO, COMM_LIFTERS_LIST, LIFTING_ACCOUNT_ID,LIFTING_ACCOUNT_CODE, PROFIT_CENTRE_ID,PROFIT_CENTRE_CODE,FORECAST_ID,FORECAST_CODE
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE NVL(COMBINE_IND,'N') = 'Y'
    AND COMM_LIFTERS_LIST IS NOT NULL
    AND FORECAST_ID = cp_to_forecast_id
    AND OBJECT_CODE = p_storage_code
    AND REQ_DATE IN
    (
        SELECT REQ_DATE FROM (
            SELECT REQ_DATE, COUNT(*) NOM
            FROM (
                SELECT REQ_DATE,  COUNT(*)AS NOM
                FROM DV_FCST_STOR_LIFT_NOM
                WHERE FORECAST_ID = cp_to_forecast_id
                AND OBJECT_CODE = p_storage_code
                AND NVL(COMBINE_IND,'N') = 'Y'
                AND COMM_LIFTERS_LIST IS NOT NULL
                GROUP BY REQ_DATE
            ) A
            GROUP BY REQ_DATE
            HAVING COUNT(*) = 1
        ) B
    )
    AND VALIDATION_ISSUES LIKE '%UE_CARGO_ACTION%';
    --AND NVL(NOM_VALID,'Y') = 'Y';

CURSOR ADDNL_NOM_TO_CARGO_BY_FORECAST(cp_to_forecast_id VARCHAR2) IS
    SELECT OBJECT_ID,OBJECT_CODE,CARGO_NO, NOM_DATE,REQ_DATE, PURGE_COOL_IND, PURGE_COOL_QTY, PURGE_COOL_DURATION,CARRIER_CODE,NOM_VALID, VALIDATION_ISSUES,COMBINE_IND
    , PARCEL_NO, COMM_LIFTERS_LIST, LIFTING_ACCOUNT_ID,LIFTING_ACCOUNT_CODE, PROFIT_CENTRE_ID,PROFIT_CENTRE_CODE,FORECAST_ID,FORECAST_CODE
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE NVL(COMBINE_IND,'N') = 'Y'
    AND COMM_LIFTERS_LIST IS NOT NULL
    and cargo_no is null
    AND FORECAST_ID = cp_to_forecast_id
    AND OBJECT_CODE = p_storage_code
    AND REQ_DATE IN
    (
        SELECT REQ_DATE FROM (
            SELECT REQ_DATE, COUNT(*) NOM
            FROM (
                SELECT REQ_DATE,  COUNT(*)AS NOM
                FROM DV_FCST_STOR_LIFT_NOM
                WHERE FORECAST_ID = cp_to_forecast_id
                AND OBJECT_CODE = p_storage_code
                AND NVL(COMBINE_IND,'N') = 'Y'
                AND COMM_LIFTERS_LIST IS NOT NULL
                GROUP BY REQ_DATE
            ) A
            GROUP BY REQ_DATE
            HAVING COUNT(*) = 1
        ) B
    )
    AND VALIDATION_ISSUES LIKE '%COMMINGLED_RL%';

    CURSOR cur_LiftAccountPC(cp_liftaccountlist VARCHAR2) IS
    SELECT regexp_substr(cp_liftaccountlist,'[^,]+', 1, level) AS liftacc_pc FROM DUAL
    CONNECT BY regexp_substr(cp_liftaccountlist, '[^,]+', 1, level) IS NOT NULL;

    CURSOR cur_LiftAccountPC2(cp_liftaccountlist VARCHAR2) IS
    SELECT regexp_substr(cp_liftaccountlist,'[^,]+', 1, level) AS liftacc_pc FROM DUAL
    CONNECT BY regexp_substr(cp_liftaccountlist, '[^,]+', 1, level) IS NOT NULL;
BEGIN

    IF p_action = 'GENERATE_SEL_COMB_CARGO' THEN
        v_REQ_DATE := ec_STOR_FCST_LIFT_NOM.REQUESTED_DATE(p_parcel_no, p_forecast_id);
    ELSE
        v_REQ_DATE := NULL;
    END IF;
    IF v_record_status = 'P' THEN
        FOR CURR_NOM IN ALL_COMB_NOM_BY_FORECAST(p_forecast_id, v_REQ_DATE) LOOP
 --  ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','PROCESSING PARCEL='||CURR_NOM.PARCEL_NO);
 --  ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','p_storage_code='||p_storage_code);

            FOR c_cursor IN cur_LiftAccountPC(CURR_NOM.COMM_LIFTERS_LIST) LOOP
                v_liftaccount_profitcentre:=c_cursor.liftacc_pc;
                IF v_liftaccount_profitcentre IS NOT NULL THEN
                    v_liftaccount := substr(v_liftaccount_profitcentre,1,instr(v_liftaccount_profitcentre,'|')-1);
                    v_profit_centre := substr(v_liftaccount_profitcentre,instr(v_liftaccount_profitcentre,'|')+1,length(v_liftaccount_profitcentre));
                    v_liftingaccount_resolvedcode := UE_CT_MSG_LOADER.GetLiftAccCodeFromCompanyAndPC(p_storage_code,v_liftaccount,v_profit_centre);
                ELSE
                    v_liftingaccount_resolvedcode := NULL;
                END IF;
  --  ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_liftingaccount_resolvedcode='|| v_liftingaccount_resolvedcode);
  --  ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_profit_centre='|| v_profit_centre);
  --  ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','COALESCE(CURR_NOM.CARGO_NO,-1)='|| COALESCE(CURR_NOM.CARGO_NO,-1));
                    --SEARCH FOR OTHER COMB CARGO in the merged scenario
                    SELECT COUNT(*) INTO v_count
                    FROM DV_FCST_STOR_LIFT_NOM
                    WHERE NVL(COMBINE_IND,'N') = 'Y'
                    AND COMM_LIFTERS_LIST IS NOT NULL
                    AND FORECAST_ID = p_forecast_id
                    AND LIFTING_ACCOUNT_CODE = v_liftingaccount_resolvedcode
                    AND PROFIT_CENTRE_CODE = v_profit_centre
                    AND REQ_DATE = CURR_NOM.REQ_DATE
                    AND (CARGO_NO IS NULL) -- OR (COALESCE(CARGO_NO,-1) <> COALESCE(CURR_NOM.CARGO_NO,-1)))
                    --PNC MUST BE SAME
                    AND COALESCE(PURGE_COOL_IND,'WST') = COALESCE(CURR_NOM.PURGE_COOL_IND,'WST')
                    AND COALESCE(CARRIER_CODE,'WST') = COALESCE(CURR_NOM.CARRIER_CODE,'WST')
                    AND COALESCE(PURGE_COOL_DURATION,999) = COALESCE(CURR_NOM.PURGE_COOL_DURATION,999)
                    AND (NVL(PURGE_COOL_IND,'N') = 'N' OR (PURGE_COOL_IND = 'Y' AND PURGE_COOL_DURATION IS NOT NULL) )
                    --VESSEL MUST BE SAME;
                    AND COALESCE(CARRIER_CODE,'WST') = COALESCE(CURR_NOM.CARRIER_CODE,'WST');
 --   ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_count='|| v_count);

                    IF v_count > 0 THEN
                    /* 124170 - KOIJ - Allow multiple liftings, per lifter, per cargo*/
                        SELECT distinct  COMM_LIFTERS_LIST,CARGO_NO INTO v_COMM_LIFTERS_LIST, v_cargo_no
                        FROM DV_FCST_STOR_LIFT_NOM
                        WHERE NVL(COMBINE_IND,'N') = 'Y'
                        AND COMM_LIFTERS_LIST IS NOT NULL
                        AND FORECAST_ID = p_forecast_id
                        AND LIFTING_ACCOUNT_CODE = v_liftingaccount_resolvedcode
                        AND PROFIT_CENTRE_CODE = v_profit_centre
                        AND REQ_DATE = CURR_NOM.REQ_DATE
                        AND (CARGO_NO IS NULL) -- OR (COALESCE(CARGO_NO,-1) <> COALESCE(CURR_NOM.CARGO_NO,-1)))
                        --PNC MUST BE SAME
                        AND COALESCE(PURGE_COOL_IND,'WST') = COALESCE(CURR_NOM.PURGE_COOL_IND,'WST')
                        AND COALESCE(CARRIER_CODE,'WST') = COALESCE(CURR_NOM.CARRIER_CODE,'WST')
                        AND COALESCE(PURGE_COOL_DURATION,999) = COALESCE(CURR_NOM.PURGE_COOL_DURATION,999)
                        AND (NVL(PURGE_COOL_IND,'N') = 'N' OR (PURGE_COOL_IND = 'Y' AND PURGE_COOL_DURATION IS NOT NULL) )
                        --VESSEL MUST BE SAME;
                        AND COALESCE(CARRIER_CODE,'WST') = COALESCE(CURR_NOM.CARRIER_CODE,'WST');
                    END IF;
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_liftingaccount_resolvedcode='|| v_liftingaccount_resolvedcode ||',v_count='||v_count||',v_COMM_LIFTERS_LIST='||v_COMM_LIFTERS_LIST);
                    IF v_count > 0 THEN
                        v_valide := 'N';
                    --    ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','before first loop,v_valide=' || v_valide);
                        FOR c_cursor_original IN cur_LiftAccountPC2(v_COMM_LIFTERS_LIST) LOOP
                            v_liftaccount_profitcentre:=c_cursor_original.liftacc_pc;
                            IF v_liftaccount_profitcentre IS NOT NULL THEN
                                v_liftaccount := substr(v_liftaccount_profitcentre,1,instr(v_liftaccount_profitcentre,'|')-1);
                                v_profit_centre := substr(v_liftaccount_profitcentre,instr(v_liftaccount_profitcentre,'|')+1,length(v_liftaccount_profitcentre));
                                v_liftingaccount_resolvedcode := UE_CT_MSG_LOADER.GetLiftAccCodeFromCompanyAndPC(p_storage_code,v_liftaccount,v_profit_centre);
                            ELSE
                                v_liftingaccount_resolvedcode := NULL;
                            END IF;
                         --   ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_valide='||v_valide || ',RES_CODE='||v_liftingaccount_resolvedcode||'='||CURR_NOM.LIFTING_ACCOUNT_CODE);
                            IF (v_liftingaccount_resolvedcode = CURR_NOM.LIFTING_ACCOUNT_CODE OR v_valide = 'Y') THEN
                                v_valide := 'Y';
                                --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','entered IF fpr v_valide='||v_valide);
                                --allowing user to regen the Commingled Cargo No if it is still in "P"
                                --IF (COALESCE(CURR_NOM.CARGO_NO,-1) = COALESCE(v_cargo_no,-1) AND CURR_NOM.CARGO_NO IS NOT NULL) THEN
                                    --v_valide := 'SKIP'; --This COmb Cargo already resolved, so skip no need to process
                                --END IF;
                            ELSE
                                v_valide := 'N';
                                --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','entered ELSE for v_valide='||v_valide);
                            END IF;
                        END LOOP;
                        --after the loop and still couldnt find the commlinged lifters, this is an error that needs to be flag
                        IF v_valide = 'N' THEN
                            --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','Exiting for loop v_valide='||v_valide);
                            EXIT;
                        END IF;
                    ELSE
                        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_count is >0, v_count='||v_count);
                        v_valide := 'N';
                        EXIT;
                    END IF;
            END LOOP;
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTIONSKIP','v_liftingaccount_resolvedcode='|| v_liftingaccount_resolvedcode ||',v_valide='||v_valide || ', PARCEL='||CURR_NOM.PARCEL_NO);
            IF v_valide <> 'SKIP' THEN
                IF v_valide = 'Y' THEN
                    UPDATE STOR_FCST_LIFT_NOM SET LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_7 = TEXT_7 ||'UE_CARGO_ACTION'
                    WHERE PARCEL_NO = CURR_NOM.PARCEL_NO AND FORECAST_ID = CURR_NOM.FORECAST_ID;
                ELSE
                    --UPDATE STOR_FCST_LIFT_NOM SET LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_9 = 'N', DECODE(TEXT_7,NULL,'COMMINGLED_RL',TEXT_7||'COMMINGLED_RL')
                    --WHERE PARCEL_NO = CURR_NOM.PARCEL_NO AND FORECAST_ID = CURR_NOM.FORECAST_ID;
                    UPDATE STOR_FCST_LIFT_NOM SET LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_9 = 'N', TEXT_7 = 'COMMINGLED_RL' --TEXT_7 = DECODE(TEXT_7,NULL,'COMMINGLED_RL',TEXT_7||'COMMINGLED_RL')
                    WHERE REQUESTED_DATE = CURR_NOM.REQ_DATE AND FORECAST_ID = CURR_NOM.FORECAST_ID AND OBJECT_ID = CURR_NOM.OBJECT_ID;
                END IF;
            END IF;

           -- ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_liftingaccount_resolvedcode='|| v_liftingaccount_resolvedcode ||',v_valide='||v_valide || ', PARCEL='||CURR_NOM.PARCEL_NO);

        END LOOP;


        --UPDATE STOR_FCST_LIFT_NOM SET LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_9 = 'N', TEXT_7 = DECODE(TEXT_7,NULL,'COMMINGLED_RL',TEXT_7||'COMMINGLED_RL')
        --WHERE PARCEL_NO = CURR_NOM.PARCEL_NO AND FORECAST_ID = CURR_NOM.FORECAST_ID
        --AND REQUESTED_DATE = v_REQ_DATE;
        FOR RESOLVED_NOM IN RESOLVED_COMB_NOM_BY_FORECAST(p_forecast_id) LOOP

            --IF NVL(RESOLVED_NOM.NOM_VALID,'Y') = 'Y'  AND RESOLVED_NOM.VALIDATION_ISSUES = 'UE_CARGO_ACTION' THEN
                    --This cargo request exists in all Comb cargoes from other lifters
                    --update Comb cargoes to the same cargo no
                    EcDp_System_Key.assignNextNumber('CARGO_TRANSPORT', ln_assign_id);
                    -- get cargo name
                    ls_cargoName := EcBp_Cargo_Transport.getCargoName(ln_assign_id, RESOLVED_NOM.parcel_no);
                    INSERT INTO cargo_fcst_transport (CARGO_NO,FORECAST_ID,CARGO_STATUS, CARGO_NAME, created_by)
                    VALUES (ln_assign_id,RESOLVED_NOM.FORECAST_ID,'T',ls_cargoName,ecdp_context.getAppUser);
                    --TEXT_9 = NOM_VALID, TEXT_7 = VALIDATION_ISSUES, TEXT_12 = COMBINE_IND
                    UPDATE STOR_FCST_LIFT_NOM SET CARGO_NO = ln_assign_id, LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_7 = SUBSTR(TEXT_7,0,LENGTH(TEXT_7)-15)
                    WHERE TEXT_12 = 'Y' AND REQUESTED_DATE = RESOLVED_NOM.REQ_DATE AND FORECAST_ID = RESOLVED_NOM.FORECAST_ID AND OBJECT_ID = v_storage_id;
                    UE_CT_LIFTING_NUMBERS.SetLiftingNumber(RESOLVED_NOM.parcel_no, 'WST', RESOLVED_NOM.REQ_DATE, ec_stor_version.product_id(RESOLVED_NOM.OBJECT_ID, RESOLVED_NOM.REQ_DATE, '<='));
            --END IF;
        END LOOP;

         FOR CARGO_NOM_GEN IN ADDNL_NOM_TO_CARGO_BY_FORECAST(p_forecast_id) LOOP

            select distinct cargo_no into v_cargo_no from stor_fcst_lift_nom
            WHERE  TEXT_12='Y' and REQUESTED_DATE = CARGO_NOM_GEN .REQ_DATE AND FORECAST_ID = CARGO_NOM_GEN .FORECAST_ID AND OBJECT_ID = v_storage_id
             and cargo_no is not null;

            UPDATE STOR_FCST_LIFT_NOM SET CARGO_NO = v_cargo_no, LAST_UPDATED_BY = ecdp_context.getAppUser , TEXT_7 =  'COMMINGLED_RL'
            WHERE  TEXT_12='Y' and REQUESTED_DATE = CARGO_NOM_GEN.REQ_DATE AND FORECAST_ID = CARGO_NOM_GEN.FORECAST_ID AND OBJECT_ID = v_storage_id and cargo_no is null;

	    UE_CT_LIFTING_NUMBERS.SetLiftingNumber(CARGO_NOM_GEN.parcel_no, 'WST', CARGO_NOM_GEN.REQ_DATE, ec_stor_version.product_id(CARGO_NOM_GEN.OBJECT_ID, CARGO_NOM_GEN.REQ_DATE, '<='));

        END LOOP;
    END IF;
    EXCEPTION  -- exception handlers begin
       WHEN NO_DATA_FOUND THEN  -- handles 'NO_DATA_FOUND' error
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
       WHEN OTHERS THEN  -- handles all other errors
          ROLLBACK;
          ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','HOUSTON, WE GOT PROBLEM');
          RAISE;


END generateCombCargo;

PROCEDURE populateCombList(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_cargo_date_time DATE := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_id);
    v_COMM_LIFTERS_LIST VARCHAR2(240) ;
    v_records noms_type;
    v_count_la number :=0;


    CURSOR ALL_COMB(cp_to_forecast_id VARCHAR2) IS
    SELECT OBJECT_ID,OBJECT_CODE,CARGO_NO, NOM_DATE,REQ_DATE,
    PARCEL_NO, COMM_LIFTERS_LIST, LIFTING_ACCOUNT_ID,LIFTING_ACCOUNT_CODE, PROFIT_CENTRE_ID,PROFIT_CENTRE_CODE,FORECAST_ID,FORECAST_CODE
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE NVL(COMBINE_IND,'N') = 'Y'
    -- 124170 KOIJ Allow a previously commingled cargo to be assigned additional liftings during the SDS process    - populatecomblist()
  --  AND COMM_LIFTERS_LIST IS NULL
  -- 124170 KOIJ Allow a previously commingled cargo to be assigned additional liftings during the SDS process    - populatecomblist()
    AND FORECAST_ID = cp_to_forecast_id
    AND NOM_DATE_TIME = nvl(v_cargo_date_time, NOM_DATE_TIME)
    AND NVL(RECORD_STATUS,'P') = 'P'
    AND OBJECT_ID = nvl(v_storage_id, OBJECT_ID)
    ORDER BY PARCEL_NO;
	 /*124170 KOIJ --Allow multiple liftings, per lifter, per cargo added distinct */
    CURSOR OTH_COMB_LIST(cp_to_forecast_id VARCHAR2,cp_lifting_account_id VARCHAR2 ) IS
    SELECT  distinct O.CODE,N.PROFIT_CENTRE_CODE,
    o.code || '|' || N.PROFIT_CENTRE_CODE as COMB_LIST, lifting_account_id
    FROM OV_MESSAGE_CONTACT O, DV_FCST_STOR_LIFT_NOM N
    WHERE N.FORECAST_ID =  cp_to_forecast_id
    AND N.LIFTING_ACCOUNT_ID <> cp_lifting_account_id
    AND N.NOM_DATE_TIME = nvl(v_cargo_date_time, N.NOM_DATE_TIME)
    AND NVL(N.COMBINE_IND,'N') = 'Y'
    AND O.COMPANY_ID =  EC_LIFTING_ACCOUNT.COMPANY_ID(N.LIFTING_ACCOUNT_ID)
    AND O.CONTACT_GROUP_CODE = 'CG_'||O.COMPANY_CODE
    AND O.FUNCTIONAL_AREA_CODE = 'CARGO'
    AND O.CODE LIKE '%LIFT_SYST%'
     ;

    /*124170 KOIJ --Allow multiple liftings, per lifter, per cargo*/
      CURSOR OTH_COMB_LIST_SL(cp_to_forecast_id VARCHAR2,cp_lifting_account_id VARCHAR2 ) IS
    SELECT distinct O.CODE,N.PROFIT_CENTRE_CODE,
    o.code || '|' || N.PROFIT_CENTRE_CODE as COMB_LIST, lifting_account_id
    FROM OV_MESSAGE_CONTACT O, DV_FCST_STOR_LIFT_NOM N
    WHERE N.FORECAST_ID =  cp_to_forecast_id
    AND N.LIFTING_ACCOUNT_ID = cp_lifting_account_id
    AND N.NOM_DATE_TIME = nvl(v_cargo_date_time, N.NOM_DATE_TIME)
    AND NVL(N.COMBINE_IND,'N') = 'Y'
    AND O.COMPANY_ID =  EC_LIFTING_ACCOUNT.COMPANY_ID(N.LIFTING_ACCOUNT_ID)
    AND O.CONTACT_GROUP_CODE = 'CG_'||O.COMPANY_CODE
    AND O.FUNCTIONAL_AREA_CODE = 'CARGO'
    AND O.CODE LIKE '%LIFT_SYST%';

BEGIN
 ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','cp_to_forecast_id='|| p_forecast_id );
--LOOP THRU THE SELECTED COMB CARGO TO GET THE REQUESTED DATE AND LOOP THRU ALL OTHER COMB LIFTER TO FORM THE COMB LIFTER LIST
    FOR CUR_ALL_COMB IN ALL_COMB(p_forecast_id) LOOP
        v_COMM_LIFTERS_LIST := '';
       /* ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','p_forecast_id1='|| p_forecast_id );
        FOR CUR_OTH_COMB IN OTH_COMB_LIST(p_forecast_id,CUR_ALL_COMB.LIFTING_ACCOUNT_ID) LOOP
            v_COMM_LIFTERS_LIST := v_COMM_LIFTERS_LIST || CUR_OTH_COMB.COMB_LIST || ',';
             ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','v_COMM_LIFTERS_LIST='|| v_COMM_LIFTERS_LIST );
        END LOOP;*/
         /*124170 KOIJ --Allow multiple liftings, per lifter, per cargo*/
         select count(distinct lifting_account_id) into v_count_la
        from DV_FCST_STOR_LIFT_NOM N,OV_MESSAGE_CONTACT O
        where N.FORECAST_ID =  p_forecast_id
          AND N.NOM_DATE_TIME = nvl(v_cargo_date_time, N.NOM_DATE_TIME)
          AND NVL(N.COMBINE_IND,'N') = 'Y'
          AND O.COMPANY_ID =  EC_LIFTING_ACCOUNT.COMPANY_ID(N.LIFTING_ACCOUNT_ID)
          AND O.CONTACT_GROUP_CODE = 'CG_'||O.COMPANY_CODE
          AND O.FUNCTIONAL_AREA_CODE = 'CARGO'
          AND O.CODE LIKE '%LIFT_SYST%';
        if v_count_la =1 then

         FOR CUR_OTH_COMB_SL IN OTH_COMB_LIST_SL(p_forecast_id,CUR_ALL_COMB.LIFTING_ACCOUNT_ID) LOOP
                  v_COMM_LIFTERS_LIST :=  CUR_OTH_COMB_SL.COMB_LIST || ',';
                 -- ECDP_DYNSQL.WRITETEMPTEXT(' CUR_OTH_COMB_SL.COMB_LIST',' v_COMM_LIFTERS_LIST='|| v_COMM_LIFTERS_LIST);
         end loop;
        else
         FOR CUR_OTH_COMB IN OTH_COMB_LIST(p_forecast_id,CUR_ALL_COMB.LIFTING_ACCOUNT_ID) LOOP
                  v_COMM_LIFTERS_LIST := v_COMM_LIFTERS_LIST || CUR_OTH_COMB.COMB_LIST || ',';
               --  ECDP_DYNSQL.WRITETEMPTEXT(' CUR_OTH_COMB.COMB_LIST',' v_COMM_LIFTERS_LIST='|| v_COMM_LIFTERS_LIST);
         END LOOP;
        end if;
         /*124170 KOIJ --Allow multiple liftings, per lifter, per cargo*/

        IF v_COMM_LIFTERS_LIST IS NOT NULL THEN
                 SELECT SUBSTR(v_COMM_LIFTERS_LIST,0,LENGTH(v_COMM_LIFTERS_LIST)-1) INTO v_COMM_LIFTERS_LIST FROM DUAL;
            --UPDATE LIFTER LIST FOR THE CURRENT LIFTING ACCOUNT
            UPDATE DV_FCST_STOR_LIFT_NOM
            SET COMM_LIFTERS_LIST = v_COMM_LIFTERS_LIST
            WHERE FORECAST_ID = CUR_ALL_COMB.FORECAST_ID
            AND LIFTING_ACCOUNT_ID = CUR_ALL_COMB.LIFTING_ACCOUNT_ID
            AND PARCEL_NO = CUR_ALL_COMB.PARCEL_NO
            AND OBJECT_ID = CUR_ALL_COMB.OBJECT_ID;
        END IF;
    END LOOP;
END populateCombList;

PROCEDURE populateMUL(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    lv_REF_ENT NUMBER := 0;
    lv_MUL NUMBER := 0 ;
    lv_NOM_RUNNING_TOTAL NUMBER := 0 ;
    lv_COUNT NUMBER := 0 ;
    lv_tmp VARCHAR2(256);

    TYPE MUL_TABLE_ARRAY IS TABLE OF VARCHAR2(100);
    a_la MUL_TABLE_ARRAY := MUL_TABLE_ARRAY();
    a_mul MUL_TABLE_ARRAY := MUL_TABLE_ARRAY();
    a_pri MUL_TABLE_ARRAY := MUL_TABLE_ARRAY();
    a_re MUL_TABLE_ARRAY := MUL_TABLE_ARRAY();

    --MUL_TABLE_ARRAY;
    --MUL_TABLE MUL_TABLE_TYPE;

    CURSOR EACHNOM(cp_to_forecast_id VARCHAR2) IS
    SELECT NOM_DATE,PARCEL_NO
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE FORECAST_ID = cp_to_forecast_id
    --Item 112305: Begin
    AND LIFTING_ACCOUNT_CODE NOT LIKE 'LA_TBD%'
    --Item 112305: End
    ORDER BY NOM_DATE;

    CURSOR EACHLA IS
    SELECT DISTINCT(OBJECT_ID) FROM OV_LIFTING_ACCOUNT WHERE STORAGE_CODE = 'STW_LNG'
    --Item 112305: Begin
    AND CODE NOT LIKE 'LA_TBD%';
    --Item 112305: End

BEGIN
    --DELETE FROM T_TEMPTEXT WHERE ID = 'populateMUL';
    --COMMIT;
    --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','p_cargo_no='||p_cargo_no);
    --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','p_parcel_no='||p_parcel_no);
    --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','p_forecast_id='||p_forecast_id);

    SELECT DISTINCT(COUNT(*)) INTO lv_COUNT FROM OV_LIFTING_ACCOUNT WHERE STORAGE_CODE = 'STW_LNG'
    --Item 112305: Begin
    AND CODE NOT LIKE 'LA_TBD%';
    --Item 112305: End

    a_la.EXTEND(lv_COUNT);
    a_mul.EXTEND(lv_COUNT);
    a_pri.EXTEND(lv_COUNT);
    a_re.EXTEND(lv_COUNT);

--LOOP THRU EACH NOM DATE AND START CALCULATING THE RUNNING SUM FOR EACH LIFTER AS OF THAT NOMINATION
    FOR EACH_NOMINATION IN EACHNOM(p_forecast_id) LOOP
        --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','EACH_NOMINATION='||TO_CHAR(EACH_NOMINATION.NOM_DATE,'YYYYMMDD'));
        lv_COUNT := 0;
        FOR EACH_LA IN EACHLA LOOP
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','EACH_LA='||EACH_LA.OBJECT_ID || ', CODE=' || ECDP_OBJECTS.GETOBJCODE(EACH_LA.OBJECT_ID));
            lv_REF_ENT := 0;
            lv_NOM_RUNNING_TOTAL := 0;
            lv_COUNT := lv_COUNT + 1;
            --GET THE RUNNING TOTAL FROM REF_ENT DAILY SUM
            SELECT SUM(REF_ENT_VOL) INTO lv_REF_ENT
            FROM DV_CT_LA_DAY_PC_REF_ENT
            WHERE DAYTIME BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(EACH_NOMINATION.NOM_DATE,-3),'YEAR'),3) AND  EACH_NOMINATION.NOM_DATE
            AND OBJECT_ID = EACH_LA.OBJECT_ID;

            SELECT SUM(NOM_GRS_VOL) INTO lv_NOM_RUNNING_TOTAL
            FROM DV_FCST_STOR_LIFT_NOM
            WHERE FORECAST_ID = p_forecast_id
            AND LIFTING_ACCOUNT_ID = EACH_LA.OBJECT_ID
            AND NOM_DATE < EACH_NOMINATION.NOM_DATE;

            IF lv_NOM_RUNNING_TOTAL IS NULL THEN
                lv_NOM_RUNNING_TOTAL := 0;
            END IF;


            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','lv_REF_ENT='||lv_REF_ENT);
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','lv_NOM_RUNNING_TOTAL='||lv_NOM_RUNNING_TOTAL);

            --AT THIS POINT, WE SHOULD HAVE RUNNING_NOM_QTY PER LIFTER PER NOM_DATE
            --THEN CALCULATE MUL FOR EACH LIFTER
            --MUL = (REF-NOM)/REF
            IF (NVL(lv_REF_ENT,0) = 0 ) THEN
                lv_MUL := -999;
            ELSE
                lv_MUL := (lv_REF_ENT-lv_NOM_RUNNING_TOTAL )/lv_REF_ENT;
            END IF;
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','lv_MUL='||lv_MUL);

            a_la(lv_COUNT):= EACH_LA.OBJECT_ID;
            a_mul(lv_COUNT):= lv_MUL;
            a_pri(lv_COUNT):= 99;
            a_re(lv_COUNT) := lv_REF_ENT;
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','a_la_COUNT='||a_la.COUNT());
        END LOOP;
        --FOR J IN 1..a_la.COUNT() LOOP
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','BFORE SORTING MUL='|| ECDP_OBJECTS.GETOBJCODE(a_la(J)) || ':' || a_mul(J) );
        --END LOOP;
        --RESOLVE DAILY MUL
        FOR I IN 2..a_la.COUNT() LOOP
            FOR J IN 1..a_la.COUNT()-1 LOOP
                IF TO_NUMBER(a_mul(J)) < TO_NUMBER(a_mul(J+1)) THEN
                    lv_tmp := a_mul(J);
                    a_mul(J) := a_mul(J+1) ;
                    a_mul(J+1) := lv_tmp;

                    lv_tmp := a_la(J);
                    a_la(J) := a_la(J+1) ;
                    a_la(J+1) := lv_tmp;

                    lv_tmp := a_pri(J);
                    a_pri(J) := a_pri(J+1) ;
                    a_pri(J+1) := lv_tmp;

                    lv_tmp := a_re(J);
                    a_re(J) := a_re(J+1) ;
                    a_re(J+1) := lv_tmp;

                END IF;
            END LOOP;
        END LOOP;
        --FOR J IN 1..a_la.COUNT() LOOP
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','AFTER 1ST SORTING MUL='|| ECDP_OBJECTS.GETOBJCODE(a_la(J)) || ':' || a_mul(J) );
        --END LOOP;
        --RESOLVE DAILY MUL if it hits the tie, compare RE
        FOR I IN 2..a_la.COUNT() LOOP
            FOR J IN 1..a_la.COUNT()-1 LOOP
                IF (TO_NUMBER(a_mul(J)) = TO_NUMBER(a_mul(J+1))) AND (TO_NUMBER(a_re(J)) < TO_NUMBER(a_re(J+1))) THEN
                    lv_tmp := a_mul(J);
                    a_mul(J) := a_mul(J+1) ;
                    a_mul(J+1) := lv_tmp;

                    lv_tmp := a_la(J);
                    a_la(J) := a_la(J+1) ;
                    a_la(J+1) := lv_tmp;

                    lv_tmp := a_pri(J);
                    a_pri(J) := a_pri(J+1) ;
                    a_pri(J+1) := lv_tmp;

                    lv_tmp := a_re(J);
                    a_re(J) := a_re(J+1) ;
                    a_re(J+1) := lv_tmp;

                END IF;
            END LOOP;
        END LOOP;
        --CONSTRUCT MUL STRING AS "LIFTERS;PRIORITY,"
        lv_tmp := NULL;
        FOR J IN 1..a_la.COUNT() LOOP
            IF lv_tmp IS NULL THEN
                --lv_tmp := ECDP_OBJECTS.GETOBJCODE(a_la(J)) || ':' || J ;
                lv_tmp := ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(a_la(J))) || ':' || J ;
            ELSE
                lv_tmp := lv_tmp || ',' || ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(a_la(J))) || ':' || J ;
            END IF;
        END LOOP;
        --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','MUL='||TO_CHAR(SYSDATE,'YYYY-MM-DD')|| ':' ||lv_tmp);
        --FOR J IN 1..a_la.COUNT() LOOP
            --ECDP_DYNSQL.WRITETEMPTEXT('populateMUL','MUL='|| ECDP_OBJECTS.GETOBJCODE(a_la(J)) || ':' || a_mul(J) || ':RE=' ||a_re(J) );
        --END LOOP;

        UPDATE DV_FCST_STOR_LIFT_NOM_SCHED
        SET MOST_UNDERLIFTED_LIFTER = TO_CHAR(SYSDATE,'YYYY-MM-DD')|| ':' ||lv_tmp
        WHERE FORECAST_ID = p_forecast_id
        AND OBJECT_ID = v_storage_id
        AND PARCEL_NO = EACH_NOMINATION.PARCEL_NO;

        FOR J IN 1..a_la.COUNT() LOOP
            a_la.DELETE(J);
            a_mul.DELETE(J);
            a_pri.DELETE(J);
            a_re.DELETE(J);
        END LOOP;
    END LOOP;


END populateMUL;

--
--
--
--
--
PROCEDURE populateExcessCargo(
    p_cargo_no      NUMBER,
    p_parcel_no     NUMBER,
    p_forecast_id  VARCHAR2)
IS
    v_storage_id VARCHAR2(32) := EC_STOR_FCST_LIFT_NOM.OBJECT_ID(p_parcel_no, p_forecast_id);
    v_EXCESS_APP_IND VARCHAR2(32) := NVL(EC_STOR_FCST_LIFT_NOM.TEXT_20(p_parcel_no, p_forecast_id),'N');
    v_carrier_id VARCHAR2(32) := NVL(EC_STOR_FCST_LIFT_NOM.CARRIER_ID(p_parcel_no, p_forecast_id),'N');
    v_cargo_no NUMBER(32) := EC_STOR_FCST_LIFT_NOM.CARGO_NO(p_parcel_no, p_forecast_id);
    v_NOM_DATE DATE := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_id);
    v_SCENARIO_TYPE VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_6(p_forecast_id,v_NOM_DATE,'<=');
    v_SCEN_APPROVAL_STATUS VARCHAR2(32) := EC_FORECAST_VERSION.TEXT_5(p_forecast_id,v_NOM_DATE,'<=');
    v_count NUMBER := 0;
    v_upd_count NUMBER := -1;


    CURSOR SDS_SCENARIOS IS
        SELECT A.*
        FROM OV_FORECAST_TRAN_CP A WHERE A.SCENARIO_TYPE = 'SDS' AND v_NOM_DATE BETWEEN A.OBJECT_START_DATE AND (A.OBJECT_END_DATE-1)
        AND A.SCEN_APPROVAL_STATUS = 'P';

BEGIN
--COPY FROM an approved PLP TO ALL SDS IS STILL IN P STATUS
-- IF CARGO ALREADY EXISTS, DO NOT COPY
    IF v_SCEN_APPROVAL_STATUS = 'A' AND v_SCENARIO_TYPE = 'PLP' AND v_EXCESS_APP_IND = 'Y' THEN
        --ITERATE THRU ALL SDS SCENARIO AND INSERT IF THERE IS NO SUCH CARGO AVAILABLE
        v_count := 0 ;
        FOR SDS IN SDS_SCENARIOS LOOP
            SELECT COUNT(*) INTO v_count
            FROM DV_FCST_STOR_LIFT_NOM
            WHERE FORECAST_ID = SDS.OBJECT_ID
            AND OBJECT_ID = v_storage_id
            --AND PARCEL_NO = p_parcel_no
            AND CARGO_NO = v_cargo_no;

            IF v_count = 0 THEN
                SELECT COUNT(*) INTO v_count
                FROM cargo_fcst_transport
                WHERE FORECAST_ID = SDS.OBJECT_ID
                AND CARGO_NO = v_cargo_no;
                IF v_count = 0 THEN
                    INSERT INTO cargo_fcst_transport (CARGO_NO,FORECAST_ID,CARGO_STATUS, CARGO_NAME, created_by)
                    VALUES (v_cargo_no,SDS.OBJECT_ID,EC_CARGO_FCST_TRANSPORT.CARGO_STATUS(v_cargo_no,p_forecast_id),EC_CARGO_FCST_TRANSPORT.CARGO_NAME(v_cargo_no,p_forecast_id),ecdp_context.getAppUser);
                END IF;
                --UE_CARGO_FCST_TRANSPORT.Copyfwdnominatedcarrier('UPDATE',SDS.OBJECT_ID,v_cargo_no,v_carrier_id,NULL,ecdp_context.getAppUser);


                INSERT INTO DV_FCST_STOR_LIFT_NOM(
                    CLASS_NAME, OBJECT_ID, OBJECT_CODE, EXCLUDE_FROM_CALC, NOM_VALID, SOFT_VALIDATION, STORAGE_NAME, NUM_SEQ, CARGO_NO, CARGO_NO_S, CARGO_NAME, REFERENCE_LIFTING_NO, COMBINE_IND, COMM_LIFTERS_LIST,
EXCESS_LIFTING_IND, EXCESS_LIFTING_APP_IND, LIFTER_CARGO_NAME, RESOLVED_CARGO_NO, REQ_DATE_RANGE, REQ_DATE, REQ_GRS_VOL, REQ_TOLERANCE_TYPE, CONTAINMENT_TYPE, EST_ROUND_TRIP_TIME, SCHED_ROUD_TRIP_TIME,
PURGE_COOL_IND, PURGE_COOL_QTY, PURGE_COOL_DURATION, ETA, LDR_START, ETA_CALC, NOM_DATE, NOM_DATE_TIME, LDR_FINISH, NOM_DATE_CALC, ETD, ETD_CALC, NOM_DATE_RANGE, NOM_GRS_VOL, PARCEL_NO, COPIED_FLAG,
VIRTUAL_CARGO_STATUS, VALIDATION_ISSUES, DAYTIME, DELETED_IND, EST_NOM_DATE, FIXED_IND, UD_LIFTED_LA_ID, UN_LIFTED_LA_CODE, LIFTER_PRIORITY, SPEC_REQ_DATE, MOST_UNDERLIFTED_LIFTER, LIFTING_ACCOUNT_ID, LIFTING_ACCOUNT_CODE,
PROFIT_CENTRE_ID, PROFIT_CENTRE_CODE, FORECAST_ID, FORECAST_CODE, CARRIER_ID, CARRIER_CODE, CONTRACT_ID, CONTRACT_CODE, RECORD_STATUS
                    )
                     (SELECT
                     CLASS_NAME, OBJECT_ID, OBJECT_CODE, EXCLUDE_FROM_CALC, NOM_VALID, SOFT_VALIDATION, STORAGE_NAME, NUM_SEQ, CARGO_NO, CARGO_NO_S, CARGO_NAME, REFERENCE_LIFTING_NO, COMBINE_IND, COMM_LIFTERS_LIST,
EXCESS_LIFTING_IND, EXCESS_LIFTING_APP_IND, LIFTER_CARGO_NAME, RESOLVED_CARGO_NO, REQ_DATE_RANGE, REQ_DATE, REQ_GRS_VOL, REQ_TOLERANCE_TYPE, CONTAINMENT_TYPE, EST_ROUND_TRIP_TIME, SCHED_ROUD_TRIP_TIME,
PURGE_COOL_IND, PURGE_COOL_QTY, PURGE_COOL_DURATION, ETA, LDR_START, ETA_CALC, NOM_DATE, NOM_DATE_TIME, LDR_FINISH, NOM_DATE_CALC, ETD, ETD_CALC, NOM_DATE_RANGE, NOM_GRS_VOL, PARCEL_NO, COPIED_FLAG,
VIRTUAL_CARGO_STATUS, VALIDATION_ISSUES, DAYTIME, DELETED_IND, EST_NOM_DATE, FIXED_IND, UD_LIFTED_LA_ID, UN_LIFTED_LA_CODE, LIFTER_PRIORITY, SPEC_REQ_DATE, MOST_UNDERLIFTED_LIFTER, LIFTING_ACCOUNT_ID, LIFTING_ACCOUNT_CODE,
PROFIT_CENTRE_ID, PROFIT_CENTRE_CODE, SDS.OBJECT_ID, SDS.CODE, CARRIER_ID, CARRIER_CODE, CONTRACT_ID, CONTRACT_CODE, 'P'
                     FROM DV_FCST_STOR_LIFT_NOM
                    WHERE OBJECT_ID = v_storage_id
                    AND FORECAST_ID = p_forecast_id --plp forecast
                    --AND PARCEL_NO = p_parcel_no
                    AND CARGO_NO = v_cargo_no
                    );

                v_upd_count := 1;
                --UPDATE DV_FCST_STOR_LIFT_NOM SET CARGO_NO = v_cargo_no ,LAST_UPDATED_BY = ecdp_context.getAppUser
                --WHERE PARCEL_NO = p_parcel_no AND  FORECAST_ID = SDS.OBJECT_ID;
            ELSE
                IF v_upd_count <> 1 THEN
                    v_upd_count := 0;
                END IF;
                ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION:popExcCargo',SDS.CODE || ' WITH CARGO NO = ' || v_cargo_no || ' ALREADY EXISTS IN SDS');
            END IF;

        END LOOP;
        IF v_upd_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20785, 'Record already exists in SDS');
        END IF;
        IF v_upd_count = -1 THEN
            RAISE_APPLICATION_ERROR(-20786, 'No relevant SDS found');
        END IF;

    ELSE
        --Lino wants to alert user if no record was updated
        RAISE_APPLICATION_ERROR(-20784, 'No record has been updated');

    END IF;
/*
    EXCEPTION  -- exception handlers begin
        WHEN NO_DATA_FOUND THEN  -- handles 'NO_DATA_FOUND' error
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
        WHEN OTHERS THEN  -- handles all other errors
            ROLLBACK;
            ECDP_DYNSQL.WRITETEMPTEXT('UE_CARGO_ACTION','HOUSTON, WE GOT PROBLEM');
            RAISE;
*/
END populateExcessCargo;

PROCEDURE execute(
  p_action        VARCHAR2,
  p_cargo_no      NUMBER default -1,
  p_parcel_no     NUMBER default -1,
  p_parameter     VARCHAR2 default ''
)
as pragma autonomous_transaction;
    v_action VARCHAR2(32);
    v_cargo_no NUMBER;
    v_parcel_no NUMBER;
    v_parameter VARCHAR2(32);
BEGIN
  --execute an action

    v_action := p_action;

    IF p_cargo_no != -1 THEN
        v_cargo_no := p_cargo_no;
    END IF;

    IF p_parcel_no != -1 THEN
        v_parcel_no := p_parcel_no;
    END IF;

    v_parameter := p_parameter;

  --ecdp_dynsql.WriteTempText('ue_cargo_action','p_action [' || p_action || '] p_cargo_no [' || p_cargo_no || '] p_parcel_no [' || p_parcel_no || '] p_parameter [' || p_parameter || ']');

  --tlxt: 23-sep-2014: DEcision made not to use anything related to re-scheduling/optimisation as below:
  --FCST_IDEALIZE_CARGO, FCST_INSERT_CARGO, FCST_DELETE_CARGO
  IF p_action = 'FCST_ADJUST_PLUS_1' THEN
      adjustPlanAroundCargo(v_cargo_no, v_parcel_no, v_parameter, 1);
  ELSIF p_action = 'FCST_ADJUST_MINUS_1' THEN
      adjustPlanAroundCargo(v_cargo_no, v_parcel_no, v_parameter, -1);
  --ELSIF p_action = 'FCST_IDEALIZE_CARGO' THEN
      --adjustPlanIdealizeCargo(v_cargo_no, v_parcel_no, v_parameter);
  --ELSIF p_action = 'FCST_DELETE_CARGO' THEN
      --deleteCargo(v_cargo_no, v_parcel_no, v_parameter);
  --ELSIF p_action = 'FCST_INSERT_CARGO' THEN
      --insertCargo(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'FCST_INSERT_NEW_CARGO' THEN
      insertNewCargo(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'FCST_GENERATE_CARGO' THEN
      generateCargo(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'GENERATE_CARGO' THEN
      generateOfficialCargo(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'GENERATE_COMB_CARGO' THEN
      generateCombCargo(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'GENERATE_SEL_COMB_CARGO' THEN
      --Work_Item:92642
      generateCombCargo(v_cargo_no, v_parcel_no, v_parameter,p_action);
  ELSIF p_action = 'POPULATE_COMB_LIST' THEN
      --Work_Item:92642
      populateCombList(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'POPULATE_MUL' THEN
      --Work_Item:94635
      populateMUL(v_cargo_no, v_parcel_no, v_parameter);
  ELSIF p_action = 'POPULATE_EX_CARGO' THEN
      --Work_Item:110507
      populateExcessCargo(v_cargo_no, v_parcel_no, v_parameter);
  END IF;

  COMMIT;

END execute;
END ue_cargo_action;
/
