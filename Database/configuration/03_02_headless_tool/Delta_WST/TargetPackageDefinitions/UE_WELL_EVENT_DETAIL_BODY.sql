CREATE OR REPLACE PACKAGE BODY Ue_Well_Event_Detail IS
/****************************************************************
** Package        :  Ue_Well_Event_Detail
**
** $Revision: 1.2.46.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Well Injections Data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.08.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
**28.05.15   abdulmaw  ECPD-31002: Updated calcInjectionRate
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcInjectionRate                                                   --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_event_detail
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
FUNCTION calcInjectionRate(
  p_object_id        VARCHAR2,
  p_daytime DATE,
  p_event_type VARCHAR2 )
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END calcInjectionRate;

END Ue_Well_Event_Detail;