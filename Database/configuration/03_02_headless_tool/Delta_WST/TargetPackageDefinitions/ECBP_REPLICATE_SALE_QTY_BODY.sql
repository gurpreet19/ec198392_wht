CREATE OR REPLACE PACKAGE BODY EcBp_Replicate_Sale_Qty IS
/****************************************************************
** Package        :  EcBp_Replicate_Sale_Qty
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  19.04.2006  Jean Ferre
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 19.04.2006  Jean Ferre  Initial version
** 11.05.2006 	KSN			Rewrite
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertSalesQty
-- Description    : Inserting sales quantities to ecrevenue interface ifac_sales_qty
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
---------------------------------------------------------------------------------------------------
PROCEDURE insertSalesQty(p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2
)
IS

BEGIN
	NULL;

END insertSalesQty;

END EcBp_Replicate_Sale_Qty;