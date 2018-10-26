CREATE OR REPLACE PACKAGE BODY EcDp_NOMINATION IS
/******************************************************************************
** Package        :  EcDp_Contract_Nom, body part
**
** $Revision: 1.19 $
**
** Purpose        : Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  04.03.2008 Olav N�and
**
** Modification history:
**
** Date        Whom        Change description:
** ------      -----       -----------------------------------------------------------------------------------
**04.03.2008   ON          Initial Version
**30.04.2008   ON          Added functions for Company
**08.01.2009   musaamah    ECPD-9845: Change the return type for functions to return NUMBER instead of INTEGER
**20.05,2009   madondin    ECPD-11543: Changing contract or location to a nomination point should not be allow when nominations exists
**16.02,2011   masamken    ECPD-16565: Added new procedure validateRenomTime() validation of the duplicate daytime
**13.06.2012   sharawan    ECPD-19476: Added new functions getTotalAdjQtyPrLoc, getTotalSchedQtyPrLoc, getSubDayTotalAdjQtyPrLoc,
**                         getSubDayTotalSchedQtyPrLoc for GD.0062-Sub Daily Nomination Location Capacity.
**31.07.2012   sharawan    ECPD-19482: Add new functions getNomUOM, getTotalLocSchedQtyMth, getTotalLocSchedQtyDay,
**                         getTotalSchedQtyPrLocationMth, getTotalSchedQtyPrLocationDay for GD.0047 : Monthly OBA Status.
**17.04.2013   meisihil    ECPD-23623: Added new function getSortOrder
**19.04.2013   meisihil    ECPD-XXXXX: Added new functions getSubDayAccQtyPrContract. getSubDayAdjQtyPrContract, getSubDayConfQtyPrContract
**25.07.2013   leeeewei    ECPD-22725: Added new procedure aggrRequestedQty and validateRenomSubTime
**31.01.2014   meisihil    ECPD-25609: Added p_class_name parameter for functions getTotalAdjQtyPrLoc, getTotalSchedQtyPrLoc, getSubDayTotalAdjQtyPrLoc, getSubDayTotalSchedQtyPrLoc
**24.01.2018   sandetho    ECPD-50371: Added new function getSumNomptQty.
**13.02.2018   baratmah    ECPD-50100: Added new procedure validateOverlappingConnection.
**09.04.2018   baratmah    ECPD-52929: Added new function getClassName.
**************************************************************************************************************/

--Cursor finding contracts  related to a company
CURSOR c_company_contracts (cp_company_id VARCHAR2) is
SELECT con.object_id
FROM contract con,contract_party_share cp, company com
WHERE com.object_id=cp_company_id
and com.object_id=cp.company_id
and (cp.object_id=con.object_id and cp.party_role='CUSTOMER');

/*
Cursor getting meter ID. This Meter ID can be use to get Meter Type (TRAN_METER_TYPE).
Meter and Contract Inventory and Nomination Point will always be in the same location. */
CURSOR c_meter_type (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT distinct(m.object_id) METER_ID
FROM meter_alloc_method_np n, meter_alloc_method m
WHERE n.alloc_method_seq = m.alloc_method_seq
AND n.contract_inventory = cp_object_id
AND cp_daytime BETWEEN m.DAYTIME AND nvl(m.end_date, cp_daytime + 1);

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrContract
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
FUNCTION getTotalReqQtyPrContract(
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(REQUESTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_ACCEPTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_ADJUSTED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(EXT_CONFIRMED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
  p_contract_id            VARCHAR2,
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
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(SCHEDULED_QTY) result
		      FROM nompnt_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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
    ln_aggregated_qty:= Nvl(ln_aggregated_qty, 0) + Nvl(getTotalReqQtyPrContract(c_comp_cont.object_id,p_nom_cycle,p_nom_type,p_oper_nom_ind,p_date),0);
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
-- Function       : getTotalAdjQtyPrLoc
-- Description    : Returns the aggregated value (daily data) of all adjusted nominations on the selected location
--                  based on the nomination_type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : objloc_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrLoc(
  p_object_id            VARCHAR2,
  p_nom_type             VARCHAR2,
  p_daytime              DATE,
  p_class_name           VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_aggregated_qty   NUMBER;

    CURSOR c_adjusted_qty IS
    SELECT SUM(ADJUSTED_IN_QTY) ADJUSTED_IN_QTY, SUM(ADJUSTED_OUT_QTY) ADJUSTED_OUT_QTY
    FROM objloc_day_nomination
    WHERE object_id = p_object_id
    AND daytime = p_daytime
	AND class_name = p_class_name;

BEGIN

    FOR curAdjQty IN c_adjusted_qty LOOP
		IF curAdjQty.ADJUSTED_IN_QTY IS NOT NULL OR curAdjQty.ADJUSTED_OUT_QTY IS NOT NULL THEN
			ln_aggregated_qty := NVL(curAdjQty.ADJUSTED_IN_QTY, 0) + NVL(curAdjQty.ADJUSTED_OUT_QTY, 0);
 		END IF;
    END LOOP;

       return ln_aggregated_qty;

END getTotalAdjQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrLoc
-- Description    : Returns the aggregated value (daily data) of all scheduled nominations on the selected location
--                  based on the nomination_type.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : objloc_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrLoc(
  p_object_id VARCHAR2,
  p_nom_type VARCHAR2,
  p_daytime DATE,
  p_class_name VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_aggregated_qty   NUMBER;

    CURSOR c_scheduled_qty IS
    SELECT SUM(SCHEDULED_IN_QTY) SCHEDULED_IN_QTY, SUM(SCHEDULED_OUT_QTY) SCHEDULED_OUT_QTY
    FROM objloc_day_nomination
    WHERE object_id = p_object_id
    AND daytime = p_daytime
	AND class_name = p_class_name;

BEGIN

    FOR curSchedQty IN c_scheduled_qty LOOP
		IF curSchedQty.SCHEDULED_IN_QTY IS NOT NULL OR curSchedQty.SCHEDULED_OUT_QTY IS NOT NULL THEN
			ln_aggregated_qty := NVL(curSchedQty.SCHEDULED_IN_QTY, 0) + NVL(curSchedQty.SCHEDULED_OUT_QTY, 0);
 		END IF;
    END LOOP;

       return ln_aggregated_qty;

END getTotalSchedQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayTotalAdjQtyPrLoc
-- Description    : Returns the aggregated value (sub daily data) of all adjusted nominations on the selected location
--                  based on the nomination_type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : objloc_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayTotalAdjQtyPrLoc(
  p_object_id            VARCHAR2,
  p_nom_type             VARCHAR2,
  p_daytime              DATE,
  p_class_name           VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_aggregated_qty   NUMBER;

    CURSOR c_adjusted_qty IS
    SELECT SUM(ADJUSTED_IN_QTY) ADJUSTED_IN_QTY, SUM(ADJUSTED_OUT_QTY) ADJUSTED_OUT_QTY
    FROM objloc_sub_day_nomination
    WHERE object_id = p_object_id
    AND daytime = p_daytime
	AND class_name = p_class_name;

BEGIN

    FOR curAdjQty IN c_adjusted_qty LOOP
		IF curAdjQty.ADJUSTED_IN_QTY IS NOT NULL OR curAdjQty.ADJUSTED_OUT_QTY IS NOT NULL THEN
			ln_aggregated_qty := NVL(curAdjQty.ADJUSTED_IN_QTY, 0) + NVL(curAdjQty.ADJUSTED_OUT_QTY, 0);
 		END IF;
    END LOOP;

       return ln_aggregated_qty;

END getSubDayTotalAdjQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayTotalSchedQtyPrLoc
-- Description    : Returns the aggregated value (sub daily data) of all scheduled nominations on the selected location
--                  based on the nomination_type.
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
FUNCTION getSubDayTotalSchedQtyPrLoc(
  p_object_id VARCHAR2,
  p_nom_type VARCHAR2,
  p_daytime DATE,
  p_class_name VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_aggregated_qty   NUMBER;

    CURSOR c_scheduled_qty IS
    SELECT SUM(SCHEDULED_IN_QTY) SCHEDULED_IN_QTY, SUM(SCHEDULED_OUT_QTY) SCHEDULED_OUT_QTY
    FROM objloc_sub_day_nomination
    WHERE object_id = p_object_id
    AND daytime = p_daytime
	AND class_name = p_class_name;

BEGIN

    FOR curSchedQty IN c_scheduled_qty LOOP
		IF curSchedQty.SCHEDULED_IN_QTY IS NOT NULL OR curSchedQty.SCHEDULED_OUT_QTY IS NOT NULL THEN
			ln_aggregated_qty := NVL(curSchedQty.SCHEDULED_IN_QTY, 0) + NVL(curSchedQty.SCHEDULED_OUT_QTY, 0);
		END IF;
    END LOOP;

       return ln_aggregated_qty;

END getSubDayTotalSchedQtyPrLoc;

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
-- Function       : getNomUOM
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
-- Behaviour      :Retrieves nomination UOM from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getNomUOM(p_object_id VARCHAR2,p_daytime DATE)RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select nom_uom from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getNomUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalLocSchedQtyMth
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : objloc_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalLocSchedQtyMth(
  p_object_id VARCHAR2,
  p_location_id VARCHAR2,
  p_daytime DATE,
  p_class_name VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_nomination_val  NUMBER;

BEGIN
    -- Call getTotalSchedQtyPrLocationDay to get aggregated daily data for the month
    ln_nomination_val := getTotalLocSchedQtyDay(p_object_id, p_location_id, p_daytime, p_class_name, 'MTH');

    return ln_nomination_val;

END getTotalLocSchedQtyMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalLocSchedQtyDay
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : objloc_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalLocSchedQtyDay(
  p_object_id VARCHAR2,
  p_location_id VARCHAR2,
  p_daytime DATE,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_time_span VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_nomination_val  NUMBER;
    lv2_meter_type     VARCHAR2(32);
    ld_from_date       DATE;
    ld_to_date         DATE;

    CURSOR c_scheduled_qty (cp_meter_type VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
    SELECT SUM(decode(cp_meter_type, 'ENTRY', nvl(SCHEDULED_IN_QTY, 0), 'EXIT', nvl(SCHEDULED_OUT_QTY, 0))) SCHED_QTY
    FROM objloc_day_nomination
    WHERE object_id = p_location_id
    AND daytime >= cp_from_date
    AND daytime < cp_to_date
    AND class_name = nvl(p_class_name, class_name);

BEGIN
    -- Get Meter type
    FOR curMeterType IN c_meter_type (p_object_id, p_daytime) LOOP
        lv2_meter_type := ec_meter_version.meter_type(curMeterType.METER_ID, p_daytime, '<=');
    END LOOP;

	  -- Check for time span indicator
	  IF (p_time_span IS NOT NULL AND p_time_span IN ('MTH', 'mth')) THEN
		   ld_from_date := TRUNC(p_daytime, 'MM');
       ld_to_date := LAST_DAY(ld_from_date) + 1;
    ELSE
       ld_from_date := p_daytime;
       ld_to_date   := p_daytime + 1;
	  END IF;

    FOR curSchedQty IN c_scheduled_qty (lv2_meter_type, ld_from_date, ld_to_date) LOOP
		    ln_nomination_val := curSchedQty.SCHED_QTY;
    END LOOP;

    return ln_nomination_val;

END getTotalLocSchedQtyDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrLocationMth
-- Description    :
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
FUNCTION getTotalSchedQtyPrLocationMth(
  p_object_id VARCHAR2,
  p_location_id VARCHAR2,
  p_daytime DATE,
  p_oper_nom_ind VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_nomination_val  NUMBER;

BEGIN
    -- Call getTotalSchedQtyPrLocationDay to get aggregated daily data for the month
    ln_nomination_val := getTotalSchedQtyPrLocationDay(p_object_id, p_location_id, p_daytime, p_oper_nom_ind, 'MTH');

    return ln_nomination_val;

END getTotalSchedQtyPrLocationMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrLocationDay
-- Description    :
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
FUNCTION getTotalSchedQtyPrLocationDay(
  p_object_id VARCHAR2,
  p_location_id VARCHAR2,
  p_daytime DATE,
  p_oper_nom_ind VARCHAR2 DEFAULT NULL,
  p_time_span VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_nomination_val  NUMBER;
    lv2_meter_type     VARCHAR2(32);
    ld_from_date       DATE;
    ld_to_date         DATE;

    -- Cursor for operational nomination scheduled qty
    CURSOR c_oper_sched_qty (cp_meter_type VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
    SELECT SUM(nvl(SCHEDULED_QTY, 0)) OPER_SCHED_QTY
    FROM nompnt_day_nomination
    WHERE decode(cp_meter_type, 'ENTRY', ENTRY_LOCATION_ID, 'EXIT', EXIT_LOCATION_ID) = p_location_id
    AND nomination_type = decode(cp_meter_type, 'ENTRY', 'TRAN_INPUT', 'EXIT', 'TRAN_OUTPUT')
    AND daytime >= cp_from_date
    AND daytime < cp_to_date
    AND oper_nom_ind = 'Y';

    -- Cursor for non-operational nomination scheduled qty
    CURSOR c_nonoper_sched_qty (cp_meter_type VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
    SELECT SUM(nvl(SCHEDULED_QTY, 0)) NONOPER_SCHED_QTY
    FROM nompnt_day_nomination
    WHERE decode(cp_meter_type, 'ENTRY', ENTRY_LOCATION_ID, 'EXIT', EXIT_LOCATION_ID) = p_location_id
    AND nomination_type = decode(cp_meter_type, 'ENTRY', 'TRAN_INPUT', 'EXIT', 'TRAN_OUTPUT')
    AND daytime >= cp_from_date
    AND daytime < cp_to_date
    AND (oper_nom_ind = 'N' OR oper_nom_ind IS NULL);

BEGIN

    -- Get Meter type
    FOR curMeterType IN c_meter_type (p_object_id, p_daytime) LOOP
        lv2_meter_type := ec_meter_version.meter_type(curMeterType.METER_ID, p_daytime, '<=');
    END LOOP;

	  -- Check for time span indicator
	  IF (p_time_span IS NOT NULL AND p_time_span IN ('MTH', 'mth')) THEN
		   ld_from_date := TRUNC(p_daytime, 'MM');
       ld_to_date := LAST_DAY(ld_from_date) + 1;
    ELSE
       ld_from_date := p_daytime;
       ld_to_date   := p_daytime + 1;
	  END IF;

    -- Get the Operational scheduled_qty
    IF (p_oper_nom_ind IS NOT NULL AND p_oper_nom_ind IN ('Y')) THEN
       FOR curOperSchedQty IN c_oper_sched_qty (lv2_meter_type, ld_from_date, ld_to_date) LOOP
		       ln_nomination_val := curOperSchedQty.OPER_SCHED_QTY;
       END LOOP;
    -- Get the Non-Operational scheduled_qty - NULL or 'N'
    ELSE
       FOR curNonOperSchedQty IN c_nonoper_sched_qty (lv2_meter_type, ld_from_date, ld_to_date) LOOP
		       ln_nomination_val := curNonOperSchedQty.NONOPER_SCHED_QTY;
       END LOOP;
    END IF;

    return ln_nomination_val;

END getTotalSchedQtyPrLocationDay;

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
		ln_return_qty := ecdp_unit.convertValue(ln_return_qty, p_from_unit, p_to_unit, Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate));
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
-- Function       : getSortOrder
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
-- Behaviour      :Retrieves sort order from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getSortOrder(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select sort_order from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAccQtyPrContract
-- Description    : Returns aggregated qty for a contract on a given hour for a given cycle
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
FUNCTION getSubDayAccQtyPrContract(
  p_contract_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE,
  p_summer_time            VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ACCEPTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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

  return ln_aggregated_qty;

END getSubDayAccQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAdjQtyPrContract
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
FUNCTION getSubDayAdjQtyPrContract(
  p_contract_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE,
  p_summer_time            VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(ADJUSTED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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

  return ln_aggregated_qty;


END getSubDayAdjQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayConfQtyPrContract
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
FUNCTION getSubDayConfQtyPrContract(
  p_contract_id            VARCHAR2,
  p_nom_cycle              VARCHAR2,
  p_nom_type               VARCHAR2,
  p_oper_nom_ind           VARCHAR2,
  p_date                   DATE,
  p_summer_time            VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
          ln_aggregated_qty   NUMBER;

          CURSOR c_contract_nom_cycle IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;

          CURSOR c_contract_nom_cycle_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code = p_nom_cycle AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';

          CURSOR c_contract_nom IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type;


          CURSOR c_contract_nom_oper IS
		      SELECT SUM(CONFIRMED_QTY) result
		      FROM nompnt_sub_day_nomination
		      WHERE contract_id = p_contract_id AND nom_cycle_code is null AND daytime = p_date AND summer_time = p_summer_time and nomination_type=p_nom_type and nvl(oper_nom_ind,'N')<>'Y';
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

  return ln_aggregated_qty;

END getSubDayConfQtyPrContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrRequestedQty
-- Description    : Returns aggregated qty for sub daily renomination
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_SUB_DAY_NOMINATION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrRequestedQty(p_day_nom_seq NUMBER)
--<EC-DOC>
IS

    CURSOR c_agg IS
      SELECT SUM(REQUESTED_QTY) AS AGG_REQ_QTY
        FROM NOMPNT_SUB_DAY_NOMINATION
       WHERE DAY_NOM_SEQ = p_day_nom_seq;

  BEGIN

    FOR r_agg IN c_agg LOOP

        UPDATE NOMPNT_DAY_NOMINATION
           SET REQUESTED_QTY = r_agg.AGG_REQ_QTY
         WHERE NOMINATION_SEQ = p_day_nom_seq;

    END LOOP;

END aggrRequestedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateRenomSubTime
-- Description    : Checks that the given time in sub daily renomination does not duplicate for the same date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_SUB_DAY_NOMINATION
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Raises an exception if the times of the same date is duplicated.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateRenomSubTime(p_day_nom_seq VARCHAR2, p_object_id VARCHAR2, p_production_day DATE, p_daytime DATE, p_summer_time VARCHAR2 DEFAULT 'N')
--</EC-DOC>
IS

   CURSOR c_cnt IS
    SELECT COUNT(*) AS DAYTIMESCNT
      FROM NOMPNT_SUB_DAY_NOMINATION
     WHERE DAY_NOM_SEQ = p_day_nom_seq
       AND OBJECT_ID = p_object_id
       AND PRODUCTION_DAY = p_production_day
       AND DAYTIME = p_daytime
       AND SUMMER_TIME = NVL(p_summer_time, ECDP_DATE_TIME.SUMMERTIME_FLAG(p_daytime));

  BEGIN

    FOR r_cnt IN c_cnt LOOP

      IF r_cnt.DAYTIMESCNT > 0 THEN
        RAISE_APPLICATION_ERROR(-20543,'Duplicate time is not allowed.');
      END IF;

  END LOOP;
END validateRenomSubTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumNomptQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_NP_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Sum contract quantities in nomination points
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumNomptQty(p_to_nompnt_id VARCHAR2,p_daytime DATE)
  --</EC-DOC>
 RETURN NUMBER IS

  ln_sum NUMBER := 0;

  cursor c_sum is
    SELECT sum(c.requested_qty) sumvalue
      FROM nompnt_np_day_nomination c
     WHERE c.to_nompnt_id = p_to_nompnt_id
       AND c.daytime = p_daytime;

BEGIN

  for cur_sum in c_sum loop
    ln_sum := cur_sum.sumvalue;
  end loop;

  return ln_sum;

END getSumNomptQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateOverlappingConnection
-- Description    :Validation to prevent overlapping connections
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRAN_ZONE_OPLOC_CONN
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingConnection(p_object_id VARCHAR2,
                                    p_new_oploc_id VARCHAR2,
                  p_old_oploc_id VARCHAR2,
                  p_old_daytime DATE,
                  p_new_daytime DATE,
                  p_old_end_date   DATE,
                  p_new_end_date   DATE)
--</EC-DOC>
 IS

  CURSOR c_overlapping_period(co_object_id VARCHAR2, co_new_oploc_id VARCHAR2, co_daytime DATE, co_end_date DATE) IS
    SELECT 'X'
      FROM tran_zone_oploc_conn t
     WHERE t.object_id = co_object_id
       AND t.oploc_id = co_new_oploc_id
       AND ((t.daytime <= co_daytime AND co_daytime <= t.end_date) OR
         (t.daytime < co_end_date AND co_end_date <= t.end_date) OR
         (co_daytime <= t.end_date and t.end_date <= co_end_date));

  CURSOR c_overlapping_per_exclude_curr(co_object_id VARCHAR2, co_new_oploc_id VARCHAR2, co_old_daytime DATE, co_daytime DATE, co_end_date DATE) IS
    SELECT 'X'
      FROM tran_zone_oploc_conn t
     WHERE t.object_id = co_object_id
       AND t.oploc_id = co_new_oploc_id
       AND t.daytime <> co_old_daytime
       AND ((t.daytime <= co_daytime AND co_daytime <= t.end_date) OR
         (t.daytime < co_end_date AND co_end_date <= t.end_date) OR
         (co_daytime <= t.end_date and t.end_date <= co_end_date));

BEGIN

  IF p_old_daytime IS NULL AND p_old_end_date IS NULL THEN
    -- Check during initial insert
    FOR cur_period IN c_overlapping_period(p_object_id, p_new_oploc_id, p_new_daytime, p_new_end_date) LOOP
      RAISE_APPLICATION_ERROR(-20589, 'Not allowed to have overlapping connection.');
    END LOOP;
  ELSE
    -- Check during update only if dates differed
    IF (p_old_daytime <> p_new_daytime) OR (p_old_end_date <> p_new_end_date) OR (p_old_oploc_id <> p_new_oploc_id) THEN
      FOR cur_period IN c_overlapping_per_exclude_curr(p_object_id,
                                                       p_new_oploc_id,
                                                       p_old_daytime,
                                                       p_new_daytime,
                                                       p_new_end_date) LOOP
        RAISE_APPLICATION_ERROR(-20589, 'Not allowed to have overlapping connection.');
      END LOOP;
    END IF;
  END IF;

END validateOverlappingConnection;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClassName
-- Description    : Get the class name for operational location
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
FUNCTION getClassName(p_operational_location_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
	lv_name VARCHAR2(240);
BEGIN

	select class_name into lv_name from iv_operational_locations where object_id = p_operational_location_id;

	RETURN lv_name;

END getClassName;

END EcDp_NOMINATION;