CREATE OR REPLACE PACKAGE BODY ue_Storage_Lift_Nomination IS
/******************************************************************************
** Package        :  ue_Storage_Lift_Nomination, body part
**
** $Revision: 1.11 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  	  : 11.04.2006 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 18.10.2006  rajarsar  Tracker 4635 - Added deleteNomination Procedure
** 12.09.2012  meisihil  ECPD-20962: Added function setBalanceDelta
** 24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** 30.03.2015  asareswi  ECPD-19757: Added procedure CreateUpdateSplit
** 30.03.2015  asareswi  ECPD-19757: Added function CalcSplitQty
** 15.10.2015  farhaann  ECPD-32358: Added function getCalendarDetail and getCalendarTooltip
** 17.02.2016  asareswi	 ECPD-33012: Added function getSubDaySplitQty, calcAggrSubDaySplitQty
** 03.03.2017  thotesan	 ECPD-43320: Added function getChartDetailCode, getChartTooltip for Schedule lifting overview
** 13.03.2017  sharawan	 ECPD-43320: Added private function getRestriction, getSubdaily for Schedule lifting overview
** 21.03.2017  sharawan  ECPD-44077: Modified getRestriction and getSubdaily for Restriction section in Schedule Lifting Overview
**                                   Modified cursor c_day_cargoes, c_subdaily_cargoes, c_tooltip_day, c_tooltip_subday to cater for null storage_id in Restrictions.
** 24.03.2017  sharawan  ECPD-42257: Modified subDaily cursor in getChartDetailCode and getChartTooltip to check for the daily table nom_firm_date
**                                   instead of sub daily table daytime, fixing the null pointer exception
** 30.03.2017  sharawan  ECPD-42257: Modified subDaily cursor in getChartDetailCode and getChartTooltip to get the conflicted cargoes list
**                                   for subdaily by checking the date in between chart_start_date and chart_end_date
** 02.05.2017  farhaann  ECPD-32533: Modified getCalendarTooltip - show berth name instead of code in tooltip
** 24.05.2017  farhaann  ECPD-32533: Modified getCalendarDetail and getCalendarTooltip
** 30.08.2017  asareswi  ECPD-45326: Modified getChartDetailCode, getChartTooltip function to show correct conflict and occupied behaviour of cargoes in berth utilization chart.
** 13.02.2018 Prashanthi ECPD-46130: Added  validateSplitEntry to prevent the same company and lifting account entry for users.
** 09.04.2018  royyypur  ECPD-53946: Added getTextColor to configure the custom Text color for a date
** -------  ------   ----- -----------------------------------------------------------------------------------------------
*/

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
FUNCTION expectedUnloadDate(p_parcel_no NUMBER)
RETURN DATE
--</EC-DOC>
IS

BEGIN
	RETURN NULL;
END expectedUnloadDate;

---------------------------------------------------------------------------------------------------
-- Function       : deleteNomination
-- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
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
PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_from_date DATE,p_to_date DATE)
--</EC-DOC>
IS
BEGIN
	NULL;
END deleteNomination;

---------------------------------------------------------------------------------------------------
-- Function       : validateSplit
-- Description    :
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
PROCEDURE validateSplit(p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN
	--NULL;
  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  Ecbp_Storage_Lift_Nomination.validateSplit(p_parcel_no);
END validateSplit;

---------------------------------------------------------------------------------------------------
-- Function       : getDefaultSplit
-- Description    :
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
PROCEDURE getDefaultSplit(p_parcel_no NUMBER)
--</EC-DOC>
IS

cursor c_get_lifting_account(b_parcel_no number) is
select lifting_account_id
from storage_lift_nomination t
where t.parcel_no = b_parcel_no;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR r_get_la IN c_get_lifting_account(p_parcel_no) loop
      IF r_get_la.lifting_account_id IS NOT NULL THEN
       EcBp_Storage_Lift_Nomination.createUpdateSplit(p_parcel_no, NULL, r_get_la.lifting_account_id);
      END IF;
  END LOOP;


END getDefaultSplit;

---------------------------------------------------------------------------------------------------
-- Function       : setBalanceDelta
-- Description    :
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
PROCEDURE setBalanceDelta(p_parcel_no NUMBER)
--</EC-DOC>
IS

	CURSOR c_nomination(cp_parcel_no number)
	IS
		SELECT nvl(purge_qty, 0) + nvl(cooldown_qty, 0) + nvl(vapour_return_qty, 0) + nvl(lauf_qty, 0) balance_delta_qty,
		       nvl(purge_qty2, 0) + nvl(cooldown_qty2, 0) + nvl(vapour_return_qty2, 0) + nvl(lauf_qty2, 0) balance_delta_qty2,
		       nvl(purge_qty3, 0) + nvl(cooldown_qty3, 0) + nvl(vapour_return_qty3, 0) + nvl(lauf_qty3, 0) balance_delta_qty3
		  FROM storage_lift_nomination
		 WHERE parcel_no = cp_parcel_no;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR c_nom IN c_nomination(p_parcel_no) loop
      UPDATE storage_lift_nomination set balance_delta_qty = c_nom.balance_delta_qty, balance_delta_qty2 = c_nom.balance_delta_qty2, balance_delta_qty3 = c_nom.balance_delta_qty3
       WHERE parcel_no = p_parcel_no;
  END LOOP;


END setBalanceDelta;

---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDayLifting
-- Description    :
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
BEGIN
	ln_result := EcBp_Storage_Lift_Nomination.aggrSubDayLifting(p_parcel_no, p_daytime, p_column, p_xtra_qty);
	RETURN ln_result;
END aggrSubDayLifting;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
-- Description    :
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
BEGIN
	EcBp_Storage_Lift_Nomination.calcSubDayLifting(p_parcel_no);
END calcSubDayLifting;

---------------------------------------------------------------------------------------------------
-- Procedure      : CreateUpdateSplit
-- Description    :
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
PROCEDURE CreateUpdateSplit( p_Parcel_No NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2)
--</EC-DOC>
	IS
BEGIN
	EcBp_Storage_Lift_Nomination.CreateUpdateSplit( p_Parcel_No, p_old_lifting_account_id, p_new_lifting_account_id) ;

END CreateUpdateSplit;

---------------------------------------------------------------------------------------------------
-- Procedure      : CalcSplitQty
-- Description    :
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

FUNCTION CalcSplitQty( p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER)
	RETURN NUMBER
--</EC-DOC>
	AS
	lv_split_qty	NUMBER;
BEGIN

	lv_split_qty 	:=	EcBp_Storage_Lift_Nomination.CalcSplitQty( p_Parcel_No, p_company_id, p_lifting_account_id, p_daytime, p_qty) ;
	RETURN lv_split_qty;

END CalcSplitQty;

-------------------------------------------------------------------------------------------------------

-- Procedure      : getCalendarDetail
-- Description    :
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

FUNCTION getCalendarDetail(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
BEGIN
 RETURN NULL;
END getCalendarDetail;

---------------------------------------------------------------------------------------------------

-- Procedure      : getCalendarTooltip
-- Description    :
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

FUNCTION getCalendarTooltip(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
BEGIN
 RETURN NULL;
END getCalendarTooltip;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getSubDaySplitQty
  -- Description    : Returns the sub daily qty split for a company
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
  -- History        : added for EC11 Upgrade, used by V_LIFT_ACC_SUB_DAY_RECEIPT
  ---------------------------------------------------------------------------------------------------
  FUNCTION getSubDaySplitQty(p_parcel_no          NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_daytime            DATE,
						   p_qty                NUMBER,
						   p_column             VARCHAR2 DEFAULT NULL)
    RETURN NUMBER
  --</EC-DOC>
   IS
    ln_split_qty        NUMBER;

  BEGIN


	ln_split_qty     := CalcSplitQty(p_Parcel_No, p_company_id, p_lifting_account_id, p_daytime, p_qty);

    RETURN ln_split_qty;
  END getSubDaySplitQty;

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
  -- History        : added for EC11 Upgrade, used by V_LIFT_ACC_DAY_ENT_DETAIL2
  ---------------------------------------------------------------------------------------------------
  FUNCTION calcAggrSubDaySplitQty(p_parcel_no   NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_daytime            DATE,
						   p_column             VARCHAR2 DEFAULT NULL,
                           p_xtra_qty           NUMBER DEFAULT 0)
    RETURN NUMBER
  --</EC-DOC>
   IS
    ln_split_qty        NUMBER;
    ln_lifted_qty       NUMBER;
	ln_tot_qty          NUMBER;

  BEGIN

    ln_lifted_qty     := ue_storage_lift_nomination.aggrSubDayLifting(p_parcel_no, p_daytime, p_column, p_xtra_qty);

	ln_split_qty     := CalcSplitQty(p_Parcel_No, p_company_id, p_lifting_account_id, p_daytime, ln_lifted_qty);

    RETURN ln_split_qty;

  END calcAggrSubDaySplitQty;

---------------------------------------------------------------------------------------------------
-- Function       : getRestriction
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getRestriction(p_daytime DATE,
                         p_berth_id VARCHAR2,
						             p_type VARCHAR2 DEFAULT 'DAY'
                       ) RETURN BOOLEAN
--</EC-DOC>
IS
lv_restriction NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO lv_restriction
    FROM OPLOC_PERIOD_RESTRICTION
   WHERE object_id = p_berth_id
     AND p_daytime between decode(p_type,'DAY',TRUNC(start_date),start_date) and decode(p_type,'DAY',TRUNC(end_date),end_date);

  IF lv_restriction >=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END getRestriction;


---------------------------------------------------------------------------------------------------
-- Function       : getSubdaily
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubdaily(p_daytime DATE,
                     p_berth_id VARCHAR2,
                     p_storage_id VARCHAR2
                     ) RETURN BOOLEAN
--</EC-DOC>
IS
lv_subdaily NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO lv_subdaily
    FROM V_CARGO_SUB_DAY_BERTH
   WHERE object_id = p_berth_id
     AND storage_id = p_storage_id
     AND p_daytime <> chart_start_date
     AND p_daytime between chart_start_date and chart_end_date;

  IF lv_subdaily >=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END getSubdaily;

---------------------------------------------------------------------------------------------------

-- Procedure      : getChartDetailCode
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT, CARGO_STATUS_MAPPING, BERTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :	Get the detail code info for Cargo Berth Chart.
--
---------------------------------------------------------------------------------------------------
FUNCTION getChartDetailCode(p_daytime DATE,
                            p_berth_id VARCHAR2,
                            p_storage_id VARCHAR2,
                            p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2
--</EC-DOC>
 IS
  CURSOR c_day_cargoes(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2 DEFAULT NULL) IS
             SELECT n.cargo_no
              FROM STORAGE_LIFT_NOMINATION N,
                   cargo_transport CT,
                   BERTH B,
                   CARGO_STATUS_MAPPING  CMAP
             where TRUNC(n.nom_firm_date) = TRUNC(cp_daytime)
               and (cp_storage_id IS NULL OR n.object_id = cp_storage_id)
               and ct.berth_id = cp_berth_id
               and b.object_id = ct.berth_id
               and n.cargo_no = ct.cargo_no
               and ct.cargo_status = cmap.cargo_status
               and cmap.ec_cargo_status != 'D';

  CURSOR c_subdaily_cargoes(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2 DEFAULT NULL) IS
             select n.cargo_no
                FROM STORAGE_LIFT_NOMINATION   N,
                     cargo_transport CT,
                     BERTH B,
                     CARGO_STATUS_MAPPING CMAP
               where n.parcel_no IN (SELECT distinct(snd.parcel_no)
                                      FROM stor_sub_day_lift_nom snd
                                     where snd.object_id = cp_storage_id)
                 AND cp_daytime >= n.start_lifting_date
				 AND cp_daytime < (SELECT max(snd.daytime) as end_date
                                                               FROM stor_sub_day_lift_nom snd
                                                              where snd.parcel_no = n.parcel_no
                                                                and snd.object_id = cp_storage_id)
                 and ct.berth_id = cp_berth_id
				 and (cp_storage_id IS NULL OR n.object_id = cp_storage_id)
                 and n.cargo_no = ct.cargo_no
                 and b.object_id = ct.berth_id
                 and ct.cargo_status = cmap.cargo_status
                 and cmap.ec_cargo_status != 'D';

  lv_detail_code VARCHAR2(32);
  ld_startDate      DATE;
  ld_production_day DATE;
  ln_rowcount       NUMBER;

BEGIN
    --Get the restrictions for the berth
	IF getRestriction(p_daytime, p_berth_id, p_type) THEN
		lv_detail_code := 'RESTRICTION';
	END IF;

    --Get the cargo that have been assigned with berth
	IF p_type = '1HR' THEN
	  FOR cur_subday_cargo in c_subdaily_cargoes(p_daytime, p_berth_id, p_storage_id) LOOP
		ln_rowcount := c_subdaily_cargoes%ROWCOUNT;
		IF (ln_rowcount > 1) OR getRestriction(p_daytime, p_berth_id, p_type) THEN
		  lv_detail_code := 'CONFLICT';
		ELSIF cur_subday_cargo.cargo_no IS NOT NULL THEN
		  lv_detail_code := 'OCCUPIED';
		END IF;
	  END LOOP;
	ELSE
	  FOR cur_day_cargo in c_day_cargoes(p_daytime, p_berth_id, p_storage_id) LOOP
		ln_rowcount := c_day_cargoes%ROWCOUNT;
		IF (ln_rowcount > 1) OR getRestriction(p_daytime, p_berth_id, p_type) THEN
		  lv_detail_code := 'CONFLICT';
		ELSIF cur_day_cargo.cargo_no IS NOT NULL THEN
		  lv_detail_code := 'OCCUPIED';
		END IF;
	  END LOOP;
	END IF;

	RETURN lv_detail_code;

END getChartDetailCode;

---------------------------------------------------------------------------------------------------

-- Procedure      : getChartTooltip
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT, CARGO_STATUS_MAPPING, BERTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :	Generating the tool tip info for Cargo Berth Chart.
--
---------------------------------------------------------------------------------------------------

FUNCTION getChartTooltip(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_storage_id VARCHAR2,
                         p_detail_code VARCHAR2,
                         p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_berth_restriction(cp_daytime DATE, cp_berth_id VARCHAR2, cp_type VARCHAR2) IS
      SELECT restriction_type
        FROM OPLOC_PERIOD_RESTRICTION r ,BERTH_VERSION B
       WHERE r.object_id = cp_berth_id
         AND cp_daytime between decode(cp_type, 'DAY', TRUNC(r.start_date), r.start_date) and decode(cp_type, 'DAY', TRUNC(r.end_date), r.end_date);

   CURSOR c_tooltip_day(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2 DEFAULT NULL) IS
      select berth_id,
             LISTAGG(cargo_name, ', ') WITHIN GROUP (ORDER BY cargo_name) cargoes
        from (select distinct ct.berth_id berth_id,
                              ct.cargo_name
                          FROM STORAGE_LIFT_NOMINATION N,
                               cargo_transport CT,
                               BERTH_VERSION B,
                               CARGO_STATUS_MAPPING  CMAP
                         where TRUNC(n.nom_firm_date) = TRUNC(cp_daytime)
                           and ct.berth_id = cp_berth_id
                           and b.object_id = ct.berth_id
						               and (cp_storage_id IS NULL OR n.object_id = cp_storage_id)
                           and n.cargo_no = ct.cargo_no
                           and ct.cargo_status = cmap.cargo_status
                           and cmap.ec_cargo_status != 'D')
       group by berth_id;

   CURSOR c_tooltip_subday(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2 DEFAULT NULL) IS
      select berth_id,
             LISTAGG(cargo_name, ', ') WITHIN GROUP(ORDER BY cargo_name) cargoes
        from (select distinct ct.berth_id berth_id, ct.cargo_name
                FROM STORAGE_LIFT_NOMINATION   N,
                     cargo_transport CT,
                     BERTH_VERSION B,
                     CARGO_STATUS_MAPPING CMAP
               where n.parcel_no IN (SELECT distinct(snd.parcel_no)
                                      FROM stor_sub_day_lift_nom snd
                                     where snd.object_id = cp_storage_id)
                 AND cp_daytime >= n.start_lifting_date
				 AND cp_daytime < (SELECT max(snd.daytime) as end_date
                                                               FROM stor_sub_day_lift_nom snd
                                                              where snd.parcel_no = n.parcel_no
                                                                and snd.object_id = cp_storage_id)
				         and (cp_storage_id IS NULL OR n.object_id = cp_storage_id)
				         and ct.berth_id = cp_berth_id
                 and n.cargo_no = ct.cargo_no
                 and b.object_id = ct.berth_id
                 and ct.cargo_status = cmap.cargo_status
                 and cmap.ec_cargo_status != 'D')
       group by berth_id;

  lv_cargoes VARCHAR2(200);
  lv_restriction VARCHAR2(100);
  lv_tool_tip VARCHAR2(1000);

BEGIN

    IF p_detail_code IN ('CONFLICT', 'OCCUPIED') THEN

      IF p_type = '1HR' THEN
        FOR cur_tooltip_subday in c_tooltip_subday(p_daytime, p_berth_id, p_storage_id) LOOP
          lv_cargoes := cur_tooltip_subday.cargoes;
        END LOOP;
      ELSIF p_type = 'DAY' THEN
        FOR cur_tooltip_day in c_tooltip_day(p_daytime, p_berth_id, p_storage_id) LOOP
            lv_cargoes := cur_tooltip_day.cargoes;
        END LOOP;
      END IF;

      -- check if conflict with restrictions
      FOR cur_restriction in c_berth_restriction(p_daytime, p_berth_id, p_type) LOOP
        lv_restriction := ec_prosty_codes.CODE_TEXT(cur_restriction.restriction_type,'CAP_RESTRICTION_TYPE');
      END LOOP;

      IF lv_restriction IS NULL THEN
         lv_tool_tip := p_detail_code||' : '||lv_cargoes;
      ELSE
         lv_tool_tip := p_detail_code||' : '||lv_cargoes||' '||'RESTRICTION'||' : '||lv_restriction;
      END IF;

	ELSIF p_detail_code IN ('RESTRICTION') THEN
      FOR cur_restriction in c_berth_restriction(p_daytime, p_berth_id, p_type) LOOP
        lv_restriction := ec_prosty_codes.CODE_TEXT(cur_restriction.restriction_type,'CAP_RESTRICTION_TYPE');
      END LOOP;
      lv_tool_tip := p_detail_code||' : '||lv_restriction;

    END IF;

    RETURN lv_tool_tip;

END getChartTooltip;


 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateSplitEntry
-- Description    : To avoid insertion of records for the same company.
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
PROCEDURE validateSplitEntry  (p_company_id          VARCHAR2,
								p_parcel_no 	     NUMBER,
								p_lifting_account_id VARCHAR2)

IS

	CURSOR c_split(p_company_id VARCHAR2, p_parcel_no NUMBER, p_lifting_account_id VARCHAR2) IS
		SELECT 'X'
			FROM STORAGE_LIFT_NOM_SPLIT t
			WHERE t.company_id = p_company_id
			AND t.lifting_account_id  = p_lifting_account_id
			AND t.parcel_no = p_parcel_no;


BEGIN

FOR cur_split_id IN c_split(p_company_id, p_parcel_no, p_lifting_account_id) LOOP
			RAISE_APPLICATION_ERROR(-20588, 'Company split already present.');
		END LOOP;

END validateSplitEntry;


-------------------------------------------------------------------------------------------------------

-- Procedure      : getTextColor
-- Description    :
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

FUNCTION getTextColor(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
BEGIN
 RETURN NULL;
END getTextColor;


END ue_Storage_Lift_Nomination;