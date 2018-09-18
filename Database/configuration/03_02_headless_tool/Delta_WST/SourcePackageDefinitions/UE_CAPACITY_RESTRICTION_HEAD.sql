CREATE OR REPLACE PACKAGE ue_capacity_restriction IS
/******************************************************************************
** Package        :  ue_capacity_restriction, header part
**
** $Revision: 1.1 $
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
** -------     ------    -----------------------------------------------
** 18.09.2017  farhaann  ECPD-48304: Initial version
*/
FUNCTION updateDailyRestriction(p_object_id      VARCHAR2,
								p_old_start_date DATE,
								p_new_start_date DATE,
								p_old_end_date   DATE,
								p_new_end_date   DATE) RETURN NUMBER;

END ue_capacity_restriction;