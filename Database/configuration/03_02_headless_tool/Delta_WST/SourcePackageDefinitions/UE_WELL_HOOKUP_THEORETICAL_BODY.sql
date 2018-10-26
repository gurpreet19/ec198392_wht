CREATE OR REPLACE PACKAGE BODY Ue_Well_Hookup_Theoretical IS
/****************************************************************
** Package        :  Ue_Well_Hookup_Theoretical
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Hook up theoretical calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.01.2017  Shivam Singhal
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 15.02.2017 singishi ECPD-43210:Initial version.
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getWellHookPhaseFactorDay                                                  --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getWellHookPhaseFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getWellHookPhaseFactorDay;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getWellHookPhaseMassFactorDay                                                  --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getWellHookPhaseMassFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getWellHookPhaseMassFactorDay;


END Ue_Well_Hookup_Theoretical;