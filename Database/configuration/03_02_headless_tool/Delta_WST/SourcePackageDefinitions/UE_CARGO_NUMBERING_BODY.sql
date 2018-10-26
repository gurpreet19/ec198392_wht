CREATE OR REPLACE PACKAGE BODY ue_Cargo_Numbering AS
/******************************************************************************
** Package        :  ue_Cargo_Numbering, body part
**
** $Revision: 1.1 $
**
** Purpose        :  License spesific package to provide cargo numbering as the customer expects in reporting
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.03.2013 Lee Wei Yap
**
** Modification history:
**
** Version  Date     Whom  		Change description:
** -------  ------   ----- 		-------------------------------------------
** 1.1   27.03.2013  leeeewei	Renamed ecbp_cargo_numbering to ue_cargo_numbering
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoNameFromDate
-- Description    : Returns the date part of a cargo name
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
FUNCTION getCargoNameFromDate(p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

ls_cargo_name  VARCHAR2(100);


BEGIN
		ls_cargo_name := TO_CHAR(p_daytime, 'YYYY') || TO_CHAR(p_daytime, 'MM') || TO_CHAR(p_daytime, 'DD');

RETURN ls_cargo_name;

END getCargoNameFromDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoName
-- Description    : Returns a string containg license specific Cargo Name
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
FUNCTION getCargoName(p_cargo_no NUMBER,
					p_parcels VARCHAR2,
					p_daytime DATE,
					p_forecast_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

ls_cargo_name  VARCHAR2(100);
ln_nextkeyvalue NUMBER;


BEGIN

--getting the next key value based on the max_id from the assign_id table
select max(max_id)+1 into ln_nextkeyvalue from assign_id where tablename='CARGO_TRANSPORT';

	ls_cargo_name := getCargoNameFromDate(p_daytime);
  --If cargo is null get the Next Key value
	IF p_cargo_no is null THEN
		ls_cargo_name := ls_cargo_name || '-' || ln_nextkeyvalue;
		ELSE
		  ls_cargo_name := ls_cargo_name || '-' || p_cargo_no;
	END IF;

RETURN ls_cargo_name;

END getCargoName;

END ue_Cargo_Numbering;