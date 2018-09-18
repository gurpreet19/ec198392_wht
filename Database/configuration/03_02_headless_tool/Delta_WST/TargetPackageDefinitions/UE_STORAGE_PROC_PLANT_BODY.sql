CREATE OR REPLACE PACKAGE BODY ue_storage_proc_plant IS
/****************************************************************
** Package        :  ue_storage_proc_plant; body part
**
** $Revision: 1.2 $
**
** Purpose        :   This package is used by calling from EcBp_Storage_Proc_plant when predefined functions supplied by EC does not cover the requirements.
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.04.2011 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 05.04.2011  rajarsar	ECPD-17066:Initial version
** 30.01.2012  choonshu	ECPD-18622:Added getContentDensity
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getStorageDayGrsOpeningVol
-- Description    : Return the OPENING grs dip level for a storage for a day
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
FUNCTION getStorageDayGrsOpeningVol(p_object_id storage.object_id%TYPE,
  p_daytime  DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getStorageDayGrsOpeningVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getStorageDayGrsClosingVol
-- Description    : Return the CLOSING grs dip level for a storage for a day
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
FUNCTION getStorageDayGrsClosingVol(p_object_id storage.object_id%TYPE,
  p_daytime  DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getStorageDayGrsClosingVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getProdDayGrsOpeningVol
-- Description    : Return the OPENING grs vol for a product per storage per day
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
FUNCTION getProdDayGrsOpeningVol (
  p_object_id        storage.object_id%TYPE,
  p_product_id product.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getProdDayGrsOpeningVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getProdDayGrsClosingVol
-- Description    : Return the Closing grs vol for a product per storage per day
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
FUNCTION getProdDayGrsClosingVol (
  p_object_id        storage.object_id%TYPE,
  p_product_id product.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getProdDayGrsClosingVol;

---------------------------------------------------------------------------------------------------
-- Function       : getCompDayGrsOpeningVol
-- Description    : Return the OPENING grs vol for a company per product per day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompDayGrsOpeningVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER
IS

BEGIN
   RETURN NULL;

END getCompDayGrsOpeningVol;

---------------------------------------------------------------------------------------------------
-- Function       : getCompDayGrsClosingVol
-- Description    : Return the CLOSING grs vol for a company per product per day
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompDayGrsClosingVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL )

RETURN NUMBER IS

BEGIN
   RETURN NULL;
END getCompDayGrsClosingVol;

---------------------------------------------------------------------------------------------------
-- Function       : createGainLossTransaction
-- Description    : Allocate volume to Gain or Loss columns in transaction_measurement table. The Gain or Loss is a consequence of imbalance between actual tanks inventory and aggregated transaction values.
-- Preconditions  :
-- Postcondition  : Gain or Loss transaction has been inserted. In addition, ownership records have been inserted for the new transaction.
--
-- Using Tables   : transaction_measurement, transaction_meas_ownshp
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
Procedure createGainLossTransaction (
  p_object_id        VARCHAR2,
  p_daytime          DATE
   )
IS

BEGIN

    NULL;

END createGainLossTransaction;

---------------------------------------------------------------------------------------------------
-- Function       : createRegradeOwnship
-- Description    : Create regrade transaction ownership records for each product based on splits in equity share.
-- Preconditions  : Regrade transaction(s) has been inserted.
-- Postcondition  : Ownership records have been inserted with reference to the new regrade transaction(s).
--
-- Using Tables   : transaction_measurement
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createRegradeOwnship(p_event_no  NUMBER)
IS

BEGIN

    NULL;

END createRegradeOwnship;

---------------------------------------------------------------------------------------------------
-- Function       : getContentDensity
-- Description    : Return the Density for the Blend Content
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   : stor_blend_meas
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getContentDensity (
  p_object_id        product.object_id%TYPE,
  p_daytime          DATE)

RETURN NUMBER
IS

BEGIN
   RETURN NULL;

END getContentDensity;

END ue_storage_proc_plant;