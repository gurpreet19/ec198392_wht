CREATE OR REPLACE PACKAGE BODY Ue_Well_Eqpm_Deferment IS
/****************************************************************
** Package        :  Ue_Well_Eqpm_Deferment
**
** $Revision: 1.2.2.4 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Constraints and Downtime Deferments.
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.10.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 24.10.2011 rajarsar ECPD-18545:Initial version.
** 11.07.2013 leongwen ECPD-24671 Added User Exit procedure sumFromWells
** 16.07.2013 wonggkai ECPD-24868:Added User Exit function getPotentialRate
** 26-07-2013 wonggkai ECPD-24868: Modified getPotentialRate, add p_potential_attribute as parameter to Ue_Well_Eqpm_Deferment.getPotentialRate()
** 17-09-2013 abdulmaw ECPD-24671: Added getEventLossRate.
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualVolumes                                                   --
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
FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getActualVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : sumFromWells                                                                   --
-- Description    : Sum child event loss volume to parent's loss rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2)
--</EC-DOC>
IS

BEGIN

  NULL;

END sumFromWells;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialRate                                                   --
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
FUNCTION getPotentialRate(p_event_no NUMBER, p_potential_attribute VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPotentialRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossRate                                                  --
-- Description    : Returns Event Loss Rate
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
FUNCTION getEventLossRate (
	p_event_no NUMBER,
	p_event_attribute VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getEventLossRate;

END Ue_Well_Eqpm_Deferment;