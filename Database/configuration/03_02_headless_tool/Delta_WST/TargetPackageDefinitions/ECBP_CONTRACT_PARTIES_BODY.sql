CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Parties IS
/******************************************************************************
** Package        :  EcBp_Contract_Parties, body part
**
** $Revision: 1.13.4.2 $
**
** Purpose        :  working with contract parties
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005 Jean Ferre
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 28/05/2009  sharawan     ECPD-9843: Added new variable ln_count to handle the situation where all entries for a given split is deleted.
** 31/08/2011  meisihil     ECPD-17893: Added new updateDelShareEndDate function
** 25/09/2012  sharawan     ECPD-21998: Modified updateDelShareEndDate. If more records exist with same daytime, exit the update that nullifies the end date.
** 04/02/2013  sharawan     ECPD-22962: Modified ValidateShare to check UOM for party_share attribute.
********************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ValidateShare
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : contract_party_share
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      : The function are validating the sum of equity. The sum have to be 100, otherwise a message error will be prompted
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateShare(
       p_contract_id     VARCHAR2,
       p_daytime      DATE,
       p_party_role   VARCHAR2
       )
--</EC-DOC>
IS
    ln_count NUMBER;
	ln_equity_pct  NUMBER;
    lv_equity_uom  VARCHAR2(10);

	cp_contract_id VARCHAR2(32);
	cp_daytime DATE;
	cp_party_role VARCHAR2(32);

	CURSOR c_equity_pct (cp_contract_id VARCHAR2, cp_daytime DATE, cp_party_role VARCHAR2) IS
		SELECT  party_share
		FROM contract_party_share
		WHERE object_id = cp_contract_id
		AND party_role =  cp_party_role
		AND daytime = cp_daytime
    AND party_share is not null;

BEGIN
	ln_equity_pct := 0;
	ln_count :=0;

	cp_contract_id := p_contract_id;
	cp_daytime := p_daytime;
	cp_party_role := p_party_role;

    --get the UOM code from EQUITY attribute in CONTRACT_PARTIES class
    lv_equity_uom := ec_class_attr_presentation.uom_code('CONTRACT_PARTIES','EQUITY');

	FOR sumValue IN c_equity_pct(cp_contract_id, cp_daytime, cp_party_role) LOOP
        ln_count := ln_count + 1;
		ln_equity_pct := ln_equity_pct + ROUND(Nvl(sumValue.party_share,0),9);
	END LOOP;

	IF ln_count <> 0 THEN
       IF ln_equity_pct <> 100 AND lv_equity_uom = 'PCT' THEN
	      RAISE_APPLICATION_ERROR(-20404,'The sum of equity percentage has to be 100');
       ELSIF ln_equity_pct <> 1 AND lv_equity_uom = 'FRAC' THEN
	      RAISE_APPLICATION_ERROR(-20405,'The sum of equity fraction has to be 1');
       END IF;
	END IF;

END ValidateShare;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : createNewShare
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : contract_party_share
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      : This function is creating a split on the existing shares. It takes the chosen date in navigator as end_date for the
--						 "old" shares, and as startdate for the "new" shares.
--
---------------------------------------------------------------------------------------------------
PROCEDURE createNewShare(p_contract_id VARCHAR2,
						p_party_role VARCHAR2,
						p_daytime DATE,
						p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN

	INSERT INTO contract_party_share (object_id, company_id, party_role, party_share, daytime, end_date, bank_account_id, exvat_receiver_id, vat_receiver_id,
			value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
			text_1, text_2, text_3, text_4, created_by)
	SELECT  t.object_id, t.company_id, t.party_role, t.party_share, p_daytime, end_date, t.bank_account_id, t.exvat_receiver_id, t.vat_receiver_id,
			t.value_1, t.value_2, t.value_3, t.value_4, t.value_5, t.value_6, t.value_7, t.value_8, t.value_9, t.value_10,
			t.text_1, t.text_2, t.text_3, t.text_4, p_user
	FROM  contract_party_share t
	WHERE 	t.object_id = p_contract_id
		AND t.party_role = p_party_role
		AND daytime <= p_daytime AND p_daytime < Nvl(end_date,p_daytime + 1/(24*60*60));

	UPDATE contract_party_share
    SET end_date = p_daytime, last_updated_by = p_user
    WHERE object_id = p_contract_id
    	AND party_role = p_party_role
    	AND daytime < p_daytime  AND p_daytime < Nvl(end_date, p_daytime + 1/(24*60*60));


END createNewShare;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : updateNewShareEndDate
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : contract_party_share
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      : This function checks for existing equity shares within dates ahead of given daytime,
--				   and updates the end date of the newly saved equity to any found daytime
--				   Triggered after inserting into contract_party_share
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateNewShareEndDate(p_contract_id VARCHAR2,
						p_party_role VARCHAR2,
						p_daytime DATE,
						p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

	CURSOR c_equity_end_date (cp_contract_id VARCHAR2, cp_daytime DATE, cp_party_role VARCHAR2) IS
    SELECT MIN(daytime) as DAYTIME
	FROM contract_party_share
    WHERE object_id = cp_contract_id
    	AND party_role = cp_party_role
    	AND daytime > cp_daytime;

	lv_end_date DATE;

BEGIN

	FOR curEndDate IN c_equity_end_date(p_contract_id, p_daytime, p_party_role) LOOP
		lv_end_date := curEndDate.daytime;
	END LOOP;

	UPDATE contract_party_share
    SET end_date = lv_end_date, last_updated_by = p_user
    WHERE object_id = p_contract_id
    	AND party_role = p_party_role
    	AND daytime = p_daytime;

END updateNewShareEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : updateDelShareEndDate
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : contract_party_share
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      : This function is updating end date for previous share, after deleting
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateDelShareEndDate(p_contract_id VARCHAR2,
						p_party_role VARCHAR2,
						p_daytime DATE,
						p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

	CURSOR c_equity_end_date (cp_contract_id VARCHAR2, cp_daytime DATE, cp_party_role VARCHAR2) IS
    SELECT MIN(daytime) as DAYTIME
	FROM contract_party_share
    WHERE object_id = cp_contract_id
    	AND party_role = cp_party_role
    	AND daytime > cp_daytime;

	CURSOR c_count_day (cp_contract_id VARCHAR2, cp_daytime DATE, cp_party_role VARCHAR2) IS
    SELECT COUNT(daytime) as daycount
	FROM contract_party_share
    WHERE object_id = cp_contract_id
    	AND party_role = cp_party_role
    	AND daytime = cp_daytime;

	lv_end_date DATE;
    ln_daycount NUMBER;

BEGIN

	FOR curEndDate IN c_equity_end_date(p_contract_id, p_daytime, p_party_role) LOOP
		lv_end_date := curEndDate.daytime;
	END LOOP;

    --Get the count of records which have the same daytime
	FOR curCountDay IN c_count_day(p_contract_id, p_daytime, p_party_role) LOOP
		ln_daycount := curCountDay.daycount;
	END LOOP;

    --If more records exist with same daytime, exit the update
    IF ln_daycount = 0 THEN
        UPDATE contract_party_share
        SET end_date = lv_end_date, last_updated_by = p_user
        WHERE object_id = p_contract_id
            AND party_role = p_party_role
            AND daytime < p_daytime  AND p_daytime <= Nvl(end_date, p_daytime + 1/(24*60*60));
    END IF;

END updateDelShareEndDate;

END EcBp_Contract_Parties;