create or replace PACKAGE Ue_Trans_Storage_Balance IS
/****************************************************************
** Package        :  Ue_Trans_Storage_Balance; head part
**
** $Revision: 1.11 $
**
** Purpose        :
**
** Documentation  :
**
** Created        :  01-AUG-2012 Samuel Webb
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
*****************************************************************/

FUNCTION getAccLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedEnergyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getAccEstLiftedQtyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtyDay, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedMassDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getAccEstLiftedEnergyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtySubDay, WNDS, WNPS, RNPS);

FUNCTION getLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getEstLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getEstLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getEstLiftedQtyDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getEstLiftedQtyDay, WNDS, WNPS, RNPS);

FUNCTION calcSumOutOrInForADay(p_storage_id VARCHAR2,
                        p_daytime DATE,
                        p_plan VARCHAR2 DEFAULT 'PO',
                        p_xtra_qty NUMBER DEFAULT 0,
            p_type VARCHAR2 DEFAULT 'OUT')
RETURN NUMBER ;

FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_daytime DATE, p_plan VARCHAR2 DEFAULT 'PO', p_xtra_qty NUMBER DEFAULT 0, p_super_cache_flag VARCHAR2 DEFAULT 'NO') RETURN NUMBER;

FUNCTION calcStorageLevelTable(p_storage_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN') RETURN UE_CT_STORAGE_GRAPH_COLL PIPELINED;
FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getStorageLoadStatus(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2,p_cargo_status VARCHAR2) RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (getStorageLoadStatus, WNDS, WNPS, RNPS);

FUNCTION adjustLoadRateForPC(p_vol NUMBER,
                             p_purge_cool_vol NUMBER,
                             p_loading_rate NUMBER) RETURN NUMBER;

FUNCTION adjForDayEndNotLifted( p_cargo_no NUMBER,
                            p_start DATE,
                            p_end DATE) RETURN NUMBER;

FUNCTION adjForLoadingRate( p_vol NUMBER,
                            p_purge_cool_vol NUMBER,
                            p_non_firm_date_time DATE,
                            p_start DATE,
                            p_end DATE,
                            p_load_rate NUMBER DEFAULT 1,
                            p_storage_id VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION get_sysdate  RETURN DATE;


END Ue_Trans_Storage_Balance;
/
create or replace PACKAGE BODY Ue_Trans_Storage_Balance IS
    /****************************************************************
    ** Package        :  Ue_Trans_Storage_Balance; body part
    **
    ** Purpose        :
    **
    ** Documentation  :
    **
    ** Created        :  01-AUG-2012
    **
    ** Modification history:
    **
    ** Date        Whom     Change description:
    ** ----------  -------- -------------------------------------------
    ** 10-SEP-2012 SWGN     Altered based on changes introduced in SP1
    **                              ECPD-21212: In calcStorageLevel removed liq_dip_level.
    ** 02-JUL-2014 SWGN     Resolved defect for combined cargoes and storage levels (combined cargoes were being calculated in parallel instead of sequentially; used group-by to solve)
    ******************************************************************/

    -- cp_storage_id -- ID of the storage for export
    -- cp_start/cp_end -- The date range
    -- cp_cargo_off_qty_ind -- Do you want to account for acutals or just estimates?
    -- cp_xtra_qty -- Do yourself a favor and leave this NULL
    -- cp_loadingRate -- What is the default loading rate for a vessel when it has no defined loading rate?
    -- cp_offset -- What is the production day offset for this storage?

    CURSOR c_sum_out (cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER, cp_LoadingRate NUMBER, cp_offset NUMBER, cp_sysdate DATE) IS
        SELECT SUM(NVL(actual, nominated)) AS lifted_qty
          FROM (  -- Is this plan type 0, 1, or 2? We only ever use plan 0, but we've left legacy plan 1/2 code in here.

            SELECT  adjForLoadingRate (DECODE(cp_xtra_qty, 1, SUM(n.grs_vol_nominated2), 2, SUM(n.grs_vol_nominated3), SUM(n.grs_vol_nominated)),
                                                        SUM(NVL(n.purge_qty, 0)) + SUM(NVL(n.cooldown_qty, 0)),
                                                        MAX(N.START_LIFTING_DATE), cp_start, cp_end, NVL (ec_carrier_version.loading_rate(MAX(c.carrier_id), MAX(n.START_LIFTING_DATE), '<='), cp_LoadingRate),
                                                        cp_storage_id) nominated, -- Calculate nominated qty pulled down within the cursor period. Adjust for loading across a midnight boundary
                    adjForDayEndNotLifted(n.cargo_no, cp_start, cp_end) actual -- Calculate the amount actually lifted
            FROM storage_lift_nomination n, cargo_transport c
            WHERE    n.object_id = cp_storage_id
                 AND c.cargo_no = n.cargo_no
                 AND ecbp_cargo_status.geteccargostatus(c.cargo_status) <> 'D'
                 AND TRUNC (N.START_LIFTING_DATE - cp_offset) <= cp_end
                 AND n.nom_firm_date > NVL(cp_sysdate, n.nom_firm_date - 1) -- Do we need to check for sysdate? If the sysdate is passed in, we only send estimates for future cargoes.
            GROUP BY n.cargo_no
              HAVING TRUNC (MAX (N.START_LIFTING_DATE) + (SUM(N.grs_vol_nominated)
                                                          / NVL (ec_carrier_version.loading_rate(MAX(c.carrier_id), MAX(n.START_LIFTING_DATE), '<='),
                                                                 cp_LoadingRate)) / 24
                            - cp_offset) >= cp_start -- Only include cargoes within the date range after adjusting for loading time
        UNION ALL -- This part handles liftings that do not have cargos assigned
        SELECT   adjForLoadingRate(DECODE(cp_xtra_qty, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3, n.grs_vol_nominated),
                                   NVL(n.purge_qty, 0) + NVL(n.cooldown_qty, 0), n.START_LIFTING_DATE,
                                   cp_start, cp_end, NVL(ec_carrier_version.loading_rate(n.carrier_id, n.START_LIFTING_DATE, '<='), cp_LoadingRate),
                                   cp_storage_id) nominated,
                 null AS actual -- Parcels cannot get actual liftings assigned without cargoes associated
          FROM storage_lift_nomination n
         WHERE     n.object_id = cp_storage_id
               AND n.cargo_no IS NULL
               AND TRUNC (N.START_LIFTING_DATE - cp_offset) <= cp_end
               AND TRUNC (N.START_LIFTING_DATE + ((N.grs_vol_nominated / NVL(ec_carrier_version.loading_rate (n.carrier_id, n.START_LIFTING_DATE, '<='), cp_LoadingRate))) / 24 - cp_offset) >= cp_start
        UNION ALL -- This part handles actual liftings when the sysdate flag is set
        SELECT  NULL AS nominated, -- force to null when this flag is set
                    adjForDayEndNotLifted(n.cargo_no, cp_start, cp_end) actual -- Calculate the amount actually lifted
            FROM storage_lift_nomination n, cargo_transport c
            WHERE    n.object_id = cp_storage_id
                 AND c.cargo_no = n.cargo_no
                 AND ecbp_cargo_status.geteccargostatus(c.cargo_status) <> 'D'
                 AND TRUNC (N.START_LIFTING_DATE - cp_offset) <= cp_end
                 AND cp_sysdate IS NOT NULL
                 AND n.nom_firm_date <= cp_sysdate
                 GROUP BY n.cargo_no
              HAVING TRUNC (MAX (N.START_LIFTING_DATE) + ((SELECT SUM (ecbp_storage_lift_nomination.getLiftedVol (nn.parcel_no, cp_xtra_qty))
                                      FROM storage_lift_nomination nn
                                      WHERE nn.cargo_no = n.cargo_no)
                                                          / NVL (ec_carrier_version.loading_rate(MAX(c.carrier_id), MAX(n.START_LIFTING_DATE), '<='),
                                                                 cp_LoadingRate)) / 24
                            - cp_offset) >= cp_start
        ) a;

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
            AND    ((p.nom_unit_ind = 'Y' and 1 <> cp_xtra_qty) or (p.nom_unit_ind2 = 'Y' and 1 = cp_xtra_qty) or (p.nom_unit_ind3 = 'Y' and 2 = cp_xtra_qty));

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
    FUNCTION getAccEstLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                     p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (--Find all cargos nomintated in the future
                    SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no (+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS') <> 'D'
                    --end edit
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    --Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty)) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status<> 'D'
                    AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS') <> 'D'
                    --end edit
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    c.cargo_no(+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS') <> 'D'
                    --end edit
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date) a;

        ld_from_date  DATE;
        ld_to_date    DATE;
        ln_lifted_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);

    BEGIN
        ld_from_date := TRUNC(p_daytime);
        ld_to_date   := ADD_MONTHS(ld_from_date, 1);

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, ld_from_date, ld_to_date, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
            END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
            END LOOP;
        END IF;

        RETURN ln_lifted_qty;

    END getAccEstLiftedQtyMth;

        --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedEnergyMth
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
    FUNCTION getAccEstLiftedEnergyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                 p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER
    IS
        v_date DATE := p_daytime;
        v_return_value NUMBER;
    BEGIN
        WHILE v_date < add_months(p_daytime, 1) LOOP
            v_return_value := nvl(v_return_value, 0) + getAccEstLiftedEnergyDay(p_lifting_account_id, p_daytime, p_xtra_qty, p_excess_lifting_ind, p_excess_lifting_priority);
            v_date := v_date + 1;
        END LOOP;

        RETURN v_return_value;
    END;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedQtyDay
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
    FUNCTION getAccEstLiftedQtyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                   p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (--Find all cargos nomintated in the future
                    SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no(+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    --Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty)) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    n.bl_date = cp_daytime
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no(+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    );

        ln_lifted_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);

    BEGIN
        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_daytime, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
            END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, p_daytime, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
            END LOOP;
        END IF;

        RETURN ln_lifted_qty;

    END getAccEstLiftedQtyDay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedMassDay
    -- Description    : Returns the total mass for the day for selected lifting account
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

    FUNCTION getAccEstLiftedMassDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                   p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL) RETURN NUMBER
    --</EC-DOC>
     IS

     CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
       SELECT sl.load_value
       FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, storage_lifting sl,
              dv_prod_meas_setup ms
       WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
       AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
       AND    ns.parcel_no (+) = n.parcel_no
       AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
       AND    c.cargo_no(+) = n.cargo_no
        --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
        --AND    c.cargo_status (+) <> 'D'
        AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
        --end edit
       AND    n.nom_firm_date <= get_sysdate
       AND    n.parcel_no = sl.parcel_no (+)
       AND    sl.product_meas_no = ms.product_meas_no
       AND    ms.meas_item = 'LIFT_NET_MASS';

     CURSOR c_storage(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
       SELECT n.object_id
       FROM  storage_lift_nomination n, cargo_transport c
       WHERE n.lifting_account_id = cp_lifting_account_id
       AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
       AND   NVL(n.bl_date, n.nom_firm_date) = cp_daytime
       AND   c.cargo_no(+) = n.cargo_no
        --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
        --AND    c.cargo_status (+) <> 'D'
        AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
        --end edit
       ;

     v_storage_id VARCHAR2(500);
     v_cargo_mass NUMBER;

     BEGIN

       FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_daytime, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
         v_cargo_mass :=  curLifted.load_value;
       END LOOP;

       IF v_cargo_mass IS NULL THEN
         FOR curStorage IN c_storage(p_lifting_account_id, p_daytime, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
           v_storage_id := curStorage.object_id;
         END LOOP;

         RETURN(NVL(getAccEstLiftedQtyDay(p_lifting_account_id, p_daytime, p_xtra_qty) *
           ec_strm_reference_value.density(ec_stor_version.plan_object_id(v_storage_id,p_daytime,'<='),p_daytime,'<='),0));
       ELSE
         RETURN(NVL(v_cargo_mass,0));
       END IF;

    END getAccEstLiftedMassDay;


    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedEnergyDay
    -- Description    : Returns the total energy for the day for selected lifting account
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

    FUNCTION getAccEstLiftedEnergyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,
                                                   p_excess_lifting_ind VARCHAR2 DEFAULT NULL, p_excess_lifting_priority VARCHAR2 DEFAULT NULL
                                                   ) RETURN NUMBER
    --</EC-DOC>
     IS

     CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
       SELECT sl.load_value
       FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns, storage_lifting sl,
              dv_prod_meas_setup ms
       WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
       AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
       AND    ns.parcel_no (+) = n.parcel_no
       AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
       AND    c.cargo_no(+) = n.cargo_no
        --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
        --AND    c.cargo_status (+) <> 'D'
        AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
        --end edit
       AND    n.nom_firm_date <= get_sysdate
       AND    n.parcel_no = sl.parcel_no (+)
       AND    sl.product_meas_no = ms.product_meas_no
       AND    ms.meas_item = 'LIFT_NET_MMBTU';

     CURSOR c_storage(cp_lifting_account_id VARCHAR2, cp_daytime DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
       SELECT n.object_id
       FROM  storage_lift_nomination n, cargo_transport c
       WHERE n.lifting_account_id = cp_lifting_account_id
       AND    COALESCE(n.text_13,'WST') = COALESCE(p_excess_lifting_ind, n.text_13,'WST')
       AND   NVL(n.bl_date, n.nom_firm_date) = cp_daytime
       AND   c.cargo_no(+) = n.cargo_no
        --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
        --AND    c.cargo_status (+) <> 'D'
        AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
        --end edit
       ;

     v_storage_id VARCHAR2(500);
     v_cargo_energy NUMBER;

     BEGIN

       FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_daytime, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
         v_cargo_energy := curLifted.load_value;
       END LOOP;

       IF v_cargo_energy IS NULL THEN
         FOR curStorage IN c_storage(p_lifting_account_id, p_daytime, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
           v_storage_id := curStorage.object_id;
         END LOOP;

         --rygx changed from mass based GCV to volume based GCV, hence removed the calculation of mass
         --Note that the returned value is a metric Energy (GJ), and needs to be converted to MMBTU
         --for consistency across all balancing equations.

         RETURN (NVL(ecdp_unit.convertValue(getAccEstLiftedQtyDay(p_lifting_account_id, p_daytime, p_xtra_qty) *
           ec_strm_reference_value.gcv(ec_stor_version.plan_object_id(v_storage_id,p_daytime,'<='),p_daytime,'<='),'GJ','MMBTU',p_daytime,10), 0));

       ELSE
         RETURN(NVL(v_cargo_energy,0));
       END IF;

    END getAccEstLiftedEnergyDay;



    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccEstLiftedQtySubDay
    -- Description    : Returns the total lifted quantity for the prevoius hours of the day for selected lifting account
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
    FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting_actual(cp_lifting_account_id VARCHAR2, cp_startdate DATE, cp_enddate DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (--Find all cargos nomintated in the future
                    SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) between cp_startdate and cp_enddate
                    AND    c.cargo_no(+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    --Find all cargos nomintated in the past, assume BL date + quantites
                    SELECT NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                               ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty)) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) between cp_startdate and cp_enddate
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_lifting(cp_lifting_account_id VARCHAR2, cp_startdate DATE, cp_enddate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty
            FROM   (SELECT NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty),
                                   ecbp_storage_lift_nomination.calcNomSplitQty(ns.parcel_no, ns.company_id, ns.lifting_account_id, cp_xtra_qty)),
                               NVL(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty),
                                   decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3))) lifted_qty
                    FROM   storage_lift_nomination n, cargo_transport c, storage_lift_nom_split ns
                    WHERE  NVL(ns.lifting_account_id, n.lifting_account_id) = cp_lifting_account_id
                    AND    ns.parcel_no (+) = n.parcel_no
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) between cp_startdate and cp_enddate
                    AND    c.cargo_no (+) = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status (+) <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status(+),'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    ) a;

        ln_lifted_qty NUMBER;
        lv_incl_sysdate VARCHAR2(1);

    BEGIN

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');

        IF nvl(lv_incl_sysdate, 'Y') = 'Y' THEN
            FOR curLifted IN c_lifting_actual(p_lifting_account_id, p_startdate, p_enddate, TRUNC(ecdp_date_time.getCurrentSysdate), p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
             END LOOP;
        ELSE
            FOR curLifted IN c_lifting(p_lifting_account_id, p_startdate, p_enddate, p_xtra_qty) LOOP
                ln_lifted_qty := curLifted.lifted_qty;
            END LOOP;
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
    FUNCTION getEstLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_object_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(lifted_qty2) lifted_qty2, SUM(lifted_qty3) lifted_qty3
            FROM   (SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) >= cp_from_date
                    AND    nvl(n.bl_date, n.nom_firm_date) < cp_to_date
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status  <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
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
    FUNCTION getEstLiftedQtyDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_lifting(cp_object_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted_qty) lifted_qty, SUM(lifted_qty2) lifted_qty2, SUM(lifted_qty3) lifted_qty3
            FROM   (SELECT nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated) lifted_qty,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated2) lifted_qty2,
                           nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), n.grs_vol_nominated3) lifted_qty3
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_object_id
                    AND    nvl(n.bl_date, n.nom_firm_date) = cp_daytime
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
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

---------------------------------------------------------------------------------------------------
-- Function       : adjustLoadRateForPC
-- Description    : Artificially adjusts loading rates to account for purge/cooling volumes
--
-- Returns a loading rate that will consume the Nominted Volume and the PC Volume together in the same
-- amount of time that the input loading rate would have consumed only the Nominated Volume
---------------------------------------------------------------------------------------------------
FUNCTION adjustLoadRateForPC(p_vol NUMBER,
                             p_purge_cool_vol NUMBER,
                             p_loading_rate NUMBER) RETURN NUMBER
IS
    ln_vol NUMBER;

BEGIN

    IF (p_vol IS NULL OR p_vol = 0) THEN
        ln_vol := 1;
    ELSE
        ln_vol := p_vol;
    END IF;

    RETURN p_loading_rate * (p_vol + NVL(p_purge_cool_vol, 0)) / ln_vol;
END adjustLoadRateForPC;
---------------------------------------------------------------------------------------------------
-- Function       : adjForDayEndNotLifted
-- Description    : Calculate loading for crossing day scenario based on actual observed quantities
--                  (from Day End Not Lifted)
---------------------------------------------------------------------------------------------------
FUNCTION adjForDayEndNotLifted( p_cargo_no NUMBER,
                            p_start DATE,
                            p_end DATE) RETURN NUMBER
IS
    v_min_value NUMBER;
    v_max_value NUMBER;
    v_return_value NUMBER;

BEGIN

    -- For the date range selected:
    -- How much had been loaded before we started? (v_min_value)
    -- How much was loaded when we finished? (v_max_value)
    -- The difference between these two will be the amount loaded within this specific time frame
    SELECT MIN(exported_qty), MAX(exported_qty) INTO v_min_value, v_max_value
    FROM
    (
        SELECT daytime, exported_qty
        FROM dv_stor_day_export_status
        WHERE cargo_no = p_cargo_no
        UNION ALL
        SELECT max(bl_date) daytime, sum(ecbp_storage_lift_nomination.getliftedvol(parcel_no)) exported_qty
        FROM storage_lift_nomination
        WHERE cargo_no = p_cargo_no
        UNION ALL
        SELECT min(nom_firm_date) - 1 AS daytime, 0 AS exported_qty
        FROM storage_lift_nomination
        WHERE cargo_no = p_cargo_no
        AND ecbp_storage_lift_nomination.getliftedvol(parcel_no) IS NOT NULL
    )
    WHERE daytime >= p_start - 1
    AND daytime <= p_end;

    v_return_value := v_max_value - v_min_value; -- DO NOT NVL or this will screw up some future NVLs in other queries

    RETURN v_return_value;

END adjForDayEndNotLifted;

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
FUNCTION adjForLoadingRate( p_vol NUMBER,
                            p_purge_cool_vol NUMBER,
                            p_non_firm_date_time DATE,
                            p_start DATE,
                            p_end DATE,
                            p_load_rate NUMBER DEFAULT 1,
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

    ln_total_volume NUMBER := p_vol + nvl(p_purge_cool_vol, 0); -- The total volume to consume in the cargo
    ln_adjusted_loading_rate NUMBER := adjustLoadRateForPC(p_vol, p_purge_cool_vol, p_load_rate); -- The adjusted loading rate accounting for PC vol

BEGIN
--the first time the system is setting the opening DIP, the Start date will be always set to when the last avaialble DIP for the Tank
--then it set the end_date to as per From Date in the screen
--when it gets the first record, then the system will keep on calling this pakcage by passing in the same from and to date from the screen.
--to handle both scenario, we need to check to see whether the passed in p_end same as trunc(p_Non_Firm_date_time)
--if it is same then that means it is NOT the first time to call this package, hence we can safely calculate the cross day rate
--if the p_end is NOt equal to the trunc(p_Non_Firm_date_time), this means that this is the first round to calculate the Tank DIP
--so no need to calculate for the cross day
    IF ln_total_volume IS NULL OR ln_total_volume = 0 THEN
        RETURN 0;
    ELSE
        --ld_calc_end_date_time := ((p_Vol/p_rate)/24) + p_Non_Firm_date_time;
        ld_calc_end_date_time := ((ln_total_volume/ln_adjusted_loading_rate)/24) + p_Non_Firm_date_time;

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

        RETURN (ld_adj_nom_end - ld_adj_nom_start) * 24 * ln_adjusted_loading_rate;
    END IF;
END adjForLoadingRate;

FUNCTION calcSumOutOrInForADay(p_storage_id VARCHAR2,
                        p_daytime DATE,
                        p_plan VARCHAR2 DEFAULT 'PO',
                        p_xtra_qty NUMBER DEFAULT 0,
            p_type VARCHAR2 DEFAULT 'OUT')
RETURN NUMBER
IS
    lv_FC1 VARCHAR2(32):= EC_STOR_VERSION.OP_FCTY_CLASS_1_ID(p_storage_id,p_daytime,'<=');
    lv_offset NUMBER:= nvl(ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET('FCTY_CLASS_1',lv_FC1,p_daytime),0) /24;

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
/*
        CURSOR c_sum_out_actual(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_sysdate DATE, cp_xtra_qty NUMBER, cp_LoadingRate NUMBER) IS
            SELECT SUM(lifted) lifted_qty
            FROM   (SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE,cp_start,cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate) ))
                          ) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status  <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date > cp_sysdate
                    AND
                    (
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) >= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )<= cp_end)
                    OR
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) <= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )>= cp_end)
                    OR
                        (cp_start <> cp_end AND nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) >= cp_start
                        AND nvl(n.bl_date,TRUNC(n.START_LIFTING_DATE) )<= cp_end)
                    )
                    UNION ALL
                    SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE, cp_start,cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate) ))
                                  ) lifted
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.nom_firm_date >= cp_start
                    AND    n.nom_firm_date <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    SELECT ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status  <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.nom_firm_date <= cp_sysdate
                    AND
                    (
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) >= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )<= cp_end)
                    OR
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) <= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )>= cp_end)
                    OR
                        (cp_start <> cp_end AND nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) >= cp_start
                        AND nvl(n.bl_date,TRUNC(n.START_LIFTING_DATE) )<= cp_end)
                    )
                    ) a;

        CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER, cp_LoadingRate NUMBER) IS
            SELECT SUM(lifted) lifted_qty
            FROM   (SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  --Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), n.grs_vol_nominated)
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE, (n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24),cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate) ))
                                  ) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status  <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND TRUNC(N.START_LIFTING_DATE) <= cp_start
                    AND TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24))>= cp_end
                    --AND    nvl(n.bl_date, n.nom_firm_date) >= cp_start
                    --AND    nvl(n.bl_date, n.nom_firm_date) <= cp_end
                    UNION ALL
                    SELECT decode(cp_xtra_qty,
                                  1,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2),
                                  2,
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3),
                                  Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 0), adjForLoadingRate(n.grs_vol_nominated,N.START_LIFTING_DATE, cp_start,cp_end,COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate) ))) lifted
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND
                    (
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) >= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )<= cp_end)
                    OR
                        (nvl(n.bl_date,TRUNC(N.START_LIFTING_DATE)) <= cp_start
                        AND nvl(n.bl_date,TRUNC((n.START_LIFTING_DATE+(N.grs_vol_nominated/COALESCE(ec_cargo_transport.VALUE_6(n.cargo_no),cp_LoadingRate))/24)) )>= cp_end)
                    )
                    ) a;
*/

    ln_qty NUMBER :=-0;
    ln_LoadingRate NUMBER;
    lv2_forecast_type VARCHAR2(32) := ec_stor_version.text_10(p_storage_id, p_daytime, '<=');
    lv_incl_sysdate VARCHAR2(1) := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
    ld_today DATE:= TRUNC(ecdp_date_time.getCurrentSysdate);
BEGIN

select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',p_daytime,'<=')) into ln_LoadingRate from dual;

IF p_type = 'OUT' THEN
            IF lv_incl_sysdate = 'Y' THEN
                FOR curOut IN c_sum_out(p_storage_id, p_daytime, p_daytime, p_xtra_qty, ln_LoadingRate, lv_offset, ld_today) LOOP
                    ln_qty := curOut.lifted_qty;
                END LOOP;
            ELSE
                FOR curOut IN c_sum_out(p_storage_id, p_daytime, p_daytime, p_xtra_qty , ln_LoadingRate, lv_offset, NULL) LOOP
                    ln_qty := curOut.lifted_qty;
                END LOOP;
            END IF;
ELSE
            IF lv2_forecast_type IS NULL OR lv2_forecast_type = 'TRAN_PCTR_FCAST' THEN
                FOR curIn IN c_sum_in(p_storage_id, p_daytime, p_daytime) LOOP
                    IF nvl(p_plan, 'PO') = 'PO' THEN
                        IF P_XTRA_QTY = 1 THEN
                            ln_qty := curIn.op2;
                        ELSIF P_XTRA_QTY = 2 THEN
                            ln_qty := curIn.op3;
                        ELSE
                            ln_qty := curIn.op;
                        END IF;
                    ELSIF p_plan = 'A' THEN
                        ln_qty := curIn.PLAN_A;
                    ELSIF p_plan = 'B' THEN
                        ln_qty := curIn.PLAN_B;
                    ELSIF p_plan = 'C' THEN
                        ln_qty := curIn.PLAN_C;
                    END IF;
                END LOOP;
            ELSE
                ln_qty := NVL(Ue_Storage_Plan.calcAggregateStoragePlan(p_storage_id, p_daytime, p_daytime + 1), 0);
            END IF;
END IF;

RETURN NVL(ln_qty,0);

END calcSumOutOrInForADay;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcStorageLevel
    -- Description    : Gets the storage level for a date based on planned/official production.
    --                  The 'plan' parameter can be
    --          PO, A, B; C
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : stor_day_forecast,  stor_day_official, stor_period_export_status, storage_nomination
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
    FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_daytime DATE, p_plan VARCHAR2 DEFAULT 'PO', p_xtra_qty NUMBER DEFAULT 0, p_super_cache_flag VARCHAR2 DEFAULT 'NO') RETURN NUMBER
    --</EC-DOC>
     IS

    lv_FC1 VARCHAR2(32):= EC_STOR_VERSION.OP_FCTY_CLASS_1_ID(p_storage_id,p_daytime,'<=');
    lv_offset NUMBER:= nvl(ECDP_PRODUCTIONDAY.GETPRODUCTIONDAYOFFSET('FCTY_CLASS_1',lv_FC1,p_daytime),0) /24;

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

        CURSOR c_tank_meas(cp_storage_id VARCHAR2, cp_measurement_event_type VARCHAR2, cp_daytime DATE) IS
            SELECT Trunc(Max(tm.daytime)) last_day
            FROM   tank_measurement tm, tank_usage tu
            WHERE  tu.object_id = cp_storage_id
            AND    tu.daytime <= cp_daytime
            AND    Nvl(tu.end_date, cp_daytime + 1) > cp_daytime
            AND    tm.object_id = tu.tank_id
            AND    tm.daytime <= cp_daytime
                  --AND tm.measurement_event_type = cp_measurement_event_type
            AND    (nvl(grs_dip_level, 0) + nvl(grs_vol, 0) + nvl(grs_mass, 0) + nvl(net_vol, 0) + nvl(net_mass, 0) + nvl(net_vol_avail, 0) + nvl(net_mass_avail, 0) + nvl(tank_level, 0) + nvl(tank_level_m3, 0) + nvl(tank_level_pct, 0) +
                  nvl(grs_vol_nsc, 0) + nvl(closing_energy, 0)) > 0;

        ld_StartDate DATE;
        ld_EndDate   DATE;
        ld_today     DATE;
        ln_Dip       NUMBER;
        lnTotalIn    NUMBER;
        lnTotalOut   NUMBER;
        ln_ExpQty    NUMBER;
        lv_condition VARCHAR2(32);
        lv_group     VARCHAR2(32);
        lv_prev_object_id storage.object_id%type;
        lv_prev_qty  NUMBER;
        lv_prev_date DATE;
        lb_Dip       BOOLEAN;
        lv_incl_sysdate VARCHAR2(1);
       --TLXT
    ln_LoadingRate NUMBER;
    --this needs to be decided later
       --END EDIT TLXT

        lv2_forecast_type VARCHAR2(32) := ec_stor_version.text_10(p_storage_id, p_daytime, '<=');
    BEGIN

        /*****************************
        INIT GLOBAL VARS
        */
        ld_today := TRUNC(ecdp_date_time.getCurrentSysdate);
        --ld_today := TO_DATE('2014-08-10','YYYY-MM-DD') ;--TRUNC(ecdp_date_time.getCurrentSysdate);
        --ld_today := COALESCE(TO_DATE(EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_TEXT(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY','CE_BGPA'),SYSDATE,'COMMERCIAL_ENTITY','EFFDAY','<='),'YYYY-MM-DD"T"HH24:MI:SS') ,TRUNC(ecdp_date_time.getCurrentSysdate));
        lb_Dip   := FALSE;
        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');
        -- select ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate') from dual
        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',p_daytime,'<=')) into ln_LoadingRate from dual;

        IF gv_prev_QTY IS NULL THEN
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

        IF gv_prev_QTY2 IS NULL THEN
            gv_prev_object_id2 := '0';
            gv_prev_QTY2  := 0;
            gv_prev_DATE2 := TO_DATE('1900-01-01', 'YYYY-MM-dd');
        END IF;

        IF gv_prev_QTY3 IS NULL THEN
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
        END LOOP;
        --check if lates dip is for requested date?
        IF ld_StartDate = p_daytime THEN
            ln_Dip := getStorageDip(p_storage_id, p_daytime, lv_condition, lv_group, 'CLOSING'); --+0.000001; -- get tank_dip for requested date
            lb_Dip := TRUE;
            --ld_StartDate:=ld_StartDate+1; --to avoid run down (but include exported not lifted)
        ELSE
            --Check if p_daytime (current calc date) is in the future AND prev_date is the day before p_daytime
            IF (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime, 'DD') = 0) THEN
                --prev_date and p_daytime is identical and in the future
                RETURN NVL(lv_prev_qty, 0); --+0.0001;
            ELSIF (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime - 1, 'DD') = 0) THEN
                --prev_date is the day before p_daytime and in the future
                ld_StartDate := p_daytime;
                ln_dip       := NVL(lv_prev_qty, 0); --+0.001;
            ELSIF (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (p_super_cache_flag = 'YES') AND (lv_prev_date < p_daytime) THEN
                --prev_date is the day before p_daytime and in the future
                ld_StartDate := lv_prev_date + 1;
                ln_dip       := NVL(lv_prev_qty, 0); --+0.001;
            ELSE
                --do full calc from last known dip (ld_StartDate), if ld_StartDate is NULL, then start for the beginning of time
                if ld_StartDate is not null then
                    ln_dip := getStorageDip(p_storage_id, ld_StartDate, lv_condition, lv_group, 'CLOSING');

                    IF Nvl(ln_Dip, 0) > 0 THEN
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
        --SWGN Commented out to resolve issue with data caching
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
            -- SWGN: Changed to calculate from Ue_Storage_Balanc
            IF lv2_forecast_type IS NULL OR lv2_forecast_type = 'TRAN_PCTR_FCAST' THEN
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
            ELSE
                lnTotalIn := NVL(Ue_Storage_Plan.calcAggregateStoragePlan(p_storage_id, ld_StartDate, ld_EndDate + 1), 0);
            END IF;


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
                FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, ld_EndDate, p_xtra_qty, ln_LoadingRate, lv_offset, ld_today) LOOP
                    lnTotalOut := curOut.lifted_qty;
                END LOOP;
            ELSE
                FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, ld_EndDate, p_xtra_qty, ln_LoadingRate, lv_offset, NULL) LOOP
                lnTotalOut := curOut.lifted_qty;
            END LOOP;
            END IF;

            IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
                ln_dip := nvl(ln_Dip, 0) - Nvl(lnTotalIn, 0) + Nvl(lnTotalOut, 0);
            ELSE
                ln_dip := nvl(ln_Dip, 0) + Nvl(lnTotalIn, 0) - Nvl(lnTotalOut, 0);
            END IF;
        End if;

        /*****************************
        SAVE GLOBAL VARS FOR NEXT ITERATION
        */
        --STORE current calc'ed storage level for next iteration
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

        return ln_dip;
    END calcStorageLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSingleStorageLevel
-- Description    : Calculates the storage level graph for a single parcel. Caches the result into a global temporary table to improve performance.
--                  Generally it is advised to avoid global temporary tables; this is done to improve performance (>5 minutes goes down to 10 seconds!!)
---------------------------------------------------------------------------------------------------
FUNCTION getSingleStorageLevel(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_open_close VARCHAR2)
RETURN UE_CT_STORAGE_GRAPH_POINT
IS

    PRAGMA AUTONOMOUS_TRANSACTION; -- Necessary to be able to be called within the context of a query

    v_sysdate DATE := sysdate;
    v_item_no NUMBER := nvl(ec_storage_lift_nomination.cargo_no(p_parcel_no), p_parcel_no);

    CURSOR CACHED_RESULTS IS
    SELECT *
    FROM T_CT_STORAGE_GRAPH
    WHERE ITEM_NO = v_item_no
    AND EVENT_TYPE = 'CARGO_' || p_open_close
    AND OBJECT_ID = p_storage_id
    AND FORECAST_ID IS NULL -- Only look for results in the mainline
    AND LOADED_DATE > v_sysdate - 10 / (24 * 60 * 60); -- This represents a cache lifespan of 10 seconds; records older than this won't be counted

    v_return_row UE_CT_STORAGE_GRAPH_POINT := new UE_CT_STORAGE_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);

BEGIN

    -- Look in the cache
    FOR item IN cached_results LOOP
        v_return_row.object_id := item.object_id;
        v_return_row.daytime := item.daytime;
        v_return_row.storage_level := item.storage_level;
        v_return_row.event_type := item.event_type;
    END LOOP;

    -- If the answer is not in the cache
    IF v_return_row.storage_level IS NULL THEN

        -- Possibly redundant delete; done to make sure that the results aren't just "old"
        DELETE FROM t_ct_storage_graph WHERE object_id = p_storage_id AND forecast_id IS NULL;

        -- Query the entire forecast, put the result into the cache
        INSERT INTO t_ct_storage_graph  (OBJECT_ID, FORECAST_ID, DAYTIME, ITEM_NO, EVENT_TYPE, STORAGE_LEVEL, LOADED_DATE)
        SELECT object_id, NULL, daytime, NULL, event_type, storage_level, v_sysdate
        FROM table(calcStorageLevelTable(p_storage_id, (select MAX(daytime) + 1 from tank_measurement), (select MAX(nom_firm_date) + 1 FROM storage_lift_nomination), NULL, 'OPEN'));

        -- Get the result from the cache
        FOR item IN cached_results LOOP
            v_return_row.object_id := item.object_id;
            v_return_row.daytime := item.daytime;
            v_return_row.storage_level := item.storage_level;
            v_return_row.event_type := item.event_type;
        END LOOP;

    END IF;

    -- If we still don't have a result, something went wrong
    IF v_return_row.storage_level IS NULL THEN

        -- We can't raise an application error here. On the Forecast side, we can assume that we should always find a parcel. Here, there are enough edge cases for cargoes right around the current
        -- date where it's possible that a tank measurement could have been entered ahead of time and accidentally affected filtering of queries. So we just put an entry in temptext and return null
        --ECDP_DYNSQL.writetemptext('UE_TRANS_STORAGE_BALANCE', 'Could never retrieve results for parcel ' || p_parcel_no || ', operation ' || p_open_close || ' on sysdate ' || to_char(ecdp_date_time.getcurrentsysdate, 'DD-MON-YYYY HH24:MI:SS'));
        v_return_row := new UE_CT_STORAGE_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);

    END IF;

    COMMIT;
    RETURN v_return_row;

END getSingleStorageLevel;

    FUNCTION calcStorageLevelTable(p_storage_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_parcel_no NUMBER DEFAULT NULL, p_open_close VARCHAR2 DEFAULT 'OPEN')
    RETURN UE_CT_STORAGE_GRAPH_COLL PIPELINED
    IS

        CURSOR c_unit(cp_event VARCHAR2) IS
            SELECT m.item_condition, c.unit, c.uom_group
            FROM   lifting_measurement_item m, product_meas_setup s, stor_version v, ctrl_unit c
            WHERE  m.item_code = s.item_code
            AND    s.lifting_event = cp_event
            AND    s.nom_unit_ind = 'Y'
            AND    s.object_id = v.product_id
            AND    v.daytime <= p_daytime
            AND    Nvl(v.end_date, p_daytime + 1) > p_daytime
            AND    v.object_id = p_storage_id
            AND    m.unit = c.unit;

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
           LEAD(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS NEXT_INDICATOR, -- What is the "indicator" of the next record?
           INDICATOR,
           LAG(INDICATOR, 1, 'DAY_OPEN') OVER (ORDER BY DAYTIME, INDICATOR) AS PREV_INDICATOR, -- What was the "indicator" of the last record
           STORAGE_RATE + SUM(DECODE(INDICATOR,'DAY_OPEN',0,'CARGO_OPEN',-LOADING_RATE,'CARGO_CLOSE',LOADING_RATE)) OVER (ORDER BY DAYTIME) AS HOURLY_RATE -- What is the net production rate for this record?
           FROM
           (
                -- Query part A (INDICATOR = "CARGO_OPEN")
                SELECT NOM.OBJECT_ID AS OBJECT_ID,
                CASE WHEN MAX(NOM.START_LIFTING_DATE) < cp_start_date AND MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_1(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24) > cp_start_date
                    THEN cp_start_date ELSE MAX(NOM.START_LIFTING_DATE) END AS DAYTIME,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_OPEN' AS INDICATOR,
                ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), MAX(NOM.NOM_FIRM_DATE), SYSDATE, NULL, NULL) / 24 AS STORAGE_RATE,
                --ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_6(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24)), SYSDATE, NULL, NULL) / 24  AS STORAGE_RATE,
                COALESCE(ec_cargo_transport.VALUE_1(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate) AS LOADING_RATE
                FROM STORAGE_LIFT_NOMINATION NOM
                WHERE NOM.OBJECT_ID = p_storage_id
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                -- Query part B (INDICATOR = "CARGO_CLOSE")
                SELECT NOM.OBJECT_ID AS OBJECT_ID,
                MAX(NOM.START_LIFTING_DATE) + ((SUM(COALESCE(
            DECODE (
             ecdp_objects.getobjcode (NOM.object_id),
             'STW_COND', EC_STORAGE_LIFTING.LOAD_VALUE (
                            NOM.PARCEL_NO,
                            (SELECT PRODUCT_MEAS_NO
                               FROM DV_PROD_MEAS_SETUP
                              WHERE     LIFTING_EVENT = 'LOAD'
                                    AND MEAS_ITEM = 'LIFT_COND_VOL_NET')),
             EC_STORAGE_LIFTING.LOAD_VALUE (
                NOM.PARCEL_NO,
                (SELECT PRODUCT_MEAS_NO
                   FROM DV_PROD_MEAS_SETUP
                  WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_NET_M3'))),
                NOM.GRS_VOL_NOMINATED))
                / COALESCE(ec_cargo_transport.VALUE_1(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24) AS DAYTIME,
                NVL(NOM.CARGO_NO, NOM.PARCEL_NO) AS ITEM_NO,
                'CARGO_CLOSE' AS INDICATOR,
                ue_storage_plan.calcdailystorageplan(MAX(NOM.OBJECT_ID), TRUNC(MAX(NOM.START_LIFTING_DATE) + ((SUM(NOM.GRS_VOL_NOMINATED) / COALESCE(ec_cargo_transport.VALUE_1(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate)) / 24)), SYSDATE, NULL, NULL) / 24  AS STORAGE_RATE,
                COALESCE(ec_cargo_transport.VALUE_1(MAX(NOM.CARGO_NO)),EC_CARRIER_VERSION.LOADING_RATE(MAX(NOM.CARRIER_ID), MAX(NOM.START_LIFTING_DATE), '<='), cp_loading_rate) AS LOADING_RATE
                FROM STORAGE_LIFT_NOMINATION NOM
                WHERE NOM.OBJECT_ID = p_storage_id
                AND NOM.NOM_FIRM_DATE >= cp_start_date - 2
                AND NOM.NOM_FIRM_DATE <= cp_end_date
                AND ECBP_CARGO_STATUS.GETECCARGOSTATUS(COALESCE(EC_CARGO_TRANSPORT.CARGO_STATUS(NOM.CARGO_NO), 'O')) <> 'D'
                GROUP BY NOM.OBJECT_ID, NVL(NOM.CARGO_NO, NOM.PARCEL_NO)

                UNION ALL

                -- Query part A (INDICATOR = "CARGO_CLOSE")
                SELECT GRAPH.OBJECT_ID,
                GRAPH.DAYTIME,
                NULL AS ITEM_NO,
                'DAY_OPEN' AS INDICATOR,
                ue_storage_plan.calcdailystorageplan(GRAPH.OBJECT_ID, GRAPH.DAYTIME, SYSDATE, NULL, NULL) / 24 AS STORAGE_RATE,
                NULL AS LOADING_RATE
                FROM CV_STORAGE_GRAPH GRAPH
                WHERE GRAPH.OBJECT_ID = p_storage_id
                AND GRAPH.DAYTIME >= cp_start_date
                AND GRAPH.DAYTIME <= cp_end_date
                )
            WHERE OBJECT_ID = p_storage_id
            AND DAYTIME >= cp_start_date
            AND DAYTIME <= cp_end_date
            AND NOT (INDICATOR = 'CARGO_CLOSE' AND DAYTIME = cp_start_date)
            ORDER BY DAYTIME, INDICATOR;

        v_return_row UE_CT_STORAGE_GRAPH_POINT;
        v_temp_level NUMBER;
        v_item_number NUMBER := NVL(ec_storage_lift_nomination.cargo_no(p_parcel_no), p_parcel_no);
        v_start_date DATE;
        v_end_date DATE;

        v_condition VARCHAR2(32);
        v_group VARCHAR2(32);
    v_loading_rate NUMBER;
    v_contract_code VARCHAR2(32);
    BEGIN

        FOR item IN c_unit('LOAD') LOOP
           v_condition := item.item_condition;
           v_group     := item.uom_group;
        END LOOP;
/*
        -- Is this a parcel point in the past?
        IF p_parcel_no IS NOT NULL AND ec_storage_lift_nomination.START_LIFTING_DATE(p_parcel_no) < sysdate THEN
            v_return_row := new UE_CT_STORAGE_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            PIPE ROW (v_return_row);
            RETURN;
        END IF;
*/
        -- Get the return record
        v_return_row := new UE_CT_STORAGE_GRAPH_POINT(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        v_return_row.object_id := p_storage_id; -- ue_trans_storage_balance
        v_return_row.event_type := 'DAY_OPEN';
        v_return_row.daytime := p_daytime;
        v_start_date := p_daytime;
        v_end_date := p_end_date;

        -- Are we cached?
        IF p_parcel_no IS NOT NULL THEN
            v_start_date := ec_storage_lift_nomination.nom_firm_date(p_parcel_no) - 1;
            v_end_date := v_start_date + 3;
            v_return_row.daytime := v_start_date;
            v_return_row.storage_level := calcStorageLevel(p_storage_id, v_start_date - 1);
        ELSE
            -- Set the initial storage level
            v_return_row.storage_level := calcStorageLevel(p_storage_id, p_daytime);

        END IF;

        -- Do we return the opening storage level?
        IF p_daytime = v_return_row.daytime THEN
            PIPE ROW (v_return_row);
        END IF;
    -- LBFK - START
    -- Get Loading Rate from contract attributes
    select DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND') into v_contract_code from dual;
    v_loading_rate := ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', v_contract_code),'LOADING_RATE',v_start_date,'<=');

        FOR item IN event_storage_graph(v_start_date, v_end_date,v_loading_rate) LOOP
            v_return_row.daytime := item.next_daytime;

            IF v_return_row.daytime = trunc(v_return_row.daytime) THEN
                v_temp_level := NVL(getStorageDip(p_storage_id, v_return_row.daytime, v_condition, v_group, 'OPENING'),0);
                IF v_temp_level = 0 THEN
                    v_return_row.storage_level := v_return_row.storage_level + (item.duration_hrs * item.hourly_rate);
                    v_return_row.event_type := item.NEXT_INDICATOR;
                ELSE
                    v_return_row.storage_level := v_temp_level;
                    v_return_row.event_type := 'DAY_OPEN';
                END IF;
            ELSE
                v_temp_level := NVL(getStorageDip(p_storage_id, trunc(v_return_row.daytime) + 1, v_condition, v_group, 'OPENING'),0);
                IF v_temp_level <> 0 THEN
                    v_temp_level := -999999;
                    v_return_row.storage_level := v_return_row.storage_level + (item.duration_hrs * item.hourly_rate);
                ELSE
                    v_return_row.storage_level := v_return_row.storage_level + (item.duration_hrs * item.hourly_rate);
                    v_return_row.event_type := item.NEXT_INDICATOR; --UE_TRANS_STORAGE_BALANCE
                END IF;
            END IF;

            IF (v_temp_level <> -999999) THEN

                IF p_parcel_no IS NULL THEN
                    IF v_return_row.daytime >= p_daytime AND v_return_row.daytime <= p_end_date+1  AND item.duration_hrs > 0 THEN
                        PIPE ROW (v_return_row);
                    END IF;
                END IF;
            END IF;
--TLXT
            IF p_parcel_no IS NOT NULL AND item.NEXT_INDICATOR = 'CARGO_' || p_open_close THEN
                v_return_row.event_type := item.NEXT_INDICATOR;
                PIPE ROW (v_return_row);
                RETURN;
            END IF;
--END EDIT

        END LOOP;

    END calcStorageLevelTable;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcStorageLevelSubDay
    -- Description    : Gets the storage level for a date based on planned/official production.
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : stor_sub_day_forecast,  stor_sub_day_official, storage_nomination
    --
    -- Using functions: calcStorageLevel, EcDp_ProductionDay.getProductionDay
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
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

        CURSOR c_sum_out_actual(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_sysdate DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty
            FROM   (SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) >= cp_start
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.START_LIFTING_DATE >= cp_start
                    AND    n.START_LIFTING_DATE <= cp_end
                    AND    n.nom_firm_date > cp_sysdate
                    UNION ALL
                    SELECT ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    n.DATE_9 >= cp_start
                    AND    n.DATE_9 <= cp_end
                    AND    n.nom_firm_date <= cp_sysdate) a;

        CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER) IS
            SELECT SUM(lifted) lifted_qty
            FROM   (SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted
                    FROM   storage_lift_nomination n, cargo_transport c
                    WHERE  n.object_id = cp_storage_id
                    AND    c.cargo_no = n.cargo_no
                    --tlxt: to ensure all cancel status with Alt code 'D' got pickuped
                    --AND    c.cargo_status <> 'D'
                    AND    NVL(EC_PROSTY_CODES.ALT_CODE(c.cargo_status,'TRAN_CARGO_STATUS'), 'XX') <> 'D'
                    --end edit
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) >= cp_start
                    AND    nvl(n.DATE_9, n.START_LIFTING_DATE) <= cp_end
                    UNION ALL
                    SELECT Nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, cp_xtra_qty), decode(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) lifted
                    FROM   storage_lift_nomination n
                    WHERE  n.object_id = cp_storage_id
                    AND    n.cargo_no IS NULL
                    AND    n.START_LIFTING_DATE >= cp_start
                    AND    n.START_LIFTING_DATE <= cp_end) a;

        ld_today          DATE;
        ld_startDate      DATE;
        ln_Dip            NUMBER;
        lnTotalIn         NUMBER;
        lnTotalOut        NUMBER;
        ld_production_day DATE;
        lv_summer_flag    VARCHAR2(32);
        lv_incl_sysdate   VARCHAR2(1);

    BEGIN
        ld_production_day := EcDp_ProductionDay.getProductionDay('STORAGE', p_storage_id, p_daytime, p_summer_time);
        ld_startDate      := EcDp_ProductionDay.getProductionDayStart('STORAGE', p_storage_id, ld_production_day);
        ld_today          := TRUNC(ecdp_date_time.getCurrentSysdate);

        lv_incl_sysdate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sysdate');

        -- get opening balance of the day
        ln_Dip := calcStorageLevel(p_storage_id, ld_production_day - 1, NULL, p_xtra_qty);

        --checking the summer time flag
        FOR curIn IN c_sumerTime_flag(p_storage_id, ld_startDate, p_daytime) LOOP
            lv_summer_flag := curIn.summerFlag;
        END LOOP;

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
        END IF;

        -- get all nominations
        IF lv_incl_sysdate = 'Y' THEN
            FOR curOut IN c_sum_out_actual(p_storage_id, ld_StartDate, p_daytime, ld_today, p_xtra_qty) LOOP
            lnTotalOut := curOut.lifted_qty;
        END LOOP;
        ELSE
            FOR curOut IN c_sum_out(p_storage_id, ld_StartDate, p_daytime, p_xtra_qty) LOOP
                lnTotalOut := curOut.lifted_qty;
            END LOOP;
        END IF;

        IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
            RETURN ln_Dip - Nvl(lnTotalIn, 0) + Nvl(lnTotalOut, 0);
        ELSE
            RETURN ln_Dip + Nvl(lnTotalIn, 0) - Nvl(lnTotalOut, 0);
        END IF;

    END calcStorageLevelSubDay;

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
    -- Using functions: ecdp_date_time.getCurrentSysdate
    -- Configuration
    -- required       : p_loadType can be 'LOAD' or 'UNLOAD'
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getStorageLoadStatus(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2
    --</EC-DOC>
     IS
        ld_today  DATE;
        ld_msg    VARCHAR2(200);
        ld_msgTxt VARCHAR2(200);

    BEGIN
        ld_today := trunc(ecdp_date_time.getCurrentSysdate);

        IF p_nom_date <= ld_today AND nvl(p_qty, 0) = 0 AND nvl(p_cargo_status, 'xxx') != 'D' THEN
            ld_msg := 'verificationStatus=showStopper;';
            IF p_loadType = 'LOAD' THEN
                ld_msgTxt := 'verificationText=No Lifting Occured';
            ELSE
                ld_msgTxt := 'verificationText=No Unloading Occured';
            END IF;
        END IF;

        IF ld_msgTxt IS NOT NULL THEN
            RETURN ld_msg || ld_msgTxt;
        ELSE
            RETURN NULL;
        END IF;

    END getStorageLoadStatus;

FUNCTION get_sysdate
  RETURN DATE
IS
BEGIN
  IF EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_TEXT(EcDp_Objects.GetObjIDFromCode('COMMERCIAL_ENTITY', 'CE_BGPA'),
       SYSDATE,'COMMERCIAL_ENTITY','PSEUDO_SYSDATE','<=') = 'Y' THEN

       RETURN (
         NVL(TO_DATE(SUBSTR (
          EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_TEXT(EcDp_Objects.GetObjIDFromCode('COMMERCIAL_ENTITY', 'CE_BGPA'),
           SYSDATE,'COMMERCIAL_ENTITY','EFFDAY','<=')
             ,1,10),'YYYY-MM-DD'),SYSDATE)
              );

  ELSE
    RETURN(SYSDATE);
  END IF;

END get_sysdate;



END Ue_Trans_Storage_Balance;
/