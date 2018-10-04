CREATE OR REPLACE PACKAGE ue_Replicate_CargoValues IS
/******************************************************************************
** Package        : ue_Replicate_CargoValues, head part
**
** $Revision: 1.3 $
**
** Purpose        :  Replicating tables in transport with interface Cargo Values
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

PROCEDURE updateCarrier(
	p_cargo_no					NUMBER,
	p_old_carrier_id			VARCHAR2,
	p_new_carrier_id			VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
);

PROCEDURE updateBLDate(
	p_parcel_no					VARCHAR2,
	p_old_bl_date				DATE,
	p_new_bl_date				DATE,
	p_user						VARCHAR2 DEFAULT NULL
);

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
);

PROCEDURE updateUnloadDate(
	p_parcel_no					NUMBER,
	p_old_unload_date			DATE,
	p_new_unload_date			DATE,
	p_user						VARCHAR2 DEFAULT NULL
);

PROCEDURE updateCargoName(
	p_old_cargo_name			VARCHAR2,
	p_new_cargo_name			VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
);

PROCEDURE updateLoadInstr(
	p_cargo_no					VARCHAR2,
	p_old_berth_id			VARCHAR2,
	p_new_berth_id			VARCHAR2,
	p_old_voyage_no				VARCHAR2,
	p_new_voyage_no				VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
);

PROCEDURE insertAlloc(
	p_parcel_no					NUMBER,
	p_profit_centre_id			VARCHAR2,
	p_qty						VARCHAR2,
	p_user						VARCHAR2 DEFAULT NULL
);

PROCEDURE updateLiftingQty(
  p_parcel_no NUMBER,
  p_old_qty NUMBER,
  p_new_qty NUMBER,
  p_old_date DATE,
  p_new_date DATE,
  p_nom_type VARCHAR2,
  p_prod_meas_no NUMBER DEFAULT NULL,
  p_user VARCHAR2 DEFAULT NULL
);

PROCEDURE insertFromCargoStatus(
  p_cargo_no NUMBER,
  p_cargo_status VARCHAR2,
  p_user VARCHAR2 DEFAULT NULL
);

PROCEDURE updateFromCargoStatus(
  p_cargo_no NUMBER,
  p_cargo_status_old VARCHAR2,
  p_cargo_status_new VARCHAR2,
  p_user VARCHAR2 DEFAULT NULL
);

END ue_Replicate_CargoValues;