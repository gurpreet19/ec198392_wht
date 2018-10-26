CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Capacity IS
    /****************************************************************
    ** Package        :  EcDp_Contract_Capacity; body part
    **
    ** $Revision: 1.10 $
    **
    ** Purpose        :
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created        :  15.09.2008  Arief Zaki
    **
    ** Modification history:
    **
    ** Date        Whom     Change description:
    ** ----------  -----    -------------------------------------------
    ** 16.09.2008  zakiiari  ECPD-9807: initial version
    ** 19.05.2009  oonnnng   ECPD-11850: Added getAwardedCapacity() and getAvailableCapacity() functions.
    ** 28.10.2009  oonnnng   ECPD-13151: Amended getAwardedCapacity() and getAvailableCapacity() functions to return NUMBER, not INTEGER.
    ** 14.09.2012  sharawan  ECPD-19576: Added function getAccumulatedQty() and procedure aggregateRequestQty().
    ** 24.01.2013  meisihil  ECPD-26382: Added function checkConnOverlaps
    ** 24.01.2013  meisihil  ECPD-26382: Updated parameters for functions getNominationQty, getSubDayNominationQty, getSubDayIconPath and getSubDayIconPath
	** 13.03.2015  muhammah  ECPD-28867: Updated variable lv_ok_icon_path, lv_nok_icon_path values
	** 06-08-2015  asareswi  ECPD-26383: Updated function getAvailableCapacity : Added sum() in the cntr_period_capacity query to get the total capacity for the contract capacity for a day and subtract it from default reserved capacity.
**************************************************************************************************/

		--Path to Default treview Icon
    lv_ok_icon_path varchar2(50) := 'OK.png';
    lv_nok_icon_path varchar2(50) := 'error_msg.gif';

    --Cursor to find the transaction_direction from contract_capacity object
    CURSOR c_trans_direction (cp_contract_id VARCHAR2, cp_oper_location_id VARCHAR2, cp_cntr_cap_type VARCHAR2, cp_daytime DATE) IS
             SELECT v.TRANSACTION_DIRECTION
               from contract_capacity p, cntr_capacity_version v
              where p.contract_id = cp_contract_id
                and p.location_id = cp_oper_location_id
                and p.capacity_type = cp_cntr_cap_type
                and p.object_id = v.object_id
                AND v.daytime <= cp_daytime
                AND Nvl(v.end_date, cp_daytime+1) > cp_daytime;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getReservedTerminalCapacity
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_cap_request
    --
    -- Using functions: ec_cntr_capacity_version
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getReservedTerminalCapacity(p_object_id CONTRACT.OBJECT_ID%TYPE,
                                         p_daytime   DATE) RETURN NUMBER
    --</EC-DOC>
     IS

        ln_rsv_capacity NUMBER;

        CURSOR c_cntr_cap IS
            SELECT sum(nvl(cv.def_reserved_capacity, 0)) as total_capacity
              FROM contract_capacity cc, cntr_capacity_version cv
             WHERE cc.object_id = cv.object_id
               AND cc.contract_id = p_object_id
               AND p_daytime >= cv.daytime
               AND p_daytime < nvl(cv.end_date, p_daytime + 1);

    BEGIN
        FOR cur IN c_cntr_cap LOOP
            ln_rsv_capacity := nvl(cur.total_capacity, 0);
        END LOOP;

        RETURN ln_rsv_capacity;
    END getReservedTerminalCapacity;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAvailableTerminalCapacity
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_cap_request
    --
    -- Using functions: ec_cntr_capacity_version
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getAvailableTerminalCapacity(p_object_id CONTRACT.OBJECT_ID%TYPE,
                                          p_daytime   DATE) RETURN NUMBER
    --</EC-DOC>
     IS

        ln_reserved_capacity  NUMBER;
        ln_requested_capacity NUMBER;

        CURSOR c_req_cap IS
            SELECT sum(nvl(cr.awarded_qty, 0)) as total
              FROM cntr_day_cap_request cr
             WHERE cr.object_id = p_object_id
               AND cr.daytime = p_daytime
               AND cr.requested_status = 'AWD';

    BEGIN
        ln_reserved_capacity := getReservedTerminalCapacity(p_object_id, p_daytime);

        FOR cur IN c_req_cap LOOP
            ln_requested_capacity := nvl(cur.total, 0);
        END LOOP;

        RETURN nvl(ln_reserved_capacity, 0) + ln_requested_capacity;
    END getAvailableTerminalCapacity;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : getAwardedCapacity
    -- Description    : Returns awarded capacity for a contract and location
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
    FUNCTION getAwardedCapacity(p_contract_id VARCHAR2,
                                p_location_id VARCHAR2,
                                p_daytime     DATE) RETURN NUMBER
    --</EC-DOC>
        --</EC-DOC>
     IS

        cursor c_contract_cap(cp_contract_id VARCHAR2,
                              cp_location_id VARCHAR2,
                              cp_daytime     DATE) is
            select ccv.def_reserved_capacity
              from contract_capacity cc, cntr_capacity_version ccv
             where cc.contract_id = cp_contract_id
               and cc.location_id = cp_location_id
               and cc.object_id = ccv.object_id
               and ccv.daytime <= cp_daytime
               AND nvl(ccv.end_date, p_daytime + 1) > p_daytime;

        ln_capacity NUMBER;

    BEGIN

        FOR curCap in c_contract_cap(p_contract_id, p_location_id, p_daytime) loop
            ln_capacity := curCap.def_reserved_capacity;
        END LOOP;

        return ln_capacity;

    END getAwardedCapacity;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : getAvailableCapacity
    -- Description    : Returns available capacity for a contract and location
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
    FUNCTION getAvailableCapacity(p_contract_id VARCHAR2,
                                  p_location_id VARCHAR2,
                                  p_daytime     DATE) RETURN NUMBER
    --</EC-DOC>
        --</EC-DOC>
     IS

        cursor c_contract_cap(cp_contract_id VARCHAR2,
                              cp_location_id VARCHAR2,
                              cp_daytime     DATE) is
            select nvl(sum(cpc.reserved_capacity),0) reserved_capacity
              from contract_capacity cc, cntr_period_capacity cpc
             where cc.contract_id = cp_contract_id
               and cc.location_id = cp_location_id
               and cc.object_id = cpc.object_id
               and cpc.daytime <= cp_daytime
               AND nvl(cpc.end_date, p_daytime + 1) > p_daytime;

        cursor c_contract_cap_def(cp_contract_id VARCHAR2,
                                  cp_location_id VARCHAR2,
                                  cp_daytime     DATE) is
            select nvl(ccv.def_reserved_capacity,0) def_reserved_capacity
              from contract_capacity cc, cntr_capacity_version ccv
             where cc.contract_id = cp_contract_id
               and cc.location_id = cp_location_id
               and cc.object_id = ccv.object_id
               and ccv.daytime <= cp_daytime
               AND nvl(ccv.end_date, p_daytime + 1) > p_daytime;

        ln_reserved_capacity 		NUMBER;
		ln_def_reserved_capacity 	NUMBER;
		ln_capacity 				NUMBER;

    BEGIN

        FOR curCap in c_contract_cap(p_contract_id, p_location_id, p_daytime) loop
            ln_reserved_capacity := curCap.reserved_capacity;
        END LOOP;

		FOR curCapDef in c_contract_cap_def(p_contract_id, p_location_id, p_daytime) loop
			ln_def_reserved_capacity := curCapDef.def_reserved_capacity;
		END LOOP;

		ln_capacity := ln_def_reserved_capacity - ln_reserved_capacity;

        return ln_capacity;

    END getAvailableCapacity;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : getAccumulatedQty
    -- Description    : Returns accumulated transaction qty for a contract and location
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
    FUNCTION getAccumulatedQty(p_contract_id VARCHAR2,
                                p_oper_location_id VARCHAR2,
                                p_cntr_cap_type VARCHAR2,
                                p_daytime     DATE) RETURN NUMBER
    --</EC-DOC>
    IS
        ln_inj_qty  NUMBER := 0;
        ln_withdrawal_qty  NUMBER := 0;
        ln_sum_trans_qty  NUMBER := 0;
        lv2_direction VARCHAR2(32);

        CURSOR c_req_qty(cp_tran_direction VARCHAR2) IS
            SELECT sum(k.transaction_qty) sum_qty
            from cntr_capacity_day_trans k, contract_capacity p, cntr_capacity_version v
            where k.object_id = p.OBJECT_ID
                and p_contract_id IN (k.contract_id, p.CONTRACT_ID)
                and p_oper_location_id IN (k.oper_location_id, p.location_id)
                and p_cntr_cap_type IN (k.cntr_cap_type, p.CAPACITY_TYPE)
                and p.object_id = v.object_id
                and k.daytime <= p_daytime
                and k.request_status NOT IN ('REJ')
                and v.TRANSACTION_DIRECTION = cp_tran_direction;

    BEGIN

        -- retrieving contract capacity transaction direction (injection or withdrawal)
        FOR curTransDirection IN c_trans_direction (p_contract_id, p_oper_location_id, p_cntr_cap_type, p_daytime) LOOP
          lv2_direction := curTransDirection.TRANSACTION_DIRECTION;

          -- retrieving injection and withdrawal qty
              FOR curReqQty IN c_req_qty(lv2_direction) LOOP
                  IF lv2_direction = 'INJ' THEN
                     ln_inj_qty := curReqQty.sum_qty;
                  ELSIF lv2_direction = 'WITHDRAWAL' THEN
                     ln_withdrawal_qty := curReqQty.sum_qty;
                  END IF;
              END LOOP;

        END LOOP;

        --calculating the accumulated transaction qty
        ln_sum_trans_qty := NVL(ln_inj_qty, 0) - NVL(ln_withdrawal_qty, 0);
        return ln_sum_trans_qty;

    END getAccumulatedQty;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : aggregateRequestQty
    -- Description    : Getting the transaction qty (from cntr_capacity_day_trans table)  by Transaction sum (injection) - Transaction sum (withdrawal) and
    --                  update Transaction_qty column (in cntr_day_capacity_req table)
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_capacity_day_trans
    --                  cntr_day_capacity_req
    --                  ov_contract_capacity
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE aggregateRequestQty(
        p_contract_id   	       VARCHAR2,
        p_daytime             	   DATE,
        p_oper_location_id         VARCHAR2,
        p_cntr_cap_type            VARCHAR2
    )
    --</EC-DOC>
    IS
        ln_inj_qty  NUMBER := 0;
        ln_withdrawal_qty  NUMBER := 0;
        ln_sum_trans_qty  NUMBER := 0;
        lv2_direction VARCHAR2(32);

        CURSOR c_req_qty(cp_tran_direction VARCHAR2) IS
            SELECT sum(k.transaction_qty) sum_qty
            from cntr_capacity_day_trans k, contract_capacity p, cntr_capacity_version v
            where k.object_id = p.OBJECT_ID
                and p_contract_id IN (k.contract_id, p.CONTRACT_ID)
                and p_oper_location_id IN (k.oper_location_id, p.location_id)
                and p_cntr_cap_type IN (k.cntr_cap_type, p.CAPACITY_TYPE)
                and p.object_id = v.object_id
                and k.daytime = p_daytime
                and k.request_status NOT IN ('REJ')
                and v.TRANSACTION_DIRECTION = cp_tran_direction;

    BEGIN

        -- retrieving contract capacity transaction direction (injection or withdrawal)
        FOR curTransDirection IN c_trans_direction (p_contract_id, p_oper_location_id, p_cntr_cap_type, p_daytime) LOOP
          lv2_direction := curTransDirection.TRANSACTION_DIRECTION;

          -- retrieving injection and withdrawal qty
              FOR curReqQty IN c_req_qty(lv2_direction) LOOP
                  IF lv2_direction = 'INJ' THEN
                     ln_inj_qty := curReqQty.sum_qty;
                  ELSIF lv2_direction = 'WITHDRAWAL' THEN
                     ln_withdrawal_qty := curReqQty.sum_qty;
                  END IF;
              END LOOP;

        END LOOP;

        --calculating the sum of transaction qty
        ln_sum_trans_qty := NVL(ln_inj_qty, 0) - NVL(ln_withdrawal_qty, 0);

        UPDATE cntr_day_capacity_req
         SET TRANSACTION_QTY = ln_sum_trans_qty,
             last_updated_by = ecdp_context.getAppUser
        WHERE OBJECT_ID = p_contract_id
             AND DAYTIME = p_daytime
             AND OPER_LOCATION_ID = p_oper_location_id
             AND CNTR_CAP_TYPE = p_cntr_cap_type;

    END aggregateRequestQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getCapacityUom
-- Description    : Returns the UOM persisted on the capacity Object. User exit function
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
FUNCTION getCapacityUom(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
  IS
  lv_capacity_uom VARCHAR2(10);
  BEGIN
    select cc.capacity_uom into lv_capacity_uom from ov_contract_capacity cc
    where  cc.object_id = p_object_id
    and    p_daytime between cc.daytime and cc.end_date;
  RETURN lv_capacity_uom;
END getCapacityUom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getCapacityQty
-- Description    : Returns Day contract capcaity value . User exit function
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

FUNCTION getCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
  ln_capacity_qty NUMBER;
  BEGIN
    select decode(dc.vol_qty, NULL, decode(dc.mass_qty, NULL, dc.energy_qty, dc.mass_qty), dc.vol_qty) into ln_capacity_qty
    from   cntr_day_cap dc
    where  dc.object_id = p_object_id
    and    dc.class_name = p_class_name
    and    dc.daytime = p_daytime;
  RETURN ln_capacity_qty;
END getCapacityQty;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSubDayCapacityQty
-- Description    : Returns Hourly Contract Capcaity value. User exit function
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
FUNCTION getSubDayCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
  ln_capacity_qty NUMBER;
  BEGIN
    select decode(dc.vol_qty, NULL, decode(dc.mass_qty, NULL, dc.energy_qty, dc.mass_qty), dc.vol_qty) into ln_capacity_qty
    from   cntr_sub_day_cap dc
    where  dc.object_id = p_object_id
    and    dc.class_name = p_class_name
    and    dc.daytime = p_daytime;
  RETURN ln_capacity_qty;
END getSubDayCapacityQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNominationQty
-- Description    : Returns Daily Nominated Quantity. User exit function
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
FUNCTION getNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_nom_status VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
    ln_return_value NUMBER;
	lv_nom_type VARCHAR2(32);
	lb_found BOOLEAN := false;
	lv_location_id VARCHAR2(32);

	CURSOR c_connections(cp_object_id VARCHAR2, cp_daytime DATE)
	IS
		SELECT c.location_id, c.nomination_type
		  FROM cntr_cap_loc_connection c
		 WHERE c.object_id = cp_object_id
		   AND c.daytime <= cp_daytime
		   AND (c.end_date IS NULL OR c.end_date > cp_daytime);

  BEGIN
	FOR c_cur IN c_connections(p_object_id, p_daytime) LOOP
		lb_found := true;
		IF c_cur.nomination_type = 'TRAN_INPUT' THEN
			lv_nom_type := 'ENTRY';
		ELSIF c_cur.nomination_type = 'TRAN_OUTPUT' THEN
			lv_nom_type := 'EXIT';
    end if;
		IF p_nom_status = 'ADJ' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalAdjQtyPrLocation(c_cur.location_id, null, lv_nom_type, p_daytime), 0);
		ELSIF p_nom_status = 'CON' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalConfQtyPrLocation(c_cur.location_id, null, lv_nom_type, p_daytime), 0);
		ELSIF p_nom_status = 'SCH' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSchedQtyPrLocation(c_cur.location_id, null, lv_nom_type, p_daytime), 0);
		END IF;
	END LOOP;

	IF NOT lb_found THEN
		lv_location_id := ec_contract_capacity.location_id(p_object_id);
		lv_nom_type := 'EXIT';
		IF p_nom_status = 'ADJ' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalAdjQtyPrLocation(lv_location_id, null, lv_nom_type, p_daytime), 0);
		ELSIF p_nom_status = 'CON' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalConfQtyPrLocation(lv_location_id, null, lv_nom_type, p_daytime), 0);
		ELSIF p_nom_status = 'SCH' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSchedQtyPrLocation(lv_location_id, null, lv_nom_type, p_daytime), 0);
		END IF;
	END IF;

    RETURN ln_return_value;

END getNominationQty;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSubDayNominationQty
-- Description    : Returns Hourly Nominated Quantity. User exit function
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
FUNCTION getSubDayNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_nom_status VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
    ln_return_value NUMBER;
	lv_nom_type VARCHAR2(32);
	lb_found BOOLEAN := false;
	lv_location_id VARCHAR2(32);

	CURSOR c_connections(cp_object_id VARCHAR2, cp_daytime DATE)
	IS
		SELECT c.location_id, c.nomination_type
		  FROM cntr_cap_loc_connection c
		 WHERE c.object_id = cp_object_id
		   AND c.daytime <= cp_daytime
		   AND (c.end_date IS NULL OR c.end_date > cp_daytime);

  BEGIN
	FOR c_cur IN c_connections(p_object_id, p_daytime) LOOP
		lb_found := true;
		IF c_cur.nomination_type = 'TRAN_INPUT' THEN
			lv_nom_type := 'ENTRY';
		ELSIF c_cur.nomination_type = 'TRAN_OUTPUT' THEN
			lv_nom_type := 'EXIT';
		END IF;
		IF p_nom_status = 'ADJ' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayAdjQtyPrLoc(c_cur.location_id, null, lv_nom_type, p_daytime, p_summer_time), 0);
		ELSIF p_nom_status = 'CON' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayConfQtyPrLoc(c_cur.location_id, null, lv_nom_type, p_daytime, p_summer_time), 0);
		ELSIF p_nom_status = 'SCH' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDaySchedQtyPrLoc(c_cur.location_id, null, lv_nom_type, p_daytime, p_summer_time), 0);
		END IF;
	END LOOP;

	IF NOT lb_found THEN
		lv_location_id := ec_contract_capacity.location_id(p_object_id);
		IF p_nom_status = 'ADJ' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayAdjQtyPrLoc(lv_location_id, null, 'ENTRY', p_daytime, p_summer_time), 0);
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayAdjQtyPrLoc(lv_location_id, null, 'EXIT', p_daytime, p_summer_time), 0);
		ELSIF p_nom_status = 'CON' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayConfQtyPrLoc(lv_location_id, null, 'ENTRY', p_daytime, p_summer_time), 0);
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDayConfQtyPrLoc(lv_location_id, null, 'EXIT', p_daytime, p_summer_time), 0);
		ELSIF p_nom_status = 'SCH' THEN
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDaySchedQtyPrLoc(lv_location_id, null, 'ENTRY', p_daytime, p_summer_time), 0);
			ln_return_value := nvl(ln_return_value, 0) + nvl(ue_nomination.getTotalSubDaySchedQtyPrLoc(lv_location_id, null, 'EXIT', p_daytime, p_summer_time), 0);
		END IF;
    end if;

    RETURN ln_return_value;
END getSubDayNominationQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getDayIconPath
-- Description    : Function for retrieving the Icon path used for in screen treeview in Daily Contract Capacity Validation
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
FUNCTION getDayIconPath(p_objectId VARCHAR2, p_daytime DATE, p_capacity_qty NUMBER) RETURN VARCHAR2
  --</EC-DOC>
  is
    lv_return_value varchar2(50);
	ln_capacity_qty NUMBER;
	ln_nominated_qty NUMBER;
  begin
	--ln_capacity_qty := ue_Contract_Capacity.getCapacityQty(p_objectId, p_daytime, 'TRCN_DAY_CAP');
	ln_capacity_qty := p_capacity_qty;
	ln_nominated_qty := ue_Contract_Capacity.getNominationQty(p_objectId, p_daytime, 'SCH');

	IF ln_capacity_qty < ln_nominated_qty THEN
		lv_return_value := lv_nok_icon_path;
	ELSE
    lv_return_value :=  lv_ok_icon_path;
	END IF;
    return lv_return_value;
  end getDayIconPath;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSubDayIconPath
-- Description    : Function for retrieving the sub day Icon path used for in screen treeview in Daily Contract Capacity Validation
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
FUNCTION getSubDayIconPath(p_objectId VARCHAR2, p_timestamp DATE, p_summer_time VARCHAR2, p_capacity_qty NUMBER) RETURN VARCHAR2
  --</EC-DOC>
is
    lv_return_value varchar2(50);
	ln_capacity_qty NUMBER;
	ln_nominated_qty NUMBER;
  begin
	--ln_capacity_qty := ue_Contract_Capacity.getSubDayCapacityQty(p_objectId, p_timestamp, 'TRCN_SUB_DAY_CAP');
	ln_capacity_qty := p_capacity_qty;
	ln_nominated_qty := ue_Contract_Capacity.getSubDayNominationQty(p_objectId, p_timestamp, p_summer_time, 'SCH');

	IF ln_capacity_qty < ln_nominated_qty THEN
		lv_return_value := lv_nok_icon_path;
	ELSE
    lv_return_value :=  lv_ok_icon_path;
	END IF;
    return lv_return_value;
  end getSubDayIconPath;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkConnOverlaps
-- Description    : Checks if overlapping connection exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping connection exists.
--
-- Using tables   : CNTR_CAP_LOC_CONNECTION
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
PROCEDURE checkConnOverlaps(p_object_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_nomination_type VARCHAR2)
--</EC-DOC>
IS
  -- overlapping period can't exist in nomination point connection
	CURSOR c_location_list IS
	  SELECT *
	  FROM CNTR_CAP_LOC_CONNECTION n
	  WHERE n.object_id = p_object_id
		AND n.location_id = p_location_id
		AND n.nomination_type = p_nomination_type
		AND n.daytime <> p_daytime
		AND (n.end_date > p_daytime OR n.end_date IS NULL)
		AND (n.daytime < p_end_date OR p_end_date IS NULL);

  lv_message VARCHAR2(4000);


BEGIN

  lv_message := null;

  FOR c_cur IN c_location_list LOOP
    lv_message := lv_message ||c_cur.object_id|| ' ';
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20403, 'A record must not overlap with an existing record period.');
  END IF;

END checkConnOverlaps;

END EcDp_Contract_Capacity;