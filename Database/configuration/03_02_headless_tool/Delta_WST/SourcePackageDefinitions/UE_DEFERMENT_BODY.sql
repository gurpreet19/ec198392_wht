CREATE OR REPLACE PACKAGE BODY ue_Deferment IS
/******************************************************************************
** Package        :  ue_Deferment, body part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :
**
** Created        :  03.07.2014 Wong Kai Chun
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 03-07-14    wonggkai    Intial Version
** 04-09-14    leongwen    Added procedure calcDeferments
** 09-09-14    kumarsur	   ECPD-28473: Create getEventLossVolume.
** 09-12-14    wonggkai    ECPD-29261: Modified arguement for insertWells
** 09-03-15    dhavaalo    ECPD-29807: Changes to improve Well Deferment Performance.
** 21-04-15    deshpadi    ECPD-30358: Added function getPotentialRate.
** 04-05-15    dhavaalo    ECPD-30780: Added User Exit procedure sumFromWells
** 05-10-16    dhavaalo    ECPD-30185: Added User Exit procedure getEventLossRate
** 20-03-17    dhavaalo    ECPD-42995: Deferment: Remove reference to PD.0020 in order to run calculation
** 24-07-17    kashisag    ECPD-43591: Added User Exit procedure allocateGroupRateToWells
** 28-02-17    leongwen    ECPD-45873: Added User Exit function getEventLossMassRate, getEventLossMass and getPotentialMassRate
********************************************************************/

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
PROCEDURE insertWells(p_group_event_no NUMBER, p_event_type VARCHAR2, p_object_typ VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2, ue_flag OUT CHAR)
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
PROCEDURE calcDeferments(p_event_no VARCHAR2, p_asset_id VARCHAR2 DEFAULT NULL, p_from_date DATE DEFAULT NULL, p_to_date DATE DEFAULT NULL,ue_flag OUT CHAR)
--</EC-DOC>
IS
BEGIN

    -- value 'Y' when customized UE applied.
    ue_flag := 'N';

END calcDeferments;


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
FUNCTION getPotentialRate(p_event_no NUMBER, p_potential_attribute VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPotentialRate;

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
-- Procedure      : getEventLossRate                                                                   --
-- Description    : Returns Event Loss Rate
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
FUNCTION getEventLossRate (
  p_event_no      NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END getEventLossRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : allocateGroupRateToWells
-- Description    :
-----------------------------------------------------------------------------------------------------
PROCEDURE allocateGroupRateToWells(p_event_no NUMBER, p_user_name VARCHAR2 ,ue_flag OUT CHAR)
--</EC-DOC>
IS
BEGIN

    -- value 'Y' when customized UE applied.
    ue_flag := 'N';

END allocateGroupRateToWells;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : getEventLossMass                                                                   --
-- Description    : Returns Event Loss Mass
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
FUNCTION getEventLossMassRate (
  p_event_no      NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END getEventLossMassRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossMass                                                               --
-- Description    : Returns Event Loss Mass
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
FUNCTION getEventLossMass (
	p_event_no NUMBER,
	p_event_attribute VARCHAR2,
	p_object_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getEventLossMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialMassRate                                                           --
-- Description    :
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
FUNCTION getPotentialMassRate(p_event_no NUMBER, p_potential_attribute VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPotentialMassRate;

END ue_Deferment;