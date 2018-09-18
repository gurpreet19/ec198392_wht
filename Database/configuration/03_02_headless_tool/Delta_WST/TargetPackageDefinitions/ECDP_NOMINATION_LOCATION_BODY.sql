CREATE OR REPLACE PACKAGE BODY EcDp_Nomination_Location IS
/******************************************************************************
** Package        :  EcDp_Nomination_Location, body part
**
** $Revision: 1.2.2.1 $
**
** Purpose        : Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.02.2012 Kenneth Masamba
**
** Modification history:
**
** Date        Whom        Change description:
** ------      -----       -----------------------------------------------------------------------------------
** 27.09.2013  leeeewei		Added getSumFracCompRecFac, getSumFracProductCompRecFac and getFcstSumFracCompRecFac
**************************************************************************************************************/

--Cursor finding contracts  related to a company
CURSOR c_company_contracts (cp_company_id VARCHAR2) is
SELECT con.object_id
FROM contract con,contract_party_share cp, company com
WHERE com.object_id=cp_company_id
and com.object_id=cp.company_id
and (cp.object_id=con.object_id and cp.party_role='CUSTOMER');




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrContract
-- Description    : Returns aggregated qty for a shipper contract on a given day for a given cycle
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
FUNCTION getTotalReqQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalReqQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccQtyPrContract
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
FUNCTION getTotalAccQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curAggQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curAggQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curAggQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curAggQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curAggQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curAggQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
    FOR curAggQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curAggQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalAccQtyPrContract;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrContract
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
FUNCTION getTotalExtAccQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curEXTAccQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curEXTAccQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curEXTAccQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curEXTAccQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curEXTACCQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curEXTACCQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
    FOR curEXTACCQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curEXTACCQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalExtAccQtyPrContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrContract
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
FUNCTION getTotalAdjQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curADJQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curADJQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curADJQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curADJQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curADJQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curADJQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
    FOR curADJQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curADJQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalAdjQtyPrContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrContract
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
FUNCTION getTotalExtAdjQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind='Y' THEN
 	     FOR curEXTAdjQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curEXTAdjQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind='N' THEN
       FOR curEXTAdjQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curEXTAdjQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curEXTAdjQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curEXTAdjQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind='N' THEN
    FOR curEXTAdjQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curEXTAdjQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalExtAdjQtyPrContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrContract
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
FUNCTION getTotalConfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind='Y' THEN
 	     FOR curCONFQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curCONFQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind='N' THEN
       FOR curCONFQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curCONFQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind='Y' then
    FOR curCONFQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curCONFQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind='N' THEN
    FOR curCONFQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curCONFQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalConfQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrContract
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
FUNCTION getTotalExtConfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curEXTCONFQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curEXTCONFQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curEXTCONFQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curEXTCONFQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curEXTCONFQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curEXTCONFQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
    FOR curEXTCONFQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curEXTCONFQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalExtConfQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrContract
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
FUNCTION getTotalSchedQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));

          CURSOR c_contract_nom IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL
			  and ((ec_nomination_point.entry_location_id(object_id) is not null and ec_nomination_point.exit_location_id(object_id) is null) or (ec_nomination_point.exit_location_id(object_id) is not null and ec_nomination_point.entry_location_id(object_id) is null));
BEGIN
 --Find the day total
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curSCHQtySum IN c_contract_nom LOOP
		       ln_aggregated_qty:= curSCHQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curSCHQtySum IN c_contract_nom_oper LOOP
		       ln_aggregated_qty:= curSCHQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind ='Y' then
    FOR curSCHQtySum IN c_contract_nom_cycle LOOP
		ln_aggregated_qty:= curSCHQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind='N' THEN
    FOR curSCHQtySum IN c_contract_nom_cycle_oper LOOP
		ln_aggregated_qty:= curSCHQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalSchedQtyPrContract;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalReqQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
   -- ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalReqQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
   null;
END LOOP;

   IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalReqQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalACCQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalAccQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalAccQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

   IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalAccQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalExtAccQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + NVL(getTotalExtAccQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

  IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalExtAccQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalAdjQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalAdjQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

 IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalAdjQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalExtAdjQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalExtAdjQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

 IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalExtAdjQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalConfQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalConfQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

   IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalConfQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalExtConfQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalExtConfQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

  IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalExtConfQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrCompany
-- Description    : Returns aggregated qty for a company on a given day for a given cycle
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
FUNCTION getTotalSchedQtyPrCompany(
  p_company_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

BEGIN
 --Find the day total
FOR c_comp_cont in c_company_contracts (p_company_id) LOOP
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalSchedQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
END LOOP;

   IF ln_aggregated_qty =0 THEN
 return null;
 else
 return ln_aggregated_qty;
 END IF;

END getTotalSchedQtyPrCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFirstContractID
-- Description    : Returns the first contract ID for selected company. Function is used to get an dispaly an UOM on Company level.
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
FUNCTION getFirstContractID(
  p_company_id            VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_first_contracts (cp_company_id VARCHAR2) is
  SELECT con.object_id
  FROM contract con,contract_party_share cp, company com
  WHERE com.object_id=cp_company_id
  AND com.object_id=cp.company_id
  AND (cp.object_id=con.object_id and cp.party_role='CUSTOMER')
  AND Rownum = 1;

  lv_contract_id VARCHAR2(32);


BEGIN
 --Find the day total
FOR c_first_cont in c_first_contracts (p_company_id) LOOP
   lv_contract_id :=c_first_cont.object_id;
END LOOP;

   return lv_contract_id;


END getFirstContractID;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLocationType
-- Description    : Get the location type for nomination point
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
FUNCTION getLocationType(p_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR curNP (cp_object_id VARCHAR2) IS
	SELECT	p.entry_location_id, p.exit_location_id
	FROM	nomination_point p
	WHERE	p.object_id = cp_object_id;

	lv_type VARCHAR2(32);
BEGIN
	FOR c_NP IN curNP (p_object_id) LOOP
		IF 	c_NP.entry_location_id IS NOT NULL AND c_NP.exit_location_id IS NOT NULL THEN
			lv_type := 'PATH';
		ELSIF c_NP.entry_location_id IS NOT NULL AND c_NP.exit_location_id IS NULL THEN
			lv_type := 'ENTRY';
		ELSIF c_NP.entry_location_id IS NULL AND c_NP.exit_location_id IS NOT NULL THEN
			lv_type := 'EXIT';
		END IF;
	END LOOP;

	RETURN lv_type;

END getLocationType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDelstrmLocationType
-- Description    : Get the location type for the delivery stream
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
FUNCTION getDelstrmLocationType(p_delstrm_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR curDS (cp_delstrm_id VARCHAR2) IS
	SELECT  s.exit_delpnt_id, s.entry_delpnt_id
	FROM  delivery_stream s
	WHERE	s.object_id = cp_delstrm_id;

	lv_type VARCHAR2(32);
BEGIN
	FOR c_DS IN curDS (p_delstrm_id) LOOP
		IF 	c_DS.entry_delpnt_id IS NOT NULL AND c_DS.exit_delpnt_id IS NOT NULL THEN
			lv_type := 'PATH';
		ELSIF c_DS.entry_delpnt_id IS NOT NULL AND c_DS.exit_delpnt_id IS NULL THEN
			lv_type := 'ENTRY';
		ELSIF c_DS.entry_delpnt_id IS NULL AND c_DS.exit_delpnt_id IS NOT NULL THEN
			lv_type := 'EXIT';
		END IF;
	END LOOP;

	RETURN lv_type;

END getDelstrmLocationType;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLocationName
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
FUNCTION getLocationName(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR curNP (cp_object_id VARCHAR2) IS
	SELECT	p.entry_location_id, p.exit_location_id
	FROM	nomination_point p
	WHERE	p.object_id = cp_object_id;

	lv_name VARCHAR2(240);
BEGIN
	FOR c_NP IN curNP (p_object_id) LOOP
		IF 	c_NP.entry_location_id IS NOT NULL AND c_NP.exit_location_id IS NOT NULL THEN
			lv_name := ecdp_objects.GetObjName(p_object_id, p_daytime);
		ELSIF c_NP.entry_location_id IS NOT NULL AND c_NP.exit_location_id IS NULL THEN
			lv_name := ecdp_objects.GetObjName(c_NP.entry_location_id, p_daytime);
		ELSIF c_NP.entry_location_id IS NULL AND c_NP.exit_location_id IS NOT NULL THEN
			lv_name := ecdp_objects.GetObjName(c_NP.exit_location_id, p_daytime);
		END IF;
	END LOOP;

	RETURN lv_name;

END getLocationName;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : lesserRule
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
FUNCTION lesserRule(p_qty_one NUMBER, p_qty_two NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	IF p_qty_one > p_qty_two THEN
		RETURN p_qty_two;
	ELSE
		RETURN p_qty_one;
	END IF;

END lesserRule;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : converteQty
-- Description    : converts a unit from one unit to another unit and net to gross or gross to net
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
FUNCTION converteQty(p_qty NUMBER,
					p_from_unit VARCHAR2,
					p_to_unit VARCHAR2,
					p_from_condition VARCHAR2,
					p_to_condition VARCHAR2,
					p_pct NUMBER,
					p_daytime DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
	ln_return_qty NUMBER;

BEGIN
	ln_return_qty := p_qty;

	-- conver net to gros or grs to net
	IF p_to_condition <>  p_from_condition THEN
		IF p_from_condition = 'NET' AND p_to_condition = 'GRS' THEN
			ln_return_qty := (p_qty *	100) / (100 - Nvl(p_pct, 0));
		ELSIF p_from_condition = 'GRS' AND p_to_condition = 'NET' THEN
			ln_return_qty := p_qty - ((p_qty * p_pct) / 100);
		END IF;
	END IF;

	IF p_from_unit <> p_to_unit THEN
		-- expect both units to be in same unit group and a unit conversion must exit in ctrl_unit_conversion
		ln_return_qty := ecdp_unit.convertValue(ln_return_qty, p_from_unit, p_to_unit, Nvl(p_daytime, ecdp_date_time.getCurrentSysdate));
	END IF;

	RETURN ln_return_qty;

END converteQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CheckTransportNomination
-- Description    : check whether nomination point already exists in nompnt_day_nomination in order to avoid changes for contract,entry/exit location
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
PROCEDURE CheckTransportNomination(
	p_object_id VARCHAR2,
	p_contract_id VARCHAR2,
	p_entry_location_id VARCHAR2,
	p_exit_location_id VARCHAR2)

--</EC-DOC>
 IS
  lrec_np NOMINATION_POINT%ROWTYPE;

  CURSOR c_ndn IS
    SELECT object_id
      FROM nompnt_day_nomination
     WHERE object_id = p_object_id;

  CURSOR c_ndn_entry(p_object_id varchar2, p_entry_loc_id varchar2) IS
    SELECT object_id
      FROM nompnt_day_nomination
     WHERE object_id = p_object_id
       and entry_location_id = p_entry_loc_id;

  CURSOR c_ndn_exit(p_object_id varchar2, p_exit_loc_id varchar2) IS
    SELECT object_id
      FROM nompnt_day_nomination
     WHERE object_id = p_object_id
       and exit_location_id = p_exit_loc_id;

BEGIN

  -- Check if transport nominations exist for nomination point.
  FOR cndn IN c_ndn LOOP
    -- Get Old values
    lrec_np := ec_nomination_point.row_by_object_id(p_object_id);

    -- Check if contract has been changed.
    IF (p_contract_id IS NOT NULL AND p_contract_id <> lrec_np.contract_id) THEN
      Raise_Application_Error(-20554, 'Not allowed to update contract');
    END IF;

    -- Check if entry location has been updated (and that it was not null before).
    IF (lrec_np.entry_location_id is not null AND (p_entry_location_id <> lrec_np.entry_location_id or p_entry_location_id IS NULL)) THEN
      -- Need to check if the nomination point has any nominations for the old entry location.
      FOR cndp_entry in c_ndn_entry(p_object_id, lrec_np.entry_location_id) LOOP
        Raise_Application_Error(-20555, 'Not allowed to update entry location');
      END LOOP;
    END IF;

    IF (lrec_np.exit_location_id IS NOT NULL AND (p_exit_location_id <> lrec_np.exit_location_id or p_exit_location_id IS NULL)) THEN
      -- Need to check if the nomination point has any nominations for the old exit location.
      FOR cndp_exit in c_ndn_exit(p_object_id, lrec_np.exit_location_id) LOOP
          Raise_Application_Error(-20556, 'Not allowed to update exit location');
      END LOOP;
    END IF;
  END LOOP;

END CheckTransportNomination;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateRenomTime
-- Description    : Checks that the given the time does not dublicate for the same date
--
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
-- Behaviour      : Raises an exception if the times of the same date is dublicated.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateRenomTime(
	p_parent_nomination_seq	VARCHAR2,
  p_object_id VARCHAR2,
	p_daytime    	DATE
)
--</EC-DOC>
IS
	ln_tmp              NUMBER;
BEGIN


  SELECT COUNT(*) INTO ln_tmp
  FROM NOMPNT_DAY_NOMINATION
  WHERE REF_NOMINATION_SEQ = p_parent_nomination_seq
  AND OBJECT_ID = p_object_id
  AND DAYTIME = p_daytime;


	IF ln_tmp > 0 THEN
    RAISE_APPLICATION_ERROR(-20543,'Duplicate time is not allowed.');
	END IF;

END validateRenomTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalTransfQtyPrContract
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
FUNCTION getTotalReqTransfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty         NUMBER;
          ln_aggregated_output_qty  NUMBER;
          ln_aggregated_input_qty   NUMBER;
          ln_input                  NUMBER;
          ln_output                 NUMBER;
          lv_nom_type_out           VARCHAR2(15);
          lv_nom_type_in            VARCHAR2(15);


          --Nomination Output
          CURSOR c_contract_nom_cycle_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle
		  AND daytime = p_date and nomination_type=cp_nom_type_out
		  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_cycle_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle
			  AND daytime = p_date and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null
			  AND daytime = p_date and nomination_type=cp_nom_type_out
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null
			  AND daytime = p_date and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          --Nomination Input
          CURSOR c_contract_nom_cycle_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle
		  AND daytime = p_date and nomination_type=cp_nom_type_in
		  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_cycle_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle
			  AND daytime = p_date and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null
			  AND daytime = p_date and nomination_type=cp_nom_type_in
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null
			  AND daytime = p_date and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y'
			  and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


BEGIN
  lv_nom_type_out := 'TRAN_OUTPUT';
  lv_nom_type_in := 'TRAN_INPUT';
  ln_aggregated_qty         := 0;
  ln_aggregated_output_qty  := 0;
  ln_aggregated_input_qty   := 0;


  ln_input  := -1;
  ln_output := 1;
 --Find the day total
 --Nomination Output and Nom cycle null
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

  --Nomination Input and nom cycle not null
   IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

--Nimination Output nom cycle null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  --Nimination Input nom cycle not null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_output_qty IS NULL THEN
     ln_aggregated_output_qty := 0;
  END IF;

  IF ln_aggregated_input_qty IS NULL THEN
     ln_aggregated_input_qty := 0;
  END IF;

  IF ln_aggregated_output_qty > ln_aggregated_input_qty THEN
     ln_aggregated_qty := ln_aggregated_output_qty - ln_aggregated_input_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_output;
  ELSE--input transfers is higher
     ln_aggregated_qty := ln_aggregated_input_qty - ln_aggregated_output_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_input;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalReqTransfQtyPrContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccTransfQtyPrContract
-- Description    : Returns aggregated transfer accepted qty for a contract on a given day for a given cycle
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
FUNCTION 	getTotalAccTransfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty         NUMBER;
          ln_aggregated_output_qty  NUMBER;
          ln_aggregated_input_qty   NUMBER;
          ln_input                  NUMBER;
          ln_output                 NUMBER;
          lv_nom_type_out           VARCHAR2(15);
          lv_nom_type_in            VARCHAR2(15);


          --Nomination Output
          CURSOR c_contract_nom_cycle_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle
		  AND daytime = p_date and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_cycle_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          --Nomination Input
          CURSOR c_contract_nom_cycle_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
		  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_cycle_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


BEGIN
  lv_nom_type_out := 'TRAN_OUTPUT';
  lv_nom_type_in := 'TRAN_INPUT';
  ln_aggregated_qty         := 0;
  ln_aggregated_output_qty  := 0;
  ln_aggregated_input_qty   := 0;


  ln_input  := -1;
  ln_output := 1;
 --Find the day total
 --Nomination Output and Nom cycle null
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

  --Nomination Input and nom cycle not null
   IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

--Nimination Output nom cycle null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  --Nimination Input nom cycle not null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_output_qty IS NULL THEN
     ln_aggregated_output_qty := 0;
  END IF;

  IF ln_aggregated_input_qty IS NULL THEN
     ln_aggregated_input_qty := 0;
  END IF;

  IF ln_aggregated_output_qty > ln_aggregated_input_qty THEN
     ln_aggregated_qty := ln_aggregated_output_qty - ln_aggregated_input_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_output;
  ELSE--input transfers is higher
     ln_aggregated_qty := ln_aggregated_input_qty - ln_aggregated_output_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_input;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalAccTransfQtyPrContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjTransfQtyPrContract
-- Description    : Returns aggregated transfer adjusted qty for a contract on a given day for a given cycle
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
FUNCTION 	getTotalAdjTransfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty         NUMBER;
          ln_aggregated_output_qty  NUMBER;
          ln_aggregated_input_qty   NUMBER;
          ln_input                  NUMBER;
          ln_output                 NUMBER;
          lv_nom_type_out           VARCHAR2(15);
          lv_nom_type_in            VARCHAR2(15);


          --Nomination Output
          CURSOR c_contract_nom_cycle_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
		  and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_cycle_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          --Nomination Input
          CURSOR c_contract_nom_cycle_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
		  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_cycle_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


BEGIN
  lv_nom_type_out := 'TRAN_OUTPUT';
  lv_nom_type_in := 'TRAN_INPUT';
  ln_aggregated_qty         := 0;
  ln_aggregated_output_qty  := 0;
  ln_aggregated_input_qty   := 0;


  ln_input  := -1;
  ln_output := 1;
 --Find the day total
 --Nomination Output and Nom cycle null
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

  --Nomination Input and nom cycle not null
   IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

--Nimination Output nom cycle null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  --Nimination Input nom cycle not null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_output_qty IS NULL THEN
     ln_aggregated_output_qty := 0;
  END IF;

  IF ln_aggregated_input_qty IS NULL THEN
     ln_aggregated_input_qty := 0;
  END IF;

  IF ln_aggregated_output_qty > ln_aggregated_input_qty THEN
     ln_aggregated_qty := ln_aggregated_output_qty - ln_aggregated_input_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_output;
  ELSE--input transfers is higher
     ln_aggregated_qty := ln_aggregated_input_qty - ln_aggregated_output_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_input;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalAdjTransfQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchTransfQtyPrContract
-- Description    : Returns aggregated transfer schedule qty for a contract on a given day for a given cycle
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
FUNCTION 	getTotalSchTransfQtyPrContract(
  p_location_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE
  )
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty         NUMBER;
          ln_aggregated_output_qty  NUMBER;
          ln_aggregated_input_qty   NUMBER;
          ln_input                  NUMBER;
          ln_output                 NUMBER;
          lv_nom_type_out           VARCHAR2(15);
          lv_nom_type_in            VARCHAR2(15);


          --Nomination Output
          CURSOR c_contract_nom_cycle_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
		  and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_cycle_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_out(cp_nom_type_out VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_out and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          --Nomination Input
          CURSOR c_contract_nom_cycle_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
          WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
		  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
		  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_cycle_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code = p_nom_cycle AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;

          CURSOR c_contract_nom_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


          CURSOR c_contract_nom_oper_in(cp_nom_type_in VARCHAR2) IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_transfer t
		      WHERE p_location_id IN (ec_nomination_point.entry_location_id(object_id),ec_nomination_point.exit_location_id(object_id))
			  AND nom_cycle_code is null AND daytime = p_date
			  and nomination_type=cp_nom_type_in and nvl(oper_nom_ind,'N')<>'Y' and nom_status != 'REJ' and supplier_nompnt_id IS NOT NULL;


BEGIN
  lv_nom_type_out := 'TRAN_OUTPUT';
  lv_nom_type_in := 'TRAN_INPUT';
  ln_aggregated_qty         := 0;
  ln_aggregated_output_qty  := 0;
  ln_aggregated_input_qty   := 0;


  ln_input  := -1;
  ln_output := 1;
 --Find the day total
 --Nomination Output and Nom cycle null
 IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_out(lv_nom_type_out) LOOP
		       ln_aggregated_output_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

  --Nomination Input and nom cycle not null
   IF p_nom_cycle is null THEN
    IF p_oper_nom_ind ='Y' THEN
 	     FOR curREQQtySum IN c_contract_nom_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
    ELSE IF p_oper_nom_ind ='N' THEN
       FOR curREQQtySum IN c_contract_nom_oper_in(lv_nom_type_in) LOOP
		       ln_aggregated_input_qty:= curREQQtySum.result;
       END LOOP;
           END IF;
       END IF;
  END IF;

--Nimination Output nom cycle null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_out(lv_nom_type_out) LOOP
		ln_aggregated_output_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  --Nimination Input nom cycle not null
 IF p_nom_cycle is not null THEN
  	IF p_oper_nom_ind = 'Y' then
    FOR curREQQtySum IN c_contract_nom_cycle_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
    ELSE IF p_oper_nom_ind = 'N' THEN
    FOR curREQQtySum IN c_contract_nom_cycle_oper_in(lv_nom_type_in) LOOP
		ln_aggregated_input_qty:= curREQQtySum.result;
    END LOOP;
        END IF;
     END IF;
  END IF;

  IF ln_aggregated_output_qty IS NULL THEN
     ln_aggregated_output_qty := 0;
  END IF;

  IF ln_aggregated_input_qty IS NULL THEN
     ln_aggregated_input_qty := 0;
  END IF;

  IF ln_aggregated_output_qty > ln_aggregated_input_qty THEN
     ln_aggregated_qty := ln_aggregated_output_qty - ln_aggregated_input_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_output;
  ELSE--input transfers is higher
     ln_aggregated_qty := ln_aggregated_input_qty - ln_aggregated_output_qty;
     ln_aggregated_qty := ln_aggregated_qty * ln_input;
  END IF;

  IF ln_aggregated_qty IS NULL THEN
     ln_aggregated_qty := 0;
  END IF;

  return ln_aggregated_qty;

END getTotalSchTransfQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumFracCompRecFac
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_EVENT_CP_TRAN_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Sum component recovery factors in Period Component Recovery Factors
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumFracCompRecFac(p_class_name VARCHAR2,
                              p_object_id  VARCHAR2,
                              p_daytime    DATE)
--</EC-DOC>
 RETURN NUMBER IS

  ln_sum NUMBER := 0;

  CURSOR c_sum IS
    SELECT SUM(o.frac) sumfrac
      FROM obj_event_cp_tran_factor o
     WHERE o.class_name = p_class_name
       AND o.object_id = p_object_id
       AND o.daytime = p_daytime;

BEGIN

  FOR cur_sum IN c_sum LOOP
    ln_sum := cur_sum.sumfrac;
  END LOOP;

  RETURN ln_sum;

END getSumFracCompRecFac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumFracProductCompRecFac
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_EVENT_DIM1_CP_TRAN_FAC
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Sum component recovery factors in Period Product Component Recovery Factors
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumFracProductCompRecFac(p_class_name VARCHAR2,
									 p_object_id  VARCHAR2,
									 p_product_id VARCHAR2,
									 p_daytime    DATE)
--</EC-DOC>
 RETURN NUMBER IS

  ln_sum NUMBER := 0;

  CURSOR c_sum IS
    SELECT SUM(o.frac) sumfrac
      FROM obj_event_dim1_cp_tran_fac o
     WHERE o.class_name = p_class_name
       AND o.object_id = p_object_id
       AND o.dim1_key = p_product_id
       AND o.daytime = p_daytime;

BEGIN

  FOR cur_sum IN c_sum LOOP
    ln_sum := cur_sum.sumfrac;
  END LOOP;

  RETURN ln_sum;

END getSumFracProductCompRecFac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstSumFracCompRecFac
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_RECOVERY_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Sum component recovery factors in Forecast Period Product Component Recovery Factors
--
---------------------------------------------------------------------------------------------------
FUNCTION getFcstSumFracCompRecFac(p_class_name VARCHAR2,
                                  p_object_id  VARCHAR2,
                                  p_daytime    DATE,
                                  p_forecast_id VARCHAR2)
--</EC-DOC>
 RETURN NUMBER IS

  ln_sum NUMBER := 0;

  CURSOR c_sum IS
    SELECT SUM(f.frac) sumfrac
      FROM fcst_recovery_factor f
     WHERE f.class_name = p_class_name
       AND f.object_id = p_object_id
       AND f.daytime = p_daytime
       AND f.forecast_id = p_forecast_id;

BEGIN

  FOR cur_sum IN c_sum LOOP
    ln_sum := cur_sum.sumfrac;
  END LOOP;

  RETURN ln_sum;

END getFcstSumFracCompRecFac;

END EcDp_Nomination_Location;