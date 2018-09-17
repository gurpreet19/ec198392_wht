CREATE OR REPLACE PACKAGE BODY ue_Contract_Capacity IS
/******************************************************************************
** Package        :  ue_Contract_Capacity, body part
**
** $Revision: 1.3.24.2 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : Fusan
**
** Modification history:
**
** Version  Date        Whom    Change description:
** -------  ------      -----   -----------------------------------------------------------------------------------------------
**          10-Mar-2010 oonnnng ECPD-12078: Add p_req_seq paramter, and modify DML statement using p_req_seq in submitTerminalRequest() function.
**
****************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : submitTerminalRequest
-- Description    : Calculate unload value. User exit function
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
PROCEDURE submitTerminalRequest(p_req_seq NUMBER, p_object_id VARCHAR2, p_daytime DATE, p_requested_qty NUMBER)
--</EC-DOC>
IS
BEGIN

  UPDATE cntr_day_cap_request cr
  SET cr.requested_status = 'SUB',
      cr.last_updated_by = ecdp_context.getAppUser
  WHERE cr.req_seq = p_req_seq;

END submitTerminalRequest;

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
  lv_capacity_uom:=ec_CNTR_CAPACITY_VERSION.capacity_uom(p_object_id,p_daytime,'<=');
  --lv_capacity_uom:=ecdp_contract_capacity.getCapacityUom(p_object_id,p_daytime);
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
  ln_capacity_qty NUMBER(10);
  BEGIN
    ln_capacity_qty:=ecdp_contract_capacity.getCapacityQty(p_object_id,p_daytime,p_class_name);
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
  ln_capacity_qty NUMBER(10);
  BEGIN
    ln_capacity_qty:=ecdp_contract_capacity.getSubDayCapacityQty(p_object_id,p_daytime,p_class_name);
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
FUNCTION getNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
  ln_nomination_qty NUMBER(10);
  BEGIN
    ln_nomination_qty:=ecdp_contract_capacity.getNominationQty(p_object_id,p_daytime,p_class_name);
  return ln_nomination_qty;
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
FUNCTION getSubDayNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER
--</EC-DOC>
  IS
  ln_nomination_qty NUMBER(10);
  BEGIN
    ln_nomination_qty:=ecdp_contract_capacity.getSubDayNominationQty(p_object_id,p_daytime,p_class_name);
  return ln_nomination_qty;
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
 Function getDayIconPath(p_objectId varchar2, p_daytime date) return varchar2
  --</EC-DOC>
  is
    lv_return_value varchar2(50);
  begin
    lv_return_value := ecdp_contract_capacity.getDayIconPath(p_objectId,p_daytime);
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
Function getSubDayIconPath(p_objectId varchar2, p_timestamp date) return varchar2
  --</EC-DOC>
is
    lv_return_value varchar2(50);
  begin
    lv_return_value := ecdp_contract_capacity.getSubDayIconPath(p_objectId,p_timestamp);
    return lv_return_value;
  end getSubDayIconPath;



END ue_Contract_Capacity;
