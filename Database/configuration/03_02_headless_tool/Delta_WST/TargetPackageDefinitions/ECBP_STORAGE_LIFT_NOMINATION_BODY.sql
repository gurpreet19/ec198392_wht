CREATE OR REPLACE PACKAGE BODY EcBP_Storage_Lift_Nomination IS
  /******************************************************************************
  ** Package        :  EcBP_Storage_Lift_Nomination, body part
  **
  ** $Revision: 1.55.2.16 $
  **
  ** Purpose        :  Business logic for storage lift nominations
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 24.09.2004 Kari Sandvik
  **
  ** Modification history:
  **
  ** Version  Date     Whom  Change description:
  ** -------  ------   ----- -----------------------------------------------------------------------------------------------
  ** 1.1  01.03.2005 kaurrnar Removed references to ec_xxx_attribute packages
  ** 1.9  01.12.2005 skjorsti Added function getProratedMonthEnd(PARCEL_NO)
  ** 1.10 04.07.2006 naerlola   Added function getUnloadVol
  **      06.10.2006 chongjer Tracker 4490 - Updated getProratedMonthEnd to use stor_period_export_status
  **      18.10.2006 rajarsar Tracker 4635 - Updated deleteNomination Procedure with user exit function
          08.06.2007 embonhaf ECPD-5694 Modified cursor in getProratedMonthEnd
          12.08.2010 lauuufus ECPD-12065 Add newprocedure updateStorageLifting() and insertCargo()
          05.11.2011 meisihil ECPD-16443 Added Nomination Unit 3 (p_extra_qty = 2)
          13.02.2012 muhammah ECPD-19571:
                              -update PROCEDURE createUpdateSplit
                              -update FUNCTION getDefSplit
                              -update FUNCTION calcNomSplitQty
                              -added FUNCTION calcActualSplitQty
  **      28.02.2012 sharawan ECPD-20106 Modify function getNomUnit to accept object id instead of storage id and
  **                          this will cater for facility id units in case no storage is passed in.
  **      28.02.2012 muhammah ECPD-19571: update cursor c_split and c_split_all to check on end date; add c_daytime to function calcNomSplitQty and
  calcActualSplitQty
  **	  01.03.2012 muhammah ECPD-19571: update function createUpdateSplit removed checking for balance indicator
  **	  21.03.2012 leeeewei ECPD-20247: Updated function getNomUnit
  **	  12.09.2012 meisihil ECPD-20962: Added function getLoadBalDeltaVol
  **      15.01.2013 muhammah ECPD-23097 Add function: getLiftedVolByIncoterm
  **	  24.01.2013 meisihil ECPD-20056: Added functions aggrSubDayLifting, calcSubDayLifting, calcSubDayLiftingCargo, calcAggrSubDaySplitQty
  **                                      to support liftings spread over hours
  **	  24.01.2013 meisihil ECPD-20056: Updated funcions calcNomSplitQty and calcActualSplitQty to read the common calcSplitQty (new function added)
  **	  17.05.2013 chooysie ECPD-24107: Add facility class to insertCargo procedure
  ********************************************************************/

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getNomToleranceMinVol
  -- Description    : Returns the min volume for nominated tolerence limit for a storage lift nomination
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :                                                                                                                         --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getNomToleranceMinVol(p_parcel_no NUMBER) RETURN NUMBER
  --</EC-DOC>
   IS

  BEGIN
    RETURN ec_storage_lift_nomination.grs_vol_nominated(p_parcel_no) *(1 -
                                                                       (ec_tolerance_limit.min_qty_pct(ec_storage_lift_nomination.REQUESTED_TOLERANCE_TYPE(p_parcel_no)) / 100));
  END getNomToleranceMinVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getNomToleranceMaxVol
  -- Description    : Returns the max volume for nominated tolerence limit for a storage lift nomination
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
  FUNCTION getNomToleranceMaxVol(p_parcel_no NUMBER) RETURN NUMBER
  --</EC-DOC>
   IS

  BEGIN
    RETURN ec_storage_lift_nomination.grs_vol_nominated(p_parcel_no) *(1 +
                                                                       (ec_tolerance_limit.max_qty_pct(ec_storage_lift_nomination.REQUESTED_TOLERANCE_TYPE(p_parcel_no)) / 100));
  END getNomToleranceMaxVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftedVol
  -- Description    : Returns the lifted volume for a parcel
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
  FUNCTION getLiftedVol(p_parcel_no NUMBER, p_xtra_qty NUMBER, p_incl_unload VARCHAR2 DEFAULT 'Y') RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lifting(cp_parcel_no     NUMBER,
                          cp_xtra_qty      NUMBER,
                          cp_lifting_event VARCHAR2) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = cp_lifting_event
         AND ((p.nom_unit_ind = 'Y' and 0 = NVL(p_xtra_qty, 0)) or
             (p.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
             (p.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));
    lnLiftedVol   NUMBER;
    lsStorageType varchar2(32);

  BEGIN

    FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'LOAD') LOOP
      lnLiftedVol := curLifted.load_value;
    END LOOP;

    --check to see if unload value should be used (for IMPORT storage).
    lsStorageType := ec_stor_version.storage_type(ec_storage_lift_nomination.object_id(p_parcel_no),
                                                  nvl(ec_storage_lift_nomination.bl_date(p_parcel_no),
                                                      ec_storage_lift_nomination.nom_firm_date(p_parcel_no)),
                                                  '<=');

    if lnLiftedVol is null and lsStorageType = 'IMPORT' and p_incl_unload = 'Y' then
      FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'UNLOAD') LOOP
        lnLiftedVol := curLifted.load_value;
      END LOOP;
    end if;

    RETURN lnLiftedVol;

  END getLiftedVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getUnloadVol
  -- Description    : Returns the unloaded volume for a parcel
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
  FUNCTION getUnloadVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_unloading(cp_parcel_no NUMBER, cp_xtra_qty NUMBER) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = 'UNLOAD'
         AND ((p.nom_unit_ind = 'Y' and 0 = NVL(p_xtra_qty, 0)) or
             (p.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
             (p.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));

    lnUnloadVol NUMBER;

  BEGIN

    FOR curUnloaded IN c_stor_unloading(p_parcel_no, p_xtra_qty) LOOP
      lnUnloadVol := curUnloaded.load_value;
    END LOOP;

    RETURN lnUnloadVol;

  END getUnloadVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLoadBalDeltaVol
  -- Description    : Returns the actual balance delta volume for a parcel
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
  FUNCTION getLoadBalDeltaVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lift(cp_parcel_no NUMBER, cp_lifting_event VARCHAR2, cp_balance_delta_qty VARCHAR2) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = cp_lifting_event
         AND p.balance_qty_type = cp_balance_delta_qty;

    lnBalDeltaVol NUMBER;
    lv_balance_delta_qty VARCHAR2(32);
    lsStorageType varchar2(32);

  BEGIN
	IF p_xtra_qty = 1 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY2';
	ELSIF p_xtra_qty = 2 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY3';
	ELSE
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY';
	END IF;

    FOR c_cur IN c_stor_lift(p_parcel_no, 'LOAD', lv_balance_delta_qty) LOOP
      lnBalDeltaVol := c_cur.load_value;
    END LOOP;

     --check to see if unload value should be used (for IMPORT storage).
    lsStorageType := ec_stor_version.storage_type(ec_storage_lift_nomination.object_id(p_parcel_no),
                                                  nvl(ec_storage_lift_nomination.bl_date(p_parcel_no),
                                                      ec_storage_lift_nomination.nom_firm_date(p_parcel_no)),
                                                  '<=');

    if lnBalDeltaVol is null and lsStorageType = 'IMPORT' then
      FOR curLifted IN c_stor_lift(p_parcel_no, 'UNLOAD', lv_balance_delta_qty) LOOP
        lnBalDeltaVol := curLifted.load_value;
      END LOOP;
    end if;
   RETURN lnBalDeltaVol;

  END getLoadBalDeltaVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getUnloadBalDeltaVol
  -- Description    : Returns the balance delta volume for a parcel
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
  FUNCTION getUnloadBalDeltaVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lift(cp_parcel_no NUMBER, cp_lifting_event VARCHAR2, cp_balance_delta_qty VARCHAR2) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = cp_lifting_event
         AND p.balance_qty_type = cp_balance_delta_qty;

    lnBalDeltaVol NUMBER;
    lv_balance_delta_qty VARCHAR2(32);

  BEGIN
	IF p_xtra_qty = 1 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY2';
	ELSIF p_xtra_qty = 2 THEN
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY3';
	ELSE
		lv_balance_delta_qty := 'BALANCE_DELTA_QTY';
	END IF;

    FOR c_cur IN c_stor_lift(p_parcel_no, 'LOAD', lv_balance_delta_qty) LOOP
      lnBalDeltaVol := c_cur.load_value;
    END LOOP;

   RETURN lnBalDeltaVol;

  END getUnloadBalDeltaVol;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getNomUnit
  -- Description    : Gets the nominated unit set for product
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : product_meas_setup
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getNomUnit(p_object_id VARCHAR2, p_xtra_qty NUMBER, p_lifting_event VARCHAR2)
    RETURN VARCHAR2
  --</EC-DOC>
   IS

    CURSOR c_product_meas_setup(cp_storage_id VARCHAR2, cp_xtra_qty NUMBER, cp_lifting_event VARCHAR2) IS
      SELECT distinct (e.unit)
        FROM storage                  b,
             product                  c,
             product_meas_setup       d,
             LIFTING_MEASUREMENT_ITEM e
       WHERE b.object_id = cp_storage_id
         AND ec_stor_version.product_id(b.object_id, sysdate, '<=') =
             c.object_id
         AND -- obs sysdate(but better than object start date)
             c.object_id = d.object_id
         AND d.item_code = e.item_code
		 AND d.lifting_event = cp_lifting_event
         AND ((d.nom_unit_ind = 'Y' and 0 = p_xtra_qty) or
             (d.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
             (d.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));

    CURSOR c_fcty_storage(cp_storage_id VARCHAR2, cp_xtra_qty NUMBER) IS
      SELECT distinct (e.unit)
        FROM storage                  b,
             product                  c,
             product_meas_setup       d,
             LIFTING_MEASUREMENT_ITEM e,
             stor_version             g
       WHERE ec_stor_version.product_id(b.object_id, sysdate, '<=') =
             c.object_id
         AND -- obs sysdate(but better than object start date)
             c.object_id = d.object_id
         AND d.item_code = e.item_code
         AND b.object_id = g.object_id
         and g.op_fcty_class_1_id = cp_storage_id
         AND ((d.nom_unit_ind = 'Y' and 0 = p_xtra_qty) or
              (d.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
              (d.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));

    lv_unit     VARCHAR2(16);
    lv_objclass VARCHAR2(32);

  BEGIN

    lv_objclass := ecdp_objects.GetObjClassName(p_object_id);

    IF lv_objclass LIKE 'FCTY_CLASS_%' THEN
      FOR curFctyUnit IN c_fcty_storage(p_object_id, p_xtra_qty) LOOP
        IF lv_unit IS NOT NULL THEN
           RETURN NULL;
        ELSE
           lv_unit := curFctyUnit.unit;
        END IF;
      END LOOP;
    ELSE
      FOR curUnit IN c_product_meas_setup(p_object_id, p_xtra_qty, p_lifting_event) LOOP
        lv_unit := curUnit.unit;
      END LOOP;
    END IF;

    RETURN lv_unit;

  END getNomUnit;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getProratedMonthEnd
  -- Description    : Gets the prorated lifted value for one product for one parcel.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : storage_lift_nomination, cargo_transport, stor_period_export_status, lift_account_transaction
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getProratedMonthEnd(p_parcel_no NUMBER) RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_export_qty(cp_parcel_no NUMBER) IS
      SELECT e.export_qty, ROWNUM
        FROM cargo_transport           c,
             storage_lift_nomination   sln,
             stor_period_export_status e
       WHERE e.cargo_no = c.cargo_no
         AND c.cargo_no = sln.cargo_no
         and sln.object_id = e.object_id
         AND sln.parcel_no = cp_parcel_no
         and e.time_span = 'MTH';

    -- Lifted volume for each parcel on the same cargo as parameter parcel. (Volume of parcel sent as parameter is excluded from this selection)
    CURSOR c_volume(cp_parcel_no NUMBER,
                    cp_object_id VARCHAR2,
                    cp_cargo_no  VARCHAR2) IS
      SELECT SUM(l.load_value) debet
        FROM storage_lift_nomination n,
             storage_lifting         l,
             product_meas_setup      s
       WHERE cargo_no = cp_cargo_no
         AND n.parcel_no <> cp_parcel_no
         AND n.object_id = cp_object_id
         AND n.parcel_no = l.parcel_no
         AND l.product_meas_no = s.product_meas_no
         AND s.nom_unit_ind = 'Y'
         AND s.lifting_event = 'LOAD';

    ln_volume_curr NUMBER;
    ln_volume      NUMBER := 0;
    ln_export_qty  NUMBER;
    ln_count       NUMBER;
    ln_percent_vol NUMBER;
    ln_parcel_ex   NUMBER;
  BEGIN

    -- Retrieve export quantity
    FOR curQty IN c_export_qty(p_parcel_no) LOOP
      ln_export_qty := curQty.export_qty;
      ln_count      := curQty.rownum;
    END LOOP;

    IF (ln_export_qty IS NULL) THEN
      RETURN NULL;
    END IF;

    IF (ln_count > 1) THEN
      RAISE_APPLICATION_ERROR(-20325,
                              'More than one export quantity has been found on selected cargo/storage');
      RETURN NULL;
    END IF;

    -- Retrieve lifted value for current parcel
    ln_volume_curr := getLiftedVol(p_parcel_no);

    IF ln_volume_curr IS NULL THEN
      RETURN NULL;
    END IF;

    -- Retrieve lifted value for other parcels same cargo/storage
    FOR volume IN c_volume(p_parcel_no,
                           ec_storage_lift_nomination.object_id(p_parcel_no),
                           ec_storage_lift_nomination.cargo_no(p_parcel_no)) LOOP
      ln_volume := ln_volume + nvl(volume.debet, 0);
    END LOOP;

    -- Sum lifted volumes
    ln_volume := ln_volume + ln_volume_curr;

    -- Retrieve current parcel's percentage of exported quantity
    ln_percent_vol := (ln_volume_curr / ln_volume) * 100;
    ln_parcel_ex   := ln_export_qty -
                      ((ln_export_qty * (100 - ln_percent_vol)) / 100);

    RETURN ln_parcel_ex;

  END getProratedMonthEnd;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : expectedUnloadDate
  -- Description    : Returns the expected unload date for the parcel
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
  FUNCTION expectedUnloadDate(p_parcel_no NUMBER) RETURN DATE
  --</EC-DOC>
   IS

  BEGIN
    RETURN ue_Storage_Lift_Nomination.expectedUnloadDate(p_parcel_no);

  END expectedUnloadDate;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : aiStorageLiftNomination
  -- Description    : Instead of using triggers on tables this procedure should be run by
  --          instead of triggers on the view layer
  --          The trigger instantiate tables described in 'using tables'
  --
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   :                                                                                                                       --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE aiStorageLiftNomination(p_parcel_no          NUMBER,
                                    p_nom_date           DATE,
                                    p_nom_date_range     VARCHAR2,
                                    p_req_date           DATE,
                                    p_REQ_DATE_RANGE     VARCHAR2,
                                    p_REQ_GRS_VOL        NUMBER,
                                    p_REQ_TOLERANCE_TYPE VARCHAR2,
                                    p_nom_grs_vol        NUMBER,
                                    p_user               VARCHAR2 DEFAULT NULL)
  --</EC-DOC>

   IS
    -- define some temp variables
    t_nom_grs_vol    NUMBER;
    t_sch_grs_vol    NUMBER;
    t_nom_date_range VARCHAR2(8);
    t_nom_date       DATE;

  BEGIN
    -- check if nominated values are set
    IF p_nom_grs_vol IS NULL THEN
      -- if null, use requested values for nominated and scheduled
      t_nom_grs_vol := p_REQ_GRS_VOL;
      t_sch_grs_vol := p_REQ_GRS_VOL;
    ELSE
      -- else use nominated values for nominated and scheduled
      t_sch_grs_vol := p_nom_grs_vol;
      t_nom_grs_vol := p_nom_grs_vol;
    END IF;

    IF p_nom_date IS NULL THEN
      t_nom_date := p_REQ_DATE;
    ELSE
      t_nom_date := p_nom_date;
    END IF;

    IF p_nom_date_range IS NULL THEN
      t_nom_date_range := p_REQ_DATE_RANGE;
    ELSE
      t_nom_date_range := p_nom_date_range;
    END IF;

    UPDATE STORAGE_LIFT_NOMINATION
       SET NOM_FIRM_DATE           = t_nom_date,
           NOM_FIRM_DATE_RANGE     = t_nom_date_range,
           GRS_VOL_NOMINATED       = t_nom_grs_vol,
           GRS_VOL_SCHEDULE        = t_sch_grs_vol,
           SCHEDULE_TOLERANCE_TYPE = p_REQ_TOLERANCE_TYPE,
           LAST_UPDATED_BY         = p_user
     WHERE parcel_no = p_PARCEL_NO;

  END aiStorageLiftNomination;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : aiStorageLiftNomination2
  -- Description    : Instead of using triggers on tables this procedure should be run by
  --          instead of triggers on the view layer
  --          The trigger instantiate tables described in 'using tables'
  --          This trigger should only be enabled when _QTY2 attribues are enabled.
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   :                                                                                                                       --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE aiStorageLiftNomination2(p_parcel_no    NUMBER,
                                     p_REQ_GRS_VOL2 NUMBER,
                                     p_nom_grs_vol2 NUMBER,
                                     p_user         VARCHAR2 DEFAULT NULL)
  --</EC-DOC>

   IS
    -- define some temp variables
    t_nom_grs_vol2 NUMBER;
    t_sch_grs_vol2 NUMBER;

  BEGIN
    -- check if nominated values are set
    IF p_nom_grs_vol2 IS NULL THEN
      -- if null, use requested values for nominated and scheduled
      t_nom_grs_vol2 := p_REQ_GRS_VOL2;
      t_sch_grs_vol2 := p_REQ_GRS_VOL2;
    ELSE
      -- else use nominated values for nominated and scheduled
      t_sch_grs_vol2 := p_nom_grs_vol2;
      t_nom_grs_vol2 := p_nom_grs_vol2;
    END IF;

    UPDATE STORAGE_LIFT_NOMINATION
       SET GRS_VOL_NOMINATED2 = t_nom_grs_vol2,
           GRS_VOL_SCHEDULED2 = t_sch_grs_vol2,
           LAST_UPDATED_BY    = p_user
     WHERE parcel_no = p_PARCEL_NO;

  END aiStorageLiftNomination2;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : aiStorageLiftNomination2
  -- Description    : Instead of using triggers on tables this procedure should be run by
  --          instead of triggers on the view layer
  --          The trigger instantiate tables described in 'using tables'
  --          This trigger should only be enabled when _QTY2 attribues are enabled.
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   :                                                                                                                       --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE aiStorageLiftNomination3(p_parcel_no    NUMBER,
                                     p_REQ_GRS_VOL3 NUMBER,
                                     p_nom_grs_vol3 NUMBER,
                                     p_user         VARCHAR2 DEFAULT NULL)
  --</EC-DOC>

   IS
    -- define some temp variables
    t_nom_grs_vol3 NUMBER;
    t_sch_grs_vol3 NUMBER;

  BEGIN
    -- check if nominated values are set
    IF p_nom_grs_vol3 IS NULL THEN
      -- if null, use requested values for nominated and scheduled
      t_nom_grs_vol3 := p_REQ_GRS_VOL3;
      t_sch_grs_vol3 := p_REQ_GRS_VOL3;
    ELSE
      -- else use nominated values for nominated and scheduled
      t_sch_grs_vol3 := p_nom_grs_vol3;
      t_nom_grs_vol3 := p_nom_grs_vol3;
    END IF;

    UPDATE STORAGE_LIFT_NOMINATION
       SET GRS_VOL_NOMINATED3 = t_nom_grs_vol3,
           GRS_VOL_SCHEDULED3 = t_sch_grs_vol3,
           LAST_UPDATED_BY    = p_user
     WHERE parcel_no = p_PARCEL_NO;

  END aiStorageLiftNomination3;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : bdStorageLiftNomination
  -- Description    : Instead of using triggers on tables this procedure should be run by
  --          instead of triggers on the view layer
  --          The trigger deletes tables with constraint to storage_lift_nomination.
  --                  See 'using tables'
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   : storage_lifting                                                                                                                        --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE bdStorageLiftNomination(p_parcel_no NUMBER)
  --</EC-DOC>
   IS

  BEGIN
    -- delete parcel data
    delete storage_lifting where parcel_no = p_parcel_no;
    delete lift_doc_instruction where parcel_no = p_parcel_no;
    delete lifting_doc_receiver where parcel_no = p_parcel_no;
    delete lifting_doc_set where parcel_no = p_parcel_no;

    -- clean cargos that no longer have nominations / implicit calling
    EcBp_Cargo_Transport.cleanLonesomeCargoes;

  END bdStorageLiftNomination;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : validateLiftingIndicator
  -- Description    : Check thats new lifting indicator is unique
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
  PROCEDURE validateLiftingIndicator(p_old_lifting_code VARCHAR2,
                                     p_new_lifting_code VARCHAR2)
  --</EC-DOC>
   IS

    CURSOR c_lifting_ind(p_lifting_code VARCHAR2) IS
      SELECT lifting_code
        FROM storage_lift_nomination
       WHERE lifting_code = p_lifting_code;

  BEGIN
    IF (p_new_lifting_code IS NOT NULL AND
       (p_old_lifting_code IS NULL OR
       p_old_lifting_code <> p_new_lifting_code)) THEN
      FOR curLiftInd IN c_lifting_ind(p_new_lifting_code) LOOP
        Raise_Application_Error(-20323,
                                'The Lifting Indicator is not unique');
      END LOOP;
    END IF;

  END validateLiftingIndicator;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : validateBalanceInd
  -- Description    : Check thats only one nomination got balance ind check for each storage
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
  PROCEDURE validateBalanceInd(p_cargo_no VARCHAR2)
  --</EC-DOC>
   IS

    CURSOR c_check(cp_cargo_no VARCHAR2) IS
      SELECT count(t.balance_ind) no
        FROM storage_lift_nomination t
       WHERE cargo_no = cp_cargo_no
         AND t.balance_ind = 'Y'
       GROUP BY t.object_id;

  BEGIN
    FOR curCheck IN c_check(p_cargo_no) LOOP
      IF curCheck.no > 1 THEN
        Raise_Application_Error(-20330,
                                'More than one nomination got balance indicator set');
      END IF;
    END LOOP;

  END validateBalanceInd;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : deleteNomination
  -- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : storage_lift_nomination
  -- Using functions: EcBp_Cargo_Transport.cleanLonesomeCargoes;
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE deleteNomination(p_storage_id VARCHAR2,
                             p_from_date  DATE,
                             p_to_date    DATE)
  --</EC-DOC>
   IS

  BEGIN

    -- User exit function
    ue_storage_lift_nomination.deleteNomination(p_storage_id,
                                                p_from_date,
                                                p_to_date);

    -- Delete nominations without cargo
    DELETE storage_lift_nomination
     WHERE (fixed_ind is null or fixed_ind = 'N')
       AND cargo_no is NULL
       AND NOM_FIRM_DATE >= p_from_date
       AND NOM_FIRM_DATE <= p_to_date
       AND object_id = Nvl(p_storage_id, object_id);

    --delete nominations that are connected to a cargo
    DELETE storage_lift_nomination
     WHERE parcel_no IN
           (SELECT n.parcel_no
              FROM storage_lift_nomination n, cargo_transport c
             WHERE (fixed_ind is null or fixed_ind = 'N')
               AND c.cargo_no = n.cargo_no
               AND EcBp_Cargo_Status.getEcCargoStatus(c.cargo_status) in
                   ('T', 'O')
               AND n.nom_firm_date >= p_from_date
               AND n.nom_firm_date <= p_to_date
               AND n.object_id = Nvl(p_storage_id, object_id));

    -- clean cargos that no longer have nominations
    EcBp_Cargo_Transport.cleanLonesomeCargoes;

  END deleteNomination;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : insertFromLiftProg
  -- Description    : additional columns set when inserting a nominations from lifting program
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : storage_lift_nomination
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE insertFromLiftProg(p_parcel_no NUMBER,
                               p_nom_qty   NUMBER,
                               p_nom_date  DATE,
                               p_user      VARCHAR2 DEFAULT NULL)
  --</EC-DOC>
   IS

  BEGIN
    UPDATE STORAGE_LIFT_NOMINATION
       SET GRS_VOL_REQUESTED = p_nom_qty,
           GRS_VOL_SCHEDULE  = p_nom_qty,
           REQUESTED_DATE    = p_nom_date,
		   START_LIFTING_DATE = nvl(START_LIFTING_DATE, p_nom_date),
           LAST_UPDATED_BY   = p_user
     WHERE parcel_no = p_PARCEL_NO;

  END insertFromLiftProg;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : updateStorageLifting
  -- Description    : update Storage_Lifting.Load_Value from value being mapped by BLMR Light
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : storage_lifting
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE updateStorageLifting(p_parcel_no  NUMBER,
                                 p_net_vol    NUMBER,
                                 p_grs_vol    NUMBER,
                                 p_net_mass   NUMBER,
                                 p_grs_mass   NUMBER,
                                 p_net_energy NUMBER,
                                 p_grs_energy NUMBER,
                                 p_user       VARCHAR2 DEFAULT NULL)
  --</EC-DOC>

   IS

    CURSOR c_mapping(cp_parcel_no VARCHAR2) IS
      SELECT pms.product_meas_no meas_no
        FROM STORAGE_LIFTING sl, PRODUCT_MEAS_SETUP pms
       WHERE sl.parcel_no = cp_parcel_no
         AND sl.product_meas_no = pms.product_meas_no;

    lv_blmr_mapping VARCHAR2(32);
    lv_lift_status  VARCHAR2(32);

  BEGIN

    FOR curMap IN c_mapping(p_parcel_no) LOOP
      lv_blmr_mapping := ec_product_meas_setup.blmr_light_mapping(curMap.Meas_No);
      lv_lift_status  := ec_product_meas_setup.lifting_event(curMap.Meas_No);

      IF lv_lift_status = 'LOAD' THEN

        IF lv_blmr_mapping = 'CL_NET_VOL' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_net_vol, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;

        IF lv_blmr_mapping = 'CL_GRS_VOL' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_grs_vol, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;

        IF lv_blmr_mapping = 'CL_NET_MASS' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_net_mass, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;

        IF lv_blmr_mapping = 'CL_GRS_MASS' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_grs_mass, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;

        IF lv_blmr_mapping = 'CL_NET_ENERGY' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_net_energy, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;

        IF lv_blmr_mapping = 'CL_GRS_ENERGY' THEN
          UPDATE STORAGE_LIFTING
             SET LOAD_VALUE = p_grs_energy, LAST_UPDATED_BY = p_user
           WHERE parcel_no = p_parcel_no
             AND product_meas_no = curMap.Meas_No;
        END IF;
      END IF;
    END LOOP;

  END updateStorageLifting;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : insertCargo
  -- Description    : Instatiation of the Parcels based on the Cargo
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : STORAGE_LIFT_NOMINATION
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE insertCargo(p_cargo_no VARCHAR2, p_bl_date DATE, p_fcty_class_1 VARCHAR2)
  --</EC-DOC>
   IS

    CURSOR c_getStorage(cp_bl_date DATE, cp_fcty_class_1 VARCHAR2) IS
      SELECT distinct storage_id
        from ov_lifting_account la, ov_storage s
       WHERE la.storage_id = s.object_id
         AND la.daytime <= cp_bl_date
         AND nvl(la.end_date, cp_bl_date + 1) > cp_bl_date
		 AND s.OP_FCTY_1_ID = cp_fcty_class_1;

    ln_parcel_no NUMBER;

  BEGIN

    FOR curStorage IN c_getStorage(p_bl_date, p_fcty_class_1) LOOP
      ln_parcel_no := EcDp_System_Key.assignNextNumber('STORAGE_LIFT_NOMINATION');
      INSERT INTO STORAGE_LIFT_NOMINATION a
        (a.parcel_no, a.object_id, a.cargo_no, a.bl_date)
      values
        (ln_parcel_no, curStorage.storage_id, p_cargo_no, p_bl_date);
    END LOOP;

  END insertCargo;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : insertCargo
  -- Description    : Instatiation of the Parcels based on the Cargo
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : STORAGE_LIFT_NOMINATION
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION insertReadyForHabour(p_cargo_status VARCHAR2)
  --</EC-DOC>
   RETURN VARCHAR2 IS

    lv2_cargo_status VARCHAR2(32);

  BEGIN

    IF p_cargo_status IS NULL THEN
      lv2_cargo_status := 'R';
    ELSIF p_cargo_status = 'R' THEN
      lv2_cargo_status := 'R';
    ELSIF p_cargo_status = 'C' THEN
      lv2_cargo_status := 'C';
    ELSIF p_cargo_status = 'A' THEN
      lv2_cargo_status := 'A';
    ELSIF p_cargo_status = 'D' THEN
      lv2_cargo_status := 'D';
    ELSIF p_cargo_status = 'T' THEN
      lv2_cargo_status := 'R';
    ELSIF p_cargo_status = 'O' THEN
      lv2_cargo_status := 'R';
    END IF;

    return lv2_cargo_status;

  END insertReadyForHabour;

  ---------------------------------------------------------------------------------------------------
  -- Function       : getDefSplit
  -- Description    : Returns default split depending og contract and date
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
  FUNCTION getDefSplit(p_parcel_no NUMBER, p_lifting_account_id VARCHAR2)
    RETURN NUMBER IS

    cursor c_get_contract(c_parcel_no number) is
      select la.contract_id
        from ov_lifting_account la, STORAGE_LIFT_NOMINATION t
       where la.OBJECT_ID = t.LIFTING_ACCOUNT_ID
         and t.PARCEL_NO = c_parcel_no;

    lv_split       number;
    lv_contract_id varchar2(32);
  BEGIN

    -- Get contract id
    FOR r_get_contract IN c_get_contract(p_parcel_no) loop
      lv_contract_id := r_get_contract.contract_id;
    END LOOP;

    lv_split := ec_cntr_lift_acc_share.account_share(lv_contract_id,
                                                     p_lifting_account_id,
                                                     ec_storage_lift_nomination.nom_firm_date(p_parcel_no),
                                                     '=<');

    RETURN lv_split;

  END getDefSplit;
  ---------------------------------------------------------------------------------------------------
  -- Function       : validateSplit
  -- Description    : Validates the nominated qty split for a company / parcel
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
  -- Behaviour      : When the split is updated it must validated to be 100%.
  --
  PROCEDURE validateSplit(p_Parcel_No NUMBER) IS

    cursor c_sum_split is
      select SUM(nvl(split.SPLIT_PCT, 0)) as sum_split
        from STORAGE_LIFT_NOM_SPLIT split
       where parcel_no = p_parcel_no;

    ln_split_sum NUMBER;
  BEGIN
    FOR r_sum_split IN c_sum_split loop
      ln_split_sum := r_sum_split.sum_split;
    END LOOP;

    IF ln_split_sum <> 1 THEN
      Raise_Application_Error(-20564,
                              'The total split pct must be 100%. [Current Split: ' ||
                              to_char(ln_split_sum) || ']');
    END IF;
  END validateSplit;

  ---------------------------------------------------------------------------------------------------
  -- Function       : createUpdateSplit
  -- Description    : Creates or updates the nominated qty split for a company / parcel
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
  PROCEDURE createUpdateSplit(p_Parcel_No              NUMBER,
                              p_old_lifting_account_id VARCHAR2,
                              p_new_lifting_account_id VARCHAR2)
  --</EC-DOC>
   IS
    cursor c_split(c_daytime         date,
                   c_contract_id     varchar2,
                   c_lifting_account varchar2) is
      select clas.OBJECT_ID,
             clas.DAYTIME,
             clas.ACCOUNT_SHARE,
             ec_lifting_account.company_id(clas.LIFTING_ACCOUNT_ID) as company_id,
             clas.lifting_account_id
        from CNTR_LIFT_ACC_SHARE clas
       where clas.object_id = c_contract_id
         and clas.DAYTIME <= c_daytime
         and (clas.END_DATE > c_daytime or clas.END_DATE is null);

    cursor c_split_check(c_daytime         date,
                         c_contract_id     varchar2,
                         c_lifting_account varchar2) is
      select clas.OBJECT_ID,
             clas.DAYTIME,
             clas.ACCOUNT_SHARE,
             ec_lifting_account.LIFT_AGREEMENT_IND(p_new_lifting_account_id) as lift_agreement_ind
        from CNTR_LIFT_ACC_SHARE clas
       where clas.object_id = c_contract_id
         and clas.DAYTIME <= c_daytime
         and (clas.END_DATE > c_daytime or clas.END_DATE is null);

    cursor c_count_parcels is
      select count(*) as count_parcels
        from STORAGE_LIFT_NOM_SPLIT split
       where parcel_no = p_parcel_no;

    cursor c_get_contract(c_lifting_account varchar2) is
      select contract_id, company_id
        from ov_lifting_account la
       where la.OBJECT_ID = c_lifting_account;

    ln_party_share        number;
    ln_count              number;
    lv_contract_id        varchar2(32);
    lv_company_id         varchar2(32);
    ld_date               date;
    lv_lifting_account_id varchar2(32);
    lv_agreement_ind      varchar2(1);

  BEGIN

    IF p_old_lifting_account_id = p_new_lifting_account_id THEN
      RETURN;
    END IF;

    FOR r_count_parcels IN c_count_parcels loop
      ln_count := r_count_parcels.count_parcels;
    END LOOP;

    IF ln_count > 0 THEN
      -- Delete old stuff
      delete from dv_STOR_LIFT_NOM_CPY_SPLIT sln
       where sln.PARCEL_NO = p_Parcel_No;
    END IF;

    IF p_new_lifting_account_id IS NULL THEN
      Raise_Application_Error(-20563, 'Missing Lifting Account');
      RETURN;
    END IF;

    -- Get contract id
    FOR r_get_contract IN c_get_contract(p_new_lifting_account_id) loop
      lv_contract_id := r_get_contract.contract_id;
    END LOOP;

    ld_date := nvl(ec_storage_lift_nomination.bl_date(p_Parcel_No),
                   ec_storage_lift_nomination.nom_firm_date(p_parcel_no));

    -- check if we have shadow invoice contract
    FOR curCheck in c_split_check(ld_date,
                                  lv_contract_id,
                                  p_new_lifting_account_id) LOOP
      ln_party_share   := nvl(ln_party_share, 0) + 1;
      lv_agreement_ind := curCheck.lift_agreement_ind;
    END LOOP;

    IF ln_party_share >= 1 and lv_agreement_ind = 'Y' THEN
      -- Insert default split
      FOR cur in c_split(ld_date, lv_contract_id, p_new_lifting_account_id) LOOP
        lv_company_id         := cur.company_id;
        lv_lifting_account_id := cur.lifting_account_id;
        insert into dv_STOR_LIFT_NOM_CPY_SPLIT
          (PARCEL_NO,
           SPLIT_PCT,
           COMPANY_ID,
           LIFTING_ACCOUNT_ID,
           created_by)
        values
          (p_Parcel_No,
           cur.ACCOUNT_SHARE,
           lv_company_id,
           lv_lifting_account_id,
           ecdp_context.getAppuser);
      END LOOP;

    END IF;

  END createUpdateSplit;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : calcNomSplitQty
  -- Description    : Returns the nominated qty split for a company
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
  FUNCTION calcNomSplitQty(p_parcel_no          NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_xtra_qty           NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS
    ln_split_qty         NUMBER;
    ln_grs_vol_nominated NUMBER;
    ld_date              date;

  BEGIN

    ld_date := nvl(ec_storage_lift_nomination.bl_date(p_Parcel_No),
                   ec_storage_lift_nomination.nom_firm_date(p_parcel_no));

	IF (p_xtra_qty = 1) THEN
		ln_grs_vol_nominated := ec_storage_lift_nomination.grs_vol_nominated2(p_parcel_no);
	ELSIF (p_xtra_qty = 2) THEN
		ln_grs_vol_nominated := ec_storage_lift_nomination.grs_vol_nominated3(p_parcel_no);
	ELSE
		ln_grs_vol_nominated := ec_storage_lift_nomination.grs_vol_nominated(p_parcel_no);
	END IF;

    ln_split_qty := calcSplitQty(p_parcel_no, p_company_id, p_lifting_account_id, ld_date, ln_grs_vol_nominated);

    RETURN ln_split_qty;
  END calcNomSplitQty;

 --<EC-DOC>
  ------------------------------------------------------------------------------------------------------
  -- Function       : calcActualSplitQty
  -- Description    : Returns the actual qty
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
  FUNCTION calcActualSplitQty(p_parcel_no          NUMBER,
                              p_company_id         VARCHAR2,
                              p_lifting_account_id VARCHAR2,
                              p_xtra_qty           NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
  IS
    ld_date      DATE;
    ln_lifted_qty       NUMBER;
    ln_split_qty NUMBER;

  BEGIN

    ld_date := nvl(ec_storage_lift_nomination.bl_date(p_Parcel_No),
                   ec_storage_lift_nomination.nom_firm_date(p_parcel_no));
    ln_lifted_qty := getLiftedVol(p_parcel_no, p_xtra_qty);

    ln_split_qty := calcSplitQty(p_parcel_no, p_company_id, p_lifting_account_id, ld_date, ln_lifted_qty);
    RETURN ln_split_qty;
  END calcActualSplitQty;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : calcAggrSubDaySplitQty
  -- Description    : Returns the aggregate qty split for a company
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
  FUNCTION calcAggrSubDaySplitQty(p_parcel_no          NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_daytime            DATE,
                           p_xtra_qty           NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS
    ln_split_qty         NUMBER;
    ln_lifted_qty       NUMBER;

  BEGIN

    ln_lifted_qty := ue_storage_lift_nomination.aggrSubDayLifting(p_parcel_no, p_daytime, NULL, p_xtra_qty);

    ln_split_qty := calcSplitQty(p_parcel_no, p_company_id, p_lifting_account_id, p_daytime, ln_lifted_qty);

    RETURN ln_split_qty;
  END calcAggrSubDaySplitQty;

 --<EC-DOC>
  ------------------------------------------------------------------------------------------------------
  -- Function       : calcSplitQty
  -- Description    : Returns the qty split for company/lifting account
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
  FUNCTION calcSplitQty(p_parcel_no          NUMBER,
                              p_company_id         VARCHAR2,
                              p_lifting_account_id VARCHAR2,
                              p_daytime            DATE,
                              p_qty                NUMBER)
    RETURN NUMBER
  --</EC-DOC>
   IS
    cursor c_split(c_daytime date) is
      select nvl(cpy_split.SPLIT_PCT, 0) as cpy_split,
             lift_acc.BALANCE_IND as BALANCE_IND,
             lift_acc.daytime as DAYTIME,
             ec_lifting_account.company_id(split.lifting_account_id) as COMPANY_ID,
             split.object_id as STORAGE_ID
        from STORAGE_LIFT_NOM_SPLIT  cpy_split,
             STORAGE_LIFT_NOMINATION split,
             CNTR_LIFT_ACC_SHARE     lift_acc
       where cpy_split.parcel_no = p_parcel_no
         and cpy_split.parcel_no = split.parcel_no
         and cpy_split.COMPANY_ID = p_company_id
         and COMPANY_ID = cpy_split.COMPANY_ID
         and lift_acc.lifting_account_id = p_lifting_account_id
		 and lift_acc.lifting_account_id = cpy_split.lifting_account_id
         and lift_acc.OBJECT_ID =
             ec_lift_account_version.contract_id(split.LIFTING_ACCOUNT_ID,
                                                 nvl(split.bl_date,
                                                     split.nom_firm_date),
                                                 '<=')
         and lift_acc.DAYTIME <= c_daytime
         and (lift_acc.END_DATE > c_daytime or lift_acc.END_DATE is null);

    cursor c_split_all(c_daytime date) is
      select nvl(cpy_split.SPLIT_PCT, 0) as cpy_split,
             lift_acc.BALANCE_IND as BALANCE_IND,
             ec_lifting_account.company_id(split.lifting_account_id) as COMPANY_ID
        from STORAGE_LIFT_NOM_SPLIT  cpy_split,
             STORAGE_LIFT_NOMINATION split,
             CNTR_LIFT_ACC_SHARE     lift_acc
       where cpy_split.parcel_no = p_parcel_no
         and cpy_split.parcel_no = split.parcel_no
         and lift_acc.OBJECT_ID =
             ec_lift_account_version.contract_id(split.LIFTING_ACCOUNT_ID,
                                                 nvl(split.bl_date,
                                                     split.nom_firm_date),
                                                 '<=')
         and lift_acc.DAYTIME <= nvl(split.bl_date, split.nom_firm_date)
         and nvl(lift_acc.BALANCE_IND, 'N') <> 'Y'
         and cpy_split.lifting_account_id = lift_acc.lifting_account_id
         and lift_acc.DAYTIME <= c_daytime
         and (lift_acc.END_DATE > c_daytime or lift_acc.END_DATE is null);

    ln_split_qty   NUMBER;
    ln_balance_qty number := 0;
    ln_decimal     NUMBER;
    lv_storage_id  varchar2(32);
    ld_daytime     date;

  BEGIN

    FOR cur IN c_split(p_daytime) loop

      lv_storage_id := cur.STORAGE_ID;
      ld_DAYTIME    := cur.DAYTIME;

      ln_decimal := ec_stor_version.nom_split_round_decimals(lv_storage_id,
                                                             ld_daytime,
                                                             '<=');
      IF cur.BALANCE_IND = 'Y' THEN
        -- Get total for all other companies:
        FOR cur2 IN c_split_all(p_daytime) loop
          ln_balance_qty := ln_balance_qty + ROUND(p_qty * cur2.cpy_split, NVL(ln_decimal, 0));
        END LOOP;
        ln_split_qty := p_qty - ln_balance_qty;
      ELSE
        ln_split_qty := p_qty * cur.cpy_split;
        ln_split_qty := ROUND(ln_split_qty, NVL(ln_decimal, 0));
      END IF;

    END LOOP;

    RETURN ln_split_qty;
  END calcSplitQty;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftedVolByIncoterm
  -- Description    : Returns the lifted volume for a parcel based on whether the lifting is FOB or CIF/DES.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : product_meas_setup, storage_lifting
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLiftedVolByIncoterm (p_parcel_no NUMBER, p_xtra_qty NUMBER) RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lifting(cp_parcel_no     NUMBER,
                          cp_xtra_qty      NUMBER,
                          cp_lifting_event VARCHAR2) IS
      SELECT s.load_value
        FROM product_meas_setup p, storage_lifting s
       WHERE p.product_meas_no = s.product_meas_no
         AND s.parcel_no = cp_parcel_no
         AND p.lifting_event = cp_lifting_event
         AND ((p.nom_unit_ind = 'Y' and 0 = NVL(p_xtra_qty, 0)) or
             (p.nom_unit_ind2 = 'Y' and 1 = p_xtra_qty) or
             (p.nom_unit_ind3 = 'Y' and 2 = p_xtra_qty));

    lnLiftedVol   NUMBER;
	lsContractType varchar2(32);


  BEGIN

	lsContractType := ec_storage_lift_nomination.incoterm(p_parcel_no);

	IF lsContractType is null OR lsContractType = 'FOB' THEN
		FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'LOAD') LOOP
			lnLiftedVol := curLifted.load_value;
		END LOOP;
	ELSE IF lsContractType = 'CIF' OR lsContractType = 'DES' THEN
      FOR curLifted IN c_stor_lifting(p_parcel_no, p_xtra_qty, 'UNLOAD') LOOP
        lnLiftedVol := curLifted.load_value;
      END LOOP;
    END IF;
	END IF;

 RETURN lnLiftedVol;

 END getLiftedVolByIncoterm ;

--<EC-DOC>
  ------------------------------------------------------------------------------------------------------
  -- Function       : aggrSubDayLifting
  -- Description    : Returns the aggregated daily lifting
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
  FUNCTION aggrSubDayLifting(p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0)
  RETURN NUMBER
  --</EC-DOC>
   IS
	ln_result NUMBER;
   	CURSOR c_sub_day(cp_parcel_no NUMBER, cp_daytime DATE, cp_xtra_qty NUMBER DEFAULT 0)
   	IS
   		SELECT object_id,
   			   SUM(DECODE(cp_xtra_qty, 0, n.grs_vol_requested, 1, n.grs_vol_requested2, 2, n.grs_vol_requested3)) grs_vol_requested,
   		       SUM(DECODE(cp_xtra_qty, 0, n.grs_vol_nominated, 1, n.grs_vol_nominated2, 2, n.grs_vol_nominated3)) grs_vol_nominated,
   		       SUM(DECODE(cp_xtra_qty, 0, n.grs_vol_schedule, 1, n.grs_vol_scheduled2, 2, n.grs_vol_scheduled3)) grs_vol_scheduled,
   		       SUM(DECODE(cp_xtra_qty, 0, n.lifted_qty, 1, n.lifted_qty2, 2, n.lifted_qty3)) lifted_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.unload_qty, 1, n.unload_qty2, 2, n.unload_qty3)) unload_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.cooldown_qty, 1, n.cooldown_qty2, 2, n.cooldown_qty3)) cooldown_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.purge_qty, 1, n.purge_qty2, 2, n.purge_qty3)) purge_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.lauf_qty, 1, n.lauf_qty2, 2, n.lauf_qty3)) lauf_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.vapour_return_qty, 1, n.vapour_return_qty2, 2, n.vapour_return_qty3)) vapour_return_qty,
   		       SUM(DECODE(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3)) balance_delta_qty
   		  FROM stor_sub_day_lift_nom n
   		 WHERE parcel_no = cp_parcel_no
   		   AND production_day = cp_daytime
   		GROUP BY object_id;
  BEGIN
  	FOR c_cur IN c_sub_day(p_parcel_no, p_daytime, p_xtra_qty) LOOP
  		IF p_column = 'REQUESTED' THEN
  			ln_result := c_cur.grs_vol_requested;
  		ELSIF p_column = 'NOMINATED' THEN
  			ln_result := c_cur.grs_vol_nominated;
  		ELSIF p_column = 'SCHEDULED' THEN
  			ln_result := c_cur.grs_vol_scheduled;
  		ELSIF p_column = 'LIFTED' THEN
  			ln_result := c_cur.lifted_qty;
  		ELSIF p_column = 'UNLOAD' THEN
  			ln_result := c_cur.unload_qty;
  		ELSIF p_column = 'COOLDOWN' THEN
  			ln_result := c_cur.cooldown_qty;
  		ELSIF p_column = 'PURGE' THEN
  			ln_result := c_cur.purge_qty;
  		ELSIF p_column = 'LAUF' THEN
  			ln_result := c_cur.lauf_qty;
  		ELSIF p_column = 'VAPOUR_RETURN' THEN
  			ln_result := c_cur.vapour_return_qty;
  		ELSIF p_column = 'BALANCE_DELTA' THEN
  			ln_result := c_cur.balance_delta_qty;
  		ELSE
  			-- If column is not specified, return best quantity
  			ln_result := c_cur.lifted_qty;
  			IF ln_result IS NULL AND (ec_stor_version.storage_type(c_cur.object_id, p_daytime, '<=') = 'IMPORT') THEN
  				ln_result := c_cur.unload_qty;
  			END IF;
  			IF ln_result IS NULL THEN
  				ln_result := c_cur.grs_vol_nominated;
  			END IF;
  		END IF;
  	END LOOP;

  	RETURN ln_result;
  END aggrSubDayLifting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
-- Description    : Procedure to calculate sub daily liftings
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
PROCEDURE calcSubDayLifting(p_parcel_no NUMBER)
--</EC-DOC>
IS
	lvStorageType VARCHAR2(32);
	ln_berth_rate NUMBER;
	ln_carrier_rate NUMBER;
	ln_hourly_full_rate NUMBER;
	ln_loop_hours NUMBER;
	ln_tot_loop_hours NUMBER := 0;
	ln_hour_counter NUMBER;
	ln_cum_lifted NUMBER;

	lud_date_time EcDp_Date_Time.Ec_Unique_Daytime;
	ld_date_time DATE;
	lv_summertime VARCHAR2(1);
	ld_start_lifting_date DATE;
	ld_to_date_time DATE;
	lv_to_summertime VARCHAR2(1);
	ld_act_lifted_date DATE;
	ld_act_lifted_end_date DATE;

	ln_pm_nom_unit_load NUMBER;
	ln_pm_nom_unit_load2 NUMBER;
	ln_pm_cooldown_qty NUMBER;
	ln_pm_cooldown_qty2 NUMBER;
	ln_pm_purge_qty NUMBER;
	ln_pm_purge_qty2 NUMBER;

	ln_hr_requested_qty NUMBER;
	ln_hr_requested_qty2 NUMBER;
	ln_hr_nominated_qty NUMBER;
	ln_hr_nominated_qty2 NUMBER;
	ln_hr_cooldown_qty NUMBER;
	ln_hr_cooldown_qty2 NUMBER;
	ln_hr_purge_qty NUMBER;
	ln_hr_purge_qty2 NUMBER;
	ln_hr_lifted_qty NUMBER;
	ln_hr_lifted_qty2 NUMBER;
	ln_hr_unload_qty NUMBER;
	ln_hr_unload_qty2 NUMBER;

	ln_act_cooldown_qty NUMBER;
	ln_act_cooldown_qty2 NUMBER;
	ln_act_purge_qty NUMBER;
	ln_act_purge_qty2 NUMBER;

	CURSOR c_nom(cp_parcel_no NUMBER)
	IS
		SELECT n.cargo_no, n.object_id, n.nom_firm_date, n.nom_firm_date_time, n.start_lifting_date,
		       n.grs_vol_requested, n.grs_vol_requested2, n.grs_vol_nominated, n.grs_vol_nominated2,
		       n.cooldown_qty, n.cooldown_qty2, n.purge_qty, n.purge_qty2,
		       EcBP_Storage_Lift_Nomination.getLiftedVol(n.parcel_no, 0, 'N') lifted_vol, EcBP_Storage_Lift_Nomination.getLiftedVol(n.parcel_no, 1, 'N') lifted_vol2,
		       EcBP_Storage_Lift_Nomination.getUnloadVol(n.parcel_no) unload_vol, EcBP_Storage_Lift_Nomination.getUnloadVol(n.parcel_no, 1) unload_vol2,
		       ct.berth_id, ct.carrier_id,
		       c.cooldown_rate, to_char(purge_time,'HH') purge_time, c.loading_rate
		  FROM storage_lift_nomination n, cargo_transport ct, carrier_version c
		 WHERE n.parcel_no = cp_parcel_no
		   AND n.cargo_no = ct.cargo_no(+)
		   AND n.carrier_id = c.object_id(+)
		   AND NVL(n.start_lifting_date, n.nom_firm_date_time) IS NOT NULL;

	CURSOR c_prod_meas(cp_parcel_no NUMBER)
	IS
		SELECT p.product_meas_no, p.balance_qty_type, p.nom_unit_ind, p.nom_unit_ind2
		  FROM product_meas_setup p, storage_lifting s
         WHERE p.product_meas_no = s.product_meas_no
           AND s.parcel_no = cp_parcel_no
           AND p.lifting_event = 'LOAD'
		   AND (p.nom_unit_ind = 'Y' OR p.nom_unit_ind2 = 'Y' OR p.balance_qty_type IN ('COOLDOWN_QTY','COOLDOWN_QTY2','PURGE_QTY','PURGE_QTY2'));

   	CURSOR c_fcst_nom(cp_parcel_no NUMBER)
	IS
		SELECT forecast_id
		  FROM stor_fcst_lift_nom
		 WHERE parcel_no = cp_parcel_no;
BEGIN
	DELETE FROM stor_sub_day_lift_nom WHERE parcel_no = p_parcel_no;

	FOR c_cur IN c_prod_meas(p_parcel_no) LOOP
		IF c_cur.nom_unit_ind = 'Y' THEN
			ln_pm_nom_unit_load := c_cur.product_meas_no;
		ELSIF c_cur.nom_unit_ind2 = 'Y' THEN
			ln_pm_nom_unit_load2 := c_cur.product_meas_no;
		ELSIF c_cur.balance_qty_type = 'COOLDOWN_QTY' THEN
			ln_pm_cooldown_qty := c_cur.product_meas_no;
		ELSIF c_cur.balance_qty_type = 'COOLDOWN_QTY2' THEN
			ln_pm_cooldown_qty2 := c_cur.product_meas_no;
		ELSIF c_cur.balance_qty_type = 'PURGE_QTY' THEN
			ln_pm_purge_qty := c_cur.product_meas_no;
		ELSIF c_cur.balance_qty_type = 'PURGE_QTY2' THEN
			ln_pm_purge_qty2 := c_cur.product_meas_no;
		END IF;
	END LOOP;

	FOR c_cur IN c_nom(p_parcel_no) LOOP
	    lvStorageType := ec_stor_version.storage_type(c_cur.object_id, NVL(c_cur.start_lifting_date, c_cur.nom_firm_date_time), '<=');

		-- Find first hour
		ld_start_lifting_date := NVL(c_cur.start_lifting_date, c_cur.nom_firm_date_time);
		ld_date_time := ld_start_lifting_date;
		lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(ld_date_time));

		-- Update purge quantity
		IF c_cur.purge_qty IS NOT NULL AND NVL(c_cur.purge_time, 0) > 0 THEN
			IF ln_pm_purge_qty IS NOT NULL THEN
				ln_act_purge_qty := ec_storage_lifting.load_value(p_parcel_no, ln_pm_purge_qty);
			END IF;
			IF c_cur.purge_qty2 IS NOT NULL THEN
				IF ln_pm_purge_qty2 IS NOT NULL THEN
					ln_act_purge_qty2 := ec_storage_lifting.load_value(p_parcel_no, ln_pm_purge_qty2);
				END IF;
				ln_hr_purge_qty2 := ln_hr_purge_qty * NVL(ln_act_purge_qty2, c_cur.purge_qty2) / NVL(ln_act_purge_qty, c_cur.purge_qty);
			END IF;

			ld_act_lifted_date := EcBp_Cargo_Activity.getLiftingStartDate(c_cur.cargo_no, 'PURGE');
			ld_act_lifted_end_date := EcBp_Cargo_Activity.getLiftingEndDate(c_cur.cargo_no, 'PURGE');

			ln_loop_hours := c_cur.purge_time;
			ln_tot_loop_hours := ln_tot_loop_hours + ln_loop_hours;
			IF ld_act_lifted_date IS NOT NULL AND ld_act_lifted_end_date IS NOT NULL THEN
				ln_loop_hours := EcDp_Date_Time.getDateDiff('HH',EcDp_Date_Time.local2utc(ld_act_lifted_date), EcDp_Date_Time.local2utc(ld_act_lifted_end_date));
				ld_date_time := ld_act_lifted_date;
				lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(ld_date_time));
			END IF;

			ln_hr_purge_qty := NVL(ln_act_purge_qty, c_cur.purge_qty) / ln_loop_hours;

			ln_hour_counter := 0;
			WHILE ln_hour_counter < ln_loop_hours LOOP
				IF ln_pm_purge_qty IS NOT NULL THEN
					ln_act_purge_qty := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_purge_qty, 'PURGE');
				END IF;
				IF ln_act_purge_qty IS NOT NULL THEN
					ln_hr_purge_qty := ln_act_purge_qty;
				END IF;

				IF ln_pm_purge_qty2 IS NOT NULL THEN
					ln_act_purge_qty2 := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_purge_qty2, 'PURGE');
				END IF;
				IF ln_act_purge_qty2 IS NOT NULL THEN
					ln_hr_purge_qty2 := ln_act_purge_qty2;
				END IF;

				IF ec_stor_sub_day_lift_nom.record_status(p_parcel_no, ld_date_time) IS NULL THEN
				INSERT INTO stor_sub_day_lift_nom(parcel_no, object_id, daytime, summer_time, purge_qty, purge_qty2, balance_delta_qty, balance_delta_qty2)
				VALUES(p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_purge_qty, ln_hr_purge_qty2, ln_hr_purge_qty, ln_hr_purge_qty2);
				ELSE
					UPDATE stor_sub_day_lift_nom
					   SET purge_qty = ln_hr_purge_qty, purge_qty2 = ln_hr_purge_qty2, balance_delta_qty = ln_hr_purge_qty, balance_delta_qty2 = ln_hr_purge_qty2
					 WHERE parcel_no = p_parcel_no AND daytime = ld_date_time;
				END IF;

				lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
				ld_date_time := lud_date_time.daytime;
				lv_summertime := lud_date_time.summertime_flag;
				ln_hour_counter := ln_hour_counter + 1;
			END LOOP;
		END IF;

		-- Update cooldown quantity
		IF c_cur.cooldown_qty IS NOT NULL AND NVL(c_cur.cooldown_rate, 0) > 0 THEN
			ln_hourly_full_rate := c_cur.cooldown_rate;
			IF ln_pm_cooldown_qty IS NOT NULL THEN
				ln_act_cooldown_qty := ec_storage_lifting.load_value(p_parcel_no, ln_pm_cooldown_qty);
			END IF;
			IF ln_pm_cooldown_qty2 IS NOT NULL THEN
				ln_act_cooldown_qty2 := ec_storage_lifting.load_value(p_parcel_no, ln_pm_cooldown_qty2);
			END IF;
			ln_loop_hours := NVL(ln_act_cooldown_qty, c_cur.cooldown_qty) / c_cur.cooldown_rate;
			IF ln_loop_hours > trunc(ln_loop_hours) THEN
				ln_loop_hours := trunc(ln_loop_hours) + 1;
			END IF;
			ln_tot_loop_hours := ln_tot_loop_hours + ln_loop_hours;

			ld_act_lifted_date := EcBp_Cargo_Activity.getLiftingStartDate(c_cur.cargo_no, 'COOLDOWN');
			ld_act_lifted_end_date := EcBp_Cargo_Activity.getLiftingEndDate(c_cur.cargo_no, 'COOLDOWN');

			IF ld_act_lifted_date IS NOT NULL AND ld_act_lifted_end_date IS NOT NULL THEN
				ln_loop_hours := EcDp_Date_Time.getDateDiff('HH',EcDp_Date_Time.local2utc(ld_act_lifted_date), EcDp_Date_Time.local2utc(ld_act_lifted_end_date));
				ld_date_time := ld_act_lifted_date;
				lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(ld_date_time));
			END IF;

			ln_hour_counter := 0;
			WHILE ln_hour_counter < ln_loop_hours LOOP
				ln_hr_cooldown_qty := NULL;
				ln_hr_cooldown_qty2 := NULL;
				IF ln_pm_cooldown_qty IS NOT NULL THEN
					ln_hr_cooldown_qty := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_cooldown_qty, 'COOLDOWN');
				END IF;
				IF ln_pm_cooldown_qty2 IS NOT NULL THEN
					ln_hr_cooldown_qty2 := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_cooldown_qty2, 'COOLDOWN');
				END IF;

				IF ln_hr_cooldown_qty IS NULL THEN
				ln_cum_lifted := ln_hourly_full_rate * ln_hour_counter;
					IF (ln_cum_lifted + ln_hourly_full_rate) > NVL(ln_act_cooldown_qty, c_cur.cooldown_qty) THEN
					ln_hr_cooldown_qty := NVL(ln_act_cooldown_qty, c_cur.cooldown_qty) - ln_cum_lifted;
					IF ln_hr_cooldown_qty < 0 THEN
						ln_hr_cooldown_qty := 0;
					END IF;
				ELSE
					ln_hr_cooldown_qty := ln_hourly_full_rate;
				END IF;
				END IF;

				IF c_cur.cooldown_qty2 IS NOT NULL THEN
					IF ln_hr_cooldown_qty2 IS NULL THEN
						ln_hr_cooldown_qty2 := ln_hr_cooldown_qty * NVL(ln_act_cooldown_qty2, c_cur.cooldown_qty2) / NVL(ln_act_cooldown_qty, c_cur.cooldown_qty);
					END IF;
				END IF;

				IF ec_stor_sub_day_lift_nom.record_status(p_parcel_no, ld_date_time) IS NULL THEN
				INSERT INTO stor_sub_day_lift_nom(parcel_no, object_id, daytime, summer_time, cooldown_qty, cooldown_qty2, balance_delta_qty, balance_delta_qty2)
				VALUES(p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_cooldown_qty, ln_hr_cooldown_qty2, ln_hr_cooldown_qty, ln_hr_cooldown_qty2);
				ELSE
					UPDATE stor_sub_day_lift_nom
					   SET cooldown_qty = ln_hr_cooldown_qty, cooldown_qty2 = ln_hr_cooldown_qty2, balance_delta_qty = ln_hr_cooldown_qty, balance_delta_qty2 = ln_hr_cooldown_qty2
					 WHERE parcel_no = p_parcel_no AND daytime = ld_date_time;
				END IF;

				lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
				ld_date_time := lud_date_time.daytime;
				lv_summertime := lud_date_time.summertime_flag;
				ln_hour_counter := ln_hour_counter + 1;
			END LOOP;
		END IF;

		-- Update nominated quantity
		-- Find first hour
		ld_start_lifting_date := ld_start_lifting_date + ln_tot_loop_hours/24;
		ld_date_time := ld_start_lifting_date;
		ld_act_lifted_date := EcBp_Cargo_Activity.getLiftingStartDate(c_cur.cargo_no);
		ld_act_lifted_end_date := EcBp_Cargo_Activity.getLiftingEndDate(c_cur.cargo_no);
		IF ld_act_lifted_date IS NOT NULL AND ld_act_lifted_date < ld_date_time THEN
			ld_date_time := ld_act_lifted_date;
		END IF;
		lv_summertime := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(ld_date_time));

		-- Find houly rate
		ln_berth_rate := ec_berth_version.design_capacity(c_cur.berth_id, c_cur.nom_firm_date, '<=');
		ln_carrier_rate := c_cur.loading_rate;
		IF ln_berth_rate IS NULL OR ln_carrier_rate < ln_berth_rate THEN
			ln_hourly_full_rate := ln_carrier_rate;
		ELSIF ln_carrier_rate IS NULL OR ln_berth_rate < ln_carrier_rate THEN
			ln_hourly_full_rate := ln_carrier_rate;
		END IF;

		IF ln_hourly_full_rate IS NULL THEN
			ln_hourly_full_rate := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/sub_day_lifting_rate');
		END IF;

		-- Find last hour
		IF NVL(ln_hourly_full_rate, 0) = 0 THEN
			ln_loop_hours := 1;
			ln_hourly_full_rate := greatest(c_cur.grs_vol_nominated, c_cur.grs_vol_requested);
			IF ld_act_lifted_date IS NULL AND c_cur.lifted_vol IS NOT NULL THEN
				ln_hourly_full_rate := greatest(ln_hourly_full_rate, c_cur.lifted_vol);
			END IF;
			IF lvStorageType = 'IMPORT' AND c_cur.unload_vol IS NOT NULL THEN
				ln_hourly_full_rate := greatest(ln_hourly_full_rate, c_cur.unload_vol);
			END IF;
		ELSE
			ln_loop_hours := greatest(c_cur.grs_vol_nominated, c_cur.grs_vol_requested);
			IF ld_act_lifted_date IS NULL AND c_cur.lifted_vol IS NOT NULL THEN
				ln_loop_hours := greatest(ln_loop_hours, c_cur.lifted_vol);
			END IF;
			IF lvStorageType = 'IMPORT' AND c_cur.unload_vol IS NOT NULL THEN
				ln_loop_hours := greatest(ln_loop_hours, c_cur.unload_vol);
			END IF;
			ln_loop_hours := ln_loop_hours / ln_hourly_full_rate;
		END IF;
		IF ln_loop_hours > trunc(ln_loop_hours) THEN
			ln_loop_hours := trunc(ln_loop_hours) + 1;
		END IF;
		IF ld_act_lifted_date IS NOT NULL AND ld_act_lifted_date < ld_start_lifting_date THEN
			ln_loop_hours := ln_loop_hours + EcDp_Date_Time.getDateDiff('HH',EcDp_Date_Time.local2utc(ld_act_lifted_date), EcDp_Date_Time.local2utc(ld_start_lifting_date));
		END IF;
		ld_to_date_time := ld_start_lifting_date + ln_loop_hours/24;
		IF ld_act_lifted_end_date IS NOT NULL AND ld_act_lifted_end_date > ld_to_date_time THEN
			ld_to_date_time := ld_act_lifted_end_date;
			ln_loop_hours := EcDp_Date_Time.getDateDiff('HH',EcDp_Date_Time.local2utc(ld_date_time), EcDp_Date_Time.local2utc(ld_to_date_time));
		END IF;

		-- Loop through hours
		ln_hour_counter := 0;
		ln_cum_lifted := 0;
		WHILE ln_hour_counter < ln_loop_hours LOOP
			IF ld_date_time >= ld_start_lifting_date THEN
				IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.grs_vol_requested THEN
					ln_hr_requested_qty := c_cur.grs_vol_requested - ln_cum_lifted;
					IF ln_hr_requested_qty < 0 THEN
						ln_hr_requested_qty := 0;
					END IF;
				ELSE
					ln_hr_requested_qty := ln_hourly_full_rate;
				END IF;
				IF c_cur.grs_vol_requested2 IS NOT NULL THEN
					ln_hr_requested_qty2 := ln_hr_requested_qty * c_cur.grs_vol_requested2 / c_cur.grs_vol_requested;
				END IF;

				IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.grs_vol_nominated THEN
					ln_hr_nominated_qty := c_cur.grs_vol_nominated - ln_cum_lifted;
					IF ln_hr_nominated_qty < 0 THEN
						ln_hr_nominated_qty := 0;
					END IF;
				ELSE
					ln_hr_nominated_qty := ln_hourly_full_rate;
				END IF;
				IF c_cur.grs_vol_nominated2 IS NOT NULL THEN
					ln_hr_nominated_qty2 := ln_hr_nominated_qty * c_cur.grs_vol_nominated2 / c_cur.grs_vol_nominated;
				END IF;

				IF lvStorageType = 'IMPORT' AND c_cur.unload_vol IS NOT NULL THEN
					IF (ln_cum_lifted + ln_hourly_full_rate) > c_cur.unload_vol THEN
						ln_hr_unload_qty := c_cur.unload_vol - ln_cum_lifted;
						IF ln_hr_unload_qty < 0 THEN
							ln_hr_unload_qty := 0;
						END IF;
					ELSE
						ln_hr_unload_qty := ln_hourly_full_rate;
					END IF;
					IF c_cur.unload_vol2 IS NOT NULL THEN
						ln_hr_unload_qty2 := ln_hr_unload_qty * c_cur.unload_vol2 / c_cur.unload_vol;
					END IF;
				END IF;
				ln_cum_lifted := ln_cum_lifted + ln_hourly_full_rate;
			END IF;

			IF ld_act_lifted_date IS NOT NULL AND ld_act_lifted_end_date IS NOT NULL THEN
				IF ln_pm_nom_unit_load IS NOT NULL THEN
					ln_hr_lifted_qty := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_nom_unit_load);
				END IF;
				IF ln_pm_nom_unit_load2 IS NOT NULL THEN
					ln_hr_lifted_qty2 := ecbp_storage_lifting.getHourlyLiftedValue(p_parcel_no, ld_date_time, ln_pm_nom_unit_load2);
				END IF;
			ELSIF c_cur.lifted_vol IS NOT NULL THEN
				IF ln_cum_lifted > c_cur.lifted_vol THEN
					ln_hr_lifted_qty := c_cur.lifted_vol - ln_cum_lifted + ln_hourly_full_rate;
					IF ln_hr_lifted_qty < 0 THEN
						ln_hr_lifted_qty := 0;
					END IF;
				ELSE
					ln_hr_lifted_qty := ln_hourly_full_rate;
				END IF;
				IF c_cur.lifted_vol2 IS NOT NULL THEN
					ln_hr_lifted_qty2 := ln_hr_lifted_qty * c_cur.lifted_vol2 / c_cur.lifted_vol;
				END IF;
			END IF;

			IF ec_stor_sub_day_lift_nom.record_status(p_parcel_no, ld_date_time) IS NULL THEN
			INSERT INTO stor_sub_day_lift_nom(parcel_no, object_id, daytime, summer_time, grs_vol_requested, grs_vol_requested2, grs_vol_nominated, grs_vol_nominated2, lifted_qty, lifted_qty2, unload_qty, unload_qty2)
			VALUES(p_parcel_no, c_cur.object_id, ld_date_time, lv_summertime, ln_hr_requested_qty, ln_hr_requested_qty2, ln_hr_nominated_qty, ln_hr_nominated_qty2, ln_hr_lifted_qty, ln_hr_lifted_qty2, ln_hr_unload_qty, ln_hr_unload_qty2);
			ELSE
				UPDATE stor_sub_day_lift_nom
				   SET grs_vol_requested = ln_hr_requested_qty, grs_vol_requested2 = ln_hr_requested_qty2, grs_vol_nominated = ln_hr_nominated_qty, grs_vol_nominated2 = ln_hr_nominated_qty2,
				       lifted_qty = ln_hr_lifted_qty, lifted_qty2 = ln_hr_lifted_qty2, unload_qty = ln_hr_unload_qty, unload_qty2 = ln_hr_unload_qty
				 WHERE parcel_no = p_parcel_no AND daytime = ld_date_time;
			END IF;

			lud_date_time := EcDp_Date_Time.getNextHour(ld_date_time, lv_summertime);
			ld_date_time := lud_date_time.daytime;
			lv_summertime := lud_date_time.summertime_flag;
			ln_hour_counter := ln_hour_counter + 1;
		END LOOP;

		FOR c_fcst IN c_fcst_nom(p_parcel_no) LOOP
			EcBP_Stor_Fcst_Lift_Nom.createMissingSubDayLift(c_fcst.forecast_id, p_parcel_no);
		END LOOP;
	END LOOP;
END calcSubDayLifting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLiftingCargo
-- Description    : Will call ue_Storage_Lift_Nomination.calcSubDayLifting for each parcel on cargo
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
PROCEDURE calcSubDayLiftingCargo(p_cargo_no NUMBER)
--</EC-DOC>
IS
	CURSOR c_parcel(cp_cargo_no NUMBER)
	IS
		SELECT parcel_no
		  FROM storage_lift_nomination
		 WHERE cargo_no = cp_cargo_no;
BEGIN
	FOR c_cur IN c_parcel(p_cargo_no) LOOP
		ue_Storage_Lift_Nomination.calcSubDayLifting(c_cur.parcel_no);
	END LOOP;
END calcSubDayLiftingCargo;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftedVolSubDay
  -- Description    : Returns the sub daily lifted volume for a parcel based on whether the terminal is IMPORT and unload value is available.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : product_meas_setup, storage_lifting
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLiftedVolSubDay (p_parcel_no NUMBER, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lifting(cp_parcel_no NUMBER, cp_daytime DATE, cp_summer_time VARCHAR2, cp_xtra_qty NUMBER) IS
      SELECT DECODE(cp_xtra_qty, 0, n.lifted_qty, 1, n.lifted_qty2, 2, n.lifted_qty3) lifted_qty,
   		     DECODE(cp_xtra_qty, 0, n.unload_qty, 1, n.unload_qty2, 2, n.unload_qty3) unload_qty
        FROM stor_sub_day_lift_nom n
       WHERE n.parcel_no = cp_parcel_no
         AND n.daytime = cp_daytime
         AND n.summer_time = cp_summer_time;

    lnLiftedVol   NUMBER;
    ln_temp NUMBER;

  BEGIN

		FOR curLifted IN c_stor_lifting(p_parcel_no, p_daytime, p_summer_time, p_xtra_qty) LOOP
			lnLiftedVol := curLifted.lifted_qty;
			IF curLifted.lifted_qty IS NULL AND (ec_stor_version.storage_type(ec_storage_lift_nomination.object_id(p_parcel_no), p_daytime, '<=') = 'IMPORT') THEN
				lnLiftedVol := curLifted.unload_qty;
			END IF;
		END LOOP;

	RETURN lnLiftedVol;

 END getLiftedVolSubDay ;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLoadBalDeltaVolSubDay
  -- Description    : Returns the sub daily lifted volume for a parcel based on whether the terminal is IMPORT and unload value is available.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : product_meas_setup, storage_lifting
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLoadBalDeltaVolSubDay (p_parcel_no NUMBER, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_stor_lifting(cp_parcel_no NUMBER, cp_daytime DATE, cp_summer_time VARCHAR2, cp_xtra_qty NUMBER) IS
      SELECT DECODE(cp_xtra_qty, 0, n.balance_delta_qty, 1, n.balance_delta_qty2, 2, n.balance_delta_qty3) balance_delta_qty
        FROM stor_sub_day_lift_nom n
       WHERE n.parcel_no = cp_parcel_no
         AND n.daytime = cp_daytime
         AND n.summer_time = cp_summer_time;

    lnBalDeltaVol NUMBER;
    ln_temp NUMBER;

  BEGIN

	ln_temp := ecbp_storage_lift_nomination.getLoadBalDeltaVol(p_parcel_no);
	IF ln_temp IS NOT NULL  THEN
		lnBalDeltaVol := 0;
		FOR curLifted IN c_stor_lifting(p_parcel_no, p_daytime, p_summer_time, p_xtra_qty) LOOP
			lnBalDeltaVol := NVL(curLifted.balance_delta_qty, 0);
		END LOOP;
	END IF;

	RETURN lnBalDeltaVol;

 END getLoadBalDeltaVolSubDay;

END EcBP_Storage_Lift_Nomination;