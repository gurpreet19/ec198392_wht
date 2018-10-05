CREATE OR REPLACE PACKAGE BODY Ue_Forecast_Event IS
/******************************************************************************
** Package        :  Ue_Forecast_Event, body part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :
**
** Created        :  19.05.2016 Suresh Kumar
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 19-05-16    kumarsur    Initial Version
** 18-07-16    abdulmaw    ECPD-37247: Added procedure calcDeferments
** 18-10-16    abdulmaw    ECPD-34304: Added function isAssociatedWithGroup
********************************************************************/

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

PROCEDURE sumFromWells(
  p_event_no NUMBER,
  p_user_name VARCHAR2)
--</EC-DOC>
IS

BEGIN

  NULL;

END sumFromWells;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossVolume                                                  --
-- Description    : Returns Event Loss Volume
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
FUNCTION getEventLossVolume (
  p_event_no NUMBER,
  p_event_attribute VARCHAR2,
  p_object_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getEventLossVolume;

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
FUNCTION getPotentialRate(
  p_event_no NUMBER,
  p_potential_attribute VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPotentialRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : insertWells
-- Description    :
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
PROCEDURE insertWells(
  p_group_event_no NUMBER,
  p_forecast_id VARCHAR2,
  p_scenario_id VARCHAR2,
  p_event_type VARCHAR2,
  p_object_typ VARCHAR2,
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_end_date DATE DEFAULT NULL,
  p_username VARCHAR2,
  ue_flag OUT CHAR)
--</EC-DOC>
IS
BEGIN

    -- value 'Y' when customized UE applied.
    ue_flag := 'N';

END insertWells;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcDeferments
-- Description    :
-----------------------------------------------------------------------------------------------------
PROCEDURE calcDeferments(
  p_event_no VARCHAR2,
  p_from_date DATE DEFAULT NULL,
  p_to_date DATE DEFAULT NULL,
  ue_flag OUT CHAR)
--</EC-DOC>
IS
BEGIN

    -- value 'Y' when customized UE applied.
    ue_flag := 'N';

END calcDeferments;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : isAssociatedWithGroup                                                   --
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
FUNCTION isAssociatedWithGroup(
  p_reason_group VARCHAR2,
  p_reason_code VARCHAR2)
--</EC-DOC>
RETURN VARCHAR2

IS

BEGIN

  RETURN NULL;

END isAssociatedWithGroup;

END Ue_Forecast_Event;