CREATE OR REPLACE PACKAGE BODY EcDp_Inventory IS
/****************************************************************
** Package        :  EcDp_Inventory, body part
**
** $Revision: 1.70 $
**
** Purpose        :  Provide special functions on Inventory. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** erd  : 19.07.2002  Manfred Vonlanthen
**
** Modification history:
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------
** 04.07.2003 JE    Updated procedure: CalcTotalPosition. Replaced movement_ol1_qty with
**                  ytd_movement1_qty when setting total_movement1_qty at the end of the
**                  procedure before updating table INV_VALUATION
** 30.07.2003 JE    PROCEDURE ProcessInventory: Moved update statement UPDATE INV_FIELD_VALUATION above
**                  Calcfieldposition(CIFCur.from_object_id,p_object_id,p_daytime). Added update statement
**                  UPDATE INV_VALUATION. PROCEDURE CalcAvgULRate: Added: last_updated_by = 'SYSTEM' in
**                  update statement UPDATE INV_FIELD_VALUATION and UPDATE INV_VALUATION. PROCEDURE
**                  CalcTotalPosition: Added: last_updated_by = 'SYSTEM' in update statement UPDATE INV_LAYER.
**                  PROCEDURE setInventoryStatus: Added p_user as parameter to the procedure. Changed in
**                  update statement from "VALID1_USER_ID = user" to "VALID1_USER_ID = p_user", and added
**                  last_updated_by = p_user. PROCEDURE CalcAvgOLPrice: Removed this procedure (contain
**                  serious error). Because of "lrec_inv_valuation.ol_avg_rate:= 22;". PROCEDURE
**                  GenMthStaticInvData: Added last_updated_by = 'SYSTEM' in update statement
**                  "UPDATE STIM_MTH_INV_BOOKED".
** 31.07.2003  JE   Added p_user as new parameter to procedure. Included p_user in update and insert statements,
**                  and package calls in the following procedures and functions: PROCEDURE CreateRelInvComp and
**                  PROCEDURE CreateRelInvField
** 07.10.2003  TRA  Change in InstantiateMth. Document_level_code is set to 'OPEN' when inventory is inserted. QA: SRA
** 26.02.2004  AV   Fixed bug in CalcTotalPosition setting last_updated_date = 'SYSTEM'
** 08.03.2004  AV   Extended GetInvMaterialCode to interpet NULL in lv2_stream_item_product_code as 'UNDEFINED'
** 16.03.2004  AV   Changed GenMthBookingData to check on cost object type, also divided between missing
**                  debit and credit cost object.
** 08.12.2006  DN   Removed LOCAL_CURRENCY_CODE reference from GetLocalCurrencyCode function. Renamed column fin_interface_ind to fin_interface_file.
** 05.13.2007  CK   update function call ecdp_fin_account_mapping.validateAccounts based on Jira Issue ECPD-4949
** 08.17.2007  SSK  Updated CalcDistPosition, CalcTotalPosition, CalcDistAllocation, and included two more functions related to Physical Stock valuation
**                  (ECPD-5696)
** 08.28.2007  SSK  UPdated the Inventory Valuation to consider Physical Stock Position (ECPD-5696)
** 08.29.2007  SSK  Added procedures DeleteInventory and ValidateCurrencies (ECPD-5696)
** 20.11.2008  OAN  Added support historic layer and LIFO (ECPD-8432):
**                  Modified the following prodecure to support Historic Layer (Process_historic = TRUE):
**                  CalcDistPosition, GenMthStaticInvData, CalcTotalPosition, CalcAvgULRate, GenMthStaticInvData
**                  Added new procedures and functions for historic layers:
**                  FUNCTION  IsAttributeEditable
**                  PROCEDURE SetStimMthInvHistoric
**                  PROCEDURE SetInvLayerHistoric
**                  PROCEDURE RemoveStimMthInvHistoric
**                  PROCEDURE ProcessHistoricInventory
**                  FUNCTION  IsValuationNotRun
**                  PROCEDURE CheckLayerSave
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetLocalCurrencyCode
-- Description    : Attempt to find any currency override on contract owner company
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: Ec_Currency.object_code
--                  Ec_Company_Version.local_currency_id
--                  ec_inventory_version.company_id
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION GetLocalCurrencyCode(
   p_object_id VARCHAR2, -- inventory object id
   p_daytime   DATE
   )
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_return_val currency.object_code%TYPE;
BEGIN

  lv2_return_val := Ec_Currency.object_code(Ec_Company_Version.local_currency_id(ec_inventory_version.company_id(p_object_id, p_daytime, '<='), p_daytime, '<='));

  RETURN lv2_return_val;

END GetLocalCurrencyCode;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetStimValueByUOM                                                               --
-- Description    : Get the monthly value for an inventory stream_item with the right UOM           --
--                  described in the Inventory configuration                                        --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_INV_BOOKED                                                           --
--                                                                                                 --
-- Using functions:                                                                            --
--                                                                --
--                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetStimValueByUOM(
   p_object_id          VARCHAR2,
   p_daytime             DATE,
   p_target_uom         VARCHAR2
)
RETURN NUMBER
IS
--</EC-DOC>

  CURSOR c_smib(pc_si_id stream_item.object_id%TYPE) IS
    SELECT *
    FROM stim_mth_inv_booked
    WHERE object_id = pc_si_id
    AND daytime = p_daytime;


  lv2_stream_item_id stream_item.object_id%TYPE;
  ln_return_qty NUMBER := 0;
  ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN

  -- Check if parameter UOM is valid
  IF p_target_uom IS NULL THEN
    RETURN NULL;
  END IF;

  lv2_stream_item_id := p_object_id;

  FOR SMIBCur IN c_smib(lv2_stream_item_id) LOOP
    -- copy figures
    IF SMIBCur.net_energy_jo IS NOT NULL THEN
      ltab_uom_set.EXTEND;
      ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_energy_jo;
      ltab_uom_set(ltab_uom_set.LAST).uom := '100MJ';
    END IF;

    IF SMIBCur.net_energy_th IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_energy_th;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'Therms';
    END IF;

    IF SMIBCur.net_energy_wh IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_energy_wh;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'KWH';
    END IF;

    IF SMIBCur.net_energy_be IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_energy_be;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BOE';
    END IF;

    IF SMIBCur.net_mass_ma IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_mass_ma;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MT';
    END IF;

    IF SMIBCur.net_mass_mv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_mass_mv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MTV';
    END IF;

   IF SMIBCur.net_mass_ua IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_mass_ua;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'UST';
    END IF;

    IF SMIBCur.net_mass_uv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_mass_uv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'USTV';
    END IF;

    IF SMIBCur.net_volume_bi IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_volume_bi;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS';
    END IF;

    IF SMIBCur.net_volume_bm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_volume_bm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS15';
    END IF;

    IF SMIBCur.net_volume_sf IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_volume_sf;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSCF';
    END IF;

    IF SMIBCur.net_volume_nm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_volume_nm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MNM3';
    END IF;

    IF SMIBCur.net_volume_sm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMIBCur.net_volume_sm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSM3';
    END IF;

  END LOOP;

  -- get right UOM
  ln_return_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, p_target_uom, p_daytime, p_object_id);

  RETURN ln_return_qty;

END GetStimValueByUOM;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetActualStimPeriodValue
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_actual
--
-- Using functions:
--
--
--
-- Configuration
-- required       : EcDp_Unit.t_uomtable TYPE must exist
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION GetActualStimPeriodValue(
   p_object_id          VARCHAR2,
   p_daytime             DATE
   )
RETURN EcDp_Unit.t_uomtable
--<EC-DOC>
IS
  CURSOR c_sma IS
    SELECT *
    FROM stim_mth_actual
    WHERE object_id = p_object_id
    AND daytime <= p_daytime AND trunc(daytime,'YYYY') = trunc(p_daytime,'YYYY');

  ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
BEGIN

  -- First 'instantiate' the uom set which is to be returned.
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := '100MJ';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'THERMS';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'KWH';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'BOE';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'MT';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'MTV';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'UST';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'USTV';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'MSCF';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'MNM3';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'MSM3';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'BBLS';
  ltab_uom_set.extend;
  ltab_uom_set(ltab_uom_set.last).qty := 0;
  ltab_uom_set(ltab_uom_set.last).uom := 'BBLS15';

  FOR SMACur IN c_sma LOOP
    -- copy figures
    IF SMACur.net_energy_jo IS NOT NULL THEN
        ltab_uom_set(1).qty := ltab_uom_set(1).qty + SMACur.net_energy_jo;
    END IF;

    IF SMACur.net_energy_th IS NOT NULL THEN
       ltab_uom_set(2).qty := ltab_uom_set(2).qty + SMACur.net_energy_th;
    END IF;

    IF SMACur.net_energy_wh IS NOT NULL THEN
       ltab_uom_set(3).qty := ltab_uom_set(3).qty + SMACur.net_energy_wh;
    END IF;

    IF SMACur.net_energy_be IS NOT NULL THEN
       ltab_uom_set(4).qty := ltab_uom_set(4).qty + SMACur.net_energy_be;
    END IF;

    IF SMACur.net_mass_ma IS NOT NULL THEN
       ltab_uom_set(5).qty := ltab_uom_set(5).qty + SMACur.net_mass_ma;
    END IF;

    IF SMACur.net_mass_mv IS NOT NULL THEN
       ltab_uom_set(6).qty := ltab_uom_set(6).qty + SMACur.net_mass_mv;
    END IF;

    IF SMACur.net_mass_ua IS NOT NULL THEN
       ltab_uom_set(7).qty := ltab_uom_set(7).qty + SMACur.net_mass_ua;
    END IF;

    IF SMACur.net_mass_uv IS NOT NULL THEN
       ltab_uom_set(8).qty := ltab_uom_set(8).qty + SMACur.net_mass_uv;
    END IF;

    IF SMACur.net_volume_sf IS NOT NULL THEN
       ltab_uom_set(9).qty := ltab_uom_set(9).qty + SMACur.net_volume_sf;
    END IF;

    IF SMACur.net_volume_nm IS NOT NULL THEN
       ltab_uom_set(10).qty := ltab_uom_set(10).qty + SMACur.net_volume_nm;
    END IF;

    IF SMACur.net_volume_sm IS NOT NULL THEN
       ltab_uom_set(11).qty := ltab_uom_set(11).qty + SMACur.net_volume_sm;
    END IF;

    IF SMACur.net_volume_bi IS NOT NULL THEN
       ltab_uom_set(12).qty := ltab_uom_set(12).qty + SMACur.net_volume_bi;
    END IF;

    IF SMACur.net_volume_bm IS NOT NULL THEN
       ltab_uom_set(13).qty := ltab_uom_set(13).qty + SMACur.net_volume_bi;
    END IF;

  END LOOP;

  RETURN ltab_uom_set;

END GetActualStimPeriodValue;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetBookedStimValueByUOM
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_booked
--
-- Using functions: EcDp_Unit.GetUOMSetQty
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION GetBookedStimValueByUOM(
   p_object_id          VARCHAR2, -- Stream Item ID
   p_daytime             DATE,
   p_target_uom         VARCHAR2
   )
RETURN NUMBER
IS
--<EC-DOC>
CURSOR c_sma(pc_si_id stream_item.object_id%TYPE) IS
  SELECT object_id, daytime,
  SUM(NET_ENERGY_JO) NET_ENERGY_JO,
SUM(NET_ENERGY_TH) NET_ENERGY_TH,
SUM(NET_ENERGY_WH) NET_ENERGY_WH,
SUM(NET_ENERGY_BE) NET_ENERGY_BE,
SUM(NET_MASS_MA) NET_MASS_MA,
SUM(NET_MASS_MV) NET_MASS_MV,
SUM(NET_MASS_UA) NET_MASS_UA,
SUM(NET_MASS_UV) NET_MASS_UV,
SUM(NET_VOLUME_SF) NET_VOLUME_SF,
SUM(NET_VOLUME_NM) NET_VOLUME_NM,
SUM(NET_VOLUME_SM) NET_VOLUME_SM,
SUM(NET_VOLUME_BM) NET_VOLUME_BM,
SUM(NET_VOLUME_BI) NET_VOLUME_BI
    FROM stim_mth_booked
   WHERE object_id = pc_si_id
  AND daytime = p_daytime
  AND TRUNC(production_period,'YYYY') = TRUNC(p_daytime,'YYYY')
   GROUP BY object_id, daytime;

  lv2_stream_item_id stream_item.object_id%TYPE;
  ln_return_qty NUMBER := 0;
  ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
BEGIN

  -- must have a valid UOM
  IF p_target_uom IS NULL THEN
    RETURN NULL;
  END IF;

  lv2_stream_item_id := p_object_id;

  FOR SMACur IN c_sma(lv2_stream_item_id) LOOP

    -- copy figures
    IF SMACur.net_energy_jo IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_jo;
       ltab_uom_set(ltab_uom_set.LAST).uom := '100MJ';
    END IF;

    IF SMACur.net_energy_th IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_th;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'THERMS';
    END IF;

    IF SMACur.net_energy_wh IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_wh;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'KWH';
    END IF;

    IF SMACur.net_energy_be IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_be;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BOE';
    END IF;

    IF SMACur.net_mass_ma IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_ma;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MT';
    END IF;

    IF SMACur.net_mass_mv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_mv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MTV';
    END IF;

    IF SMACur.net_mass_ua IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_ua;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'UST';
    END IF;

    IF SMACur.net_mass_uv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_uv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'USTV';
    END IF;

    IF SMACur.net_volume_bi IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_bi;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS';
    END IF;

    IF SMACur.net_volume_bm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_bm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS15';
    END IF;

    IF SMACur.net_volume_sf IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_sf;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSCF';
    END IF;

    IF SMACur.net_volume_nm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_nm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MNM3';
    END IF;

    IF SMACur.net_volume_sm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_sm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSM3';
    END IF;

  END LOOP;

  -- get right UOM
  ln_return_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, p_target_uom, p_daytime, p_object_id);

  RETURN ln_return_qty;

END GetBookedStimValueByUOM;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_actual
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------

FUNCTION GetActualPeriodDistMovement(
   p_object_id          VARCHAR2, -- Field object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   )
RETURN EcDp_Unit.t_uomtable
IS
--</EC-DOC>
CURSOR c_sma IS
 SELECT sma.object_id stream_item_id
   FROM stim_mth_actual sma, inventory_stim_setup iss, inventory_field inf, stream_item_version siv
  WHERE sma.daytime = p_daytime
    AND inf.inventory_id = p_inventory_id
    AND inf.field_id = p_object_id
    AND iss.object_id = inf.inventory_id
    AND iss.stream_item_id = sma.object_id
    AND siv.object_id = sma.object_id
    AND siv.field_id = inf.field_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = sma.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type IN ('INV','OWN')
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime);

ltab_temp EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
ltab_movement EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN

  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := '100MJ';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'THERMS';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'KWH';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BOE';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MT';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MTV';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'UST';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'USTV';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MSCF';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MNM3';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MSM3';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BBLS';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BBLS15';

  FOR SMACur IN c_sma LOOP
    ltab_temp := GetActualStimPeriodValue(SMACur.stream_item_id, p_daytime);

    ltab_movement(1).qty  := ltab_movement(1).qty  + ltab_temp(1).qty;  -- 100MJ
    ltab_movement(2).qty  := ltab_movement(2).qty  + ltab_temp(2).qty;  -- THERMS
    ltab_movement(3).qty  := ltab_movement(3).qty  + ltab_temp(3).qty;  -- KWH
    ltab_movement(4).qty := ltab_movement(4).qty + ltab_temp(4).qty; -- BOE
    ltab_movement(5).qty  := ltab_movement(5).qty  + ltab_temp(5).qty;  -- MT
    ltab_movement(6).qty  := ltab_movement(6).qty  + ltab_temp(6).qty;  -- MTV
    ltab_movement(7).qty  := ltab_movement(7).qty  + ltab_temp(7).qty;  -- UST
    ltab_movement(8).qty  := ltab_movement(8).qty  + ltab_temp(8).qty;  -- USTV
    ltab_movement(9).qty  := ltab_movement(9).qty  + ltab_temp(9).qty;  -- MSCF
    ltab_movement(10).qty  := ltab_movement(10).qty  + ltab_temp(10).qty;  -- MNM3
    ltab_movement(11).qty := ltab_movement(11).qty + ltab_temp(11).qty; -- MSM3
    ltab_movement(12).qty := ltab_movement(12).qty + ltab_temp(12).qty; -- BBLS60
    ltab_movement(13).qty := ltab_movement(13).qty + ltab_temp(13).qty; -- BBLS15
  END LOOP;

  RETURN ltab_movement;

END GetActualPeriodDistMovement;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetPhysicalStockDistMovement
-- Description    : Basically the same function as GetActualPeriodDistMovement except that it uses inventory stream item type = 'PHY'
--                  to get the stream item holding the physical stock value.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetPhysicalStockDistMovement(
   p_object_id          VARCHAR2, -- Field object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   )
RETURN EcDp_Unit.t_uomtable
IS
--</EC-DOC>

CURSOR c_sma IS
 SELECT sma.object_id stream_item_id
   FROM stim_mth_actual sma, inventory_stim_setup iss, inventory_field inf, stream_item_version siv
  WHERE sma.daytime = p_daytime
    AND inf.inventory_id = p_inventory_id
    AND inf.field_id = p_object_id
    AND iss.object_id = inf.inventory_id
    AND iss.stream_item_id = sma.object_id
    AND siv.object_id = sma.object_id
    AND siv.field_id = inf.field_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = sma.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type = 'PHY'
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime);

ltab_temp EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
ltab_movement EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN

  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := '100MJ';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'THERMS';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'KWH';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BOE';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MT';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MTV';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'UST';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'USTV';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MSCF';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MNM3';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'MSM3';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BBLS';
  ltab_movement.extend;
  ltab_movement(ltab_movement.last).qty := 0;
  ltab_movement(ltab_movement.last).uom := 'BBLS15';

  FOR SMACur IN c_sma LOOP
    ltab_temp := GetActualStimPeriodValue(SMACur.stream_item_id, p_daytime);

    ltab_movement(1).qty  := ltab_movement(1).qty  + ltab_temp(1).qty;  -- 100MJ
    ltab_movement(2).qty  := ltab_movement(2).qty  + ltab_temp(2).qty;  -- THERMS
    ltab_movement(3).qty  := ltab_movement(3).qty  + ltab_temp(3).qty;  -- KWH
    ltab_movement(4).qty := ltab_movement(4).qty + ltab_temp(4).qty; -- BOE
    ltab_movement(5).qty  := ltab_movement(5).qty  + ltab_temp(5).qty;  -- MT
    ltab_movement(6).qty  := ltab_movement(6).qty  + ltab_temp(6).qty;  -- MTV
    ltab_movement(7).qty  := ltab_movement(7).qty  + ltab_temp(7).qty;  -- UST
    ltab_movement(8).qty  := ltab_movement(8).qty  + ltab_temp(8).qty;  -- USTV
    ltab_movement(9).qty  := ltab_movement(9).qty  + ltab_temp(9).qty;  -- MSCF
    ltab_movement(10).qty  := ltab_movement(10).qty  + ltab_temp(10).qty;  -- MNM3
    ltab_movement(11).qty := ltab_movement(11).qty + ltab_temp(11).qty; -- MSM3
    ltab_movement(12).qty := ltab_movement(12).qty + ltab_temp(12).qty; -- BBLS60
    ltab_movement(13).qty := ltab_movement(13).qty + ltab_temp(13).qty; -- BBLS15
  END LOOP;

  RETURN ltab_movement;

END GetPhysicalStockDistMovement;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDistPriorPeriodAdjustment
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION GetDistPriorPeriodAdjustment(
   p_object_id          VARCHAR2, -- Field Object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   )
RETURN EcDp_Unit.t_uomtable
IS
--</EC-DOC>
CURSOR c_sma IS
 SELECT sma.object_id stream_item_id
   FROM stim_mth_actual sma, inventory_stim_setup iss, inventory_field inf, stream_item_version siv
  WHERE sma.daytime = p_daytime
    AND inf.inventory_id = p_inventory_id
    AND inf.field_id = p_object_id
    AND iss.object_id = inf.inventory_id
    AND iss.stream_item_id = sma.object_id
    AND siv.object_id = sma.object_id
    AND siv.field_id = inf.field_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = sma.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type IN ('INV','OWN')
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime);

ltab_temp EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
ltab_pya EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := '100MJ';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'THERMS';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'KWH';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BOE';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MT';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MTV';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'UST';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'USTV';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MSCF';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MNM3';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MSM3';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BBLS';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BBLS15';

    -- for all stream item for the inventory for this dist
    -- summarize all uom subgroups
    FOR SMACur IN c_sma LOOP
        ltab_temp := GetStimPriorPeriodAdjustment(SMACur.stream_item_id,p_daytime);

        ltab_pya(1).qty  := ltab_pya(1).qty  + ltab_temp(1).qty;  -- 100MJ
        ltab_pya(2).qty  := ltab_pya(2).qty  + ltab_temp(2).qty;  -- THERMS
        ltab_pya(3).qty  := ltab_pya(3).qty  + ltab_temp(3).qty;  -- KWH
        ltab_pya(4).qty := ltab_pya(4).qty + ltab_temp(4).qty;    -- BOE
        ltab_pya(5).qty  := ltab_pya(5).qty  + ltab_temp(5).qty;  -- MT
        ltab_pya(6).qty  := ltab_pya(6).qty  + ltab_temp(6).qty;  -- MTV
        ltab_pya(7).qty  := ltab_pya(7).qty  + ltab_temp(7).qty;  -- UST
        ltab_pya(8).qty  := ltab_pya(8).qty  + ltab_temp(8).qty;  -- USTV
        ltab_pya(9).qty  := ltab_pya(9).qty  + ltab_temp(9).qty;  -- MSCF
        ltab_pya(10).qty  := ltab_pya(10).qty  + ltab_temp(10).qty;  -- MNM3
        ltab_pya(11).qty := ltab_pya(11).qty + ltab_temp(11).qty; -- MSM3
        ltab_pya(12).qty := ltab_pya(12).qty + ltab_temp(12).qty; -- BBLS60
        ltab_pya(13).qty := ltab_pya(13).qty + ltab_temp(13).qty; -- BBLS15
    END LOOP;

    RETURN ltab_pya;

END GetDistPriorPeriodAdjustment;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDistPriorPeriodPhysicalStockAdj
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION GetDistPriorPeriodPhyStockAdj(
   p_object_id          VARCHAR2, -- Field Object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   )
RETURN EcDp_Unit.t_uomtable
IS
--</EC-DOC>
CURSOR c_sma IS
 SELECT sma.object_id stream_item_id
   FROM stim_mth_actual sma, inventory_stim_setup iss, inventory_field inf, stream_item_version siv
  WHERE sma.daytime = p_daytime
    AND inf.inventory_id = p_inventory_id
    AND inf.field_id = p_object_id
    AND iss.object_id = inf.inventory_id
    AND iss.stream_item_id = sma.object_id
    AND siv.object_id = sma.object_id
    AND siv.field_id = inf.field_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = sma.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type IN ('PHY')
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime);

ltab_temp EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
ltab_pya EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := '100MJ';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'THERMS';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'KWH';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BOE';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MT';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MTV';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'UST';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'USTV';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MSCF';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MNM3';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'MSM3';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BBLS';
    ltab_pya.extend;
    ltab_pya(ltab_pya.last).qty := 0;
    ltab_pya(ltab_pya.last).uom := 'BBLS15';

    -- for all stream item for the inventory for this dist
    -- summarize all uom subgroups
    FOR SMACur IN c_sma LOOP
        ltab_temp := GetStimPriorPeriodAdjustment(SMACur.stream_item_id,p_daytime);

        ltab_pya(1).qty  := ltab_pya(1).qty  + ltab_temp(1).qty;  -- 100MJ
        ltab_pya(2).qty  := ltab_pya(2).qty  + ltab_temp(2).qty;  -- THERMS
        ltab_pya(3).qty  := ltab_pya(3).qty  + ltab_temp(3).qty;  -- KWH
        ltab_pya(4).qty := ltab_pya(4).qty   + ltab_temp(4).qty; -- BOE
        ltab_pya(5).qty  := ltab_pya(5).qty  + ltab_temp(5).qty;  -- MT
        ltab_pya(6).qty  := ltab_pya(6).qty  + ltab_temp(6).qty;  -- MTV
        ltab_pya(7).qty  := ltab_pya(7).qty  + ltab_temp(7).qty;  -- UST
        ltab_pya(8).qty  := ltab_pya(8).qty  + ltab_temp(8).qty;  -- USTV
        ltab_pya(9).qty  := ltab_pya(9).qty  + ltab_temp(9).qty;  -- MSCF
        ltab_pya(10).qty  := ltab_pya(10).qty  + ltab_temp(10).qty;  -- MNM3
        ltab_pya(11).qty := ltab_pya(11).qty + ltab_temp(11).qty; -- MSM3
        ltab_pya(12).qty := ltab_pya(12).qty + ltab_temp(12).qty; -- BBLS60
        ltab_pya(13).qty := ltab_pya(13).qty + ltab_temp(13).qty; -- BBLS15
    END LOOP;

    RETURN ltab_pya;

END GetDistPriorPeriodPhyStockAdj;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetStimBookedProdValueByUOM
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_booked
--
-- Using functions: EcDp_Unit.GetUOMSetQty
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetStimBookedProdValueByUOM(
   p_object_id           VARCHAR2, -- Stream Item Object ID
   p_daytime              DATE,
   p_target_uom          VARCHAR2
)
RETURN NUMBER
IS
--</EC-DOC>
CURSOR c_sma(pc_si_id stream_item.object_id%TYPE) IS
  SELECT object_id, daytime,
  SUM(NET_ENERGY_JO) NET_ENERGY_JO,
SUM(NET_ENERGY_TH) NET_ENERGY_TH,
SUM(NET_ENERGY_WH) NET_ENERGY_WH,
SUM(NET_ENERGY_BE) NET_ENERGY_BE,
SUM(NET_MASS_MA) NET_MASS_MA,
SUM(NET_MASS_MV) NET_MASS_MV,
SUM(NET_MASS_UA) NET_MASS_UA,
SUM(NET_MASS_UV) NET_MASS_UV,
SUM(NET_VOLUME_SF) NET_VOLUME_SF,
SUM(NET_VOLUME_NM) NET_VOLUME_NM,
SUM(NET_VOLUME_SM) NET_VOLUME_SM,
SUM(NET_VOLUME_BM) NET_VOLUME_BM,
SUM(NET_VOLUME_BI) NET_VOLUME_BI
    FROM stim_mth_booked
   WHERE object_id = pc_si_id
  AND daytime = p_daytime
  AND TRUNC(production_period,'YYYY') = TRUNC(p_daytime,'YYYY')
   GROUP BY object_id, daytime;

lv2_stream_item_id stream_item.object_id%TYPE;
ln_return_qty NUMBER := 0;
ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

BEGIN
   -- must have a valid UOM
  IF p_target_uom IS NULL THEN
    RETURN NULL;
  END IF;

  lv2_stream_item_id := p_object_id;

  FOR SMACur IN c_sma(lv2_stream_item_id) LOOP
    -- copy figures
    IF SMACur.net_energy_jo IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_jo;
       ltab_uom_set(ltab_uom_set.LAST).uom := '100MJ';
    END IF;

    IF SMACur.net_energy_th IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_th;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'THERMS';
    END IF;

    IF SMACur.net_energy_wh IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_wh;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'KWH';
    END IF;

    IF SMACur.net_energy_be IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_energy_be;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BOE';
    END IF;

    IF SMACur.net_mass_ma IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_ma;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MT';
    END IF;

    IF SMACur.net_mass_mv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_mv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MTV';
    END IF;

    IF SMACur.net_mass_ua IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_ua;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'UST';
    END IF;

    IF SMACur.net_mass_uv IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_mass_uv;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'USTV';
    END IF;

    IF SMACur.net_volume_bi IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_bi;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS';
    END IF;

    IF SMACur.net_volume_bm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_bm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'BBLS15';
    END IF;

    IF SMACur.net_volume_sf IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_sf;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSCF';
    END IF;

    IF SMACur.net_volume_nm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_nm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MNM3';
    END IF;

    IF SMACur.net_volume_sm IS NOT NULL THEN
       ltab_uom_set.EXTEND;
       ltab_uom_set(ltab_uom_set.LAST).qty := SMACur.net_volume_sm;
       ltab_uom_set(ltab_uom_set.LAST).uom := 'MSM3';
    END IF;

  END LOOP;

  -- get right UOM
  ln_return_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, p_target_uom, p_daytime, p_object_id);

  RETURN ln_return_qty;

END GetStimBookedProdValueByUOM;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDistBookedProdYTD
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : system_mth_status
--
-- Using functions: GetDistBookedTotProdMTH
--                  ec_inventory_version.inventory_type
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetDistBookedProdYTD(
   p_object_id          VARCHAR2,  -- Field Object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE,
   p_target_uom          VARCHAR2
)
RETURN NUMBER
IS
--</EC-DOC>
CURSOR c_calculate IS
  SELECT Sum(GetDistBookedTotProdMTH(p_object_id, p_Inventory_Id, daytime, p_Target_Uom)) result
    FROM system_mth_status
   WHERE daytime BETWEEN to_date(to_char(p_daytime,'YYYY') || '0101','YYYYMMDD') AND p_daytime
   AND country_id=ec_company_version.country_id(ec_inventory_version.company_id(p_inventory_id, p_daytime, '<='), p_daytime, '<=')
   AND company_id=ec_inventory_version.company_id(p_inventory_id, p_daytime, '<=')
   AND booking_area_code='QUANTITIES';

ln_return_val NUMBER:= 0;
lv2_inv_dist_type inventory_version.dist_class%TYPE := ec_inventory_version.dist_class(p_inventory_id,p_daytime,'<=');

BEGIN
  FOR mycur IN c_calculate LOOP
    IF (lv2_inv_dist_type = 'FIELD_GROUP') THEN
      ln_return_val := mycur.result;

    ELSIF (lv2_inv_dist_type = 'FIELD') THEN
      ln_return_val := 1;

    END IF;
  END LOOP;

  RETURN ln_return_val;

END GetDistBookedProdYTD;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetYTDProductionIfFG
-- Description    : If dist_id is provided, then value is taken from inv_dist_valuation else, inv_valuation
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Used by business function Inventory Process Rate Calculation to avoid showing this value in
--                 the screen if dist type = SINGLE FIELD.
-----------------------------------------------------------------------------------------------------
FUNCTION GetYTDProductionIfFG(p_object_id VARCHAR2, p_daytime DATE, p_dist_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER


IS
lv2_inv_dist_type inventory_version.dist_class%TYPE := ec_inventory_version.dist_class(p_object_id,p_daytime,'<=');


BEGIN

IF (lv2_inv_dist_type = 'FIELD_GROUP') THEN

   IF p_dist_id IS NULL THEN
      RETURN ec_inv_valuation.ytd_prod_qty1(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'),'<=');
   ELSE
      RETURN ec_inv_dist_valuation.ytd_prod_qty1(p_object_id,p_dist_id,p_daytime, to_char(p_daytime, 'YYYY'),'<=');
   END IF;
END IF;

RETURN NULL;

END GetYTDProductionIfFG;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDistBookedTotProdMTH
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_booked, inventory_stim_setup
--
-- Using functions: GetStimBookedProdValueByUOM
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------

FUNCTION GetDistBookedTotProdMTH(
   p_object_id          VARCHAR2, -- Field Object ID
   p_inventory_id        VARCHAR2,
   p_daytime             DATE,
   p_target_uom          VARCHAR2
)
RETURN NUMBER
IS
--</EC-DOC>
CURSOR c_sma IS
 SELECT smb.object_id stream_item_id
   FROM stim_mth_booked smb, inventory_stim_setup iss, inventory_field inf, stream_item_version siv
  WHERE smb.daytime = p_daytime
    AND smb.production_period = smb.daytime
    AND inf.inventory_id = p_inventory_id
    AND inf.field_id = p_object_id
    AND iss.object_id = inf.inventory_id
    AND iss.stream_item_id = smb.object_id
    AND siv.object_id = smb.object_id
    AND siv.field_id = inf.field_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = smb.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type = 'PROD'
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime);

ln_return_qty NUMBER:= 0;

BEGIN
  -- must have a valid UOM
  IF p_target_uom IS NULL THEN
    RETURN NULL;
  END IF;

  FOR SMACur IN c_sma LOOP
    ln_return_qty := ln_return_qty + Nvl(GetStimBookedProdValueByUOM(SMACur.stream_item_id, p_daytime, p_target_uom),0);
  END LOOP;

  RETURN ln_return_qty;

END GetDistBookedTotProdMTH;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetInvActTotProdYTD
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : inventory_field
--
-- Using functions: GetDistBookedProdYTD
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetInvActTotProdYTD(
   p_object_id          VARCHAR2, -- Inventory ID
   p_daytime             DATE,
   p_target_uom          VARCHAR2
)
RETURN NUMBER
IS
--</EC-DOC>
CURSOR c_if IS
  SELECT inf.field_id
    FROM inventory_field inf
   WHERE inf.inventory_id = p_object_id
     AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1));

ln_return_val NUMBER:= 0;

BEGIN
  FOR IFcur IN c_if LOOP
    ln_return_val := ln_return_val + NVL(GetDistBookedProdYTD(IFcur.field_id, p_object_id, p_daytime, p_target_uom),0);
  END LOOP;

  RETURN ln_return_val;

END GetInvActTotProdYTD;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDistRateVal
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : inventory_field, inventory_field_version, product_price, product_price_version, product_price_value
--
-- Using functions: ec_inventory_version.review_period
--                  ec_field_version.name
-- Configuration
-- required       :
--
-- Behaviour      : This function will use either of overlift/underlift/physical_stock price object based on the new argument p_rate_type
--                  to retrieve the price. The price will be the sum of all price elements on the price concept configured on the price object.
-----------------------------------------------------------------------------------------------------
FUNCTION GetDistRateVal(
   p_object_id    VARCHAR2,-- field ID
   p_inventory_id VARCHAR2,
   p_rate_type    VARCHAR2, -- Either of UL, OL or PS
   p_daytime      DATE,
   p_ignore_error BOOLEAN DEFAULT FALSE
) RETURN NUMBER
IS

-- cursor that pick price values from the price objects that are connected to the inventory/field
-- The cursor uses price_object ahd price_concept, and sum eiter adj. price or calc. price dependent on which has values.
CURSOR c_rate(cp_price_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_review_period NUMBER) IS
  SELECT sum(nvl(p.adj_price_value, p.calc_price_value)) rate,
         add_months(max(p.daytime), cp_review_period) expiry_date
    FROM inventory_field         inf,
         inventory_field_version infv,
         product_price           pp,
         product_price_version   ppv,
         product_price_value     p
   WHERE inf.field_id = p_object_id
     AND inf.inventory_id = p_inventory_id
     AND infv.object_id = inf.object_id
     AND infv.daytime = (SELECT Max(i.daytime)
                           FROM inventory_field_version i
                          WHERE inf.object_id = i.object_id
                            AND i.daytime <= p_daytime)
     AND pp.object_id = cp_price_object_id
     AND pp.price_concept_code = cp_price_concept_code
     AND pp.object_id = ppv.object_id
     AND pp.start_date <= p_daytime
     AND nvl(pp.end_date, p_daytime + 1) > p_daytime
     AND ppv.daytime = (SELECT Max(ppv2.daytime)
                          FROM product_price_version ppv2
                         WHERE ppv.object_id = ppv2.object_id
                           AND ppv2.daytime <= p_daytime)
     AND p.object_id = cp_price_object_id
     AND p.price_concept_code = pp.price_concept_code
     AND p.daytime = (SELECT Max(p2.daytime)
                        FROM product_price_value p2
                       WHERE pp.object_id = p2.object_id
                         AND p2.daytime <= p_daytime);


ln_return_val           NUMBER;
ln_review_period        inventory_version.review_period%TYPE;
no_production_rate      EXCEPTION;
expired_production_rate EXCEPTION;
invalid_review_period   EXCEPTION;
no_rate_type            EXCEPTION;
lv2_inventory_name      inventory_version.name%TYPE;
lv2_price_object        VARCHAR2(32);
lv2_price_concept_code  VARCHAR2(32);

BEGIN


  ln_review_period := ec_inventory_version.review_period(p_inventory_id, p_daytime, '<=');

  IF ln_review_period IS NULL OR ln_review_period < 1 THEN
    RAISE invalid_review_period;
  END IF;

-- The rate type will determine which rate is returned
IF (p_rate_type = 'UL') THEN
    -- Retrieving underlift price object, Changed to pull from inventory_field_version table after column change
       SELECT infv.ul_price_obj_id
      INTO lv2_price_object
      FROM inventory_field inf,inventory_field_version infv
     WHERE inventory_id = p_inventory_id
       AND field_id = p_object_id
       and inf.object_id=infv.object_id;

  ELSIF (p_rate_type = 'OL') THEN
             -- Retrieving overlift price object,Changed to pull from inventory_field_version table after column change
                     SELECT infv.ol_price_obj_id
              INTO lv2_price_object
               FROM inventory_field inf,inventory_field_version infv
             WHERE inventory_id = p_inventory_id
               AND field_id = p_object_id
               and  inf.object_id=infv.object_id;

    ELSIF (p_rate_type = 'PS') THEN
           -- Retrieving physical stock price object,Changed to pull from inventory_field_version table after column change
        SELECT infv.phy_stock_price_obj_id
            INTO lv2_price_object
          FROM inventory_field inf,inventory_field_version infv
           WHERE inventory_id = p_inventory_id
             AND field_id = p_object_id
             and  inf.object_id=infv.object_id;
        ELSE
             RAISE no_rate_type;
END IF;

  lv2_price_concept_code := ec_product_price.price_concept_code(lv2_price_object);


    -- Finding rate
    FOR rate IN c_rate(lv2_price_object,lv2_price_concept_code,ln_review_period) LOOP

    IF ln_return_val IS NULL THEN
      ln_return_val := 0;
    END IF;

    IF p_daytime >= rate.expiry_date THEN -- not valid if expiry date is same as processing date
      lv2_inventory_name := ec_inventory_version.name(p_object_id,p_daytime,'<=');
      RAISE expired_production_rate;
    ELSE
      ln_return_val := rate.rate;
    END IF;

  END LOOP;

    -- No rate is allowed for Physical Stock if the Rate object has not been configured.
  IF (p_rate_type = 'PS' AND lv2_price_object IS NULL AND ln_return_val IS NULL) THEN
     RETURN 0;

  -- In general, a rate value is required
  ELSIF ln_return_val IS NULL AND p_ignore_error = FALSE THEN
    RAISE no_production_rate;
  END IF;

  RETURN ln_return_val;

EXCEPTION
  WHEN no_production_rate THEN
    Raise_Application_Error(-20000,'No valid '|| p_rate_type || ' rate for dist ' || ec_field_version.name(p_object_id, p_daytime, '<=') || '.' );

WHEN no_rate_type THEN
    Raise_Application_Error(-20000,'No valid rate type specified. Should be either UL, OL or PS');

  WHEN invalid_review_period THEN
    Raise_Application_Error(-20000,'No valid review period for inventory ' || lv2_inventory_name || '.');

  WHEN expired_production_rate THEN
    Raise_Application_Error(-20000,'Rates for inventory '|| lv2_inventory_name ||' have expired.');
END GetDistRateVal;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetInvAvgRate
-- Description    : Function has been renamed from GetInvULAvgRate to GetInvAvgRate as the average rate now is calculated for physical stock and overlift
--                  in addition to underlift numbers. The overlift average price and the physical stock average price will use price objects for that specific means
--                  however, the production the prices are weighted upon are still the main production numbers for all three average prices (ECPD-5696)
--                  2007-20-08   skjorsti
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : inventory_field
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetInvAvgRate(
   p_object_id    VARCHAR2, -- Inventory ID
   p_daytime      DATE,
   p_rate_type    VARCHAR2, -- Either of UL, OL or PS
   p_target_uom   VARCHAR2,
   p_ignore_error BOOLEAN DEFAULT FALSE
) RETURN NUMBER
IS
--</EC-DOC>
v_dist_prod_ytd   NUMBER;
v_dist_rate       NUMBER;
v_Inv_ProdRate    NUMBER := 0;
v_inv_totprod     NUMBER := 0;

CURSOR c_dist IS
  SELECT inf.field_id
    FROM inventory_field inf
   WHERE inf.inventory_id = p_object_id
     AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1));

ln_return_val NUMBER:= 0;
division_by_zero EXCEPTION;

BEGIN

    FOR Dist IN c_dist LOOP
      v_dist_prod_ytd := GetDistBookedProdYTD(Dist.field_id, p_object_id, p_daytime, p_target_uom);
      v_dist_rate := GetDistRateVal(Dist.field_id, p_object_id, p_rate_type, p_daytime, p_ignore_error);
      v_inv_prodrate := v_inv_prodrate + (v_dist_prod_ytd * v_dist_rate);
    END LOOP;

    v_inv_totprod :=  GetInvActTotProdYTD(p_object_id, p_daytime, p_target_uom);

    IF v_inv_totprod = 0 THEN
      ln_return_val := 0;
    ELSE
      -- Raise exception if division by zero
      IF v_inv_totprod = 0 THEN
         RAISE division_by_zero;
      ELSE

         ln_return_val := (v_inv_prodrate / v_inv_totprod);
      END IF;
    END IF;

  RETURN ln_return_val;

EXCEPTION
  WHEN division_by_zero THEN
    Raise_Application_Error(-20000, 'Division by zero during production rate calculation');
END GetInvAvgRate;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CalcDistPosition
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : INV_DIST_VALUATION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Changes related to ECPD-5696 (Inventory Valuation - support for Physical Stock);
--                  New columns related to Physical Stock valuation are populated. These are:

--                  - YTD_PS_MOVEMENT_QTY1;         Year to date physical stock inventory movement
--                  - YTD_PS_MOVEMENT_QTY2
--                  - CLOSING_POSITION_QTY1         Contains the total closing position including the physical stock
--                  - CLOSING_POSITION_QTY2
--                  - YEAR_OPENING_PS_POS_QTY1      Year opening physical stock position
--                  - YEAR_OPENING_PS_POS_QTY2
--                  - PPA_PS_QTY1                   Prior period adjustment for physical stock
--                  - PPA_PS_QTY2
--                  - CLOSING_PS_POSITION_QTY1      Closing physical stock position
--                  - CLOSING_PS_POSITION_QTY2
--
--                  There's also changes to existing columns as the closing_ul/ol_position1/2_qty are populated without the physical stock
-----------------------------------------------------------------------------------------------------
PROCEDURE CalcDistPosition(
   p_inventory_id     VARCHAR2,
   p_daytime          DATE,
   p_user             VARCHAR2,
   p_process_historic VARCHAR2 DEFAULT 'FALSE'
   )
IS

CURSOR c_if IS
  SELECT inf.field_id
    FROM inventory_field inf
   WHERE inf.inventory_id = p_inventory_id
     AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1));

CURSOR c_sum_dist(cp_inventory_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2) IS
SELECT
     SUM(YTD_MOVEMENT_QTY1) YTD_MOVEMENT_QTY1
    ,SUM(YTD_MOVEMENT_QTY2) YTD_MOVEMENT_QTY2
    ,SUM(CLOSING_UL_POSITION_QTY1) CLOSING_UL_POSITION_QTY1
    ,SUM(CLOSING_UL_POSITION_QTY2) CLOSING_UL_POSITION_QTY2
    ,SUM(CLOSING_OL_POSITION_QTY1) CLOSING_OL_POSITION_QTY1
    ,SUM(CLOSING_OL_POSITION_QTY2) CLOSING_OL_POSITION_QTY2
    ,SUM(YTD_PROD_QTY1) YTD_PROD_QTY1
    ,SUM(YTD_PROD_QTY2) YTD_PROD_QTY2
    ,SUM(OPENING_UL_POSITION_QTY1) OPENING_UL_POSITION_QTY1
    ,SUM(OPENING_UL_POSITION_QTY2) OPENING_UL_POSITION_QTY2
    ,SUM(CLOSING_PS_POSITION_QTY1) CLOSING_PS_POSITION_QTY1
    ,SUM(CLOSING_PS_POSITION_QTY2) CLOSING_PS_POSITION_QTY2
    ,SUM(OPENING_OL_POSITION_QTY1) OPENING_OL_POSITION_QTY1
    ,SUM(OPENING_OL_POSITION_QTY2) OPENING_OL_POSITION_QTY2
    ,SUM(OPENING_PS_POSITION_QTY1) OPENING_PS_POSITION_QTY1
    ,SUM(OPENING_PS_POSITION_QTY2) OPENING_PS_POSITION_QTY2
    ,SUM(TOTAL_CLOSING_POS_QTY1) TOTAL_CLOSING_POS_QTY1
    ,SUM(TOTAL_CLOSING_POS_QTY2) TOTAL_CLOSING_POS_QTY2
    ,SUM(PPA_PS_QTY1) PPA_PS_QTY1
    ,SUM(PPA_PS_QTY2) PPA_PS_QTY2
    ,SUM(PS_MOVEMENT_QTY1) PS_MOVEMENT_QTY1
    ,SUM(PS_MOVEMENT_QTY2) PS_MOVEMENT_QTY2
    ,SUM(YTD_PS_MOVEMENT_QTY1) YTD_PS_MOVEMENT_QTY1
    ,SUM(YTD_PS_MOVEMENT_QTY2) YTD_PS_MOVEMENT_QTY2
    ,SUM(YTD_OL_MOV_QTY1) YTD_OL_MOV_QTY1
    ,SUM(YTD_OL_MOV_QTY2) YTD_OL_MOV_QTY2
    ,SUM(YTD_UL_MOV_QTY1) YTD_UL_MOV_QTY1
    ,SUM(YTD_UL_MOV_QTY2) YTD_UL_MOV_QTY2
FROM
    inv_dist_valuation idv
    WHERE object_id = cp_inventory_id
    AND daytime = cp_daytime
    AND year_code = cp_year_code;

--</EC-DOC>
  ln_ytd_movement1              NUMBER;
  ln_ytd_movement2              NUMBER;
  ln_ytd_movement_incl_adj1     NUMBER;
  ln_ytd_movement_incl_adj2     NUMBER;
  ln_prior_period_adj1          NUMBER;
  ln_prior_period_adj2          NUMBER;
  ln_prior_period_ps_adj1       NUMBER;
  ln_prior_period_ps_adj2       NUMBER;
  ln_year_opening_position1     NUMBER;
  ln_year_opening_position2     NUMBER;
  ln_opening_ul_position1       NUMBER;
  ln_opening_ul_position2       NUMBER;
  ln_opening_ol_position1       NUMBER;
  ln_opening_ol_position2       NUMBER;
  ln_opening_ps_position1       NUMBER;
  ln_opening_ps_position2       NUMBER;
  ln_closing_position_qty1      NUMBER; -- Total position including Physical Stock
  ln_closing_position_qty2      NUMBER; -- Total position including Physical Stock
  ln_closing_ul_position1       NUMBER;
  ln_closing_ul_position2       NUMBER;
  ln_closing_ul_prior_year_pos1 NUMBER;
  ln_closing_ul_prior_year_pos2 NUMBER;
  ln_closing_ps_prior_year_pos1 NUMBER;
  ln_closing_ps_prior_year_pos2 NUMBER;
  ln_closing_ol_position1       NUMBER;
  ln_closing_ol_position2       NUMBER;
  ln_closing_ps_position1       NUMBER;
  ln_closing_ps_position2       NUMBER;
  ln_ytd_ps_movement1           NUMBER;
  ln_ytd_ps_movement2           NUMBER;
  lv2_inv_type                  VARCHAR(2000);
  lv2_UOM1                      VARCHAR(2000);
  lv2_UOM2                      VARCHAR2(2000);
  lv2_book_category             VARCHAR2(2000);
  ld_prior_year                 DATE;
  ltab_as_is                    EcDp_Unit.t_uomtable;
  ltab_ppa                      EcDp_Unit.t_uomtable;
  ltab_ppa_ps                   EcDp_Unit.t_uomtable;
  ltab_fpa                      EcDp_Unit.t_uomtable;
  ltab_ps                       EcDp_Unit.t_uomtable;

  lrec_prev_mth      INV_DIST_VALUATION%ROWTYPE;

  lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;
  lrec_prev_inv_dist_valuation inv_dist_valuation%ROWTYPE;

  lrec_inv_valuation inv_valuation%ROWTYPE;
  lrec_prev_inv_valuation inv_valuation%ROWTYPE;

  ltab_dist_mov t_dist_mov := t_dist_mov();

  ln_total_mov_qty1 NUMBER;
  ln_total_mov_qty2 NUMBER;
  ln_ppa_total_mov_qty1 NUMBER;
  ln_ppa_total_mov_qty2 NUMBER;
  ln_total_ps_mov_qty1 NUMBER;
  ln_total_ps_mov_qty2 NUMBER;
  ln_ppa_total_ps_mov_qty1 NUMBER;
  ln_ppa_total_ps_mov_qty2 NUMBER;

  lv2_valuation_method VARCHAR2(200) := 'FIFO';

  lv2_opening VARCHAR2(200);
  lv2_closing VARCHAR2(200);

BEGIN
/*
    IF (p_process_historic = 'TRUE') THEN -- Do not touch historic data since there is no stream item value for them
        RETURN;
    END IF;
*/

    -- If Historic layer, sum up the dist values for the total inv value
    IF (p_process_historic = 'TRUE') THEN

        FOR CurSumDist IN c_sum_dist(p_inventory_id, p_daytime, to_char(p_daytime, 'YYYY')) LOOP
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'DIST VAL: ULOpening QTY1:'|| CurSumDist.Opening_Ul_Position_Qty1 ||
' OLOpening QTY1:'|| CurSumDist.Opening_Ol_Position_Qty1 ||
' PSOpening QTY1:'|| CurSumDist.Opening_Ps_Position_Qty1 ||
' ULMov QTY1:'|| CurSumDist.Ytd_Ul_Mov_Qty1 ||
' OLMov QTY1:'|| CurSumDist.Ytd_Ol_Mov_Qty1 ||
' PSMov QTY1:'|| CurSumDist.Ps_Movement_Qty1 ||
' ULClosing QTY1:'|| CurSumDist.Closing_Ul_Position_Qty1 ||
' OLClosing QTY1:'|| CurSumDist.Closing_Ol_Position_Qty1 ||
' PSClosing QTY1:'|| CurSumDist.Closing_Ps_Position_Qty1 ||
'' );
*/
            UPDATE inv_valuation iv
            SET YTD_UL_MOV_QTY1 = CurSumDist.Ytd_Ul_Mov_Qty1
                ,YTD_UL_MOV_QTY2 = CurSumDist.Ytd_Ul_Mov_Qty2
                ,TOTAL_MOV_QTY1 = CurSumDist.Ytd_Movement_Qty1
                ,TOTAL_MOV_QTY2 = CurSumDist.Ytd_Movement_Qty2
                ,UL_OPENING_POS_QTY1 = CurSumDist.Opening_Ul_Position_Qty1
                ,UL_OPENING_POS_QTY2 = CurSumDist.Opening_Ul_Position_Qty2
                ,UL_CLOSING_POS_QTY1 = CurSumDist.Closing_Ul_Position_Qty1
                ,UL_CLOSING_POS_QTY2 = CurSumDist.Closing_Ul_Position_Qty2
--                ,YTD_PROD_QTY1 = CurSumDist.
--                ,YTD_PROD_QTY2 = CurSumDist.
                ,OL_CLOSING_POS_QTY1 = CurSumDist.Closing_Ol_Position_Qty1
                ,OL_CLOSING_POS_QTY2 = CurSumDist.Closing_Ol_Position_Qty2
                ,YTD_OL_MOV_QTY1 = CurSumDist.Ytd_Ol_Mov_Qty1
                ,YTD_OL_MOV_QTY2 = CurSumDist.Ytd_Ol_Mov_Qty2
                ,OL_OPENING_QTY1 = CurSumDist.Opening_Ol_Position_Qty1
                ,OL_OPENING_QTY2 = CurSumDist.Opening_Ol_Position_Qty2
                ,PS_CLOSING_POS_QTY1 = CurSumDist.Closing_Ps_Position_Qty1
                ,PS_CLOSING_POS_QTY2 = CurSumDist.Closing_Ps_Position_Qty2
                ,PS_OPENING_QTY1 = CurSumDist.Opening_Ps_Position_Qty1
                ,PS_OPENING_QTY2 = CurSumDist.Opening_Ps_Position_Qty2
                ,YTD_PS_MOV_QTY1 = CurSumDist.ytd_Ps_Movement_Qty1
                ,YTD_PS_MOV_QTY2 = CurSumDist.ytd_Ps_Movement_Qty2
                ,TOTAL_CLOSING_POS_QTY1 = CurSumDist.Total_Closing_Pos_Qty1
                ,TOTAL_CLOSING_POS_QTY2 = CurSumDist.Total_Closing_Pos_Qty2
                ,last_updated_by = p_user
            WHERE
                object_id = p_inventory_id
                AND daytime = p_daytime
                AND year_code = to_char(p_daytime, 'YYYY');

        END LOOP;

        RETURN;
    END IF;

    lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_inventory_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

    -- use normal LIFO logic if December
    IF ec_inventory_version.valuation_method(p_inventory_id, p_daytime, '<=') = 'LIFO_INTERIM' AND to_char(p_daytime,'MM') = '12' THEN
         lv2_valuation_method := 'LIFO';
    ELSE
         lv2_valuation_method := ec_inventory_version.valuation_method(p_inventory_id, p_daytime, '<=');
    END IF;

    lv2_UOM1 := ec_inventory_version.uom1_code(p_inventory_id, p_daytime, '<=');
    lv2_UOM2 := ec_inventory_version.uom2_code(p_inventory_id, p_daytime, '<=');


    -- Populate the correct book category
    lv2_book_category := ec_inventory_version.book_category(p_inventory_id, p_daytime, '<=');

    ln_total_mov_qty1 := 0;
    ln_total_mov_qty2 := 0;
    ln_ppa_total_mov_qty1 := 0;
    ln_ppa_total_mov_qty2 := 0;
    ln_total_ps_mov_qty1 := 0;
    ln_total_ps_mov_qty2 := 0;
    ln_ppa_total_ps_mov_qty1 := 0;
    ln_ppa_total_ps_mov_qty2 := 0;

    FOR CIFCur IN c_if LOOP

        ltab_dist_mov.extend;
        -- Set Key
        ltab_dist_mov(ltab_dist_mov.last).object_id := CIFCur.field_id;
        ltab_dist_mov(ltab_dist_mov.last).daytime := p_daytime;
        ltab_dist_mov(ltab_dist_mov.last).year_code := TO_CHAR(p_daytime, 'YYYY');

        -- Find AS IS movement
        ltab_as_is := GetActualPeriodDistMovement(CIFCur.field_id, p_inventory_id, p_daytime);
        ltab_dist_mov(ltab_dist_mov.last).qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_as_is, lv2_UOM1, p_daytime, CIFCur.field_id, FALSE),0);
        ltab_dist_mov(ltab_dist_mov.last).qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_as_is, lv2_UOM2, p_daytime, CIFCur.field_id, FALSE),0);
        ln_total_mov_qty1 := ln_total_mov_qty1 + ltab_dist_mov(ltab_dist_mov.last).qty1;
        ln_total_mov_qty2 := ln_total_mov_qty2 + ltab_dist_mov(ltab_dist_mov.last).qty2;

        -- Find Prior Period Adjustment
        ltab_ppa := GetDistPriorPeriodAdjustment(CIFCur.field_id, p_inventory_id, p_daytime);
        ltab_dist_mov(ltab_dist_mov.last).ppa_qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa, lv2_UOM1, p_daytime, CIFCur.field_id, FALSE),0);
        ltab_dist_mov(ltab_dist_mov.last).ppa_qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa, lv2_UOM2, p_daytime, CIFCur.field_id, FALSE),0);
        ln_ppa_total_mov_qty1 := ln_ppa_total_mov_qty1 + ltab_dist_mov(ltab_dist_mov.last).ppa_qty1;
        ln_ppa_total_mov_qty2 := ln_ppa_total_mov_qty2 + ltab_dist_mov(ltab_dist_mov.last).ppa_qty2;

        -- Find PS movement
        ltab_ps := GetPhysicalStockDistMovement(CIFCur.field_id, p_inventory_id, p_daytime);
        ltab_dist_mov(ltab_dist_mov.last).ps_qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ps, lv2_UOM1, p_daytime, CIFCur.field_id, FALSE),0);
        ltab_dist_mov(ltab_dist_mov.last).ps_qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ps, lv2_UOM2, p_daytime, CIFCur.field_id, FALSE),0);
        ln_total_ps_mov_qty1 := ln_total_ps_mov_qty1 + ltab_dist_mov(ltab_dist_mov.last).ps_qty1;
        ln_total_ps_mov_qty2 := ln_total_ps_mov_qty2 + ltab_dist_mov(ltab_dist_mov.last).ps_qty2;

        -- Find PS prior period adjustment movement
        ltab_ppa_ps := GetDistPriorPeriodPhyStockAdj(CIFCur.field_id, p_inventory_id, p_daytime);
        ltab_dist_mov(ltab_dist_mov.last).ppa_ps_qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa_ps, lv2_UOM1, p_daytime, CIFCur.field_id, FALSE),0);
        ltab_dist_mov(ltab_dist_mov.last).ppa_ps_qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa_ps, lv2_UOM2, p_daytime, CIFCur.field_id, FALSE),0);
        ln_ppa_total_ps_mov_qty1 := ln_ppa_total_ps_mov_qty1 + ltab_dist_mov(ltab_dist_mov.last).ppa_ps_qty1;
        ln_ppa_total_ps_mov_qty2 := ln_ppa_total_ps_mov_qty2 + ltab_dist_mov(ltab_dist_mov.last).ppa_ps_qty2;

    END LOOP;
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'CODE: ' || ec_inventory.object_code(p_inventory_id) || ' Daytime: ' || p_daytime ||
'DIST: TotalMov QTY1:'|| ln_total_mov_qty1 ||
' PPA QTY1:'|| ln_ppa_total_mov_qty1 ||
' PS Mov QTY1:'|| ln_total_ps_mov_qty1 ||
' PS PPA QTY1:' || ln_ppa_total_ps_mov_qty1 ||
' p_process_historic:' || p_process_historic);
*/
    ld_prior_year := GetEndPriorYear(p_inventory_id, p_daytime);
    lrec_prev_inv_valuation := ec_inv_valuation.row_by_pk(p_inventory_id, ld_prior_year, TO_CHAR(ld_prior_year, 'YYYY'));

    -- Previous years closing is always opening
    IF (IsInUnderLift(p_inventory_id, ld_prior_year) = 'TRUE') THEN
       lv2_opening := 'UNDERLIFT';
    ELSE
       lv2_opening := 'OVERLIFT';
    END IF;

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'CODE: ' || ec_inventory.object_code(p_inventory_id) || ' Daytime: ' || p_daytime ||
'lrec_prev_inv_valuation.total_closing_pos_qty1:'|| lrec_prev_inv_valuation.total_closing_pos_qty1 ||
' ln_total_mov_qty1:'|| ln_total_mov_qty1 ||
' ln_ppa_total_mov_qty1:'|| ln_ppa_total_mov_qty1 ||
' ln_total_ps_mov_qty1:' || ln_total_ps_mov_qty1 ||
' ln_ppa_total_ps_mov_qty1:' || ln_ppa_total_ps_mov_qty1);
*/
--    IF ((NVL(lrec_prev_inv_valuation.total_closing_pos_qty1, 0) + ln_total_mov_qty1 + ln_ppa_total_mov_qty1
/*
    IF ((NVL(lrec_prev_inv_valuation.ul_closing_pos_qty1, 0) + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0) + NVL(lrec_prev_inv_valuation.ps_closing_pos_qty1, 0)
          + NVL(ln_total_mov_qty1, 0) + NVL(ln_ppa_total_mov_qty1, 0)
          + ln_total_ps_mov_qty1 + ln_ppa_total_ps_mov_qty1) >= 0) THEN

*/
    IF ((NVL(lrec_prev_inv_valuation.ul_closing_pos_qty1, 0) + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0)
          + NVL(ln_total_mov_qty1, 0) + NVL(ln_ppa_total_mov_qty1, 0)) >= 0) THEN
       lv2_closing := 'UNDERLIFT';
    ELSE
       lv2_closing := 'OVERLIFT';
    END IF;

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'CODE: ' || ec_inventory.object_code(p_inventory_id) || ' Daytime: ' || p_daytime ||
'DIST: Opening_Pos:'|| lv2_opening ||
' Closing_Pos:'|| lv2_closing ||
' DT: ' || p_daytime);
*/
    FOR i IN 1..ltab_dist_mov.count LOOP
        lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_inventory_id, ltab_dist_mov(i).object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));
        lrec_prev_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_inventory_id, ltab_dist_mov(i).object_id, ld_prior_year, TO_CHAR(ld_prior_year, 'YYYY'));
        --============
        -- Opening
        --============
        IF (lv2_valuation_method IN ('LIFO', 'LIFO_INTERIM')) THEN
            lrec_inv_dist_valuation.opening_ul_position_qty1 := 0;
            lrec_inv_dist_valuation.opening_ul_position_qty2 := 0;
            lrec_inv_dist_valuation.opening_ol_position_qty1 := NVL(lrec_prev_inv_dist_valuation.closing_ol_position_qty1, 0);
            lrec_inv_dist_valuation.opening_ol_position_qty2 := NVL(lrec_prev_inv_dist_valuation.closing_ol_position_qty2, 0);
            lrec_inv_dist_valuation.opening_ps_position_qty1 := NVL(lrec_prev_inv_dist_valuation.closing_ps_position_qty1, 0);
            lrec_inv_dist_valuation.opening_ps_position_qty2 := NVL(lrec_prev_inv_dist_valuation.closing_ps_position_qty2, 0);
        ELSE -- FIFO
            lrec_inv_dist_valuation.opening_ul_position_qty1 := NVL(lrec_prev_inv_dist_valuation.closing_ul_position_qty1, 0);
            lrec_inv_dist_valuation.opening_ul_position_qty2 := NVL(lrec_prev_inv_dist_valuation.closing_ul_position_qty2, 0);
            lrec_inv_dist_valuation.opening_ol_position_qty1 := NVL(lrec_prev_inv_dist_valuation.closing_ol_position_qty1, 0);
            lrec_inv_dist_valuation.opening_ol_position_qty2 := NVL(lrec_prev_inv_dist_valuation.closing_ol_position_qty2, 0);
            lrec_inv_dist_valuation.opening_ps_position_qty1 := NVL(lrec_prev_inv_dist_valuation.closing_ps_position_qty1, 0);
            lrec_inv_dist_valuation.opening_ps_position_qty2 := NVL(lrec_prev_inv_dist_valuation.closing_ps_position_qty2, 0);
        END IF;

        IF (lv2_opening = 'UNDERLIFT') THEN

            IF (lv2_closing = 'UNDERLIFT') THEN -- Underlift -> Underlift
                --============
                -- Movement
                --============
                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := ltab_dist_mov(i).qty1;
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := ltab_dist_mov(i).qty2;
                lrec_inv_dist_valuation.ppa_qty1 := ltab_dist_mov(i).ppa_qty1;
                lrec_inv_dist_valuation.ppa_qty2 := ltab_dist_mov(i).ppa_qty2;

                lrec_inv_dist_valuation.ytd_ol_mov_qty1 := 0;
                lrec_inv_dist_valuation.ytd_ol_mov_qty2 := 0;
            ELSE -- Underlift -> Overlift
                --============
                -- Movement
                --============
                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := lrec_inv_dist_valuation.opening_ul_position_qty1 * -1;
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := lrec_inv_dist_valuation.opening_ul_position_qty2 * -1;
                lrec_inv_dist_valuation.ppa_qty1 := ltab_dist_mov(i).ppa_qty1;
                lrec_inv_dist_valuation.ppa_qty2 := ltab_dist_mov(i).ppa_qty2;

                lrec_inv_dist_valuation.ytd_ol_mov_qty1 := lrec_inv_dist_valuation.opening_ul_position_qty1 + ltab_dist_mov(i).qty1;
                lrec_inv_dist_valuation.ytd_ol_mov_qty2 := lrec_inv_dist_valuation.opening_ul_position_qty2 + ltab_dist_mov(i).qty2;
            END IF;

        ELSE -- Overlift -> Underlift

            IF (lv2_closing = 'UNDERLIFT') THEN
                --============
                -- Movement
                --============
                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := lrec_inv_dist_valuation.opening_ol_position_qty1 + ltab_dist_mov(i).qty1;
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := lrec_inv_dist_valuation.opening_ol_position_qty2 + ltab_dist_mov(i).qty2;
                lrec_inv_dist_valuation.ppa_qty1 := ltab_dist_mov(i).ppa_qty1;
                lrec_inv_dist_valuation.ppa_qty2 := ltab_dist_mov(i).ppa_qty2;

                lrec_inv_dist_valuation.ytd_ol_mov_qty1 := lrec_inv_dist_valuation.opening_ol_position_qty1 * -1;
                lrec_inv_dist_valuation.ytd_ol_mov_qty2 := lrec_inv_dist_valuation.opening_ol_position_qty2 * -1;
            ELSE -- Overlift -> Overlift
                --============
                -- Movement
                --============
                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := 0;
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := 0;
                lrec_inv_dist_valuation.ppa_qty1 := ltab_dist_mov(i).ppa_qty1;
                lrec_inv_dist_valuation.ppa_qty2 := ltab_dist_mov(i).ppa_qty2;
                lrec_inv_dist_valuation.ytd_ol_mov_qty1 := ltab_dist_mov(i).qty1;
                lrec_inv_dist_valuation.ytd_ol_mov_qty2 := ltab_dist_mov(i).qty2;
            END IF;

        END IF;

        --==============
        -- Movement, PS
        --==============
        lrec_inv_dist_valuation.ytd_ps_movement_qty1 := ltab_dist_mov(i).ps_qty1;
        lrec_inv_dist_valuation.ytd_ps_movement_qty2 := ltab_dist_mov(i).ps_qty2;
        lrec_inv_dist_valuation.ppa_ps_qty1 := ltab_dist_mov(i).ppa_ps_qty1;
        lrec_inv_dist_valuation.ppa_ps_qty2 := ltab_dist_mov(i).ppa_ps_qty2;

        --==============
        -- Movement, ppa
        --==============
        IF (lv2_closing = 'UNDERLIFT') THEN -- PUT ppa on Underlift if closing is underlift
            lrec_inv_dist_valuation.ytd_ul_mov_qty1 := lrec_inv_dist_valuation.ytd_ul_mov_qty1 + NVL(ltab_dist_mov(i).ppa_qty1, 0);
            lrec_inv_dist_valuation.ytd_ul_mov_qty2 := lrec_inv_dist_valuation.ytd_ul_mov_qty2 + NVL(ltab_dist_mov(i).ppa_qty2, 0);
        ELSE -- PUT ppa on Overlift if closing is overlift
            lrec_inv_dist_valuation.ytd_ol_mov_qty1 := lrec_inv_dist_valuation.ytd_ol_mov_qty1 + NVL(ltab_dist_mov(i).ppa_qty1, 0);
            lrec_inv_dist_valuation.ytd_ol_mov_qty2 := lrec_inv_dist_valuation.ytd_ol_mov_qty2 + NVL(ltab_dist_mov(i).ppa_qty2, 0);
        END IF;
        lrec_inv_dist_valuation.ytd_ps_movement_qty1 := lrec_inv_dist_valuation.ytd_ps_movement_qty1 + lrec_inv_dist_valuation.ppa_ps_qty1;
        lrec_inv_dist_valuation.ytd_ps_movement_qty2 := lrec_inv_dist_valuation.ytd_ps_movement_qty2 + lrec_inv_dist_valuation.ppa_ps_qty2;

        lrec_inv_dist_valuation.ytd_movement_qty1 := lrec_inv_dist_valuation.ytd_ul_mov_qty1 + lrec_inv_dist_valuation.ytd_ol_mov_qty1;
        lrec_inv_dist_valuation.ytd_movement_qty2 := lrec_inv_dist_valuation.ytd_ul_mov_qty2 + lrec_inv_dist_valuation.ytd_ol_mov_qty2;

        --============
        -- Closing
        --============
        lrec_inv_dist_valuation.closing_ul_position_qty1 := lrec_inv_dist_valuation.opening_ul_position_qty1 + lrec_inv_dist_valuation.ytd_ul_mov_qty1;
        lrec_inv_dist_valuation.closing_ul_position_qty2 := lrec_inv_dist_valuation.opening_ul_position_qty2 + lrec_inv_dist_valuation.ytd_ul_mov_qty2;
        lrec_inv_dist_valuation.closing_ol_position_qty1 := lrec_inv_dist_valuation.opening_ol_position_qty1 + lrec_inv_dist_valuation.ytd_ol_mov_qty1;
        lrec_inv_dist_valuation.closing_ol_position_qty2 := lrec_inv_dist_valuation.opening_ol_position_qty2 + lrec_inv_dist_valuation.ytd_ol_mov_qty2;
        lrec_inv_dist_valuation.closing_ps_position_qty1 := lrec_inv_dist_valuation.opening_ps_position_qty1 + lrec_inv_dist_valuation.ytd_ps_movement_qty1;
        lrec_inv_dist_valuation.closing_ps_position_qty2 := lrec_inv_dist_valuation.opening_ps_position_qty2 + lrec_inv_dist_valuation.ytd_ps_movement_qty2;

        lrec_inv_dist_valuation.total_closing_pos_qty1 := lrec_inv_dist_valuation.closing_ul_position_qty1 + lrec_inv_dist_valuation.closing_ol_position_qty1 + lrec_inv_dist_valuation.closing_ps_position_qty1;
        lrec_inv_dist_valuation.total_closing_pos_qty2 := lrec_inv_dist_valuation.closing_ul_position_qty2 + lrec_inv_dist_valuation.closing_ol_position_qty2 + lrec_inv_dist_valuation.closing_ps_position_qty2;

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'CODE: ' || ec_inventory.object_code(p_inventory_id) ||
' DAYTIME: '|| p_daytime ||
' UL Opening QTY1:'|| lrec_inv_dist_valuation.opening_ul_position_qty1 ||
' OL Opening QTY1:'|| lrec_inv_dist_valuation.opening_ol_position_qty1 ||
' PS Opening QTY1:'|| lrec_inv_dist_valuation.opening_ps_position_qty1 ||
' YTD Movement QTY1:' || lrec_inv_dist_valuation.ytd_movement_qty1 ||
' UL Movement QTY1:' || lrec_inv_dist_valuation.ytd_ul_mov_qty1 ||
' OL Movement QTY1:' || lrec_inv_dist_valuation.ytd_ol_mov_qty1 ||
' PS Movement QTY1:' || lrec_inv_dist_valuation.ytd_ps_movement_qty1 ||
' UL Closing QTY1:' || lrec_inv_dist_valuation.closing_ul_position_qty1 ||
' OL Closing QTY1:' || lrec_inv_dist_valuation.closing_ol_position_qty1 ||
' PS Closing QTY1:' || lrec_inv_dist_valuation.closing_ps_position_qty1 ||
' Total Closing QTY1:' || lrec_inv_dist_valuation.total_closing_pos_qty1 ||
' p_process_historic:' || p_process_historic);
*/

        -- Try to update an existing record if it exists in advance.
        UPDATE INV_DIST_VALUATION
           SET UOM1_CODE                = lv2_UOM1
              ,UOM2_CODE                = lv2_UOM2
              ,OPENING_UL_POSITION_QTY1 = lrec_inv_dist_valuation.opening_ul_position_qty1
              ,OPENING_UL_POSITION_QTY2 = lrec_inv_dist_valuation.opening_ul_position_qty2
              ,OPENING_OL_POSITION_QTY1 = lrec_inv_dist_valuation.opening_ol_position_qty1
              ,OPENING_OL_POSITION_QTY2 = lrec_inv_dist_valuation.opening_ol_position_qty2
              ,OPENING_PS_POSITION_QTY1 = lrec_inv_dist_valuation.opening_ps_position_qty1
              ,OPENING_PS_POSITION_QTY2 = lrec_inv_dist_valuation.opening_ps_position_qty2
              ,YTD_UL_MOV_QTY1          = lrec_inv_dist_valuation.ytd_ul_mov_qty1
              ,YTD_UL_MOV_QTY2          = lrec_inv_dist_valuation.ytd_ul_mov_qty2
              ,YTD_OL_MOV_QTY1          = lrec_inv_dist_valuation.ytd_ol_mov_qty1
              ,YTD_OL_MOV_QTY2          = lrec_inv_dist_valuation.ytd_ol_mov_qty2
              ,YTD_PS_MOVEMENT_QTY1     = lrec_inv_dist_valuation.ytd_ps_movement_qty1
              ,YTD_PS_MOVEMENT_QTY2     = lrec_inv_dist_valuation.ytd_ps_movement_qty2
              ,YTD_MOVEMENT_QTY1        = lrec_inv_dist_valuation.ytd_movement_qty1
              ,YTD_MOVEMENT_QTY2        = lrec_inv_dist_valuation.ytd_movement_qty2
              ,CLOSING_UL_POSITION_QTY1 = lrec_inv_dist_valuation.closing_ul_position_qty1
              ,CLOSING_UL_POSITION_QTY2 = lrec_inv_dist_valuation.closing_ul_position_qty2
              ,CLOSING_OL_POSITION_QTY1 = lrec_inv_dist_valuation.closing_ol_position_qty1
              ,CLOSING_OL_POSITION_QTY2 = lrec_inv_dist_valuation.closing_ol_position_qty2
              ,TOTAL_CLOSING_POS_QTY1    = lrec_inv_dist_valuation.total_closing_pos_qty1
              ,TOTAL_CLOSING_POS_QTY2    = lrec_inv_dist_valuation.total_closing_pos_qty2
              ,PPA_QTY1                 = lrec_inv_dist_valuation.ppa_qty1
              ,PPA_QTY2                 = lrec_inv_dist_valuation.ppa_qty2
              ,PPA_PS_QTY1              = lrec_inv_dist_valuation.ppa_ps_qty1
              ,PPA_PS_QTY2              = lrec_inv_dist_valuation.ppa_ps_qty2
              ,CLOSING_PS_POSITION_QTY1 = lrec_inv_dist_valuation.closing_ps_position_qty1
              ,CLOSING_PS_POSITION_QTY2 = lrec_inv_dist_valuation.closing_ps_position_qty2
              ,BOOK_CATEGORY            = lv2_book_category
              ,VALUATION_METHOD         = lv2_valuation_method
              ,last_updated_by          = p_user --'SYSTEM' - -  part of general processing
         WHERE OBJECT_ID = p_inventory_id
           AND DIST_ID = ltab_dist_mov(i).object_id
           AND DAYTIME = p_daytime
           AND YEAR_CODE = to_char(p_daytime, 'YYYY');

        IF SQL%NOTFOUND THEN
         -- record does not exist
        INSERT INTO INV_DIST_VALUATION
              (object_id
              ,dist_id
              ,daytime
              ,year_code
              ,name
              ,description
              ,valuation_level
              ,UOM1_CODE
              ,UOM2_CODE
              ,YTD_MOVEMENT_QTY1
              ,YTD_MOVEMENT_QTY2
              ,YTD_UL_MOV_QTY1
              ,YTD_UL_MOV_QTY2
              ,YTD_OL_MOV_QTY1
              ,YTD_OL_MOV_QTY2
              ,YTD_PS_MOVEMENT_QTY1
              ,YTD_PS_MOVEMENT_QTY2
              ,TOTAL_CLOSING_POS_QTY1
              ,TOTAL_CLOSING_POS_QTY2
              ,CLOSING_OL_POSITION_QTY1
              ,CLOSING_OL_POSITION_QTY2
              ,CLOSING_UL_POSITION_QTY1
              ,CLOSING_UL_POSITION_QTY2
              ,OPENING_UL_POSITION_QTY1
              ,OPENING_UL_POSITION_QTY2
              ,OPENING_OL_POSITION_QTY1
              ,OPENING_OL_POSITION_QTY2
              ,OPENING_PS_POSITION_QTY1
              ,OPENING_PS_POSITION_QTY2
              ,PPA_QTY1
              ,PPA_QTY2
              ,PPA_PS_QTY1
              ,PPA_PS_QTY2
              ,CLOSING_PS_POSITION_QTY1
              ,CLOSING_PS_POSITION_QTY2
              ,BOOK_CATEGORY
              ,VALUATION_METHOD
              ,last_updated_by)
              VALUES
              (p_inventory_id
              ,ltab_dist_mov(i).object_id
              ,p_daytime
              ,to_char(p_daytime, 'YYYY')
              ,Ec_Inventory_Version.name(p_inventory_id, p_daytime, '<=')
              ,Ec_Inventory.description(p_inventory_id)
              ,Ec_Inventory_Version.valuation_level(p_inventory_id, p_daytime, '<=')
              ,lv2_UOM1
              ,lv2_UOM2
              ,lrec_inv_dist_valuation.ytd_movement_qty1
              ,lrec_inv_dist_valuation.ytd_movement_qty2
              ,lrec_inv_dist_valuation.ytd_ul_mov_qty1
              ,lrec_inv_dist_valuation.ytd_ul_mov_qty2
              ,lrec_inv_dist_valuation.ytd_ol_mov_qty1
              ,lrec_inv_dist_valuation.ytd_ol_mov_qty2
              ,lrec_inv_dist_valuation.ytd_ps_movement_qty1
              ,lrec_inv_dist_valuation.ytd_ps_movement_qty2
              ,lrec_inv_dist_valuation.total_closing_pos_qty1
              ,lrec_inv_dist_valuation.total_closing_pos_qty2
              ,lrec_inv_dist_valuation.closing_ol_position_qty1
              ,lrec_inv_dist_valuation.closing_ol_position_qty2
              ,lrec_inv_dist_valuation.closing_ul_position_qty1
              ,lrec_inv_dist_valuation.closing_ul_position_qty2
              ,lrec_inv_dist_valuation.opening_ul_position_qty1
              ,lrec_inv_dist_valuation.opening_ul_position_qty2
              ,lrec_inv_dist_valuation.opening_ol_position_qty1
              ,lrec_inv_dist_valuation.opening_ol_position_qty2
              ,lrec_inv_dist_valuation.opening_ps_position_qty1
              ,lrec_inv_dist_valuation.opening_ps_position_qty2
              ,lrec_inv_dist_valuation.ppa_qty1
              ,lrec_inv_dist_valuation.ppa_qty2
              ,lrec_inv_dist_valuation.ppa_ps_qty1
              ,lrec_inv_dist_valuation.ppa_ps_qty2
              ,lrec_inv_dist_valuation.closing_ps_position_qty1
              ,lrec_inv_dist_valuation.closing_ps_position_qty2
              ,lv2_book_category
              ,lv2_valuation_method
              ,p_user -- 'SYSTEM' - - part of general processing
              );

    END IF;

    END LOOP; -- DIST LOOP

END CalcDistPosition;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CalcTotalPosition
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : inv_layer, inv_dist_valuation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Column inv_valuation.ul/ol_opening_pos_qty1 is considered to be without the opening for physical stock.
--                  Column inv_layer.opening_qty1 is considered to include the opening quantity for physical stock
--                  skjorsti 2007-27-08
-----------------------------------------------------------------------------------------------------
PROCEDURE CalcTotalPosition(p_object_id        VARCHAR2, -- Inventory Object ID
                            p_daytime          DATE,
                            p_user             VARCHAR2,
                            p_process_historic VARCHAR2 DEFAULT 'FALSE')
IS
--</EC-DOC>

CURSOR c_dist_split IS
  SELECT *
    FROM inv_dist_valuation
   WHERE object_id = p_object_id
     AND daytime = p_daytime
     AND year_code = TO_CHAR(daytime, 'YYYY');

unknown_valuation_method EXCEPTION;
no_year_opening_position EXCEPTION;
division_by_zero EXCEPTION;

-- lrec_inv_layer         inv_layer%ROWTYPE;
lrec_inv_valuation     inv_valuation%ROWTYPE;
lv2_local_currency     VARCHAR(200);

-- This variable is populated with movement without physical stock and without prior period adjustment.
diff1                  NUMBER default 0;
diff2                  NUMBER default 0;
-- This variable is populated with physical stock movement without physical stock prior period adjustment.
diff_ps1                  NUMBER default 0;
diff_ps2                  NUMBER default 0;

-- This value is populated with the sum of the prior period ajustments for each field.
-- The variable is used as input for inv_layer.closing_qty and inv_layer.total_closing_qty.
ln_ppa1                    NUMBER default 0;

-- This value is populated with the sum of the physical stock prior period ajustments for each field.
-- The variable is used as input for inv_layer.closing_ps_qty and inv_layer.total_closing_qty.
ln_ppa1_ps                 NUMBER default 0;
ln_ppa2                    NUMBER default 0;
ln_ppa2_ps                 NUMBER default 0;

ln_opening_pos_qty1      NUMBER;
ln_opening_pos_qty2      NUMBER;

ld_rate_day DATE := LAST_DAY(p_daytime);
lv2_forex_source_id VARCHAR2(32);

ld_end_last_year DATE;

BEGIN
    IF p_process_historic = 'TRUE' THEN
        RETURN;
    END IF;
/* DEBUG
   ecdp_dynsql.WriteTempText('INV', 'INVENTORY Code:'|| ec_inventory.object_code(p_object_id) || ' p_daytime:' || p_daytime || ' p_user:'|| p_user || ' p_process_historic:' || p_process_historic);
*/

   -- Current Layer, remember
   lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

   --  get valuation method for inventory
   lrec_inv_valuation.valuation_method := ec_inventory_version.valuation_method(p_object_id, p_daytime, '<=');
   lrec_inv_valuation.book_category    := ec_inventory_version.book_category(p_object_id, p_daytime, '<=');
   lrec_inv_valuation.valuation_level  := ec_inventory_version.valuation_level(p_object_id, p_daytime, '<=');
   lrec_inv_valuation.name             := ec_inventory_version.name(p_object_id, p_daytime, '<=');
   lrec_inv_valuation.description      := ec_inventory.description(p_object_id);

/* DEBUG
 Ecdp_Dynsql.WriteTempText('INV_PROCESS', 'UL BookingMemo: ' || lv2_ul_booking_memo || ' bookingLocal: ' ||lv2_ul_booking_local || ' bookingGroup: ' || lv2_ul_booking_group);
*/
   -- find UOM's for inventory
   lrec_inv_valuation.uom1_code := ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=');
   lrec_inv_valuation.uom2_code := ec_inventory_version.uom2_code(p_object_id, p_daytime, '<=');

   -- find avg. rates and prices
   lrec_inv_valuation.ul_avg_rate  := EC_INV_VALUATION.ul_avg_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
   lrec_inv_valuation.ol_avg_rate  := EC_INV_VALUATION.ol_avg_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
   lrec_inv_valuation.ps_avg_rate  := EC_INV_VALUATION.ps_avg_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));

   -- use normal LIFO logic if December
   IF lrec_inv_valuation.valuation_method = 'LIFO_INTERIM' AND to_char(p_daytime,'MM') = '12' THEN
        lrec_inv_valuation.valuation_method := 'LIFO';
   END IF;

   IF lrec_inv_valuation.valuation_method = 'LIFO_INTERIM' THEN
        lrec_inv_valuation.posting_type := 'INTERIM';
   ELSE
        lrec_inv_valuation.posting_type := 'PERMANENT';
   END IF;

--=====================================================
--=====================================================
--=====================================================

       --==============
       -- Opening
       --==============
       IF (lrec_inv_valuation.valuation_method IN ('LIFO_INTERIM', 'LIFO')) THEN
           lrec_inv_valuation.ul_opening_pos_qty1 := 0;
           lrec_inv_valuation.ul_opening_pos_qty2 := 0;
           lrec_inv_valuation.ol_opening_qty1 := 0;
           lrec_inv_valuation.ol_opening_qty2 := 0;
           lrec_inv_valuation.ps_opening_qty1 := 0;
           lrec_inv_valuation.ps_opening_qty2 := 0;
       ELSE -- FIFO
           ld_end_last_year := GetEndPriorYear(p_object_id,p_daytime);
           lrec_inv_valuation.ul_opening_pos_qty1 := NVL(ec_inv_valuation.ul_closing_pos_qty1(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
           lrec_inv_valuation.ul_opening_pos_qty2 := NVL(ec_inv_valuation.ul_closing_pos_qty2(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
           lrec_inv_valuation.ol_opening_qty1 := NVL(ec_inv_valuation.ol_closing_pos_qty1(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
           lrec_inv_valuation.ol_opening_qty2 := NVL(ec_inv_valuation.ol_closing_pos_qty2(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
           lrec_inv_valuation.ps_opening_qty1 := NVL(ec_inv_valuation.ps_closing_pos_qty1(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
           lrec_inv_valuation.ps_opening_qty2 := NVL(ec_inv_valuation.ps_closing_pos_qty2(p_object_id, ld_end_last_year, TO_CHAR(ld_end_last_year, 'YYYY')), 0);
       END IF;

       --==============
       -- Find Movement
       --==============
       lrec_inv_valuation.ytd_ul_mov_qty1 := 0;
       lrec_inv_valuation.ytd_ul_mov_qty2 := 0;
       lrec_inv_valuation.ytd_ol_mov_qty1 := 0;
       lrec_inv_valuation.ytd_ol_mov_qty2 := 0;
       lrec_inv_valuation.ytd_ps_mov_qty1 := 0;
       lrec_inv_valuation.ytd_ps_mov_qty2 := 0;
       ln_ppa1 := 0;
       ln_ppa2 := 0;
       ln_ppa1_ps := 0;
       ln_ppa2_ps := 0;

       FOR CurDist IN c_dist_split LOOP
/* DEBUG
    Ecdp_Dynsql.WriteTempText('INV_PROCESS', 'Processing Inv: ' || ec_inventory.object_code(p_object_id) ||
      ' Daytime: ' || p_daytime
      || ' NVL(CurDist.Ytd_Ul_Mov_Qty1, 0): ' || NVL(CurDist.Ytd_Ul_Mov_Qty1, 0)
      || ' NVL(CurDist.Ppa_Qty1, 0): ' ||  NVL(CurDist.Ppa_Qty1, 0));
 */
           lrec_inv_valuation.ytd_ul_mov_qty1 := lrec_inv_valuation.ytd_ul_mov_qty1 + NVL(CurDist.Ytd_Ul_Mov_Qty1, 0);
           lrec_inv_valuation.ytd_ul_mov_qty2 := lrec_inv_valuation.ytd_ul_mov_qty2 + NVL(CurDist.Ytd_Ul_Mov_Qty2, 0);
           lrec_inv_valuation.ytd_ol_mov_qty1 := lrec_inv_valuation.ytd_ol_mov_qty1 + NVL(CurDist.Ytd_Ol_Mov_Qty1, 0);
           lrec_inv_valuation.ytd_ol_mov_qty2 := lrec_inv_valuation.ytd_ol_mov_qty2 + NVL(CurDist.Ytd_Ol_Mov_Qty2, 0);
           lrec_inv_valuation.ytd_ps_mov_qty1 := lrec_inv_valuation.ytd_ps_mov_qty1 + NVL(CurDist.Ytd_Ps_Movement_Qty1, 0);
           lrec_inv_valuation.ytd_ps_mov_qty2 := lrec_inv_valuation.ytd_ps_mov_qty2 + NVL(CurDist.Ytd_Ps_Movement_Qty2, 0);

           ln_ppa1 := ln_ppa1 + NVL(CurDist.Ppa_Qty1, 0);
           ln_ppa2 := ln_ppa2 + NVL(CurDist.Ppa_Qty2, 0);
           ln_ppa1_ps := ln_ppa1_ps + NVL(CurDist.Ppa_Ps_Qty1, 0);
           ln_ppa2_ps := ln_ppa2_ps + NVL(CurDist.Ppa_Ps_Qty2, 0);

       END LOOP;

       lrec_inv_valuation.total_mov_qty1 := lrec_inv_valuation.ytd_ul_mov_qty1 + lrec_inv_valuation.ytd_ol_mov_qty1 + lrec_inv_valuation.ytd_ps_mov_qty1;
       lrec_inv_valuation.total_mov_qty2 := lrec_inv_valuation.ytd_ul_mov_qty2 + lrec_inv_valuation.ytd_ol_mov_qty2 + lrec_inv_valuation.ytd_ps_mov_qty2;

       --==============
       -- Closing
       --==============
       lrec_inv_valuation.ul_closing_pos_qty1 := lrec_inv_valuation.ul_opening_pos_qty1 + lrec_inv_valuation.ytd_ul_mov_qty1;
       lrec_inv_valuation.ul_closing_pos_qty2 := lrec_inv_valuation.ul_opening_pos_qty2 + lrec_inv_valuation.ytd_ul_mov_qty2;
       lrec_inv_valuation.ol_closing_pos_qty1 := lrec_inv_valuation.ol_opening_qty1 + lrec_inv_valuation.ytd_ol_mov_qty1;
       lrec_inv_valuation.ol_closing_pos_qty2 := lrec_inv_valuation.ol_opening_qty2 + lrec_inv_valuation.ytd_ol_mov_qty2;
       lrec_inv_valuation.ps_closing_pos_qty1 := lrec_inv_valuation.ps_opening_qty1 + lrec_inv_valuation.ytd_ps_mov_qty1;
       lrec_inv_valuation.ps_closing_pos_qty2 := lrec_inv_valuation.ps_opening_qty2 + lrec_inv_valuation.ytd_ps_mov_qty2;

       lrec_inv_valuation.total_closing_pos_qty1 := lrec_inv_valuation.ul_closing_pos_qty1 + lrec_inv_valuation.ol_closing_pos_qty1 + lrec_inv_valuation.ps_closing_pos_qty1;
       lrec_inv_valuation.total_closing_pos_qty2 := lrec_inv_valuation.ul_closing_pos_qty2 + lrec_inv_valuation.ol_closing_pos_qty2 + lrec_inv_valuation.ps_closing_pos_qty2;

   -- update inventory table
   UPDATE INV_VALUATION
   SET
      UL_RATE                     =    lrec_inv_valuation.ul_avg_rate
      ,PS_RATE                    =    lrec_inv_valuation.ps_avg_rate
      ,OL_RATE                    =    lrec_inv_valuation.ol_avg_rate
      ,YTD_UL_MOV_QTY1            =    lrec_inv_valuation.ytd_ul_mov_qty1
      ,YTD_PS_MOV_QTY1            =    lrec_inv_valuation.ytd_ps_mov_qty1
      ,YTD_UL_MOV_QTY2            =    lrec_inv_valuation.ytd_ul_mov_qty2
      ,YTD_PS_MOV_QTY2            =    lrec_inv_valuation.ytd_ps_mov_qty2
      ,TOTAL_MOV_QTY1             =    lrec_inv_valuation.total_mov_qty1
      ,TOTAL_MOV_QTY2             =    lrec_inv_valuation.total_mov_qty2
      ,UL_OPENING_POS_QTY1        =    lrec_inv_valuation.ul_opening_pos_qty1
      ,UL_OPENING_POS_QTY2        =    lrec_inv_valuation.ul_opening_pos_qty2
      ,UL_CLOSING_POS_QTY1        =    lrec_inv_valuation.ul_closing_pos_qty1
      ,UL_CLOSING_POS_QTY2        =    lrec_inv_valuation.ul_closing_pos_qty2
      ,OL_OPENING_QTY1            =    lrec_inv_valuation.ol_opening_qty1
      ,OL_OPENING_QTY2            =    lrec_inv_valuation.ol_opening_qty2
      ,PS_OPENING_QTY1            =    lrec_inv_valuation.ps_opening_qty1
      ,PS_OPENING_QTY2            =    lrec_inv_valuation.ps_opening_qty2
      ,PS_CLOSING_POS_QTY1        =    lrec_inv_valuation.ps_closing_pos_qty1
      ,PS_CLOSING_POS_QTY2        =    lrec_inv_valuation.ps_closing_pos_qty2
      ,OL_CLOSING_POS_QTY1        =    lrec_inv_valuation.ol_closing_pos_qty1
      ,OL_CLOSING_POS_QTY2        =    lrec_inv_valuation.ol_closing_pos_qty2
      ,YTD_OL_MOV_QTY1            =    lrec_inv_valuation.ytd_ol_mov_qty1
      ,YTD_OL_MOV_QTY2            =    lrec_inv_valuation.ytd_ol_mov_qty2
      ,TOTAL_CLOSING_POS_QTY1     =    lrec_inv_valuation.total_closing_pos_qty1
      ,TOTAL_CLOSING_POS_QTY2     =    lrec_inv_valuation.total_closing_pos_qty2
      ,COMMENTS                   =    'Calculated by the system'
      ,VALUATION_LEVEL            =    lrec_inv_valuation.valuation_level
      ,BOOK_CATEGORY              =    lrec_inv_valuation.book_category
      ,FX_TYPE                    =    lrec_inv_valuation.fx_type
      ,FX_SOURCE_ID               =    lrec_inv_valuation.fx_source_id
      ,FX_SOURCE_CODE             =    lrec_inv_valuation.fx_source_code
      ,GROUP_CURRENCY_ID          =    lrec_inv_valuation.group_currency_id
      ,LOCAL_CURRENCY_ID          =    ec_currency.object_id_by_uk(lv2_local_currency)
      ,VALUATION_METHOD           =    lrec_inv_valuation.valuation_method
      ,UOM1_CODE                  =    lrec_inv_valuation.uom1_code
      ,UOM2_CODE                  =    lrec_inv_valuation.uom2_code
      ,POSTING_TYPE               =    lrec_inv_valuation.posting_type
      ,NAME                       =    lrec_inv_valuation.name
      ,DESCRIPTION                =    lrec_inv_valuation.description
      ,PROCESSED_BY               =    p_user
      ,PROCESSED_DATE             =    Ecdp_Timestamp.getCurrentSysdate
      ,last_updated_by            =    'SYSTEM'
   WHERE object_id = p_object_id
   AND daytime     = p_daytime
   AND year_code = to_char(p_daytime, 'YYYY');

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'QTYS UL Opening QTY1:'|| lrec_inv_valuation.ul_opening_pos_qty1 ||
' OL Opening QTY1:'|| lrec_inv_valuation.ol_opening_qty1 ||
' PS Opening QTY1:'|| lrec_inv_valuation.ps_opening_qty1 ||
' UL Movement QTY1:' || lrec_inv_valuation.ytd_ul_mov_qty1 ||
' OL Movement QTY1:' || lrec_inv_valuation.ytd_ol_mov_qty1 ||
' PS Movement QTY1:' || lrec_inv_valuation.ytd_ps_mov_qty1 ||
' Total Movement QTY1:' || lrec_inv_valuation.total_mov_qty1 ||
' UL Closing QTY1:' || lrec_inv_valuation.ul_closing_pos_qty1 ||
' OL Closing QTY1:' || lrec_inv_valuation.ol_closing_pos_qty1 ||
' PS Closing QTY1:' || lrec_inv_valuation.ps_closing_pos_qty1 ||
' Total Closing QTY1:' || lrec_inv_valuation.total_closing_pos_qty1 ||
' p_user:'|| p_user || ' p_process_historic:' || p_process_historic);
*/
ProcessInvLayer(p_object_id
               ,p_daytime
               ,'NOX'
               ,lrec_inv_valuation.valuation_method
               ,lrec_inv_valuation.ul_opening_pos_qty1 + lrec_inv_valuation.ol_opening_qty1 + lrec_inv_valuation.ps_opening_qty1
               ,lrec_inv_valuation.ul_opening_pos_qty2 + lrec_inv_valuation.ol_opening_qty2 + lrec_inv_valuation.ps_opening_qty2
               ,lrec_inv_valuation.total_mov_qty1
               ,lrec_inv_valuation.total_mov_qty2
               ,lrec_inv_valuation.ytd_ps_mov_qty1
               ,lrec_inv_valuation.ytd_ps_mov_qty2
               ,lrec_inv_valuation.ul_avg_rate
               ,lrec_inv_valuation.ol_avg_rate
               ,lrec_inv_valuation.ps_avg_rate
               ,p_user
               ,p_process_historic);

    -- Calculate Price Values
    CalcPricingValue(p_object_id, p_daytime, p_user);

    -- Calculate Other currecncies
    CalcCurrencyValues(p_object_id, p_daytime, p_user);

  EXCEPTION
      WHEN unknown_valuation_method THEN
         Raise_Application_Error(-20000,'No Valuation method defined' );

      WHEN no_year_opening_position THEN
         Raise_Application_Error(-20000,'Opening position for UOM1 or UOM2 is missing' );

      WHEN division_by_zero THEN
         Raise_Application_Error(-20000,'Division by zero during total inv rate calculation' );
END CalcTotalPosition;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CalcAvgULRate
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE CalcAvgULRate(
   p_object_id          VARCHAR2,
   p_daytime             DATE,
   p_process_historic    VARCHAR2 DEFAULT 'FALSE',
   p_force_avg_upd       VARCHAR2 DEFAULT 'FALSE'
)
IS
--</EC-DOC>
lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;
lrec_inv_valuation inv_valuation%ROWTYPE;

CURSOR c_if IS
SELECT inf.*
    FROM inventory_field inf
   WHERE inf.inventory_id = p_object_id
     AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1));

-- Underlift
lv2_ul_avg_rate_status VARCHAR(32):= ec_inv_valuation.ul_avg_rate_status(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
ln_ul_avg_rate         NUMBER     := ec_inv_valuation.ul_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

-- Overlift
lv2_ol_avg_rate_status VARCHAR(32):= ec_inv_valuation.ol_avg_price_status(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
ln_ol_avg_rate         NUMBER     := ec_inv_valuation.ol_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

-- Same approach for Physical Stock
lv2_ps_avg_rate_status VARCHAR(32):= ec_inv_valuation.ps_avg_rate_status(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
ln_ps_avg_rate         NUMBER     := ec_inv_valuation.ps_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

lv2_pricing_value_method VARCHAR2(32) := ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=');

BEGIN

    -- common calculations:
     lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
     lrec_inv_valuation.uom1_code := ec_inventory_version.uom1_code(p_object_id,p_daytime,'<=');
     lrec_inv_valuation.uom2_code := ec_inventory_version.uom2_code(p_object_id,p_daytime,'<=');

    -- calculate rates and production for each field in the inventory
     FOR CIFCursor IN c_if LOOP

          lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id,CIFCursor.field_id,p_daytime, to_char(p_daytime, 'YYYY'));

          IF p_process_historic = 'TRUE' THEN

            -- lrec_inv_dist_valuation.ul_rate     := 0;
            -- Replaced by the line below
            -- Use the rate to the layer.

            IF lv2_pricing_value_method = 'WEIGHTED_AVERAGE' THEN

              lrec_inv_dist_valuation.ul_rate := ec_inv_valuation.ul_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
              lrec_inv_dist_valuation.ol_rate := ec_inv_valuation.ol_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
              lrec_inv_dist_valuation.ps_rate := ec_inv_valuation.ps_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));

            END IF;

            lrec_inv_dist_valuation.ytd_prod_qty1 := 0;
            lrec_inv_dist_valuation.ytd_prod_qty2 := 0;

          ELSE

            lrec_inv_dist_valuation.ul_rate     := getdistrateval(CIFCursor.field_id, p_object_id, 'UL', p_daytime);

            -- Calculating Overlift Price
            lrec_inv_dist_valuation.ol_rate     := getdistrateval(CIFCursor.field_id, p_object_id, 'OL', p_daytime, true);

            -- Calculating Physical Stock Rate
            lrec_inv_dist_valuation.ps_rate     := getdistrateval(CIFCursor.field_id, p_object_id, 'PS', p_daytime, true);

            lrec_inv_dist_valuation.ytd_prod_qty1 := getdistbookedprodytd(CIFCursor.field_id,p_object_id,p_daytime,lrec_inv_valuation.uom1_code);
            lrec_inv_dist_valuation.ytd_prod_qty2 := getdistbookedprodytd(CIFCursor.field_id,p_object_id,p_daytime,lrec_inv_valuation.uom2_code);

          END IF;

          UPDATE INV_DIST_VALUATION
             SET ul_rate         = lrec_inv_dist_valuation.ul_rate,
                 ol_rate         = lrec_inv_dist_valuation.ol_rate,
                 ps_rate         = lrec_inv_dist_valuation.ps_rate,
                 ytd_prod_qty1   = lrec_inv_dist_valuation.ytd_prod_qty1,
                 ytd_prod_qty2   = lrec_inv_dist_valuation.ytd_prod_qty2,
                 last_updated_by = 'SYSTEM'
           WHERE OBJECT_ID = p_object_id
             AND DIST_ID   = CIFCursor.field_id
             AND DAYTIME   = p_daytime
             AND YEAR_CODE = to_char(p_daytime, 'YYYY');

      END LOOP;



     -- calculate the total production and rate for the inventory

     IF p_process_historic = 'TRUE' THEN

        lrec_inv_valuation.ytd_prod_qty1 := 0;
        lrec_inv_valuation.ytd_prod_qty2 := 0;
        -- Use the rate to the layer.

        IF lv2_pricing_value_method = 'WEIGHTED_AVERAGE' THEN

          lrec_inv_valuation.ul_avg_rate := ec_inv_valuation.ul_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
          lrec_inv_valuation.ol_avg_rate := ec_inv_valuation.ol_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));
          lrec_inv_valuation.ps_avg_rate := ec_inv_valuation.ps_rate(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));

        END IF;

     ELSE

          lrec_inv_valuation.ytd_prod_qty1 := GetInvActTotProdYTD(p_Object_Id,p_daytime,lrec_inv_valuation.uom1_code);
          lrec_inv_valuation.ytd_prod_qty2 := GetInvActTotProdYTD(p_Object_Id,p_daytime,lrec_inv_valuation.uom2_code);
          lrec_inv_valuation.ul_avg_rate   := Getinvavgrate(p_object_id, p_daytime, 'UL', lrec_inv_valuation.uom1_code);

          -- Overlift average price
          lrec_inv_valuation.ol_avg_rate  := Getinvavgrate(p_object_id, p_daytime, 'OL', lrec_inv_valuation.uom1_code, true);

          -- Physical Stock average rate
          lrec_inv_valuation.ps_avg_rate   := Getinvavgrate(p_object_id, p_daytime,'PS',lrec_inv_valuation.uom1_code, true);


          -- Keeping the rate for undelift if this has been manually updated
          IF lv2_ul_avg_rate_status = 'OW' AND ln_ul_avg_rate IS NOT NULL AND p_force_avg_upd = 'FALSE' THEN

               lrec_inv_valuation.ul_avg_rate := ln_ul_avg_rate;

          END IF;

          -- Keeping the rate for overlift if this has been manually updated
          IF lv2_ol_avg_rate_status = 'OW' AND ln_ol_avg_rate IS NOT NULL AND p_force_avg_upd = 'FALSE' THEN

               lrec_inv_valuation.ol_avg_rate := ln_ol_avg_rate;

          END IF;

          -- Keeping the rate for physical stock if this has been manually updated
          IF lv2_ps_avg_rate_status = 'OW' AND ln_ps_avg_rate IS NOT NULL AND p_force_avg_upd = 'FALSE' THEN

               lrec_inv_valuation.ps_avg_rate := ln_ps_avg_rate;

          END IF;

     END IF;

      UPDATE INV_VALUATION
         SET UL_AVG_RATE         = lrec_inv_valuation.ul_avg_rate,
             OL_AVG_RATE         = lrec_inv_valuation.ol_avg_rate,
             PS_AVG_RATE         = lrec_inv_valuation.ps_avg_rate,
             YTD_PROD_QTY1       = lrec_inv_valuation.ytd_prod_qty1,
             YTD_PROD_QTY2       = lrec_inv_valuation.ytd_prod_qty2,
             UL_AVG_RATE_STATUS  = lrec_inv_valuation.UL_AVG_RATE_STATUS,
             ol_avg_price_status = lrec_inv_valuation.ol_avg_price_status,
             PS_AVG_RATE_STATUS  = lrec_inv_valuation.PS_AVG_RATE_STATUS,
             last_updated_by     = 'SYSTEM'
       WHERE OBJECT_ID = p_object_id
         AND DAYTIME   = p_daytime
         AND YEAR_CODE = to_char(p_daytime, 'YYYY');

END CalcAvgULRate;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GenMthStaticInvData
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE GenMthStaticInvData(
   p_object_id          VARCHAR2, -- Inventory Object ID
   p_daytime            DATE,
   p_process_historic   VARCHAR2 DEFAULT 'FALSE')
IS
--</EC-DOC>
CURSOR c_sma IS
SELECT
   sma.object_id         a_object_id
  ,sma.STATUS            a_STATUS
  ,sma.PERIOD_REF_ITEM   a_PERIOD_REF_ITEM
  ,sma.VALUE_SOURCE      a_VALUE_SOURCE
  ,sma.CALC_METHOD       a_CALC_METHOD
  ,sma.NET_ENERGY_JO     a_NET_ENERGY_JO
  ,sma.NET_ENERGY_TH     a_NET_ENERGY_TH
  ,sma.NET_ENERGY_WH     a_NET_ENERGY_WH
  ,sma.NET_ENERGY_BE     a_NET_ENERGY_BE
  ,sma.NET_MASS_MA       a_NET_MASS_MA
  ,sma.NET_MASS_MV       a_NET_MASS_MV
  ,sma.NET_MASS_UA       a_NET_MASS_UA
  ,sma.NET_MASS_UV       a_NET_MASS_UV
  ,sma.NET_VOLUME_BI     a_NET_VOLUME_BI
  ,sma.NET_VOLUME_BM     a_NET_VOLUME_BM
  ,sma.NET_VOLUME_SF     a_NET_VOLUME_SF
  ,sma.NET_VOLUME_NM     a_NET_VOLUME_NM
  ,sma.NET_VOLUME_SM     a_NET_VOLUME_SM
  FROM stim_mth_actual sma, inventory_stim_setup iss
 WHERE sma.daytime = p_daytime
   AND iss.object_id = p_object_id -- Inventory ID
   AND sma.object_id = iss.stream_item_id
   AND p_daytime >= Nvl(iss.daytime,p_daytime-1)
   AND iss.inv_stream_item_type IN ('INV','OWN','PHY');

-- NEW CODE START - 2008-11-06
CURSOR c_smh IS
SELECT idv.dist_id si_object_id,
       idv.daytime daytime,
       idv.ytd_movement_qty1 qty1,
       ec_inventory_version.uom1_code(idv.object_id, idv.daytime, '<=') uom1_code,
       idv.ytd_movement_qty2 qty2,
       ec_inventory_version.uom2_code(idv.object_id, idv.daytime, '<=') uom2_code
  FROM inv_dist_valuation idv, inventory_stim_setup iss
 WHERE idv.daytime = p_daytime
   AND iss.object_id = p_object_id -- Inventory
   AND idv.object_id = p_object_id -- Inventory
   AND idv.dist_id = iss.stream_item_id
   AND p_daytime >= Nvl(iss.daytime, p_daytime - 1)
   AND iss.inv_stream_item_type IN ('INV', 'OWN');

lr_stim_mth_value stim_mth_value%ROWTYPE;
lr_stim_mth_inv_booked stim_mth_inv_booked%ROWTYPE;
lv2_uom1_group VARCHAR2(200);
lv2_uom2_group VARCHAR2(200);

ltab_fpa EcDp_Unit.t_uomtable;
lr_stim_mth_actual stim_mth_actual%ROWTYPE;

BEGIN
       IF p_process_historic = 'TRUE' THEN

            -- create empty records
            INSERT INTO STIM_MTH_INV_BOOKED
              (object_id, daytime, status, calc_method, created_by, created_date)
              SELECT idv.dist_id,
                     idv.daytime,
                     'FINAL',
                     siv.calc_method,
                     'SYSTEM',
                     Ecdp_Timestamp.getCurrentSysdate
                FROM inv_dist_valuation    idv,
                     inventory_stim_setup  iss,
                     inventory_field       inf,
                     stream_item_version   siv
               WHERE idv.daytime = p_daytime
                 AND inf.field_id = p_object_id
                 AND iss.object_id = inf.inventory_id
                 AND iss.stream_item_id = idv.dist_id
                 AND siv.object_id = idv.object_id
                 AND siv.field_id = inf.field_id
                 AND siv.daytime = (SELECT MAX(daytime)
                                      FROM stream_item_version sive
                                     WHERE sive.object_id = idv.dist_id
                                       AND sive.field_id = inf.field_id
                                       AND sive.daytime <= p_daytime)
                 AND iss.inv_stream_item_type IN ('INV', 'OWN')
                 AND iss.daytime = (SELECT MAX(daytime)
                                      FROM inventory_stim_setup issp
                                     WHERE issp.object_id = inf.inventory_id
                                       AND iss.stream_item_id = issp.stream_item_id
                                       AND issp.daytime <= p_daytime)
                 AND NOT EXISTS (select 'x'
                        from STIM_MTH_INV_BOOKED a
                       where a.object_id = idv.dist_id
                         and a.daytime = idv.daytime);

            FOR SMHCur IN c_smh LOOP

                lr_stim_mth_value := NULL;

                lr_stim_mth_value.object_id := SMHCur.si_object_id;

                lr_stim_mth_value.daytime := SMHCur.daytime;

                lv2_uom1_group := EcDp_Unit.GetUOMGroup(SMHCur.uom1_code);

                IF lv2_uom1_group = 'E' THEN

                    lr_stim_mth_value.net_energy_value := SMHCur.qty1;
                    lr_stim_mth_value.energy_uom_code := SMHCur.uom1_code;

                ELSIF lv2_uom1_group = 'V' THEN

                    lr_stim_mth_value.net_volume_value := SMHCur.qty1;
                    lr_stim_mth_value.volume_uom_code := SMHCur.uom1_code;

                ELSE

                    lr_stim_mth_value.net_mass_value := SMHCur.qty1;
                    lr_stim_mth_value.mass_uom_code := SMHCur.uom1_code;

                END IF;

                lv2_uom2_group := EcDp_Unit.GetUOMGroup(SMHCur.uom2_code);

                IF Nvl(lv2_uom2_group,lv2_uom1_group) <> lv2_uom1_group THEN

                    IF lv2_uom2_group = 'E' THEN

                        lr_stim_mth_value.net_energy_value := SMHCur.qty2;
                        lr_stim_mth_value.energy_uom_code := SMHCur.uom2_code;

                    ELSIF lv2_uom2_group = 'V' THEN

                        lr_stim_mth_value.net_volume_value := SMHCur.qty2;
                        lr_stim_mth_value.volume_uom_code := SMHCur.uom2_code;

                    ELSE

                        lr_stim_mth_value.net_mass_value := SMHCur.qty2;
                        lr_stim_mth_value.mass_uom_code := SMHCur.uom2_code;

                    END IF;

                END IF;

                lr_stim_mth_inv_booked.net_energy_jo := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'E', 'JO');
                lr_stim_mth_inv_booked.net_energy_th := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'E', 'TH');
                lr_stim_mth_inv_booked.net_energy_wh := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'E', 'WH');
                lr_stim_mth_inv_booked.net_energy_be := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'E', 'BE');
                lr_stim_mth_inv_booked.net_mass_ma   := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'M', 'MA');
                lr_stim_mth_inv_booked.net_mass_mv   := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'M', 'MV');
                lr_stim_mth_inv_booked.net_mass_ua   := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'M', 'UA');
                lr_stim_mth_inv_booked.net_mass_uv   := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'M', 'UV');
                lr_stim_mth_inv_booked.net_volume_bi := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'V', 'BI');
                lr_stim_mth_inv_booked.net_volume_bm := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'V', 'BM');
                lr_stim_mth_inv_booked.net_volume_sf := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'V', 'SF');
                lr_stim_mth_inv_booked.net_volume_nm := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'V', 'NM');
                lr_stim_mth_inv_booked.net_volume_sm := ECDP_STREAM_ITEM.GetSubGroupValue(lr_stim_mth_value, 'V', 'SM');

                UPDATE STIM_MTH_INV_BOOKED
                SET  NET_ENERGY_JO      =  lr_stim_mth_inv_booked.net_energy_jo
                    ,NET_ENERGY_TH      =  lr_stim_mth_inv_booked.net_energy_th
                    ,NET_ENERGY_WH      =  lr_stim_mth_inv_booked.net_energy_wh
                    ,NET_ENERGY_BE      =  lr_stim_mth_inv_booked.net_energy_be
                    ,NET_MASS_MA        =  lr_stim_mth_inv_booked.net_mass_ma
                    ,NET_MASS_MV        =  lr_stim_mth_inv_booked.net_mass_mv
                    ,NET_MASS_UA        =  lr_stim_mth_inv_booked.net_mass_ua
                    ,NET_MASS_UV        =  lr_stim_mth_inv_booked.net_mass_uv
                    ,NET_VOLUME_BI      =  lr_stim_mth_inv_booked.net_volume_bi
                    ,NET_VOLUME_BM      =  lr_stim_mth_inv_booked.net_volume_bm
                    ,NET_VOLUME_SF      =  lr_stim_mth_inv_booked.net_volume_sf
                    ,NET_VOLUME_NM      =  lr_stim_mth_inv_booked.net_volume_nm
                    ,NET_VOLUME_SM      =  lr_stim_mth_inv_booked.net_volume_sm
                   ,last_updated_by = 'SYSTEM'
                  WHERE daytime = p_daytime
                  AND  object_id = SMHCur.si_object_id;

            END LOOP;

       ELSE
        -- create empty records
        INSERT INTO STIM_MTH_INV_BOOKED
            (object_id,
             daytime,
             status,
             period_ref_item,
             calc_method,
             comments,
             created_by,
             created_date
             )
         SELECT
             sma.object_id,
             sma.daytime,
             sma.status,
             sma.period_ref_item,
             sma.calc_method,
             sma.comments,
             'SYSTEM',
             Ecdp_Timestamp.getCurrentSysdate
            FROM stim_mth_actual sma, inventory_stim_setup iss
            WHERE sma.daytime = p_daytime
             AND iss.daytime = (
                 SELECT MAX(issp.daytime) FROM inventory_stim_setup issp
                 WHERE issp.object_id = iss.object_id
                 AND issp.stream_item_id = iss.stream_item_id
                 AND issp.daytime <= p_daytime)
             AND sma.object_id = iss.stream_item_id
             AND iss.object_id = p_object_id
             AND iss.inv_stream_item_type IN ('INV','OWN','PHY')
             AND NOT EXISTS( SELECT 'x'
                               FROM STIM_MTH_INV_BOOKED smib
                              WHERE smib.object_id = sma.object_id
                                AND smib.daytime = sma.daytime);

           FOR SMACur IN c_sma LOOP

              lr_stim_mth_actual := ec_stim_mth_actual.row_by_pk(SMACur.a_object_id,p_daytime);
              lr_stim_mth_actual.net_energy_jo := SMACur.a_NET_ENERGY_JO;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'100MJ',p_daytime,p_object_id);
              lr_stim_mth_actual.net_energy_th := SMACur.a_NET_ENERGY_TH;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'THERMS',p_daytime,p_object_id);
              lr_stim_mth_actual.net_energy_wh := SMACur.a_NET_ENERGY_WH;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'KWH',p_daytime,p_object_id);
              lr_stim_mth_actual.net_energy_be := SMACur.a_NET_ENERGY_BE;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'BOE',p_daytime,p_object_id);
              lr_stim_mth_actual.net_mass_ma   := SMACur.a_NET_MASS_MA;-- -   EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'MT',p_daytime,p_object_id);
              lr_stim_mth_actual.net_mass_mv   := SMACur.a_NET_MASS_MV;-- -   EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'MTV',p_daytime,p_object_id);
              lr_stim_mth_actual.net_mass_ua   := SMACur.a_NET_MASS_UA;-- -   EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'UST',p_daytime,p_object_id);
              lr_stim_mth_actual.net_mass_uv   := SMACur.a_NET_MASS_UV;-- -   EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'USTV',p_daytime,p_object_id);
              lr_stim_mth_actual.net_volume_bi := SMACur.a_NET_VOLUME_BI;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'BBLS',p_daytime,p_object_id);
              lr_stim_mth_actual.net_volume_bm := SMACur.a_NET_VOLUME_BM;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'BBLS15',p_daytime,p_object_id);
              lr_stim_mth_actual.net_volume_sf := SMACur.a_NET_VOLUME_SF;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'MSCF',p_daytime,p_object_id);
              lr_stim_mth_actual.net_volume_nm := SMACur.a_NET_VOLUME_NM;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'MNM3',p_daytime,p_object_id);
              lr_stim_mth_actual.net_volume_sm := SMACur.a_NET_VOLUME_SM;-- - EcDp_Revn_Unit.GetUOMSetQty(ltab_fpa,'MSM3',p_daytime,p_object_id);

              UPDATE STIM_MTH_INV_BOOKED
              SET  STATUS               =  SMACur.a_status
                    ,PERIOD_REF_ITEM    =  SMACur.a_PERIOD_REF_ITEM
                    ,VALUE_SOURCE       =  SMACur.a_VALUE_SOURCE
                    ,CALC_METHOD        =  SMACur.a_CALC_METHOD
                    ,NET_ENERGY_JO      =  lr_stim_mth_actual.net_energy_jo
                    ,NET_ENERGY_TH      =  lr_stim_mth_actual.net_energy_th
                    ,NET_ENERGY_WH      =  lr_stim_mth_actual.net_energy_wh
                    ,NET_ENERGY_BE      =  lr_stim_mth_actual.net_energy_be
                    ,NET_MASS_MA        =  lr_stim_mth_actual.net_mass_ma
                    ,NET_MASS_MV        =  lr_stim_mth_actual.net_mass_mv
                    ,NET_MASS_UA        =  lr_stim_mth_actual.net_mass_ua
                    ,NET_MASS_UV        =  lr_stim_mth_actual.net_mass_uv
                    ,NET_VOLUME_BI      =  lr_stim_mth_actual.net_volume_bi
                    ,NET_VOLUME_BM      =  lr_stim_mth_actual.net_volume_bm
                    ,NET_VOLUME_SF      =  lr_stim_mth_actual.net_volume_sf
                    ,NET_VOLUME_NM      =  lr_stim_mth_actual.net_volume_nm
                    ,NET_VOLUME_SM      =  lr_stim_mth_actual.net_volume_sm
                    ,last_updated_by = 'SYSTEM'
              WHERE daytime = p_daytime
              AND  object_id = SMACur.a_object_id;

           END LOOP;
     END IF;
END GenMthStaticInvData;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : InstantiateMth
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE InstantiateMth(
     p_object_id VARCHAR2 -- Inventory Object ID
   ,p_daytime   DATE)
IS
--</EC-DOC>

lv2_valuation_method   VARCHAR(2000);
ld_layer_date          DATE;
lb_next                BOOLEAN := TRUE;
ln_cnt                 NUMBER := 0;

BEGIN

  -- insert all valid Inventories for a given month
  INSERT INTO INV_VALUATION iv
   (OBJECT_ID
    ,DAYTIME
    ,YEAR_CODE
    ,HISTORIC
    ,NAME
    ,DESCRIPTION
    ,VALUATION_LEVEL
    ,DOCUMENT_LEVEL_CODE
  ,CREATED_BY
  ,LAST_UPDATED_BY -- include this during insert to allow for standard processing in subsequent updates
  ,REV_TEXT
    ,VALUATION_METHOD
    ,INV_MONEY_DIST_METHOD
    ,INV_PRICING_VALUE_METHOD
   )
  SELECT
   OBJECT_ID
  ,Trunc(p_daytime,'MM')
  ,to_char(p_daytime,'YYYY')
  ,'FALSE'
  ,Ec_Inventory_Version.name(p_object_id,p_daytime, '<=')
  ,Ec_Inventory.description(p_object_id)
  ,Ec_Inventory_Version.valuation_level(p_object_id,p_daytime, '<=')
  ,'OPEN'
  ,'INSTANTIATE'
  ,'INSTANTIATE'
  ,'Instantiated record'
    ,Ec_Inventory_Version.valuation_method(p_object_id,p_daytime, '<=')
    ,Ec_Inventory_Version.inv_money_dist_method(p_object_id,p_daytime, '<=')
    ,Ec_Inventory_Version.inv_pricing_value_method(p_object_id,p_daytime, '<=')
  FROM inventory i
  WHERE i.object_id = p_object_id
    AND (p_daytime >= Nvl(i.start_date, p_daytime-1) AND p_daytime < Nvl(i.end_date, p_daytime+1))
    AND NOT EXISTS (SELECT 'x' FROM inv_valuation iv WHERE iv.object_id = i.object_id AND iv.daytime = Trunc(p_daytime,'MM'));

END InstantiateMth;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : ProcessInventory
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE ProcessInventory(
    p_object_id        VARCHAR2,
    p_daytime          DATE,
    p_user             VARCHAR2 DEFAULT NULL,
    p_process_historic VARCHAR2 DEFAULT 'FALSE'
    )
--</EC-DOC>
IS

ln_stim_records      NUMBER := 0;
lv2_valuation_method VARCHAR(2000);
lv2_doc_level_code   VARCHAR(2000);
ln_count_rows        NUMBER;

returntest      EXCEPTION;
pending_changes EXCEPTION;
illegal_level   EXCEPTION;
unbook_pending  EXCEPTION;

lrec_inv_valuation inv_valuation%ROWTYPE;
/*
CURSOR   c_if IS
  SELECT inf.field_id
    FROM inventory_field inf
   WHERE inf.inventory_id = p_object_id
     AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1));
*/
CURSOR  c_if_old IS
SELECT  dist_id
FROM    inv_dist_valuation
WHERE   object_id = p_object_id
AND     daytime = p_daytime
AND     dist_id NOT IN
        (SELECT inf.field_id
           FROM inventory_field inf
          WHERE inf.inventory_id = p_object_id
            AND (p_daytime >= Nvl(inf.start_date, p_daytime-1) AND p_daytime < Nvl(inf.end_date, p_daytime+1)));

BEGIN
    lv2_doc_level_code := ec_inv_valuation.document_level_code(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));

    SELECT count(*)
      INTO ln_count_rows
      FROM inv_valuation iv
     WHERE iv.object_id = p_object_id
     AND iv.daytime = p_daytime;

    IF ln_count_rows > 0 AND p_process_historic = 'FALSE' THEN
      IF lv2_doc_level_code <> 'OPEN' OR lv2_doc_level_code is null THEN
         RAISE illegal_level;
      END IF;

      lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

      IF lrec_inv_valuation.booking_date IS NOT NULL THEN
         RAISE unbook_pending;
      END IF;
    END IF;

    IF p_process_historic = 'FALSE' THEN
        -- Set year to date movement to zero since it is determined later
        UPDATE inv_valuation iv SET
            iv.ytd_ul_mov_qty1 = 0
            ,iv.ytd_ul_mov_qty2 = 0
            ,iv.ytd_ol_mov_qty1 = 0
            ,iv.ytd_ol_mov_qty2 = 0
            ,iv.ytd_ps_mov_qty1 = 0
            ,iv.ytd_ps_mov_qty2 = 0
        WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = to_char(p_daytime, 'YYYY');
    END IF;

    CheckDistRelations(p_object_id,p_daytime,p_user);                   -- SSK; Insert into INVENTORY_FIELD/INVENTORY_FIELD_VERSION

    lv2_valuation_method := ec_inventory_version.valuation_method(p_object_id, p_daytime, '<=');

      -- instantiates any new inventories not already processed, always commit here
      instantiatemth(p_object_id, p_daytime);                           -- SSK; Insert into INV_VALUATION/INV_LAYER

      -- copy the latest AS-IS data for this month to the inventory
      Genmthstaticinvdata(p_object_id,p_daytime,p_process_historic);    -- SSK; Insert into STIM_MTH_INV_BOOKED

      -- Process and update DIST position
      CalcDistPosition(p_object_id, p_daytime, p_user, p_process_historic);

     -- remove old records (needed if inventory is processed, then field / field_group is changed and inventory reprocessed)
      FOR CIFOldCur IN c_if_old LOOP

        DELETE FROM inv_dist_valuation
        WHERE object_id = p_object_id
        AND daytime = p_daytime
        AND dist_id = CIFOldCur.dist_id;

      END LOOP;

      -- set user and create revision
      UPDATE INV_VALUATION
         SET last_updated_by = p_user
       WHERE OBJECT_ID    =   p_object_id
         AND DAYTIME      =   p_daytime
         AND YEAR_CODE    =   to_char(p_daytime, 'YYYY');


     -- Update INV_VALUATION/INV_DIST_VALUATION. Rates and prod qtys
     -- DONE:
     -- TODO: Rates
     Calcavgulrate(p_object_id,p_daytime,p_process_historic);

     -- Update INV_VALUATION. *
     -- QTYs only
     CalcTotalPosition(p_object_id, p_daytime, p_user, p_process_historic);

     -- Make sure the UOMs are set correctly
     PopulateUOM(p_object_id, p_daytime, p_user);

     -- Make sure the Currencies are set correctly
     PopulateCurrencies(p_object_id, p_daytime, p_user);

     -- Pricing Values
     -- Update INV_VALUATION. *
     CalcPricingValue(p_object_id, p_daytime, p_user);

     -- Other currencies
     -- Update INV_VALUATION. *
     CalcCurrencyValues(p_object_id, p_daytime, p_user);


  EXCEPTION

     WHEN illegal_level THEN

              Raise_Application_Error(-20000,'It is not possible to process an inventory with a document level other than OPEN. The document level for this inventory is '||Nvl(lv2_doc_level_code,'empty')||'.' );

     WHEN unbook_pending THEN

              Raise_Application_Error(-20001,'Cannot process ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') || ' for ' || p_daytime || ' as it is pending for unbooking.');

     WHEN pending_changes THEN

              Raise_Application_Error(-20002,'There are ' || ln_stim_records || ' pending VO changes running in the background, please wait and retry');

END ProcessInventory;


PROCEDURE CreateRelInvDist(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_user                VARCHAR2 DEFAULT NULL
)
IS

--<EC-DOC>
CURSOR   c_field_group_field (pc_field_group_id  objects.object_id%TYPE) IS
SELECT *
FROM field_group_setup fgs
WHERE fgs.field_group_id = pc_field_group_id
AND   p_daytime >= Nvl(fgs.daytime,p_daytime-1);

lv2_valuation_level VARCHAR2(32);
lv2_pool_code   VARCHAR2(32);
lv2_pool_id  VARCHAR2(32);

no_valuation_level EXCEPTION;
not_valid_valuation_level EXCEPTION;

lv2_rel_code VARCHAR2(32);
lv2_new_rel VARCHAR2(32);
ln_count NUMBER;

BEGIN

    -- get valuation level

    lv2_valuation_level := NVL(ec_inventory_version.valuation_level(p_object_id, p_daytime, '<='),'POOL');

    -- get the field_group used

    lv2_pool_code   :=  ec_inventory_version.dist_code(p_object_id, p_daytime, '<=');


    IF lv2_valuation_level = 'POOL' THEN

        -- find all fields related to the pool and set up relations to the inventory.
       lv2_pool_id     := ec_field_group.object_id_by_uk(lv2_pool_code);

        FOR CFieldGroupField in c_field_group_field(lv2_pool_id) LOOP

            SELECT count(*) INTO ln_count FROM inventory_field WHERE inventory_id = p_object_id AND field_id = CFieldGroupField.object_id;
            IF (ln_count = 0) THEN
                Ecdp_System_Key.assignNextNumber('INVENTORY_FIELD', lv2_rel_code);
                lv2_rel_code := 'IF' || lv2_rel_code;
                INSERT INTO inventory_field (object_code, start_date, inventory_id, field_id)
                VALUES (lv2_rel_code, p_daytime, p_object_id, CFieldGroupField.object_id) RETURNING object_id INTO lv2_new_rel;

                INSERT INTO inventory_field_version (object_id,daytime)
                VALUES (lv2_new_rel, p_daytime);
            END IF;

        END LOOP;

    ELSIF lv2_valuation_level = 'SINGLE_FIELD' OR lv2_valuation_level = 'Single Field' THEN

            lv2_pool_id     := ec_field.object_id_by_uk(lv2_pool_code, 'FIELD');

            SELECT count(*) INTO ln_count FROM inventory_field WHERE inventory_id = p_object_id AND field_id = lv2_pool_id;
            IF (ln_count = 0) THEN
                Ecdp_System_Key.assignNextNumber('INVENTORY_FIELD', lv2_rel_code);
                lv2_rel_code := 'IF' || lv2_rel_code;
                INSERT INTO inventory_field (object_code, start_date, inventory_id, field_id)
                VALUES (lv2_rel_code, p_daytime, p_object_id, lv2_pool_id) RETURNING object_id INTO lv2_new_rel;

                INSERT INTO inventory_field_version (object_id,daytime)
                VALUES (lv2_new_rel, p_daytime);
            END IF;

    ELSE

         RAISE no_valuation_level;

    END IF;


EXCEPTION

     WHEN no_valuation_level THEN

              Raise_Application_Error(-20000,'No Valuation method defined - This i do weally not like' );

     WHEN not_valid_valuation_level THEN

              Raise_Application_Error(-20000,'Only Single Field Valuation are valid' );

END CreateRelInvDist;


PROCEDURE GenNewRates (
   p_object_id VARCHAR2, -- Inventory_ID
   p_daytime DATE)       -- Date to instantiate rates for
IS

CURSOR rates IS
  SELECT infv.*
  FROM inventory_field inf, inventory_field_version infv
  WHERE inf.inventory_id = p_object_id
  AND inf.object_id = infv.object_id
  AND inf.start_date = (SELECT MAX(inf2.start_date)
                        FROM inventory_field inf2
                        WHERE inf2.start_date <= p_daytime
                        AND inf2.object_id = inf.object_id)
  AND infv.daytime = (SELECT MAX(infv2.daytime)
                      FROM inventory_field_version infv2
                      WHERE infv2.daytime <= p_daytime
                      AND infv2.object_id = infv.object_id);

ld_end_date DATE;

BEGIN

    FOR Field IN rates LOOP

        INSERT INTO inventory_field_version (object_id,daytime, name, rate_1, rate_2, rate_3, rate_4, rate_5)
        VALUES (Field.Object_Id, p_daytime, Field.name, Field.rate_1, Field.rate_2, Field.rate_3, Field.rate_4, Field.rate_5);

        -- Set end_date on previous record
        UPDATE inventory_field_version SET end_date = p_daytime
        WHERE object_id = Field.Object_Id
        AND daytime = Field.daytime;

        -- Get next daytime, if there is a newer version after given date.
        ld_end_date := ec_inventory_field_version.next_daytime(Field.Object_Id, p_daytime);

        IF (ld_end_date IS NOT NULL) THEN
            -- Set end_date on current record
            UPDATE inventory_field_version SET end_date = ld_end_date
            WHERE object_id = Field.Object_Id
            AND daytime = p_daytime;
        END IF;

    END LOOP;

END GenNewRates;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setInventoryStatus
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE setInventoryStatus(
    p_object_id VARCHAR2,
    p_daytime DATE,
    p_doc_level VARCHAR2,
    p_user VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
IS

lrec_inv_valuation inv_valuation%ROWTYPE;
inventory_is_valid EXCEPTION;
unbook_pending EXCEPTION;

BEGIN

          lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));


          IF lrec_inv_valuation.document_level_code IN ('TRANSFER','BOOKED') THEN

              RAISE inventory_is_valid;

          ELSIF lrec_inv_valuation.booking_date IS NOT NULL
              AND ec_ctrl_system_attribute.attribute_text(p_daytime,'SELECT_BOOKING_PERIOD','<=') = 'N' THEN

               RAISE unbook_pending;

          ELSIF lrec_inv_valuation.booking_date IS NOT NULL
              AND ec_ctrl_system_attribute.attribute_text(p_daytime,'SELECT_BOOKING_PERIOD','<=') = 'Y'
              AND lrec_inv_valuation.document_level_code NOT IN ('OPEN','VALID1') THEN

               RAISE unbook_pending;

          ELSE

            IF p_doc_level = 'VALID1' AND lrec_inv_valuation.document_level_code <> 'VALID1' THEN

                validateInventory(p_object_id, p_daytime);

                -- get booking data
                genMthBookingData(p_object_id,p_daytime,'SYSTEM');

                UPDATE inv_valuation
                SET set_to_next_ind = 'Y'
                   ,last_updated_by = p_user
                WHERE object_id = p_object_id
                AND daytime     = p_daytime
                AND year_code   = to_char(p_daytime, 'YYYY');

                -- Fetch current layer after SET TO NEXT
                lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

                UPDATE inv_valuation
                SET document_level_code = lrec_inv_valuation.document_level_code
                   ,last_updated_by = p_user
                WHERE object_id = p_object_id
                AND daytime     = p_daytime
                AND year_code   <> to_char(p_daytime, 'YYYY');

            ELSIF (p_doc_level <> lrec_inv_valuation.document_level_code) THEN -- i.e. p_doc_level = 'OPEN'

                UPDATE inv_valuation
                SET set_to_prev_ind = 'Y'
                   ,last_updated_by = p_user
                WHERE object_id = p_object_id
                AND daytime     = p_daytime
                AND year_code   = to_char(p_daytime, 'YYYY');

                -- Fetch current layer after SET TO PREV
                lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

                UPDATE inv_valuation
                SET document_level_code = lrec_inv_valuation.document_level_code
                   ,last_updated_by = p_user
                WHERE object_id = p_object_id
                AND daytime     = p_daytime
                AND year_code   <> to_char(p_daytime, 'YYYY');

            END IF;

          END IF;

EXCEPTION

     WHEN inventory_is_valid THEN

              Raise_Application_Error(-20000,'The Inventory is already valid' );

     WHEN unbook_pending THEN

              Raise_Application_Error(-20000,'Status cannot be changed ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') || ' for ' || p_daytime || ' as it is pending for unbooking.');


END setInventoryStatus;



PROCEDURE GenMthBookingData(
        p_object_id VARCHAR2
       ,p_daytime   DATE
       , -- booking period
        p_user      VARCHAR2)

IS

    CURSOR c_if IS
    SELECT * FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime;

    CURSOR c_inv IS
    SELECT * FROM inv_valuation WHERE object_id = p_object_id AND daytime = p_daytime;

    invalid_period EXCEPTION;
    missing_account EXCEPTION;
    missing_deb_cost_object EXCEPTION;
    missing_cred_cost_object EXCEPTION;

    lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;
    lrec_inv_valuation       inv_valuation%ROWTYPE := ec_inv_valuation.row_by_pk(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

    lv2_pri_li_code                  VARCHAR2(32);
    lv2_sec_li_code                  VARCHAR2(32);
    lv2_pri_credit_accnt_id          VARCHAR2(32);
    lv2_pri_debit_accnt_id           VARCHAR2(32);
    lv2_pri_debit_cost_obj_type      VARCHAR2(32);
    lv2_pri_credit_cost_obj_type     VARCHAR2(32);
    lv2_sec_credit_accnt_id          VARCHAR2(32);
    lv2_sec_debit_accnt_id           VARCHAR2(32);
    lv2_sec_debit_cost_obj_type      VARCHAR2(32);
    lv2_sec_credit_cost_obj_type     VARCHAR2(32);
    lv2_company_id                   VARCHAR2(32);
    lv2_err_text                     VARCHAR2(2000);
    lv2_inventory_type               VARCHAR2(32);
    lv2_product                      VARCHAR2(32);
    lv2_product_obj_id               VARCHAR2(32);
    lv2_company                      VARCHAR2(32);
    lv2_ps_ind                       VARCHAR2(1);
    lv2_pri_cre_ps_accnt_id          VARCHAR2(32);
    lv2_pri_deb_ps_accnt_id          VARCHAR2(32);
    lv2_pri_deb_ps_cost_obj_type     VARCHAR2(32);
    lv2_pri_cre_ps_cost_obj_type     VARCHAR2(32);
    lv2_sec_cre_ps_accnt_id          VARCHAR2(32);
    lv2_sec_deb_ps_accnt_id          VARCHAR2(32);
    lv2_sec_deb_ps_cost_obj_type     VARCHAR2(32);
    lv2_sec_cre_ps_cost_obj_type     VARCHAR2(32);

BEGIN

    -- Verify that the rates are in place
    FOR CurInv IN c_inv LOOP
        IF (IsInOverLift(p_object_id, p_daytime) = 'TRUE') THEN
            -- Verify that we have a OL rate present...
            IF (ec_inv_valuation.ol_price_value(p_object_id, p_daytime, CurInv.year_code) IS NULL AND to_char(p_daytime, 'YYYY') = CurInv.year_code) THEN
                Raise_Application_Error(-20000,'Overlift pricing value not calculated. Is OL rate present?' );
            END IF;
        END IF;

        IF (Ec_Inventory_Version.physical_stock_ind(p_object_id, p_daytime, '<=') = 'Y') THEN
            -- Verify that we have a PS rate present...
            IF (ec_inv_valuation.ps_price_value(p_object_id, p_daytime, CurInv.year_code) IS NULL) THEN
                Raise_Application_Error(-20000,'Physical stock pricing value not calculated. Is PS rate present?' );
            END IF;
        END IF;
    END LOOP;

    IF (ue_Inventory.isGenMthBookingDataUEEnabled = 'TRUE') THEN
        ue_Inventory.GenMthBookingData(p_object_id, p_daytime, p_user);
    ELSE -- No user exit, normal code
        -- Get the inventory type which will be used for accounf mapping
        lv2_inventory_type := 'INVENTORY';
        lv2_ps_ind := ec_inventory_version.physical_stock_ind(p_object_id, p_daytime, '<=');
        -- Get the product which will be used for accounf mapping
        lv2_product_obj_id := ec_inventory_version.product_id(p_object_id, p_daytime, '<=');
        lv2_product := ec_product.object_code(lv2_product_obj_id);

        -- Get the company which will be used for accounf mapping
        lv2_company_id := ec_inventory_version.company_id(p_object_id, p_daytime, '<=');
        lv2_company := ec_company.object_code(lv2_company_id);

        FOR C_IFCur IN c_if LOOP
            -- Clear temporary variables
            lv2_pri_li_code               := NULL;
            lv2_sec_li_code               := NULL;
            lv2_pri_credit_accnt_id       := NULL;
            lv2_pri_debit_accnt_id        := NULL;
            lv2_pri_debit_cost_obj_type   := NULL;
            lv2_pri_credit_cost_obj_type  := NULL;
            lv2_sec_credit_accnt_id       := NULL;
            lv2_sec_debit_accnt_id        := NULL;
            lv2_sec_debit_cost_obj_type   := NULL;
            lv2_sec_credit_cost_obj_type  := NULL;
            lv2_pri_cre_ps_accnt_id       := NULL;
            lv2_pri_deb_ps_accnt_id       := NULL;
            lv2_pri_deb_ps_cost_obj_type  := NULL;
            lv2_pri_cre_ps_cost_obj_type  := NULL;
            lv2_sec_cre_ps_accnt_id       := NULL;
            lv2_sec_deb_ps_accnt_id       := NULL;
            lv2_sec_deb_ps_cost_obj_type  := NULL;
            lv2_sec_cre_ps_cost_obj_type  := NULL;

            -- determine cost object (if any)
    --        lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id,C_IFCur.field_id,p_daytime, to_char(p_daytime, 'YYYY'));
            lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id, C_IFCur.dist_id, p_daytime, C_IFCur.Year_Code);

            -- get material code
            lrec_inv_dist_valuation.fin_material_number := getInvMaterialCode(p_object_id,p_daytime);

            -- get booking info
            IF lrec_inv_valuation.ul_closing_pos_qty1 >= 0 AND (lrec_inv_valuation.ol_closing_pos_qty1 IS NULL OR lrec_inv_valuation.ol_closing_pos_qty1 = 0) THEN -- Underlift
                lv2_pri_li_code := ec_inventory_version.pri_ul_li_code(p_object_id,p_daytime,'<=');

                -- Primary
                IF NVL(lrec_inv_dist_valuation.ul_price_value, 0) + NVL(lrec_inv_dist_valuation.ol_price_value, 0) >= 0 THEN -- DistUnderlift

                    lv2_pri_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                    lv2_pri_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    lrec_inv_dist_valuation.fin_debit_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_pri_debit_accnt_id
                                                                                                  ,p_daytime
                                                                                                  ,'<=');
                    lrec_inv_dist_valuation.fin_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_pri_credit_accnt_id
                                                                                                  ,p_daytime
                                                                                                  ,'<=');

                ELSE -- DistOverlift

                    lv2_pri_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                    lv2_pri_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    lrec_inv_dist_valuation.fin_debit_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_pri_debit_accnt_id
                                                                                                  ,p_daytime
                                                                                                  ,'<=');
                    lrec_inv_dist_valuation.fin_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_pri_credit_accnt_id
                                                                                                  ,p_daytime
                                                                                                  ,'<=');

                END IF;

                -- Secondary
                lv2_sec_li_code := ec_inventory_version.sec_ul_li_code(p_object_id,p_daytime,'<=');
                IF (lv2_sec_li_code IS NOT NULL) THEN

                    IF NVL(lrec_inv_dist_valuation.ul_price_value, 0) + NVL(lrec_inv_dist_valuation.ol_price_value, 0) >= 0 THEN -- DistUnderlift

                        lv2_sec_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'DEBIT', null, lv2_product, lv2_company, NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                        lv2_sec_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                        lrec_inv_dist_valuation.fin_int_deb_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_sec_debit_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');
                        lrec_inv_dist_valuation.fin_int_cre_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_sec_credit_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');

                    ELSE -- Negative Underlift Movement

                        lv2_sec_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                        lv2_sec_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                        lrec_inv_dist_valuation.fin_int_deb_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_sec_debit_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');
                        lrec_inv_dist_valuation.fin_int_cre_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_sec_credit_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');

                    END IF;
                END IF;



            ELSE -- Overlift

                lv2_pri_li_code := ec_inventory_version.pri_ol_li_code(p_object_id, p_daytime, '<=');
                -- Primary
                IF NVL(lrec_inv_dist_valuation.ul_price_value, 0) + NVL(lrec_inv_dist_valuation.ol_price_value, 0) <= 0 THEN -- DistOverlift

                   lv2_pri_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                   lv2_pri_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    lrec_inv_dist_valuation.fin_debit_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_pri_debit_accnt_id,p_daytime,'<=');
                    lrec_inv_dist_valuation.fin_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_pri_credit_accnt_id,p_daytime,'<=');

                ELSE -- DistUnderlift

                   lv2_pri_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'CREDIT', null,  lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                   lv2_pri_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_pri_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    lrec_inv_dist_valuation.fin_debit_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_pri_debit_accnt_id,p_daytime,'<=');
                    lrec_inv_dist_valuation.fin_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_pri_credit_accnt_id,p_daytime,'<=');


                END IF;

                -- Secondary
                lv2_sec_li_code := ec_inventory_version.sec_ol_li_code(p_object_id,p_daytime,'<=');
                IF (lv2_sec_li_code IS NOT NULL) THEN

                    IF NVL(lrec_inv_dist_valuation.ul_price_value, 0) + NVL(lrec_inv_dist_valuation.ol_price_value, 0) < 0 THEN -- DistOverlift

                       lv2_sec_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                       lv2_sec_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                        lrec_inv_dist_valuation.fin_int_deb_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_sec_debit_accnt_id,p_daytime,'<=');
                        lrec_inv_dist_valuation.fin_int_cre_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_sec_credit_accnt_id,p_daytime,'<=');

                    ELSE -- DistUnderlift
                       lv2_sec_debit_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'CREDIT', null,  lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                       lv2_sec_credit_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type, 'ALL', 'ALL', lv2_sec_li_code, 'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                        lrec_inv_dist_valuation.fin_int_deb_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_sec_debit_accnt_id,p_daytime,'<=');
                        lrec_inv_dist_valuation.fin_int_cre_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_sec_credit_accnt_id,p_daytime,'<=');

                    END IF;
                END IF;

            END IF;

            IF lv2_pri_debit_accnt_id IS NULL OR lv2_pri_credit_accnt_id IS NULL THEN

                lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                ', dist ' || ec_field_version.name(C_IFCur.dist_id,p_daytime,'<=') ||
                                ' using the following PRIMARY_LINE_ITEM_TYPE: ' || lv2_pri_li_code ||
                                ' and the following SECONDARY_LINE_ITEM_TYPE: ' || lv2_sec_li_code;

                RAISE missing_account;

            END IF;

            lv2_pri_debit_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_pri_debit_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');

            lv2_pri_credit_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_pri_credit_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');

            lv2_sec_debit_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_sec_debit_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');

            lv2_sec_credit_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_sec_credit_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');


            lrec_inv_dist_valuation.fin_debit_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_pri_debit_cost_obj_type
                                                                                               ,lv2_company_id
                                                                                               ,C_IFCur.dist_id
                                                                                               ,NULL
                                                                                               ,lv2_pri_li_code
                                                                                               ,lv2_product_obj_id
                                                                                               ,p_daytime);

            lrec_inv_dist_valuation.fin_credit_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_pri_credit_cost_obj_type
                                                                                                ,lv2_company_id
                                                                                                ,C_IFCur.dist_id
                                                                                                ,NULL
                                                                                                ,lv2_pri_li_code
                                                                                                ,lv2_product_obj_id
                                                                                                ,p_daytime);

            IF (lv2_sec_li_code IS NOT NULL) THEN
                lrec_inv_dist_valuation.fin_int_deb_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_sec_debit_cost_obj_type
                                                                                                   ,lv2_company_id
                                                                                                   ,C_IFCur.dist_id
                                                                                                   ,NULL
                                                                                                   ,lv2_sec_li_code
                                                                                                   ,lv2_product_obj_id
                                                                                                   ,p_daytime);

                lrec_inv_dist_valuation.fin_int_cre_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_sec_credit_cost_obj_type
                                                                                                    ,lv2_company_id
                                                                                                    ,C_IFCur.dist_id
                                                                                                    ,NULL
                                                                                                    ,lv2_sec_li_code
                                                                                                    ,lv2_product_obj_id
                                                                                                    ,p_daytime);
            END IF;

            IF lrec_inv_dist_valuation.fin_debit_cost_object IS NULL AND Nvl(lv2_pri_debit_cost_obj_type, 'N') <> 'N' THEN

                lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                ' using the following parameters: ' ||
                               --  'COST_OBJECT_TYPE => ' || lv2_debit_cost_obj_type || ' ' || lv2_debit_cost_obj_type ||
                                ', COMPANY => ' || Nvl(ec_company_version.name(lv2_company_id, p_daytime, '<=')
                                                      , lv2_company) ||
                                ', DIST => ' || Nvl(ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=')
                                                    ,ec_field.object_code(C_IFCur.dist_id));

                RAISE missing_deb_cost_object;

            END IF;

            IF lrec_inv_dist_valuation.fin_credit_cost_object IS NULL AND
               Nvl(lv2_pri_credit_cost_obj_type, 'N') <> 'N' THEN

                lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                ' using the following parameters: ' ||
                               --  'COST_OBJECT_TYPE => ' || lv2_debit_cost_obj_type || ' ' || lv2_debit_cost_obj_type ||
                                ', COMPANY => ' || Nvl(ec_company_version.name(lv2_company_id, p_daytime, '<=')
                                                      , lv2_company) ||
                                ', DIST => ' || Nvl(ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=')
                                                    ,ec_field.object_code(C_IFCur.dist_id));

                RAISE missing_cred_cost_object;

            END IF;

            --if physical stock is enabled
            IF lv2_ps_ind = 'Y' THEN

                lv2_pri_li_code := ec_inventory_version.pri_ps_li_code(p_object_id, p_daytime, '<=');

                IF lrec_inv_dist_valuation.ps_booking_value >= 0 THEN

                    lv2_pri_deb_ps_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_pri_li_code,'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                    lv2_pri_cre_ps_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_pri_li_code,'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                ELSE

                    -- switch the credit/debit if the physical stock value is negative
                    lv2_pri_deb_ps_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_pri_li_code,'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                    lv2_pri_cre_ps_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_pri_li_code,'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                END IF;


                IF lv2_pri_deb_ps_accnt_id IS NULL OR lv2_pri_cre_ps_accnt_id IS NULL THEN

                    lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                    ', dist ' || ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=') ||
                                    ' using the following LINE_ITEM_TYPE: ' || lv2_pri_li_code;

                    RAISE missing_account;

                END IF;

                    lrec_inv_dist_valuation.fin_ps_debit_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_pri_deb_ps_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');
                    lrec_inv_dist_valuation.fin_ps_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_pri_cre_ps_accnt_id
                                                                                                      ,p_daytime
                                                                                                      ,'<=');


                lv2_pri_deb_ps_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_pri_deb_ps_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');

                lv2_pri_cre_ps_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_pri_cre_ps_accnt_id
                                                                                                ,p_daytime, '<='), p_daytime, '<=');


                lrec_inv_dist_valuation.fin_ps_debit_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_pri_deb_ps_cost_obj_type
                                                                                                   ,lv2_company_id
                                                                                                   ,C_IFCur.dist_id
                                                                                                   ,NULL
                                                                                                   ,lv2_pri_li_code
                                                                                                   ,lv2_product_obj_id
                                                                                                   ,p_daytime);

                lrec_inv_dist_valuation.fin_ps_credit_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_pri_cre_ps_cost_obj_type
                                                                                                    ,lv2_company_id
                                                                                                    ,C_IFCur.dist_id
                                                                                                    ,NULL
                                                                                                    ,lv2_pri_li_code
                                                                                                    ,lv2_product_obj_id
                                                                                                    ,p_daytime);

                -- SECONDARY
                lv2_sec_li_code := ec_inventory_version.sec_ps_li_code(p_object_id, p_daytime, '<=');
                IF (lv2_sec_li_code IS NOT NULL) THEN

                    IF lrec_inv_dist_valuation.ps_booking_value >= 0 THEN

                        lv2_sec_deb_ps_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_sec_li_code,'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                        lv2_sec_cre_ps_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_sec_li_code,'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    ELSE

                        lv2_sec_deb_ps_accnt_id  := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_sec_li_code,'CREDIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);
                        lv2_sec_cre_ps_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_inventory_type,'ALL','ALL',lv2_sec_li_code,'DEBIT', null, lv2_product, lv2_company,  NULL, NULL, p_daytime, C_IFCur.dist_id, NULL, p_object_id);

                    END IF;

                    IF lv2_sec_deb_ps_accnt_id IS NULL OR lv2_sec_cre_ps_accnt_id IS NULL THEN

                        lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                        ', dist ' || ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=') ||
                                        ' using the following LINE_ITEM_TYPE: ' || lv2_sec_li_code;

                        RAISE missing_account;

                    END IF;


                        lrec_inv_dist_valuation.fin_int_ps_dr_posting_key  := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_sec_deb_ps_accnt_id
                                                                                                          ,p_daytime
                                                                                                          ,'<=');
                        lrec_inv_dist_valuation.fin_int_ps_cr_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_sec_cre_ps_accnt_id
                                                                                                          ,p_daytime
                                                                                                          ,'<=');


                    lv2_sec_deb_ps_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_sec_deb_ps_accnt_id
                                                                                                    ,p_daytime, '<='), p_daytime, '<=');

                    lv2_sec_cre_ps_cost_obj_type  := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_sec_cre_ps_accnt_id
                                                                                                    ,p_daytime, '<='), p_daytime, '<=');


                    lrec_inv_dist_valuation.fin_int_ps_dr_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_sec_deb_ps_cost_obj_type
                                                                                                       ,lv2_company_id
                                                                                                       ,C_IFCur.dist_id
                                                                                                       ,NULL
                                                                                                       ,lv2_sec_li_code
                                                                                                       ,lv2_product_obj_id
                                                                                                       ,p_daytime);

                    lrec_inv_dist_valuation.fin_int_ps_cr_cost_object := EcDp_Fin_Cost_Object.GetCostObjID(lv2_sec_cre_ps_cost_obj_type
                                                                                                        ,lv2_company_id
                                                                                                        ,C_IFCur.dist_id
                                                                                                        ,NULL
                                                                                                        ,lv2_sec_li_code
                                                                                                        ,lv2_product_obj_id
                                                                                                        ,p_daytime);

            END IF; -- Secondary


                IF lrec_inv_dist_valuation.fin_ps_debit_cost_object IS NULL AND Nvl(lv2_pri_deb_ps_cost_obj_type, 'N') <> 'N' THEN

                    lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                    ' using the following parameters : ' ||
                                   --  'COST_OBJECT_TYPE => ' || lv2_debit_cost_obj_type || ' ' || lv2_debit_cost_obj_type ||
                                ', COMPANY => ' || Nvl(ec_company_version.name(lv2_company_id, p_daytime, '<=')
                                                      , lv2_company) ||
                                ', DIST => ' || Nvl(ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=')
                                                    ,ec_field.object_code(C_IFCur.dist_id));

                    RAISE missing_deb_cost_object;

                END IF;

                IF lrec_inv_dist_valuation.fin_ps_credit_cost_object IS NULL AND Nvl(lv2_pri_cre_ps_cost_obj_type, 'N') <> 'N' THEN

                    lv2_err_text := 'inventory ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') ||
                                    ' using the following parameters : ' ||
                                   --  'COST_OBJECT_TYPE => ' || lv2_credit_cost_obj_type || ' ' || lv2_credit_cost_obj_type ||
                                ', COMPANY => ' || Nvl(ec_company_version.name(lv2_company_id, p_daytime, '<=')
                                                      , lv2_company) ||
                                ', DIST => ' || Nvl(ec_field_version.name(C_IFCur.dist_id, p_daytime, '<=')
                                                    ,ec_field.object_code(C_IFCur.dist_id));

                    RAISE missing_cred_cost_object;

                END IF;


            END IF; --end if physical stock is enabled


            -- then set any figures
            UPDATE INV_DIST_VALUATION x
               SET x.fin_debit_posting_key = lrec_inv_dist_valuation.fin_debit_posting_key,
                   x.fin_debit_account_id  = ec_fin_acc_mapping_version.fin_account_id(lv2_pri_debit_accnt_id, p_daytime, '<='),
                   x.fin_debit_gl_account  = EcDp_Fin_Account.GetAccntNo(lv2_pri_debit_accnt_id,
                                                                         NULL,
                                                                         p_daytime),
                   x.fin_debit_cost_object = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_debit_cost_object,p_daytime),
                   x.fin_credit_posting_key   = lrec_inv_dist_valuation.fin_credit_posting_key,
                   x.fin_credit_account_id    = ec_fin_acc_mapping_version.fin_account_id(lv2_pri_credit_accnt_id, p_daytime, '<='),
                   x.fin_credit_gl_account    = EcDp_Fin_Account.GetAccntNo(lv2_pri_credit_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_credit_cost_object   = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_credit_cost_object,p_daytime),
                   x.fin_material_number      = lrec_inv_dist_valuation.fin_material_number,
                   x.fin_debit_cost_obj_type  = lv2_pri_debit_cost_obj_type,
                   x.fin_credit_cost_obj_type = lv2_pri_credit_cost_obj_type,

                   x.fin_int_deb_posting_key  = lrec_inv_dist_valuation.fin_int_deb_posting_key,
                   x.fin_int_deb_account_id   = ec_fin_acc_mapping_version.fin_account_id(lv2_sec_debit_accnt_id, p_daytime, '<='),
                   x.fin_int_deb_gl_account   = EcDp_Fin_Account.GetAccntNo(lv2_sec_debit_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_int_deb_cost_object  = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_int_deb_cost_object,p_daytime),
                   x.fin_int_cre_posting_key  = lrec_inv_dist_valuation.fin_int_cre_posting_key,
                   x.fin_int_cre_account_id   = ec_fin_acc_mapping_version.fin_account_id(lv2_sec_credit_accnt_id, p_daytime, '<='),
                   x.fin_int_cre_gl_account   = EcDp_Fin_Account.GetAccntNo(lv2_sec_credit_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_int_cre_cost_object  = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_int_cre_cost_object,p_daytime),


                   x.fin_int_deb_cost_o_type  = lv2_sec_debit_cost_obj_type,
                   x.fin_int_cre_cost_o_type  = lv2_sec_credit_cost_obj_type,
                   x.fin_ps_debit_posting_key  = lrec_inv_dist_valuation.fin_ps_debit_posting_key,
                   x.fin_ps_debit_account_id   = ec_fin_acc_mapping_version.fin_account_id(lv2_pri_deb_ps_accnt_id, p_daytime, '<='),
                   x.fin_ps_debit_gl_account   = EcDp_Fin_Account.GetAccntNo(lv2_pri_deb_ps_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_ps_debit_cost_object  = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_ps_debit_cost_object,p_daytime),
                   x.fin_ps_credit_posting_key  = lrec_inv_dist_valuation.fin_ps_credit_posting_key,
                   x.fin_ps_credit_account_id   = ec_fin_acc_mapping_version.fin_account_id(lv2_pri_cre_ps_accnt_id, p_daytime, '<='),
                   x.fin_ps_credit_gl_account   = EcDp_Fin_Account.GetAccntNo(lv2_pri_cre_ps_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_ps_credit_cost_object  = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_ps_credit_cost_object,p_daytime),

                   x.fin_ps_deb_cost_obj_type  = lv2_pri_deb_ps_cost_obj_type,
                   x.fin_ps_cre_cost_obj_type  = lv2_pri_cre_ps_cost_obj_type,

                   x.fin_int_ps_cr_account_id  = ec_fin_acc_mapping_version.fin_account_id(lv2_sec_cre_ps_accnt_id, p_daytime, '<='),
                   x.fin_int_ps_cr_cost_object = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_int_ps_cr_cost_object,p_daytime),
                   x.fin_int_ps_cr_gl_account  = EcDp_Fin_Account.GetAccntNo(lv2_sec_cre_ps_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_int_ps_cr_posting_key = lrec_inv_dist_valuation.fin_int_ps_cr_posting_key,
                   x.fin_int_ps_dr_account_id  = ec_fin_acc_mapping_version.fin_account_id(lv2_sec_deb_ps_accnt_id, p_daytime, '<='),
                   x.fin_int_ps_dr_cost_object = ecdp_fin_cost_object.getcostobject(lrec_inv_dist_valuation.fin_int_ps_dr_cost_object,p_daytime),

                   x.fin_int_ps_dr_gl_account  =  EcDp_Fin_Account.GetAccntNo(lv2_sec_deb_ps_accnt_id,
                                                                            NULL,
                                                                            p_daytime),
                   x.fin_int_ps_dr_posting_key = lrec_inv_dist_valuation.fin_int_ps_dr_posting_key,
                   x.fin_int_ps_dr_cost_obj_type  = lv2_sec_deb_ps_cost_obj_type,
                   x.fin_int_ps_cr_cost_obj_type  = lv2_sec_cre_ps_cost_obj_type,
                   x.fin_interface_file       = NULL, -- empty this in case of any previous transfers
                   x.last_updated_by          = p_user
             WHERE x.object_id = p_object_id
               AND x.dist_id = C_IFCur.dist_id
               AND x.daytime = p_daytime
               AND x.year_code = C_IFCur.year_code;

        END LOOP;
    END IF;



EXCEPTION

    WHEN invalid_period THEN

        Raise_Application_Error(-20000
                               ,'An attempt was made to book against a closed or invalid period: ' ||
                                Nvl(to_char(p_daytime, 'MM.YYYY')
                                   ,'<NULL>'));

    WHEN missing_account THEN

        Raise_Application_Error(-20000
                               ,'No account mapping was found for ' ||
                                lv2_err_text);

    WHEN missing_deb_cost_object THEN

        Raise_Application_Error(-20000
                               ,'No debit cost object was found for ' ||
                                lv2_err_text);

    WHEN missing_cred_cost_object THEN

        Raise_Application_Error(-20000
                               ,'No credit cost object was found for ' ||
                                lv2_err_text);

END GenMthBookingData;

PROCEDURE GenMthReversalBookingData(
   p_object_id VARCHAR2,
   p_daytime   DATE, -- booking period
   p_user      VARCHAR2
)
IS

CURSOR   c_if IS
SELECT   *
FROM inventory_field inf
WHERE inf.inventory_id = p_object_id
AND       (p_daytime >= Nvl(start_date,p_daytime-1) AND p_daytime < Nvl(end_date,p_daytime+1));

invalid_period EXCEPTION;

lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;

lv2_old_debit_posting_key inv_dist_valuation.fin_debit_posting_key%TYPE;
--Ref ECPD-9961 - Added to handle all the posting keys:
lv2_old_int_deb_posting_key inv_dist_valuation.fin_int_deb_posting_key%TYPE;
lv2_old_ps_debit_posting_key inv_dist_valuation.fin_ps_debit_posting_key%TYPE;
lv2_old_int_ps_dr_posting_key inv_dist_valuation.fin_int_ps_dr_posting_key%TYPE;

BEGIN

       FOR C_IFCur IN c_if LOOP


          lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id,C_IFCur.field_id,p_daytime, to_char(p_daytime, 'YYYY'));

          -- switch posting keys - find the old ones for the debit side
          lv2_old_debit_posting_key := lrec_inv_dist_valuation.fin_debit_posting_key;
          --Ref ECPD-9961 - Added to handle all the posting keys:
          lv2_old_int_deb_posting_key := lrec_inv_dist_valuation.fin_int_deb_posting_key;
          lv2_old_ps_debit_posting_key := lrec_inv_dist_valuation.fin_ps_debit_posting_key;
          lv2_old_int_ps_dr_posting_key := lrec_inv_dist_valuation.fin_int_ps_dr_posting_key;
          -- Doing the switch:
          --Primary UL/OL
          lrec_inv_dist_valuation.fin_debit_posting_key := lrec_inv_dist_valuation.fin_credit_posting_key;
          lrec_inv_dist_valuation.fin_credit_posting_key := lv2_old_debit_posting_key;

          --Ref ECPD-9961 - Added to handle all the posting keys:
          --Secondary UL/OL
          lrec_inv_dist_valuation.fin_int_deb_posting_key:= lrec_inv_dist_valuation.fin_int_cre_posting_key;
          lrec_inv_dist_valuation.fin_int_cre_posting_key := lv2_old_int_deb_posting_key;
          --Primary PS
          lrec_inv_dist_valuation.fin_ps_debit_posting_key := lrec_inv_dist_valuation.fin_ps_credit_posting_key;
          lrec_inv_dist_valuation.fin_ps_credit_posting_key := lv2_old_ps_debit_posting_key;
          --Secondary PS
          lrec_inv_dist_valuation.fin_int_ps_dr_posting_key := lrec_inv_dist_valuation.fin_int_ps_cr_posting_key;
          lrec_inv_dist_valuation.fin_int_ps_cr_posting_key := lv2_old_int_ps_dr_posting_key;


           -- then set any figures
           UPDATE INV_DIST_VALUATION x
             SET
              x.fin_debit_posting_key = lrec_inv_dist_valuation.fin_debit_posting_key,
              x.fin_credit_posting_key = lrec_inv_dist_valuation.fin_credit_posting_key,
              x.fin_int_deb_posting_key = lrec_inv_dist_valuation.fin_int_deb_posting_key,
              x.fin_int_cre_posting_key = lrec_inv_dist_valuation.fin_int_cre_posting_key,
              x.fin_ps_debit_posting_key = lrec_inv_dist_valuation.fin_ps_debit_posting_key,
              x.fin_ps_credit_posting_key = lrec_inv_dist_valuation.fin_ps_credit_posting_key,
              x.fin_int_ps_dr_posting_key = lrec_inv_dist_valuation.fin_int_ps_dr_posting_key,
              x.fin_int_ps_cr_posting_key = lrec_inv_dist_valuation.fin_int_ps_cr_posting_key,
              x.fin_interface_file = NULL, -- empty this in case of any previous transfers
              x.last_updated_by = p_user
            WHERE x.object_id = p_object_id
               AND x.dist_id = C_IFCur.field_id
               AND x.daytime = p_daytime
               --Ref ECPD-9961: The following should be commented out!
               AND x.year_code = to_char(p_daytime, 'YYYY');

        END LOOP;

END GenMthReversalBookingData;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMaterialCodeFromSreamItem
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE GenMthAsIsInvData(
   p_object_id          VARCHAR2,
   p_daytime             DATE,
   p_last_run_time       DATE
)
--</EC-DOC>
IS

CURSOR c_siv IS
SELECT smv.*
FROM stim_mth_value smv, inventory_stim_setup iss
WHERE smv.object_id = iss.stream_item_id
AND iss.object_id = p_object_id
AND iss.daytime <= p_daytime
AND smv.daytime = p_daytime
AND smv.last_updated_date >= p_last_run_time;

lr_net_sub_uom ecdp_stream_item.t_net_sub_uom;
lr_this_value stim_mth_value%ROWTYPE;

BEGIN

        -- create empty records
        INSERT INTO stim_mth_actual
        (object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         created_by,
         created_date
        )
        SELECT
         smv.object_id,
         smv.daytime,
         smv.status,
         smv.period_ref_item,
         smv.calc_method,
         smv.comments,
         'SYSTEM',
         Ecdp_Timestamp.getCurrentSysdate
        FROM stim_mth_value smv, inventory_stim_setup iss
        WHERE smv.daytime = p_daytime
         AND smv.object_id = iss.stream_item_id
         AND iss.object_id = p_object_id
         AND p_daytime >= Nvl(iss.daytime,p_daytime-1)
         AND NOT EXISTS (SELECT 'x' FROM stim_mth_actual
                  WHERE object_id = smv.object_id
                    AND daytime = smv.daytime) ;

        FOR StrmItmCur IN c_siv LOOP

         lr_this_value := StrmItmCur;

         lr_net_sub_uom.net_energy_jo :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'E', 'JO');

         lr_net_sub_uom.net_energy_th :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'E', 'TH');

         lr_net_sub_uom.net_energy_wh :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'E', 'WH');

         lr_net_sub_uom.net_energy_be :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'E', 'BE');

         lr_net_sub_uom.net_mass_ma :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'M', 'MA');

         lr_net_sub_uom.net_mass_mv :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'M', 'MV');

         lr_net_sub_uom.net_mass_ua :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'M', 'UA');

         lr_net_sub_uom.net_mass_uv :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'M', 'UV');

         lr_net_sub_uom.net_volume_bi :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'V', 'BI');

         lr_net_sub_uom.net_volume_bm :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'V', 'BM');

         lr_net_sub_uom.net_volume_sf :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'V', 'SF');

         lr_net_sub_uom.net_volume_nm :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'V', 'NM');

         lr_net_sub_uom.net_volume_sm :=
              ecdp_stream_item.GetSubGroupValue(lr_this_value, 'V', 'SM');

         -- now update table
         UPDATE stim_mth_actual
           SET NET_ENERGY_JO         = lr_net_sub_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_uom.NET_MASS_UV
              ,NET_VOLUME_BI         = lr_net_sub_uom.NET_VOLUME_BI
              ,NET_VOLUME_BM         = lr_net_sub_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_uom.NET_VOLUME_SM
              ,last_updated_by = 'SYSTEM'
         WHERE object_id = StrmItmCur.object_id
           AND daytime = StrmItmCur.daytime;

     END LOOP;

END GenMthAsIsInvData;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMaterialCodeFromSreamItem
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION GetMaterialCodeFromSreamItem(
   p_object_id          VARCHAR2,
   p_daytime             DATE
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR   c_InvStreamItem IS
SELECT a.*
FROM  stim_mth_inv_booked a, inventory_stim_setup c
WHERE a.daytime = p_daytime
and a.object_id = c.stream_item_id
and c.object_id = p_object_id
and p_daytime >= Nvl(c.daytime,p_daytime-1);

lv2_product_id VARCHAR2(32);
lv2_prev_product_id VARCHAR2(32);
lv2_stream_id VARCHAR2(32);
lv2_material_code VARCHAR2(32);
ln_stream_item_count NUMBER := 0;

BEGIN

   -- get the inventory product_group_code

   FOR InvStreamItemCur IN c_InvStreamItem LOOP

       -- get the stream for the stream item
      lv2_stream_id := ec_stream_item.stream_id(InvStreamItemCur.object_id);

       IF ln_stream_item_count = 0 THEN

           lv2_prev_product_id :=  lv2_product_id;

       ELSE

           lv2_product_id := ec_stream_item_version.product_id(InvStreamItemCur.object_id, p_daytime, '<=');

       END IF;

       IF  NVL(lv2_product_id,'XXX') = NVL(lv2_prev_product_id,'XXX') THEN

           lv2_product_id := ec_stream_item_version.product_id(InvStreamItemCur.object_id, p_daytime, '<=');

           lv2_material_code := ec_product_version.erp_code(lv2_product_id,p_daytime,'<=');

           lv2_prev_product_id :=  lv2_product_id;

           ln_stream_item_count := ln_stream_item_count + 1;

       ELSE

            lv2_material_code := 'UNDEFINED';

            EXIT;

       END IF;

   END LOOP;

  RETURN lv2_material_code;

END GetMaterialCodeFromSreamItem;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetInvMaterialCode
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION GetInvMaterialCode(
   p_object_id          VARCHAR2,
   p_daytime             DATE
)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_stream_item_product_code VARCHAR2(32);
lv2_inv_product_group_code VARCHAR2(32);
lv2_material_code VARCHAR2(32);

BEGIN

   -- get the product group detected from stream items
   lv2_stream_item_product_code :=  GetMaterialCodeFromSreamItem(p_object_id,p_daytime);

   IF   nvl(lv2_stream_item_product_code,'UNDEFINED') = 'UNDEFINED' THEN

          -- get the inventory product_group_code
         lv2_inv_product_group_code := ec_product_version.product_group(ec_inventory_version.product_id(p_object_id, p_daytime, '<='), p_daytime, '<=');

         IF lv2_inv_product_group_code = '120' THEN ---should be done more general but it works !!!

             lv2_material_code := 'P-Crude';

         ELSIF lv2_inv_product_group_code = '150' THEN

            lv2_material_code := 'P-NGL';

         ELSIF lv2_inv_product_group_code = '200' THEN

            lv2_material_code := 'P-Gas';

         ELSE

             lv2_material_code := NULL; --Undefined

         END IF;


   ELSE

           lv2_material_code := lv2_stream_item_product_code;

   END IF;

  RETURN lv2_material_code;

END GetInvMaterialCode;

PROCEDURE ValidateFxRates(
   p_object_id              VARCHAR2,
   p_daytime                VARCHAR2,
   p_fx_type                VARCHAR2,
   p_mode                   VARCHAR2 -- UL or OL
)
IS

lv2_local_currency_code VARCHAR2(32) := GetLocalCurrencyCode(p_object_id,p_daytime);
lv2_group_currency_code VARCHAR2(32);
lv2_from_curr_code VARCHAR2(32);
lv2_to_curr_code VARCHAR2(32);
lv2_forex_source_id VARCHAR2(32);
ln_ex_rate NUMBER;
ld_rate_day DATE := p_daytime;

missing_rate EXCEPTION;

BEGIN

    lv2_group_currency_code := ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<=');
    lv2_forex_source_id     := ec_inventory_version.forex_source_id(p_object_id, p_daytime, '<=');

    IF p_mode = 'UL' THEN

        -- 1. Check price -> booking
        lv2_from_curr_code := ec_currency.object_code(ec_inventory_version.ul_pricing_currency_id(p_object_id,p_daytime,'<='));
        lv2_to_curr_code := ec_currency.object_code(ec_inventory_version.ul_booking_currency_id(p_object_id,p_daytime,'<='));
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

        -- 2. Check price -> other
        -- lv2_from_curr_code := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'UL_PRICING_CURRENCY');
        lv2_to_curr_code := ec_currency.object_code(ec_inventory_version.ul_memo_currency_id(p_object_id,p_daytime,'<='));

        IF lv2_to_curr_code IS NOT NULL THEN

            ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

            IF ln_ex_rate IS NULL THEN

                RAISE missing_rate;

            END IF;

        END IF;

        -- 3. Check booking -> group
        lv2_from_curr_code := ec_currency.object_code(ec_inventory_version.ul_booking_currency_id(p_object_id,p_daytime,'<='));
        lv2_to_curr_code := lv2_group_currency_code;
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

        -- 4. Check booking -> local
        -- lv2_from_curr_code := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'UL_BOOKING_CURRENCY');
        lv2_to_curr_code := lv2_local_currency_code;
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

    ELSIF p_mode = 'OL' THEN

        -- 1. Check price -> booking
        lv2_from_curr_code := ec_currency.object_code(ec_inventory_version.ol_pricing_currency_id(p_object_id,p_daytime,'<='));
        lv2_to_curr_code := ec_currency.object_code(ec_inventory_version.ol_booking_currency_id(p_object_id,p_daytime,'<='));
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

        -- 2. Check price -> other
        -- lv2_from_curr_code := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'OL_PRICING_CURRENCY');
        lv2_to_curr_code := ec_currency.object_code(ec_inventory_version.ol_memo_currency_id(p_object_id,p_daytime,'<='));

        IF lv2_to_curr_code IS NOT NULL THEN

            ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

            IF ln_ex_rate IS NULL THEN

                RAISE missing_rate;

            END IF;

        END IF;

        -- 3. Check booking -> group
        lv2_from_curr_code := ec_currency.object_code(ec_inventory_version.ol_booking_currency_id(p_object_id,p_daytime,'<='));
        lv2_to_curr_code := lv2_group_currency_code;
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

        -- 4. Check booking -> local
        -- lv2_from_curr_code := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'OL_BOOKING_CURRENCY');
        lv2_to_curr_code := lv2_local_currency_code;
        ln_ex_rate := EcDp_Currency.GetExRateViaCurrency(lv2_from_curr_code,lv2_to_curr_code,NULL,ld_rate_day,lv2_forex_source_id,p_fx_type);

        IF ln_ex_rate IS NULL THEN

            RAISE missing_rate;

        END IF;

    END IF;

EXCEPTION

    WHEN missing_rate THEN

        Raise_Application_Error(-20000,'Missing ' || p_fx_type || ' exchange rate for ' || ld_rate_day ||': ' || lv2_from_curr_code || ' to ' || lv2_to_curr_code ||'.' );

END ValidateFxRates;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : IsInUnderLift
-- Description    : This function checks if the position at <daytime> is in underlift or not. If no information exists for the period <daytime>,
--                  the check will use <fallback date>
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION IsInUnderLift (
    p_object_id         VARCHAR2,
    p_daytime           DATE,
    p_fallback_date     DATE DEFAULT NULL
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_sum_layer(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    SUM(NVL(iv.ul_closing_pos_qty1, 0) + NVL(iv.ol_closing_pos_qty1, 0)) sum_closing
--    SUM(NVL(iv.ul_closing_pos_qty1, 0) + NVL(iv.ol_closing_pos_qty1, 0) + NVL(iv.ps_closing_pos_qty1, 0)) sum_closing
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
;

ln_sum NUMBER;

BEGIN

    ln_sum := 0;

    -- If sum of closing qty in layer is greater than zero then underlift
    FOR CurSum IN c_sum_layer(p_object_id, p_daytime) LOOP
        ln_sum := CurSum.Sum_Closing;
    END LOOP;

    IF (ln_sum IS NULL) THEN -- Go for the fallback date
        FOR CurSum IN c_sum_layer(p_object_id, p_fallback_date) LOOP
            ln_sum := CurSum.Sum_Closing;
        END LOOP;
    END IF;

    IF (ln_sum >= 0) THEN -- Underlift
        RETURN 'TRUE';
    ELSE -- Overlift
        RETURN 'FALSE';
    END IF;

END IsInUnderLift;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : IsInOverLift
-- Description    : This function checks if the position at <daytime> is in overlift or not. If no information exists for the period <daytime>,
--                  the check will use <fallback date>
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
FUNCTION IsInOverLift (
    p_object_id         VARCHAR2,
    p_daytime           DATE,
    p_fallback_date     DATE DEFAULT NULL
)
RETURN VARCHAR2
IS


CURSOR c_sum_layer(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    SUM(NVL(iv.ul_closing_pos_qty1, 0) + NVL(iv.ol_closing_pos_qty1, 0)) sum_closing
--    SUM(NVL(iv.ul_closing_pos_qty1, 0) + NVL(iv.ol_closing_pos_qty1, 0) + NVL(iv.ps_closing_pos_qty1, 0)) sum_closing
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
;

ln_sum NUMBER;

BEGIN

    ln_sum := 0;

    -- If sum of closing qty in layer is less than zero then overlift
    FOR CurSum IN c_sum_layer(p_object_id, p_daytime) LOOP
        ln_sum := CurSum.Sum_Closing;
    END LOOP;

    IF (ln_sum IS NULL) THEN -- Go for the fallback date
        FOR CurSum IN c_sum_layer(p_object_id, p_fallback_date) LOOP
            ln_sum := CurSum.Sum_Closing;
        END LOOP;
    END IF;

    IF (ln_sum < 0) THEN -- Overlift
        RETURN 'TRUE';
    ELSE -- Underlift
        RETURN 'FALSE';
    END IF;

END IsInOverLift;

PROCEDURE CheckProduction (
    p_object_id     VARCHAR2,
    p_daytime       DATE
)
IS

rate_set_to_zero EXCEPTION;
lv2_uom1_code VARCHAR2(32) := ec_inventory_version.uom1_code(p_object_id,p_daytime,'<=');
ln_ul_avg_rate NUMBER := ec_inv_valuation.ul_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
ln_prod_qty NUMBER := GetInvActTotProdYTD(p_object_id,p_daytime,lv2_uom1_code);
lv2_inv_dist_type inventory_version.dist_class%TYPE := ec_inventory_version.dist_class(p_object_id,p_daytime,'<=');

BEGIN

    IF (lv2_inv_dist_type = 'FIELD_GROUP') THEN

        IF ln_ul_avg_rate = 0 AND ln_prod_qty = 0 THEN

            RAISE rate_set_to_zero;

        END IF;

    END IF;

EXCEPTION

    WHEN rate_set_to_zero THEN

         Raise_Application_Error(-20000,'The underlift valuation rate has been set to zero because one or more YTD dist production volumes are null or zero.  Please check the production data, or overwrite the underlift rate in the Rate Calculation panel.');

END CheckProduction;

-- function which returns December 1st of previous processed year
FUNCTION GetEndPriorYear(
    p_object_id VARCHAR2,
    p_daytime DATE)
RETURN DATE
IS

ld_prior_year DATE;

BEGIN
     BEGIN

        SELECT MAX(daytime)
        INTO ld_prior_year
        FROM inv_valuation
        WHERE object_id = p_object_id
        AND TO_NUMBER(TO_CHAR(daytime, 'YYYY')) < TO_NUMBER(TO_CHAR(TRUNC(p_daytime, 'YYYY'), 'YYYY'));

     EXCEPTION

        WHEN NO_DATA_FOUND THEN

            ld_prior_year := NULL;

     END;

     RETURN ld_prior_year;

END GetEndPriorYear;


FUNCTION GetNewDistRelStatus (
    p_object_id VARCHAR2, -- Inventory_ID
    p_daytime DATE
) RETURN VARCHAR2
IS

CURSOR c_fg_fields(pc_field_group_id VARCHAR2) IS
SELECT fgs.object_id field_id
FROM field_group_setup fgs
WHERE fgs.field_group_id = pc_field_group_id
AND daytime <= p_daytime
AND NOT EXISTS (
      SELECT 'x' FROM
      inventory_field inf WHERE inf.field_id = fgs.object_id
      AND inf.inventory_id = p_object_id
      AND inf.start_date <= p_daytime
      AND Nvl(inf.end_date,p_daytime+1) > p_daytime
    );

CURSOR c_inv_fields_remove(pc_field_group_id VARCHAR2) IS
SELECT inf.field_id field_id, inf.object_id object_id, ifv.approval_state
FROM inventory_field inf, inventory_field_version ifv
WHERE inf.object_id = ifv.object_id
AND inf.inventory_id = p_object_id
AND ifv.daytime = (SELECT MAX(daytime) FROM inventory_field_version WHERE object_id = inf.object_id AND daytime <= p_daytime)
AND inf.start_date <= p_daytime
AND Nvl(inf.end_date,p_daytime+1) > p_daytime
AND NOT EXISTS (
        SELECT 'x'
        FROM field_group_setup fgs
        WHERE fgs.field_group_id = pc_field_group_id
        AND fgs.object_id = inf.field_id
        AND fgs.daytime <= p_daytime
        );

lv2_ret_text VARCHAR2(100) := '(No update required)';
lv2_valuation_level VARCHAR2(32) := ec_inventory_version.valuation_level(p_object_id, p_daytime, '<=');
lv2_field_group_id VARCHAR2(32) := ec_field_group.object_id_by_uk(ec_inventory_version.dist_code(p_object_id, p_daytime, '<='));
ln_count_new NUMBER := 0;
ln_count_rem NUMBER := 0;
ln_count_app NUMBER := 0;

BEGIN
    -- If other than Pool based distribution, N is returned
    IF upper(lv2_valuation_level) <> 'POOL' THEN
       RETURN lv2_ret_text;
    END IF;

    -- Check if any new relations should be inserted
    FOR FGFields IN c_fg_fields(lv2_field_group_id) LOOP
        ln_count_new := ln_count_new + 1;

        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('INVENTORY_FIELD'),'N') = 'Y' THEN
           ln_count_app := ln_count_app + 1;
        END IF;

    END LOOP;

    -- Chek if any outdated relations exists
    FOR RemFields IN c_inv_fields_remove(lv2_field_group_id) LOOP
        ln_count_rem := ln_count_rem + 1;

        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('INVENTORY_FIELD'),'N') = 'Y' AND RemFields.approval_state = 'D' THEN
           ln_count_app := ln_count_app + 1;
        END IF;

    END LOOP;

    IF ln_count_new > 0 OR ln_count_rem > 0 THEN
        lv2_ret_text := 'Field distribution has changed: ';
        lv2_ret_text := lv2_ret_text || to_char(ln_count_new) || ' new, ';
        lv2_ret_text := lv2_ret_text || to_char(ln_count_rem) || ' removed. ';

        IF ln_count_app > 0 THEN
           lv2_ret_text := lv2_ret_text || to_char(ln_count_app) || ' requires approval!';
        END IF;
    END IF;

    RETURN lv2_ret_text;

END GetNewDistRelStatus;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : ProcessInventory
-- Description    :
-- Preconditions  :
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
-----------------------------------------------------------------------------------------------------
PROCEDURE CheckDistRelations (
    p_object_id VARCHAR2, -- Inventory_ID
    p_daytime DATE,
    p_user VARCHAR2
)
--</EC-DOC>
IS

CURSOR c_fg_fields(pc_field_group_id VARCHAR2) IS
SELECT fgs.object_id field_id
FROM field_group_setup fgs
WHERE fgs.field_group_id = pc_field_group_id
AND daytime <= p_daytime
AND NOT EXISTS (
      SELECT 'x' FROM
      inventory_field inf WHERE inf.field_id = fgs.object_id
      AND inf.inventory_id = p_object_id
      AND inf.start_date <= p_daytime
      AND Nvl(inf.end_date,p_daytime+1) > p_daytime
    );

CURSOR c_inv_fields_remove(pc_field_group_id VARCHAR2) IS
SELECT inf.field_id field_id, inf.object_id object_id, ifv.approval_state, ifv.rec_id
FROM inventory_field inf, inventory_field_version ifv
WHERE inf.object_id = ifv.object_id
AND inf.inventory_id = p_object_id
AND ifv.daytime = (SELECT MAX(daytime) FROM inventory_field_version WHERE object_id = inf.object_id AND daytime <= p_daytime)
AND inf.start_date <= p_daytime
AND Nvl(inf.end_date,p_daytime+1) > p_daytime
AND NOT EXISTS (
        SELECT 'x'
        FROM field_group_setup fgs
        WHERE fgs.field_group_id = pc_field_group_id
        AND fgs.object_id = inf.field_id
        AND fgs.daytime <= p_daytime
        );

lv2_valuation_level VARCHAR2(32) := ec_inventory_version.valuation_level(p_object_id, p_daytime, '<=');
lv2_field_group_code VARCHAR2(32) := ec_inventory_version.dist_code(p_object_id, p_daytime, '<=');
lv2_field_group_id VARCHAR2(32);


lv2_new_rel VARCHAR2(32);
lv2_rel_code VARCHAR2(32);
ld_start_date DATE;
ld_end_date DATE;
ld_field_start_date DATE;
ld_field_end_date DATE;
lv2_4e_recid VARCHAR2(32);

not_valid_valuation_level EXCEPTION;

BEGIN

    IF upper(lv2_valuation_level) <> 'POOL' THEN

        RETURN;

    END IF;

    lv2_field_group_id := ec_field_group.object_id_by_uk(lv2_field_group_code);
    ld_start_date := ec_inventory.start_date(p_object_id);
    ld_end_date := ec_inventory.end_date(p_object_id);

    -- insert any new relations
    FOR FGFields IN c_fg_fields(lv2_field_group_id) LOOP

        ld_field_start_date := ec_field.start_date(FGFields.field_id);
        ld_start_date := GREATEST(ld_field_start_date,ld_start_date); -- to avoid trying to create relation before new field is valid.

        ld_field_end_date := ec_field.end_date(FGFields.field_id);

        IF ld_end_date IS NOT NULL AND ld_field_end_date IS NULL THEN

            NULL; -- just use ld_end_date as is

        ELSIF ld_end_date IS NULL AND ld_field_end_date IS NOT NULL THEN

            ld_end_date := ld_field_end_date;

        ELSE

            ld_end_date := LEAST(ld_field_end_date,ld_end_date); -- to avoid trying to create relation when new field is not valid anymore.

        END IF;

        Ecdp_System_Key.assignNextNumber('INVENTORY_FIELD', lv2_rel_code);
        lv2_rel_code := 'IF' || lv2_rel_code;
        INSERT INTO inventory_field (object_code, start_date, end_date, inventory_id, field_id, last_updated_by)
        VALUES (lv2_rel_code, ld_start_date, ld_end_date, p_object_id, FGFields.field_id, p_user) RETURNING object_id INTO lv2_new_rel;

        INSERT INTO inventory_field_version (object_id, daytime, end_date, last_updated_by)
        VALUES (lv2_new_rel, ld_start_date, ld_end_date, p_user);

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('INVENTORY_FIELD'),'N') = 'Y' THEN

          -- TODO: Set approval info on versions prior to the latest, that is set to 'N' below

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on record
          UPDATE inventory_field_version
              SET last_updated_by = p_user,
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              approval_state = 'N',
              rec_id = lv2_4e_recid,
              rev_no = (nvl(rev_no,0) + 1)
          WHERE object_id = lv2_new_rel
          AND daytime = (SELECT MAX(daytime) FROM inventory_field_version WHERE object_id = lv2_new_rel);

          -- Register record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'INVENTORY_FIELD',
                                            p_user);

        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- remove any outdated relations
    FOR RemFields IN c_inv_fields_remove(lv2_field_group_id) LOOP

        -- ** 4-eyes approval logic - Controlling DELETE ** --
      IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('INVENTORY_FIELD'),'N') = 'Y' THEN

          -- Updated or Official - Delete must be approved
          IF RemFields.approval_state IN ('U','O') THEN

             -- Set approval info on record
             UPDATE inventory_field_version
                SET last_updated_by = p_user,
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'D',
                    approval_by = null,
                    approval_date = null,
                    rev_no = (nvl(rev_no,0) + 1)
              WHERE rec_id = RemFields.Rec_Id;

             -- Prepare record for approval
             Ecdp_Approval.registerTaskDetail(RemFields.Rec_Id,
                                              'INVENTORY_FIELD',
                                              p_user);

          ELSE
             -- Updating ACL for if ringfencing is enabled
             IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('INVENTORY_FIELD'),'N') = 'Y') THEN
                EcDp_Acl.RefreshObject(RemFields.object_id, 'INVENTORY_FIELD', 'DELETING');
             END IF;

             -- Delete all objects
             DELETE FROM inventory_field_version ifv WHERE
             ifv.object_id = RemFields.object_id;

             DELETE FROM inventory_field inf WHERE
             inf.object_id = RemFields.object_id;

          END IF;

          -- ** END 4-eyes approval ** --

      ELSE

         -- Updating ACL for if ringfencing is enabled
         IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('INVENTORY_FIELD'),'N') = 'Y') THEN
            EcDp_Acl.RefreshObject(RemFields.object_id, 'INVENTORY_FIELD', 'DELETING');
         END IF;

         -- Delete all objects
         DELETE FROM inventory_field_version ifv WHERE
         ifv.object_id = RemFields.object_id;

         DELETE FROM inventory_field inf WHERE
         inf.object_id = RemFields.object_id;

      END IF;

    END LOOP;
EXCEPTION
   WHEN  not_valid_valuation_level THEN

              Raise_Application_Error(-20000,'Pool valuation level not valid' );

END CheckDistRelations;

FUNCTION GetCostElementBW(
   p_object_id VARCHAR2,
   p_dist_obj_id VARCHAR2,
   p_daytime DATE
)
RETURN VARCHAR2
IS

   lv2_account_no VARCHAR2(200) := NULL;

   lr_inv_dist_valuation inv_dist_valuation%rowtype;

BEGIN

   lr_inv_dist_valuation := Ec_Inv_Dist_Valuation.row_by_pk(p_object_id, p_dist_obj_id, p_daytime, to_char(p_daytime, 'YYYY'));

   IF (NVL(lr_inv_dist_valuation.ol_booking_value,0) <> 0) THEN
      lv2_account_no := lr_inv_dist_valuation.fin_debit_account_id;
   ELSIF (NVL(lr_inv_dist_valuation.ul_booking_value,0) <> 0) THEN
      lv2_account_no := lr_inv_dist_valuation.fin_credit_account_id;
   END IF;

   RETURN lv2_account_no;

END GetCostElementBW;

FUNCTION GetMarginOrderBW(
   p_object_id VARCHAR2,
   p_dist_obj_id VARCHAR2,
   p_daytime DATE
)
RETURN VARCHAR2
IS

   lv2_cost_object VARCHAR2(200) := NULL;
   lr_inv_dist_valuation inv_dist_valuation%rowtype;

BEGIN

   lr_inv_dist_valuation := Ec_Inv_Dist_Valuation.row_by_pk(p_object_id, p_dist_obj_id, p_daytime, to_char(p_daytime, 'YYYY'));

   IF (NVL(lr_inv_dist_valuation.ol_booking_value,0) <> 0) THEN
      lv2_cost_object := lr_inv_dist_valuation.fin_debit_cost_object;
   ELSIF (NVL(lr_inv_dist_valuation.ul_booking_value,0) <> 0) THEN
      lv2_cost_object := lr_inv_dist_valuation.fin_credit_cost_object;
   END IF;

   RETURN lv2_cost_object;

END GetMarginOrderBW;

FUNCTION GetProductCodeBW(
   p_fin_material_code VARCHAR2,
   p_daytime DATE
)
RETURN VARCHAR2
IS

   lv2_product_code VARCHAR2(200) := NULL;

CURSOR c_prod IS
SELECT p.object_code
FROM product p, product_version pv
WHERE p.object_id = pv.object_id
AND p.start_date <= p_daytime
AND NVL(p.end_date,p_daytime+1) > p_daytime
AND pv.daytime <= p_daytime
AND pv.erp_code = p_fin_material_code
;

BEGIN

   FOR cprod IN c_prod LOOP
      lv2_product_code := cprod.object_code;
   END LOOP;

   RETURN lv2_product_code;

END GetProductCodeBW;

FUNCTION GetStimPriorPeriodAdjustment (
    p_object_id VARCHAR2,
    p_daytime DATE  -- the daytime to calculate the ppa for
  	)
RETURN EcDp_Unit.t_uomtable
IS

CURSOR  c_stim IS
SELECT  object_id
        ,daytime
        ,net_energy_jo
        ,net_energy_th
        ,net_energy_wh
        ,net_energy_be
        ,net_mass_ma
        ,net_mass_mv
        ,net_mass_ua
        ,net_mass_uv
        ,net_volume_sf
        ,net_volume_nm
        ,net_volume_sm
        ,net_volume_bi
        ,net_volume_bm
        ,rev_no
        ,production_period
FROM    stim_mth_booked
WHERE   object_id = p_object_id
AND     TRUNC(daytime, 'YYYY') = TRUNC(p_daytime, 'YYYY')
AND     production_period < trunc(p_daytime,'YYYY');

ltab_ppa EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
lb_calc_ppa BOOLEAN := FALSE;
ld_curr_daytime DATE;

BEGIN

    -- First 'instantiate' the uom set which is to be returned.
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := '100MJ';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'THERMS';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'KWH';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'BOE';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'MT';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'MTV';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'UST';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'USTV';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'MSCF';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'MNM3';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'MSM3';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'BBLS';
    ltab_ppa.extend;
    ltab_ppa(ltab_ppa.last).qty := 0;
    ltab_ppa(ltab_ppa.last).uom := 'BBLS15';

    -- Now loop through all records of this stream item to find any adjustments
    FOR SI IN c_stim LOOP

            ltab_ppa(1).qty  := ltab_ppa(1).qty  + Nvl(SI.net_energy_jo,0);
            ltab_ppa(2).qty  := ltab_ppa(2).qty  + Nvl(SI.net_energy_th,0);
            ltab_ppa(3).qty  := ltab_ppa(3).qty  + Nvl(SI.net_energy_wh,0);
            ltab_ppa(4).qty :=  ltab_ppa(4).qty + Nvl(SI.net_energy_be,0);
            ltab_ppa(5).qty  := ltab_ppa(5).qty  + Nvl(SI.net_mass_ma,0);
            ltab_ppa(6).qty  := ltab_ppa(6).qty  + Nvl(SI.net_mass_mv,0);
            ltab_ppa(7).qty  := ltab_ppa(7).qty  + Nvl(SI.net_mass_ua,0);
            ltab_ppa(8).qty  := ltab_ppa(8).qty  + Nvl(SI.net_mass_uv,0);
            ltab_ppa(9).qty  := ltab_ppa(9).qty  + Nvl(SI.net_volume_sf,0);
            ltab_ppa(10).qty  := ltab_ppa(10).qty  + Nvl(SI.net_volume_nm,0);
            ltab_ppa(11).qty := ltab_ppa(11).qty + Nvl(SI.net_volume_sm,0);
            ltab_ppa(12).qty := ltab_ppa(12).qty + Nvl(SI.net_volume_bi,0);
            ltab_ppa(13).qty := ltab_ppa(13).qty + Nvl(SI.net_volume_bm,0);

    END LOOP;

    RETURN ltab_ppa;

END GetStimPriorPeriodAdjustment;

-- temp function for testing only, to be deleted

FUNCTION GetSIPYAByUOM (
    p_object_id VARCHAR2,
    p_daytime DATE,
    p_uom VARCHAR2
    )
RETURN NUMBER
IS

ltab_result ecdp_unit.t_uomtable;
ln_result NUMBER;

BEGIN

    ltab_result := getstimpriorperiodadjustment(p_object_id,p_daytime);
    ln_result := EcDp_Revn_Unit.GetUOMSetQty(ltab_result,p_uom,p_daytime, p_object_id);

    RETURN ln_result;

END GetSIPYAByUOM;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : ValidateCurrencies
-- Description    : It is required that the currencies for underlift and overlift quantities are the same when physical stock are considered
--                  during the Inventory Valuation.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : The procedure prevent the user from creating a new Inventory object with differences on currencies between overlift/underlift
--                  if physical stock are considered during the Inventory valuation.
--                  Referred to from class INVENTORY
-----------------------------------------------------------------------------------------------------
PROCEDURE ValidateInventoryObj(p_ul_pricing_currency_code VARCHAR2,
                               p_ul_booking_currency_code VARCHAR2,
                               p_ul_memo_currency_code    VARCHAR2,
                               p_ol_pricing_currency_code VARCHAR2,
                               p_ol_booking_currency_code VARCHAR2,
                               p_ol_memo_currency_code    VARCHAR2,
                               p_ps_account_mapping       VARCHAR2,
                               p_ps_ind                   VARCHAR2,
                               p_daytime                  DATE)
--<EC-DOC>
IS

-- Physical Stock flag
ps_ind                       VARCHAR2(32);
currencies_mismatch          EXCEPTION;
missing_ps_acc_mapping       EXCEPTION;

lv2_message                  VARCHAR2(2000);
lv2_message2                  VARCHAR2(2000);

BEGIN

ps_ind := nvl(p_ps_ind,'N');
lv2_message := 'Currencies for Underlift and Overlift quantities does not match. This is required when Physical Stock valuation is in use.';
lv2_message2 := 'Physical Stock Account Mapping is required on an Inventory object with Physical Stock enabled.';

IF ps_ind = 'N' THEN
   RETURN;
END IF;

IF (p_ul_pricing_currency_code <> p_ol_pricing_currency_code) OR
   (p_ul_booking_currency_code <> p_ol_booking_currency_code) OR
   (nvl(p_ul_memo_currency_code,'XXX') <> nvl(p_ol_memo_currency_code,'XXX')) THEN

   Raise currencies_mismatch;
END IF;

IF (p_ps_account_mapping IS NULL) THEN
   raise missing_ps_acc_mapping;
END IF;

EXCEPTION
  WHEN currencies_mismatch THEN
    Raise_Application_Error(-20000,lv2_message);
  WHEN missing_ps_acc_mapping THEN
       Raise_Application_Error(-20000,lv2_message2);

END ValidateInventoryObj;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : ValidateInventory
-- Description    : Supports validation on inventory valuation upon setting it to VALID1.
-- Preconditions  : Inventory valuation must be at level OPEN.
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
-----------------------------------------------------------------------------------------------------
PROCEDURE ValidateInventory(p_object_id VARCHAR2,
                            p_daytime DATE)
IS

  lrec_inv_valuation inv_valuation%ROWTYPE;
  lv2_rate_name VARCHAR2(32);

  missing_rate EXCEPTION;
  missing_book_category EXCEPTION;

BEGIN

  IF ue_inventory.isValidateInventoryUEE = 'TRUE' THEN

    ue_inventory.ValidateInventory(p_object_id, p_daytime);

  ELSE

    IF ue_inventory.isValidateInventoryPreUEE = 'TRUE' THEN
      ue_inventory.ValidateInventoryPre(p_object_id, p_daytime);
    END IF;

    lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, to_char(p_daytime, 'YYYY'));

    IF IsInUnderLift(p_object_id,p_daytime) = 'TRUE' THEN

        IF lrec_inv_valuation.ul_avg_rate IS NULL THEN

            lv2_rate_name := 'Underlift avg. rate';

            RAISE missing_rate;

        END IF;

    ELSIF IsInOverLift(p_object_id,p_daytime) = 'TRUE' THEN

        IF lrec_inv_valuation.ol_avg_rate IS NULL THEN

            lv2_rate_name := 'Overlift avg. price';

            RAISE missing_rate;

        END IF;

    END IF;

    -- check that book category is not null
    IF lrec_inv_valuation.book_category IS NULL THEN

        RAISE missing_book_category;

    END IF;

    IF ue_inventory.isValidateInventoryPostUEE = 'TRUE' THEN
      ue_inventory.ValidateInventoryPost(p_object_id, p_daytime);
    END IF;

  END IF; -- "Instead of" User Exit

EXCEPTION
     WHEN missing_rate THEN

              Raise_Application_Error(-20000, 'Missing ' || lv2_rate_name || ' for ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') || ' for ' || p_daytime ||'.');

     WHEN missing_book_category THEN

              Raise_Application_Error(-20000, 'Missing book category for ' || ec_inventory_version.name(p_object_id,p_daytime,'<=') || ' for ' || p_daytime ||'.');
END ValidateInventory;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : DeleteInventory
-- Description    : If the inventory object is being deleted, this procedure makes sure all child objects and references are deleted
--                  as well in order for the object deletion to be successful.
-- Preconditions  : The inventory object cannot be processed
-- Postconditions : DAO is handling the deletion of the actual object
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
PROCEDURE DeleteInventory(p_object_id      VARCHAR2,
                          p_old_start_date DATE,
                          p_new_start_date DATE,
                          p_old_end_date   DATE,
                          p_new_end_date   DATE)
--<EC-DOC>
IS

CURSOR c_processed IS
SELECT DISTINCT iv.object_id
  FROM INV_VALUATION iv
 WHERE object_id = p_object_id;

CURSOR c_inv_field IS
SELECT object_id FROM inventory_field WHERE inventory_id = p_object_id;

CURSOR c_inv_po IS
SELECT object_id FROM product_price WHERE inventory_id = p_object_id;


BEGIN


-- If Inventory has been processed, we delete nothing.
FOR c_p IN c_processed LOOP
    RETURN;
END LOOP;

-- Make sure conditions for deletion are ok
IF p_new_start_date IS NULL THEN
   RETURN;
END IF;

-- Object is being deleted - Deleting all child objects and references
IF nvl(p_new_end_date,p_new_start_date+1) = p_new_start_date THEN

   -- Deleting Stream Item setup
   DELETE FROM inventory_stim_setup WHERE object_id = p_object_id;


   -- Deleting connection between Inventory, Field and the different Price Objects
   FOR c_inv_f IN c_inv_field LOOP
       DELETE FROM inventory_field_version WHERE object_id = c_inv_f.object_id;
       DELETE FROM inventory_field WHERE object_id = c_inv_f.object_id;
   END LOOP;


   -- Handling Prices and Price Objects
   FOR c_i_po IN c_inv_po LOOP

       -- Deleting the actual price values
       DELETE FROM product_price_value ppr
        WHERE ppr.object_id = c_i_po.object_id;

       -- Deleting Price Object Versions
       DELETE FROM product_price_version ppv
        WHERE ppv.object_id = c_i_po.object_id;

        -- Deleting Price Object
       DELETE FROM product_price pp WHERE pp.object_id = c_i_po.object_id;
    END LOOP;


END IF;


END DeleteInventory;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : WriteAvgRate
-- Description    : The procedure is used by the user to write the underlift or overlift average rate based on current position.
--                : The user will write to only one attribute in the business function Inventory - Process - Rate Calculation
--                 and this procedure need to evaluate which column to write the value to.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
PROCEDURE WriteAvgRate(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_rate      NUMBER,
                       p_user      VARCHAR2)
--</EC-DOC>
IS

lv2_underlift VARCHAR2(32) := IsInUnderLift(p_object_id,p_daytime);

BEGIN

    IF lv2_underlift = 'TRUE' THEN -- Underlift

        IF (p_rate IS NOT NULL) THEN
            UPDATE inv_valuation i
            SET    i.ul_avg_rate = p_rate
            WHERE  i.object_id = p_object_id
            AND    i.daytime = p_daytime
            AND    i.year_code = to_char(p_daytime, 'YYYY');
        ELSIF (p_rate IS NULL) THEN -- Recalculate AVG rate if rate is set to NULL
            CalcAvgULRate(p_object_id, p_daytime, 'FALSE', 'TRUE');
        END IF;

    ELSE -- Overlift

        IF (p_rate IS NOT NULL) THEN
            UPDATE inv_valuation i
            SET    i.ol_avg_rate = p_rate
            WHERE  i.object_id = p_object_id
            AND    i.daytime = p_daytime
            AND    i.year_code = to_char(p_daytime, 'YYYY');
        ELSIF (p_rate IS NULL) THEN -- Recalculate AVG rate if rate is set to NULL
            CalcAvgULRate(p_object_id, p_daytime, 'FALSE', 'TRUE');
        END IF;

    END IF;



END WriteAvgRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetPositionAvgRate
-- Description    : Returns Underlift Average Rate if inventory in underlift and Overlift Average Rate otherwise
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetPositionAvgRate(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

lv2_underlift VARCHAR2(32) := IsInUnderLift(p_object_id,p_daytime);

BEGIN

IF lv2_underlift = 'TRUE' THEN
   RETURN ec_inv_valuation.ul_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));

ELSE
     RETURN ec_inv_valuation.ol_avg_rate(p_object_id,p_daytime, to_char(p_daytime, 'YYYY'));
END IF;


END GetPositionAvgRate;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ConfigureReport
-- Description    : Used by the EC Revenue Inventory reporting. When Running the report from the business function 'Inventory Process General'
--                  This procedure will create a runable report if missing. Else it will update the report parameters based on
--                  existing runable_no and data retrieved from the report selector in the screen.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report_runable, report_runable_param
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If missing, creates a new record in report_runable and one record for each argument on this report in report_runable_param.
--                  If not missing, updates existing parameters with new values.
-------------------------------------------------------------------------------------------------
PROCEDURE ConfigureReport(p_object_id            VARCHAR2,
                          p_daytime              VARCHAR2,
                          p_report_definition_no NUMBER)
--</EC-DOC>
IS

CURSOR c_report_runable(cp_rep_group_code VARCHAR2, cp_name VARCHAR2) IS
    select report_runable_no
      from report_runable
     where rep_group_code = cp_rep_group_code
       and name = cp_name
     order by report_runable_no desc;

CURSOR c_report_runable_param(cp_report_runable_no NUMBER, cp_parameter_name VARCHAR2, cp_parameter_date DATE) IS
    select count(*) param_count
      from report_runable_param
     where report_runable_no = cp_report_runable_no
       and parameter_name = cp_parameter_name
       and daytime = cp_parameter_date;

lv2_rep_group_code       VARCHAR2(32);
lv2_rep_name             VARCHAR2(240);
ln_report_runable_no     NUMBER := 0;
ld_report_daytime        DATE := Ecdp_Timestamp.getCurrentSysdate;
ld_parameter_daytime     DATE;
ln_param_count_1         NUMBER;
ln_param_count_2         NUMBER;

BEGIN
lv2_rep_group_code := ec_report_definition.rep_group_code(p_report_definition_no);
ld_parameter_daytime := ec_report_definition.daytime(p_report_definition_no);
lv2_rep_name := ec_report_definition_group.name(lv2_rep_group_code);

--Look for existing report_runable_no.
for Runable in c_report_runable(lv2_rep_group_code, lv2_rep_name) loop
    ln_report_runable_no := Runable.report_runable_no;
    exit;
end loop;


--Create report_runable if missing.
if ln_report_runable_no = 0 then
    Ecdp_System_Key.assignNextNumber('REPORT_RUNABLE', ln_report_runable_no);

    INSERT INTO tv_report_runable
      (report_runable_no, rep_group_code, name)
    VALUES
      (ln_report_runable_no,
       lv2_rep_group_code,
       lv2_rep_name);
end if;

--Look for existing partameter 1.
for Param in c_report_runable_param(ln_report_runable_no, 'PARAMETER_1', ld_parameter_daytime) loop
    ln_param_count_1 := Param.param_count;
    exit;
end loop;
--Look for existing partameter 2.
for Param in c_report_runable_param(ln_report_runable_no, 'PARAMETER_2', ld_parameter_daytime) loop
    ln_param_count_2 := Param.param_count;
    exit;
end loop;

--Create "PARAMETER_1" if missing. Use contract ID as parameter value.
--Else update the parameter value.
if ln_param_count_1 = 0 then
    INSERT INTO report_runable_param
      (parameter_value,
       parameter_name,
       parameter_type,
       parameter_sub_type,
       report_runable_no,
       daytime)
    VALUES
      (p_object_id,
       'PARAMETER_1',
       'EC_OBJECT_TYPE',
       'INVENTORY',
       ln_report_runable_no,
       ld_parameter_daytime);
else
    UPDATE report_runable_param
       SET parameter_type = 'EC_OBJECT_TYPE',
           parameter_sub_type = 'INVENTORY',
           parameter_value = p_object_id
     WHERE report_runable_no = ln_report_runable_no
       AND daytime = ld_parameter_daytime
       AND parameter_name = 'PARAMETER_1';
end if;

--Create "PARAMETER_2" if missing. Use processing month as parameter value.
--Else update the parameter value.
if ln_param_count_2 = 0 then
    INSERT INTO report_runable_param
      (parameter_value,
       parameter_name,
       parameter_type,
       parameter_sub_type,
       report_runable_no,
       daytime)
    VALUES
      (p_daytime,
       'PARAMETER_2',
       'BASIC_TYPE',
       'STRING',
       ln_report_runable_no,
       ld_parameter_daytime);
else
    UPDATE report_runable_param
       SET parameter_type = 'BASIC_TYPE',
           parameter_sub_type = 'STRING',
           parameter_value = p_daytime
     WHERE report_runable_no = ln_report_runable_no
       AND daytime = ld_parameter_daytime
       AND parameter_name = 'PARAMETER_2';
end if;
END ConfigureReport;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ValidateReportBeforeGenerate
-- Description    : Used by the EC Revenue Inventory reporting. When generating a new report,
--                  this procedure will check if:
--                    1. A report is specified.
--                    2. The specified inventory is processed for current month.
--                  Will return application error messages if the checks does not pass.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : inv_valuation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateReportBeforeGenerate(p_inventory_id         VARCHAR2,
                                       p_daytime              VARCHAR2,
                                       p_report_definition_no VARCHAR2)
--</EC-DOC>
IS
    CURSOR c_inv_valuation (cp_inventory_id VARCHAR2, cp_daytime DATE) IS
    SELECT count(object_id) rec_count
      FROM inv_valuation
     WHERE object_id = cp_inventory_id
       AND daytime = cp_daytime;

    ld_daytime                DATE;
    ln_rec_count              NUMBER := 0;
    ex_no_report_specified    EXCEPTION;
    ex_no_processed_inventory EXCEPTION;
BEGIN
    ld_daytime := to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

    --A selected report is mandatory.
    IF nvl(p_report_definition_no,'NULL') = 'NULL' THEN
        RAISE ex_no_report_specified;
    END IF;

    --A processed inventory for current month is mandatory.
    FOR cur IN c_inv_valuation(p_inventory_id, ld_daytime) LOOP
        ln_rec_count := cur.rec_count;
    END LOOP;
    IF ln_rec_count = 0 THEN
        RAISE ex_no_processed_inventory;
    END IF;

EXCEPTION
    WHEN ex_no_report_specified THEN
        Raise_Application_Error(-20000,'Error!\n' ||
            'It is not possible to generate the report, ' ||
            'because no report is selected.\n\n' ||
            'Technical:\n');
    WHEN ex_no_processed_inventory THEN
        Raise_Application_Error(-20000,'Error!\n' ||
            'It is not possible to generate the report, ' ||
            'because the ''' || ec_inventory.object_code(p_inventory_id) || ''' inventory is not processed for current month.\n' ||
            'This can be done by the ''Process Inventory'' button in the ''Overview'' tab.\n\n' ||
            'Technical:\n');
    WHEN OTHERS THEN
        Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END ValidateReportBeforeGenerate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      : IsAttributeEditable
-- Description    : Used in static presentation for class INVENTORY.
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
-- Behaviour      : Return 'true' if the attribute is editable, 'false' if not.
--
-------------------------------------------------------------------------------------------------
FUNCTION IsAttributeEditable(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_attribute_name VARCHAR2
  ) RETURN VARCHAR2
--</EC-DOC>
is

lv_editable VARCHAR2(10) default 'true';
BEGIN
  IF (p_attribute_name in ('UL_INTERIM_LI_CODE','OL_INTERIM_LI_CODE')) THEN
     IF ec_inventory_version.valuation_method(p_object_id , p_daytime, '<=') = 'LIFO_INTERIM' THEN
       lv_editable := 'true';
     ELSE
       lv_editable := 'false';
     END IF;
  END IF;

  RETURN lv_editable;
END IsAttributeEditable;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : SetStimMthInvHistoric
-- Description    : Calculate the field split for Layer and stor it against the last layer.
--                  Use existing field split. If no field split exists, use prorate.
-- Preconditions  : Layer must be saved in the database
--
-- Postconditions : Field split is saved in the database
--
-- Using tables   : INV_LAYER, INVENTORY_FIELD, INVENTORY_STIM_SETUP, STREAM_ITEM_VERSION, STIM_MTH_INV_HISTORIC
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Called from triggers IUD_INV_LAYER_UL and IUD_INV_LAYER_OL
--
-------------------------------------------------------------------------------------------------
PROCEDURE SetStimMthInvHistoric
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2)  -- User ID that is updating the values
--</EC-DOC>
IS


TYPE t_field_split IS table of INV_DIST_VALUATION%ROWTYPE INDEX BY BINARY_INTEGER;
ltab_field_split t_field_split;
ltab_field_sum   t_field_split;

ln_total_field_qty1    NUMBER default 0;
ln_total_field_qty2    NUMBER default 0;
ln_total_field_ps_qty1 NUMBER default 0;
ln_total_field_ps_qty2 NUMBER default 0;
ln_total_field_ol_qty1 NUMBER default 0;
ln_total_field_ol_qty2 NUMBER default 0;
ln_max_field_qty1      NUMBER default -9999999999999999;
ln_max_field_qty2      NUMBER default -9999999999999999;
ln_max_field_ol_qty1   NUMBER default -9999999999999999;
ln_max_field_ol_qty2   NUMBER default -9999999999999999;
ln_max_field_ps_qty1   NUMBER default -9999999999999999;
ln_max_field_ps_qty2   NUMBER default -9999999999999999;
ln_sum_field_qty1      NUMBER default 0;
ln_sum_field_qty2      NUMBER default 0;
ln_sum_field_ol_qty1   NUMBER default 0;
ln_sum_field_ol_qty2   NUMBER default 0;
ln_sum_field_ps_qty1   NUMBER default 0;
ln_sum_field_ps_qty2   NUMBER default 0;

ln_total_qty1          NUMBER default 0;
ln_total_qty2          NUMBER default 0;
ln_total_ol_qty1       NUMBER default 0;
ln_total_ol_qty2       NUMBER default 0;
ln_total_ps_qty1       NUMBER default 0;
ln_total_ps_qty2       NUMBER default 0;
li_count               integer default 0;
li_index_max_qty1      integer default 0;
li_index_max_qty2      integer default 0;
li_index_max_ol_qty1   integer default 0;
li_index_max_ol_qty2   integer default 0;
li_index_max_ps_qty1   integer default 0;
li_index_max_ps_qty2   integer default 0;
li_round               integer default 6;

lv2_uom1_code VARCHAR2(32);
lv2_uom2_code VARCHAR2(32);

-- Find existing field split
CURSOR c_existing_field_split (p_inventory_id VARCHAR2, p_daytime date) IS
SELECT idv.object_id
       ,idv.dist_id
       ,idv.closing_ul_position_qty1
       ,idv.closing_ul_position_qty2
       ,idv.closing_ol_position_qty1
       ,idv.closing_ol_position_qty2
       ,idv.closing_ps_position_qty1
       ,idv.closing_ps_position_qty2
  FROM inv_dist_valuation idv
 WHERE idv.object_id = p_inventory_id
   AND idv.daytime = p_daytime
   AND idv.year_code = to_char(p_daytime, 'YYYY');

-- Find any missing fields
CURSOR c_missing_field_split (p_inventory_id VARCHAR2, p_daytime DATE) IS
 SELECT DISTINCT iss.object_id AS inventory_id,
                 inf.field_id  AS field_id
   FROM inventory_stim_setup iss,
        inventory_field inf,
        stream_item_version siv
  WHERE inf.inventory_id = p_inventory_id
    AND iss.object_id = inf.inventory_id
    AND siv.field_id = inf.field_id
    and siv.object_id = iss.stream_item_id
    AND siv.daytime = (SELECT MAX(daytime)
                         FROM stream_item_version sive
                        WHERE sive.object_id = siv.object_id
                          AND sive.field_id = inf.field_id
                          AND sive.daytime <= p_daytime)
    AND iss.inv_stream_item_type IN ('INV','OWN')
    AND iss.daytime = (SELECT MAX(daytime)
                         FROM inventory_stim_setup issp
                        WHERE issp.object_id = inf.inventory_id
                          AND iss.stream_item_id = issp.stream_item_id
                          AND issp.daytime <= p_daytime)
   AND NOT EXISTS (SELECT 'x'
          FROM inv_dist_valuation h
         WHERE h.object_id = iss.object_id
           AND h.dist_id = inf.field_id
           AND h.daytime = p_daytime
           AND h.year_code = TO_CHAR(p_daytime, 'YYYY'));

BEGIN
  -- Get total layer quantities
  SELECT sum(l.ul_closing_pos_qty1),
         sum(l.ul_closing_pos_qty2),
         sum(l.ol_closing_pos_qty1),
         sum(l.ol_closing_pos_qty2),
         sum(l.ps_closing_pos_qty1),
         sum(l.ps_closing_pos_qty2)
--  SELECT sum(l.opening_qty1), sum(l.opening_qty2), sum(l.opening_ps_qty1), sum(l.opening_ps_qty2)
    INTO ln_total_qty1, ln_total_qty2, ln_total_ol_qty1, ln_total_ol_qty2, ln_total_ps_qty1, ln_total_ps_qty2
  FROM inv_valuation l
  where l.object_id = p_object_id
    and l.daytime = p_daytime
    and l.year_code = to_char(p_daytime, 'YYYY');

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'SUM Closing1:'|| ln_total_qty1 || ' Closing2:' || ln_total_qty2
|| ' OLClosing1:'|| ln_total_ol_qty1 || ' OLClosing2:' || ln_total_ol_qty2
|| ' PSClosing1:'|| ln_total_ps_qty1 || ' PSClosing2:' || ln_total_ps_qty2);
*/
  -- Find any existing field splits
  for c_split in c_existing_field_split(p_object_id, p_daytime) loop
     li_count := li_count + 1;
     ltab_field_split(li_count).object_id := c_split.object_id;
     ltab_field_split(li_count).dist_id := c_split.dist_id;

     ltab_field_split(li_count).closing_ul_position_qty1 := c_split.closing_ul_position_qty1;
     ltab_field_split(li_count).closing_ul_position_qty2 := c_split.closing_ul_position_qty2;

     ltab_field_split(li_count).closing_ol_position_qty1 := c_split.closing_ol_position_qty1;
     ltab_field_split(li_count).closing_ol_position_qty2 := c_split.closing_ol_position_qty2;

     ltab_field_split(li_count).closing_ps_position_qty1 := c_split.closing_ps_position_qty1;
     ltab_field_split(li_count).closing_ps_position_qty2 := c_split.closing_ps_position_qty2;

     ln_total_field_qty1 := ln_total_field_qty1 + nvl( c_split.closing_ul_position_qty1, 0);
     ln_total_field_qty2 := ln_total_field_qty2 + nvl( c_split.closing_ul_position_qty2, 0);
     ln_total_field_ps_qty1 := ln_total_field_ps_qty1 + nvl( c_split.closing_ps_position_qty1, 0);
     ln_total_field_ps_qty2 := ln_total_field_ps_qty2 + nvl( c_split.closing_ps_position_qty2, 0);

  END LOOP;

  -- Add any missing fields (when inserting)
  for c_ref in c_missing_field_split(p_object_id, p_daytime) loop
     li_count := li_count + 1;
     ltab_field_split(li_count).object_id := c_ref.inventory_id;
     ltab_field_split(li_count).dist_id := c_ref.field_id;

     ltab_field_split(li_count).closing_ul_position_qty1 := 0;
     ltab_field_split(li_count).closing_ul_position_qty2 := 0;

     ltab_field_split(li_count).closing_ol_position_qty1 := 0;
     ltab_field_split(li_count).closing_ol_position_qty2 := 0;

     ltab_field_split(li_count).closing_ps_position_qty1 := 0;
     ltab_field_split(li_count).closing_ps_position_qty2 := 0;
  END LOOP;

/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'Field Count:'|| ltab_field_split.COUNT );
*/
  -- Calculate field split - UL QTY1
  IF ln_total_field_qty1 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ul_position_qty1 := Round(ln_total_qty1/ltab_field_split.COUNT, li_round);
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'Setting FieldPos1:'|| ltab_field_split(i).closing_ul_position_qty1 );
*/

      ln_sum_field_qty1 := ln_sum_field_qty1 + ltab_field_split(i).closing_ul_position_qty1;
      IF ltab_field_split(i).closing_ul_position_qty1 > ln_max_field_qty1 THEN
         ln_max_field_qty1 := ltab_field_split(i).closing_ul_position_qty1;
         li_index_max_qty1 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ul_position_qty1 := Round(ln_total_qty1 * (ltab_field_split(i).closing_ul_position_qty1 / ln_total_field_qty1), li_round);
      ln_sum_field_qty1 := ln_sum_field_qty1 + ltab_field_split(i).closing_ul_position_qty1;
      IF ltab_field_split(i).closing_ul_position_qty1 > ln_max_field_qty1 THEN
         ln_max_field_qty1 := ltab_field_split(i).closing_ul_position_qty1;
         li_index_max_qty1 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate field split - UL QTY2
  IF ln_total_field_qty2 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ul_position_qty2 := Round(ln_total_qty2/ltab_field_split.COUNT, li_round);
      ln_sum_field_qty2 := ln_sum_field_qty2 + ltab_field_split(i).closing_ul_position_qty2;
      IF ltab_field_split(i).closing_ul_position_qty2 > ln_max_field_qty2 THEN
         ln_max_field_qty2 := ltab_field_split(i).closing_ul_position_qty2;
         li_index_max_qty2 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ul_position_qty2 := Round(ln_total_qty2 * (ltab_field_split(i).closing_ul_position_qty2 / ln_total_field_qty2), li_round);
      ln_sum_field_qty2 := ln_sum_field_qty2 + ltab_field_split(i).closing_ul_position_qty2;
      IF ltab_field_split(i).closing_ul_position_qty2 > ln_max_field_qty2 THEN
         ln_max_field_qty2 := ltab_field_split(i).closing_ul_position_qty2;
         li_index_max_qty2 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate field split - OL QTY1
  IF ln_total_field_ol_qty1 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ol_position_qty1 := Round(ln_total_ol_qty1/ltab_field_split.COUNT, li_round);
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'Setting FieldPos1:'|| ltab_field_split(i).closing_ol_position_qty1 );
*/
      ln_sum_field_ol_qty1 := ln_sum_field_ol_qty1 + ltab_field_split(i).closing_ol_position_qty1;
      IF ltab_field_split(i).closing_ol_position_qty1 > ln_max_field_ol_qty1 THEN
         ln_max_field_ol_qty1 := ltab_field_split(i).closing_ol_position_qty1;
         li_index_max_ol_qty1 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ol_position_qty1 := Round(ln_total_ol_qty1 * (ltab_field_split(i).closing_ol_position_qty1 / ln_total_field_ol_qty1), li_round);
      ln_sum_field_ol_qty1 := ln_sum_field_ol_qty1 + ltab_field_split(i).closing_ol_position_qty1;
      IF ltab_field_split(i).closing_ol_position_qty1 > ln_max_field_ol_qty1 THEN
         ln_max_field_ol_qty1 := ltab_field_split(i).closing_ol_position_qty1;
         li_index_max_ol_qty1 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate field split - OL QTY2
  IF ln_total_field_ol_qty2 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ol_position_qty2 := Round(ln_total_ol_qty2/ltab_field_split.COUNT, li_round);
      ln_sum_field_ol_qty2 := ln_sum_field_ol_qty2 + ltab_field_split(i).closing_ol_position_qty2;
      IF ltab_field_split(i).closing_ol_position_qty2 > ln_max_field_ol_qty2 THEN
         ln_max_field_ol_qty2 := ltab_field_split(i).closing_ol_position_qty2;
         li_index_max_ol_qty2 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ol_position_qty2 := Round(ln_total_ol_qty2 * (ltab_field_split(i).closing_ol_position_qty2 / ln_total_field_ol_qty2), li_round);
      ln_sum_field_ol_qty2 := ln_sum_field_ol_qty2 + ltab_field_split(i).closing_ol_position_qty2;
      IF ltab_field_split(i).closing_ol_position_qty2 > ln_max_field_ol_qty2 THEN
         ln_max_field_ol_qty2 := ltab_field_split(i).closing_ol_position_qty2;
         li_index_max_ol_qty2 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate field split - PS QTY1
  IF ln_total_field_ps_qty1 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ps_position_qty1 := Round(ln_total_ps_qty1/ltab_field_split.COUNT, li_round);
      ln_sum_field_ps_qty1 := ln_sum_field_ps_qty1 + ltab_field_split(i).closing_ps_position_qty1;
      IF ltab_field_split(i).closing_ps_position_qty1 > ln_max_field_ps_qty1 THEN
         ln_max_field_ps_qty1 := ltab_field_split(i).closing_ps_position_qty1;
         li_index_max_ps_qty1 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ps_position_qty1 := Round(ln_total_ps_qty1 * (ltab_field_split(i).closing_ps_position_qty1 / ln_total_field_ps_qty1), li_round);
      ln_sum_field_ps_qty1 := ln_sum_field_ps_qty1 + ltab_field_split(i).closing_ps_position_qty1;
      IF ltab_field_split(i).closing_ps_position_qty1 > ln_max_field_ps_qty1 THEN
         ln_max_field_ps_qty1 := ltab_field_split(i).closing_ps_position_qty1;
         li_index_max_ps_qty1 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate field split - PS QTY2
  IF ln_total_field_ps_qty2 = 0 THEN
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ps_position_qty2 := Round(ln_total_ps_qty2/ltab_field_split.COUNT, li_round);
      ln_sum_field_ps_qty2 := ln_sum_field_ps_qty2 + ltab_field_split(i).closing_ps_position_qty2;
      IF ltab_field_split(i).closing_ps_position_qty2 > ln_max_field_ps_qty2 THEN
         ln_max_field_ps_qty2 := ltab_field_split(i).closing_ps_position_qty2;
         li_index_max_ps_qty2 := i;
      END IF;
    END LOOP;
  ELSE
    FOR i in 1..ltab_field_split.COUNT LOOP
      ltab_field_split(i).closing_ps_position_qty2 := Round(ln_total_ps_qty2 * (ltab_field_split(i).closing_ps_position_qty2 / ln_total_field_ps_qty2), li_round);
      ln_sum_field_ps_qty2 := ln_sum_field_ps_qty2 + ltab_field_split(i).closing_ps_position_qty2;
      IF ltab_field_split(i).closing_ps_position_qty2 > ln_max_field_ps_qty2 THEN
         ln_max_field_ps_qty2 := ltab_field_split(i).closing_ps_position_qty2;
         li_index_max_ps_qty2 := i;
      END IF;
    END LOOP;
  END IF;

  -- Calculate the remainder to the max field.
  IF li_index_max_qty1 > 0 and ln_total_qty1 > 0 THEN
    ltab_field_split(li_index_max_qty1).closing_ul_position_qty1 := ltab_field_split(li_index_max_qty1).closing_ul_position_qty1 + ln_total_qty1 - ln_sum_field_qty1;
  END IF;
  IF li_index_max_qty2 > 0 and ln_total_qty2 > 0 THEN
    ltab_field_split(li_index_max_qty2).closing_ul_position_qty2 := ltab_field_split(li_index_max_qty2).closing_ul_position_qty2 + ln_total_qty2 - ln_sum_field_qty2;
  END IF;
  IF li_index_max_ol_qty1 > 0 and ln_total_ol_qty1 > 0 THEN
    ltab_field_split(li_index_max_ol_qty1).closing_ol_position_qty1 := ltab_field_split(li_index_max_ol_qty1).closing_ol_position_qty1 + ln_total_ol_qty1 - ln_sum_field_ol_qty1;
  END IF;
  IF li_index_max_ol_qty2 > 0 and ln_total_ol_qty2 > 0 THEN
    ltab_field_split(li_index_max_ol_qty2).closing_ol_position_qty2 := ltab_field_split(li_index_max_ol_qty2).closing_ol_position_qty2 + ln_total_ol_qty2 - ln_sum_field_ol_qty2;
  END IF;
  IF li_index_max_ps_qty1 > 0 and ln_total_ps_qty1 > 0 THEN
    ltab_field_split(li_index_max_ps_qty1).closing_ps_position_qty1 := ltab_field_split(li_index_max_ps_qty1).closing_ps_position_qty1 + ln_total_ps_qty1 - ln_sum_field_ps_qty1;
  END IF;
  IF li_index_max_ps_qty2 > 0 and ln_total_ps_qty2 > 0 THEN
    ltab_field_split(li_index_max_ps_qty2).closing_ps_position_qty2 := ltab_field_split(li_index_max_ps_qty2).closing_ps_position_qty2 + ln_total_ps_qty2 - ln_sum_field_ps_qty2;
  END IF;

  lv2_uom1_code := ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=');
  lv2_uom2_code := ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=');

      -- Insert new field split
      FOR i in 1..ltab_field_split.COUNT LOOP
           UPDATE INV_DIST_VALUATION idv
              SET idv.closing_ul_position_qty1   = ltab_field_split(i).closing_ul_position_qty1,
                  idv.closing_ul_position_qty2   = ltab_field_split(i).closing_ul_position_qty2,
                  idv.closing_ol_position_qty1   = ltab_field_split(i).closing_ol_position_qty1,
                  idv.closing_ol_position_qty2   = ltab_field_split(i).closing_ol_position_qty2,
                  idv.closing_ps_position_qty1   = ltab_field_split(i).closing_ps_position_qty1,
                  idv.closing_ps_position_qty2   = ltab_field_split(i).closing_ps_position_qty2,
                  idv.uom1_code = lv2_uom1_code,
                  idv.uom2_code = lv2_uom2_code,
                  idv.valuation_method = ec_inventory_version.valuation_method(p_object_id, p_daytime, '<='),
                  LAST_UPDATED_BY = P_USER_ID
            WHERE OBJECT_ID = ltab_field_split(i).OBJECT_ID
              AND DAYTIME = p_daytime
              AND YEAR_CODE = TO_CHAR(p_daytime, 'YYYY')
--              AND INVENTORY_ID = ltab_field_split(i).OBJECT_ID
              AND DIST_ID = ltab_field_split(i).DIST_ID;

         IF SQL%ROWCOUNT = 0 THEN

           INSERT INTO INV_DIST_VALUATION idv
             (Object_Id,
              Daytime,
              year_code,
              Dist_Id,
              name,
              description,
              valuation_level,
              uom1_code,
              uom2_code,
              opening_ul_position_qty1,
              opening_ul_position_qty2,
              opening_ol_position_qty1,
              opening_ol_position_qty2,
              opening_ps_position_qty1,
              opening_ps_position_qty2,
              closing_ul_position_qty1,
              closing_ul_position_qty2,
              closing_ol_position_qty1,
              closing_ol_position_qty2,
              closing_ps_position_qty1,
              closing_ps_position_qty2,
              valuation_method,
              Created_By)
           VALUES
             (ltab_field_split(i).object_id,
              p_daytime,
              TO_CHAR(p_daytime, 'YYYY'),
              ltab_field_split(i).dist_id,
              Ec_Inventory_Version.name(p_object_id,p_daytime, '<='),
              Ec_Inventory.description(p_object_id),
              Ec_Inventory_Version.valuation_level(p_object_id,p_daytime, '<='),
              lv2_uom1_code,
              lv2_uom2_code,
              ltab_field_split(i).closing_ul_position_qty1, -- Opening
              ltab_field_split(i).closing_ul_position_qty2,
              ltab_field_split(i).closing_ol_position_qty1,
              ltab_field_split(i).closing_ol_position_qty2,
              ltab_field_split(i).closing_ps_position_qty1,
              ltab_field_split(i).closing_ps_position_qty2,
              ltab_field_split(i).closing_ul_position_qty1, -- Closing
              ltab_field_split(i).closing_ul_position_qty2,
              ltab_field_split(i).closing_ol_position_qty1,
              ltab_field_split(i).closing_ol_position_qty2,
              ltab_field_split(i).closing_ps_position_qty1,
              ltab_field_split(i).closing_ps_position_qty2,
              ec_inventory_version.valuation_method(p_object_id, p_daytime, '<='),
              p_user_id);

        END IF;
      END LOOP;

END SetStimMthInvHistoric;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : SetInvLayerHistoric
-- Description    : Store the sum of the field split on the inventory layer.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : INV_LAYER, STIM_MTH_INV_LAYER
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------

PROCEDURE SetInvLayerHistoric
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2)  -- User ID that is updating the values
--</EC-DOC>
IS

CURSOR c_sum IS
SELECT sum(h.closing_ul_position_qty1) qty1, sum(h.closing_ul_position_qty2) qty2,
 sum(h.closing_ol_position_qty1) ol_qty1, sum(h.closing_ol_position_qty2) ol_qty2,
 sum(h.closing_ps_position_qty1) ps_qty1, sum(h.closing_ps_position_qty1) ps_qty2
FROM inv_dist_valuation h
WHERE h.object_id = p_object_id
  AND h.daytime = p_daytime
  AND h.year_code = TO_CHAR(p_daytime, 'YYYY');

BEGIN

  UPDATE inv_dist_valuation idv
  SET idv.opening_ul_position_qty1 = idv.closing_ul_position_qty1
     ,idv.opening_ul_position_qty2 = idv.closing_ul_position_qty2
     ,idv.opening_ol_position_qty1 = idv.closing_ol_position_qty1
     ,idv.opening_ol_position_qty2 = idv.closing_ol_position_qty2
     ,idv.opening_ps_position_qty1 = idv.closing_ps_position_qty1
     ,idv.opening_ps_position_qty2 = idv.closing_ps_position_qty2
     ,idv.valuation_method = ec_inventory_version.valuation_method(p_object_id, p_daytime, '<=')
  WHERE
      object_id = p_object_id
      AND daytime = p_daytime;

  FOR c_res IN c_sum LOOP
  UPDATE inv_valuation l
    SET l.ul_opening_pos_qty1 = c_res.qty1,
        l.ul_opening_pos_qty2 = c_res.qty2,
        l.ul_closing_pos_qty1 = c_res.qty1,
        l.ul_closing_pos_qty2 = c_res.qty2,
        l.ol_opening_qty1 = c_res.ol_qty1,
        l.ol_opening_qty2 = c_res.ol_qty2,
        l.ol_closing_pos_qty1 = c_res.ol_qty1,
        l.ol_closing_pos_qty2 = c_res.ol_qty2,
        l.total_closing_pos_qty1 = c_res.qty1 + NVL(c_res.ol_qty1, 0),
        l.total_closing_pos_qty2 = c_res.qty2 + NVL(c_res.ol_qty2, 0),
        l.ps_opening_qty1 = c_res.ps_qty1,
        l.ps_opening_qty2 = c_res.ps_qty2,
        l.ps_closing_pos_qty1 = c_res.ps_qty1,
        l.ps_closing_pos_qty2 = c_res.ps_qty2,
        l.valuation_method = ec_inventory_version.valuation_method(p_object_id, p_daytime, '<='),
        l.last_updated_by = p_user_id
    WHERE l.object_id = p_object_id
      AND l.daytime = p_daytime
      AND l.year_code = to_char(p_daytime, 'YYYY');

  END LOOP;

END SetInvLayerHistoric;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : RemoveStimMthInvHistoric
-- Description    : Remove rows for inventory and year from:
--                  - STIM_MTH_INV_HISTORY
--                  - INV_VALUATION
--                  - INV_LAYER
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
--
-------------------------------------------------------------------------------------------------

PROCEDURE RemoveStimMthInvHistoric
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2)  -- User ID that is updating the values
--</EC-DOC>
IS

BEGIN

  DELETE FROM INV_DIST_VALUATION
    WHERE OBJECT_ID = p_object_id
    and Trunc(DAYTIME, 'YYYY') = trunc(p_daytime, 'YYYY');

  DELETE FROM INV_VALUATION
    WHERE OBJECT_ID = p_object_id
    and Trunc(DAYTIME, 'YYYY') = trunc(p_daytime, 'YYYY');

END RemoveStimMthInvHistoric;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ProcessHistoricInventory
-- Description    : Call ProcessInventory for all years starting with the date pasted as argument.
--                  ProcessInventory will calculate INV_LAYER based on value in STIM_MTH_INV_HISTORIC.
--                  The EC application will treat the new calculated record as changed with the LAST_UPDATED_DATE is modified.
--                  Store the last updated date in a PL/SQL table before processing the inventory and reset it after the processing.
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
--
-------------------------------------------------------------------------------------------------
PROCEDURE ProcessHistoricInventory
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2)  -- User ID that is updating the values
--</EC-DOC>
IS

BEGIN

    ProcessInventory(p_object_id, p_daytime, p_user_id, 'TRUE');

    -- Set the valuation to booked.
    UPDATE inv_valuation v
       SET v.document_level_code = 'BOOKED'
           ,v.name = Ec_Inventory_Version.name(p_object_id, p_daytime, '<=')
           ,v.description = Ec_Inventory.description(p_object_id)
           ,v.valuation_level = Ec_Inventory_Version.valuation_level(p_object_id, p_daytime, '<=')
     WHERE v.object_id = p_object_id
       AND v.daytime = p_daytime;

END ProcessHistoricInventory;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      : IsValidationNotRun
-- Description    : Check if validation has been run for inventory
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
-- Behaviour      : Return 1 if the validation has been run and 0 if not.
--
-------------------------------------------------------------------------------------------------
FUNCTION IsValuationNotRun(
  p_object_id      VARCHAR2,
  p_historic       VARCHAR2 DEFAULT 'FALSE',
  p_physical_stock VARCHAR2 DEFAULT 'FALSE'
  ) RETURN VARCHAR2
--</EC-DOC>

is

ld_historic_daytime date;
ln_count  number default 0;

BEGIN
    -- Find last date with historic layer.
    SELECT nvl(max(daytime), to_date('01.01.1900','dd.mm.yyyy'))
    INTO   ld_historic_daytime
    FROM   inv_valuation
    WHERE  object_id = p_object_id
    AND    TO_CHAR(daytime, 'YYYY') = year_code
    AND    historic = 'TRUE';

    IF p_historic = 'TRUE' THEN
        select count(*)
          into ln_count
          from inv_valuation v
         where v.object_id = p_object_id
           and v.daytime > ld_historic_daytime;
    ELSE
        select count(*)
          into ln_count
          from inv_valuation v
         where v.object_id = p_object_id
           and v.daytime <= ld_historic_daytime;
    END IF;

    -- Returns false is physical stock is NOT enabled
    IF (p_physical_stock = 'TRUE') THEN
        IF (NVL(ec_inventory_version.physical_stock_ind(p_object_id, Ecdp_Timestamp.getCurrentSysdate, '<='), 'N')= 'N') THEN
            RETURN 'false';
        END IF;
    END IF;

    IF ln_count > 0 THEN
      return 'false';
    ELSE
      return 'true';
    END IF;

END IsValuationNotRun;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : CheckLayerSave
-- Description    : Check if it is OK to save the Layer.
--                  Validation must not have been run. And FIFO or Overlift can only have one layer.
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
-- Behaviour      : Raise an error if it is not OK to save the layer.
--
-------------------------------------------------------------------------------------------------
PROCEDURE CheckLayerSave(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_overlift       VARCHAR2 default 'FALSE'
  )
--</EC-DOC>
is

ln_count number default 0;

ln_underlift_layers NUMBER := 0;
ln_overlift_layers NUMBER := 0;

BEGIN
  -- Check that it is not any valuation
  IF IsValuationNotRun(p_object_id, 'TRUE') = 'false' THEN
     Raise_Application_Error(-20000,'\n\nCan not proceed since valuation exists.\n\n' );
  END IF;

    SELECT COUNT(*)
        INTO ln_underlift_layers
    FROM
        inv_valuation iv
    WHERE
        object_id = p_object_id
        AND iv.ul_closing_pos_qty1 >= 0;

    SELECT COUNT(*)
        INTO ln_overlift_layers
    FROM
        inv_valuation iv
    WHERE
        object_id = p_object_id
        AND iv.ol_closing_pos_qty1 < 0;

    IF (ln_underlift_layers > 0 AND ln_overlift_layers > 0) THEN
        Raise_Application_Error(-20000, 'Can not have both underlift layers and overlift layers.' );
    END IF;


   IF (ec_inventory_version.physical_stock_ind(p_object_id, p_daytime, '<=') = 'Y') THEN
       SELECT count(*)
       INTO ln_count
       FROM inv_valuation iv
       WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND (iv.ps_closing_pos_qty1 IS NULL
       OR  NVL(iv.ps_closing_pos_qty1, 0) < 0)
       AND (iv.ps_rate IS NULL
       OR  NVL(iv.ps_rate, 0) < 0)
       ;

        IF (ln_count > 0) THEN
            Raise_Application_Error(-20000, '\n\nPhysical stock quantity is missing or physical stock quantity is less than zero for this layer.');
        END IF;
   ELSE
       SELECT count(*)
       INTO ln_count
       FROM inv_valuation iv
       WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND (iv.ps_closing_pos_qty1 IS NOT NULL
        OR  iv.ps_closing_pos_qty2 IS NOT NULL
        OR  iv.ps_rate IS NOT NULL);

        IF (ln_count > 0) THEN
            Raise_Application_Error(-20000, '\n\nPhysical stock is not enabled for this inventory. Please remove values from the physical stock columns and resave.');
        END IF;

   END IF;

  -- Check if valuation type = FIFO or Overlift: Can only have one layer.
  IF (ec_inventory_version.valuation_method(p_object_id, p_daytime, '<=') = 'FIFO') OR (p_overlift = 'TRUE') THEN
     select count(*)
       into ln_count
       from inv_valuation
      where object_id = p_object_id;

       IF ln_count > 1 THEN
         IF p_overlift = 'TRUE' THEN
            Raise_Application_Error(-20000,'\n\nOverlifting can only have one layer.\n\n' );
         ELSE
            Raise_Application_Error(-20000,'\n\nFIFO can only have one layer.\n\n' );
         END IF;
       END IF;

  END IF;

END CheckLayerSave;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : VerifyLayer
-- Description    : Verifies that the historical layers have valid values for qty, rate and closing value.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Called from class triggers STIM_MTH_INV_HISTORIC_UL/OL and INV_LAYER_UL/OL.
--                  Also called from Java class HistoricLayerFieldSaveBusinessAction upon save in field level component.
-----------------------------------------------------------------------------------------------------
PROCEDURE VerifyLayer(p_inv_position VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_daytime DATE
                     ,p_qty1 NUMBER
                     ,p_qty2 NUMBER
                     ,p_rate NUMBER
                     ,p_pricing_value NUMBER
                     ,p_level VARCHAR2)
IS
--</EC-DOC>
BEGIN

    IF (p_inv_position = 'UNDERLIFT') THEN

       IF p_level = 'LAYER' THEN

          IF nvl(p_QTY1, -1) < 0 AND ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=') IS NOT NULL THEN
              Raise_Application_Error(-20000, 'Qty 1 can not be empty or a negative number.');
          END IF;

          IF nvl(p_QTY2, -1) < 0 AND ec_inventory_version.uom2_code(p_object_id, p_daytime, '<=') IS NOT NULL THEN
              Raise_Application_Error(-20000, 'Qty 2 can not be empty or a negative number.');
          END IF;

          IF nvl(p_pricing_value, 0) < 0 THEN
              Raise_Application_Error(-20000, 'Underlift pricing value must be greater than 0.');
          END IF;

          IF nvl(p_RATE, -1) < 0 AND ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=') = 'WEIGHTED_AVERAGE' THEN
              Raise_Application_Error(-20000, 'Historic Layer Underlift Rate must be greater than 0.');
          END IF;

       ELSIF p_level = 'FIELD' THEN

          IF nvl(p_RATE, -1) < 0 AND ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=') = 'BY_FIELD_RATE' THEN
              Raise_Application_Error(-20000, 'Field Underlift Rate must be greater than 0.');
          END IF;

       END IF;

    ELSIF (p_inv_position = 'OVERLIFT') THEN

       IF p_level = 'LAYER' THEN

          IF nvl(p_QTY1, 1) >= 0 AND ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=') IS NOT NULL THEN
              Raise_Application_Error(-20000, 'Qty 1 must be a negative number.');
          END IF;

          IF nvl(p_QTY2, 1) >= 0 AND ec_inventory_version.uom2_code(p_object_id, p_daytime, '<=') IS NOT NULL THEN
              Raise_Application_Error(-20000, 'Qty 2 must be a negative number.');
          END IF;

          IF nvl(p_RATE, -1) < 0 AND ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=') = 'WEIGHTED_AVERAGE' THEN
              Raise_Application_Error(-20000, 'Historic Layer Overlift Rate must be greater than 0.');
          END IF;

       ELSIF p_level = 'FIELD' THEN

          IF nvl(p_RATE, -1) < 0 AND ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=') = 'BY_FIELD_RATE' THEN
              Raise_Application_Error(-20000, 'Field Overlift Rate must be greater than 0.');
          END IF;

       END IF;

    END IF;

END VerifyLayer;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ProcessInvLayer
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
-- Behaviour      : Raise an error if it is not OK to save the layer.
--
-------------------------------------------------------------------------------------------------
PROCEDURE ProcessInvLayer(p_object_id VARCHAR2
                         ,p_daytime DATE
                         ,p_call_tag VARCHAR2
                         ,p_valuation_method VARCHAR2
                         ,p_opening_qty1 NUMBER
                         ,p_opening_qty2 NUMBER
                         ,p_ytd_movement_qty1 NUMBER
                         ,p_ytd_movement_qty2 NUMBER
                         ,p_ytd_ps_mov_qty1 NUMBER
                         ,p_ytd_ps_mov_qty2 NUMBER
                         ,p_ul_rate NUMBER
                         ,p_ol_rate NUMBER
                         ,p_ps_rate NUMBER
                         ,p_user VARCHAR2
                         ,p_process_historic VARCHAR2)
IS

ld_pre_recent DATE;
ln_movement_qty1 NUMBER;
ln_movement_left_qty1 NUMBER;
ln_movement_qty2 NUMBER;
ln_movement_left_qty2 NUMBER;

ln_movement_ps_qty1 NUMBER;
ln_movement_ps_left_qty1 NUMBER;
ln_movement_ps_qty2 NUMBER;
ln_movement_ps_left_qty2 NUMBER;

ln_pricing_value NUMBER;
ln_memo_value NUMBER;

ln_pricing_ps_value NUMBER;
ln_memo_ps_value NUMBER;

ln_ul_rate NUMBER;
ln_ol_rate NUMBER;
ln_ps_rate NUMBER;

-- Cursor for looping through all layers for a given daytime in descending order
-- This since we are "eating" from the latest layer for LIFO
-- FIFO has only got one layer
CURSOR c_layer_desc(cp_object_id VARCHAR2, cp_daytime DATE, cp_valuation_method VARCHAR2)
IS
SELECT *
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
    AND TO_NUMBER(year_code) < TO_NUMBER(TO_CHAR(cp_daytime, 'YYYY'))
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
ORDER BY
    TO_NUMBER(year_code) DESC;


CURSOR c_prev_layer(cp_object_id VARCHAR2, cp_daytime DATE, cp_valuation_method VARCHAR2, cp_historic VARCHAR2) IS
SELECT
    *
FROM
    inv_valuation
WHERE
    (cp_historic = 'FALSE'
    AND daytime = (SELECT MAX(daytime) FROM inv_valuation WHERE daytime <= cp_daytime)
    AND object_id = cp_object_id
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
    ) OR (
    cp_historic = 'TRUE'
    AND daytime <= cp_daytime
    AND object_id = cp_object_id
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
    )
    ;

CURSOR c_prev_dist_layer(cp_object_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2, cp_valuation_method VARCHAR2, cp_historic VARCHAR2) IS
SELECT
    *
FROM
    inv_dist_valuation
WHERE
    (cp_historic = 'FALSE'
    AND daytime = cp_daytime
    AND object_id = cp_object_id
    AND year_code = cp_year_code
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
    ) OR (
    cp_historic = 'TRUE'
    AND daytime <= cp_daytime
    AND object_id = cp_object_id
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
    )
;

-- Max daytime from previous years
CURSOR c_max_prev_layer(cp_object_id VARCHAR2, cp_daytime DATE, cp_valuation_method VARCHAR2) IS
SELECT
    MAX(daytime) daytime
    ,MAX(TO_NUMBER(year_code)) year_code
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime < cp_daytime
    AND TO_NUMBER(TO_CHAR(daytime, 'YYYY')) < TO_NUMBER(TO_CHAR(cp_daytime, 'YYYY'))
    AND TO_NUMBER(year_code) < TO_NUMBER(TO_CHAR(cp_daytime, 'YYYY'))
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
;

CURSOR c_sum_closing(cp_object_id VARCHAR2, cp_daytime DATE, cp_valuation_method VARCHAR2) IS
SELECT
    SUM(NVL(iv.ul_closing_pos_qty1, 0) + NVL(iv.ol_closing_pos_qty1, 0)) sum_qty1
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
    AND ('LIFO' = cp_valuation_method OR 'LIFO_INTERIM' = cp_valuation_method)
;


CURSOR c_max_prev_year_code(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    MAX(TO_NUMBER(year_code)) year_code
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
    AND TO_NUMBER(year_code) < TO_NUMBER(TO_CHAR(cp_daytime, 'YYYY'))
;

TYPE t_InvLayerTab IS TABLE OF inv_valuation%ROWTYPE;

ltab_inv_layer t_InvLayerTab := t_InvLayerTab();

lrec_prev_inv_valuation inv_valuation%ROWTYPE;
lrec_inv_valuation inv_valuation%ROWTYPE;

lv2_code VARCHAR2(32);
lv2_historic VARCHAR2(32);
ln_max_year_code NUMBER;
ln_sum_qty1 NUMBER := NULL;

ln_max_prev_year_code  VARCHAR2(32);
-- ln_ul_closing_prev NUMBER;

BEGIN

/********************************
*********************************
 * December valuation is handled specially
 * First valuation in a year must be handled specially
 * Layers always copied from last valuation in previous years
 * Field split must be taken from the field valuation / historic field val (STIM_MTH_INV_HISTORIC)
 * Movement into layers always uses current layers rate

Postings
 * Accounts for negative UL booking when using layers must be handled
 * Underlift - Posting to all fields
 * Overlift - Post to overlift fields only pro rata
*********************************
*********************************
*/


    -- "layer" valuation only valid for LIFO_INTERIM valuation
    IF (p_valuation_method NOT IN ('LIFO_INTERIM', 'LIFO') ) THEN
        RETURN;
    END IF;


    -- Clear Temporary PL/SQL table which contains all the prevois layers
    ltab_inv_layer.delete;

    -- Delete "old" layers from dist table to have a fresh start
    DELETE FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code <> to_char(daytime, 'YYYY');

    -- Delete "old" layers from valuation table to have a fresh start
    DELETE FROM inv_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code <> to_char(daytime, 'YYYY');

/* DEBUG
    Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Processing Inv Layer: ' || ec_inventory.object_code(p_object_id) ||
      ' Daytime: ' || p_daytime || ' CallTag: ' || p_call_tag
      || ' p_valuation_method: ' || p_valuation_method
      || ' YTD Movement QTY1: ' || p_ytd_movement_qty1 || ' YTD Movement QTY2: ' || p_ytd_movement_qty2
      || ' ulRate: ' || p_ul_rate
      || ' olRate: ' || p_ol_rate
      || ' p_opening_qty1: ' ||  p_opening_qty1);
 */
    ld_pre_recent := NULL;

    -- If Layer for Current Year does not exist asume new month and copy all layers from previous valuation
    IF (p_process_historic = 'FALSE') THEN
        BEGIN
            --
            -- Insert Into Layer for "Current" Year
            --
            INSERT INTO inv_valuation(
                                 object_id
                                 ,daytime
                                 ,year_code
                                 ,historic
                                 ,name
                                 ,description
                                 ,valuation_level
                                 ,document_level_code
                                 )
            VALUES (p_object_id
                    ,p_daytime
                    ,TO_CHAR(p_daytime, 'YYYY')
                    ,p_process_historic
                    ,Ec_Inventory_Version.name(p_object_id, p_daytime, '<=')
                    ,Ec_Inventory.description(p_object_id)
                    ,Ec_Inventory_Version.valuation_level(p_object_id, p_daytime, '<=')
                    ,'OPEN'
                    );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END IF;

    -- Find the previous valuation based by layers, picks latest valuation in previous years
    FOR CurPrev IN c_max_prev_layer(p_object_id, p_daytime, p_valuation_method) LOOP
        ld_pre_recent := CurPrev.daytime;
        ln_max_year_code := CurPrev.year_code;
    END LOOP;

    -- Find the total closing on all layers in previous years run
    FOR CurPrevSum IN c_sum_closing(p_object_id, ld_pre_recent, p_valuation_method) LOOP
        ln_sum_qty1 := CurPrevSum.sum_qty1;
    END LOOP;

    lrec_prev_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, ld_pre_recent, ln_max_year_code);

/* DEBUG
Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'YYY: ld_pre_recent: ' || ld_pre_recent ||
' ln_ul_closing_prev: ' || lrec_prev_inv_valuation.ul_closing_pos_qty1);
*/
    -- Copy previous layers to current layer if not exists

    IF (NVL(ln_sum_qty1,0) > 0) THEN
        lv2_historic := ec_inv_valuation.historic(p_object_id, ld_pre_recent, TO_CHAR(ld_pre_recent, 'YYYY'));
/* DEBUG
Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'XXX: ld_pre_recent: ' || ld_pre_recent ||
' lv2_historic: ' || lv2_historic);
*/
        -- All Layers are looped over and copied to current daytime
        FOR CurPrevLayer IN c_prev_layer(p_object_id, ld_pre_recent, p_valuation_method, lv2_historic) LOOP
/* DEBUG
Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Copy Layer: ' || CurPrevLayer.year_code);
 */
            -- Only copy layers which have either Underlift or Overlift
            IF (CurPrevLayer.Ul_Closing_Pos_Qty1 > 0 OR CurPrevLayer.Ol_Closing_Pos_Qty1 < 0) THEN

            BEGIN
                INSERT INTO inv_valuation(object_id
                                      ,daytime
                                      ,year_code
                                      ,historic
                                      ,valuation_method
                                      ,name
                                      ,description
                                      ,valuation_level
                                      ,document_level_code
                                      ,Inv_Money_Dist_Method
                                      ,Inv_Pricing_Value_Method
                                      ,YTD_UL_MOV_QTY1 -- QTYs
                                      ,YTD_UL_MOV_QTY2
                                      ,TOTAL_MOV_QTY1
                                      ,TOTAL_MOV_QTY2
                                      ,UL_OPENING_POS_QTY1
                                      ,UL_OPENING_POS_QTY2
                                      ,UL_CLOSING_POS_QTY1
                                      ,UL_CLOSING_POS_QTY2
                                      ,YTD_PROD_QTY1
                                      ,YTD_PROD_QTY2
                                      ,OL_CLOSING_POS_QTY1
                                      ,OL_CLOSING_POS_QTY2
                                      ,YTD_OL_MOV_QTY1
                                      ,YTD_OL_MOV_QTY2
                                      ,OL_OPENING_QTY1
                                      ,OL_OPENING_QTY2
                                      ,PS_CLOSING_POS_QTY1
                                      ,PS_CLOSING_POS_QTY2
                                      ,PS_OPENING_QTY1
                                      ,PS_OPENING_QTY2
                                      ,YTD_PS_MOV_QTY1
                                      ,YTD_PS_MOV_QTY2
                                      ,TOTAL_CLOSING_POS_QTY1
                                      ,TOTAL_CLOSING_POS_QTY2
                                      ,UL_AVG_RATE -- RATES
                                      ,OL_AVG_RATE
                                      ,UL_RATE
                                      ,UL_AVG_RATE_STATUS
                                      ,OL_AVG_PRICE_STATUS
                                      ,OL_BOOKING_GROUP_FOREX_RATE
                                      ,OL_BOOKING_LOCAL_FOREX_RATE
                                      ,OL_BOOKING_MEMO_FOREX_RATE
                                      ,OL_RATE
                                      ,PS_AVG_RATE
                                      ,PS_AVG_RATE_STATUS
                                      ,PS_RATE
                                      ,UL_BOOKING_GROUP_FOREX_RATE
                                      ,UL_BOOKING_LOCAL_FOREX_RATE
                                      ,UL_BOOKING_MEMO_FOREX_RATE
                                      )
                VALUES (p_object_id
                       ,p_daytime
                       ,CurPrevLayer.year_code
                       ,CurPrevLayer.historic
                       ,p_valuation_method
                       ,Ec_Inventory_Version.name(p_object_id, p_daytime, '<=')
                       ,Ec_Inventory.description(p_object_id)
                       ,Ec_Inventory_Version.valuation_level(p_object_id, p_daytime, '<=')
                       ,'OPEN'
                       ,CurPrevLayer.Inv_Money_Dist_Method
                       ,CurPrevLayer.Inv_Pricing_Value_Method
                       ,NVL(CurPrevLayer.YTD_UL_MOV_QTY1, 0) -- QTYs
                       ,NVL(CurPrevLayer.YTD_UL_MOV_QTY2, 0)
                       ,CurPrevLayer.TOTAL_MOV_QTY1
                       ,CurPrevLayer.TOTAL_MOV_QTY2
                       ,CurPrevLayer.UL_OPENING_POS_QTY1
                       ,CurPrevLayer.UL_OPENING_POS_QTY2
                       ,CurPrevLayer.UL_CLOSING_POS_QTY1
                       ,CurPrevLayer.UL_CLOSING_POS_QTY2
                       ,CurPrevLayer.YTD_PROD_QTY1
                       ,CurPrevLayer.YTD_PROD_QTY2
                       ,CurPrevLayer.OL_CLOSING_POS_QTY1
                       ,CurPrevLayer.OL_CLOSING_POS_QTY2
                       ,NVL(CurPrevLayer.YTD_OL_MOV_QTY1, 0)
                       ,NVL(CurPrevLayer.YTD_OL_MOV_QTY2, 0)
                       ,CurPrevLayer.OL_OPENING_QTY1
                       ,CurPrevLayer.OL_OPENING_QTY2
                       ,CurPrevLayer.PS_CLOSING_POS_QTY1
                       ,CurPrevLayer.PS_CLOSING_POS_QTY2
                       ,CurPrevLayer.PS_OPENING_QTY1
                       ,CurPrevLayer.PS_OPENING_QTY2
                       ,NVL(CurPrevLayer.YTD_PS_MOV_QTY1, 0)
                       ,NVL(CurPrevLayer.YTD_PS_MOV_QTY2, 0)
                       ,CurPrevLayer.TOTAL_CLOSING_POS_QTY1
                       ,CurPrevLayer.TOTAL_CLOSING_POS_QTY2
                       ,CurPrevLayer.UL_AVG_RATE -- RATES
                       ,CurPrevLayer.OL_AVG_RATE
                       ,CurPrevLayer.UL_RATE
                       ,CurPrevLayer.UL_AVG_RATE_STATUS
                       ,CurPrevLayer.OL_AVG_PRICE_STATUS
                       ,CurPrevLayer.OL_BOOKING_GROUP_FOREX_RATE
                       ,CurPrevLayer.OL_BOOKING_LOCAL_FOREX_RATE
                       ,CurPrevLayer.OL_BOOKING_MEMO_FOREX_RATE
                       ,CurPrevLayer.OL_RATE
                       ,CurPrevLayer.PS_AVG_RATE
                       ,CurPrevLayer.PS_AVG_RATE_STATUS
                       ,CurPrevLayer.PS_RATE
                       ,CurPrevLayer.UL_BOOKING_GROUP_FOREX_RATE
                       ,CurPrevLayer.UL_BOOKING_LOCAL_FOREX_RATE
                       ,CurPrevLayer.UL_BOOKING_MEMO_FOREX_RATE
                       );

                FOR CurPrevDistLayer IN c_prev_dist_layer(p_object_id, ld_pre_recent, CurPrevLayer.year_code, p_valuation_method, lv2_historic) LOOP
                    INSERT INTO inv_dist_valuation (
                        OBJECT_ID
                        ,DIST_ID
                        ,DAYTIME
                        ,YEAR_CODE
                        ,BOOK_CATEGORY
                        ,VALUATION_METHOD
                        ,VALUATION_LEVEL
                        ,NAME
                        ,UL_RATE
                        ,OL_RATE
                        ,UL_PRICE_VALUE
                        ,UL_MEMO_VALUE
                        ,UL_BOOKING_VALUE
                        ,OL_PRICE_VALUE
                        ,OL_MEMO_VALUE
                        ,OL_BOOKING_VALUE
                        ,UOM1_CODE
                        ,UOM2_CODE
                        ,YTD_MOVEMENT_QTY1
                        ,YTD_MOVEMENT_QTY2
                        ,CLOSING_UL_POSITION_QTY1
                        ,CLOSING_UL_POSITION_QTY2
                        ,CLOSING_OL_POSITION_QTY1
                        ,CLOSING_OL_POSITION_QTY2
                        ,YTD_PROD_QTY1
                        ,YTD_PROD_QTY2
                        ,PPA_QTY1
                        ,PPA_QTY2
                        ,OPENING_UL_POSITION_QTY1
                        ,OPENING_UL_POSITION_QTY2
                        ,UL_LOCAL_VALUE
                        ,OL_LOCAL_VALUE
                        ,UL_GROUP_VALUE
                        ,OL_GROUP_VALUE
                        ,FIN_DEBIT_POSTING_KEY
                        ,FIN_DEBIT_COST_OBJECT
                        ,FIN_CREDIT_POSTING_KEY
                        ,FIN_CREDIT_COST_OBJECT
                        ,FIN_MATERIAL_NUMBER
                        ,FIN_INTERFACE_FILE
                        ,FIN_DEBIT_COST_OBJ_TYPE
                        ,FIN_CREDIT_COST_OBJ_TYPE
                        ,FIN_INT_DEB_POSTING_KEY
                        ,FIN_INT_DEB_COST_OBJECT
                        ,FIN_INT_CRE_POSTING_KEY
                        ,FIN_INT_CRE_COST_OBJECT
                        ,FIN_INT_DEB_COST_O_TYPE
                        ,FIN_INT_CRE_COST_O_TYPE
                        ,CLOSING_PS_POSITION_QTY1
                        ,CLOSING_PS_POSITION_QTY2
                        ,FIN_PS_CREDIT_COST_OBJECT
                        ,FIN_PS_CREDIT_POSTING_KEY
                        ,FIN_PS_DEBIT_COST_OBJECT
                        ,FIN_PS_DEBIT_POSTING_KEY
                        ,FIN_PS_DEB_COST_OBJ_TYPE
                        ,FIN_PS_INTERFACE_FILE
                        ,FIN_PS_MATERIAL_NUMBER
                        ,OPENING_OL_POSITION_QTY1
                        ,OPENING_OL_POSITION_QTY2
                        ,OPENING_PS_POSITION_QTY1
                        ,OPENING_PS_POSITION_QTY2
                        ,TOTAL_CLOSING_POS_QTY1
                        ,TOTAL_CLOSING_POS_QTY2
                        ,PPA_PS_QTY1
                        ,PPA_PS_QTY2
                        ,PS_BOOKING_VALUE
                        ,PS_GROUP_VALUE
                        ,PS_LOCAL_VALUE
                        ,PS_MEMO_VALUE
                        ,PS_MOVEMENT_QTY1
                        ,PS_MOVEMENT_QTY2
                        ,PS_PRICE_VALUE
                        ,PS_RATE
                        ,YTD_PS_MOVEMENT_QTY1
                        ,YTD_PS_MOVEMENT_QTY2
                        ,YTD_OL_MOV_QTY1
                        ,YTD_OL_MOV_QTY2
                        ,YTD_UL_MOV_QTY1
                        ,YTD_UL_MOV_QTY2
                        ,FIN_PS_CRE_COST_OBJ_TYPE
                        ,FIN_CREDIT_GL_ACCOUNT
                        ,FIN_DEBIT_GL_ACCOUNT
                        ,FIN_INT_CRE_GL_ACCOUNT
                        ,FIN_INT_DEB_GL_ACCOUNT
                        ,FIN_PS_CREDIT_GL_ACCOUNT
                        ,FIN_PS_DEBIT_GL_ACCOUNT
                        ,FIN_CREDIT_ACCOUNT_ID
                        ,FIN_DEBIT_ACCOUNT_ID
                        ,FIN_INT_CRE_ACCOUNT_ID
                        ,FIN_INT_DEB_ACCOUNT_ID
                        ,FIN_PS_CREDIT_ACCOUNT_ID
                        ,FIN_PS_DEBIT_ACCOUNT_ID
                        ,FIN_INT_PS_CR_COST_OBJ_TYPE
                        ,FIN_INT_PS_CR_ACCOUNT_ID
                        ,FIN_INT_PS_CR_COST_OBJECT
                        ,FIN_INT_PS_CR_GL_ACCOUNT
                        ,FIN_INT_PS_CR_POSTING_KEY
                        ,FIN_INT_PS_DR_COST_OBJ_TYPE
                        ,FIN_INT_PS_DR_ACCOUNT_ID
                        ,FIN_INT_PS_DR_COST_OBJECT
                        ,FIN_INT_PS_DR_GL_ACCOUNT
                        ,FIN_INT_PS_DR_POSTING_KEY
                        ,DESCRIPTION
                        ,COMMENTS
                    ) VALUES (
                        p_object_id
                        ,CurPrevDistLayer.DIST_ID
                        ,p_daytime
                        ,CurPrevDistLayer.YEAR_CODE
                        ,CurPrevDistLayer.BOOK_CATEGORY
                        ,p_valuation_method
                        ,CurPrevDistLayer.VALUATION_LEVEL
                        ,CurPrevDistLayer.NAME
                        ,CurPrevDistLayer.UL_RATE
                        ,CurPrevDistLayer.OL_RATE
                        ,CurPrevDistLayer.UL_PRICE_VALUE
                        ,CurPrevDistLayer.UL_MEMO_VALUE
                        ,CurPrevDistLayer.UL_BOOKING_VALUE
                        ,CurPrevDistLayer.OL_PRICE_VALUE
                        ,CurPrevDistLayer.OL_MEMO_VALUE
                        ,CurPrevDistLayer.OL_BOOKING_VALUE
                        ,CurPrevDistLayer.UOM1_CODE
                        ,CurPrevDistLayer.UOM2_CODE
                        ,CurPrevDistLayer.YTD_MOVEMENT_QTY1
                        ,CurPrevDistLayer.YTD_MOVEMENT_QTY2
                        ,CurPrevDistLayer.CLOSING_UL_POSITION_QTY1
                        ,CurPrevDistLayer.CLOSING_UL_POSITION_QTY2
                        ,CurPrevDistLayer.CLOSING_OL_POSITION_QTY1
                        ,CurPrevDistLayer.CLOSING_OL_POSITION_QTY2
                        ,CurPrevDistLayer.YTD_PROD_QTY1
                        ,CurPrevDistLayer.YTD_PROD_QTY2
                        ,CurPrevDistLayer.PPA_QTY1
                        ,CurPrevDistLayer.PPA_QTY2
                        ,CurPrevDistLayer.OPENING_UL_POSITION_QTY1
                        ,CurPrevDistLayer.OPENING_UL_POSITION_QTY2
                        ,CurPrevDistLayer.UL_LOCAL_VALUE
                        ,CurPrevDistLayer.OL_LOCAL_VALUE
                        ,CurPrevDistLayer.UL_GROUP_VALUE
                        ,CurPrevDistLayer.OL_GROUP_VALUE
                        ,CurPrevDistLayer.FIN_DEBIT_POSTING_KEY
                        ,CurPrevDistLayer.FIN_DEBIT_COST_OBJECT
                        ,CurPrevDistLayer.FIN_CREDIT_POSTING_KEY
                        ,CurPrevDistLayer.FIN_CREDIT_COST_OBJECT
                        ,CurPrevDistLayer.FIN_MATERIAL_NUMBER
                        ,CurPrevDistLayer.FIN_INTERFACE_FILE
                        ,CurPrevDistLayer.FIN_DEBIT_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_CREDIT_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_INT_DEB_POSTING_KEY
                        ,CurPrevDistLayer.FIN_INT_DEB_COST_OBJECT
                        ,CurPrevDistLayer.FIN_INT_CRE_POSTING_KEY
                        ,CurPrevDistLayer.FIN_INT_CRE_COST_OBJECT
                        ,CurPrevDistLayer.FIN_INT_DEB_COST_O_TYPE
                        ,CurPrevDistLayer.FIN_INT_CRE_COST_O_TYPE
                        ,CurPrevDistLayer.CLOSING_PS_POSITION_QTY1
                        ,CurPrevDistLayer.CLOSING_PS_POSITION_QTY2
                        ,CurPrevDistLayer.FIN_PS_CREDIT_COST_OBJECT
                        ,CurPrevDistLayer.FIN_PS_CREDIT_POSTING_KEY
                        ,CurPrevDistLayer.FIN_PS_DEBIT_COST_OBJECT
                        ,CurPrevDistLayer.FIN_PS_DEBIT_POSTING_KEY
                        ,CurPrevDistLayer.FIN_PS_DEB_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_PS_INTERFACE_FILE
                        ,CurPrevDistLayer.FIN_PS_MATERIAL_NUMBER
                        ,CurPrevDistLayer.OPENING_OL_POSITION_QTY1
                        ,CurPrevDistLayer.OPENING_OL_POSITION_QTY2
                        ,CurPrevDistLayer.OPENING_PS_POSITION_QTY1
                        ,CurPrevDistLayer.OPENING_PS_POSITION_QTY2
                        ,CurPrevDistLayer.TOTAL_CLOSING_POS_QTY1
                        ,CurPrevDistLayer.TOTAL_CLOSING_POS_QTY2
                        ,CurPrevDistLayer.PPA_PS_QTY1
                        ,CurPrevDistLayer.PPA_PS_QTY2
                        ,CurPrevDistLayer.PS_BOOKING_VALUE
                        ,CurPrevDistLayer.PS_GROUP_VALUE
                        ,CurPrevDistLayer.PS_LOCAL_VALUE
                        ,CurPrevDistLayer.PS_MEMO_VALUE
                        ,CurPrevDistLayer.PS_MOVEMENT_QTY1
                        ,CurPrevDistLayer.PS_MOVEMENT_QTY2
                        ,CurPrevDistLayer.PS_PRICE_VALUE
                        ,CurPrevDistLayer.PS_RATE
                        ,NVL(CurPrevDistLayer.YTD_PS_MOVEMENT_QTY1, 0)
                        ,NVL(CurPrevDistLayer.YTD_PS_MOVEMENT_QTY2, 0)
                        ,NVL(CurPrevDistLayer.YTD_OL_MOV_QTY1, 0)
                        ,NVL(CurPrevDistLayer.YTD_OL_MOV_QTY2, 0)
                        ,NVL(CurPrevDistLayer.YTD_UL_MOV_QTY1, 0)
                        ,NVL(CurPrevDistLayer.YTD_UL_MOV_QTY2, 0)
                        ,CurPrevDistLayer.FIN_PS_CRE_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_CREDIT_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_DEBIT_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_INT_CRE_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_INT_DEB_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_PS_CREDIT_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_PS_DEBIT_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_CREDIT_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_DEBIT_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_INT_CRE_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_INT_DEB_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_PS_CREDIT_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_PS_DEBIT_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_INT_PS_CR_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_INT_PS_CR_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_INT_PS_CR_COST_OBJECT
                        ,CurPrevDistLayer.FIN_INT_PS_CR_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_INT_PS_CR_POSTING_KEY
                        ,CurPrevDistLayer.FIN_INT_PS_DR_COST_OBJ_TYPE
                        ,CurPrevDistLayer.FIN_INT_PS_DR_ACCOUNT_ID
                        ,CurPrevDistLayer.FIN_INT_PS_DR_COST_OBJECT
                        ,CurPrevDistLayer.FIN_INT_PS_DR_GL_ACCOUNT
                        ,CurPrevDistLayer.FIN_INT_PS_DR_POSTING_KEY
                        ,CurPrevDistLayer.DESCRIPTION
                        ,CurPrevDistLayer.COMMENTS
                    );
                END LOOP;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
            END IF;

        END LOOP; -- Copy "Layers"
    END IF; -- Check wheter UL Position is greater than zero

    -- Find previous layer which is not HISTORIC
    FOR CurPrevLayer IN c_max_prev_year_code(p_object_id, p_daytime) LOOP
        ln_max_prev_year_code := CurPrevLayer.year_code;
    END LOOP;

    -- If previous layer found then switch the opening and movement
    IF (ln_max_prev_year_code IS NOT NULL) THEN
        lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, ln_max_prev_year_code);

        -- Inv Valuation
        -- The decode statement is to set only Underlift or Overlift, both openings can not have values
        UPDATE inv_valuation iv
        SET iv.ul_opening_pos_qty1 = DECODE(SIGN(iv.ul_closing_pos_qty1), 1, iv.ul_closing_pos_qty1, 0)
           ,iv.ul_opening_pos_qty2 = DECODE(SIGN(iv.ul_closing_pos_qty2), 1, iv.ul_closing_pos_qty2, 0)
           ,iv.ol_opening_qty1 = DECODE(SIGN(iv.ol_closing_pos_qty1), -1, iv.ol_closing_pos_qty1, 0)
           ,iv.ol_opening_qty2 = DECODE(SIGN(iv.ol_closing_pos_qty2), -1, iv.ol_closing_pos_qty2, 0)
           ,iv.ps_opening_qty1 = iv.ps_closing_pos_qty1
           ,iv.ps_opening_qty2 = iv.ps_closing_pos_qty2
        WHERE
            object_id = p_object_id
            AND daytime = p_daytime
            AND year_code = ln_max_prev_year_code;

        -- Inv Dist Valuation
        -- The decode statement is to set only Underlift or Overlift, both openings can not have values
        -- the decode must use the valuation state and not the field state since they can be different
        UPDATE inv_dist_valuation idv
        SET idv.opening_ul_position_qty1 = DECODE(SIGN(ec_inv_valuation.ul_closing_pos_qty1(object_id, daytime, year_code)), 1, idv.closing_ul_position_qty1, 0)
           ,idv.opening_ul_position_qty2 = DECODE(SIGN(ec_inv_valuation.ul_closing_pos_qty2(object_id, daytime, year_code)), 1, idv.closing_ul_position_qty2, 0)
           ,idv.opening_ol_position_qty1 = DECODE(SIGN(ec_inv_valuation.ol_closing_pos_qty1(object_id, daytime, year_code)), -1, idv.closing_ol_position_qty1, 0)
           ,idv.opening_ol_position_qty2 = DECODE(SIGN(ec_inv_valuation.ol_closing_pos_qty2(object_id, daytime, year_code)), -1, idv.closing_ol_position_qty2, 0)
           ,idv.opening_ps_position_qty1 = idv.closing_ps_position_qty1
           ,idv.opening_ps_position_qty2 = idv.closing_ps_position_qty2
        WHERE
            object_id = p_object_id
            AND daytime = p_daytime
            AND year_code = ln_max_prev_year_code;

        -- Inv Valuation
        -- Movement on layers is initially always 0
        UPDATE inv_valuation iv
        SET  iv.ytd_ul_mov_qty1 = 0
            ,iv.ytd_ul_mov_qty2 = 0
            ,iv.ytd_ol_mov_qty1 = 0
            ,iv.ytd_ol_mov_qty2 = 0
            ,iv.ytd_ps_mov_qty1 = 0
            ,iv.ytd_ps_mov_qty2 = 0
        WHERE
            object_id = p_object_id
            AND daytime = p_daytime
            AND year_code = ln_max_prev_year_code;

        -- Inv Dist Valuation
        -- Movement on layers is initially always 0
        UPDATE inv_dist_valuation idv
        SET idv.ytd_ul_mov_qty1 = 0
           ,idv.ytd_ul_mov_qty2 = 0
           ,idv.ytd_ol_mov_qty1 = 0
           ,idv.ytd_ol_mov_qty2 = 0
           ,idv.ytd_ps_movement_qty1 = 0
           ,idv.ytd_ps_movement_qty2 = 0
           ,idv.ytd_movement_qty1 = 0
           ,idv.ytd_movement_qty2 = 0
        WHERE
            object_id = p_object_id
            AND daytime = p_daytime
            AND year_code = ln_max_prev_year_code;

    END IF;

    -- Layer with CODE = TRUNC(daytime,'YYYY') is treated specially, the opening is set to zero
    -- and the closing is set to the opening + movement

    -- If opening balance on pre recent is zero then assume new layer, update the pre recent layer
    -- New "Layer" present
    --
    -- TODO: FIX CODE=trunc(DAYTIME,YYYY)
    --
    IF (p_ytd_movement_qty1 < 0) THEN -- UNDERLIFT with Draw down
        -- The movement is negative and we are using the "underlift" on layers

        ln_movement_qty1 := p_ytd_movement_qty1;
        ln_movement_left_qty1 := p_ytd_movement_qty1;

        ln_movement_qty2 := p_ytd_movement_qty2;
        ln_movement_left_qty2 := p_ytd_movement_qty2;

        ln_movement_ps_qty1 := p_ytd_ps_mov_qty1;
        ln_movement_ps_left_qty1 := p_ytd_ps_mov_qty1;

        ln_movement_ps_qty2 := p_ytd_ps_mov_qty2;
        ln_movement_ps_left_qty2 := p_ytd_ps_mov_qty2;

        -- Looping over the layers descending, the order they will be used in.. LIFO :)
        FOR CurLayer IN c_layer_desc(p_object_id, p_daytime, p_valuation_method) LOOP
            ltab_inv_layer.extend;
            -- Key
            ltab_inv_layer(ltab_inv_layer.last).year_code := CurLayer.year_code;
            ltab_inv_layer(ltab_inv_layer.last).object_id := CurLayer.object_id;
            ltab_inv_layer(ltab_inv_layer.last).daytime := CurLayer.daytime;

/* DEBUG
   Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Movement Left Before: ' || ln_movement_left_qty1);
 */
            -- Values
            -- Opening values
            ltab_inv_layer(ltab_inv_layer.last).UL_OPENING_POS_QTY1 := CurLayer.UL_OPENING_POS_QTY1;
            ltab_inv_layer(ltab_inv_layer.last).OL_OPENING_QTY1 := CurLayer.OL_OPENING_QTY1;
            ltab_inv_layer(ltab_inv_layer.last).PS_OPENING_QTY1 := CurLayer.PS_OPENING_QTY1;

            ltab_inv_layer(ltab_inv_layer.last).UL_OPENING_POS_QTY2 := CurLayer.UL_OPENING_POS_QTY2;
            ltab_inv_layer(ltab_inv_layer.last).OL_OPENING_QTY2 := CurLayer.OL_OPENING_QTY2;
            ltab_inv_layer(ltab_inv_layer.last).PS_OPENING_QTY2 := CurLayer.PS_OPENING_QTY2;

            ln_movement_qty1 := ln_movement_left_qty1 + NVL(CurLayer.OL_OPENING_QTY1, 0) + NVL(CurLayer.UL_OPENING_POS_QTY1, 0);
            ln_movement_qty2 := ln_movement_left_qty2 + NVL(CurLayer.OL_OPENING_QTY2, 0) + NVL(CurLayer.UL_OPENING_POS_QTY2, 0);

            ln_movement_ps_qty1 := ln_movement_ps_left_qty1 + CurLayer.PS_OPENING_QTY1;
            ln_movement_ps_qty2 := ln_movement_ps_left_qty2 + CurLayer.PS_OPENING_QTY2;

            IF (ln_movement_left_qty1 < 0) THEN -- We still have something left in the whole layer
                IF (ln_movement_qty1 <= 0) THEN -- Underlift "eating" the whole layer
/* DEBUG
   Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Underlift "eating" the whole layer: ' || p_daytime || ' ' ||CurLayer.UL_OPENING_POS_QTY1 * -1);
 */
                    -- Movement
                    ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY1 := CurLayer.UL_OPENING_POS_QTY1 * -1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY1  := CurLayer.UL_OPENING_POS_QTY1 * -1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY1 := CurLayer.PS_OPENING_QTY1 * -1;

                    ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY2 := CurLayer.UL_OPENING_POS_QTY2 * -1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY2  := CurLayer.UL_OPENING_POS_QTY2 * -1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY2 := CurLayer.PS_OPENING_QTY2 * -1;

                    -- Closing
                    ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY1 := 0;

                    ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY2 := 0;

                ELSIF (ln_movement_qty1 > 0) THEN -- Underlift "eating" a bit of the layer
/* DEBUG
   Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Underlift "eating" a bit of the layer: ' || p_daytime || ' ' || ln_movement_left_qty1);
 */
                    -- Movement
                    ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY1 := ln_movement_left_qty1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY1  := ln_movement_left_qty1;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY1 := ln_movement_ps_left_qty1;

                    ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY2 := ln_movement_left_qty2;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY2  := ln_movement_left_qty2;
                    ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY2 := ln_movement_ps_left_qty2;

                    -- Closing
                    ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY1 := CurLayer.UL_OPENING_POS_QTY1 + ln_movement_left_qty1;
                    ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY1 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY1 := CurLayer.PS_OPENING_QTY1 + ln_movement_ps_left_qty1;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY1 := CurLayer.UL_OPENING_POS_QTY1 + ln_movement_left_qty1 + NVL(CurLayer.PS_OPENING_QTY1 + ln_movement_ps_left_qty1, 0);

                    ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY2 := CurLayer.UL_OPENING_POS_QTY2 + ln_movement_left_qty2;
                    ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY2 := 0;
                    ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY2 := CurLayer.PS_OPENING_QTY2 + ln_movement_ps_left_qty2;
                    ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY2 := CurLayer.UL_OPENING_POS_QTY2 + ln_movement_left_qty2 + NVL(CurLayer.PS_OPENING_QTY2 + ln_movement_ps_left_qty2, 0);

                END IF;
            ELSE -- No movement left, set movement to zero, layer not used
                -- Movement
                ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY1 := 0;
                ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY1 := 0;
                ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY1  := 0;
                ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY1 := 0;

                ltab_inv_layer(ltab_inv_layer.last).YTD_UL_MOV_QTY2 := 0;
                ltab_inv_layer(ltab_inv_layer.last).YTD_OL_MOV_QTY2 := 0;
                ltab_inv_layer(ltab_inv_layer.last).TOTAL_MOV_QTY2  := 0;
                ltab_inv_layer(ltab_inv_layer.last).YTD_PS_MOV_QTY2 := 0;

                -- Closing
                ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY1 := CurLayer.UL_OPENING_POS_QTY1;
                ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY1 := CurLayer.OL_OPENING_QTY1;
                ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY1 := CurLayer.PS_OPENING_QTY1;
                ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY1 := NVL(CurLayer.UL_OPENING_POS_QTY1, 0) + NVL(CurLayer.OL_OPENING_QTY1, 0) + NVL(CurLayer.PS_OPENING_QTY1, 0);

                ltab_inv_layer(ltab_inv_layer.last).UL_CLOSING_POS_QTY2 := CurLayer.UL_OPENING_POS_QTY2;
                ltab_inv_layer(ltab_inv_layer.last).OL_CLOSING_POS_QTY2 := CurLayer.OL_OPENING_QTY2;
                ltab_inv_layer(ltab_inv_layer.last).PS_CLOSING_POS_QTY2 := CurLayer.PS_OPENING_QTY2;
                ltab_inv_layer(ltab_inv_layer.last).TOTAL_CLOSING_POS_QTY2 := NVL(CurLayer.UL_OPENING_POS_QTY2, 0) + NVL(CurLayer.OL_OPENING_QTY2, 0) + NVL(CurLayer.PS_OPENING_QTY2, 0);

            END IF;

            ln_movement_left_qty1 :=  ln_movement_left_qty1 + CurLayer.UL_OPENING_POS_QTY1;

            ln_movement_left_qty2 :=  ln_movement_left_qty2 + CurLayer.UL_OPENING_POS_QTY2;

            ln_movement_ps_left_qty1 :=  ln_movement_ps_left_qty1 + CurLayer.PS_OPENING_QTY1;

            ln_movement_ps_left_qty2 :=  ln_movement_ps_left_qty2 + CurLayer.PS_OPENING_QTY2;

        END LOOP;

        -- We could potentially have Overlift in previous closing
        lrec_prev_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, ld_pre_recent, ln_max_year_code);

        IF ( p_process_historic <> 'TRUE' AND ln_movement_left_qty1 < 0 ) THEN
            -- Overlift, there are still negative movement and all the layers are beeing used
            -- Update on "Current" Layer, layer where code equals daytime
            -- ======================
            -- OVERLIFT
            -- ======================
            UPDATE inv_valuation iv
            SET
              UL_OPENING_POS_QTY1 = 0-- Opening
              ,OL_OPENING_QTY1 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0)
              ,PS_OPENING_QTY1 = NVL(lrec_prev_inv_valuation.ps_closing_pos_qty1, 0)
              ,UL_OPENING_POS_QTY2 = 0
              ,OL_OPENING_QTY2 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0)
              ,PS_OPENING_QTY2 = NVL(lrec_prev_inv_valuation.ps_closing_pos_qty2, 0)
              ,YTD_UL_MOV_QTY1 = 0 -- Movement
              ,YTD_OL_MOV_QTY1 = ln_movement_left_qty1
              ,YTD_PS_MOV_QTY1 = ln_movement_ps_left_qty1
              ,TOTAL_MOV_QTY1 = ln_movement_left_qty1 + NVL(ln_movement_ps_left_qty1, 0)
              ,YTD_UL_MOV_QTY2 = 0
              ,YTD_OL_MOV_QTY2 = ln_movement_left_qty2
              ,YTD_PS_MOV_QTY2 = ln_movement_ps_left_qty2
              ,TOTAL_MOV_QTY2 = ln_movement_left_qty2 + NVL(ln_movement_ps_left_qty2, 0)
              ,UL_CLOSING_POS_QTY1 = 0 -- Closing
              ,OL_CLOSING_POS_QTY1 = ln_movement_left_qty1 + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0)
              ,PS_CLOSING_POS_QTY1 = NVL(lrec_prev_inv_valuation.ps_closing_pos_qty1, 0) + ln_movement_ps_left_qty1
              ,TOTAL_CLOSING_POS_QTY1 = ln_movement_left_qty1 + NVL(ln_movement_ps_left_qty1, 0)
              ,UL_CLOSING_POS_QTY2 = 0
              ,OL_CLOSING_POS_QTY2 = ln_movement_left_qty2 + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0)
              ,PS_CLOSING_POS_QTY2 = NVL(lrec_prev_inv_valuation.ps_closing_pos_qty2, 0) + ln_movement_ps_left_qty2
              ,TOTAL_CLOSING_POS_QTY2 = ln_movement_left_qty2 + NVL(ln_movement_ps_left_qty2, 0)
--              ,historic = lv2_historic
            WHERE
                object_id = p_object_id
                AND year_code = TO_CHAR(p_daytime, 'YYYY')
                AND daytime = p_daytime;

/* DEBUG
Ecdp_Dynsql.WriteTempText('INV_LAYER_PROCESS', 'Overlift Movement Left: ' || ln_movement_left_qty1 );
 */
        ELSIF (p_process_historic <> 'TRUE') THEN
           -- We have not used all the underlift on layers, current layers movement is set to zero
            -- ======================
            -- UNDERLIFT
            -- ======================
            UPDATE inv_valuation iv
            SET
              UL_OPENING_POS_QTY1 = 0-- Opening
              ,OL_OPENING_QTY1 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0)
              ,PS_OPENING_QTY1 = 0
              ,UL_OPENING_POS_QTY2 = 0
              ,OL_OPENING_QTY2 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0)
              ,PS_OPENING_QTY2 = 0
              ,YTD_UL_MOV_QTY1 = 0 -- Movement
              ,YTD_OL_MOV_QTY1 = 0
              ,YTD_PS_MOV_QTY1 = 0
              ,TOTAL_MOV_QTY1 = 0
              ,YTD_UL_MOV_QTY2 = 0
              ,YTD_OL_MOV_QTY2 = 0
              ,YTD_PS_MOV_QTY2 = 0
              ,TOTAL_MOV_QTY2 = 0
              ,UL_CLOSING_POS_QTY1 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0) -- Closing
              ,OL_CLOSING_POS_QTY1 = 0
              ,PS_CLOSING_POS_QTY1 = 0
              ,TOTAL_CLOSING_POS_QTY1 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0)
              ,UL_CLOSING_POS_QTY2 = 0
              ,OL_CLOSING_POS_QTY2 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0)
              ,PS_CLOSING_POS_QTY2 = 0
              ,TOTAL_CLOSING_POS_QTY2 = NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0)
--              ,historic = lv2_historic
            WHERE
                object_id = p_object_id
                AND year_code = TO_CHAR(p_daytime, 'YYYY')
                AND daytime = p_daytime;

        END IF;

        -- Layer update, the layers processed in the descending loop will be updated here
        FOR i IN 1..ltab_inv_layer.count LOOP
            UPDATE inv_valuation iv
            SET
              UL_OPENING_POS_QTY1 = ltab_inv_layer(i).UL_OPENING_POS_QTY1
              ,OL_OPENING_QTY1 = ltab_inv_layer(i).OL_OPENING_QTY1
              ,PS_OPENING_QTY1 = ltab_inv_layer(i).PS_OPENING_QTY1
              ,UL_OPENING_POS_QTY2 = ltab_inv_layer(i).UL_OPENING_POS_QTY2
              ,OL_OPENING_QTY2 = ltab_inv_layer(i).OL_OPENING_QTY2
              ,PS_OPENING_QTY2 = ltab_inv_layer(i).PS_OPENING_QTY2
              ,YTD_UL_MOV_QTY1 = ltab_inv_layer(i).YTD_UL_MOV_QTY1
              ,YTD_OL_MOV_QTY1 = ltab_inv_layer(i).YTD_OL_MOV_QTY1
              ,YTD_PS_MOV_QTY1 = ltab_inv_layer(i).YTD_PS_MOV_QTY1
              ,TOTAL_MOV_QTY1 = ltab_inv_layer(i).TOTAL_MOV_QTY1
              ,YTD_UL_MOV_QTY2 = ltab_inv_layer(i).YTD_UL_MOV_QTY2
              ,YTD_OL_MOV_QTY2 = ltab_inv_layer(i).YTD_OL_MOV_QTY2
              ,YTD_PS_MOV_QTY2 = ltab_inv_layer(i).YTD_PS_MOV_QTY2
              ,TOTAL_MOV_QTY2 = ltab_inv_layer(i).TOTAL_MOV_QTY2
              ,UL_CLOSING_POS_QTY1 = ltab_inv_layer(i).UL_CLOSING_POS_QTY1
              ,OL_CLOSING_POS_QTY1 = ltab_inv_layer(i).OL_CLOSING_POS_QTY1
              ,PS_CLOSING_POS_QTY1 = ltab_inv_layer(i).PS_CLOSING_POS_QTY1
              ,TOTAL_CLOSING_POS_QTY1 = ltab_inv_layer(i).TOTAL_CLOSING_POS_QTY1
              ,UL_CLOSING_POS_QTY2 = ltab_inv_layer(i).UL_CLOSING_POS_QTY2
              ,OL_CLOSING_POS_QTY2 = ltab_inv_layer(i).OL_CLOSING_POS_QTY2
              ,PS_CLOSING_POS_QTY2 = ltab_inv_layer(i).PS_CLOSING_POS_QTY2
              ,TOTAL_CLOSING_POS_QTY2 = ltab_inv_layer(i).TOTAL_CLOSING_POS_QTY2
--               ,historic = lv2_historic
            WHERE
                object_id = p_object_id
                AND year_code = ltab_inv_layer(i).year_code
                AND daytime = p_daytime;

            -- We need to update the dist level as well
            IF ((NVL(ltab_inv_layer(i).UL_OPENING_POS_QTY1, 0) + NVL(ltab_inv_layer(i).OL_OPENING_QTY1, 0) + NVL(ltab_inv_layer(i).PS_OPENING_QTY1, 0) +
             NVL(ltab_inv_layer(i).YTD_UL_MOV_QTY1, 0) + NVL(ltab_inv_layer(i).YTD_OL_MOV_QTY1, 0) + NVL(ltab_inv_layer(i).YTD_PS_MOV_QTY1, 0)) = 0) THEN
                ProcessInvDistLayer(p_object_id, p_daytime, ltab_inv_layer(i).year_code, p_ytd_movement_qty1, 'NO3', p_user, p_valuation_method, p_process_historic, TRUE);
            ELSE
                ProcessInvDistLayer(p_object_id, p_daytime, ltab_inv_layer(i).year_code, p_ytd_movement_qty1, 'NO3', p_user, p_valuation_method, p_process_historic, FALSE);
            END IF;

        END LOOP;

    ELSE -- Build up, underlift, IF (p_ytd_movement_qty1 < 0) THEN
            -- ======================
            -- UNDERLIFT
            -- ======================
        -- Set the build up to movement, special handling for recent layer

        -- We could potentially have Overlift in previous closing
        lrec_prev_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, ld_pre_recent, ln_max_year_code);


        --=====================
        -- Opening
        --=====================
        lrec_inv_valuation.ol_opening_qty1 := NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0);
        lrec_inv_valuation.ol_opening_qty2 := NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0);
        lrec_inv_valuation.ps_opening_qty1 := NVL(lrec_prev_inv_valuation.ps_closing_pos_qty1, 0);
        lrec_inv_valuation.ps_opening_qty2 := NVL(lrec_prev_inv_valuation.ps_closing_pos_qty2, 0);

        --=====================
        -- Movement
        --=====================
        IF ((lrec_inv_valuation.ol_opening_qty1 + p_ytd_movement_qty1) > 0 ) THEN -- Underlift
            lrec_inv_valuation.ytd_ul_mov_qty1 := p_ytd_movement_qty1 + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0);
            lrec_inv_valuation.ytd_ul_mov_qty2 := p_ytd_movement_qty2 + NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0);
            lrec_inv_valuation.ytd_ol_mov_qty1 := NVL(lrec_prev_inv_valuation.ol_closing_pos_qty1, 0) * -1;
            lrec_inv_valuation.ytd_ol_mov_qty2 := NVL(lrec_prev_inv_valuation.ol_closing_pos_qty2, 0) * -1;
        ELSE -- Overlift
            lrec_inv_valuation.ytd_ul_mov_qty1 := 0;
            lrec_inv_valuation.ytd_ul_mov_qty2 := 0;
            lrec_inv_valuation.ytd_ol_mov_qty1 := p_ytd_movement_qty1;
            lrec_inv_valuation.ytd_ol_mov_qty2 := p_ytd_movement_qty2;
        END IF;
        lrec_inv_valuation.ytd_ps_mov_qty1 := p_ytd_ps_mov_qty1;
        lrec_inv_valuation.ytd_ps_mov_qty2 := p_ytd_ps_mov_qty2;

        lrec_inv_valuation.total_mov_qty1 := lrec_inv_valuation.ytd_ul_mov_qty1 + lrec_inv_valuation.ytd_ol_mov_qty1 + NVL(lrec_inv_valuation.ytd_ps_mov_qty1, 0);
        lrec_inv_valuation.total_mov_qty2 := lrec_inv_valuation.ytd_ul_mov_qty2 + lrec_inv_valuation.ytd_ol_mov_qty2 + NVL(lrec_inv_valuation.ytd_ps_mov_qty2, 0);

        --=====================
        -- Closing
        --=====================
        lrec_inv_valuation.ul_closing_pos_qty1 := lrec_inv_valuation.ytd_ul_mov_qty1;
        lrec_inv_valuation.ul_closing_pos_qty2 := lrec_inv_valuation.ytd_ul_mov_qty2;
        lrec_inv_valuation.ol_closing_pos_qty1 := lrec_inv_valuation.ol_opening_qty1 + lrec_inv_valuation.ytd_ol_mov_qty1;
        lrec_inv_valuation.ol_closing_pos_qty2 := lrec_inv_valuation.ol_opening_qty2 + lrec_inv_valuation.ytd_ol_mov_qty2;
        lrec_inv_valuation.ps_closing_pos_qty1 := lrec_inv_valuation.ps_opening_qty1 + lrec_inv_valuation.ytd_ps_mov_qty1;
        lrec_inv_valuation.ps_closing_pos_qty2 := lrec_inv_valuation.ps_opening_qty2 + lrec_inv_valuation.ytd_ps_mov_qty2;

        lrec_inv_valuation.total_closing_pos_qty1 := lrec_inv_valuation.ul_closing_pos_qty1 + lrec_inv_valuation.ol_closing_pos_qty1 + NVL(lrec_inv_valuation.ps_closing_pos_qty1, 0);
        lrec_inv_valuation.total_closing_pos_qty2 := lrec_inv_valuation.ul_closing_pos_qty2 + lrec_inv_valuation.ol_closing_pos_qty2 + NVL(lrec_inv_valuation.ps_closing_pos_qty2, 0);

            -- ======================
            -- UNDERLIFT
            -- ======================
        -- Set the build up to movement, special handling for recent layer
            UPDATE inv_valuation iv
            SET
              UL_OPENING_POS_QTY1 = 0-- Opening
              ,OL_OPENING_QTY1 = lrec_inv_valuation.ol_opening_qty1
              ,PS_OPENING_QTY1 = lrec_inv_valuation.ps_opening_qty1
              ,UL_OPENING_POS_QTY2 = 0
              ,OL_OPENING_QTY2 = lrec_inv_valuation.ol_opening_qty2
              ,PS_OPENING_QTY2 = lrec_inv_valuation.ps_opening_qty2
              ,YTD_UL_MOV_QTY1 = lrec_inv_valuation.ytd_ul_mov_qty1 -- Movement
              ,YTD_OL_MOV_QTY1 = lrec_inv_valuation.ytd_ol_mov_qty1
              ,YTD_PS_MOV_QTY1 = lrec_inv_valuation.ytd_ps_mov_qty1
              ,TOTAL_MOV_QTY1 = lrec_inv_valuation.total_mov_qty1
              ,YTD_UL_MOV_QTY2 = lrec_inv_valuation.ytd_ul_mov_qty2
              ,YTD_OL_MOV_QTY2 = lrec_inv_valuation.ytd_ol_mov_qty2
              ,YTD_PS_MOV_QTY2 = lrec_inv_valuation.ytd_ps_mov_qty2
              ,TOTAL_MOV_QTY2 = lrec_inv_valuation.total_mov_qty2
              ,UL_CLOSING_POS_QTY1 = lrec_inv_valuation.ul_closing_pos_qty1 -- Closing
              ,OL_CLOSING_POS_QTY1 = lrec_inv_valuation.ol_closing_pos_qty1
              ,PS_CLOSING_POS_QTY1 = lrec_inv_valuation.ps_closing_pos_qty1
              ,TOTAL_CLOSING_POS_QTY1 = lrec_inv_valuation.total_closing_pos_qty1
              ,UL_CLOSING_POS_QTY2 = lrec_inv_valuation.ul_closing_pos_qty2
              ,OL_CLOSING_POS_QTY2 = lrec_inv_valuation.ol_closing_pos_qty2
              ,PS_CLOSING_POS_QTY2 = lrec_inv_valuation.ps_closing_pos_qty2
              ,TOTAL_CLOSING_POS_QTY2 = lrec_inv_valuation.total_closing_pos_qty2
            WHERE
                object_id = p_object_id
                AND year_code = TO_CHAR(p_daytime, 'YYYY')
                AND daytime = p_daytime;

    END IF;

    ProcessInvDistLayer(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'), p_ytd_movement_qty1, 'NO1', p_user, p_valuation_method, p_process_historic, FALSE);

    -- Remove empty layers if valuation method is LIFO, LIFO_INTERIM has LIFO as valuation method for december..
    -- December is the "final" posting and all layers beeing used are deleted
    IF (p_valuation_method = 'LIFO' OR (to_char(p_daytime,'MM') = '12' AND p_valuation_method = 'LIFO_INTERIM')) THEN

        DELETE FROM
            inv_dist_valuation idv
        WHERE
            daytime = p_daytime
            AND object_id = p_object_id
            AND ec_inv_valuation.ul_closing_pos_qty1(object_id, daytime, year_code) = 0
            AND TO_NUMBER(year_code) < TO_NUMBER(TO_CHAR(p_daytime, 'YYYY'))
            AND ('LIFO' = p_valuation_method OR p_valuation_method = 'LIFO_INTERIM')
        ;

        DELETE FROM
            inv_valuation iv
        WHERE
            daytime = p_daytime
            AND object_id = p_object_id
            AND NVL(UL_CLOSING_POS_QTY1, 0) = 0
            AND TO_NUMBER(year_code) < TO_NUMBER(TO_CHAR(p_daytime, 'YYYY'))
            AND ('LIFO' = p_valuation_method OR p_valuation_method = 'LIFO_INTERIM')
        ;

    END IF;

    ltab_inv_layer.delete;

END ProcessInvLayer;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ProcessInvDistLayer
-- Description    :
-------------------------------------------------------------------------------------------------
PROCEDURE ProcessInvDistLayer(p_object_id VARCHAR2
                         ,p_daytime DATE
                         ,p_year_code VARCHAR2
                         ,p_ytd_movement_qty1 NUMBER
                         ,p_call_tag VARCHAR2
                         ,p_user VARCHAR2
                         ,p_valuation_method VARCHAR2
                         ,p_process_historic VARCHAR2
                         ,p_used_whole_layer BOOLEAN)
IS

CURSOR c_dist(cp_object_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2) IS
  SELECT dist_id
  FROM inv_dist_valuation
  WHERE object_id = cp_object_id
  AND   daytime = cp_daytime
  AND   year_code = cp_year_code;

CURSOR c_sum_mov_layer(cp_object_id VARCHAR2, cp_daytime DATE, cp_dist_id VARCHAR2) IS
SELECT
    SUM(idv.ytd_ul_mov_qty1) ytd_ul_mov_qty1
    ,SUM(idv.ytd_ul_mov_qty2) ytd_ul_mov_qty2
FROM
    inv_dist_valuation idv
    WHERE object_id = cp_object_id
    AND daytime = cp_daytime
    AND year_code <> TO_CHAR(cp_daytime, 'YYYY')
    AND dist_id = cp_dist_id;

CURSOR c_layer_dist_mov(cp_object_id VARCHAR2, cp_daytime DATE, cp_dist_id VARCHAR2, cp_year_code VARCHAR2) IS
SELECT idv.*
FROM
    inv_dist_valuation idv
WHERE
  object_id = cp_object_id
  AND daytime = cp_daytime
  AND to_char(daytime, 'YYYY') <> year_code
  AND to_number(year_code) > to_number(cp_year_code)
  AND dist_id = cp_dist_id;

CURSOR c_layer_mov(cp_object_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2) IS
SELECT iv.*
FROM
    inv_valuation iv
WHERE
  object_id = cp_object_id
  AND daytime = cp_daytime
  AND to_char(daytime, 'YYYY') <> year_code
  AND to_number(year_code) > to_number(cp_year_code)
;

lrec_inv_valuation inv_valuation%ROWTYPE;

lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;

ytd_ul_mov_qty1 NUMBER;

sum_ul_mov_qty1 NUMBER;
sum_ul_mov_qty2 NUMBER;

ltab_as_is  EcDp_Unit.t_uomtable;
ltab_ppa    EcDp_Unit.t_uomtable;
ln_total_mov_qty1 NUMBER;
ln_total_mov_qty2 NUMBER;
ln_ppa_total_mov_qty1 NUMBER;
ln_ppa_total_mov_qty2 NUMBER;

ln_tot_mov_qty1 NUMBER;

BEGIN

    lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, p_year_code);

    ln_tot_mov_qty1 := p_ytd_movement_qty1;
/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code ||
      ' 001 ln_tot_mov_qty1: ' || ln_tot_mov_qty1
      );
*/
    FOR CurLayerMov IN c_layer_mov(p_object_id, p_daytime, p_year_code) LOOP
        ln_tot_mov_qty1 := ln_tot_mov_qty1 - CurLayerMov.Ytd_Ul_Mov_Qty1;
    END LOOP;

/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code ||
      ' 002 ln_tot_mov_qty1: ' || ln_tot_mov_qty1
      );
*/
    FOR CurDist IN c_dist(p_object_id, p_daytime, p_year_code) LOOP

        IF  (NVL(lrec_inv_valuation.ul_opening_pos_qty1,0) <> 0) THEN
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'Update Dist UL Opening:' || ec_inv_dist_valuation.opening_ul_position_qty1(p_object_id, CurDist.Dist_Id, p_daytime, p_year_code)
       || ' ValUlOpening: ' ||  lrec_inv_valuation.ul_opening_pos_qty1 || ' ValYTDMovement: ' || lrec_inv_valuation.ytd_ul_mov_qty1 );
*/

            lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id, CurDist.Dist_Id, p_daytime, to_char(p_daytime, 'YYYY'));

            IF (p_used_whole_layer = TRUE) THEN -- Setting the movement to negative of the opening
                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := ec_inv_dist_valuation.opening_ul_position_qty1(p_object_id, CurDist.Dist_Id, p_daytime, p_year_code) * -1;
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := ec_inv_dist_valuation.opening_ul_position_qty2(p_object_id, CurDist.Dist_Id, p_daytime, p_year_code) * -1;
                lrec_inv_dist_valuation.ytd_ol_mov_qty1 := ec_inv_dist_valuation.opening_ol_position_qty1(p_object_id, CurDist.Dist_Id, p_daytime, p_year_code) * -1;
                lrec_inv_dist_valuation.ytd_ol_mov_qty2 := ec_inv_dist_valuation.opening_ol_position_qty2(p_object_id, CurDist.Dist_Id, p_daytime, p_year_code) * -1;
                lrec_inv_dist_valuation.ytd_ps_movement_qty1 := 0;
                lrec_inv_dist_valuation.ytd_ps_movement_qty2 := 0;
/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code ||
      ' 000 lrec_inv_dist_valuation.ytd_ul_mov_qty1: ' || lrec_inv_dist_valuation.ytd_ul_mov_qty1
      );
*/
            ELSE -- Have not used the whole layer, so will calculate the field split

            IF (ln_tot_mov_qty1 < 0) THEN
                -- Find AS IS movement
                ltab_as_is := GetActualPeriodDistMovement(CurDist.Dist_Id, p_object_id, p_daytime);
                ln_total_mov_qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_as_is, ec_inventory_version.uom1_code(p_object_id, p_daytime, '<='), p_daytime, CurDist.Dist_Id),0);
                ln_total_mov_qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_as_is, ec_inventory_version.uom2_code(p_object_id, p_daytime, '<='), p_daytime, CurDist.Dist_Id),0);

                -- Find Prior Period Adjustment
                ltab_ppa := GetDistPriorPeriodAdjustment(CurDist.Dist_Id, p_object_id, p_daytime);
                ln_ppa_total_mov_qty1 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa, ec_inventory_version.uom1_code(p_object_id, p_daytime, '<='), p_daytime, CurDist.Dist_Id),0);
                ln_ppa_total_mov_qty2 := Nvl(EcDp_Revn_Unit.GetUOMSetQty(ltab_ppa, ec_inventory_version.uom2_code(p_object_id, p_daytime, '<='), p_daytime, CurDist.Dist_Id),0);

                lrec_inv_dist_valuation.ytd_ul_mov_qty1 := ln_total_mov_qty1 + NVL(ln_ppa_total_mov_qty1, 0);
                lrec_inv_dist_valuation.ytd_ul_mov_qty2 := ln_total_mov_qty2 + NVL(ln_ppa_total_mov_qty2, 0);
/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code ||
      ' 111 ln_total_mov_qty1: ' || ln_total_mov_qty1 ||
      ' ln_ppa_total_mov_qty1: ' || ln_ppa_total_mov_qty1 ||
      ' lrec_inv_dist_valuation.ytd_ul_mov_qty1:' || lrec_inv_dist_valuation.ytd_ul_mov_qty1
      );
*/

                 lrec_inv_dist_valuation.ytd_ol_mov_qty1 := 0;
                 lrec_inv_dist_valuation.ytd_ol_mov_qty2 := 0;
                 lrec_inv_dist_valuation.ytd_ps_movement_qty1 := 0;
                 lrec_inv_dist_valuation.ytd_ps_movement_qty2 := 0;

                FOR CurLayerDistMov IN c_layer_dist_mov(p_object_id, p_daytime, CurDist.Dist_Id, p_year_code) LOOP
                    lrec_inv_dist_valuation.ytd_ul_mov_qty1 := lrec_inv_dist_valuation.ytd_ul_mov_qty1 - NVL(CurLayerDistMov.ytd_ul_mov_qty1, 0);
                    lrec_inv_dist_valuation.ytd_ul_mov_qty2 := lrec_inv_dist_valuation.ytd_ul_mov_qty2 - NVL(CurLayerDistMov.ytd_ul_mov_qty2, 0);

/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code ||
 ' 222 YEAR_CODE: ' || CurLayerDistMov.year_code ||
      ' CurLayerDistMov.ytd_ul_mov_qty1: ' || CurLayerDistMov.ytd_ul_mov_qty1 );
*/
                END LOOP;
            ELSE
                    lrec_inv_dist_valuation.ytd_ul_mov_qty1 := 0;
                    lrec_inv_dist_valuation.ytd_ul_mov_qty2 := 0;
                    lrec_inv_dist_valuation.ytd_ol_mov_qty1 := 0;
                    lrec_inv_dist_valuation.ytd_ol_mov_qty2 := 0;
                    lrec_inv_dist_valuation.ytd_ps_movement_qty1 := 0;
                    lrec_inv_dist_valuation.ytd_ps_movement_qty2 := 0;
            END IF;
            END IF;
/*
ecdp_dynsql.WriteTempText('INV', 'DIST layer QTY Daytime: ' || p_daytime || ' YearCode: ' || p_year_code
          || ' 333 lrec_inv_dist_valuation.ytd_ul_mov_qty1:' || lrec_inv_dist_valuation.ytd_ul_mov_qty1
          || ' lrec_inv_dist_valuation.ytd_ul_mov_qty2: ' || lrec_inv_dist_valuation.ytd_ul_mov_qty2
          || ' lrec_inv_dist_valuation.ytd_ol_mov_qty1: ' || lrec_inv_dist_valuation.ytd_ol_mov_qty1
          || ' lrec_inv_dist_valuation.ytd_ol_mov_qty2: ' || lrec_inv_dist_valuation.ytd_ol_mov_qty2
          || ' lrec_inv_dist_valuation.ytd_ps_movement_qty1: ' || lrec_inv_dist_valuation.ytd_ps_movement_qty1
          || ' lrec_inv_dist_valuation.ytd_ps_movement_qty2: ' || lrec_inv_dist_valuation.ytd_ps_movement_qty2
  );
*/
            UPDATE inv_dist_valuation idv
            SET idv.ytd_ul_mov_qty1 = lrec_inv_dist_valuation.ytd_ul_mov_qty1
            ,idv.ytd_ul_mov_qty2 = lrec_inv_dist_valuation.ytd_ul_mov_qty2
            ,idv.ytd_ol_mov_qty1 = lrec_inv_dist_valuation.ytd_ol_mov_qty1
            ,idv.ytd_ol_mov_qty2 = lrec_inv_dist_valuation.ytd_ol_mov_qty2
            ,idv.ytd_ps_movement_qty1 = lrec_inv_dist_valuation.ytd_ps_movement_qty1
            ,idv.ytd_ps_movement_qty2 = lrec_inv_dist_valuation.ytd_ps_movement_qty2
            ,idv.valuation_method = p_valuation_method
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

/*
            -- Movement
            -- ProRata distribution of the movement
            UPDATE inv_dist_valuation idv
            SET idv.ytd_ul_mov_qty1 = ROUND((idv.opening_ul_position_qty1 / lrec_inv_valuation.ul_opening_pos_qty1) * lrec_inv_valuation.ytd_ul_mov_qty1, 15)
            ,idv.ytd_ul_mov_qty2 = ROUND((idv.opening_ul_position_qty2 / lrec_inv_valuation.ul_opening_pos_qty2) * lrec_inv_valuation.ytd_ul_mov_qty2, 15)
            ,idv.ytd_ol_mov_qty1 = ROUND(DECODE(lrec_inv_valuation.ol_opening_qty1, 0, 0, ((idv.opening_ol_position_qty1 / lrec_inv_valuation.ol_opening_qty1) * lrec_inv_valuation.ytd_ol_mov_qty1)), 15)
            ,idv.ytd_ol_mov_qty2 = ROUND(DECODE(lrec_inv_valuation.ol_opening_qty2, 0, 0, ((idv.opening_ol_position_qty2 / lrec_inv_valuation.ol_opening_qty2) * lrec_inv_valuation.ytd_ol_mov_qty2)), 15)
            ,idv.ytd_ps_movement_qty1 = ROUND(DECODE(lrec_inv_valuation.ps_opening_qty1, 0, 0, ((idv.opening_ps_position_qty1 / lrec_inv_valuation.ps_opening_qty1) * lrec_inv_valuation.ytd_ps_mov_qty1)) , 15)
            ,idv.ytd_ps_movement_qty2 = ROUND(DECODE(lrec_inv_valuation.ps_opening_qty2, 0, 0, ((idv.opening_ps_position_qty2 / lrec_inv_valuation.ps_opening_qty2) * lrec_inv_valuation.ytd_ps_mov_qty2)) , 15)
            ,idv.valuation_method = p_valuation_method
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;
*/
            -- Closing
            UPDATE inv_dist_valuation idv
            SET idv.closing_ul_position_qty1 = idv.opening_ul_position_qty1 + idv.ytd_ul_mov_qty1
            ,idv.closing_ul_position_qty2 = idv.opening_ul_position_qty2 + idv.ytd_ul_mov_qty2
            ,idv.closing_ol_position_qty1 = idv.opening_ol_position_qty1 + idv.ytd_ol_mov_qty1
            ,idv.closing_ol_position_qty2 = idv.opening_ol_position_qty2 + idv.ytd_ol_mov_qty2
            ,idv.closing_ps_position_qty1 = idv.opening_ps_position_qty1 + idv.ytd_ps_movement_qty1
            ,idv.closing_ps_position_qty2 = idv.opening_ps_position_qty2 + idv.ytd_ps_movement_qty2
            ,idv.ytd_movement_qty1 = NVL(idv.ytd_ul_mov_qty1, 0) + NVL(idv.ytd_ol_mov_qty1, 0) + NVL(idv.ytd_ps_movement_qty1, 0)
            ,idv.ytd_movement_qty2 = NVL(idv.ytd_ul_mov_qty2, 0) + NVL(idv.ytd_ol_mov_qty2, 0) + NVL(idv.ytd_ps_movement_qty2, 0)
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

            -- Total Closing
            UPDATE inv_dist_valuation idv
            SET idv.total_closing_pos_qty1 = NVL(idv.closing_ul_position_qty1, 0) + NVL(idv.closing_ol_position_qty1, 0) + NVL(idv.closing_ps_position_qty1, 0)
            ,idv.total_closing_pos_qty2 = NVL(idv.closing_ul_position_qty2, 0) + NVL(idv.closing_ol_position_qty2, 0) + NVL(idv.closing_ps_position_qty2, 0)
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

        ELSIF (lrec_inv_valuation.ytd_ul_mov_qty1 = 0 AND lrec_inv_valuation.ytd_ol_mov_qty1 = 0) THEN -- Draw down
            -- Opening is zero
            UPDATE inv_dist_valuation idv
            SET idv.closing_ul_position_qty1 = 0
            ,idv.closing_ul_position_qty2 = 0
            ,idv.closing_ol_position_qty1 = NVL(idv.opening_ol_position_qty1, 0)
            ,idv.closing_ol_position_qty2 = NVL(idv.opening_ol_position_qty2, 0)
            ,idv.closing_ps_position_qty1 = NVL(idv.opening_ps_position_qty1, 0)
            ,idv.closing_ps_position_qty2 = NVL(idv.opening_ps_position_qty2, 0)
            ,idv.ytd_ul_mov_qty1 = 0
            ,idv.ytd_ul_mov_qty2 = 0
            ,idv.ytd_ol_mov_qty1 = 0
            ,idv.ytd_ol_mov_qty2 = 0
            ,idv.ytd_ps_movement_qty1 = 0
            ,idv.ytd_ps_movement_qty2 = 0
            ,idv.ytd_movement_qty1 = 0
            ,idv.ytd_movement_qty2 = 0
            ,idv.valuation_method = p_valuation_method
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

            -- Total Closing
            UPDATE inv_dist_valuation idv
            SET idv.total_closing_pos_qty1 = NVL(idv.closing_ul_position_qty1, 0) + NVL(idv.closing_ol_position_qty1, 0) + NVL(idv.closing_ps_position_qty1, 0)
            ,idv.total_closing_pos_qty2 = NVL(idv.closing_ul_position_qty2, 0) + NVL(idv.closing_ol_position_qty2, 0) + NVL(idv.closing_ps_position_qty2, 0)
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

        ELSIF (lrec_inv_valuation.ytd_ul_mov_qty1 = 0 AND lrec_inv_valuation.ytd_ol_mov_qty1 < 0) THEN -- Overlift
            FOR CurSumLayer IN c_sum_mov_layer(p_object_id, p_daytime, CurDist.Dist_Id) LOOP
                sum_ul_mov_qty1 := CurSumLayer.ytd_ul_mov_qty1;
                sum_ul_mov_qty2 := CurSumLayer.ytd_ul_mov_qty2;
            END LOOP;
/* DEBUG
ecdp_dynsql.WriteTempText('INV', 'DIST Layer:' || ec_inventory.object_code(p_object_id) ||
' Sum UL: ' || sum_ul_mov_qty1 ||
' Daytime: ' || p_daytime);
*/
            UPDATE inv_dist_valuation idv
            SET idv.ytd_ul_mov_qty1 = 0
            ,idv.ytd_ul_mov_qty2 = 0
            ,idv.ytd_ol_mov_qty1 = idv.ytd_ol_mov_qty1 + (NVL(sum_ul_mov_qty1, 0) * -1)
            ,idv.ytd_ol_mov_qty2 = idv.ytd_ol_mov_qty2 + (NVL(sum_ul_mov_qty2, 0) * -1)
            ,idv.valuation_method = p_valuation_method
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

            -- Closing
            UPDATE inv_dist_valuation idv
            SET idv.closing_ul_position_qty1 = idv.opening_ul_position_qty1 + idv.ytd_ul_mov_qty1
            ,idv.closing_ul_position_qty2 = idv.opening_ul_position_qty2 + idv.ytd_ul_mov_qty2
            ,idv.closing_ol_position_qty1 = idv.opening_ol_position_qty1 + idv.ytd_ol_mov_qty1
            ,idv.closing_ol_position_qty2 = idv.opening_ol_position_qty2 + idv.ytd_ol_mov_qty2
            ,idv.closing_ps_position_qty1 = idv.opening_ps_position_qty1 + idv.ytd_ps_movement_qty1
            ,idv.closing_ps_position_qty2 = idv.opening_ps_position_qty2 + idv.ytd_ps_movement_qty2
            ,idv.ytd_movement_qty1 = NVL(idv.ytd_ul_mov_qty1, 0) + NVL(idv.ytd_ol_mov_qty1, 0) + NVL(idv.ytd_ps_movement_qty1, 0)
            ,idv.ytd_movement_qty2 = NVL(idv.ytd_ul_mov_qty2, 0) + NVL(idv.ytd_ol_mov_qty2, 0) + NVL(idv.ytd_ps_movement_qty2, 0)
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;

            -- Total Closing
            UPDATE inv_dist_valuation idv
            SET idv.total_closing_pos_qty1 = NVL(idv.closing_ul_position_qty1, 0) + NVL(idv.closing_ol_position_qty1, 0) + NVL(idv.closing_ps_position_qty1, 0)
            ,idv.total_closing_pos_qty2 = NVL(idv.closing_ul_position_qty2, 0) + NVL(idv.closing_ol_position_qty2, 0) + NVL(idv.closing_ps_position_qty2, 0)
            ,last_updated_by = p_user
            WHERE
                object_id = p_object_id
                AND daytime = p_daytime
                AND year_code = p_year_code
                AND dist_id = CurDist.Dist_Id;
        END IF;

    END LOOP;

END ProcessInvDistLayer;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getLayerDistValue
-- Description    :
-------------------------------------------------------------------------------------------------
FUNCTION getLayerDistValue(p_value NUMBER,
                           p_code VARCHAR2,
                           p_object_id VARCHAR2,
                           p_dist_id VARCHAR2,
                           p_daytime DATE
                          )
RETURN NUMBER
IS

ln_return_value NUMBER;
ln_sum_value NUMBER;

CURSOR c_sum_field(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    SUM(idv.ytd_movement_qty1) AS total
FROM
    inv_dist_valuation idv
WHERE
    idv.object_id = cp_object_id
    AND idv.daytime = cp_daytime
;

CURSOR c_split_field(cp_object_id VARCHAR2, cp_daytime DATE, cp_sum NUMBER) IS
SELECT
    (idv.ytd_movement_qty1 / cp_sum) AS split
    ,idv.dist_id
FROM
    inv_dist_valuation idv
WHERE
    idv.object_id = cp_object_id
    AND idv.daytime = cp_daytime
;

BEGIN
        ln_return_value := 0;

        -- Find Total to calculate share from
        FOR CurSum IN c_sum_field(p_object_id, p_daytime) LOOP
            ln_sum_value := CurSum.total;
        END LOOP;

        IF (ln_sum_value <> 0) THEN
            FOR CurSplit IN c_split_field(p_object_id, p_daytime, ln_sum_value) LOOP
                -- Found the correct share
                IF (CurSplit.dist_id = p_dist_id) THEN
                    ln_return_value := p_value * CurSplit.split;
                END IF;
            END LOOP;
        END IF;

    RETURN ln_return_value;

END getLayerDistValue;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetPpaLayer
-- Description    :
-------------------------------------------------------------------------------------------------
FUNCTION GetPpaLayer(p_object_id VARCHAR2, p_daytime DATE, p_movement_qty NUMBER, p_dist_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
ln_return_value NUMBER;
BEGIN
    ln_return_value := 0;
    IF (p_movement_qty <> 0) THEN -- AND ecdp_inventory.isinunderlift(p_object_id, p_daytime) = 'TRUE') THEN
        SELECT
            SUM(i.ppa_qty1) INTO ln_return_value
        FROM
            inv_dist_valuation i
        WHERE
            i.object_id=p_object_id
            AND i.daytime = p_daytime
            AND i.dist_id = NVL(p_dist_id, i.dist_id);
    END IF;

    RETURN ln_return_value;

END GetPpaLayer;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetFinInterfaceFile
-- Description    :
-------------------------------------------------------------------------------------------------
FUNCTION GetFinInterfaceFile(p_object_id VARCHAR2, p_daytime DATE, p_year_code VARCHAR2)
RETURN VARCHAR2
IS
lv2_file VARCHAR2(2000);

CURSOR c_dist(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT fin_interface_file
FROM inv_dist_valuation
WHERE object_id = cp_object_id
AND daytime = cp_daytime
;

BEGIN

    FOR CurDist IN c_dist(p_object_id, p_daytime) LOOP
        lv2_file := CurDist.Fin_Interface_File;
    END LOOP;

    RETURN lv2_file;
END GetFinInterfaceFile;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : CalcPricingValue
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
--
-------------------------------------------------------------------------------------------------
PROCEDURE CalcPricingValue(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

lrec_inv_dist_valuation inv_dist_valuation%ROWTYPE;
lrec_inv_valuation inv_valuation%ROWTYPE;

CURSOR cur_dist(cp_object_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2) IS
SELECT
    *
FROM inv_dist_valuation
WHERE object_id = cp_object_id
  AND daytime = cp_daytime
  AND year_code = cp_year_code
  ;

CURSOR cur_inv(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    *
FROM
    inv_valuation
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime;


CURSOR cur_overlift(cp_object_id VARCHAR2, cp_daytime DATE, cp_year_code VARCHAR2) IS
SELECT
    *
FROM inv_dist_valuation idv
WHERE object_id = cp_object_id
  AND daytime = cp_daytime
  AND year_code = cp_year_code
  AND idv.closing_ol_position_qty1 < 0;


lv2_valuation_method VARCHAR2(200);
lv2_posting_type VARCHAR2(200);
lv2_valuation_level VARCHAR2(200);
ln_sum_overlift NUMBER;

lv2_inv_money_dist_method VARCHAR2(32);
lv2_inv_pricing_value_method VARCHAR2(32);

BEGIN


    IF (ue_Inventory.isCalcPricingValueUEEnabled = 'TRUE') THEN
       ue_Inventory.CalcPricingValue(p_object_id, p_daytime, p_user);
    ELSE -- No user exit, normal code


        lv2_valuation_level := ec_inventory_version.valuation_level(p_object_id, p_daytime, '<=');

        lv2_inv_money_dist_method := ec_inventory_version.inv_money_dist_method(p_object_id, p_daytime, '<=');

        lv2_inv_pricing_value_method := ec_inventory_version.inv_pricing_value_method(p_object_id, p_daytime, '<=');

        -- All quantities must be calculated in order to have correct pricing values

        -- All monetary values are rounded to two decimals

        -- Loop over all layers in the inventory, including "current"
        FOR CurInv IN cur_inv(p_object_id, p_daytime) LOOP
             -- use normal LIFO logic if December
             IF CurInv.Valuation_Method = 'LIFO_INTERIM' AND to_char(p_daytime,'MM') = '12' THEN
                  lv2_valuation_method := 'LIFO';
             ELSE
                  lv2_valuation_method := CurInv.Valuation_Method;
             END IF;

             IF lv2_valuation_method = 'LIFO_INTERIM' THEN
                  lv2_posting_type := 'INTERIM';
             ELSE
                  lv2_posting_type := 'PERMANENT';
             END IF;

           IF (CurInv.year_code = TO_CHAR(p_daytime, 'YYYY')) THEN -- Current layer

               IF (lv2_inv_pricing_value_method = 'WEIGHTED_AVERAGE') THEN
                    IF (IsInUnderLift(p_object_id, p_daytime) = 'TRUE') THEN -- Underlift
                        -- INV_VALUATION
                        UPDATE inv_valuation iv
                        SET iv.ul_price_value = ROUND(iv.UL_CLOSING_POS_QTY1 * UL_AVG_RATE, 2)
                           ,iv.ol_price_value = ROUND(iv.OL_CLOSING_POS_QTY1 * OL_AVG_RATE, 2)
                           ,iv.ps_price_value = ROUND(iv.PS_CLOSING_POS_QTY1 * PS_AVG_RATE, 2)
                           ,iv.closing_price_value = ROUND(NVL((iv.UL_CLOSING_POS_QTY1 * UL_AVG_RATE),0) + NVL((iv.OL_CLOSING_POS_QTY1 * OL_AVG_RATE),0) + NVL((iv.PS_CLOSING_POS_QTY1 * PS_AVG_RATE),0), 2)
                           ,iv.posting_type = lv2_posting_type
                           ,iv.valuation_level = lv2_valuation_level
                           ,last_updated_by = p_user
                        WHERE
                            iv.object_id = p_object_id
                            AND iv.daytime = p_daytime
                            AND iv.year_code = CurInv.year_code
                        ;

                        lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                        -- INV_DIST_VALUATION
                        UPDATE inv_dist_valuation idv
                        SET idv.ul_price_value = ROUND(idv.closing_ul_position_qty1 * lrec_inv_valuation.ul_avg_rate, 2)
                           ,idv.ol_price_value = ROUND(idv.closing_ol_position_qty1 * lrec_inv_valuation.ol_avg_rate, 2)
                           ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * lrec_inv_valuation.ps_avg_rate, 2)
                           ,last_updated_by = p_user
                        WHERE
                            idv.object_id = p_object_id
                            AND idv.daytime = p_daytime
                            AND idv.year_code = CurInv.year_code
                        ;

                    ELSIF (IsInOverLift(p_object_id, p_daytime) = 'TRUE') THEN -- Overlift
                        -- INV_VALUATION
                        UPDATE inv_valuation iv
                        SET iv.ul_price_value = ROUND(iv.UL_CLOSING_POS_QTY1 * UL_AVG_RATE, 2)
                           ,iv.ol_price_value = ROUND(iv.OL_CLOSING_POS_QTY1 * OL_AVG_RATE, 2)
                           ,iv.ps_price_value = ROUND(iv.PS_CLOSING_POS_QTY1 * PS_AVG_RATE, 2)
                           ,iv.closing_price_value = ROUND(NVL((iv.UL_CLOSING_POS_QTY1 * UL_AVG_RATE),0) + NVL((iv.OL_CLOSING_POS_QTY1 * OL_AVG_RATE),0) + NVL((iv.PS_CLOSING_POS_QTY1 * PS_AVG_RATE),0), 2)
                           ,iv.posting_type = lv2_posting_type
                           ,iv.valuation_level = lv2_valuation_level
                           ,last_updated_by = p_user
                        WHERE
                            iv.object_id = p_object_id
                            AND iv.daytime = p_daytime
                            AND iv.year_code = CurInv.year_code
                        ;

                        lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                        IF (lv2_inv_money_dist_method = 'PRORATA_EX_UL')THEN
                            -- Find number of overlift dists and use in prorata calc
                            -- ol_price_value = (INV_VALUATION.ol_closing_pos * ol_rate) / sum overlift
                            -- All
                            ln_sum_overlift := 0;
                            FOR CurOverlift IN cur_overlift(p_object_id, p_daytime, CurInv.year_code) LOOP
                                ln_sum_overlift := ln_sum_overlift + CurOverlift.Closing_Ol_Position_Qty1;
                            END LOOP;

                            -- INV_DIST_VALUATION
                            -- Is in Overlift and the pricing value for "underlift" fields is set to zero
                            -- Overlift
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = 0
                               ,idv.ol_price_value = ROUND((idv.closing_ol_position_qty1 / ln_sum_overlift) * lrec_inv_valuation.ol_closing_pos_qty1 * lrec_inv_valuation.ol_avg_rate, 2)
                               ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * lrec_inv_valuation.ps_avg_rate, 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.closing_ol_position_qty1 < 0
                            ;
                            -- Underlift
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = 0
                               ,idv.ol_price_value = 0
                               ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * lrec_inv_valuation.ps_avg_rate, 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.closing_ol_position_qty1 >= 0
                            ;
                        ELSE -- ProRata, code should be 'PRORATA'
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = 0
                               ,idv.ol_price_value = ROUND(idv.closing_ol_position_qty1 * lrec_inv_valuation.ol_avg_rate, 2)
                               ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * lrec_inv_valuation.ps_avg_rate, 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                            ;
                        END IF;
                    END IF;
                ELSE -- Assume 'BY_FIELD_RATE' as pricing value method

                    -- INV_DIST_VALUATION
                    UPDATE inv_dist_valuation idv
                    SET idv.ul_price_value = ROUND(idv.closing_ul_position_qty1 * idv.ul_rate, 2)
                       ,idv.ol_price_value = ROUND(idv.closing_ol_position_qty1 * idv.ol_rate, 2)
                       ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * idv.ps_rate, 2)
                       ,last_updated_by = p_user
                    WHERE
                        idv.object_id = p_object_id
                        AND idv.daytime = p_daytime
                        AND idv.year_code = CurInv.year_code
                    ;

                    -- INV_VALUATION
                    UPDATE inv_valuation iv
                    SET iv.ul_price_value = (SELECT SUM(ul_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ol_price_value = (SELECT SUM(ol_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ps_price_value = (SELECT SUM(ps_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ul_rate = DECODE(iv.historic, 'TRUE', iv.ul_rate, NULL)
                       ,iv.ol_rate = DECODE(iv.historic, 'TRUE', iv.ol_rate, NULL)
                       ,iv.ps_rate = DECODE(iv.historic, 'TRUE', iv.ps_rate, NULL)
                       ,iv.closing_price_value = (SELECT (SUM(ul_price_value)+SUM(ol_price_value)+SUM(ps_price_value)) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.posting_type = lv2_posting_type
                       ,iv.valuation_level = lv2_valuation_level
                       ,last_updated_by = p_user
                    WHERE
                        iv.object_id = p_object_id
                        AND iv.daytime = p_daytime
                        AND iv.year_code = CurInv.year_code
                    ;


                    UPDATE inv_valuation iv
                    SET iv.ul_avg_rate = iv.ul_price_value / DECODE(iv.ul_closing_pos_qty1, 0, 1, iv.ul_closing_pos_qty1)
                       ,iv.ol_avg_rate = iv.ol_price_value / DECODE(iv.ol_closing_pos_qty1, 0, 1, iv.ol_closing_pos_qty1)
                       ,iv.ps_avg_rate = iv.ps_price_value / DECODE(iv.ps_closing_pos_qty1, 0, 1, iv.ps_closing_pos_qty1)
                       ,iv.ul_rate = iv.ul_price_value / DECODE(iv.ul_closing_pos_qty1, 0, 1, iv.ul_closing_pos_qty1)
                       ,iv.ol_rate = iv.ol_price_value / DECODE(iv.ol_closing_pos_qty1, 0, 1, iv.ol_closing_pos_qty1)
                       ,iv.ps_rate = iv.ps_price_value / DECODE(iv.ps_closing_pos_qty1, 0, 1, iv.ps_closing_pos_qty1)
                       ,last_updated_by = p_user
                    WHERE
                        iv.object_id = p_object_id
                        AND iv.daytime = p_daytime
                        AND iv.year_code = CurInv.year_code
                    ;

                    IF (IsInOverLift(p_object_id, p_daytime) = 'TRUE') THEN -- Overlift

                        IF (lv2_inv_money_dist_method = 'PRORATA_EX_UL')THEN

                            lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));
                            -- Find number of overlift dists and use in prorata calc
                            -- ol_price_value = (INV_VALUATION.ol_closing_pos * ol_rate) / sum overlift
                            -- All
                            ln_sum_overlift := 0;
                            FOR CurOverlift IN cur_overlift(p_object_id, p_daytime, CurInv.year_code) LOOP
                                ln_sum_overlift := ln_sum_overlift + CurOverlift.Closing_Ol_Position_Qty1;
                            END LOOP;

                            -- INV_DIST_VALUATION
                            -- Is in Overlift and the pricing value for "underlift" fields is set to zero
                            -- Overlift
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = 0
                               ,idv.ol_price_value = ROUND((idv.closing_ol_position_qty1 / ln_sum_overlift) * lrec_inv_valuation.ol_closing_pos_qty1 * idv.ol_rate, 2)
                               ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * idv.ps_rate, 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.closing_ol_position_qty1 < 0
                            ;
                            -- Underlift
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = 0
                               ,idv.ol_price_value = 0
                               ,idv.ps_price_value = ROUND(idv.closing_ps_position_qty1 * idv.ps_rate, 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.closing_ol_position_qty1 >= 0
                            ;
                        END IF;

                    END IF;
                END IF;


            ELSE -- LIFO layers

                IF (lv2_inv_pricing_value_method = 'WEIGHTED_AVERAGE') THEN
                    lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                    -- INV_VALUATION
                    -- This is the "trick" with the layers, there can be a pricing_value without having anything left on the layer
                    -- The opening position is rated with "historic" rate and the movement is rated with current rate
                    -- December is the PERMANENT Posting which uses Layer Rates only
                    IF (TO_CHAR(p_daytime,'MM') = '12') THEN
                        UPDATE inv_valuation iv2
                        SET iv2.ul_price_value = ROUND((iv2.ul_closing_pos_qty1 * iv2.ul_avg_rate) , 2)
                           ,iv2.ol_price_value = ROUND((iv2.ol_closing_pos_qty1 * iv2.ol_avg_rate) , 2)
                           ,iv2.ps_price_value = ROUND((iv2.ps_closing_pos_qty1 * iv2.ps_avg_rate) , 2)
                           ,iv2.posting_type = lv2_posting_type
                           ,iv2.valuation_level = lv2_valuation_level
                           ,last_updated_by = p_user
                        WHERE
                            iv2.object_id = p_object_id
                            AND iv2.daytime = p_daytime
                            AND iv2.year_code = CurInv.year_code
                        ;
                    ELSE
                    -- All other months use OPENING * Layer Rate + MOVEMENT * Current Rate
                        UPDATE inv_valuation iv2
                        SET iv2.ul_price_value = ROUND((iv2.ul_opening_pos_qty1 * iv2.ul_avg_rate) + (iv2.ytd_ul_mov_qty1 * lrec_inv_valuation.ul_avg_rate), 2)
                           ,iv2.ol_price_value = ROUND((iv2.ol_opening_qty1 * iv2.ol_avg_rate) +  (iv2.ytd_ol_mov_qty1 * lrec_inv_valuation.ol_avg_rate), 2)
                           ,iv2.ps_price_value = ROUND((iv2.ps_opening_qty1 * iv2.ps_avg_rate) +  (iv2.ytd_ps_mov_qty1 * lrec_inv_valuation.ps_avg_rate), 2)
                           ,iv2.posting_type = lv2_posting_type
                           ,iv2.valuation_level = lv2_valuation_level
                           ,last_updated_by = p_user
                        WHERE
                            iv2.object_id = p_object_id
                            AND iv2.daytime = p_daytime
                            AND iv2.year_code = CurInv.year_code
                        ;
                    END IF;
                    -- INV_VALUATION
                    UPDATE inv_valuation iv
                    SET iv.closing_price_value = ROUND(NVL(iv.ul_price_value, 0) + NVL(iv.ol_price_value, 0) + NVL(iv.ps_price_value, 0), 2)
                       ,last_updated_by = p_user
                    WHERE
                        iv.object_id = p_object_id
                        AND iv.daytime = p_daytime
                        AND iv.year_code = CurInv.year_code
                    ;

                    FOR CurDist IN cur_dist(p_object_id, p_daytime, CurInv.year_code) LOOP

                        lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id, CurDist.Dist_Id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                        -- INV_DIST_VALUATION
                        -- Opening position is at layers rate while movement is at current layers rate
                    -- December is the PERMANENT Posting which uses Layer Rates only
                        IF (TO_CHAR(p_daytime,'MM') = '12') THEN
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = ROUND((idv.closing_ul_position_qty1 * ec_inv_valuation.ul_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) , 2)
                               ,idv.ol_price_value = ROUND((idv.closing_ol_position_qty1 * ec_inv_valuation.ol_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) , 2)
                               ,idv.ps_price_value = ROUND((idv.closing_ps_position_qty1 * ec_inv_valuation.ps_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) , 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.dist_id = CurDist.Dist_Id;
                        ELSE
                    -- All other months use OPENING * Layer Rate + MOVEMENT * Current Rate
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = ROUND((idv.opening_ul_position_qty1 * ec_inv_valuation.ul_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) +  (idv.ytd_ul_mov_qty1 * lrec_inv_valuation.ul_avg_rate), 2)
                               ,idv.ol_price_value = ROUND((idv.opening_ol_position_qty1 * ec_inv_valuation.ol_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) +  (idv.ytd_ol_mov_qty1 * lrec_inv_valuation.ol_avg_rate), 2)
                               ,idv.ps_price_value = ROUND((idv.opening_ps_position_qty1 * ec_inv_valuation.ps_avg_rate(p_object_id,  p_daytime, CurInv.year_code)) +  (idv.ytd_ps_movement_qty1 * lrec_inv_valuation.ps_avg_rate), 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.dist_id = CurDist.Dist_Id;
                        END IF;

                    END LOOP;
                ELSE
                    lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                    FOR CurDist IN cur_dist(p_object_id, p_daytime, CurInv.year_code) LOOP

                        lrec_inv_dist_valuation := ec_inv_dist_valuation.row_by_pk(p_object_id, CurDist.Dist_Id, p_daytime, TO_CHAR(p_daytime, 'YYYY'));

                        -- INV_DIST_VALUATION
                        -- Opening position is at layers rate while movement is at current layers rate
                        -- This is the "trick" with the layers, there can be a pricing_value without having anything left on the layer
                        -- The opening position is rated with "historic" rate and the movement is rated with current rate
                    -- December is the PERMANENT Posting which uses Layer Rates only
                        IF (TO_CHAR(p_daytime,'MM') = '12') THEN
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = ROUND((idv.closing_ul_position_qty1 * idv.ul_rate) , 2)
                               ,idv.ol_price_value = ROUND((idv.closing_ol_position_qty1 * idv.ol_rate) , 2)
                               ,idv.ps_price_value = ROUND((idv.closing_ps_position_qty1 * idv.ps_rate) , 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.dist_id = CurDist.Dist_Id;
                        ELSE
                    -- All other months use OPENING * Layer Rate + MOVEMENT * Current Rate
                            UPDATE inv_dist_valuation idv
                            SET idv.ul_price_value = ROUND((idv.opening_ul_position_qty1 * idv.ul_rate) +  (idv.ytd_ul_mov_qty1 * lrec_inv_dist_valuation.ul_rate), 2)
                               ,idv.ol_price_value = ROUND((idv.opening_ol_position_qty1 * idv.ol_rate) +  (idv.ytd_ol_mov_qty1 * lrec_inv_dist_valuation.ol_rate), 2)
                               ,idv.ps_price_value = ROUND((idv.opening_ps_position_qty1 * idv.ps_rate) +  (idv.ytd_ps_movement_qty1 * lrec_inv_dist_valuation.ps_rate), 2)
                               ,last_updated_by = p_user
                            WHERE
                                idv.object_id = p_object_id
                                AND idv.daytime = p_daytime
                                AND idv.year_code = CurInv.year_code
                                AND idv.dist_id = CurDist.Dist_Id;
                        END IF;

                    END LOOP;

                    -- INV_VALUATION
                    UPDATE inv_valuation iv
                    SET iv.ul_price_value = (SELECT SUM(ul_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ol_price_value = (SELECT SUM(ol_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ps_price_value = (SELECT SUM(ps_price_value) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.closing_price_value = (SELECT (SUM(ul_price_value)+SUM(ol_price_value)+SUM(ps_price_value)) FROM inv_dist_valuation WHERE object_id = p_object_id AND daytime = p_daytime AND year_code = CurInv.year_code)
                       ,iv.ul_rate = DECODE(iv.historic, 'TRUE', iv.ul_rate, NULL)
                       ,iv.ol_rate = DECODE(iv.historic, 'TRUE', iv.ol_rate, NULL)
                       ,iv.ps_rate = DECODE(iv.historic, 'TRUE', iv.ps_rate, NULL)
                       ,iv.posting_type = lv2_posting_type
                       ,iv.valuation_level = lv2_valuation_level
                       ,last_updated_by = p_user
                    WHERE
                        iv.object_id = p_object_id
                        AND iv.daytime = p_daytime
                        AND iv.year_code = CurInv.year_code
                    ;

                    UPDATE inv_valuation iv
                    SET iv.ul_avg_rate = iv.ul_price_value / DECODE(iv.ul_closing_pos_qty1, 0, 1, iv.ul_closing_pos_qty1)
                       ,iv.ol_avg_rate = iv.ol_price_value / DECODE(iv.ol_closing_pos_qty1, 0, 1, iv.ol_closing_pos_qty1)
                       ,iv.ps_avg_rate = iv.ps_price_value / DECODE(iv.ps_closing_pos_qty1, 0, 1, iv.ps_closing_pos_qty1)
                       ,iv.ul_avg_rate_status = iv.ul_avg_rate_status
                       ,iv.ol_avg_price_status = iv.ol_avg_price_status
                       ,iv.ps_avg_rate_status = iv.ps_avg_rate_status
                       ,iv.ul_rate = iv.ul_price_value / DECODE(iv.ul_closing_pos_qty1, 0, 1, iv.ul_closing_pos_qty1)
                       ,iv.ol_rate = iv.ol_price_value / DECODE(iv.ol_closing_pos_qty1, 0, 1, iv.ol_closing_pos_qty1)
                       ,iv.ps_rate = iv.ps_price_value / DECODE(iv.ps_closing_pos_qty1, 0, 1, iv.ps_closing_pos_qty1)
                       ,last_updated_by = p_user
                    WHERE
                        iv.object_id = p_object_id
                        AND iv.daytime = p_daytime
                        AND iv.year_code = CurInv.year_code
                    ;

                END IF;
            END IF;

        END LOOP;

    END IF;

END CalcPricingValue;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : CalcCurrencyValues
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
--
-------------------------------------------------------------------------------------------------
PROCEDURE CalcCurrencyValues(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

lv2_forex_source_id VARCHAR2(200);
ld_rate_day DATE := LAST_DAY(p_daytime);
lrec_inv_valuation inv_valuation%ROWTYPE;

CURSOR cur_inv(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    *
FROM
    inv_valuation
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime;

BEGIN
    IF (ue_Inventory.isCalcCurrencyValuesUEEnabled = 'TRUE') THEN
       ue_Inventory.CalcCurrencyValues(p_object_id, p_daytime, p_user);
    ELSE -- No user exit, normal code
        -- All pricing values must be updated before entering this procedure
        -- Here is the BOOKING, MEMO, LOCAL and GROUP values calculated


        FOR CurInv IN cur_inv(p_object_id, p_daytime) LOOP
            lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, CurInv.year_code);

            lv2_forex_source_id := lrec_inv_valuation.fx_source_id;

            -- INV_VALUATION
            UPDATE inv_valuation iv
            SET iv.ul_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ul_price_value,
                                                                    ec_currency.object_code(ul_pricing_currency_id),
                                                                    ec_currency.object_code(ul_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ol_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ol_price_value,
                                                                    ec_currency.object_code(ol_pricing_currency_id),
                                                                    ec_currency.object_code(ol_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ps_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ps_price_value,
                                                                    ec_currency.object_code(ul_pricing_currency_id),
                                                                    ec_currency.object_code(ul_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ul_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ul_price_value,
                                                                    ec_currency.object_code(ul_pricing_currency_id),
                                                                    ec_currency.object_code(ul_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ol_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ol_price_value,
                                                                    ec_currency.object_code(ol_pricing_currency_id),
                                                                    ec_currency.object_code(ol_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ps_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ps_price_value,
                                                                    ec_currency.object_code(ul_pricing_currency_id),
                                                                    ec_currency.object_code(ul_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    fx_type), 2)
               ,iv.ul_booking_memo_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ul_booking_currency_id),
                                                                         ec_currency.object_code(ul_memo_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.ul_booking_group_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ul_booking_currency_id),
                                                                         ec_currency.object_code(group_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.ul_booking_local_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ul_booking_currency_id),
                                                                         ec_currency.object_code(local_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.ol_booking_memo_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ol_booking_currency_id),
                                                                         ec_currency.object_code(ol_memo_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.ol_booking_group_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ol_booking_currency_id),
                                                                         ec_currency.object_code(group_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.ol_booking_local_forex_rate = ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ol_booking_currency_id),
                                                                         ec_currency.object_code(local_currency_id),
                                                                         NULL,
                                                                         p_daytime,
                                                                         lv2_forex_source_id,
                                                                         lrec_inv_valuation.fx_type)
               ,iv.book_category = ec_inventory_version.book_category(iv.object_id, iv.daytime, '<=')
               ,last_updated_by = p_user
            WHERE
                iv.object_id = p_object_id
                AND iv.daytime = p_daytime
                AND iv.year_code = CurInv.year_code
           ;

            UPDATE inv_valuation iv
            SET iv.closing_memo_value = ROUND(NVL(iv.ul_memo_value, 0) + NVL(iv.ol_memo_value, 0) + NVL(iv.ps_memo_value, 0), 2)
               ,iv.closing_booking_value = ROUND(NVL(iv.ul_booking_value, 0) + NVL(iv.ol_booking_value, 0) + NVL(iv.ps_booking_value, 0), 2)
               ,iv.ps_closing_booking_value = ROUND(iv.ps_booking_value, 2)
               ,iv.ps_closing_memo_value = ROUND(iv.ps_memo_value, 2)
               ,last_updated_by = p_user
            WHERE
                iv.object_id = p_object_id
                AND iv.daytime = p_daytime
                AND iv.year_code = CurInv.year_code
           ;

            -- Read the valuation once more in order to have the ex rates
            lrec_inv_valuation := ec_inv_valuation.row_by_pk(p_object_id, p_daytime, CurInv.year_code);

            -- INV_DIST_VALUATION
            UPDATE inv_dist_valuation idv
            SET idv.ul_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ul_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.ol_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ol_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ol_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ol_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.ps_memo_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ps_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_memo_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.ul_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ul_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.ol_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ol_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ol_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ol_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.ps_booking_value = ROUND(ECDP_CURRENCY.convertViaCurrency(ps_price_value,
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_pricing_currency_id),
                                                                    ec_currency.object_code(lrec_inv_valuation.ul_booking_currency_id),
                                                                    NULL,
                                                                    ld_rate_day,
                                                                    lv2_forex_source_id,
                                                                    lrec_inv_valuation.fx_type), 2)
               ,idv.book_category = ec_inventory_version.book_category(idv.object_id, idv.daytime, '<=')
               ,last_updated_by = p_user
            WHERE
                idv.object_id = p_object_id
                AND idv.daytime = p_daytime
                AND idv.year_code = CurInv.year_code
           ;

            UPDATE inv_dist_valuation idv
            SET idv.ul_local_value = ROUND(lrec_inv_valuation.ul_booking_local_forex_rate * idv.ul_booking_value, 2)
               ,idv.ol_local_value = ROUND(lrec_inv_valuation.ol_booking_local_forex_rate * idv.ol_booking_value, 2)
               ,idv.ps_local_value = ROUND(lrec_inv_valuation.ul_booking_local_forex_rate * idv.ps_booking_value, 2)
               ,idv.ul_group_value = ROUND(lrec_inv_valuation.ul_booking_group_forex_rate * idv.ul_booking_value, 2)
               ,idv.ol_group_value = ROUND(lrec_inv_valuation.ol_booking_group_forex_rate * idv.ol_booking_value, 2)
               ,idv.ps_group_value = ROUND(lrec_inv_valuation.ul_booking_group_forex_rate * idv.ps_booking_value, 2)
               ,last_updated_by = p_user
            WHERE
                idv.object_id = p_object_id
                AND idv.daytime = p_daytime
                AND idv.year_code = CurInv.year_code
           ;

        END LOOP; -- Loop over all layers

    END IF;

END CalcCurrencyValues;

PROCEDURE PopulateUOM(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

lv2_uom1_code VARCHAR2(32);
lv2_uom2_code VARCHAR2(32);

BEGIN
    -- Set the UOM codes on valuation and dist level for the whole inventory valuation

    lv2_uom1_code := ec_inventory_version.uom1_code(p_object_id, p_daytime, '<=');
    lv2_uom2_code := ec_inventory_version.uom2_code(p_object_id, p_daytime, '<=');

    -- INV_VALUATION
    UPDATE inv_valuation iv SET
        iv.uom1_code = lv2_uom1_code
        ,iv.uom2_code = lv2_uom2_code
        ,last_updated_by = p_user
    WHERE
        object_id = p_object_id
        AND daytime = p_daytime;

    -- INV_DIST_VALUATION
    UPDATE inv_dist_valuation idv SET
        idv.uom1_code = lv2_uom1_code
        ,idv.uom2_code = lv2_uom2_code
        ,last_updated_by = p_user
    WHERE
        object_id = p_object_id
        AND daytime = p_daytime;

END PopulateUOM;

PROCEDURE PopulateCurrencies(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

lv2_ul_pricing_currency_id VARCHAR2(32);
lv2_ul_booking_currency_id VARCHAR2(32);
lv2_ul_memo_currency_id VARCHAR2(32);
lv2_ol_pricing_currency_id VARCHAR2(32);
lv2_ol_booking_currency_id VARCHAR2(32);
lv2_ol_memo_currency_id VARCHAR2(32);
lv2_group_currency_id VARCHAR2(32);
lv2_local_currency_id VARCHAR2(32);

lv2_fx_type VARCHAR2(32);
lv2_fx_source_code VARCHAR2(32);
lv2_fx_source_id VARCHAR2(32);

BEGIN
    -- Set the Currencies on valuation and dist level for the whole inventory valuation

    lv2_ul_pricing_currency_id := ec_inventory_version.ul_pricing_currency_id(p_object_id, p_daytime, '<=');
    lv2_ul_booking_currency_id := ec_inventory_version.ul_booking_currency_id(p_object_id, p_daytime, '<=');
    lv2_ul_memo_currency_id := ec_inventory_version.ul_memo_currency_id(p_object_id, p_daytime, '<=');
    lv2_ol_pricing_currency_id := ec_inventory_version.ol_pricing_currency_id(p_object_id, p_daytime, '<=');
    lv2_ol_booking_currency_id := ec_inventory_version.ol_booking_currency_id(p_object_id, p_daytime, '<=');
    lv2_ol_memo_currency_id := ec_inventory_version.ol_memo_currency_id(p_object_id, p_daytime, '<=');
    lv2_group_currency_id := ec_currency.object_id_by_uk(ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<='));
    lv2_local_currency_id := Ec_Company_Version.local_currency_id(ec_inventory_version.company_id(p_object_id, p_daytime, '<='), p_daytime, '<=');

    lv2_fx_type := ec_inventory_version.fx_type(p_object_id, p_daytime, '<=');
    lv2_fx_source_code := ec_forex_source.object_code(ec_inventory_version.forex_source_id(p_object_id, p_daytime, '<='));
    lv2_fx_source_id := ec_inventory_version.forex_source_id(p_object_id, p_daytime, '<=');


    UPDATE inv_valuation iv SET
        ul_pricing_currency_id = lv2_ul_pricing_currency_id
        ,ul_booking_currency_id = lv2_ul_booking_currency_id
        ,ul_memo_currency_id = lv2_ul_memo_currency_id
        ,ol_pricing_currency_id = lv2_ol_pricing_currency_id
        ,ol_booking_currency_id = lv2_ol_booking_currency_id
        ,ol_memo_currency_id = lv2_ol_memo_currency_id
        ,group_currency_id = lv2_group_currency_id
        ,local_currency_id = lv2_local_currency_id
        ,fx_type = lv2_fx_type
        ,fx_source_code = lv2_fx_source_code
        ,fx_source_id = lv2_fx_source_id
        ,last_updated_by = p_user
    WHERE
        object_id = p_object_id
        AND daytime = p_daytime;

END PopulateCurrencies;

FUNCTION GetInventoryValue(p_object_id VARCHAR2, p_daytime DATE, p_attribute VARCHAR2) RETURN NUMBER
IS

CURSOR c_all_layers(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT
    SUM(iv.ul_opening_pos_qty1) ul_opening_pos_qty1 -- Opening
    ,SUM(iv.ul_opening_pos_qty2) ul_opening_pos_qty2
    ,SUM(iv.ol_opening_qty1) ol_opening_qty1
    ,SUM(iv.ol_opening_qty2) ol_opening_qty2
    ,SUM(iv.ps_opening_qty1) ps_opening_qty1
    ,SUM(iv.ps_opening_qty2) ps_opening_qty2
    ,SUM(iv.ytd_ul_mov_qty1) ytd_ul_mov_qty1 -- Movement
    ,SUM(iv.ytd_ul_mov_qty2) ytd_ul_mov_qty2
    ,SUM(iv.ytd_ol_mov_qty1) ytd_ol_mov_qty1
    ,SUM(iv.ytd_ol_mov_qty2) ytd_ol_mov_qty2
    ,SUM(iv.ytd_ps_mov_qty1) ytd_ps_mov_qty1
    ,SUM(iv.ytd_ps_mov_qty2) ytd_ps_mov_qty2
    ,SUM(iv.ul_closing_pos_qty1) ul_closing_pos_qty1 -- Closing
    ,SUM(iv.ul_closing_pos_qty2) ul_closing_pos_qty2
    ,SUM(iv.ol_closing_pos_qty1) ol_closing_pos_qty1
    ,SUM(iv.ol_closing_pos_qty2) ol_closing_pos_qty2
    ,SUM(iv.ps_closing_pos_qty1) ps_closing_pos_qty1
    ,SUM(iv.ps_closing_pos_qty2) ps_closing_pos_qty2
    ,SUM(iv.total_closing_pos_qty1) total_closing_pos_qty1
    ,SUM(iv.total_closing_pos_qty2) total_closing_pos_qty2
    ,SUM(iv.closing_booking_value) closing_booking_value -- Monetary values
    ,SUM(iv.ps_closing_booking_value) ps_closing_booking_value
    ,SUM(iv.ul_booking_value) ul_booking_value
    ,SUM(iv.ol_booking_value) ol_booking_value
FROM
    inv_valuation iv
WHERE
    object_id = cp_object_id
    AND daytime = cp_daytime
    ;

ln_return_value NUMBER := 0;

BEGIN
/*
    This function is made in order to the the "whole" number and not only the number for the layer
    it is a sum of the values based on Inventory and Daytime (All year_codes is included)
*/
    FOR CurLayers IN c_all_layers(p_object_id, p_daytime) LOOP
        IF (p_attribute = 'CLOSING_BOOKING_VALUE') THEN
            ln_return_value := CurLayers.closing_booking_value;
        ELSIF (p_attribute = 'PS_CLOSING_BOOKING_VALUE') THEN
            ln_return_value := CurLayers.ps_closing_booking_value;
        ELSIF (p_attribute = 'ULOL_CLOSING_BOOKING_VALUE') THEN
            ln_return_value := CurLayers.ul_booking_value + CurLayers.ol_booking_value;
        ELSIF (p_attribute = 'UL_CLOSING_POS_QTY1') THEN
            ln_return_value := CurLayers.ul_closing_pos_qty1;
        ELSIF (p_attribute = 'PS_CLOSING_POS_QTY1') THEN
            ln_return_value := CurLayers.ps_closing_pos_qty1;
        ELSIF (p_attribute = 'ULOL_CLOSING_POS_QTY1') THEN
            ln_return_value := CurLayers.ul_closing_pos_qty1 + CurLayers.ol_closing_pos_qty1;
        END IF;
    END LOOP;

    RETURN ln_return_value;

END GetInventoryValue;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetInventoryBusinessUnitID
-- Description    : Gets the business unit id of an inventory.
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
--
-------------------------------------------------------------------------------------------------
FUNCTION GetInventoryBusinessUnitID(p_object_id VARCHAR2, p_daytime DATE)
    RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_business_unit_id VARCHAR2(32);
    lv2_inventory_area_id VARCHAR2(32);
BEGIN
    lv2_inventory_area_id := ec_inventory_version.inventory_area_id(p_object_id, p_daytime, '<=');
    lv2_business_unit_id := ec_inventory_area_version.business_unit_id(lv2_inventory_area_id, p_daytime, '<=');

    RETURN lv2_business_unit_id;
END GetInventoryBusinessUnitID;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetFormatString
-- Description    : Format string passed in this function. It replaces '_' to blank space and
--                  convert the capital letters to Normal formatted text. Needs to set a
--                  system attribute 'TRANS_INV_INITCAP' to 'Y' to get formatting.
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
--
-------------------------------------------------------------------------------------------------
FUNCTION GetFormatString(p_string VARCHAR2)
  RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_mystring  VARCHAR2(4000);

BEGIN
  lv2_mystring := p_string;
  IF nvl(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate,'TRANS_INV_INITCAP','<='),'Y') = 'Y' then
    lv2_mystring := INITCAP(replace(lv2_mystring,'_',' '));
  END IF;
     RETURN lv2_mystring;
END GetFormatString;

END Ecdp_Inventory;