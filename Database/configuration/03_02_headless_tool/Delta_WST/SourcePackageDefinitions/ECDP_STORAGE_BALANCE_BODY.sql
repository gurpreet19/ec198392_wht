CREATE OR REPLACE PACKAGE BODY EcDp_Storage_Balance IS
    /****************************************************************
    ** Package        :  EcDp_Storage_Balance; body part
    **
    ** $Revision: 1.50 $
    **
    ** Purpose        :
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created        :  05.09.2006 Kari Sandvik
    **
    ** Modification history:
    **
    ** Date        Whom     Change description:
    ** ----------  -------- -------------------------------------------
    ** 06.10.2006  chongjer Tracker 4490 - Updated calcStorageLevel and calcStorageLevelUnload to use STOR_PERIOD_EXPORT_STATUS table
    ** 31.12.2008  oonnnng  ECPD-10641: Modify getStorageDip() function,
                            - Remove the raise application error when lv_group = 'E' and add support for UOM Group = 'E'.
    ** 24.08.2009  leongsei ECPD-12104: Modified function CalcStorageLevel
    ** 20.05.2010  kallesve ECPD-14855: Modified function CalcStorageLevel to utilise precalc'ed global variables
    ** 28.12.2010  sharawan ECPD-16547: Modified calcStorageLevel() function to handle the plan parameter correctly.
    ** 07.01.2011  amirrasn ECPD-16595: Modified calcStorageLevel() function for handling when nomination date later than the bill of lading date.
	** 26.08.2011  meisihil ECPD-16348: Modified getAccEstLiftedQtyMth/Day/SubDay to exclude cargos with nominated date earlier than current date, and no BL date
	** 14.11.2011  leeeewei	ECPD-18710: Fixed typo in calcStorageLevel
	** 17.11.2011  leeeewei	ECPD-18640: Added out_of_service = Y as input parameter to function calls in getStorageDip
	** 19.06.2012  kumarsur	ECPD-20272: In calcStorageLevel removed liq_dip_level.
	** 26.09.2012  meisihil ECPD-20961: Modified calcStorageLevel and calcStorageLevelSubDay to read allocated balance tables
    ** 12.09.2011  meisihil ECPD-20962: Included balance delta in calcStorageLevel and calcStorageLevelSubDay
    ** 21.12.2011  meisihil ECPD-21960: Cancelled cargos are included in Lifting Account closing balance
    ** 24.01.2013  meisihil ECPD-20056: Updated functions getAccEstLiftedQtyMth, getAccEstLiftedQtyDay, getAccEstLiftedQtySubDay, calcStorageLevel, calcStorageLevelSubDay
    **                                  to support liftings spread over hours
	** 26.05.2014  meisihil ECPD-26324: Updated calcStorageLevel and calcStorageLevelSubDay to take sub daily tank measurements into account
    ** 26.05.2015  sharawan ECPD-19047: Added parameter p_ignore_cache to calcStorageLevel and calcStorageLevelSubDay
	** 03.02.2016  thotesan ECPD-33013: Modified function getAccEstLiftedQtySubDay to get correct closing balance as it should bring cargo volume as split quantity, instead of the hourly cargo volume
	** 20.12.2016  royyypur ECPD-34933: Day End Not Lifted vs. Closing Balance(merged changes from ECPD-31819)
	** 22.03.2017  asareswi ECPD-40299: Modified calcStorageLevel function to call user exit pkg when GRS_VOL_METHOD is USER_EXIT.
	** 14.06.2017  thotesan ECPD-46235: Modified getAccLiftedQtyMth for calculating correct value for Lifted Qty 3.
	** 18.07.2017  baratmah ECPD-45870: Modified getAccEstLiftedQtyMth, getAccEstLiftedQtyDay, getAccEstLiftedQtySubDay, getEstLiftedQtyMth, getEstLiftedQtyDay, calcStorageLevel, calcStorageLevelSubDay to Fix filtering on cargo status.
	** 16.08.2017  thotesan ECPD-39313: Modified calcStorageLevel for performance improvement.
	** 19.09.2017  sharawan ECPD-48695: Modified calcStorageLevel to take the remaining not lifted qty into consideration when calculating closing balance.
	** 31.05.2018  sharawan ECPD-56221: Revert changes done on day end not lifted from calcStorageLevel function.
	******************************************************************/

    /**private global session variables **/
	gv_prev_object_id storage.object_id%type;
	gv_prev_object_id2 storage.object_id%type;
	gv_prev_object_id3 storage.object_id%type;
	gv_prev_object_id_a storage.object_id%type;
	gv_prev_object_id_b storage.object_id%type;
	gv_prev_object_id_c storage.object_id%type;
    gv_prev_date   DATE;
    gv_prev_date2  DATE;
    gv_prev_date3  DATE;
    gv_prev_date_a DATE;
    gv_prev_date_b DATE;
    gv_prev_date_c DATE;
    gv_prev_qty    NUMBER;
    gv_prev_qty2   NUMBER;
    gv_prev_qty3   NUMBER;
    gv_prev_qty_a  NUMBER;
    gv_prev_qty_b  NUMBER;
    gv_prev_qty_c  NUMBER;

    /**private function **/
    FUNCTION getStorageDip(p_storage_id VARCHAR2, p_daytime DATE, p_condition VARCHAR2, p_group VARCHAR2, p_type VARCHAR) RETURN NUMBER IS

        lv_condition VARCHAR2(32);
        lv_group     VARCHAR2(32);
        ln_dip       NUMBER;

    BEGIN
        lv_condition := p_condition;
        lv_group     := p_group;

        IF lv_condition IS NULL THEN
            lv_condition := 'GRS';
        END IF;

        IF lv_group IS NULL THEN
            lv_group := 'V';
        END IF;

        IF p_type = 'OPENING' THEN
            IF lv_condition = 'GRS' AND lv_group = 'V' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayGrsOpeningVol(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'GRS' AND lv_group = 'M' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayGrsOpeningMass(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'NET' AND lv_group = 'V' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayOpeningNetVol(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'NET' AND lv_group = 'M' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayOpeningNetMass(p_storage_id, p_daytime, 'Y');
            ELSIF lv_group = 'E' THEN
                ln_dip := EcBp_Storage_measurement.getStorageDayOpeningEnergy(p_storage_id, p_daytime);
            END IF;
        ELSE
            IF lv_condition = 'GRS' AND lv_group = 'V' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayGrsClosingVol(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'GRS' AND lv_group = 'M' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayGrsClosingMass(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'NET' AND lv_group = 'V' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayClosingNetVol(p_storage_id, p_daytime, 'Y');
            ELSIF lv_condition = 'NET' AND lv_group = 'M' THEN
                ln_dip := ecbp_storage_measurement.getStorageDayClosingNetMass(p_storage_id, p_daytime, 'Y');
            ELSIF lv_group = 'E' THEN
                ln_dip := EcBp_Storage_measurement.getStorageDayClosingEnergy(p_storage_id, p_daytime);
            END IF;
        END IF;

        ln_dip := ue_Storage_Balance.getStorageDip(p_storage_id, p_daytime, lv_condition, lv_group, p_type, ln_dip);

        RETURN ln_dip;
    END;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccLiftedQtyMth
    -- Description    : Returns the total lifted quantity for the month for selected lifting account
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting
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
    FUNCTION getAccLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, p_from_date DATE, p_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty), s.load_value)) lifted_qty
            FROM   storage_lift_nomination n, product_meas_setup p, storage_lifting s, storage_lift_nom_split ns
            WHERE  nvl(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
            AND    n.bl_date >= p_from_date
            AND    n.bl_date < p_to_date
            AND    n.parcel_no = s.parcel_no
            AND    ns.parcel_no (+) = n.parcel_no
            AND    s.product_meas_no = p.product_meas_no
            AND    p.lifting_event = 'LOAD'
            AND    ((p.nom_unit_ind = 'Y' and 0 = cp_xtra_qty) or (p.nom_unit_ind2 = 'Y' and 1 = cp_xtra_qty) or (p.nom_unit_ind3 = 'Y' and 2 = cp_xtra_qty));

        ld_from_date  DATE;
        ld_to_date    DATE;
        ln_lifted_qty NUMBER;

    BEGIN
        ld_from_date := TRUNC(p_daytime);
        ld_to_date   := ADD_MONTHS(ld_from_date, 1);

        FOR curLifted IN c_lifting(p_lifting_account_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
            ln_lifted_qty := curLifted.lifted_qty;
        END LOOP;

        RETURN ln_lifted_qty;

    END getAccLiftedQtyMth;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedQtyMth
    -- Description    : Returns the total lifted quantity for the month for selected lifting account
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting, cargo_status_mapping
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
    FUNCTION getAccEstLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (--Find all cargos nomintated in the future
					SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
					--Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty) split_lifted_qty,
                           ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty) lifted_qty,
                           ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.nom_firm_date <= cp_sysdate
                    UNION ALL
					--Find all cargos without cargo transport record, in the future
					SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.cargo_no is null
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.nom_firm_date > cp_sysdate) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    UNION ALL
					--Find all cargos without cargo transport record
                    SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.cargo_no is null
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date) a;

        CURSOR c_lifting_actual_sub_day(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (--Find all cargos nomintated in the future
					SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_from_date
                    AND    sn.production_day < cp_to_date
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
					--Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                     FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,(SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom WHERE lifted_qty IS NOT NULL) sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_from_date
                    AND    sn.production_day < cp_to_date
                    AND    n.nom_firm_date <= cp_sysdate
                    UNION ALL
					--Find all cargos without cargo transport record, in the future
					SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns,stor_subday_nom_sum sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.cargo_no is null
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_from_date
                    AND    sn.production_day < cp_to_date
                    AND    n.nom_firm_date > cp_sysdate
                    ) a;

        CURSOR c_lifting_sub_day(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    sn.production_day >= cp_from_date
                    AND    sn.production_day < cp_to_date
                    UNION ALL
					--Find all cargos without cargo transport record
                    SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns,stor_subday_nom_sum sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    n.cargo_no is null
                    AND    sn.production_day >= cp_from_date
                    AND    sn.production_day < cp_to_date) a;

        ld_from_date  DATE;
        ld_to_date    DATE;
        ln_lifted_qty NUMBER;
        ln_split_lifted_qty NUMBER;
        ln_balance_delta_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);
        lv_read_sub_day VARCHAR2(1);

    BEGIN
        ld_from_date := TRUNC(p_daytime);
        ld_to_date   := ADD_MONTHS(ld_from_date, 1);

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
        lv_read_sub_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sub_day');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
	        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	            FOR curLifted IN c_lifting_actual_sub_day(p_lifting_account_id, ld_from_date, ld_to_date, TRUNC(Ecdp_Timestamp.getCurrentSysdate), p_xtra_qty) LOOP
	                ln_lifted_qty := curLifted.lifted_qty;
	                ln_split_lifted_qty := curLifted.split_lifted_qty;
	                IF ln_lifted_qty IS NOT NULL AND ln_lifted_qty>0 THEN
		                ln_balance_delta_qty := curLifted.balance_delta_qty;
		            END IF;
	            END LOOP;
	        ELSE
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, ld_from_date, ld_to_date, TRUNC(Ecdp_Timestamp.getCurrentSysdate), p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
            END LOOP;
	        END IF;
        ELSE
	        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	            FOR curLifted IN c_lifting_sub_day(p_lifting_account_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
	                ln_lifted_qty := curLifted.lifted_qty;
	                ln_split_lifted_qty := curLifted.split_lifted_qty;
	                IF ln_lifted_qty IS NOT NULL AND ln_lifted_qty>0 THEN
		                ln_balance_delta_qty := curLifted.balance_delta_qty;
		            END IF;
	            END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
            END LOOP;
        END IF;
        END IF;

        IF p_incl_delta = 'Y' THEN
        	IF ln_split_lifted_qty IS NOT NULL THEN
        		ln_balance_delta_qty := ln_balance_delta_qty * ln_split_lifted_qty / ln_lifted_qty;
        		ln_lifted_qty := ln_split_lifted_qty;
        	END IF;
        	IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_lifting_account_id), p_daytime, '<=') = 'IMPORT') THEN
        		ln_lifted_qty := ln_lifted_qty - NVL(ln_balance_delta_qty, 0);
        	ELSE
        		ln_lifted_qty := ln_lifted_qty + NVL(ln_balance_delta_qty, 0);
        	END IF;
        ELSIF ln_split_lifted_qty IS NOT NULL THEN
        	ln_lifted_qty := ln_split_lifted_qty;
        END IF;

        RETURN ln_lifted_qty;

    END getAccEstLiftedQtyMth;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedQtyDay
    -- Description    : Returns the total lifted quantity for the month for selected lifting account
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting, cargo_status_mapping
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
    FUNCTION getAccEstLiftedQtyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (--Find all cargos nomintated in the future
					SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
					--Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty) split_lifted_qty,
                           ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty) lifted_qty,
                           ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.bl_date = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date <= cp_sysdate
                    UNION ALL
					--Find all cargos without cargo transport record, in the future
                    SELECT ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty) split_lifted_qty,
                           decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3) lifted_qty,
                           decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.nom_firm_date = cp_daytime
					AND    n.nom_firm_date > cp_sysdate
                    AND    n.cargo_no is null) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted_qty,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    UNION ALL
					--Find all cargos without cargo transport record
                    SELECT ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty) split_lifted_qty,
                           decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3) lifted_qty,
                           decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.nom_firm_date = cp_daytime
                    AND    n.cargo_no is null);

        CURSOR c_lifting_actual_sub_day(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (--Find all cargos nomintated in the future
					SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
					--Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,(SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom WHERE lifted_qty IS NOT NULL) sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date <= cp_sysdate
                    UNION ALL
					--Find all cargos without cargo transport record, in the future
					SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns,stor_subday_nom_sum sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day = cp_daytime
                    AND    n.cargo_no is null
					AND    n.nom_firm_date > cp_sysdate) a;

        CURSOR c_lifting_sub_day(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    UNION ALL
					--Find all cargos without cargo transport record
                    SELECT ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day, cp_xtra_qty) split_lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted_qty,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns,stor_subday_nom_sum sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day = cp_daytime
                    AND    n.cargo_no is null);

        ln_lifted_qty NUMBER;
        ln_split_lifted_qty NUMBER;
        ln_balance_delta_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);
        lv_read_sub_day VARCHAR2(1);

    BEGIN
        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
        lv_read_sub_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sub_day');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
	        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	            FOR curLifted IN c_lifting_actual_sub_day(p_lifting_account_id, p_daytime, TRUNC(Ecdp_Timestamp.getCurrentSysdate), p_xtra_qty) LOOP
	                ln_lifted_qty := curLifted.lifted_qty;
	                ln_split_lifted_qty := curLifted.split_lifted_qty;
		                ln_balance_delta_qty := curLifted.balance_delta_qty;
	            END LOOP;
	        ELSE
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_daytime, TRUNC(Ecdp_Timestamp.getCurrentSysdate), p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
            END LOOP;
	        END IF;
        ELSE
	        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	            FOR curLifted IN c_lifting_sub_day(p_lifting_account_id, p_daytime, p_xtra_qty) LOOP
	                ln_lifted_qty := curLifted.lifted_qty;
	                ln_split_lifted_qty := curLifted.split_lifted_qty;
		                ln_balance_delta_qty := curLifted.balance_delta_qty;
	            END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, p_daytime, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
            END LOOP;
        END IF;
        END IF;

        IF p_incl_delta = 'Y' THEN
        	IF ln_split_lifted_qty IS NOT NULL THEN
        		ln_balance_delta_qty := ln_balance_delta_qty * ln_split_lifted_qty / ln_lifted_qty;
        		ln_lifted_qty := ln_split_lifted_qty;
        	END IF;
        	IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_lifting_account_id), p_daytime, '<=') = 'IMPORT') THEN
        		ln_lifted_qty := NVL(ln_lifted_qty, 0) - NVL(ln_balance_delta_qty, 0);
        	ELSE
        		ln_lifted_qty := NVL(ln_lifted_qty, 0) + NVL(ln_balance_delta_qty, 0);
        	END IF;
        ELSIF ln_split_lifted_qty IS NOT NULL THEN
        	ln_lifted_qty := ln_split_lifted_qty;
        END IF;

        RETURN ln_lifted_qty;

    END getAccEstLiftedQtyDay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedQtySubDay
    -- Description    : Returns the total lifted quantity for the prevoius hours of the day for selected lifting account
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting, cargo_status_mapping
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
    FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N', p_summer_time VARCHAR2 DEFAULT NULL) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_startdate DATE, cp_enddate DATE, cp_sysdate DATE, cp_summer_time VARCHAR2, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (--Find all cargos nomintated in the future
					SELECT ue_storage_lift_nomination.calcSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day,
					       NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3))) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime between cp_startdate and cp_enddate
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date > cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
                    --Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT ue_storage_lift_nomination.calcSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day,
					       decode(cp_xtra_qty, 0, sn.lifted_qty, 1, sn.lifted_qty2, 2, sn.lifted_qty3)) split_lifted_qty,
                           decode(cp_xtra_qty, 0, sn.lifted_qty, 1, sn.lifted_qty2, 2, sn.lifted_qty3) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.lifted_qty IS NOT NULL
                    AND    sn.daytime between cp_startdate and cp_enddate
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    n.nom_firm_date <= cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
					--Find all cargos without cargo transport record, in the future
					SELECT ue_storage_lift_nomination.calcSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day,
					       NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3))) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns, stor_sub_day_lift_nom sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime between cp_startdate and cp_enddate
                    AND    n.cargo_no is null
					AND    n.nom_firm_date > cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_startdate DATE, cp_enddate DATE, cp_summer_time VARCHAR2, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(split_lifted_qty) split_lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT ue_storage_lift_nomination.calcSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day,
							NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3))) split_lifted_qty,
                               NVL(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty),
                               decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime between cp_startdate and cp_enddate
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
					--Find all cargos without cargo transport record
                    SELECT ue_storage_lift_nomination.calcSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, sn.production_day,
					       decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) split_lifted_qty,
                           decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, storage_lift_nom_split ns, stor_sub_day_lift_nom sn
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime between cp_startdate and cp_enddate
                    AND    n.cargo_no is null
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)) a;

        ln_lifted_qty NUMBER;
        ln_split_lifted_qty NUMBER;
        ln_balance_delta_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);

    BEGIN

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_startdate, p_enddate, TRUNC(Ecdp_Timestamp.getCurrentSysdate), p_summer_time, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
             END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, p_startdate, p_enddate, p_summer_time, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
                ln_split_lifted_qty := curLifted.split_lifted_qty;
                ln_balance_delta_qty := curLifted.balance_delta_qty;
            END LOOP;
        END IF;

        IF p_incl_delta = 'Y' THEN
        	IF ln_split_lifted_qty IS NOT NULL THEN
        		ln_balance_delta_qty := ln_balance_delta_qty * ln_split_lifted_qty / ln_lifted_qty;
        		ln_lifted_qty := ln_split_lifted_qty;
        	END IF;
        	IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_lifting_account_id), p_startdate, '<=') = 'IMPORT') THEN
        		ln_lifted_qty := NVL(ln_lifted_qty, 0) - NVL(ln_balance_delta_qty, 0);
        	ELSE
        		ln_lifted_qty := NVL(ln_lifted_qty, 0) + NVL(ln_balance_delta_qty, 0);
        	END IF;
        ELSIF ln_split_lifted_qty IS NOT NULL THEN
        	ln_lifted_qty := ln_split_lifted_qty;
        END IF;

        RETURN ln_lifted_qty;

    END getAccEstLiftedQtySubDay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getLiftedQtyMth
    -- Description    : Returns the total lifted quantity for the month for selected storage
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting
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
    FUNCTION getLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_object_id VARCHAR2, p_from_date DATE, p_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(s.load_value) lifted_qty
            FROM   storage_lift_nomination n, product_meas_setup p, storage_lifting s
            WHERE  n.object_id = cp_object_id
            AND    n.bl_date >= p_from_date
            AND    n.bl_date < p_to_date
            AND    n.parcel_no = s.parcel_no
            AND    s.product_meas_no = p.product_meas_no
            AND    p.lifting_event = 'LOAD'
            AND    ((p.nom_unit_ind = 'Y' and 0 = NVL(cp_xtra_qty, 0)) or (p.nom_unit_ind2 = 'Y' and 1 = cp_xtra_qty) or (p.nom_unit_ind2 = 'Y' and 3 = cp_xtra_qty));

        ld_from_date  DATE;
        ld_to_date    DATE;
        ln_lifted_qty NUMBER;

    BEGIN
        ld_from_date := TRUNC(p_daytime);
        ld_to_date   := ADD_MONTHS(ld_from_date, 1);

        FOR curLifted IN c_lifting(p_object_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
            ln_lifted_qty := curLifted.lifted_qty;
        END LOOP;

        RETURN ln_lifted_qty;

    END getLiftedQtyMth;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getEstLiftedQtyMth
    -- Description    : Returns the total lifted quantity for the month for selected storage
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting, cargo_status_mapping
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
    FUNCTION getEstLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_object_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(lifted_qty2) lifted_qty2, SUM(lifted_qty3) lifted_qty3
            FROM   (SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n, cargo_transport c, cargo_status_mapping csm
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    UNION ALL
                    SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.cargo_no is null) a;

        ld_from_date  DATE;
        ld_to_date    DATE;
        ln_lifted_qty NUMBER;

    BEGIN
        ld_from_date := TRUNC(p_daytime);
        ld_to_date   := ADD_MONTHS(ld_from_date, 1);

        FOR curLifted IN c_lifting(p_object_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
            IF (p_xtra_qty = 1) THEN
                ln_lifted_qty := curLifted.lifted_qty2;
            ELSIF (p_xtra_qty = 2) THEN
                ln_lifted_qty := curLifted.lifted_qty3;
            ELSE
                ln_lifted_qty := curLifted.lifted_qty;
            END IF;
        END LOOP;

        RETURN ln_lifted_qty;

    END getEstLiftedQtyMth;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getEstLiftedQtyDay
    -- Description    : Returns the total lifted quantity for the month for selected storage
    --
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : storage_lift_nomination, product_meas_setup, storage_lifting, cargo_status_mapping
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
    FUNCTION getEstLiftedQtyDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_object_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(lifted_qty2) lifted_qty2, SUM(lifted_qty3) lifted_qty3
            FROM   (SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n, cargo_transport c, cargo_status_mapping csm
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    UNION ALL
                    SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    n.cargo_no is null) a;

        ln_lifted_qty NUMBER;

    BEGIN
        FOR curLifted IN c_lifting(p_object_id, p_daytime, p_xtra_qty) LOOP
            IF (p_xtra_qty = 1) THEN
                ln_lifted_qty := curLifted.lifted_qty2;
            ELSIF (p_xtra_qty = 2) THEN
                ln_lifted_qty := curLifted.lifted_qty3;
            ELSE
                ln_lifted_qty := curLifted.lifted_qty;
            END IF;
        END LOOP;

        RETURN ln_lifted_qty;

    END getEstLiftedQtyDay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcStorageLevel
    -- Description    : Gets the storage level for a date based on planned/official production.
    --                  The 'plan' parameter can be
    --          PO, A, B; C
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : stor_day_forecast,  stor_day_official, stor_period_export_status, storage_nomination, cargo_status_mapping
    --
    -- Using functions: ec_stor_day_official.official_qty
    --          ecbp_storage_lift_nomination.getLiftedVol
    --          ecbp_storage_measurement.getStorageDayGrsClosingVol
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_daytime DATE, p_plan VARCHAR2 DEFAULT 'PO', p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER
    --</EC-DOC>
     IS
        -- first day of month
        CURSOR c_exported(cp_storage_id VARCHAR2, cp_daytime DATE) IS
            SELECT SUM(export_qty) qty, SUM(export_qty2) qty2, SUM(export_qty3) qty3
            FROM   stor_period_export_status
            WHERE  object_id = cp_storage_id
            AND    daytime = cp_daytime
            AND    time_span = 'MTH';

        -- rest day of month, get the latest as the closest/actual value
        CURSOR c_exported_day(cp_storage_id VARCHAR2, cp_daytime DATE) IS
            SELECT sum(a.export_qty) qty, sum(a.export_qty2) qty2, sum(a.export_qty3) qty3
            FROM   stor_period_export_status a
            WHERE  a.object_id = cp_storage_id
            AND    a.daytime = (SELECT MAX(daytime)
                                FROM   stor_period_export_status s
                                WHERE  s.object_id = a.object_id
                                AND    s.time_span = 'DAY'
                                AND    trunc(s.daytime) = cp_daytime)
            AND    a.time_span = 'DAY';

        CURSOR c_sum_in(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE) IS
            SELECT SUM(Nvl(ec_stor_day_official.official_qty(f.object_id, f.daytime), f.forecast_qty)) OP,
                   SUM(Nvl(ec_stor_day_official.official_qty2(f.object_id, f.daytime), f.forecast_qty2)) OP2,
                   SUM(Nvl(ec_stor_day_official.official_qty3(f.object_id, f.daytime), f.forecast_qty3)) OP3,
                   SUM(Nvl(ec_stor_day_official.official_qty(f.object_id, f.daytime), f.plan_a_qty)) PLAN_A,
                   SUM(Nvl(ec_stor_day_official.official_qty(f.object_id, f.daytime), f.plan_b_qty)) PLAN_B,
                   SUM(Nvl(ec_stor_day_official.official_qty(f.object_id, f.daytime), f.plan_c_qty)) PLAN_C
            FROM   stor_day_forecast f
            WHERE  f.object_id = cp_storage_id
            AND    f.daytime >= cp_start
            AND    f.daytime <= cp_end;

        CURSOR c_sum_out_actual(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), n.grs_vol_nominated)) lifted,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_start
                    AND    nvl(n.bl_date, n.nom_firm_date) <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    --AND    n.nom_firm_date <= cp_end
                    UNION ALL
                    SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), n.grs_vol_nominated)) lifted,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.nom_firm_date >= cp_start
                    AND    n.nom_firm_date <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    SELECT ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty) lifted,
                           ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.bl_date >= cp_start
					AND    n.bl_date <= cp_end
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_sum_out_actual_sub_day(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_start
                    AND    sn.production_day <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    --AND    n.nom_firm_date <= cp_end
                    UNION ALL
                    SELECT ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n,stor_subday_nom_sum sn
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.parcel_no = sn.parcel_no
                    AND    n.nom_firm_date >= cp_start
                    AND    n.nom_firm_date <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    SELECT ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', cp_xtra_qty) lifted,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c,(SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom WHERE lifted_qty IS NOT NULL) sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_start
					AND    sn.production_day <= cp_end
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), n.grs_vol_nominated)) lifted,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_start
                    AND    nvl(n.bl_date, n.nom_firm_date) <= cp_end
                    UNION ALL
                    SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), n.grs_vol_nominated)) lifted,
                           Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, cp_xtra_qty),
                           	   decode(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.nom_firm_date >= cp_start
                    AND    n.nom_firm_date <= cp_end) a;

        CURSOR c_sum_out_sub_day(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c,stor_subday_nom_sum sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_start
                    AND    sn.production_day <= cp_end
                    UNION ALL
                    SELECT ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                           ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
                    FROM   storage_lift_nomination n,stor_subday_nom_sum sn
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.production_day >= cp_start
                    AND    sn.production_day <= cp_end) a;

        CURSOR c_unit(cp_storage_id VARCHAR2, cp_daytime DATE, cp_event VARCHAR2) IS
            SELECT m.item_condition, c.unit, c.uom_group
            FROM   lifting_measurement_item m, product_meas_setup s, stor_version v, ctrl_unit c
            WHERE  m.item_code = s.item_code
            AND    s.lifting_event = cp_event
            AND    s.nom_unit_ind = 'Y'
            AND    s.object_id = v.product_id
            AND    v.daytime <= cp_daytime
            AND    Nvl(v.end_date, cp_daytime + 1) > cp_daytime
            AND    v.object_id = cp_storage_id
            AND    m.unit = c.unit;

        CURSOR c_unit2(cp_storage_id VARCHAR2, cp_daytime DATE, cp_event VARCHAR2) IS
            SELECT m.item_condition, c.unit, c.uom_group
            FROM   lifting_measurement_item m, product_meas_setup s, stor_version v, ctrl_unit c
            WHERE  m.item_code = s.item_code
            AND    s.lifting_event = cp_event
            AND    s.nom_unit_ind2 = 'Y'
            AND    s.object_id = v.product_id
            AND    v.daytime <= cp_daytime
            AND    Nvl(v.end_date, cp_daytime + 1) > cp_daytime
            AND    v.object_id = cp_storage_id
            AND    m.unit = c.unit;

        CURSOR c_unit3(cp_storage_id VARCHAR2, cp_daytime DATE, cp_event VARCHAR2) IS
            SELECT m.item_condition, c.unit, c.uom_group
            FROM   lifting_measurement_item m, product_meas_setup s, stor_version v, ctrl_unit c
            WHERE  m.item_code = s.item_code
            AND    s.lifting_event = cp_event
            AND    s.nom_unit_ind3 = 'Y'
            AND    s.object_id = v.product_id
            AND    v.daytime <= cp_daytime
            AND    Nvl(v.end_date, cp_daytime + 1) > cp_daytime
            AND    v.object_id = cp_storage_id
            AND    m.unit = c.unit;

		--HMM: Updated to filter on event_day to support sub daily
        CURSOR c_tank_meas(cp_storage_id VARCHAR2, cp_measurement_event_type VARCHAR2, cp_daytime DATE) IS
            SELECT trunc(Max(tm.event_day)) last_day, max(tm.daytime) last_dip, max(tm.measurement_event_type) event_type
            FROM   tank_measurement tm, tank_usage tu
            WHERE  tu.object_id = cp_storage_id
            AND    tu.daytime <= cp_daytime
            AND    Nvl(tu.end_date, cp_daytime + 1) > cp_daytime
            AND    tm.object_id = tu.tank_id
            AND    tm.event_day <= cp_daytime
                  --AND tm.measurement_event_type = cp_measurement_event_type
            AND    (nvl(grs_dip_level, 0) + nvl(grs_vol, 0) + nvl(grs_mass, 0) + nvl(net_vol, 0) + nvl(net_mass, 0) + nvl(net_vol_avail, 0) + nvl(net_mass_avail, 0) + nvl(tank_level, 0) + nvl(tank_level_m3, 0) + nvl(tank_level_pct, 0) +
                  nvl(grs_vol_nsc, 0) + nvl(closing_energy, 0)) > 0;

        CURSOR c_actual(cp_storage_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT Trunc(sa.daytime) last_day, DECODE(cp_xtra_qty, 1, closing_balance2, 2, closing_balance3, closing_balance) closing_balance
            FROM   stor_day_bal_alloc sa
            WHERE  sa.object_id = cp_storage_id
            AND    sa.daytime = (SELECT Trunc(Max(sa2.daytime))
		            FROM   stor_day_bal_alloc sa2
		            WHERE  sa2.object_id = cp_storage_id
		            AND    sa2.daytime <= cp_daytime
		            AND    (sa2.closing_balance IS NOT NULL OR sa2.closing_balance2 IS NOT NULL OR sa2.closing_balance3 IS NOT NULL));

        CURSOR c_sub_day_actual(cp_storage_id VARCHAR2, cp_production_day DATE) IS
            SELECT distinct Trunc(sa.daytime, 'HH') last_hour
            FROM   stor_sub_day_bal_alloc sa
            WHERE  sa.object_id = cp_storage_id
            AND    sa.production_day = cp_production_day
            AND    sa.daytime = (SELECT Trunc(Max(sa2.daytime), 'HH')
		            FROM   stor_sub_day_bal_alloc sa2
		            WHERE  sa2.object_id = cp_storage_id
		            AND    sa2.production_day = cp_production_day
		            AND    (sa2.closing_balance IS NOT NULL OR sa2.closing_balance2 IS NOT NULL OR sa2.closing_balance3 IS NOT NULL));

        ld_StartDate DATE;
        ld_EndDate   DATE;
        ld_today     DATE;
        ln_Dip       NUMBER;
		lv_event_type VARCHAR2(32);
		ld_last_dip  DATE;
        lnTotalIn    NUMBER;
        lnTotalOut   NUMBER;
        ln_balance_delta NUMBER;
        ln_ExpQty    NUMBER;
        lv_condition VARCHAR2(32);
        lv_group     VARCHAR2(32);
        lv_prev_object_id storage.object_id%type;
        lv_prev_qty  NUMBER;
        lv_prev_date DATE;
        lb_Dip       BOOLEAN;
        lv_incl_sysdate VARCHAR2(1);
        lv_read_sub_day VARCHAR2(1);
        ln_actual_qty NUMBER;
        ld_day_end   DATE;
    BEGIN

        /*****************************
        INIT GLOBAL VARS
        */
        ld_today := TRUNC(Ecdp_Timestamp.getCurrentSysdate);
        lb_Dip   := FALSE;
        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
        lv_read_sub_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sub_day');

        --reset global variable if cache is OFF (p_ignore_cache = 'Y')
        IF (gv_prev_QTY IS NULL OR p_ignore_cache = 'Y') THEN
        	gv_prev_object_id := '0';
        	gv_prev_object_id_a := '0';
        	gv_prev_object_id_b := '0';
        	gv_prev_object_id_c := '0';
            gv_prev_QTY    := 0;
            gv_prev_qty_a  := 0;
            gv_prev_qty_b  := 0;
            gv_prev_qty_c  := 0;
            gv_prev_DATE   := TO_DATE('1900-01-01', 'YYYY-MM-dd');
            gv_prev_DATE_a := TO_DATE('1900-01-01', 'YYYY-MM-dd');
            gv_prev_DATE_b := TO_DATE('1900-01-01', 'YYYY-MM-dd');
            gv_prev_DATE_c := TO_DATE('1900-01-01', 'YYYY-MM-dd');
        END IF;

        IF (gv_prev_QTY2 IS NULL OR p_ignore_cache = 'Y') THEN
            gv_prev_object_id2 := '0';
            gv_prev_QTY2  := 0;
            gv_prev_DATE2 := TO_DATE('1900-01-01', 'YYYY-MM-dd');
        END IF;

        IF (gv_prev_QTY3 IS NULL OR p_ignore_cache = 'Y') THEN
            gv_prev_object_id3 := '0';
            gv_prev_QTY3  := 0;
            gv_prev_DATE3 := TO_DATE('1900-01-01', 'YYYY-MM-dd');
        END IF;

        IF P_XTRA_QTY = 1 THEN
            --use prev_date2 and prev_qty2
            lv_prev_object_id := gv_prev_object_id2;
            lv_prev_date := gv_prev_date2;
            lv_prev_qty  := gv_prev_qty2;

            FOR curUnit IN c_unit2(p_storage_id, p_daytime, 'LOAD') LOOP
                lv_condition := curUnit.item_condition;
                lv_group     := curUnit.uom_group;
            END LOOP;
        ELSIF P_XTRA_QTY = 2 THEN
            --use prev_date3 and prev_qty3
            lv_prev_object_id := gv_prev_object_id3;
            lv_prev_date := gv_prev_date3;
            lv_prev_qty  := gv_prev_qty3;
            FOR curUnit IN c_unit3(p_storage_id, p_daytime, 'LOAD') LOOP
                lv_condition := curUnit.item_condition;
                lv_group     := curUnit.uom_group;
            END LOOP;
        ELSE
            --use prev_date and prev_qty
            case
                when p_plan = 'A' then
		            lv_prev_object_id := gv_prev_object_id_a;
                    lv_prev_qty  := gv_prev_qty_a;
                    lv_prev_date := gv_prev_date_a;
                when p_plan = 'B' then
		            lv_prev_object_id := gv_prev_object_id_b;
                    lv_prev_qty  := gv_prev_qty_b;
                    lv_prev_date := gv_prev_date_b;
                when p_plan = 'C' then
		            lv_prev_object_id := gv_prev_object_id_c;
                    lv_prev_qty  := gv_prev_qty_c;
                    lv_prev_date := gv_prev_date_c;
                else
		            lv_prev_object_id := gv_prev_object_id;
                    lv_prev_qty  := gv_prev_qty;
                    lv_prev_date := gv_prev_date;
            end case;

            FOR curUnit IN c_unit(p_storage_id, p_daytime, 'LOAD') LOOP
                lv_condition := curUnit.item_condition;
                lv_group     := curUnit.uom_group;
            END LOOP;
        END IF;

        /*****************************
        DIP OR NOT
        */
        --get latest dip date.
        FOR cur_rec IN c_tank_meas(p_storage_id, 'DAY_CLOSING', p_daytime) LOOP
            ld_StartDate := cur_rec.last_day;
			lv_event_type := cur_rec.event_type;
			ld_last_dip := cur_rec.last_dip;
        END LOOP;

		    ld_StartDate := ue_storage_balance.getStorageDipDate(ld_StartDate, lv_event_type, ld_last_dip, p_daytime, p_storage_id);

        --get latest allocated actual.
        FOR cur_rec IN c_actual(p_storage_id, p_daytime, p_xtra_qty) LOOP
        	IF cur_rec.last_day >= NVL(ld_StartDate, cur_rec.last_day) THEN
	            ld_StartDate := cur_rec.last_day;
	            ln_actual_qty := cur_rec.closing_balance;
	        END IF;
        END LOOP;

        --check if latest dip is for requested date?
		ld_day_end := EcDp_ProductionDay.getProductionDayStart('STORAGE',p_storage_id,ld_StartDate + 1) - 1/24;
        IF ld_StartDate = p_daytime THEN
        	IF ln_actual_qty IS NULL THEN
				IF lv_event_type = 'DAY_CLOSING' THEN
	            ln_Dip := getStorageDip(p_storage_id, p_daytime, lv_condition, lv_group, 'CLOSING'); --+0.000001; -- get tank_dip for requested date
				ELSIF ld_last_dip = ld_day_end THEN
					ln_Dip := getStorageDip(p_storage_id, ld_day_end, lv_condition, lv_group, 'CLOSING'); --+0.000001; -- get tank_dip for requested date
				ELSE
					ln_Dip := calcStorageLevelSubDay(p_storage_id, ld_day_end, ecdp_date_time.summertime_flag(ld_day_end), p_xtra_qty, p_ignore_cache); --+0.000001; -- get tank_dip for requested date
				END IF;
	            lb_Dip := TRUE;
	            --ld_StartDate:=ld_StartDate+1; --to avoid run down (but include exported not lifted)
	        ELSE
	            ln_Dip := ln_actual_qty; --+0.000001; -- get tank_dip for requested date
	            lb_Dip := TRUE;
	            --ld_StartDate:=ld_StartDate+1; --to avoid run down (but include exported not lifted)
	        END IF;
        ELSE
            --Check if p_daytime (current calc date) is in the future AND prev_date is the day before p_daytime
            IF (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime, 'DD') = 0) THEN
                --prev_date and p_daytime is identical and in the future
                RETURN NVL(lv_prev_qty, 0); --+0.0001;
            ELSIF (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime - 1, 'DD') = 0) THEN
                --prev_date is the day before p_daytime and in the future
                ld_StartDate := p_daytime;
                ln_dip       := NVL(lv_prev_qty, 0); --+0.001;
            ELSE
                --do full calc from last known dip (ld_StartDate), if ld_StartDate is NULL, then start for the beginning of time
                if ld_StartDate is not null then
                	IF ln_actual_qty IS NULL THEN
                    IF lv_event_type = 'DAY_CLOSING' THEN
                      ln_dip := getStorageDip(p_storage_id, ld_StartDate, lv_condition, lv_group, 'CLOSING');
                    ELSIF ld_last_dip = ld_day_end THEN
                      ln_Dip := getStorageDip(p_storage_id, ld_day_end, lv_condition, lv_group, 'CLOSING'); --+0.000001; -- get tank_dip for requested date
                    ELSE
                      ln_Dip := calcStorageLevelSubDay(p_storage_id, ld_day_end, ecdp_date_time.summertime_flag(ld_day_end), p_xtra_qty, p_ignore_cache); --+0.000001; -- get tank_dip for requested date
                    END IF;
	                ELSE
	                	-- If sub daily allocated balance is calculated for the next day
	                	FOR cur_rec IN c_sub_day_actual(p_storage_id, ld_StartDate + 1) LOOP
							ld_day_end := ld_day_end + 1;
	                		ln_dip := calcStorageLevelSubDay(p_storage_id, ld_day_end, ecdp_date_time.summertime_flag(ld_day_end), p_xtra_qty, p_ignore_cache);
	                		ld_StartDate:=ld_StartDate+1;
	                	END LOOP;

	                	IF ln_dip IS NULL THEN
		                	ln_dip := ln_actual_qty;
		                END IF;
	                END IF;

                    IF ln_Dip IS NOT NULL THEN
                        ld_StartDate := ld_StartDate + 1;
                    END if;
                else
                    ld_StartDate := to_Date('1900-01-01', 'yyyy-mm-dd');
                end if;
                ln_dip := nvl(ln_dip, 0); --+0.01;

            END IF;
        END IF;

        /*****************************
        EXPORTED NOT LIFTED
        */
        --IF Nvl(ln_Dip, 0) > 0 THEN
        IF lb_Dip THEN
            -- adjust with exported not lifted number if a tank dip exist
            FOR curExp IN c_exported_day(p_storage_id, ld_StartDate) LOOP
                if p_xtra_qty = 1 then
                    ln_ExpQty := nvl(curExp.Qty2, 0); -- get daily exported-not-lifted
                elsif p_xtra_qty = 2 then
                    ln_ExpQty := nvl(curExp.Qty3, 0); -- get daily exported-not-lifted
                else
                    ln_ExpQty := nvl(curExp.Qty, 0); -- get daily exported-not-lifted
                end if;
            END LOOP;

            IF ln_ExpQty = 0 AND to_char(ld_StartDate, 'dd') = '01' THEN
                -- if no value and it is 1st day of month, get monthly exported-not-lifted
                FOR curExp IN c_exported(p_storage_id, ld_StartDate) LOOP
                    if p_xtra_qty = 1 then
                        ln_ExpQty := nvl(curExp.Qty2, 0); -- get daily exported-not-lifted
                    elsif p_xtra_qty = 2 then
                        ln_ExpQty := nvl(curExp.Qty3, 0); -- get daily exported-not-lifted
                    else
                        ln_ExpQty := nvl(curExp.Qty, 0); -- get daily exported-not-lifted
                    end if;
                END LOOP;
            END IF;

            ln_Dip := ln_Dip + nvl(ln_ExpQty, 0);
            --ELSE
            --  ln_Dip := 0;    -- last choice, set to 0
        END IF;
        ld_EndDate := p_daytime;

        /*****************************
        RUNDOWN
        */
        -- get official/planned incomming
        if Not lb_Dip then
            FOR curIn IN c_sum_in(p_storage_id, ld_StartDate, ld_EndDate) LOOP
                IF nvl(p_plan, 'PO') = 'PO' THEN
                    IF P_XTRA_QTY = 1 THEN
                        lnTotalIn := curIn.op2;
                    ELSIF P_XTRA_QTY = 2 THEN
                        lnTotalIn := curIn.op3;
                    ELSE
                        lnTotalIn := curIn.op;
                    END IF;
                ELSIF p_plan = 'A' THEN
                    lnTotalIn := curIn.PLAN_A;
                ELSIF p_plan = 'B' THEN
                    lnTotalIn := curIn.PLAN_B;
                ELSIF p_plan = 'C' THEN
                    lnTotalIn := curIn.PLAN_C;
                END IF;
            END LOOP;


	        /*
	          IF ld_today > ld_EndDate THEN
	            ld_today := ld_EndDate;
	          END IF;
	        */

	        /*****************************
	        LIFTED
	        */
	        -- get official/planned lifted
            IF lv_incl_sysdate = 'Y' THEN
		        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	                FOR curOut IN c_sum_out_actual_sub_day(p_storage_id, ld_StartDate, ld_EndDate, ld_today, p_xtra_qty) LOOP
	                    lnTotalOut := curOut.lifted_qty;
	                    ln_balance_delta := curOut.balance_delta_qty;
	                END LOOP;
	            ELSE
                FOR curOut IN c_sum_out_actual(p_storage_id, ld_StartDate, ld_EndDate, ld_today, p_xtra_qty) LOOP
                    lnTotalOut := curOut.lifted_qty;
                    ln_balance_delta := curOut.balance_delta_qty;
                END LOOP;
	            END IF;
            ELSE
		        IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
	                FOR curOut IN c_sum_out_sub_day(p_storage_id, ld_StartDate, ld_EndDate, p_xtra_qty) LOOP
			            lnTotalOut := curOut.lifted_qty;
	                    ln_balance_delta := curOut.balance_delta_qty;
			        END LOOP;
            ELSE
                FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, ld_EndDate, p_xtra_qty) LOOP
	            lnTotalOut := curOut.lifted_qty;
                    ln_balance_delta := curOut.balance_delta_qty;
	        END LOOP;
            END IF;
            END IF;

	        IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
	            ln_dip := nvl(ln_Dip, 0) - Nvl(lnTotalIn, 0) + Nvl(lnTotalOut, 0);
	        ELSE
	            ln_dip := nvl(ln_Dip, 0) + Nvl(lnTotalIn, 0) - Nvl(lnTotalOut, 0);
	        END IF;

	        ln_dip := nvl(ln_Dip, 0) - nvl(ln_balance_delta, 0);
        End if;

        /*****************************
        SAVE GLOBAL VARS FOR NEXT ITERATION
        */
        --STORE current calc'ed storage level for next iteration if the cache is turn ON (p_ignore_cache = 'N')
        IF (p_ignore_cache = 'N') THEN
          IF p_xtra_qty = 1 THEN
            gv_prev_object_id2 := p_storage_id;
              gv_prev_date2 := p_daytime;
              gv_prev_qty2  := ln_dip;
          ELSIF p_xtra_qty = 2 THEN
            gv_prev_object_id3 := p_storage_id;
              gv_prev_date3 := p_daytime;
              gv_prev_qty3  := ln_dip;
          ELSE
              case
                  when p_plan = 'A' then
                gv_prev_object_id_a := p_storage_id;
                      gv_prev_qty_a  := ln_dip;
                      gv_prev_date_a := p_daytime;
                  when p_plan = 'B' then
                gv_prev_object_id_b := p_storage_id;
                      gv_prev_qty_b  := ln_dip;
                      gv_prev_date_b := p_daytime;
                  when p_plan = 'C' then
                gv_prev_object_id_c := p_storage_id;
                      gv_prev_qty_c  := ln_dip;
                      gv_prev_date_c := p_daytime;
                  else
                gv_prev_object_id := p_storage_id;
                      gv_prev_qty  := ln_dip;
                      gv_prev_date := p_daytime;
              end case;
          END IF;
        END IF;

      return ln_dip;
    END calcStorageLevel;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcStorageLevelSubDay
    -- Description    : Gets the storage level for a date based on planned/official production.
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : stor_sub_day_forecast,  stor_sub_day_official, storage_nomination, cargo_status_mapping
    --
    -- Using functions: calcStorageLevel, EcDp_ProductionDay.getProductionDay
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER
    --</EC-DOC>
     IS

        CURSOR c_sum_in(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE) IS
            SELECT SUM(Nvl(ec_stor_sub_day_official.official_qty(f.object_id, f.daytime), f.forecast_qty)) OP,
                   SUM(Nvl(ec_stor_sub_day_official.official_qty2(f.object_id, f.daytime), f.forecast_qty2)) OP2,
                   SUM(Nvl(ec_stor_sub_day_official.official_qty3(f.object_id, f.daytime), f.forecast_qty3)) OP3
            FROM   stor_sub_day_forecast f
            WHERE  f.object_id = cp_storage_id
            AND    f.daytime >= cp_start
            AND    f.daytime <= cp_end;

        CURSOR c_sum_intercept(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_summer_time VARCHAR2) IS
            SELECT SUM(Nvl(ec_stor_sub_day_official.official_qty(f.object_id, f.daytime), f.forecast_qty)) OP,
                   SUM(Nvl(ec_stor_sub_day_official.official_qty2(f.object_id, f.daytime), f.forecast_qty2)) OP2,
                   SUM(Nvl(ec_stor_sub_day_official.official_qty3(f.object_id, f.daytime), f.forecast_qty3)) OP3
            FROM   stor_sub_day_forecast f
            WHERE  f.object_id = cp_storage_id
            AND    f.daytime >= cp_start
            AND    f.daytime <= cp_end
            AND    f.summer_time = cp_summer_time;

        CURSOR c_sumerTime_flag(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE) IS
            SELECT ecdp_date_time.summertime_flag(t.daytime) summerFlag
            from   stor_sub_day_forecast t
            where  t.daytime >= cp_start
            AND    t.daytime <= cp_end
            AND    t.object_id = cp_storage_id;

        CURSOR c_sum_out_actual(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_sysdate DATE, cp_xtra_qty NUMBER, cp_summer_time VARCHAR2 DEFAULT NULL) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty), decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) lifted,
                            decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime >= cp_start
                    AND    sn.daytime <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
                    SELECT decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3) lifted,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, stor_sub_day_lift_nom sn
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime >= cp_start
                    AND    sn.daytime <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
                    SELECT decode(cp_xtra_qty, 0, sn.lifted_qty, 1, sn.lifted_qty2, 2, sn.lifted_qty3) lifted,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.lifted_qty IS NOT NULL
                    AND    sn.daytime >= cp_start
                    AND    sn.daytime <= cp_end
                    AND    n.nom_firm_date <= cp_sysdate
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)) a;

        CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER, cp_summer_time VARCHAR2 DEFAULT NULL) IS
            SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
            FROM   (SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, cp_xtra_qty), decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3)) lifted,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, cargo_transport c, stor_sub_day_lift_nom sn, cargo_status_mapping csm
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
					AND    c.cargo_status= csm.cargo_status
                    AND    csm.ec_cargo_status <> 'D'
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime >= cp_start
                    AND    sn.daytime <= cp_end
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                    UNION ALL
                    SELECT decode(cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3) lifted_qty,
                           decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                    FROM   storage_lift_nomination n, stor_sub_day_lift_nom sn
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.parcel_no = sn.parcel_no
                    AND    sn.daytime >= cp_start
                    AND    sn.daytime <= cp_end
					AND    sn.summer_time = NVL(cp_summer_time, sn.summer_time)) a;

        CURSOR c_unit(cp_storage_id VARCHAR2, cp_daytime DATE, cp_event VARCHAR2, cp_xtra_qty NUMBER) IS
            SELECT m.item_condition, c.unit, c.uom_group
            FROM   lifting_measurement_item m, product_meas_setup s, stor_version v, ctrl_unit c
            WHERE  m.item_code = s.item_code
            AND    s.lifting_event = cp_event
            AND    DECODE(cp_xtra_qty, 1, s.nom_unit_ind2, 2, s.nom_unit_ind3, s.nom_unit_ind)  = 'Y'
            AND    s.object_id = v.product_id
            AND    v.daytime <= cp_daytime
            AND    Nvl(v.end_date, cp_daytime + 1) > cp_daytime
            AND    v.object_id = cp_storage_id
            AND    m.unit = c.unit;

        CURSOR c_tank_meas(cp_storage_id VARCHAR2, cp_measurement_event_type VARCHAR2, cp_production_day DATE, cp_daytime DATE) IS
            SELECT Max(tm.daytime) last_hour
            FROM   tank_measurement tm, tank_usage tu
            WHERE  tu.object_id = cp_storage_id
            AND    tu.daytime <= cp_daytime
            AND    Nvl(tu.end_date, cp_daytime + 1) > cp_daytime
            AND    tm.object_id = tu.tank_id
            AND    tm.event_day = cp_production_day
            AND    tm.daytime <= cp_daytime
            AND    tm.measurement_event_type = cp_measurement_event_type
            AND    (nvl(grs_dip_level, 0) + nvl(grs_vol, 0) + nvl(grs_mass, 0) + nvl(net_vol, 0) + nvl(net_mass, 0) + nvl(net_vol_avail, 0) + nvl(net_mass_avail, 0) + nvl(tank_level, 0) + nvl(tank_level_m3, 0) + nvl(tank_level_pct, 0) +
                  nvl(grs_vol_nsc, 0) + nvl(closing_energy, 0)) > 0;

        CURSOR c_actual(cp_storage_id VARCHAR2, cp_production_day DATE, cp_daytime DATE, cp_xtra_qty NUMBER, cp_summer_time_order VARCHAR2) IS
            SELECT Trunc(sa.daytime,'HH') last_hour, summer_time, DECODE(cp_xtra_qty, 1, closing_balance2, 2, closing_balance3, closing_balance) closing_balance
            FROM   stor_sub_day_bal_alloc sa
            WHERE  sa.object_id = cp_storage_id
            AND    sa.production_day = cp_production_day
            AND    sa.daytime = (SELECT Trunc(Max(sa2.daytime),'HH') last_day
                FROM   stor_sub_day_bal_alloc sa2
                WHERE  sa2.object_id = cp_storage_id
                AND    sa2.production_day = cp_production_day
                AND    sa2.daytime <= cp_daytime
                AND    (sa2.closing_balance IS NOT NULL OR sa2.closing_balance2 IS NOT NULL OR sa2.closing_balance3 IS NOT NULL))
          ORDER BY daytime, decode(cp_summer_time_order,'ASC',summer_time,null) ASC, decode(cp_summer_time_order,'DESC',summer_time,null) DESC;

        ld_today          DATE;
        ld_startDate      DATE;
        lv_condition      VARCHAR2(32);
        lv_group          VARCHAR2(32);
        ln_Dip            NUMBER;
        lnTotalIn         NUMBER;
        lnTotalOut        NUMBER;
        ln_balance_delta  NUMBER;
        ld_production_day DATE;
        lv_summer_flag    VARCHAR2(32);
        lv_incl_sysdate   VARCHAR2(1);
        lv_summer_time_order VARCHAR2(32);
		lud_next_hour EcDp_Date_Time.Ec_Unique_Daytime;

    BEGIN
        ld_production_day := EcDp_ProductionDay.getProductionDay('STORAGE', p_storage_id, p_daytime, p_summer_time);
        ld_startDate      := EcDp_ProductionDay.getProductionDayStart('STORAGE', p_storage_id, ld_production_day);
        ld_today          := TRUNC(Ecdp_Timestamp.getCurrentSysdate);

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
        lv_summer_time_order := Nvl(ecdp_ctrl_property.getSystemProperty('/com/ec/frmw/summer_time/order'),'DESC');

	  --get latest allocated actual.
        FOR cur_rec IN c_actual(p_storage_id, ld_production_day, p_daytime, p_xtra_qty, lv_summer_time_order) LOOP
          IF cur_rec.last_hour >= ld_startDate THEN
              ln_Dip := cur_rec.closing_balance;
        IF cur_rec.last_hour = p_daytime AND cur_rec.summer_time = p_summer_time THEN
          RETURN NVL(cur_rec.closing_balance,0);
        ELSE
          lud_next_hour := EcDp_Date_Time.getNextHour(cur_rec.last_hour, cur_rec.summer_time);
          ld_StartDate := lud_next_hour.daytime;
          IF cur_rec.summer_time != lud_next_hour.summertime_flag THEN
            lv_summer_flag := cur_rec.summer_time;
          END IF;
        END IF;
          END IF;
        END LOOP;


        --get latest dip date.
        FOR cur_rec IN c_tank_meas(p_storage_id, 'EVENT_CLOSING', ld_production_day, p_daytime) LOOP
			IF cur_rec.last_hour IS NOT NULL THEN
				FOR curUnit IN c_unit(p_storage_id, p_daytime, 'LOAD', p_xtra_qty) LOOP
					lv_condition := curUnit.item_condition;
					lv_group     := curUnit.uom_group;
				END LOOP;
				-- get sub daily tank dip
				ln_dip := getStorageDip(p_storage_id, cur_rec.last_hour, lv_condition, lv_group, 'CLOSING');
				IF cur_rec.last_hour = p_daytime THEN
					RETURN NVL(ln_dip,0);
				END IF;
				ld_StartDate := cur_rec.last_hour + 1/24; --TODO: support 25 hour days
			END IF;
        END LOOP;


        -- get opening balance of the day
        IF ln_Dip IS NULL THEN
        	ln_Dip := calcStorageLevel(p_storage_id, ld_production_day - 1, NULL, p_xtra_qty, p_ignore_cache);
	    END IF;

        --checking the summer time flag
        IF lv_summer_flag IS NULL THEN
	        FOR curIn IN c_sumerTime_flag(p_storage_id, ld_startDate, p_daytime) LOOP
	            lv_summer_flag := curIn.summerFlag;
	        END LOOP;
	    END IF;

        IF (p_summer_time != lv_summer_flag) THEN
            -- Get forecast/official production during an intercept
            FOR curIn IN c_sum_intercept(p_storage_id, ld_startDate, p_daytime, p_summer_time) LOOP
                IF (p_xtra_qty = 1) THEN
                    lnTotalIn := curIn.op2;
                ELSIF (p_xtra_qty = 2) THEN
                    lnTotalIn := curIn.op3;
                ELSE
                    lnTotalIn := curIn.op;
                END IF;
            END LOOP;

			-- get all nominations during an intercept
			IF lv_incl_sysdate = 'Y' THEN
				FOR curOut IN c_sum_out_actual(p_storage_id, ld_StartDate, p_daytime, ld_today, p_xtra_qty, p_summer_time) LOOP
					lnTotalOut := curOut.lifted_qty;
					ln_balance_delta := curOut.balance_delta_qty;
				END LOOP;
			ELSE
				FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, p_daytime, p_xtra_qty, p_summer_time) LOOP
					lnTotalOut := curOut.lifted_qty;
					ln_balance_delta := curOut.balance_delta_qty;
				END LOOP;
			END IF;

        ELSE
            -- Get forecast/official production normal operations
            FOR curIn IN c_sum_in(p_storage_id, ld_startDate, p_daytime) LOOP
                IF (p_xtra_qty = 1) THEN
                    lnTotalIn := curIn.op2;
                ELSIF (p_xtra_qty = 2) THEN
                    lnTotalIn := curIn.op3;
                ELSE
                    lnTotalIn := curIn.op;
                END IF;
            END LOOP;

			-- get all nominations normal operations
			IF lv_incl_sysdate = 'Y' THEN
				FOR curOut IN c_sum_out_actual(p_storage_id, ld_StartDate, p_daytime, ld_today, p_xtra_qty) LOOP
				lnTotalOut := curOut.lifted_qty;
					ln_balance_delta := curOut.balance_delta_qty;
			END LOOP;
			ELSE
				FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, p_daytime, p_xtra_qty) LOOP
					lnTotalOut := curOut.lifted_qty;
					ln_balance_delta := curOut.balance_delta_qty;
				END LOOP;
			END IF;

        END IF;

      ln_dip := nvl(ln_Dip, 0) - nvl(ln_balance_delta, 0);

        IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
            RETURN ln_Dip - Nvl(lnTotalIn, 0) + Nvl(lnTotalOut, 0);
        ELSE
     		RETURN nvl(ln_Dip, 0) + Nvl(lnTotalIn, 0) - Nvl(lnTotalOut, 0);
        END IF;

    END calcStorageLevelSubDay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getStorageLoadVerifStatusValue
    -- Description    : Get the storage load/unload status if there is lifting/unloading occured
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   :
    --
    -- Using functions: Ecdp_Timestamp.getCurrentSysdate
    -- Configuration
    -- required       : p_loadType can be 'LOAD' or 'UNLOAD'
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getStorageLoadVerifStatusValue(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2
    --</EC-DOC>
    IS
    BEGIN
        IF p_nom_date <= trunc(Ecdp_Timestamp.getCurrentSysdate) AND nvl(p_qty, 0) = 0 AND nvl(p_cargo_status, 'xxx') != 'D' THEN
            RETURN 'showStopper';
        END IF;

        RETURN NULL;
    END getStorageLoadVerifStatusValue;


    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getStorageLoadVerifTextValue
    -- Description    : Get the storage load/unload status if there is lifting/unloading occured
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   :
    --
    -- Using functions: Ecdp_Timestamp.getCurrentSysdate
    -- Configuration
    -- required       : p_loadType can be 'LOAD' or 'UNLOAD'
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getStorageLoadVerifTextValue(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2
    --</EC-DOC>
    IS
    BEGIN
        IF p_nom_date <= trunc(Ecdp_Timestamp.getCurrentSysdate) AND nvl(p_qty, 0) = 0 AND nvl(p_cargo_status, 'xxx') != 'D' THEN
            IF p_loadType = 'LOAD' THEN
                RETURN 'No Lifting Occured';
            END IF;
            RETURN 'No Unloading Occured';
        END IF;

        RETURN NULL;
    END getStorageLoadVerifTextValue;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getStorageLoadStatus
    -- Description    : Get the storage load/unload status if there is lifting/unloading occured
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   :
    --
    -- Using functions: Ecdp_Timestamp.getCurrentSysdate
    -- Configuration
    -- required       : p_loadType can be 'LOAD' or 'UNLOAD'
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getStorageLoadStatus(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2
    --</EC-DOC>
     IS
        lv2_status VARCHAR2(200) := getStorageLoadVerifStatusValue(p_qty, p_nom_date, p_loadType, p_cargo_status);
        lv2_text   VARCHAR2(200) := getStorageLoadVerifTextValue(p_qty, p_nom_date, p_loadType, p_cargo_status);

    BEGIN

        IF lv2_status IS NOT NULL AND lv2_text IS NOT NULL THEN
            RETURN 'verificationStatus=' || lv2_status || ';' || 'verificationText=' || lv2_text;
        END IF;
        IF lv2_status IS NOT NULL THEN
            RETURN 'verificationStatus=' || lv2_status;
        END IF;
        IF lv2_text IS NOT NULL THEN
            RETURN 'verificationText=' || lv2_text;
        END IF;

        RETURN NULL;

    END getStorageLoadStatus;

END EcDp_Storage_Balance;