CREATE OR REPLACE PACKAGE BODY ue_Nomination IS
/******************************************************************************
** Package        :  ue_Nomination, body part
**
** $Revision: 1.18.2.4 $
**
** Purpose        :  Business logic for nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.03.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 20.04.2012  leeeewei       ECPD-20581: Added function getOperParam
** 15.05.2012  leeeewei       ECPD-20581: Added function getSchedQty and getNominatedQty
** 08.06.2012  sharawan		  ECPD-20870: Added function getCapacityUOM
** 08.05.2014  chooysie		  ECPD-27544: Added function setFactorsEndDate and updateFactorsEndDate
********************************************************************/

/** Cursors used by delivery point functions*/
 CURSOR c_input_nom (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Aggregate input nominations for delivery points
 SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_point        d
	  WHERE n.object_id = p.object_id
    AND p.entry_location_id = d.object_id
    AND p.exit_location_id is NULL
	  AND n.daytime = cp_daytime
	  AND d.object_id = cp_delpnt_id
	  AND n.nomination_type = 'TRAN_INPUT'
	  AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
UNION ALL
(
 --Aggregate input nominations for delivery streams
SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_stream       s,
	       delivery_point        d
	 WHERE n.object_id = p.object_id
     AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
     AND (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
	   AND n.daytime = cp_daytime
	   AND d.object_id = cp_delpnt_id
	   AND n.nomination_type = 'TRAN_INPUT'
	   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
     GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
 );


CURSOR c_output_nom (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Aggregate output nominations for delivery points
 SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_point        d
	  WHERE n.object_id = p.object_id
    AND p.entry_location_id is NULL
    AND p.exit_location_id = d.object_id
	  AND n.daytime = cp_daytime
	  AND d.object_id = cp_delpnt_id
	  AND n.nomination_type = 'TRAN_OUTPUT'
	  AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
UNION ALL
(
 --Aggregate output nominations for delivery streams
SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_stream       s,
	       delivery_point        d
	 WHERE n.object_id = p.object_id
     AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
     AND (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
	   AND n.daytime = cp_daytime
	   AND d.object_id = cp_delpnt_id
	   AND n.nomination_type = 'TRAN_OUTPUT'
	   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
     GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
 );

/** Cursors used by delivery stream functions*/
CURSOR c_input_nom_destrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
SELECT s.object_id,
       s.object_code,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM nompnt_day_nomination n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or
       p.exit_location_id = s.object_id)
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND nvl(v.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY n.daytime, s.object_id, s.object_code, p.contract_id;

CURSOR c_output_nom_destrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
SELECT s.object_id,
       s.object_code,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	   ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	   ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	   ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM nompnt_day_nomination n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or
       p.exit_location_id = s.object_id)
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND Nvl(v.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY n.daytime, s.object_id, s.object_code, p.contract_id;

 -- Sub Day Cursors
CURSOR c_input_nom_sub_day (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
 SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_point d
 WHERE n.object_id = p.object_id
   AND p.entry_location_id is NULL
   AND p.exit_location_id = d.object_id
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type
UNION ALL
SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s, delivery_point d
 WHERE n.object_id = p.object_id
   AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id) AND
       (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;

CURSOR c_output_nom_sub_day (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
 SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_point d
 WHERE n.object_id = p.object_id
   AND p.entry_location_id is NULL
   AND p.exit_location_id = d.object_id
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type
UNION ALL
SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s, delivery_point d
 WHERE n.object_id = p.object_id
   AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id) AND
       (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : extConfirmNom
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE extConfirmNom(p_nom_seq NUMBER)
--</EC-DOC>
IS
	ln_qty NUMBER;

BEGIN
	-- example implementation.
	ln_qty := ec_nompnt_day_nomination.ext_confirmed_qty(p_nom_seq);

	if (ln_qty is not null) then
		UPDATE nompnt_day_nomination
		SET CONFIRMED_QTY = ln_qty,
			NOM_STATUS = 'CON', last_updated_by = ecdp_context.getAppUser
		WHERE nomination_seq = p_nom_seq;
	else
		-- replace ORA-20000 with a unique number
		RAISE_APPLICATION_ERROR(-20000, 'Cannot confirm when externally confirmed quantity is null');
	end if;

END extConfirmNom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : extRejectConfirmedNom
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE extRejectConfirmedNom(p_nom_seq NUMBER)
--</EC-DOC>
IS

BEGIN
	-- example implementation.
	UPDATE nompnt_day_nomination
	SET CONFIRMED_QTY = NULL,
		NOM_STATUS = 'ADJ', last_updated_by = ecdp_context.getAppUser
	WHERE nomination_seq = p_nom_seq;

END extRejectConfirmedNom;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SubmittNom
-- Description    : Proccedure for submitting nominations for a selected contract on a given day for a cycle.
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
PROCEDURE submittNom(p_contract_id VARCHAR2, p_daytime date, p_nom_cycle_code varchar2)
--</EC-DOC>
IS

cursor c_contract_nominations (p_contract_id VARCHAR2, p_daytime DATE) is
select n.nomination_seq from nompnt_day_nomination n
where contract_id = p_contract_id
and daytime = p_daytime;


cursor c_contract_nominations_cycle (p_contract_id VARCHAR2, p_daytime DATE, p_nom_cycle_code VARCHAR2 ) is
select n.nomination_seq from nompnt_day_nomination n
where contract_id = p_contract_id
and daytime = p_daytime
and nom_cycle_code = p_nom_cycle_code;


BEGIN
	-- example implementation.

IF p_nom_cycle_code is null THEN
FOR curCnNom IN c_contract_nominations (p_contract_id, p_daytime) LOOP
  UPDATE nompnt_day_nomination n
	SET n.accepted_qty = n.requested_qty,
	NOM_STATUS = 'ACC',
  last_updated_by = ecdp_context.getAppUser
	WHERE n.nomination_seq=curCnNom.Nomination_Seq
  AND nvl(OPER_NOM_IND, 'N') <> 'Y';
  END LOOP;
  END IF;

IF p_nom_cycle_code is not null THEN
  FOR curCnNomCycle IN c_contract_nominations_cycle (p_contract_id, p_daytime, p_nom_cycle_code) LOOP
  UPDATE nompnt_day_nomination n
	SET n.accepted_qty = n.requested_qty,
	NOM_STATUS = 'ACC',
  last_updated_by = ecdp_context.getAppUser
	WHERE n.nomination_seq=curCnNomCycle.Nomination_Seq
  AND nvl(OPER_NOM_IND, 'N') <> 'Y';
  END LOOP;
  END IF;


END submittNom;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateBalance
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
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateBalance(p_input_qty NUMBER, p_output_qty NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

ln_result NUMBER;

BEGIN

	ln_result := p_input_qty-p_output_qty;

	RETURN ln_result;

END calculateBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateTransfBalance
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
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateTransfBalance(p_contract_id VARCHAR2 DEFAULT NULL, p_date DATE DEFAULT NULL, p_input_qty NUMBER, p_output_qty NUMBER, p_transf_qty NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

ln_result          NUMBER;
ln_transf_qty      NUMBER;
ln_inbalance_sign  NUMBER;
ln_input_sign      NUMBER;
ln_output_sign     NUMBER;
ln_input_qty       NUMBER;
ln_output_qty      NUMBER;

BEGIN

  --getting the sign positive or negative as hard coded values this is a call from Daily Location Contract Balance Screen in Gas Dispatch Module.
  IF p_contract_id IS NULL OR p_date IS NULL THEN
	ln_input_sign  := -1;
	ln_output_sign := 1;
  ELSE
    --getting the sign positive or negative from the contract attribute
    ln_input_sign  := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_INPUT',p_date);
	ln_output_sign := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_OUTPUT',p_date);
  END IF;

  ln_input_qty  := p_input_qty;
  ln_output_qty := p_output_qty;

  ---TRAN_INPUT
  IF p_transf_qty < 0 AND ln_input_sign < 0 THEN
     --TRAN_INPUT -VE
     ln_input_qty :=  ln_input_qty + (p_transf_qty*ln_input_sign);
  END IF;
  IF p_transf_qty > 0 AND ln_input_sign > 0 THEN
     --TRAN_INPUT +VE
     ln_input_qty :=  ln_input_qty + (p_transf_qty*ln_input_sign);
  END IF;

  --TRAN_OUTPUT
  IF p_transf_qty < 0 AND ln_output_sign < 0 THEN
     --TRAN_OUTPUT -VE
     ln_output_qty :=  ln_output_qty + (p_transf_qty*ln_output_sign);
  END IF;
  IF p_transf_qty > 0 AND ln_output_sign > 0 THEN
     --TRAN_OUTPUT +VE
     ln_output_qty :=  ln_output_qty + (p_transf_qty*ln_output_sign);
  END IF;

  --getting the difference btwn input and output, the result should always be +ve
  IF ln_input_qty > ln_output_qty THEN
    ln_inbalance_sign := ln_output_sign;
    ln_result := ln_input_qty - ln_output_qty;
  ELSE
    ln_inbalance_sign := ln_input_sign;
    ln_result := ln_output_qty - ln_input_qty;
  END IF;
    ln_result := ln_result*ln_inbalance_sign;

	RETURN ln_result;

END calculateTransfBalance;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getClassUniqueKey
-- Description    : Don't have a clue
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
PROCEDURE getClassUniqueKey (p_class_name IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
--</EC-DOC>
IS

BEGIN

	/*IF (p_class_name IN ('TRNP_DAY_NOM_INPUT', 'TRNP_DAY_NOM_OUTPUT', 'TRNP_DAY_NOM_OPER_CTR')) THEN
		OPEN p_cursor FOR
			select a.attribute_name
			from class_attribute a,
				 class_attr_db_mapping d
			where  a.class_name = d.class_name
				   and a.attribute_name = d.attribute_name
				   and a.class_name = p_class_name
				   and a.attribute_name in ('OBJECT_ID', 'DAYTIME', 'SHIPPER_CODE', 'TRANSACTION_TYPE', 'NOM_CYCLE_CODE')
			order by d.sort_order;
	END IF;*/
	NULL;

END getClassUniqueKey;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixRecipt
    -- Description    : Return the total input nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixReceipt(p_object_id  VARCHAR2,
                              p_daytime    DATE,
                              p_qty_column VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_nom(cp_object_id VARCHAR2,
                     cp_daytime   DATE) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_INPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
             group by n.contract_id;

        ln_recipt_qty NUMBER;

    BEGIN
        -- this is an example implementation if the object id is a CONTRACT
        IF ecdp_objects.GetObjClassName(p_object_id) = 'CONTRACT' THEN
            FOR curNom IN c_nom(p_object_id, p_daytime) LOOP
                case p_qty_column
                    when 'REQUESTED_QTY' then
                        ln_recipt_qty := curNom.Requested_Qty;
                    when 'ACCEPTED_QTY' then
                        ln_recipt_qty := curNom.Accepted_Qty;
                    when 'EXT_ACCEPTED_QTY' then
                        ln_recipt_qty := curNom.Ext_Accepted_Qty;
                    when 'ADJUSTED_QTY' then
                        ln_recipt_qty := curNom.Adjusted_Qty;
                    when 'EXT_ADJUSTED_QTY' then
                        ln_recipt_qty := curNom.Ext_Adjusted_Qty;
                    when 'CONFIRMED_QTY' then
                        ln_recipt_qty := curNom.Confirmed_Qty;
                    when 'EXT_CONFIRMED_QTY' then
                        ln_recipt_qty := curNom.Ext_Confirmed_Qty;
                    when 'SCHEDULED_QTY' then
                        ln_recipt_qty := curNom.Scheduled_Qty;
                end case;
            END LOOP;

        END IF;

        RETURN ln_recipt_qty;

    END getMatrixReceipt;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixDelivery
    -- Description    : Return the total output nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixDelivery(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_qty_column VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS
       CURSOR c_nom(cp_object_id VARCHAR2,
                     cp_daytime   DATE) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_OUTPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
             group by n.contract_id;

        ln_del_qty NUMBER;

    BEGIN
        -- this is an example implementation if the object id is a CONTRACT
        IF ecdp_objects.GetObjClassName(p_object_id) = 'CONTRACT' THEN
            FOR curNom IN c_nom(p_object_id, p_daytime) LOOP
                case p_qty_column
                    when 'REQUESTED_QTY' then
                        ln_del_qty := curNom.Requested_Qty;
                    when 'ACCEPTED_QTY' then
                        ln_del_qty := curNom.Accepted_Qty;
                    when 'EXT_ACCEPTED_QTY' then
                        ln_del_qty := curNom.Ext_Accepted_Qty;
                    when 'ADJUSTED_QTY' then
                        ln_del_qty := curNom.Adjusted_Qty;
                    when 'EXT_ADJUSTED_QTY' then
                        ln_del_qty := curNom.Ext_Adjusted_Qty;
                    when 'CONFIRMED_QTY' then
                        ln_del_qty := curNom.Confirmed_Qty;
                    when 'EXT_CONFIRMED_QTY' then
                        ln_del_qty := curNom.Ext_Confirmed_Qty;
                    when 'SCHEDULED_QTY' then
                        ln_del_qty := curNom.Scheduled_Qty;
                end case;
            END LOOP;

        END IF;

        RETURN ln_del_qty;
    END getMatrixDelivery;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixInventory
    -- Description    : Return the difference between input and output nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixInventory(p_object_id  VARCHAR2,
                                p_daytime    DATE,
                                p_qty_column VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS

    BEGIN
        RETURN getMatrixDelivery(p_object_id, p_daytime, p_qty_column) - getMatrixReceipt(p_object_id, p_daytime, p_qty_column);
    END getMatrixInventory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalReqQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalReqQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalAccQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtAccQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a contract on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalSchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalReqQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalReqQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAccQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm(p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalAccQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAccQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalExtAccQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalAdjQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrDelstrm
-- Description    : Returns aggregated qty for a contract on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm(p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalExtAdjQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalConfQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtConfQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;


END getTotalExtConfQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalSchedQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalInternalQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalAdjInOutQtyPrDelpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalAdjInOutQtyPrDelstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalAdjQtyPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalIExternalQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalExtAdjInOutQtyPrDpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalExtAdjInOutQtyPrDstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalExtAdjQtyPrLocation;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjInOutQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjInOutQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalAdjInOutQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjInOutQtyPrDpnt
-- Description    :returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjInOutQtyPrDpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalExtAdjInOutQtyPrDpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjInOutQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjInOutQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;

END getTotalAdjInOutQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjInOutQtyPrDstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjInOutQtyPrDstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
    --loop output nominations
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;


  	RETURN ln_return_qty;

END getTotalExtAdjInOutQtyPrDstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayReqQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given time for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayReqQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayReqQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayAccQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayExtAccQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a contract on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayExtAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDayExtConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDaySchedQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDaySchedQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getSubDaySchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : valid_nompnt
-- Description    : User exit for chosing nomination point (Nomination Point, Counter Nomination Point)
--                Used for validating nomination points in popups, projects can insert logic to narrow the list of possible nomination points.
--                p_nompnt_id  - nomination point which is validated
--                p_nomination_category  - Which nomination point should be possible to choose from (based on the entry, exit location)
--                p_bf_number  - Which screen does it originate from, projects have the possibility to do special validation for different screens
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
-- Behaviour      : Return Y if nompnt have been validated and matched the criteria(s)
--
---------------------------------------------------------------------------------------------------
FUNCTION valid_nompnt(p_nompnt_id VARCHAR2,
                      p_nomination_category VARCHAR2 DEFAULT NULL,
                      p_bf_number VARCHAR2 DEFAULT NULL
                      )

RETURN VARCHAR2
IS

-- Used for finding which nompnt category
lv_entry_location_id nomination_point.entry_location_id%TYPE;
lv_exit_location_id  nomination_point.exit_location_id%TYPE;

lv_valid VARCHAR2(1);

BEGIN
    ecdp_dynsql.WriteTempText('OHS','p_bf_number:' || p_bf_number ||', p_nomination_category:' ||p_nomination_category);
  IF p_nomination_category IS NOT NULL THEN
    lv_valid := 'N';

    lv_entry_location_id := ec_nomination_point.entry_location_id(p_nompnt_id);
    lv_exit_location_id := ec_nomination_point.exit_location_id(p_nompnt_id);

    IF p_nomination_category = 'ENTRY_EXIT_PATH' THEN
       lv_valid := 'Y';
    ELSIF p_nomination_category = 'EXIT' THEN
       IF lv_exit_location_id is not null and lv_entry_location_id is null then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'ENTRY' THEN
       IF lv_exit_location_id is null AND lv_entry_location_id is not null then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'PATH' THEN
       IF lv_exit_location_id is not null AND lv_entry_location_id is not null THEN
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'EXIT_ENTRY' THEN
       IF (lv_exit_location_id is not null AND lv_entry_location_id is null)
           OR (lv_exit_location_id is null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'EXIT_PATH' THEN
       IF (lv_exit_location_id is not null and lv_entry_location_id is null)
           OR (lv_exit_location_id is not null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'ENTRY_PATH' THEN
       IF (lv_entry_location_id is not null and lv_exit_location_id is null)
           OR (lv_exit_location_id is not null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSE
     lv_valid := 'Y';
    END IF;

  END IF;


RETURN lv_valid;
--RETURN 'Y';

END valid_nompnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : valid_nompnt
-- Description    : User exit for chosing nomination point (Nomination Point, Counter Nomination Point)
--                Used for validating nomination points in popups, projects can insert logic to narrow the list of possible nomination points.
--                p_nompnt_id  - nomination point which is validated
--                p_ref_nompnt_id  - Sending in a nomination point to do validation based on (used for counter)
--                p_bf_profile  - BF Profile for the screen - possible to add different BF profiling for validation
--                p_nomination_category  - Which nomination point should be possible to choose from (based on the entry, exit location)
--                p_bf_number  - Which screen does it originate from, projects have the possibility to do special validation for different screens
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
-- Behaviour      : Return Y if nompnt have been validated and matched the criteria(s)
--
---------------------------------------------------------------------------------------------------
FUNCTION valid_counter_nompnt(p_nompnt_id VARCHAR2,
                              p_ref_nompnt_id VARCHAR2,
                              p_bf_profile VARCHAR2 DEFAULT NULL,
                              p_nomination_category VARCHAR2 DEFAULT NULL,
                              p_bf_number VARCHAR2 DEFAULT NULL,
                              p_show_operational VARCHAR2 DEFAULT NULL
                              )
RETURN VARCHAR2
IS


lv_valid VARCHAR2(1);

BEGIN
      ecdp_dynsql.WriteTempText('OHS2','p_nompnt_id:' || p_nompnt_id ||', p_ref_nompnt_id:' ||p_ref_nompnt_id||', p_bf_profile:' ||p_bf_profile||', p_nomination_category:' ||p_nomination_category||', p_bf_number:' ||p_bf_number);
  -- Set it to default Y
  lv_valid := 'Y';

  IF p_nompnt_id = p_ref_nompnt_id THEN
     lv_valid := 'N';
  ELSIF REPLACE(p_bf_profile,'$BFPROFILE$',null) IS NOT NULL THEN
    IF ec_contract.bf_profile(ec_nomination_point.contract_id(p_nompnt_id)) != p_bf_profile THEN
       lv_valid := 'N';
    END IF;
  END IF;




RETURN lv_valid;
--RETURN 'Y';

END valid_counter_nompnt;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getTransferCounterQuantity
  -- Description    :
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : NOMPNT_DAY_TRANSFER
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
FUNCTION getTransferCounterQuantity(p_transfer_seq NUMBER, p_column VARCHAR2)
RETURN NUMBER

IS

CURSOR c_nom_transfer(b_daytime DATE,b_nompnt_id VARCHAR2, b_counter_nompnt_id VARCHAR2, b_type VARCHAR2, b_service VARCHAR2)
IS
SELECT   *
FROM     NOMPNT_DAY_TRANSFER nt
WHERE    nt.daytime = b_daytime
AND      nt.object_id = b_nompnt_id
AND      nt.counter_nompnt_id = b_counter_nompnt_id
AND      nt.nomination_type = b_type
AND      nt.transfer_service = b_service;

ln_qty NUMBER;
lv_nomination_type prosty_codes.code%TYPE;
BEGIN

ln_qty := 0;

IF ec_nompnt_day_transfer.nomination_type(p_transfer_seq) = 'TRAN_INPUT' THEN
   lv_nomination_type := 'TRAN_OUTPUT';
ELSE
   lv_nomination_type := 'TRAN_INPUT';
END IF;

FOR r_nom_transfer IN c_nom_transfer(ec_nompnt_day_transfer.daytime(p_transfer_seq), ec_nompnt_day_transfer.counter_nompnt_id(p_transfer_seq), ec_nompnt_day_transfer.object_id(p_transfer_seq), lv_nomination_type, ec_nompnt_day_transfer.transfer_service(p_transfer_seq)) LOOP

   IF p_column = 'REQUESTED' THEN
      ln_qty := ln_qty + r_nom_transfer.requested_qty;
   ELSIF p_column = 'ACCEPTED' THEN
      ln_qty := ln_qty + r_nom_transfer.accepted_qty;
   ELSIF p_column = 'ADJUSTED' THEN
      ln_qty := ln_qty + r_nom_transfer.adjusted_qty;
   ELSIF p_column = 'SCHEDULED' THEN
      ln_qty := ln_qty + r_nom_transfer.scheduled_qty;
   END IF;

END LOOP;


--Send blank if qty = 0
IF ln_qty = 0 THEN
   ln_qty := NULL;
ELSE
   ln_qty := qty_sig_converter(ec_nompnt_day_transfer.object_id(p_transfer_seq),lv_nomination_type,ec_nompnt_day_transfer.daytime(p_transfer_seq), ln_qty);
END IF;

RETURN ln_qty;

END getTransferCounterQuantity;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getTransferSummaryCounterQty
  -- Description    :
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : NOMPNT_DAY_TRANSFER
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
FUNCTION getTransferSummaryCounterQty(p_daytime DATE, p_nompnt_id VARCHAR2, p_counter_nompnt_id VARCHAR2,  p_column VARCHAR2, p_service VARCHAR2, p_transfer_type VARCHAR2)
RETURN NUMBER

IS

CURSOR c_nom_transfer(b_daytime Date, b_nompnt_id VARCHAR2, b_counter_nompnt_id VARCHAR2, b_type VARCHAR2, b_service VARCHAR2)
IS
SELECT   *
FROM     NOMPNT_DAY_TRANSFER nt
WHERE    nt.daytime = b_daytime
AND      nt.object_id = b_nompnt_id
AND      nt.counter_nompnt_id = b_counter_nompnt_id
AND      nt.nomination_type = b_type
AND      nt.transfer_service = b_service;

ln_qty NUMBER;
lv_transfer_type prosty_codes.code%TYPE;
ln_sign NUMBER;

BEGIN

ln_qty := 0;

IF p_transfer_type = 'TRAN_INPUT' THEN
   lv_transfer_type := 'TRAN_OUTPUT';
ELSE
   lv_transfer_type := 'TRAN_INPUT';
END IF;

FOR r_nom_transfer IN c_nom_transfer(p_daytime, p_nompnt_id, p_counter_nompnt_id, lv_transfer_type, p_service) LOOP

   IF p_column = 'REQUESTED' THEN
      ln_qty := ln_qty + r_nom_transfer.requested_qty;
   ELSIF p_column = 'ACCEPTED' THEN
      ln_qty := ln_qty + r_nom_transfer.accepted_qty;
   ELSIF p_column = 'ADJUSTED' THEN
      ln_qty := ln_qty + r_nom_transfer.adjusted_qty;
   ELSIF p_column = 'SCHEDULED' THEN
      ln_qty := ln_qty + r_nom_transfer.scheduled_qty;
   END IF;

END LOOP;


ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),lv_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF lv_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

--Send blank if qty = 0
IF ln_qty = 0 THEN
   ln_qty := NULL;
ELSE
   ln_qty := ln_qty * ln_sign;
END IF;

RETURN ln_qty;

END getTransferSummaryCounterQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTransferSumQuantity
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOM_TRANSFER
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTransferSumQuantity(p_nompnt_id         VARCHAR2,
                                p_counter_nompnt_id VARCHAR2,
                                p_daytime           DATE,
                                p_column            VARCHAR2)
RETURN NUMBER
--</EC-DOC>
 IS

 lv_query VARCHAR2(2000);
 ln_sum_input   NUMBER;
 ln_sum_output   NUMBER;
 ln_sum NUMBER;
 ln_sign NUMBER;
 lv_transfer_type VARCHAR2(32);


BEGIN

 lv_transfer_type := ue_nomination.get_nom_type(p_nompnt_id,p_nompnt_id,p_daytime,p_column);
 ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),lv_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF lv_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_INPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_input;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_OUTPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_output;

  IF lv_transfer_type = 'TRAN_INPUT' THEN
     ln_sum := nvl(ln_sum_output,0) - nvl(ln_sum_input,0);
  ELSIF lv_transfer_type = 'TRAN_OUTPUT' THEN
     ln_sum := nvl(ln_sum_input,0) - nvl(ln_sum_output,0);
  END IF;

  RETURN ln_sum;

END getTransferSumQuantity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : get_nom_type
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOM_TRANSFER
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION get_nom_type(p_nompnt_id         VARCHAR2,
                      p_counter_nompnt_id VARCHAR2,
                      p_daytime           DATE,
                      p_column            VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
 IS

 lv_query VARCHAR2(2000);
 ln_sum_input   NUMBER;
 ln_sum_output   NUMBER;
 lv_nom_type VARCHAR2(32);


BEGIN

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_INPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_input;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_OUTPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_output;

  IF NVL(ln_sum_input,0) = nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_INPUT';
  ELSIF NVL(ln_sum_input,0) > nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_INPUT';
  ELSIF NVL(ln_sum_input,0) < nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_OUTPUT';
  ELSE
     lv_nom_type := 'TRAN_INPUT';
  END IF;

  RETURN lv_nom_type;

END get_nom_type;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTransferSummaryDifference
-- Description    : Return difference between quantities
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

FUNCTION getTransferSummaryDifference(p_nompnt_id VARCHAR2, p_qty NUMBER, p_counter_qty NUMBER, p_transfer_type VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS


ln_difference NUMBER;


BEGIN

  ln_difference := (nvl(p_qty,0) + nvl(p_counter_qty,0));

RETURN ln_difference;

END getTransferSummaryDifference;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : qty_sig_converter
-- Description    : Return qty either as plus or minus
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
FUNCTION qty_sig_converter(p_nompnt_id VARCHAR2, p_transfer_type VARCHAR2, p_daytime DATE,  p_qty NUMBER)
RETURN NUMBER
IS

 ln_sign NUMBER;
 ln_qty  NUMBER;

BEGIN

  ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),p_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF p_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

 ln_qty := p_qty * ln_sign;

RETURN ln_qty;

END qty_sig_converter;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createSubdayConfHours
-- Description    : Generates sub-daily nomination location confirmation data records for a contract day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_confirmation
--                  nompnt_sub_day_confirmation
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Generates hourly rows for the given contract day, taking contract
--                  day offsets and daylight savings time transitions into account.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createSubdayConfHours(
  p_class_name VARCHAR2,
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_contract_id VARCHAR2,
  p_confirmation_type VARCHAR2,
  p_day_con_seq NUMBER,
  p_con_status VARCHAR2
)

IS
  lr_daytimes Ecdp_Date_Time.Ec_Unique_Daytimes;

BEGIN

  lr_daytimes:= EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_daytime);

  FOR i IN 1 .. lr_daytimes.COUNT LOOP
    INSERT INTO nompnt_sub_day_confirmation (CLASS_NAME, OBJECT_ID, DAYTIME, CONTRACT_ID, CONFIRMATION_TYPE, DAY_CON_SEQ, CON_STATUS) VALUES (p_class_name, p_object_id, lr_daytimes(i).daytime, p_contract_id, p_confirmation_type, p_day_con_seq, p_con_status);
  END LOOP;

END createSubdayConfHours;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createNomConn
-- Description    : Generates data record in nomination connection and/or nomination point.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_connection
--                  nomination point
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Generates a new record in table nompnt_connection where connection does not exit in
--                  counter nomination point
--                  or create a new record in table nomination_point according to shipper code.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createNomConn(
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_counter_nompnt_id VARCHAR2,
  p_shipper_code VARCHAR2
)

IS

BEGIN
  null;
END createNomConn;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDailyToDailyConf
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_confirmation
--                  nompnt_day_confirmation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nomination location confirmation table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrSubDailyToDailyConf(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_contract_id    VARCHAR2,
  p_summer_time    VARCHAR2,
  p_production_day DATE,
  p_day_con_seq    NUMBER
)
--</EC-DOC>
IS
  ln_sum_apt_qty      NUMBER :=0;
	ln_sum_apt_qty_in   NUMBER :=0;
  ln_sum_apt_qty_out  NUMBER :=0;

  ln_sum_adj_qty      NUMBER :=0;
  ln_sum_adj_qty_in   NUMBER :=0;
  ln_sum_adj_qty_out  NUMBER :=0;

  ln_sum_cnf_qty      NUMBER :=0;
  ln_sum_cnf_qty_in   NUMBER :=0;
  ln_sum_cnf_qty_out  NUMBER :=0;

  ln_input            NUMBER;
  ln_output           NUMBER;

  lv_record_exists    VARCHAR2(1):='N';

  ld_daytime DATE;

	CURSOR c_day_exits IS
	SELECT 1 FROM nompnt_day_confirmation WHERE confirmation_seq = p_day_con_seq;


	CURSOR c_sum_apt_qty_in IS
		SELECT SUM(Nvl(ACCEPTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_apt_qty_out IS
		SELECT SUM(Nvl(ACCEPTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';


  CURSOR c_sum_adj_qty_in IS
		SELECT SUM(Nvl(ADJUSTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_adj_qty_out IS
		SELECT SUM(Nvl(ADJUSTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';


  CURSOR c_sum_cnf_qty_in IS
		SELECT SUM(Nvl(CONFIRMED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_cnf_qty_out IS
		SELECT SUM(Nvl(CONFIRMED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';

BEGIN
  ld_daytime := trunc(p_daytime, 'DDD');
  ln_input  := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_INPUT',ld_daytime);
  ln_output := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_OUTPUT',ld_daytime);

   -- Find the day total
  FOR curAptSumIn IN c_sum_apt_qty_in LOOP
		ln_sum_apt_qty_in := curAptSumIn.result;
	END LOOP;

  FOR curAptSumOut IN c_sum_apt_qty_out LOOP
		ln_sum_apt_qty_out := curAptSumOut.result;
	END LOOP;

  IF ln_sum_apt_qty_in IS NULL THEN
     ln_sum_apt_qty_in := 0;
  END IF;

  IF ln_sum_apt_qty_out IS NULL THEN
     ln_sum_apt_qty_out := 0;
  END IF;

  IF ln_sum_apt_qty_out > ln_sum_apt_qty_in THEN
     ln_sum_apt_qty := ln_sum_apt_qty_out - ln_sum_apt_qty_in;
     ln_sum_apt_qty := ln_sum_apt_qty * ln_output;
  ELSE
     ln_sum_apt_qty := ln_sum_apt_qty_in - ln_sum_apt_qty_out;
     ln_sum_apt_qty := ln_sum_apt_qty * ln_input;
  END IF;

  IF ln_sum_apt_qty IS NULL THEN
     ln_sum_apt_qty := 0;
  END IF;

	FOR curAdjSumIn IN c_sum_adj_qty_in LOOP
		ln_sum_adj_qty_in := curAdjSumIn.result;
	END LOOP;

  FOR curAdjSumOut IN c_sum_adj_qty_out LOOP
		ln_sum_adj_qty_out := curAdjSumOut.result;
	END LOOP;

  IF ln_sum_adj_qty_in IS NULL THEN
     ln_sum_adj_qty_in := 0;
  END IF;

  IF ln_sum_adj_qty_out IS NULL THEN
     ln_sum_adj_qty_out := 0;
  END IF;

  IF ln_sum_adj_qty_out > ln_sum_adj_qty_in THEN
     ln_sum_adj_qty := ln_sum_adj_qty_out - ln_sum_adj_qty_in;
     ln_sum_adj_qty := ln_sum_adj_qty * ln_output;
  ELSE
     ln_sum_adj_qty := ln_sum_adj_qty_in - ln_sum_adj_qty_out;
     ln_sum_adj_qty := ln_sum_adj_qty * ln_input;
  END IF;

  IF ln_sum_adj_qty IS NULL THEN
     ln_sum_adj_qty := 0;
  END IF;

  FOR curCnfSumIn IN c_sum_cnf_qty_in LOOP
		ln_sum_cnf_qty_in := curCnfSumIn.result;
	END LOOP;

  FOR curCnfSumOut IN c_sum_cnf_qty_out LOOP
		ln_sum_cnf_qty_out := curCnfSumOut.result;
	END LOOP;

  IF ln_sum_cnf_qty_in IS NULL THEN
     ln_sum_cnf_qty_in := 0;
  END IF;

  IF ln_sum_cnf_qty_out IS NULL THEN
     ln_sum_cnf_qty_out := 0;
  END IF;

  IF ln_sum_cnf_qty_out > ln_sum_cnf_qty_in THEN
     ln_sum_cnf_qty := ln_sum_cnf_qty_out - ln_sum_cnf_qty_in;
     ln_sum_cnf_qty := ln_sum_cnf_qty * ln_output;
  ELSE
     ln_sum_cnf_qty := ln_sum_cnf_qty_in - ln_sum_cnf_qty_out;
     ln_sum_cnf_qty := ln_sum_cnf_qty * ln_input;
  END IF;

  IF ln_sum_cnf_qty IS NULL THEN
     ln_sum_cnf_qty := 0;
  END IF;


  FOR i in c_day_exits LOOP
    lv_record_exists := 'Y';
  END LOOP;

  IF lv_record_exists = 'Y' THEN -- update existing record
    UPDATE nompnt_day_confirmation
      SET ACCEPTED_QTY = ln_sum_apt_qty,
          ADJUSTED_QTY = ln_sum_adj_qty,
          CONFIRMED_QTY = ln_sum_cnf_qty
	  WHERE confirmation_seq = p_day_con_seq;
  END IF;

END aggrSubDailyToDailyConf;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOperUOM
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : IV_NOMINATION_LOCATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves operational UOM from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getOperUOM(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select oper_uom from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getOperUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNominatedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination type and nomination status
--
---------------------------------------------------------------------------------------------------
FUNCTION getNominatedQty(p_object_id   VARCHAR2,
                         p_daytime     DATE,
                         p_summer_time VARCHAR2,
                         p_class_name  VARCHAR2) RETURN NUMBER

 IS

  CURSOR c_nom_qty IS
    select o.accepted_in_qty,
           o.accepted_out_qty,
           o.adjusted_in_qty,
           o.adjusted_out_qty,
           o.confirmed_in_qty,
           o.confirmed_out_qty,
           o.scheduled_in_qty,
           o.scheduled_out_qty,
           o.requested_in_qty,
           o.requested_out_qty,
           o.nomination_type,
           o.nom_status
      from objloc_sub_day_nomination o
     where o.object_id = p_object_id
       and o.daytime = p_daytime
       and o.summer_time = p_summer_time
       and o.class_name = p_class_name;

  ln_nominated_qty NUMBER := 0;

BEGIN

  FOR cur_nom_qty IN c_nom_qty LOOP
    IF (cur_nom_qty.nomination_type = 'TRAN_INPUT') THEN
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_in_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;
    ELSIF (cur_nom_qty.nomination_type = 'TRAN_OUTPUT') THEN
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_out_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;
    ELSE --null
      ln_nominated_qty := 0;
    END IF;

  END LOOP;

  RETURN ln_nominated_qty;
END getNominatedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSchedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination type (TRAN_INPUT and TRAN_OUTPUT)
--
---------------------------------------------------------------------------------------------------
FUNCTION getSchedQty(p_object_id   VARCHAR2,
                     p_daytime     DATE,
                     p_summer_time VARCHAR2,
                     p_class_name  VARCHAR2) RETURN NUMBER

 IS

  CURSOR c_sched_qty IS
    select o.scheduled_in_qty, o.scheduled_out_qty, o.nomination_type
      from objloc_sub_day_nomination o
     where o.object_id = p_object_id
       and o.daytime = p_daytime
       and o.summer_time = p_summer_time
       and o.class_name = p_class_name;

  ln_sched_qty NUMBER := 0;

BEGIN

  FOR cur_sched_qty in c_sched_qty LOOP
    IF cur_sched_qty.nomination_type = 'TRAN_INPUT' THEN
      ln_sched_qty := cur_sched_qty.scheduled_in_qty;
    ELSIF cur_sched_qty.nomination_type = 'TRAN_OUTPUT' THEN
      ln_sched_qty := cur_sched_qty.scheduled_out_qty;
	ELSE --null
	  ln_sched_qty := 0;
    END IF;
  END LOOP;

  RETURN ln_sched_qty;

END getSchedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCapacityUOM
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : IV_NOMINATION_LOCATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves capacity UOM from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getCapacityUOM(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select capacity_uom from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getCapacityUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : setFactorsEndDate
-- Description    : set end date for factors
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_TRAN_EVENT_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2)
--</EC-DOC>
IS

CURSOR cur_end_date(cp_nomination_point_id VARCHAR2, cp_daytime DATE, cp_class_name VARCHAR2) IS
select min(daytime) end_date from OBJ_TRAN_EVENT_FACTOR
where OBJECT_ID = cp_nomination_point_id
and DAYTIME > cp_daytime
and CLASS_NAME=cp_class_name;

lv2_appuser VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
BEGIN

UPDATE OBJ_TRAN_EVENT_FACTOR
SET END_DATE = p_daytime, REV_NO = NVL2(REV_NO, REV_NO+1, 0), LAST_UPDATED_BY = lv2_appuser
WHERE OBJECT_ID = p_nomination_point_id
AND DAYTIME = (select max(daytime) from OBJ_TRAN_EVENT_FACTOR
where DAYTIME < p_daytime
and p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60))
and object_id= p_nomination_point_id
and CLASS_NAME=p_class_name)
AND p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60))
AND CLASS_NAME = p_class_name;

FOR c_end_date in cur_end_date(p_nomination_point_id, p_daytime, p_class_name) LOOP
  IF c_end_date.end_date is not null THEN
    UPDATE OBJ_TRAN_EVENT_FACTOR
    SET END_DATE = c_end_date.end_date
    where DAYTIME = p_daytime
    and object_id= p_nomination_point_id
    and CLASS_NAME = p_class_name;
  END IF;
END LOOP;

END setFactorsEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : updateFactorsEndDate
-- Description    : update end date for factors
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_TRAN_EVENT_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_class_name VARCHAR2)
--</EC-DOC>
IS

lv2_appuser VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
BEGIN

UPDATE OBJ_TRAN_EVENT_FACTOR
SET END_DATE = nvl(p_end_date, null) , REV_NO = NVL2(REV_NO, REV_NO+1, 0), LAST_UPDATED_BY = lv2_appuser
WHERE OBJECT_ID = p_nomination_point_id
AND END_DATE = p_daytime
AND CLASS_NAME = p_class_name;

END updateFactorsEndDate;

END ue_Nomination;