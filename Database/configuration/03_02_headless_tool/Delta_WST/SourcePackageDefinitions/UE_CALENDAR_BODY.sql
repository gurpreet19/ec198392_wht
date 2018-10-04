CREATE OR REPLACE PACKAGE BODY ue_Calendar IS
/****************************************************************
** Package        :  ue_Calendar, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions for EcDp_Calendar
**
** Documentation  :  www.energy-components.com
**
** Created        : 12.12.2011  EnergyComponents Team
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.0	    12.12.2011 HOIENGEO   Initial version
************************************************************************************************************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetCollActualDate
-- Description    : This is an INSTEAD OF user-exit addon to the standard EcDp_Calendar.GetCollActualDate.
-- Preconditions  : Must be enabled using global variable isGetCollActualDateUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDate(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_offset NUMBER,
                           p_method VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  GetCollActualDatePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Calendar.GetCollActualDatePre.
-- Preconditions  : Must be enabled using global variable isGetCollActualDatePreUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDatePre(p_object_id VARCHAR2,
                              p_daytime DATE,
                              p_offset NUMBER,
                              p_method VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDatePre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetCollActualDatePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Calendar.GetCollActualDatePost.
-- Preconditions  : Must be enabled using global variable isGetCollActualDatePostUEEnabled
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCollActualDatePost(p_object_id VARCHAR2,
                               p_daytime DATE,
                               p_offset NUMBER,
                               p_method VARCHAR2,
                               p_tentative_ret_val DATE)
RETURN DATE
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetCollActualDatePost;

END ue_Calendar;