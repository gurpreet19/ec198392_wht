CREATE OR REPLACE PACKAGE BODY ue_Replicate_CargoValues IS
/******************************************************************************
** Package        :  ue_Replicate_CargoValues, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Replicating tables in transport with interface IFAC_CargoValues
**
** Documentation  :  www.energy-components.com
**
** Created  		:	10.09.2007 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
**
********************************************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCarrier
--
-- Description    : Update vessel_code(carrier) in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: ec_carrier.object_code
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateCarrier(
	p_cargo_no					NUMBER,
	p_old_carrier_id			VARCHAR2,
	p_new_carrier_id			VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
  NULL;
END updateCarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateBLDate
--
-- Description    : Update bl_date in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates bl_date, but also point_of_sale_date if incoterm = FOB
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateBLDate(
	p_parcel_no					VARCHAR2,
	p_old_bl_date				DATE,
	p_new_bl_date				DATE,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
  NULL;
END updateBLDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateDetails
--
-- Description    : updates details like consignor, consignee, price_concept, discharge_point, contract_code
--						  for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :  storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      :	Update details for a cargo
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateDetails(
	p_parcel_no					VARCHAR2,
	p_old_consignor				VARCHAR2,
	p_new_consignor				VARCHAR2,
	p_old_consignee				VARCHAR2,
	p_new_consignee				VARCHAR2,
	p_old_incoterm				VARCHAR2,
	p_new_incoterm				VARCHAR2,
	p_old_contract_id			VARCHAR2,
	p_new_contract_id			VARCHAR2,
	p_old_port_id				VARCHAR2,
	p_new_port_id				VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
)

--</EC-DOC>
IS
BEGIN
  NULL;
END updateDetails;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateUnloadDate
--
-- Description    : Update unload_date in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates unload_date, but also point_of_sale_date if incoterm = CIF
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateUnloadDate(
	p_parcel_no					NUMBER,
	p_old_unload_date			DATE,
	p_new_unload_date			DATE,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
  NULL;
END updateUnloadDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCargoName
--
-- Description    : Update a cargoname in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: ec_cargo_transport.cargoname
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates unload_date, but also point_of_sale_date if incoterm = CIF
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateCargoName(
	p_old_cargo_name			VARCHAR2,
	p_new_cargo_name			VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
   NULL;
END updateCargoName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateLoadInstr
--
-- Description    : Update a vessel_code, loading_point and voyage_no in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : cargo_transport
--
-- Using functions: ec_cargo_transport.cargoname,
--
-- Configuration
-- required       :
--
-- Behaviour      : update loading_point and voyage_no in cargo_values, when one or both fields have
--							been updated.
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateLoadInstr(
	p_cargo_no					VARCHAR2,
	p_old_berth_id			VARCHAR2,
	p_new_berth_id			VARCHAR2,
	p_old_voyage_no				VARCHAR2,
	p_new_voyage_no				VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
  NULL;
END updateLoadInstr;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertAlloc
--
-- Description    :
--
-- Preconditions  :
--
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
PROCEDURE insertAlloc(
	p_parcel_no					NUMBER,
	p_profit_centre_id			VARCHAR2,
	p_qty						VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN
  NULL;
END insertAlloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateLiftingQty
--
-- Description    :
--
-- Preconditions  :
--
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
PROCEDURE updateLiftingQty(p_parcel_no NUMBER,
					p_old_qty NUMBER,
					p_new_qty NUMBER,
					p_old_date DATE,
					p_new_date DATE,
					p_nom_type VARCHAR2,
					p_prod_meas_no NUMBER DEFAULT NULL,
					p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
  NULL;
END updateLiftingQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertFromCargoStatus
--
-- Description    :
--
-- Preconditions  :
--
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
PROCEDURE insertFromCargoStatus(p_cargo_no NUMBER, p_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
  NULL;
END insertFromCargoStatus;


END ue_Replicate_CargoValues;