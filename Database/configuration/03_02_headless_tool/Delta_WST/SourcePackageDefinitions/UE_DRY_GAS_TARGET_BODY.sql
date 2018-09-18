CREATE OR REPLACE PACKAGE BODY ue_Dry_Gas_Target IS
/******************************************************************************
** Package        :  ue_Dry_Gas_Target, body part
**
** $Revision: 1.2 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.06.2006 Stian Skj?tad
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-----------------------------------------------------------------------------------------------
** 21.10.13   leeeewei  ECPD-25002: Added createNomLocTarget
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createNomLocDayTarget
-- Description    : User exit function for any additional function in Daily Nomination Location Target
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
PROCEDURE createNomLocTarget(p_nomloc_id VARCHAR2,
						     p_daytime DATE,
							 p_valid_from DATE
)
--</EC-DOC>
IS
BEGIN

NULL;

END createNomLocTarget;

END ue_Dry_Gas_Target;