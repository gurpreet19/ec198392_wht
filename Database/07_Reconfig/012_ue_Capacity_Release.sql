create or replace 
PACKAGE ue_Capacity_Release IS
/****************************************************************
** Package        :  ue_Capacity_Release; head part
**
** $Revision: 1.17 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.04.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  -------- -------------------------------------------
   24-12-2008  kaurrjes ECPD-10643: Added a new procedure withdrawBid.
   23-10-2009  oonnnng  ECPD-13056: Rename P_RELEASE_NO to P_RECALL_NO in reputRelease() and recallRelease() functions' arguement.
   18-02-2010  ismaiime	ECPD-13844: Rename argument P_RECALL_NO to P_REPUT_NO in function reputRelease()
   12-06-2012  farhaann	ECPD-19488: Added function generateRequestId;
   26-06-2012  leeeewei ECPD-21294: Added function getAwardedQty
   29-06-2012  muhammah	ECPD-21292: Added procedure validateCapBidRange
   11-09-2012  chooysie	ECPD-21292: Added procedure validateLocEventDateRange
******************************************************************************************************/

PROCEDURE generateReleaseName(p_release_no NUMBER);
PROCEDURE genBidName(p_bid_no NUMBER);

PROCEDURE submitRelease(p_release_no NUMBER);
PROCEDURE withdrawRelease(p_release_no NUMBER);
PROCEDURE awardRelease(p_release_no NUMBER);
PROCEDURE resetAwardedReleasingContract(p_release_no NUMBER);
PROCEDURE cancelRelease(p_release_no NUMBER);

PROCEDURE submitBid(p_bid_no NUMBER);
PROCEDURE withdrawBid(p_bid_no NUMBER);
PROCEDURE confirmBid(p_bid_no NUMBER);
PROCEDURE rejectBid(p_bid_no NUMBER);
PROCEDURE matchBid(p_bid_no NUMBER);

PROCEDURE reputRelease(p_reput_no NUMBER,p_reput_note varchar2,p_daytime date);
PROCEDURE recallRelease(p_recall_no NUMBER, p_start_date date, p_end_date date,p_recall_note varchar2);

PROCEDURE validateCapBidRange(n_bid_no NUMBER, p_daytime date);

FUNCTION generateRequestId RETURN VARCHAR2;
FUNCTION getAwardedQty(p_release_no NUMBER) RETURN NUMBER;
PROCEDURE validateLocEventDateRange(p_rel_no number, p_startdate date, p_end_date date);

END ue_Capacity_Release;
/

create or replace 
PACKAGE BODY ue_Capacity_Release IS
/****************************************************************
** Package        :  ue_Capacity_Release; body part
**
** $Revision: 1.37 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.04.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom    Change description:
** ----------  -------- -------------------------------------------
   30-05-2008  FS      Modify SubmitRelease to insert Location into Capacity_Bid upon submit in Capacity_Release
   24-12-2008  kaurrjes ECPD-10643: Added a new procedure withdrawBid.
   23-10-2009  oonnnng  ECPD-13056: Rename P_RELEASE_NO to P_RECALL_NO in reputRelease() and recallRelease() functions' arguement.
   18-02-2010  ismaiime	ECPD-13844: Rename argument P_RECALL_NO to P_REPUT_NO in function reputRelease()
   12-06-2012  farhaann	ECPD-19488: Added function generateRequestId
   26-06-2012  leeeewei ECPD-21294: Added function getAwardedQty
   29-06-2012  muhammah	ECPD-21292: Added procedure validateCapBidRange
   11-09-2012  chooysie	ECPD-21292: Added procedure validateLocEventDateRange
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : genReleaseName
-- Description    : Generates a unique release name
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE generateReleaseName(p_release_no NUMBER)
--</EC-DOC>
IS
  lv_release_name         VARCHAR2(32);

BEGIN
  lv_release_name := TO_CHAR(p_release_no);

  UPDATE capacity_release cr
    SET cr.release_name = lv_release_name,
        cr.last_updated_by = Ecdp_Context.getAppUser
    WHERE cr.release_no = p_release_no;

END generateReleaseName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : genBidName
-- Description    : Generates a unique bid name
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE genBidName(p_bid_no NUMBER)

--</EC-DOC>
IS
  lv_bid_name         VARCHAR2(32);

BEGIN
  lv_bid_name:=TO_CHAR(p_bid_no);
  UPDATE capacity_bid cb
    SET cb.bid_name = lv_bid_name,
        cb.last_updated_by = Ecdp_Context.getAppUser
    WHERE cb.bid_no = p_bid_no;
END genBidName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : submitRelease
-- Description    : Validates and submits the release
--                    - validation-rule:
--                         - must be in PRV or REJ
--                         - if it is a pre-arranged:
--                           - replacement shipper should not be NULL
--                           - bid start date, bid end date, bid eval method, tie break method should not be NULL
--
--                    - if validation fails:
--                         - write error mesg to capacity_rel_form.status_desc
--                         - set status to REJECTED
--
--                    - if validation pass:
--                        - if it is a pre-arranged
--                             - create bid record
--                        - set status to SUBMIT
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
PROCEDURE submitRelease (p_release_no NUMBER)
--</EC-DOC>

IS
  lr_cap_rel            CAPACITY_RELEASE%ROWTYPE;
  lr_cap_rel_form       CAPACITY_REL_FORM%ROWTYPE;

  ln_bid_no             CAPACITY_BID.BID_NO%TYPE;

  lv_valid_status       VARCHAR2(32);
  lv_err_msg            VARCHAR2(1000);
  lb_valid              BOOLEAN := true;

  CURSOR curNP (cp_release_no VARCHAR2) IS
  SELECT  p.pre_bid_qty, p.location_id
  FROM  capacity_rel_location p
  WHERE  p.release_no = cp_release_no;

BEGIN
  lr_cap_rel := ec_capacity_release.row_by_pk(p_release_no);
  lr_cap_rel_form := ec_capacity_rel_form.row_by_pk(p_release_no);

  --Start validation
  IF lr_cap_rel.release_status NOT IN ('PRV','REJ') THEN
    lb_valid := false;
    lv_err_msg := 'Release status is not Provisional or Rejected; ';
  END IF;

  IF lr_cap_rel_form.prearranged_ind = 'Y' THEN
    -- simple example validation
    IF lr_cap_rel_form.pre_company_id IS NULL THEN
      lb_valid := false;
      lv_err_msg := lv_err_msg || 'Replacement company is not selected; ';
    END IF;
  END IF;

  IF lb_valid = true THEN
    lv_valid_status := 'SUB';

    IF lr_cap_rel_form.prearranged_ind = 'Y' THEN
      -- create a bid with 'PENDING' status
      INSERT INTO capacity_bid (release_no,bid_status,company_id,start_date,end_date,created_by)
        VALUES (p_release_no,
                'PND',
                lr_cap_rel_form.pre_company_id,
                lr_cap_rel.START_DATE,
                lr_cap_rel.END_DATE,
                Ecdp_Context.getAppUser)
      RETURNING bid_no INTO ln_bid_no;

  FOR c_NP IN curNP (p_release_no) LOOP
      INSERT INTO CAPACITY_BID_LOCATION (bid_no,BID_QTY,LOCATION_ID,created_by)
        VALUES (ln_bid_no,
               c_NP.Pre_Bid_Qty,
               c_NP.Location_Id,
               Ecdp_Context.getAppUser);
      END LOOP;

      -- instantiate bid form
      Ecdp_Capacity_Release.instantiateBidForm(ln_bid_no);

      -- generate bid name
      genBidName(ln_bid_no);

      -- set bid rate and bid quantity
      UPDATE capacity_bid_form SET BID_QTY = lr_cap_rel_form.PRE_BID_QTY, BID_RATE = lr_cap_rel_form.PRE_BID_RATE
      WHERE bid_no = ln_bid_no;
    END IF;

  ELSIF lb_valid = false THEN
    lv_valid_status := 'REJ';

  END IF;

  UPDATE capacity_release cr
         SET cr.release_status = lv_valid_status,
             cr.last_updated_by = Ecdp_Context.getAppUser
         WHERE cr.release_no = p_release_no;

  UPDATE capacity_rel_form crl
         SET crl.status_description = lv_err_msg,
             crl.last_updated_by = Ecdp_Context.getAppUser
         WHERE crl.release_no = p_release_no;

END submitRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : withdrawRelease
-- Description    : Withdraws the release
--                  Rules:
--                  - can be done if status=SUBMIT
--                  - no SUBMITTED or PENDING bid on it
--
--                  Set status=WITHDRAWN
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
PROCEDURE withdrawRelease (p_release_no NUMBER)
--</EC-DOC>

IS
  lr_cap_rel            CAPACITY_RELEASE%ROWTYPE;

  CURSOR c_bid(cp_release_no NUMBER) IS
    SELECT * FROM capacity_bid cb
    WHERE cb.release_no=cp_release_no AND
          cb.bid_status IN ('SUB','PND');

BEGIN
  lr_cap_rel := ec_capacity_release.row_by_pk(p_release_no);

  IF lr_cap_rel.release_status <> 'SUB' THEN
    RAISE_APPLICATION_ERROR(-20538, 'Not allowed to withdraw if the release has not been submitted yet.');
  END IF;

  FOR bid IN c_bid(p_release_no) LOOP
    -- if there is submitted or pending bid
    RAISE_APPLICATION_ERROR(-20539, 'Not allowed to withdraw a release if its bid has been submitted or still pending.');
  END LOOP;

  -- Everything passed
  UPDATE capacity_release cr
         SET cr.release_status = 'WDR',
             cr.last_updated_by = Ecdp_Context.getAppUser
         WHERE cr.release_no = p_release_no;

END withdrawRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : awardRelease
-- Description    : Award the release
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
PROCEDURE awardRelease (p_release_no NUMBER)
--</EC-DOC>

IS

BEGIN
  NULL;

END awardRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : resetAwardedReleasingContract
-- Description    : Reset awarded contract
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
PROCEDURE resetAwardedReleasingContract (p_release_no NUMBER)
--</EC-DOC>

IS

BEGIN
  NULL;

END resetAwardedReleasingContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : cancelRelease
-- Description    : Cancel the release
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
PROCEDURE cancelRelease (p_release_no NUMBER)
--</EC-DOC>

IS

BEGIN
  NULL;

END cancelRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : submitBid
-- Description    : Validates that this is not a prearranged and pending bid
--                  before submitting the bid
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
PROCEDURE submitBid (p_bid_no NUMBER)
--</EC-DOC>

IS
          lv_companyId VARCHAR2(32) := ec_capacity_bid.company_id(p_bid_no);
          lv_preArrangeCompanyId VARCHAR2(32) := ec_capacity_rel_form.pre_company_id(ec_capacity_bid.release_no(p_bid_no));
          lv_preArrangedInd VARCHAR(1) := ec_capacity_rel_form.prearranged_ind(ec_capacity_bid.release_no(p_bid_no));

BEGIN
          IF (((lv_companyId != lv_preArrangeCompanyId) OR (lv_preArrangeCompanyId IS NULL)) AND Ec_Capacity_Bid.bid_status(p_bid_no) != 'PND') THEN
             update CAPACITY_BID set bid_status = 'SUB', last_updated_by = ecdp_context.getAppUser where bid_no = p_bid_no;
          ELSE
             RAISE_APPLICATION_ERROR(-20540, 'Submit is not allowed on prearranged deals.');
          END IF;

END submitBid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : withdrawBid
-- Description    :
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
PROCEDURE withdrawBid (p_bid_no NUMBER)
--</EC-DOC>
IS

BEGIN
  NULL;
END withdrawBid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : confirmBid
-- Description    : confirms the bid. Validates that this is a prearranged and pending bid before updating the
--                  status to submited
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
PROCEDURE confirmBid (p_bid_no NUMBER)
--</EC-DOC>

IS
          lv_companyId VARCHAR2(32) := ec_capacity_bid.company_id(p_bid_no);
          lv_preArrangeCompanyId VARCHAR2(32) := ec_capacity_rel_form.pre_company_id(ec_capacity_bid.release_no(p_bid_no));
          lv_preArrangedInd VARCHAR(1) := ec_capacity_rel_form.prearranged_ind(ec_capacity_bid.release_no(p_bid_no));

BEGIN
          IF lv_companyId IS NOT NULL AND lv_preArrangeCompanyId IS NOT NULL THEN
             IF (lv_companyId = lv_preArrangeCompanyId AND lv_preArrangedInd = 'Y' AND Ec_Capacity_Bid.bid_status(p_bid_no) = 'PND') THEN
                update CAPACITY_BID set bid_status = 'SUB', last_updated_by = ecdp_context.getAppUser where bid_no = p_bid_no;
             ELSE
                RAISE_APPLICATION_ERROR(-20535, 'Confirmations are only allowed when the company matches the replacement company in the prearranged deal and the bid has status pending.');
             END IF;
          ELSE
             RAISE_APPLICATION_ERROR(-20536, 'Replacement company not defined on prearranged deal.');
          END IF;
END confirmBid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : rejectBid
-- Description    : Validates that this is a prearranged and pending bid before updating the status to rejected
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
PROCEDURE rejectBid (p_bid_no NUMBER)
--</EC-DOC>

IS
          lv_companyId VARCHAR2(32) := ec_capacity_bid.company_id(p_bid_no);
          lv_preArrangeCompanyId VARCHAR2(32) := ec_capacity_rel_form.pre_company_id(ec_capacity_bid.release_no(p_bid_no));
          lv_preArrangedInd VARCHAR(1) := ec_capacity_rel_form.prearranged_ind(ec_capacity_bid.release_no(p_bid_no));

BEGIN
          IF lv_companyId IS NOT NULL AND lv_preArrangeCompanyId IS NOT NULL THEN
             IF (lv_companyId = lv_preArrangeCompanyId AND lv_preArrangedInd = 'Y' AND Ec_Capacity_Bid.bid_status(p_bid_no) = 'PND') THEN
                update CAPACITY_BID set bid_status = 'REJ', last_updated_by = ecdp_context.getAppUser where bid_no = p_bid_no;
             ELSE
                RAISE_APPLICATION_ERROR(-20541, 'Rejections are only allowed when the company matches the replacement company in the prearranged deal and the bid has status pending.');
             END IF;
          ELSE
             RAISE_APPLICATION_ERROR(-20536, 'Replacement company not defined on prearranged deal.');
          END IF;
END rejectBid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : matchBid
-- Description    : Validates that this is a prearranged bid and that the status is submitted before starting matching.
--                  The matching process involves retrieving the bid rate of highest bid and copying the content
--                  into the bid rate of this bid
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
PROCEDURE matchBid (p_bid_no NUMBER)
--</EC-DOC>
IS
          lv_release_no NUMBER := ec_capacity_bid.release_no(p_bid_no);
          lv_companyId VARCHAR2(32) := ec_capacity_bid.company_id(p_bid_no);
          lv_preArrangeCompanyId VARCHAR2(32) := ec_capacity_rel_form.pre_company_id(ec_capacity_bid.release_no(p_bid_no));
          lv_preArrangedInd VARCHAR(1) := ec_capacity_rel_form.prearranged_ind(ec_capacity_bid.release_no(p_bid_no));
          lv_max_bid_no NUMBER;
          lv_max_bid_rate NUMBER;

          --Cursor finding the highest bid
          CURSOR c_capacity_bid (cp_release_no NUMBER) is
          SELECT max(BID_NO) as maxValue
          FROM capacity_bid
          WHERE RELEASE_NO = lv_release_no AND BID_STATUS = 'SUB';
BEGIN
          IF lv_companyId IS NOT NULL AND lv_preArrangeCompanyId IS NOT NULL THEN
             IF (lv_companyId = lv_preArrangeCompanyId AND lv_preArrangedInd = 'Y' AND Ec_Capacity_Bid.bid_status(p_bid_no) = 'SUB') THEN --if this is a prearranged deal, match:
                FOR c_bid_count in c_capacity_bid (lv_release_no) LOOP
                lv_max_bid_no := c_bid_count.maxvalue;
                END LOOP;
                IF (lv_max_bid_no IS NOT NULL) THEN
                   IF(lv_max_bid_no = p_bid_no) THEN --you are matching your "own" bid
                      RAISE_APPLICATION_ERROR(-20537, 'You currently hold the highest bid rate.');
                   ELSE
                      lv_max_bid_rate := ec_capacity_bid_form.bid_rate(lv_max_bid_no);
                      update CAPACITY_BID_FORM set bid_rate = lv_max_bid_rate, last_updated_by = ecdp_context.getAppUser where bid_no = p_bid_no;
                   END IF;
                END IF;
             ELSE
                RAISE_APPLICATION_ERROR(-20542, 'Matching is only allowed on prearranged deals and when the bid has status submitted.');
             END IF;
          ELSE
                 RAISE_APPLICATION_ERROR(-20536, 'Replacement company not defined on prearranged deal.');
          END IF;


END matchBid;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CapacityReput
-- Description    : Reput the capacity release
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
PROCEDURE reputRelease (p_reput_no NUMBER,p_reput_note VARCHAR2,p_daytime DATE)
--</EC-DOC>

IS

BEGIN

  NULL;

END reputRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CapacityRecall
-- Description    : Recall the capacity release
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
PROCEDURE recallRelease (p_recall_no NUMBER, p_start_date DATE, p_end_date DATE,p_recall_note VARCHAR2)
--</EC-DOC>

IS

BEGIN
  NULL;

END recallRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateCapBidRange
-- Description    : to get the validate the bid range date
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
PROCEDURE validateCapBidRange(n_bid_no NUMBER, p_daytime date)
--<EC-DOC>
IS

ln_bid_no NUMBER;

BEGIN

		Select count(b.bid_no) into ln_bid_no from capacity_bid b
		Where  p_daytime between b.start_date and b.end_date
    and b.bid_no = n_bid_no;

		IF ln_bid_no < 1 Then
			Raise_Application_Error(-20571, 'The Daytime should be in Bid Date Range.');
		END IF;

END validateCapBidRange;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : generateRequestId
-- Description    : generate Request Id for Ad Hoc is not null
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
--
---------------------------------------------------------------------------------------------------
FUNCTION generateRequestId
RETURN VARCHAR2
--</EC-DOC>
IS

  lv_request_id     VARCHAR2(32);
  ln_seq_no         NUMBER;
  lv_seq_string     VARCHAR2(32);

BEGIN

    IF ln_seq_no IS NULL THEN

      EcDp_System_Key.assignNextNumber('CAPACITY_REL_LOC_EVENT'||to_char(ecdp_date_time.getCurrentSysdate(),'yyyy'), ln_seq_no);

      IF (ln_seq_no < 100)THEN
         lv_seq_string := to_char(ln_seq_no,'000');
      ELSE
         lv_seq_string := ln_seq_no;
      END IF;

      lv_request_id :=  'AH-'||to_char(ecdp_date_time.getCurrentSysdate(),'yyyy')||'-'||lv_seq_string;

     END IF;

  return lv_request_id;

END generateRequestId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAwardedQty
-- Description    : sums the total awarded qty by the release no
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :capacity_bid_location,capacity_bid,capacity_bid_cntr_cap
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAwardedQty(p_release_no NUMBER) RETURN NUMBER
--</EC-DOC>
 IS

  ln_sum_qty  NUMBER := 0;
  lv_ext_name VARCHAR2(2000);

BEGIN

  lv_ext_name := ec_ctrl_tv_presentation.component_ext_name('ENERGYX','CAP_REL_INT');

  IF (lv_ext_name like '%CAPACITY_BID_LOC_INTER%') THEN

    select sum(l.awarded_qty)
      into ln_sum_qty
      from capacity_bid_location l, capacity_bid cb
     where cb.bid_no = l.bid_no
       and cb.release_no = p_release_no;

  ELSIF (lv_ext_name like '%CAPACITY_BID_CNTR_INTER%') THEN

    select sum(c.awarded_qty)
      into ln_sum_qty
      from capacity_bid_cntr_cap c, capacity_bid cb
     where cb.bid_no = c.bid_no
       and cb.release_no = p_release_no;

  ELSE

    ln_sum_qty := 0;

  END IF;

  IF ln_sum_qty IS NULL THEN
    ln_sum_qty := 0;
  END IF;

  return ln_sum_qty;

END getAwardedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateLocEventDateRange
-- Description    : to get the validate the location event range date
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
PROCEDURE validateLocEventDateRange(p_rel_no number, p_startdate date, p_end_date date)
--<EC-DOC>
IS

ln_rel_no NUMBER;

BEGIN

    Select count(b.release_no) into ln_rel_no from capacity_release b
    Where  (p_startdate between b.start_date and b.end_date)
    and (p_end_date between b.start_date and b.end_date)
    and b.release_no = p_rel_no;

    IF ln_rel_no = 0 Then
      Raise_Application_Error(-20575, 'The Event Period should be in Release Date Range.');
    END IF;

END validateLocEventDateRange;
END ue_Capacity_Release;
/