CREATE OR REPLACE PACKAGE BODY EcBp_Storage_Proc_Plant IS
/****************************************************************
** Package        :  EcBp_Storage_Proc_Plant, body part
**
** $Revision: 1.71 $
**
** Purpose        :  Finds storage differences for active storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.01.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date     Whom  	    Change description:
** -------  ------   -------- 	--------------------------------------
**          04.01.11 rajarsar   ECPD-16478:Initial Version
**          05.01.11 farhaann   ECPD-16484:Added validateOverlappingPeriod - checking for overlapping
**          11.01.11 musthram   ECPD-16483:Added validateBlendContentSplit - checking for sum equal to 100
**          24.01.11 farhaann   ECPD-16478:Added getStorageDayGrsOpeningVol, getStorageDayGrsClosingVol, getStorageDayGrsReceiptsVol, getStorageDayGrsYieldVol,
**                                         getStorageDayGrsIntakeVol, getStorageDayGrsDeliveredVol, getStorageDayGrsGainVol, getStorageDayGrsLossVol, getStorageDayGrsSellVol,
**                                         getStorageDayGrsBuyVol, getStorageDayDiffVol, createGainLossTransaction, getStorTotalCreditVol, getStorTotalDebitVol, getTotalTankVol
** 	    28.01.11 rajarsar   ECPD-16479:Added getProdDayGrsOpeningVol, getProdDayGrsClosingVol and createTransactionOwnshp and updated createTransactionOwnshp
**          31.01.11 rajarsar   ECPD-16479:Added validateSplitVolume
**          21.02.11 rajarsar   ECPD-16872:Added updateOwnshpVol and updateChildOwnshp,updated createTransactionOwnshp and validateSplitVolume
**          24.02.11 rajarsar   ECPD-16874:Added createComplementTrans,updateComplementOwnshp, deleteComplementEvent and updated updateOwnshpVol and updateChildOwnshp
**          25.02.11 rajarsar   ECPD-16874:Changed procedure name from deleteComplementEvent to deleComplementTrans
**          25.02.11 rajarsar   ECPD-16873:Added procedure updateComplementTrans.
**          28.02.11 farhaann   ECPD-16480:Added createBlendContent, validateBlendSplitVolume and validateBlendContentVolume.
**          28.02.11 farhaann   ECPD-16480:Added getActualVolume
**          28.02.11 rajarsar   ECPD-16873:Added createRegradeTrans and getCompDayVol
**          01.03.11 rajarsar   ECPD-16873:Added getCompDayGrsOpeningVol and getCompDayGrsClosingVol
**          02.03.11 rajarsar   ECPD-16481:Added getTotalProdTransVol, getTotalProdGrsOpeningVol and getTotalProdGrsClosingVol
**          02.03.11 farhaann   ECPD-16480:Added updateBlendContent and approveSelectedBatch
**          03.03.11 rajarsar   ECPD-16873:Added updateOwnshpType, updated createRegradeTrans and createComplementTrans
**          03.03.11 farhaann   ECPD-16480:Added updateBlendOwnshp and updateVolBlendOwnshp
**          22.03.11 farhaann   ECPD-16480:Added deleteChildEvent
**          08.04.11 rajarsar   ECPD-17066:Updated getStorageDayGrsOpeningVol,getStorageDayGrsClosingVol,getProdDayGrsOpeningVol,getProdDayGrsClosingVol,getCompDayGrsClosingVol,getCompDayGrsOpeningVol,createRegradeTrans,createGainLossTransaction
**                                         to add user exits.
**          13.04.11 farhaann   ECPD-17138:Modified getProdDayGrsOpeningVol, getProdDayGrsClosingVol and createComplementTrans.
**          15.04.11 farhaann   ECPD-17177:Modified approveSelectedBatch -  added error message if no data in blend ownership
**          19.04.11 rajarsar   ECPD-17066:Updated getCompDayGrsClosingVol and getCompDayGrsOpeningVol
**          06.05.11 rajarsar   ECPD-16920:Added updateRecalculateStorageMeas,insertRecalculateStorageMeas and deleteRecalculateStorageMeas
**                                        :Removed getStorTotalCreditVol and getStorTotalDebitVol
**                                        :getStorageDayGrsOpeningVol,getStorageDayGrsClosingVol,getProdDayGrsOpeningVol,getProdDayGrsClosingVol,getTotalProdGrsOpeningVol,getTotalProdGrsClosingVol,approveSelectedBatch
**          30.05.11 kumarsur   ECPD-17453:Added Created_By in insert into STOR_BLEND_MEAS in createBlendContent
**          31.05.11 rajarsar   ECPD-17518:Added updateBlendTrans
**          20.06.11 rajarsar   ECPD-17641:Updated createTransactionOwnshp
**          22.06.11 rajarsar   ECPD-17708:Added createComplementTransOwnshp,updated createTransactionOwnshp,createComplementTrans,updateComplementTrans,deleteComplementTrans
**          04.07.11 musthram   ECPD-17179:Modified createGainLossTransaction
**          07.07.11 musthram   ECPD-17925:Modified createGainLossTransaction and updateChildOwnshp
**          25.07.11 musthram   ECPD-17948:Removed getStorageDayGrsReceiptsVol, getStorageDayGrsYieldVol,
**                                         getStorageDayGrsIntakeVol, getStorageDayGrsDeliveredVol, getStorageDayGrsGainVol, getStorageDayGrsLossVol
** 										   Added getStorageDayGrsTransactionVol
**          26.07.11 rajarsar   ECPD-18159:Modified updateBlendContent and updateBlendTrans
**          26.07.11 kumarsur   ECPD-17981:Modified deleteChildEvent
**          27.07.11 kumarsur   ECPD-18017:Modified createBlendContent
**          15.09.11 musthram   ECPD-18629:Removed updateComplementOwnshp
**          19.09.11 musthram   ECPD-18598:Modified approveSelectedBatch
**			20.09.11 syazwnur	ECPD-18584:Modified updateOwnshpVol
**			19.10.11 madondin	ECPD-18457:Add new function for validateStorageProdUpdate and validateStorageProdDelete
**			03.11.11 musthram	ECPD-18380:Modified ApproveSelectedBatch
**			27.12.11 musthram	ECPD-18949:Added updateApprovedBatchOwnshp, insertApprovedBatchOwnshp, deleteApprovedBatchOwnshp and deleteApprovedProductTrans
**                                        :Updated UpdateBlendTrans and ApproveSelectedBatch
**			30.01.12 musthram   ECPD-18652:Updated createComplementTrans and createComplementTransOwnshp
**			30.01.12 choonshu	ECPD-18622:Modified approveSelectedBatch, updateBlendTrans, updateChildOwnshp, updateApprovedBatchOwnshp, insertApprovedBatchOwnshp, updateOwnshpVol and updateComplementTrans
**										  :Added calcBlendContentMass, updateVolBlendBatch and approveBlendContent
**			09.02.12 rajarsar	ECPD-18622:Updated deleteApprovedProductTrans
*****************************************************************/

CURSOR cur_trans_overview(cp_object_id VARCHAR2, cp_daytime DATE, cp_trans_type VARCHAR2) IS
  SELECT sum(tm.volume)total_volume
  FROM transaction_measurement tm
  WHERE tm.storage_id = cp_object_id
  AND tm.daytime = cp_daytime
  AND tm.transaction_type = cp_trans_type;

CURSOR c_transaction_measurement (cp_event_no NUMBER) IS
  SELECT *
  FROM transaction_measurement
  WHERE event_no = cp_event_no;

CURSOR c_trans_meas_ownshp (cp_event_no NUMBER) IS
  SELECT *
  FROM transaction_meas_ownshp tmo
  WHERE tmo.event_no = cp_event_no;

CURSOR c_storage_meas_days(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT *
    FROM storage_measurement sm
    WHERE sm.object_id = cp_storage_id
    AND sm.product_id = cp_product_id
    AND sm.daytime > cp_daytime;

CURSOR c_trans_inventory_exist(cp_storage_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT 1
    FROM transaction_measurement
    WHERE storage_id =  cp_storage_id
    AND object_id = cp_product_id
    AND daytime =  cp_daytime
    AND transaction_type = 'INVENTORY';

CURSOR c_trans_meas_inv(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT sum(volume) sum_inv_vol
    FROM transaction_measurement tm
    WHERE tm.storage_id= cp_storage_id
    AND tm.object_id = cp_product_id
    AND tm.daytime = cp_daytime
    AND tm.transaction_type = 'INVENTORY';

CURSOR c_storage_meas_current_event(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT *
    FROM storage_measurement sm
    WHERE sm.object_id = cp_storage_id
    AND sm.product_id = cp_product_id
    AND sm.daytime = cp_daytime;

CURSOR c_trans_meas_recalculate(cp_event_no NUMBER) IS
  SELECT tm.object_id, tm.storage_id, tm.volume, tm.daytime, pc.alt_code, tm.transaction_type
    FROM transaction_measurement tm, prosty_codes pc
    WHERE tm.event_no = cp_event_no
    AND tm.transaction_type =  pc.code
    AND pc.code_type = 'STOR_TRANS_TYPE';

CURSOR c_stor_intermed_prod(cp_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT *
    FROM stor_intermed_prod sip
    WHERE sip.object_id = cp_object_id
    AND sip.daytime <= cp_daytime
    AND nvl(sip.end_date,cp_daytime+1) >cp_daytime;
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Checking for overlapping events.
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_intermed_prod
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_end_date   DATE,
                                    p_product_id  VARCHAR2)
IS
  CURSOR c_product IS
    SELECT *
      FROM stor_intermed_prod
     WHERE object_id = p_object_id
       AND product_id = p_product_id
       AND daytime <> p_daytime
       AND (end_date >= p_daytime OR end_date is null)
       AND (daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_product IN c_product LOOP
    lv_message := lv_message || cur_product.product_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20606,'A record is overlapping with an existing record.');
  END IF;

END validateOverlappingPeriod;

---------------------------------------------------------------------------------------------------
-- Function       : validateBlendContentSplit
-- Description    : Checking for Blend Content Split sum equal to 100
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : blend_content
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateBlendContentSplit(
       p_object_id     VARCHAR2,
       p_daytime      DATE
       )
IS
  ln_count NUMBER;
  ln_product_split  NUMBER;

  CURSOR c_product_split IS
    SELECT  product_split
    FROM blend_content
    WHERE object_id = p_object_id
    AND daytime = p_daytime;

BEGIN
  ln_product_split := 0;
  ln_count :=0;

  FOR sumProductSplit IN c_product_split LOOP
    ln_count := ln_count + 1;
    ln_product_split := ln_product_split + ROUND(Nvl(sumProductSplit.Product_Split,0),9);
  END LOOP;

  IF ln_product_split <> 1 AND ln_count <> 0 THEN
    RAISE_APPLICATION_ERROR(-20326,'The sum of equity has to be 100');
  END IF;

END validateBlendContentSplit;

---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayGrsOpeningVol
-- Description    : Return the OPENING grs dip level for a storage for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getStorageDayGrsOpeningVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayGrsOpeningVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS

CURSOR c_storage_meas(cp_product_id VARCHAR2) IS
  SELECT closing_volume
  FROM STORAGE_MEASUREMENT
  WHERE object_id = p_object_id
  AND product_id = cp_product_id
  AND daytime =
   (SELECT max(daytime)
    FROM STORAGE_MEASUREMENT
    WHERE object_id = p_object_id
    AND product_id = cp_product_id
    AND daytime < p_daytime);

  ln_return_val NUMBER ;

BEGIN
  ln_return_val := ue_storage_proc_plant.getStorageDayGrsOpeningVol(p_object_id,p_daytime);
  IF ln_return_val IS NULL THEN
    FOR  cur_stor_intermed_prod IN  c_stor_intermed_prod(p_object_id,p_daytime) LOOP
      FOR cur_storage_meas IN c_storage_meas(cur_stor_intermed_prod.product_id) LOOP
        ln_return_val := nvl(ln_return_val,0) + cur_storage_meas.closing_volume;
      END LOOp;
    END LOOP;
  END IF;

  RETURN ln_return_val;
END getStorageDayGrsOpeningVol;
---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayGrsClosingVol
-- Description    : Return the CLOSING grs dip level for a storage for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getStorageDayGrsClosingVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayGrsClosingVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)
RETURN NUMBER IS

CURSOR c_storage_meas(cp_product_id VARCHAR2) IS
  SELECT closing_volume
  FROM STORAGE_MEASUREMENT
  WHERE object_id = p_object_id
  AND product_id = cp_product_id
  AND daytime =
  (SELECT max(daytime)
   FROM STORAGE_MEASUREMENT
   WHERE object_id = p_object_id
   AND product_id = cp_product_id
   AND daytime <= p_daytime);

  ln_return_val NUMBER;

BEGIN
  ln_return_val := ue_storage_proc_plant.getStorageDayGrsClosingVol(p_object_id,p_daytime);
  IF ln_return_val IS NULL THEN
    FOR  cur_stor_intermed_prod IN  c_stor_intermed_prod(p_object_id,p_daytime) LOOP
      FOR cur_storage_meas IN c_storage_meas(cur_stor_intermed_prod.product_id) LOOP
        ln_return_val := nvl(ln_return_val,0) + cur_storage_meas.closing_volume;
      END LOOp;
    END LOOP;
  END IF;
  RETURN ln_return_val;

END getStorageDayGrsClosingVol;
---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayGrsTransactionVol
-- Description    : Get volume for a storage per day based on transaction
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayGrsTransactionVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE,
  p_trans_type       VARCHAR2)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

  FOR mycur IN cur_trans_overview(p_object_id, p_daytime, p_trans_type) LOOP
    ln_return_val := nvl(mycur.total_volume,0);
  END LOOP;

  RETURN ln_return_val;

END getStorageDayGrsTransactionVol;
---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayGrsSellVol
-- Description    : Get volume for a storage per day that has transaction type = 'SELL'
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayGrsSellVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

  FOR mycur IN cur_trans_overview(p_object_id, p_daytime,'SELL') LOOP
    ln_return_val := nvl(mycur.total_volume,0);
  END LOOP;

  RETURN ln_return_val;

END getStorageDayGrsSellVol;

---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayGrsBuyVol
-- Description    : Get volume for a storage per day that has transaction type = 'BUY'
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayGrsBuyVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

  FOR mycur IN cur_trans_overview(p_object_id, p_daytime,'BUY') LOOP
    ln_return_val := nvl(mycur.total_volume,0);
  END LOOP;

  RETURN ln_return_val;

END getStorageDayGrsBuyVol;

---------------------------------------------------------------------------------------------------
-- Function       : getStorageDayDiffVol
-- Description    : Get different value between closing volume and total tank volume for a storage per day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDayDiffVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
  ln_return_val NUMBER;
  ln_total_tank_vol NUMBER;
  ln_closing_vol NUMBER;

BEGIN

  ln_total_tank_vol := getTotalTankVol(p_object_id,p_daytime);
  ln_closing_vol    := getStorageDayGrsClosingVol(p_object_id,p_daytime);
  ln_return_val     := nvl(ln_closing_vol,0) - nvl(ln_total_tank_vol,0);

  RETURN ln_return_val;

END getStorageDayDiffVol;

---------------------------------------------------------------------------------------------------
-- Function       : createGainLossTransaction
-- Description    : Allocate volume to Gain or Loss columns in transaction_measurement.
--                  User exit is supported for this function at ue_storage_proc_plant.createGainLossTransaction().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createGainLossTransaction(p_object_id  VARCHAR2,
                                    p_daytime    DATE)
IS

CURSOR c_stor_intermed_prod IS
SELECT *
FROM stor_intermed_prod sip
WHERE sip.object_id = p_object_id
AND   sip.daytime <= p_daytime
AND nvl(sip.end_date,p_daytime+1) > p_daytime;


CURSOR c_trans_meas_ownshp (cp_product_id VARCHAR2)  IS
   SELECT sum(tmo.split_volume) As CompSplitVolSum, sum(tm.volume) As VolSum, tmo.object_id
    FROM transaction_meas_ownshp tmo, transaction_measurement tm
    where tmo.event_no = tm.event_no
    and  tm.storage_id = p_object_id
      and tm.object_id = cp_product_id
      AND tm.daytime = p_daytime
     AND tm.transaction_type NOT IN ('GAIN','LOSS')
     GROUP BY tmo.object_id;


  ln_diffvol NUMBER;
  ln_storageClosingvol NUMBER;
  ln_gain_loss NUMBER;
  ln_event_no NUMBER;
  ln_company_vol NUMBER;
  ln_company_pct NUMBER;
  ln_company_day_vol NUMBER;


BEGIN

  ue_storage_proc_plant.createGainLossTransaction(p_object_id,p_daytime);
  ln_diffvol := getStorageDayDiffVol(p_object_id, p_daytime);
  IF ln_diffvol <> 0 THEN
    ln_storageClosingvol:= getStorageDayGrsClosingVol(p_object_id, p_daytime);
    FOR cur_stor_intermed_prod IN  c_stor_intermed_prod LOOP
      --ln_gain_loss :=  (ln_opening_grs_vol + ln_total_credit_vol -ln_total_debit_vol) * ln_diffvol/ln_closingvol;
      -- need to check divisor by zero for ln_storageClosingvol
      IF ln_storageClosingvol = 0 THEN
        ln_gain_loss := ln_diffvol;
      ELSE
        ln_gain_loss :=  getProdDayGrsClosingVol(p_object_id,cur_stor_intermed_prod.product_id,p_daytime,p_daytime)/ln_storageClosingvol * ln_diffvol;
      END IF;

      --If ln_diffvol bigger than 0, assign value as LOSS
      EcDp_System_Key.assignNextNumber('TRANSACTION_MEASUREMENT', ln_event_no);
      IF ln_diffvol > 0 THEN
        INSERT INTO TRANSACTION_MEASUREMENT (event_no, storage_id, object_id, daytime, transaction_type, volume,OWNERSHIP_TYPE, Ownership_Split_Type) values (ln_event_no,p_object_id, cur_stor_intermed_prod.product_id, p_daytime, 'LOSS',ln_gain_loss,'GENERATED','VOLUME_SPLIT');
      --If ln_diffvol less than 0, assign value as GAIN
      ELSIF ln_diffvol < 0 THEN
        ln_gain_loss := ln_gain_loss * -1;
        INSERT INTO TRANSACTION_MEASUREMENT (event_no, storage_id, object_id, daytime, transaction_type, volume,OWNERSHIP_TYPE, Ownership_Split_Type) values (ln_event_no, p_object_id, cur_stor_intermed_prod.product_id, p_daytime, 'GAIN',ln_gain_loss,'GENERATED','VOLUME_SPLIT');
      END IF;
      insertRecalculateStorageMeas(ln_event_no);
      -- create transaction_meas_ownship records
      -- we are "aware" of request for changes on ownership
      FOR cur_trans_meas_ownshp IN c_trans_meas_ownshp(cur_stor_intermed_prod.product_id) LOOP

        IF (cur_trans_meas_ownshp.CompSplitVolSum = 0) OR (cur_trans_meas_ownshp.VolSum = 0) THEN
             ln_company_vol := 0;
        ELSE
             ln_company_vol :=   (cur_trans_meas_ownshp.CompSplitVolSum/cur_trans_meas_ownshp.VolSum) * (ln_gain_loss);
        END IF;
		IF ln_gain_loss != 0 THEN
          ln_company_pct :=  ln_company_vol/ln_gain_loss * 100 ;
        END IF;
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_VOLUME, SPLIT_PCT)
        VALUES (ln_event_no, cur_trans_meas_ownshp.object_id, p_daytime,ln_company_vol, ln_company_pct);
      END LOOP;
    END LOOP;
  END IF;
END createGainLossTransaction;

---------------------------------------------------------------------------------------------------
-- Function       : getTotalTankVol
-- Description    : Get total tank volume for a storage per day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : v_stor_day_overview_detail
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalTankVol (
  p_object_id        storage.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
ln_return_val NUMBER;


CURSOR cur_total_tank_vol IS
  SELECT sum(volume)total_tank_vol
    FROM v_stor_day_overview_detail
    WHERE storage_id = p_object_id
    AND daytime = p_daytime;

BEGIN

  FOR c_total_tank_vol IN cur_total_tank_vol LOOP
    ln_return_val := nvl(c_total_tank_vol.total_tank_vol,0);
  END LOOP;

  RETURN ln_return_val;

END getTotalTankVol;

---------------------------------------------------------------------------------------------------
-- Function       : getProdDayGrsOpeningVol
-- Description    : Return the OPENING grs vol for a product per storage for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getProdDayGrsOpeningVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Opening is credit - debit for all transactions BEFORE the opening date
--                  Inventory will override the value
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getProdDayGrsOpeningVol (
  p_object_id        storage.object_id%TYPE,
  p_product_id product.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
  ln_return_val NUMBER;

BEGIN
  ln_return_val := ue_storage_proc_plant.getProdDayGrsOpeningVol(p_object_id,p_product_id,p_daytime);
  IF ln_return_val IS NULL THEN
    ln_return_val := ec_storage_measurement.closing_volume(p_object_id,p_product_id,p_daytime,'<');
  END IF;
  RETURN ln_return_val;

END getProdDayGrsOpeningVol;

---------------------------------------------------------------------------------------------------
-- Function       : getProdDayGrsClosingVol
-- Description    : Return the Closing grs vol for a product per product for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getProdDayGrsClosingVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Closing is opening + credit - debit
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getProdDayGrsClosingVol (
  p_object_id        storage.object_id%TYPE,
  p_product_id product.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL)

RETURN NUMBER IS
  ln_return_val NUMBER;

BEGIN

  ln_return_val := ue_storage_proc_plant.getProdDayGrsClosingVol(p_object_id,p_product_id,p_daytime,p_to_daytime);
  IF ln_return_val IS NULL THEN
    ln_return_val := ec_storage_measurement.closing_volume(p_object_id,p_product_id,p_to_daytime,'<=');
  END IF;
  RETURN ln_return_val;

END getProdDayGrsClosingVol;

---------------------------------------------------------------------------------------------------
-- Function       : getProdDayTransVol
-- Description    : Return the total volume a product based on transaction type for a day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getProdTransVol (
    p_object_id product.object_id%TYPE,
    p_company_id company.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL,
    p_trans_type VARCHAR2)

RETURN NUMBER IS
  ln_return_val NUMBER;

CURSOR c_trans_measurement IS
  SELECT sum(tmo.split_volume) volume
    FROM transaction_meas_ownshp tmo
    WHERE tmo.daytime BETWEEN p_daytime AND Nvl(p_to_daytime, p_daytime)
    AND tmo.object_id = p_company_id
    AND tmo.event_no IN (SELECT event_no FROM TRANSACTION_MEASUREMENT tm
    WHERE tm.object_id = p_object_id
    AND tm.transaction_type = p_trans_type);

BEGIN
  ln_return_val  := 0;

  FOR cur_trans_measurement IN c_trans_measurement LOOP
    ln_return_val := cur_trans_measurement.volume;
  END LOOP;


  RETURN ln_return_val;

END getProdTransVol;

---------------------------------------------------------------------------------------------------
-- Function       : getCompDayVol
-- Description    : Return the company split volume for that day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompDayVol (
  p_object_id       company.object_id%TYPE,
  p_daytime          DATE
  )
RETURN NUMBER IS


CURSOR c_trans_meas_ownshp IS
  SELECT tmo.split_volume, tmo.event_no
    FROM transaction_meas_ownshp tmo
    WHERE tmo.object_id = p_object_id
    AND tmo.daytime = p_daytime
    AND tmo.event_no IN ( select event_no from Transaction_Measurement
    where daytime = p_daytime
    and transaction_type NOT IN ('GAIN','LOSS')) ;

  ln_return_val NUMBER;
  ln_total_vol NUMBER;
  ln_volume NUMBER;

BEGIN
  ln_return_val  := 0;
  ln_total_vol :=0;

  FOR cur_trans_meas_ownshp IN c_trans_meas_ownshp LOOP
    IF ec_prosty_codes.alt_code(ec_transaction_measurement.transaction_type(cur_trans_meas_ownshp.event_no),'STOR_TRANS_TYPE') = 'DEB' THEN
      ln_volume := cur_trans_meas_ownshp.split_volume * -1;
    ELSE
      ln_volume :=   cur_trans_meas_ownshp.split_volume ;
    END IF;
    ln_total_vol := ln_total_vol + nvl(ln_volume,0);
  END LOOP;
  ln_return_val := ln_total_vol;

  RETURN ln_return_val;

END getCompDayVol;

---------------------------------------------------------------------------------------------------
-- Function       : createTransactionOwnshp
-- Description    : Create transaction ownership records for each product based on splits in equity share.
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, equity_share
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createTransactionOwnshp(p_event_no  NUMBER)
IS

CURSOR c_equity_share(cp_owner VARCHAR2,cp_daytime DATE) IS
  SELECT *
  FROM equity_share es
  WHERE ecdp_objects.GetObjCode(es.object_id) = cp_owner
  AND es.daytime = (SELECT MAX(es2.daytime) FROM equity_share es2
    WHERE es2.daytime<= cp_daytime
    AND ecdp_objects.GetObjCode(es2.object_id) = cp_owner
    AND nvl(es2.end_date, cp_daytime+1) > cp_daytime)
    AND NOT EXISTS
      (SELECT 1
       FROM TRANSACTION_MEAS_OWNSHP x
       WHERE es.company_id = x.object_id
       AND x.event_no = p_event_no);

  ln_trans_volume NUMBER;
  ln_split_vol NUMBER;

BEGIN
  FOR cur_trans_meas IN  c_transaction_measurement(p_event_no) LOOP
    ln_trans_volume := cur_trans_meas.volume;
      FOR cur_equity_share IN  c_equity_share(cur_trans_meas.ownership_type, cur_trans_meas.daytime) LOOP
        IF ln_trans_volume > 0 THEN
          ln_split_vol := cur_equity_share.eco_share /100 * ln_trans_volume;
        ELSIF ln_trans_volume = 0 THEN
          ln_split_vol := 0;
        END IF;
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_equity_share.company_id,cur_trans_meas.daytime,cur_equity_share.eco_share,ln_split_vol);
      END LOOP;

  END LOOP;

END createTransactionOwnshp;

---------------------------------------------------------------------------------------------------
-- Function       : validateSplitVolume
-- Description    : validate split volume in transaction ownership as total split volumes must sum up to volume in Transaction_Measurement table for the event.
--                  validate split pct to be equal too 100%.
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateSplitVolume(
       p_event_no NUMBER)
IS

  CURSOR c_transaction_meas_ownshp IS
    SELECT  sum(split_volume) total_split_vol, sum(split_pct) total_split_pct
    FROM transaction_meas_ownshp
    WHERE event_no = p_event_no;

    ln_sum NUMBER;
    ln_transVol  NUMBER;

BEGIN
  FOR cur_transaction_measurement IN c_transaction_measurement(p_event_no) LOOP
    IF cur_transaction_measurement.ownership_split_type = 'VOLUME_SPLIT' THEN
      ln_transVol := cur_transaction_measurement.volume;
      FOR cur_transaction_meas_ownshp IN c_transaction_meas_ownshp LOOP
        IF ln_transVol != cur_transaction_meas_ownshp.total_split_vol THEN
          RAISE_APPLICATION_ERROR(-20000,'The sum of split volumes must equal to ' ||  ln_transVol);
        END IF;
      END LOOP;
    ELSIF cur_transaction_measurement.ownership_split_type = 'PCT_SPLIT' THEN
        FOR cur_transaction_meas_ownshp IN c_transaction_meas_ownshp LOOP
          IF cur_transaction_meas_ownshp.total_split_pct != 100 THEN
            RAISE_APPLICATION_ERROR(-20000,'The sum of split percentage must equal to 100 ' );
          END IF;
        END LOOP;
    END IF;
  END LOOP;

 END validateSplitVolume;

---------------------------------------------------------------------------------------------------
-- Procedure       : updateOwnshpVol
-- Description    : calc and update volume, mass and pct in transaction_meas_ownshp
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateOwnshpVol(p_event_no  NUMBER, p_user VARCHAR2)
IS

  ln_trans_vol NUMBER;
  ln_com_vol NUMBER;
  ln_trans_mass NUMBER;
  ln_com_mass NUMBER;

BEGIN
    FOR cur_trans_meas IN  c_transaction_measurement(p_event_no) LOOP
      ln_trans_vol := cur_trans_meas.volume;
      ln_trans_mass := cur_trans_meas.mass;
      FOR cur_trans_meas_ownshp IN c_trans_meas_ownshp(p_event_no) LOOP
        ln_com_vol := cur_trans_meas_ownshp.split_pct/100 * ln_trans_vol;
        ln_com_mass := cur_trans_meas_ownshp.split_pct/100 * ln_trans_mass;
        if cur_trans_meas_ownshp.record_status in ('A','V') then
         UPDATE transaction_meas_ownshp
           SET split_volume = ln_com_vol
            ,split_mass = ln_com_mass
            ,last_updated_by =  Nvl(p_user, ecdp_context.getAppUser())
            , rev_no = rev_no + 1
           WHERE event_no = p_event_no
           AND object_id = cur_trans_meas_ownshp.object_id;
        else
         UPDATE transaction_meas_ownshp
           SET split_volume = ln_com_vol
            ,split_mass = ln_com_mass
            ,last_updated_by =  Nvl(p_user, ecdp_context.getAppUser())
           WHERE event_no = p_event_no
           AND object_id = cur_trans_meas_ownshp.object_id;
        end if;
      END LOOP;
    END LOOP;

END updateOwnshpVol;

---------------------------------------------------------------------------------------------------
-- Procedure       :updateOwnshpType
-- Description    : updates ownship in transaction_meas_ownshp when user updates ownshp type in transaction_measurement
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateOwnshpType(p_event_no  NUMBER)
IS

BEGIN

    DELETE FROM transaction_meas_ownshp where event_no = p_event_no;
    createTransactionOwnshp(p_event_no);

END updateOwnshpType;
---------------------------------------------------------------------------------------------------
-- Procedure       : updateChildOwnshp at child transaction section
-- Description    : calc and update volume and pct in transaction_meas_ownshp
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateChildOwnshp(p_event_no  NUMBER)
IS

  ln_trans_vol NUMBER;
  ln_com_vol NUMBER;
  ln_split_pct NUMBER;
  ln_trans_mass NUMBER;
  ln_split_mass NUMBER;

BEGIN
   FOR cur_trans_meas IN c_transaction_measurement(p_event_no) LOOP
      ln_trans_vol := cur_trans_meas.volume;
      ln_trans_mass := cur_trans_meas.mass;
      IF cur_trans_meas.ownership_split_type = 'VOLUME_SPLIT' THEN
        FOR cur_trans_meas_ownshp IN c_trans_meas_ownshp(p_event_no) LOOP
          IF ln_trans_vol = 0 THEN
             ln_split_pct  := 0;
             ln_split_mass := 0;
          ELSE
             ln_split_pct  := cur_trans_meas_ownshp.split_volume / ln_trans_vol * 100;
             ln_split_mass := ln_trans_mass * ln_split_pct / 100;
          END IF;
          UPDATE transaction_meas_ownshp
          SET split_pct = ln_split_pct
          ,split_mass = ln_split_mass
          ,last_updated_by =  ecdp_context.getAppUser()
          WHERE event_no = p_event_no
          AND object_id = cur_trans_meas_ownshp.object_id;
        END LOOP;
      ELSIF cur_trans_meas.ownership_split_type = 'PCT_SPLIT' THEN
         FOR cur_trans_meas_ownshp IN c_trans_meas_ownshp(p_event_no) LOOP
           ln_split_pct := cur_trans_meas_ownshp.split_pct;
           ln_com_vol := ln_split_pct/100 * ln_trans_vol;
           ln_split_mass := ln_split_pct/100 * ln_trans_mass;
           UPDATE transaction_meas_ownshp
             SET split_volume = ln_com_vol
             ,split_mass = ln_split_mass
             ,last_updated_by =  ecdp_context.getAppUser()
             WHERE event_no = p_event_no
             AND object_id = cur_trans_meas_ownshp.object_id;
         END LOOP;
      END IF;
    END LOOP;

END updateChildOwnshp;

---------------------------------------------------------------------------------------------------
-- Function       : createComplementTrans
-- Description    : Create a complement transaction which has type of BUY,SELL,BORROW,LOAN,REGRADE_IN,REGRADE_OUT
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, equity_share
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createComplementTrans(p_event_no  NUMBER)
IS

  CURSOR c_stor_intermed_prod(cp_storage_id_in VARCHAR2,cp_storage_id_out VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT 1
    FROM stor_intermed_prod sip
    WHERE sip.object_id = nvl(cp_storage_id_in,cp_storage_id_out)
    AND sip.product_id = cp_product_id
    AND sip.daytime <= cp_daytime
    AND nvl(sip.end_date,cp_daytime+1) >cp_daytime;


  lv2_trans_type VARCHAR2(32);
  ln_event_no NUMBER;
  lv2_from_asset_type VARCHAR2(32);
  lv2_from_asset_id VARCHAR2(32);
  lv2_to_asset_type VARCHAR2(32);
  lv2_to_asset_id VARCHAR2(32);
  ln_row_count NUMBER :=0;
  ld_daytime DATE;
  lv2_ownership_type VARCHAR2(32);


BEGIN

  FOR cur_trans_meas_comp IN  c_transaction_measurement(p_event_no) LOOP
    ld_daytime := cur_trans_meas_comp.daytime;
    IF cur_trans_meas_comp.transaction_type IN ('BUY', 'SELL','BORROW','LOAN','TANK_TRANSFER_OUT','TANK_TRANSFER_IN') THEN
      IF cur_trans_meas_comp.transaction_type = 'BUY' THEN
        lv2_trans_type := 'SELL';
      ELSIF  cur_trans_meas_comp.transaction_type = 'SELL' THEN
        lv2_trans_type := 'BUY';
      ELSIF  cur_trans_meas_comp.transaction_type = 'BORROW' THEN
        lv2_trans_type := 'LOAN';
      ELSIF  cur_trans_meas_comp.transaction_type = 'LOAN' THEN
        lv2_trans_type := 'BORROW';
      ELSIF  cur_trans_meas_comp.transaction_type = 'TANK_TRANSFER_OUT' THEN
        lv2_trans_type := 'TANK_TRANSFER_IN';
      ELSIF  cur_trans_meas_comp.transaction_type = 'TANK_TRANSFER_IN' THEN
        lv2_trans_type := 'TANK_TRANSFER_OUT';
      END IF;
	  IF (lv2_trans_type = 'SELL' AND cur_trans_meas_comp.from_asset_type  = 'COMMERCIAL_ENTITY') THEN
        lv2_to_asset_type := cur_trans_meas_comp.from_asset_type;
        lv2_to_asset_id   := ecdp_objects.GetObjIDFromCode('COMMERCIAL_ENTITY',cur_trans_meas_comp.ownership_type);
      ELSIF (lv2_trans_type = 'BUY' AND cur_trans_meas_comp.to_asset_type  = 'COMMERCIAL_ENTITY') THEN
        lv2_from_asset_type := cur_trans_meas_comp.to_asset_type;
        lv2_from_asset_id   := ecdp_objects.GetObjIDFromCode('COMMERCIAL_ENTITY',cur_trans_meas_comp.ownership_type);
      ELSE
        IF cur_trans_meas_comp.from_asset_type IS NOT NULL THEN
          lv2_to_asset_type := cur_trans_meas_comp.from_asset_type;
          lv2_to_asset_id   := cur_trans_meas_comp.from_asset_id;
        ELSIF cur_trans_meas_comp.to_asset_type IS NOT NULL THEN
          lv2_from_asset_type := cur_trans_meas_comp.to_asset_type;
          lv2_from_asset_id   := cur_trans_meas_comp.to_asset_id;
        END IF;
      END IF;
      EcDp_System_Key.assignNextNumber('TRANSACTION_MEASUREMENT', ln_event_no);

      FOR onerow_stor_intermed_prod IN c_stor_intermed_prod(cur_trans_meas_comp.to_asset_id,cur_trans_meas_comp.from_asset_id,cur_trans_meas_comp.object_id,ld_daytime) LOOP
        ln_row_count :=1;
      END LOOP;

      IF (lv2_trans_type = 'TANK_TRANSFER_IN') OR (lv2_trans_type = 'BUY' AND cur_trans_meas_comp.to_asset_type = 'STORAGE') OR (lv2_trans_type = 'BORROW' AND cur_trans_meas_comp.to_asset_type = 'STORAGE') THEN
        IF ln_row_count = 0 THEN
          RAISE_APPLICATION_ERROR(-20624, 'Please ensure a relationship exists between the product and storage.');
        END IF;
        INSERT INTO TRANSACTION_MEASUREMENT (EVENT_NO,LINKED_EVENT_NO,OBJECT_ID,STORAGE_ID,DAYTIME,TRANSACTION_TYPE,FROM_ASSET_TYPE,FROM_ASSET_ID,VOLUME,OWNERSHIP_TYPE,OWNERSHIP_SPLIT_TYPE,CREATED_BY)
        VALUES (ln_event_no,p_event_no,cur_trans_meas_comp.object_id,cur_trans_meas_comp.to_asset_id,cur_trans_meas_comp.daytime,lv2_trans_type,lv2_from_asset_type,cur_trans_meas_comp.storage_id,cur_trans_meas_comp.volume, cur_trans_meas_comp.ownership_type,cur_trans_meas_comp.ownership_split_type, ecdp_context.getAppUser());

      ELSIF (lv2_trans_type = 'TANK_TRANSFER_OUT') OR (lv2_trans_type = 'SELL' AND cur_trans_meas_comp.from_asset_type = 'STORAGE') OR (lv2_trans_type = 'LOAN' AND cur_trans_meas_comp.from_asset_type = 'STORAGE')  THEN
        IF ln_row_count = 0 THEN
          RAISE_APPLICATION_ERROR(-20624, 'Please ensure a relationship exists between the product and storage.');
        END IF;
        INSERT INTO TRANSACTION_MEASUREMENT (EVENT_NO,LINKED_EVENT_NO,OBJECT_ID,STORAGE_ID,DAYTIME,TRANSACTION_TYPE,TO_ASSET_TYPE,TO_ASSET_ID,VOLUME,Ownership_Type,OWNERSHIP_SPLIT_TYPE,Created_By)
          VALUES (ln_event_no,p_event_no,cur_trans_meas_comp.object_id,cur_trans_meas_comp.from_asset_id,cur_trans_meas_comp.daytime,lv2_trans_type,lv2_to_asset_type,cur_trans_meas_comp.storage_id, cur_trans_meas_comp.volume, cur_trans_meas_comp.ownership_type,cur_trans_meas_comp.ownership_split_type, ecdp_context.getAppUser());
      ELSE
         IF (lv2_trans_type = 'BUY' AND (lv2_from_asset_type  = 'COMPANY' OR lv2_from_asset_type  = 'COMMERCIAL_ENTITY')) OR (lv2_trans_type = 'SELL' AND  (lv2_to_asset_type  = 'COMPANY' OR lv2_to_asset_type  = 'COMMERCIAL_ENTITY')) OR (lv2_trans_type = 'LOAN' AND lv2_to_asset_type  = 'COMPANY') OR (lv2_trans_type = 'BORROW' AND lv2_from_asset_type  = 'COMPANY')   THEN
          lv2_ownership_type := 'GENERATED';
        ELSE
          lv2_ownership_type :=  cur_trans_meas_comp.ownership_type;
        END IF;
        INSERT INTO TRANSACTION_MEASUREMENT (EVENT_NO,LINKED_EVENT_NO,OBJECT_ID,STORAGE_ID,DAYTIME,TRANSACTION_TYPE,FROM_ASSET_TYPE,From_Asset_Id,TO_ASSET_TYPE,TO_ASSET_ID,VOLUME,Ownership_Type,OWNERSHIP_SPLIT_TYPE,Created_By)
        VALUES (ln_event_no,p_event_no,cur_trans_meas_comp.object_id,cur_trans_meas_comp.storage_id,cur_trans_meas_comp.daytime,lv2_trans_type,lv2_from_asset_type,lv2_from_asset_id,lv2_to_asset_type,lv2_to_asset_id, cur_trans_meas_comp.volume,  lv2_ownership_type,cur_trans_meas_comp.ownership_split_type, ecdp_context.getAppUser());
      END IF;

      insertRecalculateStorageMeas(ln_event_no);
      -- link the event with the new event
      UPDATE transaction_measurement
      SET linked_event_no = ln_event_no
      ,last_updated_by = ecdp_context.getAppUser()
      WHERE event_no = p_event_no;
      END IF;
    END LOOP;
    -- create ownership records for the new transaction
    createComplementTransOwnshp(ln_event_no);

END  createComplementTrans;


---------------------------------------------------------------------------------------------------
-- Procedure       : updateComplementTrans
-- Description    :  update the linked event when the transaction is updated
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateComplementTrans(p_event_no  NUMBER, p_user VARCHAR2)
IS

  ln_linked_event_no NUMBER;
  ln_volume NUMBER;
  ln_mass NUMBER;

BEGIN
      ln_linked_event_no := ec_transaction_measurement.linked_event_no(p_event_no);
      ln_volume := ec_transaction_measurement.volume(p_event_no);
      ln_mass := ec_transaction_measurement.mass(p_event_no);
      UPDATE TRANSACTION_MEASUREMENT
      SET volume = ln_volume
      ,mass = ln_mass
      ,last_updated_by =  Nvl(p_user, ecdp_context.getAppUser())
      WHERE event_no = ln_linked_event_no;
      updateRecalculateStorageMeas(ln_linked_event_no);
      --Update ownership records
      updateOwnshpVol(ln_linked_event_no, p_user);

END updateComplementTrans;

---------------------------------------------------------------------------------------------------
-- Procedure       : deleteComplementEvent
-- Description    :  delete linked event when another linked event is deleted
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteComplementTrans(p_event_no  NUMBER)
IS


CURSOR c_trans_meas_linked IS
  SELECT *
  FROM transaction_measurement tm
  WHERE tm.linked_event_no = p_event_no;

BEGIN
      FOR cur_trans_meas_linked IN c_trans_meas_linked LOOP

        deleteRecalculateStorageMeas(cur_trans_meas_linked.event_no);
        DELETE FROM transaction_meas_ownshp WHERE event_no = cur_trans_meas_linked.event_no;
        DELETE FROM transaction_measurement WHERE event_no = cur_trans_meas_linked.event_no;
      END LOOP;

END deleteComplementTrans;

---------------------------------------------------------------------------------------------------
-- Function       : createRegradeTrans
-- Description    : Create a complement transaction which has type of REGRADE_IN,REGRADE_OUT.
--                  User exit is supported to create ownerships at ue_storage_proc_plant.createRegradeOwnship().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, equity_share
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createRegradeTrans(p_event_no  NUMBER)
IS

  lv2_trans_type VARCHAR2(32);
  ln_event_no NUMBER;
  lv2_from_asset_type VARCHAR2(32);
  lv2_from_asset_id VARCHAR2(32);
  lv2_to_asset_type VARCHAR2(32);
  lv2_to_asset_id VARCHAR2(32);

BEGIN
    EcDp_System_Key.assignNextNumber('TRANSACTION_MEASUREMENT', ln_event_no);
    FOR cur_trans_meas_comp IN  c_transaction_measurement(p_event_no) LOOP
      IF cur_trans_meas_comp.transaction_type = 'REGRADE_OUT' THEN
        lv2_trans_type := 'REGRADE_IN';
        lv2_from_asset_type := 'PRODUCT';
        lv2_from_asset_id   := cur_trans_meas_comp.object_id;
        lv2_to_asset_type := null;
        lv2_to_asset_id := null;

        INSERT INTO TRANSACTION_MEASUREMENT (EVENT_NO,LINKED_EVENT_NO,OBJECT_ID,STORAGE_ID,DAYTIME,TRANSACTION_TYPE,FROM_ASSET_TYPE,From_Asset_Id,TO_ASSET_TYPE,TO_ASSET_ID,VOLUME,Ownership_Type,OWNERSHIP_SPLIT_TYPE,Created_By)
        VALUES (ln_event_no,p_event_no,cur_trans_meas_comp.to_asset_id,cur_trans_meas_comp.storage_id,cur_trans_meas_comp.daytime,lv2_trans_type,lv2_from_asset_type,lv2_from_asset_id,lv2_to_asset_type,lv2_to_asset_id, cur_trans_meas_comp.volume, cur_trans_meas_comp.ownership_type,cur_trans_meas_comp.ownership_split_type, ecdp_context.getAppUser());
         -- link the event with the new event
        UPDATE transaction_measurement
        SET linked_event_no = ln_event_no
        ,last_updated_by = ecdp_context.getAppUser()
        WHERE event_no = p_event_no;

      ELSIF  cur_trans_meas_comp.transaction_type = 'REGRADE_IN' THEN
        lv2_trans_type := 'REGRADE_OUT';
        lv2_to_asset_type := 'PRODUCT';
        lv2_to_asset_id   := cur_trans_meas_comp.object_id;
        lv2_from_asset_type := null;
        lv2_from_asset_id := null;

        INSERT INTO TRANSACTION_MEASUREMENT (EVENT_NO,LINKED_EVENT_NO,OBJECT_ID,STORAGE_ID,DAYTIME,TRANSACTION_TYPE,FROM_ASSET_TYPE,From_Asset_Id,TO_ASSET_TYPE,TO_ASSET_ID,VOLUME,Ownership_Type,OWNERSHIP_SPLIT_TYPE,Created_By)
        VALUES (ln_event_no,p_event_no,cur_trans_meas_comp.from_asset_id,cur_trans_meas_comp.storage_id,cur_trans_meas_comp.daytime,lv2_trans_type,lv2_from_asset_type,lv2_from_asset_id,lv2_to_asset_type,lv2_to_asset_id, cur_trans_meas_comp.volume, cur_trans_meas_comp.ownership_type,cur_trans_meas_comp.ownership_split_type, ecdp_context.getAppUser());
        -- link the event with the new event
        UPDATE transaction_measurement
        SET linked_event_no = ln_event_no
        ,last_updated_by = ecdp_context.getAppUser()
        WHERE event_no = p_event_no;
      END IF;
    END LOOP;
    IF lv2_trans_type IN ('REGRADE_IN', 'REGRADE_OUT') THEN
      ue_storage_proc_plant.createRegradeOwnship(ln_event_no);
      insertRecalculateStorageMeas(ln_event_no);
      createTransactionOwnshp(ln_event_no);
    END IF;
END  createRegradeTrans;

---------------------------------------------------------------------------------------------------
-- Function       : createBlendContent
-- Description    : Create blend content records for each batch based on setting in blend content screen and storage intermediate product screen
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_batch, blend_content, stor_blend_meas, stor_intermed_prod
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createBlendContent(p_event_no  NUMBER)
IS

CURSOR c_blend_batch IS
SELECT *
FROM stor_blend_batch sbb
WHERE sbb.event_no = p_event_no;

CURSOR c_blend_content(cp_blend_id VARCHAR2,cp_daytime DATE) IS
SELECT *
FROM blend_content bc
WHERE bc.object_id = cp_blend_id
and bc.daytime <= cp_daytime
and nvl(bc.end_date, cp_daytime+1) > cp_daytime
and  bc.daytime = (select max(bc.daytime) from blend_content bc2 where
bc2.daytime <= cp_daytime
AND nvl(bc2.end_date, cp_daytime+1) > cp_daytime)
AND NOT EXISTS
            (SELECT 1
             FROM stor_blend_meas x
             WHERE bc.product_id = x.object_id
             AND x.event_no = p_event_no);

CURSOR c_stor_intermed_prod(cp_product_id VARCHAR2,cp_daytime DATE) IS
SELECT *
FROM stor_intermed_prod
WHERE product_id = cp_product_id
and daytime <= cp_daytime
and nvl(end_date, cp_daytime+1) > cp_daytime;

ln_totalVol NUMBER;
ln_pct_vol NUMBER;
ln_prod_vol NUMBER;
ln_stor_id VARCHAR2(32);

BEGIN

    FOR cur_blend_batch IN  c_blend_batch LOOP
      FOR cur_blend_content IN  c_blend_content(cur_blend_batch.blend_id, cur_blend_batch.daytime) LOOP
      ln_totalVol := nvl(ec_stor_blend_batch.volume(p_event_no),0);
      ln_pct_vol := nvl((cur_blend_content.product_split*100),0);
      IF ln_totalVol IS NULL THEN
         ln_prod_vol := 0;
      ELSE
         ln_prod_vol := ln_pct_vol * ln_totalVol / 100;
      END IF;
      FOR cur_stor_intermed_prod IN c_stor_intermed_prod (cur_blend_content.product_id, cur_blend_content.daytime)LOOP
        EXIT WHEN c_stor_intermed_prod%notfound;
        IF c_stor_intermed_prod%ROWCOUNT =1 THEN
          ln_stor_id := cur_stor_intermed_prod.object_id;
        ELSE
          ln_stor_id  := null;
        END IF;
      END LOOP;
         INSERT INTO STOR_BLEND_MEAS (EVENT_NO,OBJECT_ID,DAYTIME,BLEND_ID,VOLUME,STORAGE_ID,CREATED_BY)
         VALUES (p_event_no,cur_blend_content.product_id,cur_blend_batch.daytime,cur_blend_content.object_id,ln_prod_vol,ln_stor_id,ecdp_context.getAppUser);
      END LOOP;
    END LOOP;

END createBlendContent;

---------------------------------------------------------------------------------------------------
-- Function       : validateBlendSplitVolume
-- Description    :
--                  validate split pct to be equal too 100%.
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateBlendSplitVolume(
       p_event_no NUMBER)
IS

  CURSOR c_stor_blend_batch (cp_event_no NUMBER) IS
  SELECT *
  FROM stor_blend_batch
  WHERE event_no = cp_event_no;

  CURSOR c_stor_blend_ownshp IS
  SELECT  sum(split_volume) total_split_vol, sum(split_pct) total_split_pct
  FROM stor_blend_ownshp
  WHERE event_no = p_event_no;

  ln_sum NUMBER;
  ln_transVol  NUMBER;

BEGIN
  FOR cur_stor_blend_batch IN c_stor_blend_batch(p_event_no) LOOP
    IF cur_stor_blend_batch.owner_split_type = 'VOLUME_SPLIT' THEN
      ln_transVol := cur_stor_blend_batch.volume;
      FOR cur_stor_blend_ownshp IN c_stor_blend_ownshp LOOP
        IF ln_transVol != cur_stor_blend_ownshp.total_split_vol THEN
          RAISE_APPLICATION_ERROR(-20617, 'The sum of volumes must equal to batches volume.');
        END IF;
      END LOOP;
    ELSIF cur_stor_blend_batch.owner_split_type = 'PCT_SPLIT' THEN
        FOR cur_stor_blend_ownshp IN c_stor_blend_ownshp LOOP
          IF cur_stor_blend_ownshp.total_split_pct != 100 THEN
            RAISE_APPLICATION_ERROR(-20619,'The sum of split percentage must equal to 100.' );
          END IF;
        END LOOP;
    END IF;
  END LOOP;

 END validateBlendSplitVolume;
---------------------------------------------------------------------------------------------------
-- Function       : validateBlendContentVolume
-- Description    : The sum of volumes must equal to batches volume
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_batch, stor_blend_meas
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateBlendContentVolume(
       p_event_no NUMBER)
IS

  CURSOR c_stor_blend_batch (cp_event_no NUMBER) IS
  SELECT *
  FROM stor_blend_batch
  WHERE event_no = cp_event_no;

  CURSOR c_stor_blend_content IS
  SELECT  sum(volume) total_vol
  FROM stor_blend_meas
  WHERE event_no = p_event_no;

  ln_sum NUMBER;
  ln_transVol  NUMBER;

BEGIN
  FOR cur_stor_blend_batch IN c_stor_blend_batch(p_event_no) LOOP
    IF ec_prosty_codes.alt_code('BLEND_VOLUME_VALIDATION','BLEND_VALIDATION') = 'Y' THEN
      ln_transVol := cur_stor_blend_batch.volume;
      FOR cur_stor_blend_content IN c_stor_blend_content LOOP
        IF ln_transVol != cur_stor_blend_content.total_vol THEN
          RAISE_APPLICATION_ERROR(-20617, 'The sum of volumes must equal to batches volume.');
        END IF;
      END LOOP;
    ELSE
      ln_transVol := cur_stor_blend_batch.volume;
    END IF;
  END LOOP;

 END validateBlendContentVolume;

---------------------------------------------------------------------------------------------------
-- Function       : getActualVolume
-- Description    : Get actual volume for a product
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_meas
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getActualVolume (
       p_object_id  VARCHAR2,
       p_event_no NUMBER)

RETURN NUMBER IS
ln_return_val NUMBER;
ln_totalVol NUMBER;
ln_prod_vol NUMBER;
ln_actual_vol NUMBER;

CURSOR c_stor_blend_content IS
SELECT  volume
FROM stor_blend_meas
WHERE event_no = p_event_no
and object_id = p_object_id;

BEGIN

  FOR cur_stor_blend_content IN c_stor_blend_content LOOP
      ln_totalVol := nvl(ec_stor_blend_batch.volume(p_event_no),0);
      ln_prod_vol := nvl(cur_stor_blend_content.volume,0);
      IF ln_totalVol = 0 THEN
         ln_actual_vol := 0;
      ELSE
         ln_actual_vol := ln_prod_vol * 100/ln_totalVol;
      END IF;
  END LOOP;

  ln_return_val := ln_actual_vol;

  RETURN ln_return_val;

END getActualVolume;

---------------------------------------------------------------------------------------------------
-- Function       : getCompDayGrsOpeningVol
-- Description    : Return the OPENING grs vol for a company per product for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getCompDayGrsOpeningVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompDayGrsOpeningVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS

  ln_return_val NUMBER;
  ln_total_debit_vol NUMBER;
  ln_total_credit_vol NUMBER;

CURSOR c_trans_meas_ownship_debit IS
  SELECT sum(tmo.split_volume) total_vol_debit
    FROM transaction_meas_ownshp tmo, transaction_measurement tm
    WHERE tmo.object_id = p_company_id
    AND tmo.daytime < p_daytime
    AND tmo.event_no = tm.event_no
    AND tm.object_id = p_object_id
    AND tm.transaction_type iN (select code from prosty_codes where code_type = 'STOR_TRANS_TYPE'
    AND alt_code = 'DEB');

CURSOR c_trans_meas_ownship_credit IS
  SELECT sum(tmo.split_volume) total_vol_credit
    FROM transaction_meas_ownshp tmo, transaction_measurement tm
    WHERE tmo.object_id = p_company_id
    AND tmo.daytime < p_daytime
    AND tmo.event_no = tm.event_no
    AND tm.object_id = p_object_id
    AND tm.transaction_type iN (select code from prosty_codes where code_type = 'STOR_TRANS_TYPE'
    AND alt_code = 'CRED');

BEGIN
    ln_return_val := ue_storage_proc_plant.getCompDayGrsOpeningVol(p_object_id,p_company_id,p_daytime);
    IF ln_return_val IS NULL THEN
      ln_return_val := 0;
      FOR cur_trans_meas_ownship_debit IN c_trans_meas_ownship_debit LOOP
        ln_total_debit_vol := cur_trans_meas_ownship_debit.total_vol_debit;
      END LOOP;
      FOR cur_trans_meas_ownship_credit IN c_trans_meas_ownship_credit LOOP
        ln_total_credit_vol := cur_trans_meas_ownship_credit.total_vol_credit;
      END LOOP;
      ln_return_val := nvl(ln_total_credit_vol,0) - nvl(ln_total_debit_vol,0) ;
    END IF;
  RETURN ln_return_val;

END getCompDayGrsOpeningVol;


---------------------------------------------------------------------------------------------------
-- Function       : getCompDayGrsClosingVol
-- Description    : Return the CLOSING grs vol for a company per product for a day.Return the OPENING grs vol for a company per product for a day.
--                  User exit is supported for this function at ue_storage_proc_plant.getCompDayGrsClosingVol().
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompDayGrsClosingVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL )

RETURN NUMBER IS

  ln_return_val NUMBER;
  ln_total_debit_vol NUMBER;
  ln_total_credit_vol NUMBER;
  ln_opening_vol NUMBER;

CURSOR c_trans_meas_ownshp_debit IS
  SELECT sum(tmo.split_volume) total_vol_debit
    FROM transaction_meas_ownshp tmo, transaction_measurement tm
    WHERE tmo.object_id = p_company_id
    AND tmo.daytime BETWEEN p_daytime AND Nvl(p_to_daytime, p_daytime)
    AND tmo.event_no = tm.event_no
    AND tm.object_id = p_object_id
    AND tm.transaction_type iN (select code from prosty_codes where code_type = 'STOR_TRANS_TYPE'
    AND alt_code = 'DEB');

CURSOR c_trans_meas_ownshp_credit IS
  SELECT sum(tmo.split_volume) total_vol_credit
    FROM transaction_meas_ownshp tmo, transaction_measurement tm
    WHERE tmo.object_id = p_company_id
    AND tmo.daytime BETWEEN p_daytime AND Nvl(p_to_daytime, p_daytime)
    AND tmo.event_no = tm.event_no
    AND tm.object_id = p_object_id
    AND tm.transaction_type iN (select code from prosty_codes where code_type = 'STOR_TRANS_TYPE'
    AND alt_code = 'CRED');


BEGIN

  ln_return_val := ue_storage_proc_plant.getCompDayGrsClosingVol(p_object_id,p_company_id,p_daytime,p_to_daytime);
  IF ln_return_val IS NULL THEN
    ln_return_val  := 0;
    ln_total_debit_vol := 0;
    ln_total_credit_vol := 0;
    ln_opening_vol := getCompDayGrsOpeningVol(p_object_id, p_company_id,p_daytime);
    FOR cur_trans_meas_ownshp_debit IN c_trans_meas_ownshp_debit LOOP
      ln_total_debit_vol := ln_total_debit_vol + nvl(cur_trans_meas_ownshp_debit.total_vol_debit,0);
    END LOOP;
    FOR cur_trans_meas_ownshp_credit IN c_trans_meas_ownshp_credit LOOP
      ln_total_credit_vol := ln_total_credit_vol +  nvl(cur_trans_meas_ownshp_credit.total_vol_credit,0);
    END LOOP;
    ln_return_val :=  ln_opening_vol + nvl(ln_total_credit_vol,0) - nvl(ln_total_debit_vol,0) ;
  END IF;
  RETURN ln_return_val;

END getCompDayGrsClosingVol;

---------------------------------------------------------------------------------------------------
-- Function       : getTotalProdTransVol
-- Description    : return the total of a product per day based on transaction type
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalProdTransVol (
    p_object_id product.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL,
    p_trans_type VARCHAR2)

RETURN NUMBER IS
ln_return_val NUMBER;


CURSOR c_trans_measurement IS
  SELECT sum(tm.volume) total_volume
    FROM transaction_measurement tm
    WHERE tm.daytime BETWEEN p_daytime AND Nvl(p_to_daytime, p_daytime)
    AND tm.object_id = p_object_id
    AND tm.transaction_type = p_trans_type;

BEGIN
  ln_return_val  := 0;

  FOR cur_trans_measurement IN c_trans_measurement LOOP
    ln_return_val := cur_trans_measurement.total_volume;
  END LOOP;

  RETURN ln_return_val;

END getTotalProdTransVol;


---------------------------------------------------------------------------------------------------
-- Function       : getTotalProdGrsOpeningVol
-- Description    : Return the OPENING grs vol for a product for a day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalProdGrsOpeningVol (
  p_object_id         product.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER IS
  ln_return_val NUMBER;

CURSOR c_stor_intermed_storage IS
  SELECT *
  FROM stor_intermed_prod sip
  WHERE sip.product_id = p_object_id
  AND sip.daytime <= p_daytime
  AND nvl(sip.end_date,p_daytime+1) > p_daytime;

BEGIN
  ln_return_val := 0;
  FOR  cur_stor_intermed_storage IN  c_stor_intermed_storage LOOP
    ln_return_val := nvl(ln_return_val,0) + getProdDayGrsOpeningVol(cur_stor_intermed_storage.object_id,p_object_id,p_daytime);
  END LOOP;
  RETURN ln_return_val;

END getTotalProdGrsOpeningVol;

---------------------------------------------------------------------------------------------------
-- Function       : getTotalProdGrsClosingVol
-- Description    : Return the Closing grs vol for a product for a day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  getTotalProdGrsClosingVol (
  p_object_id        product.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL)

RETURN NUMBER IS
    ln_return_val NUMBER;

CURSOR c_stor_intermed_storage IS
  SELECT *
  FROM stor_intermed_prod sip
  WHERE sip.product_id = p_object_id
  AND sip.daytime <= p_daytime
  AND nvl(sip.end_date,p_daytime+1) > p_daytime;

BEGIN
  ln_return_val  := 0;
  FOR  cur_stor_intermed_storage IN  c_stor_intermed_storage LOOP
    ln_return_val := nvl(ln_return_val,0) + getProdDayGrsClosingVol(cur_stor_intermed_storage.object_id,p_object_id,p_to_daytime,p_to_daytime);
  END LOOP;

  RETURN ln_return_val;

END  getTotalProdGrsClosingVol;


---------------------------------------------------------------------------------------------------
-- Procedure      : updateBlendContent
-- Description    :
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateBlendContent(p_event_no  NUMBER)
IS

CURSOR c_blend_batch IS
SELECT *
FROM stor_blend_batch sbb
WHERE sbb.event_no = p_event_no;

CURSOR c_blend_content(cp_blend_id VARCHAR2,cp_daytime DATE) IS
SELECT *
FROM blend_content bc
WHERE bc.object_id = cp_blend_id
and bc.daytime <= cp_daytime
and nvl(bc.end_date, cp_daytime+1) > cp_daytime
and  bc.daytime = (select max(bc.daytime) from blend_content bc2 where
bc2.daytime <= cp_daytime
AND nvl(bc2.end_date, cp_daytime+1) > cp_daytime);

ln_totalVol NUMBER;
ln_pct_vol NUMBER;
ln_prod_vol NUMBER;

BEGIN

    FOR cur_blend_batch IN  c_blend_batch LOOP
      ln_totalVol := nvl(cur_blend_batch.volume,0);
      FOR cur_blend_content IN  c_blend_content(cur_blend_batch.blend_id, cur_blend_batch.daytime) LOOP
        ln_pct_vol := nvl((cur_blend_content.product_split*100),0);
        IF ln_totalVol IS NULL THEN
           ln_prod_vol := 0;
        ELSE
           ln_prod_vol := ln_pct_vol * ln_totalVol / 100;
        END IF;
        UPDATE stor_blend_meas
                SET volume = ln_prod_vol
                ,last_updated_by = ecdp_context.getAppUser()
                WHERE event_no =  p_event_no
                AND object_id = cur_blend_content.product_id;
        END LOOP;
    END LOOP;
    updateBlendTrans(p_event_no,ecdp_context.getAppUser());
END updateBlendContent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveSelectedBatch
-- Description    : The Procedure approves the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : transaction_measurement, stor_blend_batch, stor_blend_meas, stor_blend_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveSelectedBatch(p_event_no VARCHAR2,
                         p_user_name VARCHAR2)
--</EC-DOC>
IS

CURSOR c_stor_blend_meas IS
SELECT *
FROM stor_blend_meas
WHERE event_no = p_event_no;

CURSOR c_blend_ownshp IS
SELECT *
FROM stor_blend_ownshp bo
WHERE bo.event_no = p_event_no;

  lv2_last_update_date VARCHAR2(20);
  ln_stor_id VARCHAR2(32);
  ln_event_no NUMBER;
  ln_prod_vol NUMBER;
  ln_prod_event_vol NUMBER;
  ln_vol_ownership NUMBER;
  ln_split_pct NUMBER;
  ln_count NUMBER;
  ln_prod_mass NUMBER;
  ln_mass_ownership NUMBER;

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  ln_count :=0;
  FOR cur_blend_ownshp IN c_blend_ownshp LOOP
    ln_count := ln_count + 1;
  END LOOP;

  FOR cur_stor_blend_meas IN c_stor_blend_meas LOOP
    ln_stor_id := ec_stor_blend_meas.storage_id(p_event_no,cur_stor_blend_meas.object_id);
    ln_prod_vol := cur_stor_blend_meas.volume;
    ln_prod_event_vol := cur_stor_blend_meas.event_no;
    IF cur_stor_blend_meas.record_status != 'A'THEN
      IF ln_stor_id is null THEN
        RAISE_APPLICATION_ERROR(-20618,'Storage is missing in blend content records. Approval of batch cannot be executed.');
      ELSIF ln_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20621,'Blend Ownership is empty. Approval of batch cannot be executed.');
      ELSE
        EcDp_System_Key.assignNextNumber('TRANSACTION_MEASUREMENT', ln_event_no);
      -- Update parent
        ln_prod_mass := calcBlendContentMass(cur_stor_blend_meas.object_id,ln_prod_event_vol);
        INSERT INTO transaction_measurement(event_no,object_id,storage_id,daytime,transaction_type,from_asset_type,from_asset_id,volume,mass,ownership_type,ownership_split_type,linked_event_no,record_status,created_by)
        VALUES (ln_event_no,cur_stor_blend_meas.object_id,cur_stor_blend_meas.storage_id,cur_stor_blend_meas.daytime,'BLEND_IN','BLEND',ec_stor_blend_batch.blend_id(p_event_no),cur_stor_blend_meas.volume,ln_prod_mass,
        'GENERATED','VOLUME_SPLIT',p_event_no,'A',p_user_name);
        -- insert into storage_measurement
        insertRecalculateStorageMeas(ln_event_no);

        UPDATE  stor_blend_batch
           SET blend_status = 'APPROVED',
               record_status='A',
               last_updated_by = p_user_name,
               last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               rev_text = 'Approved at ' ||  lv2_last_update_date
        WHERE event_no = p_event_no;

      -- update child
        UPDATE stor_blend_meas
           SET linked_event_no = ln_event_no,
               record_status='A',
               last_updated_by = p_user_name,
               last_updated_date = last_updated_date,
               rev_text = 'Approved at ' ||  lv2_last_update_date
        WHERE event_no = p_event_no
		and object_id = cur_stor_blend_meas.object_id
        and storage_id is not null;

      -- update child
        UPDATE stor_blend_ownshp
           SET record_status='A',
               last_updated_by = p_user_name,
               last_updated_date = last_updated_date,
               rev_text = 'Approved at ' ||  lv2_last_update_date
        WHERE event_no = p_event_no;

        FOR cur_blend_ownshp IN c_blend_ownshp LOOP
         ln_split_pct := cur_blend_ownshp.split_pct;
         ln_vol_ownership := nvl((ln_prod_vol * ln_split_pct/100),0);
         ln_mass_ownership := nvl((ln_prod_mass * ln_split_pct/100),0);
         INSERT INTO transaction_meas_ownshp(event_no,object_id,daytime,split_volume,split_mass,split_pct,record_status,created_by)
         VALUES (ln_event_no,cur_blend_ownshp.object_id,cur_blend_ownshp.daytime,ln_vol_ownership,ln_mass_ownership,ln_split_pct,'A',p_user_name);
        END LOOP;

      END IF;
    END IF;
  END LOOP;
END approveSelectedBatch;

---------------------------------------------------------------------------------------------------
-- Procedure      : updateBlendOwnshp
-- Description    : calc and update volume and pct in stor_blend_ownshp
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_ownshp, stor_blend_batch
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateBlendOwnshp(p_event_no  NUMBER)
IS

CURSOR c_blend_batch IS
SELECT *
FROM stor_blend_batch sbb
WHERE sbb.event_no = p_event_no;

CURSOR c_blend_ownshp IS
SELECT *
FROM stor_blend_ownshp bo
WHERE bo.event_no = p_event_no;

ln_totalVol NUMBER;
ln_split_vol NUMBER;
ln_split_pct NUMBER;
ln_split_type VARCHAR2(32);

BEGIN

   FOR cur_blend_batch IN  c_blend_batch LOOP
    ln_totalVol := nvl(cur_blend_batch.volume,0);
    ln_split_type := cur_blend_batch.owner_split_type;

    IF ln_split_type = 'VOLUME_SPLIT' THEN
      FOR cur_blend_ownshp IN c_blend_ownshp LOOP
        ln_split_vol := nvl(cur_blend_ownshp.split_volume,0);
        IF ln_totalVol > 0 THEN
            ln_split_pct := ln_split_vol / ln_totalVol * 100;

            UPDATE stor_blend_ownshp
              SET split_pct = ln_split_pct
              ,last_updated_by = ecdp_context.getAppUser()
              WHERE event_no =  p_event_no
              AND object_id = cur_blend_ownshp.object_id
              AND daytime = cur_blend_ownshp.daytime;
        ELSE
            ln_split_pct := 0;

            UPDATE stor_blend_ownshp
              SET split_pct = ln_split_pct,
              split_volume = ln_totalVol    --ownership volume will always 0 if batch volume is null
              ,last_updated_by = ecdp_context.getAppUser()
              WHERE event_no =  p_event_no
              AND object_id = cur_blend_ownshp.object_id
              AND daytime = cur_blend_ownshp.daytime;

        END IF;
      END LOOP;
	  ELSIF ln_split_type = 'PCT_SPLIT' THEN
	    FOR cur_blend_ownshp IN c_blend_ownshp LOOP
	    ln_split_pct := nvl(cur_blend_ownshp.split_pct,0);
    		IF ln_totalVol > 0 THEN
    		ln_split_vol := ln_split_pct / 100 * ln_totalVol;
    		ELSE
    		ln_split_vol := 0;
    		END IF;
  			    UPDATE stor_blend_ownshp
        			SET split_volume = ln_split_vol
        			,last_updated_by = ecdp_context.getAppUser()
        			WHERE event_no =  p_event_no
        			AND object_id = cur_blend_ownshp.object_id
        			AND daytime = cur_blend_ownshp.daytime;
  	  END LOOP;
	  END IF;
   END LOOP;
END updateBlendOwnshp;

---------------------------------------------------------------------------------------------------
-- Procedure      : updateVolBlendOwnshp
-- Description    : calc and update volume in stor_blend_ownshp
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_ownshp, stor_blend_batch
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateVolBlendOwnshp(p_event_no  NUMBER)
IS

CURSOR c_blend_batch IS
SELECT *
FROM stor_blend_batch sbb
WHERE sbb.event_no = p_event_no;

CURSOR c_blend_ownshp IS
SELECT *
FROM stor_blend_ownshp bo
WHERE bo.event_no = p_event_no;

ln_totalVol NUMBER;
ln_pct_vol NUMBER;
ln_split_vol NUMBER;

BEGIN

    FOR cur_blend_batch IN  c_blend_batch LOOP
      ln_totalVol := nvl(cur_blend_batch.volume,0);
      FOR cur_blend_ownshp IN  c_blend_ownshp LOOP
      ln_pct_vol := nvl((cur_blend_ownshp.split_pct/100),0);
      IF ln_totalVol IS NULL THEN
         ln_split_vol := 0;
      ELSE
         ln_split_vol := ln_pct_vol * ln_totalVol;
      END IF;
      UPDATE stor_blend_ownshp
              SET split_volume = ln_split_vol
              ,last_updated_by = ecdp_context.getAppUser()
              WHERE event_no =  p_event_no
              AND object_id = cur_blend_ownshp.object_id
              AND daytime = cur_blend_ownshp.daytime;
      END LOOP;
    END LOOP;
END updateVolBlendOwnshp;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : stor_blend_meas, stor_blend_ownshp
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_event_no  NUMBER)
IS

CURSOR c_batches_child IS
  SELECT *
  FROM stor_blend_batch
  WHERE event_no = p_event_no;

BEGIN
      FOR cur_batches_child IN c_batches_child LOOP
           DELETE FROM stor_blend_ownshp WHERE event_no = cur_batches_child.event_no;
           DELETE FROM stor_blend_meas WHERE event_no = cur_batches_child.event_no;
      END LOOP;
	  deleteComplementTrans(p_event_no);
END deleteChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertRecalculateStorageMeas
-- Description    : Updates/inserts volume in Storage Measurement when a record is inserted in transaction_measurement
--                  It is called after the selected record is inserted.
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : storage_measurement, transaction_measurement
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertRecalculateStorageMeas(p_event_no NUMBER)
IS


CURSOR c_stor_meas_exist(cp_storage_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT 1
    FROM storage_measurement
    WHERE object_id =  cp_storage_id
    AND product_id = cp_product_id
    AND daytime =  cp_daytime;

CURSOR c_trans_overview_event(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT tm.object_id, tm.storage_id, tm.volume, tm.daytime, pc.alt_code, tm.transaction_type
  FROM transaction_measurement tm, prosty_codes pc
  WHERE tm.storage_id= cp_storage_id
  AND tm.object_id = cp_product_id
  AND tm.daytime > cp_daytime
  AND tm.transaction_type =  pc.code
  AND pc.code_type = 'STOR_TRANS_TYPE'
  ORDER by daytime;

  lv2_storage_id VARCHAR2(32);
  lv2_product_id VARCHAR2(32);
  ln_prev_storage_vol NUMBER;
  ln_inventory_event_exists NUMBER := 0;
  ln_storage_vol NUMBER;
  ln_newvolume NUMBER;
  ln_row_count NUMBER :=0;
  ld_daytime DATE;


BEGIN

   ld_daytime :=  ec_transaction_measurement.daytime(p_event_no);
   lv2_storage_id := ec_transaction_measurement.storage_id(p_event_no);
   lv2_product_id :=ec_transaction_measurement.object_id(p_event_no);

   FOR onerow_stor_meas IN c_stor_meas_exist(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
     ln_row_count :=1;
     EXIT;
   END LOOP;
   FOR onerow_trans_inv_exist IN c_trans_inventory_exist(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
     ln_inventory_event_exists :=1;
     EXIT;
   END LOOP;
   IF ln_row_count = 0 then -- if no entry found in storage_measurement, then we do an insert
     FOR cur_trans_meas IN  c_trans_meas_recalculate(p_event_no) LOOP
       IF cur_trans_meas.transaction_type != 'INVENTORY' THEN
         IF cur_trans_meas.alt_code = 'CRED' THEN
           ln_newvolume :=  nvl(ec_storage_measurement.closing_volume(lv2_storage_id,lv2_product_id,ld_daytime,'<'),0) + cur_trans_meas.volume;
         ELSE
           ln_newvolume :=  nvl(ec_storage_measurement.closing_volume(lv2_storage_id,lv2_product_id,ld_daytime,'<'),0)  - cur_trans_meas.volume;
         END IF;
       ELSE
         ln_newvolume :=   cur_trans_meas.volume;
       END IF;
     END LOOP;
     INSERT INTO storage_measurement (object_id, product_id,daytime,closing_volume) VALUES (lv2_storage_id,lv2_product_id,ld_daytime,ln_newvolume);
   ELSE -- there is existing entry in storage_measurement, then we do an update
     IF ln_inventory_event_exists > 0 then -- if inventory transaction is found, we sum it.
       FOR cur_trans_meas_inv IN c_trans_meas_inv(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
         ln_newvolume := cur_trans_meas_inv.sum_inv_vol;
       END LOOP;
     ELSE
       ln_storage_vol := nvl(ec_storage_measurement.closing_volume(lv2_storage_id,lv2_product_id,ld_daytime,'='),0);
       FOR cur_trans_meas IN  c_trans_meas_recalculate(p_event_no) LOOP
         IF cur_trans_meas.alt_code = 'CRED' THEN
           ln_newvolume :=  ln_storage_vol + cur_trans_meas.volume;
         ELSE
           ln_newvolume :=  ln_storage_vol - cur_trans_meas.volume;
         END IF;
       END LOOP;
     END IF;
     UPDATE storage_measurement set closing_volume = ln_newvolume
       WHERE object_id = lv2_storage_id
       AND product_id = lv2_product_id
       AND daytime = ld_daytime;
   END IF;

  FOR cur_trans_overview_event IN c_trans_overview_event(lv2_storage_id, lv2_product_id, ld_daytime) LOOP
    IF cur_trans_overview_event.transaction_type = 'INVENTORY' THEN
      EXIT;
    END IF;
    FOR cur_storage_meas_current_event IN c_storage_meas_current_event(cur_trans_overview_event.storage_id, cur_trans_overview_event.object_id,cur_trans_overview_event.daytime) LOOP
      ln_newvolume := 0;
      ln_prev_storage_vol := 0;
      ln_prev_storage_vol := ec_storage_measurement.closing_volume(cur_storage_meas_current_event.object_id,cur_storage_meas_current_event.product_id,cur_storage_meas_current_event.daytime,'<');
      IF cur_trans_overview_event.alt_code = 'CRED' THEN
        ln_newvolume :=   nvl(ln_newvolume,0) +  cur_trans_overview_event.volume;
      ELSE
        ln_newvolume :=  nvl(ln_newvolume,0) - cur_trans_overview_event.volume;
      END IF;
      ln_newvolume := nvl(ln_prev_storage_vol,0) +  ln_newvolume;
      UPDATE storage_measurement set closing_volume = ln_newvolume
        WHERE object_id = cur_trans_overview_event.storage_id
        AND product_id = cur_trans_overview_event.object_id
        AND daytime = cur_trans_overview_event.daytime;
    END LOOP;
  END LOOP;

END insertRecalculateStorageMeas;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateRecalculateStorageMeas
-- Description    : Updates volume in Storage Measurement when a record is updated in transaction_measurement
--                  It is called after the selected record is updated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_measurement,transaction_measurement
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateRecalculateStorageMeas(p_event_no NUMBER)
IS


CURSOR c_trans_meas_recalculate(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT tm.object_id, tm.storage_id, tm.volume, tm.daytime, pc.alt_code, tm.transaction_type
  FROM transaction_measurement tm, prosty_codes pc
  WHERE tm.storage_id = cp_storage_id
  AND tm.object_id = cp_product_id
  AND tm.daytime = cp_daytime
  AND tm.transaction_type != 'INVENTORY'
  AND tm.transaction_type =  pc.code
  AND pc.code_type = 'STOR_TRANS_TYPE';

  ln_newvolume NUMBER;
  ld_daytime DATE;
  lv2_storage_id VARCHAR2(32);
  lv2_product_id VARCHAR2(32);
  ln_inventory_event_exists NUMBER := 0;

BEGIN
    ld_daytime     :=  ec_transaction_measurement.daytime(p_event_no);
    lv2_storage_id :=  ec_transaction_measurement.storage_id(p_event_no);
    lv2_product_id :=  ec_transaction_measurement.object_id(p_event_no);
    FOR onerow_trans_inv_exist IN c_trans_inventory_exist(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
      ln_inventory_event_exists :=1;
      EXIT;
    END LOOP;
    IF ln_inventory_event_exists > 0 then -- if there are inventory events, we sum them
      FOR cur_trans_meas_inv IN c_trans_meas_inv(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
        ln_newvolume := cur_trans_meas_inv.sum_inv_vol;
      END LOOP;
    ELSE -- else we recalculate the values for that storage,product,day
      FOR cur_trans_meas_recalc IN  c_trans_meas_recalculate(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
        IF cur_trans_meas_recalc.alt_code = 'CRED' THEN
          ln_newvolume :=  nvl(ln_newvolume,0) + cur_trans_meas_recalc.volume;
        ELSE
          ln_newvolume :=  nvl(ln_newvolume,0) + - cur_trans_meas_recalc.volume;
        END IF;
      END LOOP;
      ln_newvolume := nvl(ec_storage_measurement.closing_volume(lv2_storage_id,lv2_product_id,ld_daytime,'<'),0) + ln_newvolume;
    END IF;
    UPDATE storage_measurement set closing_volume = ln_newvolume
      WHERE object_id = lv2_storage_id
      AND product_id = lv2_product_id
      AND daytime = ld_daytime;

   FOR cur_storage_meas_days IN c_storage_meas_days(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
     ln_newvolume:= 0;
     ln_inventory_event_exists := 0;
     FOR onerow_trans_inv_exist IN c_trans_inventory_exist(lv2_storage_id,lv2_product_id,cur_storage_meas_days.daytime) LOOP
       ln_inventory_event_exists :=1;
       EXIT;
     END LOOP;
     IF ln_inventory_event_exists != 1 THEN
       FOR cur_trans_meas_recalc_days IN  c_trans_meas_recalculate(lv2_storage_id, lv2_product_id, cur_storage_meas_days.daytime) LOOP
         IF cur_trans_meas_recalc_days.alt_code = 'CRED' THEN
           ln_newvolume := nvl(ln_newvolume,0) + cur_trans_meas_recalc_days.volume;
         ELSE
           ln_newvolume :=  nvl(ln_newvolume,0) - cur_trans_meas_recalc_days.volume;
         END IF;
       END LOOP;
       ln_newvolume := ec_storage_measurement.closing_volume(lv2_storage_id, lv2_product_id,cur_storage_meas_days.daytime, '<') + ln_newvolume ;
       UPDATE storage_measurement set closing_volume = ln_newvolume
         WHERE object_id = lv2_storage_id
         AND product_id = lv2_product_id
         AND daytime = cur_storage_meas_days.daytime;
      END IF;
    END LOOP;
END updateRecalculateStorageMeas;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteRecalculateStorageMeas
-- Description    : Updates/Deletes volume in Storage Measurement when a record is deleted in transaction_measurement.
--                  It is called before the selected record is deleted.
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : storage_measurement, transaction_measurement
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteRecalculateStorageMeas(p_event_no NUMBER)
IS



CURSOR c_trans_inventory_exist(cp_storage_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT 1
    FROM transaction_measurement
    WHERE storage_id =  cp_storage_id
    AND object_id = cp_product_id
    AND daytime =  cp_daytime
    AND transaction_type = 'INVENTORY'
    AND event_no != p_event_no;

CURSOR c_trans_measurement_count(cp_storage_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT COUNT(*) row_count
    FROM transaction_measurement
    WHERE object_id  =  cp_product_id
    AND storage_id = cp_storage_id
    AND daytime =  cp_daytime
    AND event_no != p_event_no;

CURSOR c_trans_measurement_non_inv(cp_storage_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT  tm.object_id, tm.storage_id, tm.volume, tm.daytime, pc.alt_code, tm.transaction_type
    FROM transaction_measurement tm, prosty_codes pc
    WHERE object_id  =  cp_product_id
    AND storage_id = cp_storage_id
    AND daytime =  cp_daytime
    AND event_no != p_event_no
    AND tm.transaction_type =  pc.code
    AND pc.code_type = 'STOR_TRANS_TYPE';

CURSOR c_trans_meas_inv_today(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT  sum(volume) sum_inv_vol
    FROM transaction_measurement tm
    WHERE tm.storage_id= cp_storage_id
    AND tm.object_id = cp_product_id
    AND tm.daytime = cp_daytime
    AND tm.event_no != p_event_no
    AND tm.transaction_type = 'INVENTORY';

CURSOR c_trans_meas_recalculate_event(cp_storage_id VARCHAR2,cp_product_id VARCHAR2, cp_daytime DATE) IS
  SELECT tm.object_id, tm.storage_id, tm.volume, tm.daytime, pc.alt_code, tm.transaction_type
  FROM transaction_measurement tm, prosty_codes pc
  WHERE tm.storage_id = cp_storage_id
  AND tm.object_id = cp_product_id
  AND tm.daytime = cp_daytime
  AND tm.transaction_type != 'INVENTORY'
  AND tm.transaction_type =  pc.code
  AND pc.code_type = 'STOR_TRANS_TYPE';


  ln_newvolume NUMBER :=0;
  ln_row_count NUMBER;
  ld_daytime DATE;
  lv2_storage_id VARCHAR2(32);
  lv2_product_id VARCHAR2(32);
  ln_inventory_event_exists NUMBER := 0;

BEGIN

  FOR cur_trans_meas IN  c_trans_meas_recalculate(p_event_no) LOOP
    ld_daytime :=  cur_trans_meas.daytime;
    lv2_storage_id := cur_trans_meas.storage_id;
    lv2_product_id := cur_trans_meas.object_id;
    FOR cur_trans_measurement_count IN c_trans_measurement_count(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
      ln_row_count :=cur_trans_measurement_count.row_count;
    END LOOP;
    IF ln_row_count = 0 THEN -- If there's no any other events for that storage,product and day, we can delete the record
      DELETE FROM storage_measurement sm
        WHERE sm.object_id = lv2_storage_id
        AND sm.product_id = lv2_product_id
        AND sm.daytime =  ld_daytime;
    ELSE -- else update the volume for that storage,product and day
      FOR onerow_trans_inv_exist IN c_trans_inventory_exist(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
        ln_inventory_event_exists :=1;
        EXIT;
      END LOOP;
      IF ln_inventory_event_exists > 0 then   -- If there is another inventory event for that day which is not deleted
        -- other inventory event found
        FOR cur_trans_meas_inv_today IN c_trans_meas_inv_today(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
          ln_newvolume := cur_trans_meas_inv_today.sum_inv_vol;
        END LOOP;
      ELSE -- other than INVENTORY events found
        IF cur_trans_meas.transaction_type = 'INVENTORY' THEN -- if the event which will be deleted is an inventory,we need to recalculate
          FOR cur_trans_measurement_non_inv  IN c_trans_measurement_non_inv(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
            IF cur_trans_measurement_non_inv.alt_code = 'CRED' THEN
              ln_newvolume :=  ln_newvolume  + nvl(cur_trans_measurement_non_inv.volume,0) ;
            ELSE
              ln_newvolume := ln_newvolume - nvl(cur_trans_measurement_non_inv.volume,0);
            END IF;
          END LOOP;
          ln_newvolume := nvl(ec_storage_measurement.closing_volume(lv2_storage_id,lv2_product_id,ld_daytime,'<'),0) + ln_newvolume;
        ELSE  -- we can just minus/plus from storage measurement
          FOR cur_storage_meas_current_event IN c_storage_meas_current_event(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
            ln_newvolume :=  cur_trans_meas.volume;
            IF cur_trans_meas.alt_code = 'CRED' THEN
              ln_newvolume := nvl(cur_storage_meas_current_event.closing_volume,0) -  ln_newvolume;
            ELSE
              ln_newvolume := nvl(cur_storage_meas_current_event.closing_volume,0) +  ln_newvolume;
            END IF;
          END LOOP;
        END IF;
      END IF;
      UPDATE storage_measurement SET closing_volume = ln_newvolume
        WHERE object_id = lv2_storage_id
        AND product_id = lv2_product_id
        AND daytime = ld_daytime;
    END IF;
  END LOOP;
  -- update all records for that storage,product and > daytime
  FOR cur_storage_meas IN c_storage_meas_days(lv2_storage_id,lv2_product_id,ld_daytime) LOOP
    ln_newvolume:= 0;
    FOR onerow_trans_inv_exist IN c_trans_inventory_exist(lv2_storage_id,lv2_product_id,cur_storage_meas.daytime) LOOP
      ln_inventory_event_exists :=1;
      EXIT; -- when an INVENTORY transaction is found for that day, we dont update and instead we exit
    END LOOP;
    IF ln_inventory_event_exists != 1 THEN -- we only update the volume when there are no INVENTORY transaction for that day
      FOR cur_trans_meas_recalc_event IN  c_trans_meas_recalculate_event(lv2_storage_id, lv2_product_id , cur_storage_meas.daytime) LOOP
        IF cur_trans_meas_recalc_event.alt_code = 'CRED' THEN
          ln_newvolume := nvl(ln_newvolume,0) + cur_trans_meas_recalc_event.volume;
        ELSE
          ln_newvolume :=  nvl(ln_newvolume,0) - cur_trans_meas_recalc_event.volume;
        END IF;
      END LOOP;
      ln_newvolume := nvl(ec_storage_measurement.closing_volume(lv2_storage_id, lv2_product_id,cur_storage_meas.daytime, '<'),0) + ln_newvolume ;
      UPDATE storage_measurement set closing_volume = ln_newvolume

        WHERE object_id = lv2_storage_id
        AND product_id = lv2_product_id
        AND daytime = cur_storage_meas.daytime;
    END IF;
  END LOOP;

END deleteRecalculateStorageMeas;

---------------------------------------------------------------------------------------------------
-- Procedure       :updateBlendTrans
-- Description    : Updates volume of the linked events when the original event in stor_blend_batch is updated.
-- Preconditions  : Volume in stor_blend_batch is updated.
-- Postcondition  : Volume of the linked events in transaction_measurement and transaction_meas_ownshp are updated.
--
-- Using Tables   : transaction_measurement, stor_blend_batch
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateBlendTrans(p_event_no  NUMBER,p_user VARCHAR2)
IS

CURSOR c_stor_blend_meas IS
  SELECT *
    FROM stor_blend_meas
    WHERE event_no = p_event_no;

CURSOR c_trans_meas IS
  SELECT distinct(event_no)
    FROM transaction_measurement
    WHERE linked_event_no = p_event_no;

ln_prod_mass NUMBER;

BEGIN
   FOR cur_stor_blend_meas IN  c_stor_blend_meas LOOP
	 ln_prod_mass := calcBlendContentMass(cur_stor_blend_meas.object_id,p_event_no);
     UPDATE transaction_measurement
       SET volume = cur_stor_blend_meas.volume
	   ,mass = ln_prod_mass
	   ,storage_id = cur_stor_blend_meas.storage_id
       ,last_updated_by =  Nvl(p_user, ecdp_context.getAppUser())
       WHERE linked_event_no = p_event_no
       AND object_id = cur_stor_blend_meas.object_id
       AND storage_id = cur_stor_blend_meas.storage_id;
   END LOOP;
   FOR cur_trans_meas IN c_trans_meas LOOP
     updateRecalculateStorageMeas(cur_trans_meas.event_no);
     updateOwnshpVol(cur_trans_meas.event_no,p_user);
   END LOOP;
END updateBlendTrans;

---------------------------------------------------------------------------------------------------
-- Function       : createComplementTransOwnshp
-- Description    : Create transaction ownership records for each product based on splits in equity share.
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, equity_share
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createComplementTransOwnshp(p_event_no  NUMBER)
IS

CURSOR c_equity_share(cp_owner VARCHAR2,cp_daytime DATE) IS
  SELECT *
  FROM equity_share es
  WHERE ecdp_objects.GetObjCode(es.object_id) = cp_owner
  AND es.daytime = (SELECT MAX(es2.daytime) FROM equity_share es2
    WHERE es2.daytime<= cp_daytime
    AND ecdp_objects.GetObjCode(es2.object_id) = cp_owner
    AND nvl(es2.end_date, cp_daytime+1) > cp_daytime)
    AND NOT EXISTS
      (SELECT 1
       FROM TRANSACTION_MEAS_OWNSHP x
       WHERE es.company_id = x.object_id
       AND x.event_no = p_event_no);

CURSOR c_comm_entity_share(cp_comm_entity_id VARCHAR2,cp_daytime DATE) IS
  SELECT *
  FROM equity_share es
  WHERE es.object_id = cp_comm_entity_id
  AND es.daytime = (SELECT MAX(es2.daytime) FROM equity_share es2 WHERE
    es2.object_id = es.object_id
    AND es2.daytime<= cp_daytime
    AND nvl(es2.end_date, cp_daytime+1) > cp_daytime)
    AND NOT EXISTS
      (SELECT 1
       FROM TRANSACTION_MEAS_OWNSHP x
       WHERE es.company_id = x.object_id
       AND x.event_no = p_event_no);

  ln_trans_volume NUMBER;
  ln_split_vol NUMBER;
  lv2_comm_entity_id VARCHAR2(32);

BEGIN

  FOR cur_trans_meas IN  c_transaction_measurement(p_event_no) LOOP
    ln_trans_volume := cur_trans_meas.volume;
    IF cur_trans_meas.transaction_type = 'SELL' AND cur_trans_meas.to_asset_type = 'COMPANY' THEN
      INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
      VALUES (p_event_no,cur_trans_meas.to_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
    ELSIF cur_trans_meas.transaction_type = 'SELL' AND cur_trans_meas.to_asset_type = 'COMMERCIAL_ENTITY' THEN
	  lv2_comm_entity_id := ec_transaction_measurement.from_asset_id(cur_trans_meas.linked_event_no);
      FOR cur_comm_entity_share IN c_comm_entity_share(lv2_comm_entity_id, cur_trans_meas.daytime) LOOP
        IF ln_trans_volume > 0 THEN
          ln_split_vol := cur_comm_entity_share.eco_share /100 * ln_trans_volume;
        ELSIF ln_trans_volume = 0 THEN
          ln_split_vol := 0;
        END IF;
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_comm_entity_share.company_id,cur_trans_meas.daytime,cur_comm_entity_share.eco_share,ln_split_vol);
      END LOOP;
    ELSIF cur_trans_meas.transaction_type = 'BUY' AND cur_trans_meas.from_asset_type = 'COMPANY' THEN
      INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
      VALUES (p_event_no,cur_trans_meas.from_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
    ELSIF cur_trans_meas.transaction_type = 'BUY' AND cur_trans_meas.from_asset_type = 'COMMERCIAL_ENTITY' THEN
	  lv2_comm_entity_id := ec_transaction_measurement.to_asset_id(cur_trans_meas.linked_event_no);
      FOR cur_comm_entity_share IN c_comm_entity_share(lv2_comm_entity_id, cur_trans_meas.daytime) LOOP
        IF ln_trans_volume > 0 THEN
          ln_split_vol := cur_comm_entity_share.eco_share /100 * ln_trans_volume;
        ELSIF ln_trans_volume = 0 THEN
          ln_split_vol := 0;
        END IF;
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_comm_entity_share.company_id,cur_trans_meas.daytime,cur_comm_entity_share.eco_share,ln_split_vol);
      END LOOP;
    ELSIF cur_trans_meas.transaction_type = 'TRANSFER_IN' THEN
      IF cur_trans_meas.from_asset_type = 'STORAGE' THEN
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_trans_meas.from_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
      END IF;
    ELSIF cur_trans_meas.transaction_type = 'TRANSFER_OUT' THEN
      IF cur_trans_meas.from_asset_type = 'STORAGE' THEN
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_trans_meas.to_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
      END IF;
    ELSIF cur_trans_meas.transaction_type = 'LOAN' AND cur_trans_meas.to_asset_type = 'COMPANY' THEN
       INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_trans_meas.to_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
    ELSIF cur_trans_meas.transaction_type = 'BORROW' AND cur_trans_meas.from_asset_type = 'COMPANY' THEN
       INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_trans_meas.from_asset_id,cur_trans_meas.daytime,100,cur_trans_meas.volume);
    ELSE
      FOR cur_equity_share IN  c_equity_share(cur_trans_meas.ownership_type, cur_trans_meas.daytime) LOOP
        IF ln_trans_volume > 0 THEN
          ln_split_vol := cur_equity_share.eco_share /100 * ln_trans_volume;
        ELSIF ln_trans_volume = 0 THEN
          ln_split_vol := 0;
        END IF;
        INSERT INTO TRANSACTION_MEAS_OWNSHP (EVENT_NO,OBJECT_ID,DAYTIME,SPLIT_PCT,SPLIT_VOLUME)
        VALUES (p_event_no,cur_equity_share.company_id,cur_trans_meas.daytime,cur_equity_share.eco_share,ln_split_vol);
      END LOOP;
    END IF;
  END LOOP;

END createComplementTransOwnshp;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : validateStorageProdUpdate                                              --
-- Description    : Add  validation when want to update the Intermediate Storage Product especially want to update the End Date
--					which it will check in Product Transaction Overview and Blend Export first
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE validateStorageProdUpdate(p_object_id VARCHAR2, p_daytime DATE, p_end_daytime DATE, p_product_id  VARCHAR2)
IS

CURSOR c_trans_measurement(cp_storage_id VARCHAR2) IS
  SELECT case when exists (SELECT 1 FROM transaction_measurement a
  WHERE a.object_id = p_product_id
  AND a.storage_id = p_object_id
  AND p_daytime <= a.daytime
  AND p_end_daytime < a.daytime+1)
       THEN 'Y'
       ELSE 'N'
       END as rec_exists FROM dual;

CURSOR c_stor_blend_meas(cp_storage_id VARCHAR2) IS
  SELECT case when exists (SELECT 1 FROM stor_blend_meas b
  WHERE b.object_id = p_product_id
  AND b.storage_id = p_object_id
  AND p_daytime <= b.daytime
  AND p_end_daytime < b.daytime+1)
       THEN 'Y'
       ELSE 'N'
       END as rec_exists FROM dual;

BEGIN
	IF p_end_daytime IS NOT NULL THEN
		FOR cur_tm IN c_trans_measurement(p_object_id) LOOP
			IF cur_tm.rec_exists = 'Y' THEN
				RAISE_APPLICATION_ERROR(-20627,'A record exists in Product Transaction Overview.');
			ELSE
				FOR cur_sbm IN c_stor_blend_meas(p_object_id) LOOP
					IF cur_sbm.rec_exists = 'Y' THEN
						RAISE_APPLICATION_ERROR(-20628,'A record exists in Blend Export.');
					END IF;
				END LOOP;
			END IF;
		END LOOP;
	END IF;

END validateStorageProdUpdate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : validateStorageProdDelete                                              --
-- Description    : Add  validation when want to delete the Intermediate Storage Product need to check in Product Transaction Overview and Blend Export first
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE validateStorageProdDelete(p_object_id VARCHAR2, p_daytime DATE, p_product_id  VARCHAR2)
IS

CURSOR c_trans_measurement(cp_storage_id VARCHAR2) IS
  SELECT case when exists (SELECT 1 FROM transaction_measurement a
  WHERE a.object_id = p_product_id
  AND a.storage_id = p_object_id
  AND p_daytime <= a.daytime)
       THEN 'Y'
       ELSE 'N'
       END as rec_exists FROM dual;

CURSOR c_stor_blend_meas(cp_storage_id VARCHAR2) IS
  SELECT case when exists (SELECT 1 FROM stor_blend_meas b
  WHERE b.object_id = p_product_id
  AND b.storage_id = p_object_id
  AND p_daytime <= b.daytime)
       THEN 'Y'
       ELSE 'N'
       END as rec_exists FROM dual;

BEGIN

	FOR cur_tm IN c_trans_measurement(p_object_id) LOOP
		IF cur_tm.rec_exists = 'Y' THEN
			RAISE_APPLICATION_ERROR(-20627,'A record exists in Product Transaction Overview.');
		ELSE
			FOR cur_sbm IN c_stor_blend_meas(p_object_id) LOOP
				IF cur_sbm.rec_exists = 'Y' THEN
					RAISE_APPLICATION_ERROR(-20628,'A record exists in Blend Export.');
				END IF;
			END LOOP;
		END IF;
	END LOOP;

END validateStorageProdDelete;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : updateApprovedBatchOwnshp                                              --
-- Description    : Update Product Transaction Overview records when Blend Ownership is updated
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE updateApprovedBatchOwnshp(p_event_no NUMBER)
IS

CURSOR c_stor_blend_ownshp IS
 SELECT *
  FROM stor_blend_ownshp sbo
  WHERE sbo.event_no = p_event_no ;

CURSOR c_stor_blend_meas IS
 SELECT object_id, storage_id
  FROM stor_blend_meas sbm
  WHERE sbm.event_no = p_event_no ;

CURSOR c_transaction_measurement(ln_prod_id VARCHAR2) IS
 SELECT event_no, object_id, volume, mass
  FROM transaction_measurement tm
  WHERE tm.linked_event_no = p_event_no AND tm.object_id = ln_prod_id ;

  ln_tm_prod_vol       NUMBER;
  ln_vol_ownership     NUMBER;
  ln_split_pct         NUMBER;
  ln_count             NUMBER;
  ln_split_volume      NUMBER;
  ln_new_split_volume  NUMBER;
  ln_tm_event_no       NUMBER;
  ln_batch_vol         NUMBER;
  ln_prod_storageid    VARCHAR2(32);
  ln_tmo_compid        VARCHAR2(32);
  ln_ownership_type    VARCHAR2(32);
  ln_batch_rec_status  VARCHAR2(32);
  ln_product_id        VARCHAR2(32);
  ln_tm_prod_mass      NUMBER;
  ln_new_split_mass    NUMBER;

BEGIN

  ln_count := 0;
  ln_ownership_type  := ec_stor_blend_batch.owner_split_type(p_event_no);
  ln_batch_vol  := ec_stor_blend_batch.volume(p_event_no);
  ln_batch_rec_status  := ec_stor_blend_batch.blend_status(p_event_no);
  IF ln_batch_rec_status = 'APPROVED' THEN
    FOR cur_stor_blend_ownshp IN c_stor_blend_ownshp LOOP
      ln_count := ln_count + 1;
      ln_split_pct  :=cur_stor_blend_ownshp.split_pct;
      ln_split_volume :=cur_stor_blend_ownshp.split_volume;
      ln_tmo_compid  :=cur_stor_blend_ownshp.object_id;
      FOR cur_stor_blend_meas IN c_stor_blend_meas LOOP
        ln_product_id  :=cur_stor_blend_meas.object_id;
        ln_prod_storageid :=cur_stor_blend_meas.storage_id;
        FOR cur_transaction_measurement IN c_transaction_measurement(ln_product_id) LOOP
          ln_tm_event_no :=cur_transaction_measurement.event_no;
          ln_tm_prod_vol :=cur_transaction_measurement.volume;
          ln_tm_prod_mass := cur_transaction_measurement.mass;
          IF ln_ownership_type = 'VOLUME_SPLIT' THEN
            IF ln_batch_vol = 0 THEN
              ln_split_pct  := 0;
              ln_new_split_volume := 0;
              ln_new_split_mass := 0;
            ELSE
              ln_split_pct := (ln_split_volume / ln_batch_vol) * 100 ;
              ln_new_split_volume := (ln_split_pct / 100) * ln_tm_prod_vol;
              ln_new_split_mass := (ln_split_pct / 100) * ln_tm_prod_mass;
            END IF;
            UPDATE transaction_meas_ownshp
            SET split_pct = ln_split_pct,
            split_volume = ln_new_split_volume
            ,split_mass = ln_new_split_mass
            ,last_updated_by =  ecdp_context.getAppUser()
            WHERE event_no = ln_tm_event_no
            AND object_id = ln_tmo_compid;
          ELSIF ln_ownership_type = 'PCT_SPLIT' THEN
            IF ln_split_pct = 0 THEN
              ln_vol_ownership := 0;
              ln_new_split_mass := 0;
            ELSE
              ln_vol_ownership := nvl((ln_tm_prod_vol * ln_split_pct / 100),0);
              ln_new_split_mass := nvl((ln_tm_prod_mass * ln_split_pct / 100),0);
              ln_split_pct := ln_split_pct;
            END IF;
            UPDATE transaction_meas_ownshp
            SET split_volume = ln_vol_ownership
            ,split_mass      = ln_new_split_mass
            ,split_pct       = ln_split_pct
            ,last_updated_by =  ecdp_context.getAppUser()
            WHERE event_no = ln_tm_event_no
            AND object_id = ln_tmo_compid;
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
  END IF;
END updateApprovedBatchOwnshp;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : insertApprovedBatchOwnshp                                              --
-- Description    : Insert into Product Transaction Ownership table when new Blend Ownership is inserted
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE insertApprovedBatchOwnshp(p_event_no NUMBER, p_object_id VARCHAR2)
IS

CURSOR c_stor_blend_batch IS
 SELECT blend_status
  FROM stor_blend_batch
  WHERE event_no = p_event_no;

CURSOR c_transaction_measurement IS
 SELECT *
  FROM transaction_measurement
  WHERE linked_event_no = p_event_no;

CURSOR c_stor_blend_ownshp  IS
 SELECT *
  FROM stor_blend_ownshp
  WHERE event_no = p_event_no AND object_id = p_object_id;

  ln_prod_vol          NUMBER;
  ln_vol_ownership     NUMBER;
  ln_split_pct         NUMBER;
  ln_count             NUMBER;
  ln_split_volume      NUMBER;
  ln_tmo_event_no      NUMBER;
  ln_split_pct_trans   NUMBER;
  ln_tmo_compid        VARCHAR2(32);
  ln_prod_mass         NUMBER;
  ln_mass_ownership    NUMBER;

BEGIN

  ln_count := 0;
  FOR cur_stor_blend_batch IN c_stor_blend_batch LOOP
    IF cur_stor_blend_batch.blend_status = 'APPROVED' THEN
      FOR cur_transaction_measurement IN c_transaction_measurement LOOP
        ln_count := ln_count + 1;
      END LOOP;
      IF ln_count > 0 THEN
        FOR cur_stor_blend_ownshp IN c_stor_blend_ownshp LOOP
          ln_split_pct       := cur_stor_blend_ownshp.split_pct;
          ln_split_volume    := cur_stor_blend_ownshp.split_volume;
          FOR cur_transaction_measurement IN c_transaction_measurement LOOP
            ln_prod_vol       := cur_transaction_measurement.volume;
            ln_prod_mass      := cur_transaction_measurement.mass;
            ln_tmo_event_no   := cur_transaction_measurement.event_no;
            ln_tmo_compid     :=  cur_transaction_measurement.object_id;
            ln_vol_ownership := nvl((ln_prod_vol * ln_split_pct/100),0);
            ln_mass_ownership := nvl((ln_prod_mass * ln_split_pct/100),0);
            ln_split_pct_trans := ln_split_pct;
            INSERT INTO transaction_meas_ownshp(event_no,object_id,daytime,split_volume,split_mass,split_pct,record_status,created_by)
            VALUES (ln_tmo_event_no,cur_stor_blend_ownshp.object_id,cur_stor_blend_ownshp.daytime,ln_vol_ownership,ln_mass_ownership,ln_split_pct_trans,'A',ecdp_context.getAppUser());
          END LOOP;
        END LOOP;
        updateApprovedBatchOwnshp(p_event_no);
      END IF;
    END IF;
  END LOOP;
END insertApprovedBatchOwnshp;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : deleteApprovedBatchOwnshp                                              --
-- Description    : Delete Product Transaction Ownership records when Blend Ownership record is deleted
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteApprovedBatchOwnshp(p_event_no NUMBER, p_object_id VARCHAR2)
IS

CURSOR c_stor_blend_batch IS
 SELECT blend_status
  FROM stor_blend_batch
  WHERE event_no = p_event_no;

CURSOR c_transaction_measurement IS
 SELECT *
  FROM transaction_measurement
  WHERE linked_event_no = p_event_no;

CURSOR c_stor_blend_ownshp  IS
 SELECT *
  FROM stor_blend_ownshp
  WHERE event_no = p_event_no AND object_id = p_object_id;

  ln_count             NUMBER;
  ln_tmo_event_no      NUMBER;
  ln_tmo_compid        VARCHAR2(32);

BEGIN

  ln_count := 0;
  FOR cur_stor_blend_batch IN c_stor_blend_batch LOOP
    IF cur_stor_blend_batch.blend_status = 'APPROVED' THEN
      FOR cur_transaction_measurement IN c_transaction_measurement LOOP
        ln_count := ln_count + 1;
      END LOOP;
      IF ln_count > 0 THEN
        FOR cur_stor_blend_ownshp IN c_stor_blend_ownshp LOOP
          FOR cur_transaction_measurement IN c_transaction_measurement LOOP
            ln_tmo_event_no   := cur_transaction_measurement.event_no;
            ln_tmo_compid     := cur_transaction_measurement.object_id;
            DELETE FROM transaction_meas_ownshp
            WHERE event_no = ln_tmo_event_no AND
            object_id = cur_stor_blend_ownshp.object_id;
          END LOOP;
        END LOOP;
        updateApprovedBatchOwnshp(p_event_no);
      END IF;
    END IF;
  END LOOP;
END deleteApprovedBatchOwnshp;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : deleteApprovedProductTrans                                              --
-- Description    : Delete Product Transaction and Ownership records when Blend Content is deleted
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteApprovedProductTrans(p_event_no NUMBER, p_object_id VARCHAR2)
IS

CURSOR c_transaction_measurement IS
 SELECT event_no
  FROM transaction_measurement
  WHERE linked_event_no = p_event_no and object_id = p_object_id;

BEGIN

   IF ec_stor_blend_batch.blend_status(p_event_no) = 'APPROVED' THEN
     FOR cur_transaction_measurement IN c_transaction_measurement LOOP
       DELETE FROM transaction_meas_ownshp
       WHERE event_no = cur_transaction_measurement.event_no;
       deleteRecalculateStorageMeas(cur_transaction_measurement.event_no);
     END LOOP;
     DELETE FROM transaction_measurement
     WHERE linked_event_no = p_event_no
     AND object_id = p_object_id;
     updateApprovedBatchOwnshp(p_event_no);
   END IF;
END deleteApprovedProductTrans;

---------------------------------------------------------------------------------------------------
-- Function       : calcBlendContentMass
-- Description    : Calculate the Mass for the Blend Content
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_meas
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION calcBlendContentMass (
       p_object_id  VARCHAR2,
       p_event_no NUMBER)

RETURN NUMBER IS
ln_return_val NUMBER;
ln_volume NUMBER;
ln_density NUMBER;

CURSOR c_stor_blend_content IS
SELECT daytime, volume, density
FROM stor_blend_meas
WHERE event_no = p_event_no
and object_id = p_object_id;

BEGIN

  FOR cur_stor_blend_content IN c_stor_blend_content LOOP
      ln_volume := cur_stor_blend_content.volume;
      ln_density := nvl(ue_storage_proc_plant.getContentDensity(p_object_id, cur_stor_blend_content.daytime), cur_stor_blend_content.density);
      ln_return_val := ln_volume * ln_density;
  END LOOP;

  RETURN ln_return_val;

END calcBlendContentMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : updateVolBlendBatch                                              --
-- Description    : Update the volume for Blend Batch record
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : stor_blend_batch, stor_blend_meas
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE updateVolBlendBatch(p_event_no NUMBER)
IS

BEGIN

   UPDATE stor_blend_batch
   SET volume = (
     SELECT sum(volume)
     FROM stor_blend_meas
     WHERE event_no = p_event_no),
     last_updated_by = ecdp_context.getAppUser(),
     last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE event_no = p_event_no;

   updateVolBlendOwnshp(p_event_no);

END updateVolBlendBatch;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveBlendContent
-- Description    : The Procedure approves blend content if the status of the blend batch is approved
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_blend_batch, stor_blend_meas, stor_blend_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveBlendContent(p_event_no NUMBER,
                         p_object_id VARCHAR2)
--</EC-DOC>
IS

CURSOR c_stor_blend_batch IS
SELECT record_status
FROM stor_blend_batch
WHERE event_no = p_event_no;

CURSOR c_stor_blend_meas IS
SELECT *
FROM stor_blend_meas
WHERE event_no = p_event_no
and object_id = p_object_id;

CURSOR c_blend_ownshp IS
SELECT *
FROM stor_blend_ownshp
WHERE event_no = p_event_no;

  ln_user_name VARCHAR2(30);
  lv2_last_update_date VARCHAR2(20);
  ln_record_status VARCHAR2(1);
  ln_event_no NUMBER;
  ln_prod_vol NUMBER;
  ln_prod_mass NUMBER;
  ln_split_pct NUMBER;
  ln_vol_ownership NUMBER;
  ln_mass_ownership NUMBER;

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate,'YYYY-MM-DD"T"HH24:MI:SS');

  FOR cur_stor_blend_batch IN c_stor_blend_batch LOOP
    ln_record_status := cur_stor_blend_batch.record_status;
  END LOOP;

  IF ln_record_status = 'A' THEN
    ln_user_name := ecdp_context.getAppUser();

    FOR cur_stor_blend_meas IN c_stor_blend_meas LOOP
      EcDp_System_Key.assignNextNumber('TRANSACTION_MEASUREMENT', ln_event_no);
      ln_prod_vol := cur_stor_blend_meas.volume;
      ln_prod_mass := calcBlendContentMass(p_object_id,p_event_no);
      INSERT INTO transaction_measurement(event_no,object_id,storage_id,daytime,transaction_type,from_asset_type,from_asset_id,volume,mass,ownership_type,ownership_split_type,linked_event_no,record_status,created_by)
        VALUES (ln_event_no,p_object_id,cur_stor_blend_meas.storage_id,cur_stor_blend_meas.daytime,'BLEND_IN','BLEND',ec_stor_blend_batch.blend_id(p_event_no),ln_prod_vol,ln_prod_mass,
        'GENERATED','VOLUME_SPLIT',p_event_no,'A',ecdp_context.getAppUser());

      insertRecalculateStorageMeas(ln_event_no);

	    UPDATE stor_blend_meas
      SET linked_event_no = ln_event_no,
          record_status='A',
          last_updated_by = ln_user_name,
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          rev_text = 'Approved at ' ||  lv2_last_update_date
      WHERE event_no = p_event_no
		  and object_id = p_object_id
      and storage_id is not null;

      FOR cur_blend_ownshp IN c_blend_ownshp LOOP
        ln_split_pct := cur_blend_ownshp.split_pct;
        ln_vol_ownership := nvl((ln_prod_vol * ln_split_pct/100),0);
        ln_mass_ownership := nvl((ln_prod_mass * ln_split_pct/100),0);

        INSERT INTO transaction_meas_ownshp(event_no,object_id,daytime,split_volume,split_mass,split_pct,record_status,created_by)
          VALUES (ln_event_no,cur_blend_ownshp.object_id,cur_blend_ownshp.daytime,ln_vol_ownership,ln_mass_ownership,ln_split_pct,'A',ln_user_name);
      END LOOP;
    END LOOP;
  END IF;

END approveBlendContent;

END EcBp_Storage_Proc_Plant;