CREATE OR REPLACE PACKAGE BODY ue_Date_Time IS
/******************************************************************************
** Package        :  ue_Date_Time, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Perform production day based on user specific code, raise error if not found.
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.05.2006 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 10.05.2006  zakiiari	Initial version
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDay
-- Description    : user exit function
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
FUNCTION getProductionDay(pdd_object_id VARCHAR2,
                          p_daytime     DATE,
                          p_summer_time VARCHAR2
                          )
RETURN DATE
--</EC-DOC>
IS

BEGIN
  RETURN NULL;
END getProductionDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStartTimeUTC
-- Description    : user exit function
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
FUNCTION getProductionDayStartTimeUTC(pdd_object_id VARCHAR2,
                                      p_day         DATE
                                      )
RETURN DATE
--</EC-DOC>

IS

BEGIN

  RETURN NULL;

END getProductionDayStartTimeUTC;


END ue_Date_Time;