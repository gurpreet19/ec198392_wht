CREATE OR REPLACE PACKAGE BODY EcDp_Capacity_Release IS
/****************************************************************
** Package        :  EcDp_Capacity_Release; body part
**
** $Revision: 1.13 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.04.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -----     -------------------------------------------
** 09.05.2008   LF       Validation for validateReleaseUpdate
** 12.05.2008   LF       New Trigger for deleteRelease
** 19.05.2009  oonnnng   ECPD-11850: Removed getAwardedCapacity() and getAvailableCapacity() functions.
** 13.07.2009  lauuufus Add new function getMatchBidRate()
** 26.06.2012  leeeewei Add new function getMinMaxDaytime()
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instantiateReleaseForm
-- Description    : Instantiates capacity_rel_form
--
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

---------------------------------------------------------------------------------------------------
PROCEDURE instantiateReleaseForm (p_release_no NUMBER)
--</EC-DOC>

IS

BEGIN
  INSERT INTO CAPACITY_REL_FORM (RELEASE_NO, CREATED_BY) VALUES (p_release_no, ecdp_context.getAppUser);

END instantiateReleaseForm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instantiateBidForm
-- Description    : Instantiates capacity_bid_form
--
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

---------------------------------------------------------------------------------------------------
PROCEDURE instantiateBidForm (p_bid_no NUMBER)
--</EC-DOC>

IS

BEGIN
  NULL;
   INSERT INTO CAPACITY_BID_FORM (BID_NO, created_by) VALUES (p_bid_no, ecdp_context.getAppUser);

END instantiateBidForm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateReleaseUpdate
-- Description    : Validate update on capacity bid. Update only allowed if status is provisional or rejected
--
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

---------------------------------------------------------------------------------------------------
PROCEDURE validateReleaseUpdate (p_release_no NUMBER)
--</EC-DOC>

IS

  lv_status VARCHAR2(10);

BEGIN
   lv_status := ec_capacity_release.release_status(p_release_no);

  IF lv_status NOT IN ('PRV','REJ')THEN
    RAISE_APPLICATION_ERROR(-20531, 'Updates are only allowed when the release has status provisional or rejected.');
  END IF;

END validateReleaseUpdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteRelease
-- Description    : Validate delete on capacity release. Deletion only allowed if status is provisional or rejected
--
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
---------------------------------------------------------------------------------------------------
PROCEDURE deleteRelease(p_release_no NUMBER)
--</EC-DOC>

IS

  lv_status VARCHAR2(10);

BEGIN
  lv_status :=ec_capacity_release.release_status (p_release_no);


  IF lv_status IN ('PRV','REJ') THEN


   DELETE FROM capacity_rel_location cr WHERE cr.RELEASE_NO = p_release_no;
   DELETE FROM capacity_rel_form rf WHERE rf.RELEASE_NO = p_release_no;

   ELSE
     RAISE_APPLICATION_ERROR(-20532, 'Deletes are only allowed when the release has status provisional or rejected.');

  END IF;

END deleteRelease;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteBid
-- Description    : Validate delete on capacity bid. Deletion only allowed if status is provisional or rejected
--
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
---------------------------------------------------------------------------------------------------
PROCEDURE deleteBid(p_bid_no NUMBER)
--</EC-DOC>

IS

  lv_status VARCHAR2(10);

BEGIN
  lv_status :=ec_capacity_bid.bid_status(p_bid_no);


  IF lv_status IN ('PRV','REJ') THEN


   DELETE FROM capacity_bid_location cl WHERE cl.BID_NO = p_bid_no;
   DELETE FROM capacity_bid_form bf WHERE bf.BID_NO = p_bid_no;


   ELSE
     RAISE_APPLICATION_ERROR(-20534, 'Deletes are only allowed when the bid has status provisional or rejected.');

  END IF;

END deleteBid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateBidUpdate
-- Description    : Validate update on capacity bid. Update only allowed if status is provisional or rejected
--
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

---------------------------------------------------------------------------------------------------
PROCEDURE validateBidUpdate (p_bid_no VARCHAR2)
--</EC-DOC>

IS

  lv_status VARCHAR2(10);

BEGIN
   lv_status := ec_capacity_bid.bid_status(p_bid_no);

  IF lv_status NOT IN ('PRV','REJ')THEN
             RAISE_APPLICATION_ERROR(-20533, 'Updates are only allowed when the bid has status provisional or rejected.');
          END IF;

END validateBidUpdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getRecalledCapacity
-- Description    : Returns the difference between Awarded and recalled
--
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

---------------------------------------------------------------------------------------------------
FUNCTION getRecalledCapacity(p_awarded_cap INTEGER, p_available_cap INTEGER) RETURN INTEGER

--</EC-DOC>
IS

ln_recalled_cap NUMBER;

BEGIN

ln_recalled_cap:=(p_awarded_cap-p_available_cap);

return ln_recalled_cap;

END getRecalledCapacity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getMatchBidRate
-- Description    : Returns the highest bit rate
--
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

---------------------------------------------------------------------------------------------------
FUNCTION getMatchBidRate(p_bid_no NUMBER) RETURN NUMBER

--</EC-DOC>
IS


CURSOR c_max_bit_rate IS
      select max(cbf.bid_rate) max_rate
      from capacity_bid cb, capacity_bid_form cbf
      where cb.release_no = ec_capacity_bid.release_no(p_bid_no)
      and cb.bid_no = cbf.bid_no
      and cbf.bid_no <> p_bid_no;


ln_max_bid_rate NUMBER;
lv_prearrange_ind VARCHAR(10):= ec_capacity_bid_form.prearranged_ind(p_bid_no);

BEGIN

   IF lv_prearrange_ind <> 'Y' THEN

     ln_max_bid_rate := NULL;

  ELSIF lv_prearrange_ind = 'Y' THEN

      FOR cur_rec IN c_max_bit_rate LOOP

      ln_max_bid_rate := cur_rec.max_rate;

      END LOOP;

  END IF;

return ln_max_bid_rate;

END getMatchBidRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getMinMaxDaytime
-- Description    : Returns the minimum and maximum daytime for contract capacity bid
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : capacity_bid_cntr_cap,capacity_bid_day_cap
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :

---------------------------------------------------------------------------------------------------
FUNCTION getMinMaxDaytime(p_bid_no NUMBER,p_cntr_cap_id VARCHAR2, p_min_or_max VARCHAR2) RETURN DATE

--</EC-DOC>
IS

CURSOR c_min_max_daytime IS
select min(day_cap.daytime) min_daytime, max(day_cap.daytime) max_daytime
  from capacity_bid_cntr_cap cntr_cap, capacity_bid_day_cap day_cap
 where cntr_cap.bid_no = p_bid_no
   and cntr_cap.bid_no = day_cap.bid_no
   and cntr_cap.contract_capacity_id = p_cntr_cap_id
   and cntr_cap.contract_capacity_id = day_cap.contract_capacity_id;

ld_min_max_date DATE;

BEGIN

  FOR cur_min_max_daytime IN c_min_max_daytime LOOP
    IF p_min_or_max = 'MIN' THEN
       ld_min_max_date := cur_min_max_daytime.min_daytime;
    ELSE -- get max daytime
       ld_min_max_date := cur_min_max_daytime.max_daytime;
    END IF;
  END LOOP;

return ld_min_max_date;

END getMinMaxDaytime;

END EcDp_Capacity_Release;