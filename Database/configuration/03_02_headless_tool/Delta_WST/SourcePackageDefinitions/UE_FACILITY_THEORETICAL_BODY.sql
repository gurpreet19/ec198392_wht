CREATE OR REPLACE PACKAGE BODY Ue_Facility_Theoretical IS
/****************************************************************
** Package        :  Ue_Facility_Theoretical
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Facility theoretical calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2013  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 09.05.2013 rajarsar ECPD-23618:Initial version.
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseFactorDay                                                  --
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
FUNCTION getFacilityPhaseFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getFacilityPhaseFactorDay;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getFacilityMassFactorDay                                                  --
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
FUNCTION getFacilityMassFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getFacilityMassFactorDay;

END Ue_Facility_Theoretical;