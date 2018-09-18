CREATE OR REPLACE PACKAGE BODY ue_Dry_Gas_Target IS
/******************************************************************************
** Package        :  ue_Dry_Gas_Target, body part
**
** $Revision: 1.1 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.06.2006 Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createBeforeDayTarget
-- Description    : User exit function for Before Day Target
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
PROCEDURE createBeforeDayTarget(p_daytime    	DATE,
								p_user VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS
BEGIN

NULL;

END createBeforeDayTarget;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createWithinDayTarget
-- Description    : User exit function for Within Day Target
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
PROCEDURE createWithinDayTarget(p_daytime    	DATE,
								p_change_reason VARCHAR2,
								p_user VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS
BEGIN

NULL;

END createWithinDayTarget;

END ue_Dry_Gas_Target;