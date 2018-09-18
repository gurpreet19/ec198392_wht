CREATE OR REPLACE PACKAGE BODY EcBp_HCM_VFM IS
/****************************************************************
** Package        :  EcBp_HCM_VFM, body part
**
** $Revision: 1.223 $
**
** Purpose        :  To support Technic FMC
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.03.2018  Mawaddah Abdul Latif
**
** Modification history:
**
** Date         Whom      Change description:
** ------       -----     --------------------------------------
** 13.03.2018   abdulmaw  ECPD-52711: Initial version
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume for well on a given day, source method specified
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
FUNCTION getOilStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume for well on a given day, source method specified
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
FUNCTION getGasStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume for well on a given day, source method specified
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
FUNCTION getWatStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)

RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getWatStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume for well on a given day, source method specified
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
FUNCTION getCondStdRateDay(p_object_id   well.object_id%TYPE,
                           p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getCondStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gaslift volume for well on a given day, source method specified
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
FUNCTION getGasLiftStdRateDay(p_object_id     well.object_id%TYPE,
                              p_daytime       DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END getGasLiftStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilMassDay
-- Description    : Returns theoretical oil mass for well on a given day, source method specified
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
FUNCTION findOilMassDay(p_object_id well.object_id%TYPE,
                        p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END findOilMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
-- Description    : Returns theoretical gas mass for well on a given day, source method specified
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
FUNCTION findGasMassDay (p_object_id well.object_id%TYPE,
                         p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
-- Description    : Returns theoretical water mass for well on a given day, source method specified
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
FUNCTION findWaterMassDay (p_object_id well.object_id%TYPE,
                           p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
-- Description    : Returns theoretical condensate mass for well on a given day, source method specified
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
FUNCTION findCondMassDay (p_object_id well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;

END findCondMassDay;

END EcBp_HCM_VFM;