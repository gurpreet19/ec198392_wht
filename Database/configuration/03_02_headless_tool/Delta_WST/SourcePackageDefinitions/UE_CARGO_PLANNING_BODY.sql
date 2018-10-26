CREATE OR REPLACE PACKAGE BODY ue_cargo_planning IS
/******************************************************************************
** Package        :  ue_cargo_planning, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Includes user-exit functionality for cargo planning forecast
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.03.2013 Lee Wei Yap
**
** Modification history:
**
** Date   		Whom  	  Change description:
** -----  		----- 	  -----------------------------------------------------------------------------------------------
** 05.03.2013 	leeeewei  ECPD-20121:initial version
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setProcessTrainEvent
-- Description    : calculate the production forecast rundown on daily and subdaily for a storage when an event is registered
-- 					Unit conversion will be implemented by the project in this ue package
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
PROCEDURE setProcessTrainEvent(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_end_date   DATE,
                               p_event_code VARCHAR2)

IS

BEGIN

 ecbp_cargo_planning.setProcessTrainEvent(p_object_id,p_daytime,p_end_date,p_event_code);

END setProcessTrainEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : delProcessTrainEvent
-- Description    : Delete process train event and recalculate rundown to their original values defined in the process train yield factors
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
PROCEDURE delProcessTrainEvent(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_end_date   DATE)

IS

BEGIN

 ecbp_cargo_planning.delProcessTrainEvent(p_object_id,p_daytime,p_end_date);

END delProcessTrainEvent;

END ue_cargo_planning;