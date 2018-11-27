CREATE OR REPLACE PACKAGE BODY EcBp_Replicate_Cargo_Qty IS
/******************************************************************************
** Package        :  EcBp_Replicate_Cargo_Qty, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Replicate quantities from sale into ifac_quantities
**
** Documentation  :  www.energy-components.com
**
** Created  		:	09.03.2006 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 09.03.2006		Jean Ferré	Initial version
** 04.04.2006	Kari Sandvik	Updated
** 07.04.2006	Arild Vervik	Added Exportparselsplit and replicateMeL, checked in redesigned package
** 20.04.2006 Arild Vervik  Made this package body into a dummy version so initial install are without Revenue interface.
**                          Revenue interface code that was here is moved to subfolder optional in file EcBp_Replicate_Quantities_body2.sql
**                          where hardcoded references are handled by separate install script
**                          Note interface in this package and the version under optional has to be kept in sync.
********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : insertQty
-- Description    : Inserts a row into the ecrevenue_xxx.ifac_quantities table
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
PROCEDURE insertQty(p_product_code VARCHAR2,
					p_company_code VARCHAR2,
					p_profit_centre_code VARCHAR2,
					p_daytime DATE,
					p_qty_type VARCHAR2,
					p_qty NUMBER,
					p_uom VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END insertQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicatePROD
-- Description    : This procedure inserts/updates the monthly production on product, company and profit centre
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : stor_day_pc_cpy_receipt, storage, product
--
-- Using functions: ecbp_lifting_entitlement.IsMissingProdNumbers ,ecbp_storage_lift_nomination.getNomUnit
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE replicatePROD(p_DAYTIME DATE)

--</EC-DOC>
IS
BEGIN
  NULL;
END replicatePROD;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateGIT
-- Description    : This procedure inserts/updates the monthly Gods in Transit on product, company and profit centre
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
PROCEDURE replicateGIT(p_DAYTIME DATE)

--</EC-DOC>
IS

BEGIN
  NULL;
END replicateGIT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateLoss
-- Description    : This procedure inserts/updates the monthly Loss on product, company and profit centre
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
PROCEDURE replicateLoss(p_DAYTIME DATE)

--</EC-DOC>
IS

BEGIN
NULL;
END replicateLoss;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateInv
-- Description    : This procedure inserts/updates the monthly Inventory on product, company and profit centre
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
-- Behaviour      :	special behavoiur for NLNG in 8.3. This would usually be lifting account balance
--
---------------------------------------------------------------------------------------------------
PROCEDURE replicateInv(p_DAYTIME DATE)

--</EC-DOC>
IS
BEGIN
  NULL;
END replicateInv;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : Exportparselsplit
-- Description    : Find the Percentage the given parcel is of the total load on Cargo
-- Preconditions  :
--
-- Postconditions : Returns the percentage or NULL if the percentage is undefined or 0.
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :	Loops over Storage lifting,
--
---------------------------------------------------------------------------------------------------
FUNCTION  Exportparselsplit(p_parcel_no number) return number
--</EC-DOC>
IS


BEGIN
  NULL;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : replicateMeL
-- Description    : This procedure inserts/updates the monthly MEL (Month end liftings) on product, company and profit centre
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
PROCEDURE replicateMeL(p_DAYTIME DATE)

--</EC-DOC>
IS

BEGIN
  NULL;
END replicateMel;

END EcBp_Replicate_Cargo_Qty;