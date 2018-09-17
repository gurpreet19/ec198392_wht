CREATE OR REPLACE PACKAGE ue_Dry_Gas_Target IS
/******************************************************************************
** Package        :  ue_Dry_Gas_Target, head part
**
** $Revision: 1.1 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.01.2006 Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
********************************************************************/


PROCEDURE createBeforeDayTarget(p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE createWithinDayTarget(p_daytime DATE, p_change_reason VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

END ue_Dry_Gas_Target;