CREATE OR REPLACE PACKAGE BODY Ue_Well_Theoretical_Month IS
/****************************************************************
** Package        :  Ue_Well_Theoretical_Month, body part
**
** $Revision: 1.223 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.09.2015  Alok Dhavale
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  --------------------------------------
** 1.0      21.09.2015  dhavaalo       Initial version
** 1.1      07.10.2015  dhavaalo       ECPD-32095-New Theoretical Monthly Method for Steam Injection-Function getInjectedStdRateMonth Added
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateMonth
-- Description    : Returns theoretical oil volume for well on a given month
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
FUNCTION getOilStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  BEGIN

  RETURN NULL;

END getOilStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateMonth
-- Description    : Returns theoretical gas volume for well on a given month
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
FUNCTION getGasStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  BEGIN

  RETURN NULL;

END getGasStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateMonth
-- Description    : Returns theoretical water volume for well on a given month
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
FUNCTION getWatStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  BEGIN

  RETURN NULL;

END getWatStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateMonth
-- Description    : Returns theoretical condensate volume for well on a given month
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
FUNCTION getCondStdRateMonth(p_object_id   well.object_id%TYPE,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  BEGIN

  RETURN NULL;

END getCondStdRateMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injection volume for well on a given day, source method specified
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
FUNCTION getInjectedStdRateMonth(p_object_id   well.object_id%TYPE,
                               p_inj_type    VARCHAR2,
                               p_daytime     DATE,
                               p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  BEGIN

  RETURN NULL;

END getInjectedStdRateMonth;

END Ue_Well_Theoretical_Month;