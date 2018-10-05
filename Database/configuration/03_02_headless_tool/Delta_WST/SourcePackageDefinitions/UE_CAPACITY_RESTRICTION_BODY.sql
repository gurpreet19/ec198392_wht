CREATE OR REPLACE PACKAGE BODY ue_capacity_restriction IS
/******************************************************************************
** Package        :  ue_capacity_restriction, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Handles user-exit functionality for capacity restriction operations
**
** Documentation  :  www.energy-components.com
**
** Created  : 18.09.2017 Annida Farhana
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     -----------------------------------------------------------------------------------------------
** 18.09.2017  farhaann  ECPD-48304: Initial version
*/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateDailyRestriction
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
FUNCTION updateDailyRestriction(p_object_id      VARCHAR2,
                                p_old_start_date DATE,
                                p_new_start_date DATE,
                                p_old_end_date   DATE,
                                p_new_end_date   DATE) RETURN NUMBER
--</EC-DOC>
   IS
  BEGIN
    RETURN NULL;
  END updateDailyRestriction;
END ue_capacity_restriction;