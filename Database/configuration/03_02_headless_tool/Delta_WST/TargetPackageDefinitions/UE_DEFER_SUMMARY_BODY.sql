CREATE OR REPLACE PACKAGE BODY Ue_Defer_Summary IS
/****************************************************************
** Package        :  Ue_Defer_Summary
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment Summary.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.01.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 18.08.2008 aliassit ECPD-9294: Added two new functions getActualMass and getActualEnergy
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPlannedVolumes                                                   --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : plan_day_fcty
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
FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPlannedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualProducedVolumes                                                   --
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
FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getActualProducedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualMass                                               --
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
FUNCTION getActualMass(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getActualMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualEnergy                                                 --
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
FUNCTION getActualEnergy(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getActualEnergy;

END Ue_Defer_Summary;