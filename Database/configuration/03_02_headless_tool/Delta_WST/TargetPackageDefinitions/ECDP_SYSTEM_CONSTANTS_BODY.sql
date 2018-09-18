CREATE OR REPLACE PACKAGE BODY EcDp_System_Constants IS
/**************************************************************
** Package	:  EcDp_System_Constants
**
** $Revision: 1.2 $
**
** Purpose	:  Energy Components dataware house
**   This package groups together constant functions
**   used by basis Insert/Update packages like Objects, Node etc.
**
** General Logic:
**
**
**
**
** Assumptions
**
**
**
** Created:   	13.11.02  Arild Vervik, TE
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 27.05.2004 SHN  Changed EARLIEST_DATE to 01.01.1900
**************************************************************/
--
--
-- Constant functions used within this package


---------------------------------------------------------------------------------------------------
-- function       : EARLIEST_DATE
-- Description    : Constant funtion returning a dummy date representing a lower date boundary.
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION EARLIEST_DATE
RETURN DATE
--</EC-DOC>
IS
BEGIN

  -- NOTYET  Look this up from agreed config table
  RETURN TO_DATE('01.01.1900 00:00','dd.mm.yyyy hh24:mi');
END;

---------------------------------------------------------------------------------------------------
-- function       : FUTURE_DATE
-- Description    : Constant funtion returning a dummy date representing a upper date boundary.
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION FUTURE_DATE
RETURN DATE
--</EC-DOC>
IS
BEGIN
  RETURN TO_DATE('01.01.2200 00:00','dd.mm.yyyy hh24:mi');
END;


END;