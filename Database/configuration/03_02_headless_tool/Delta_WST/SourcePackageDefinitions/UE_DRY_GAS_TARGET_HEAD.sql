CREATE OR REPLACE PACKAGE ue_Dry_Gas_Target IS
/******************************************************************************
** Package        :  ue_Dry_Gas_Target, head part
**
** $Revision: 1.2 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.01.2006 Stian Skj�tad
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 18.10.2013  leeeewei		ECPD-25002: Added createNomLocTarget
********************************************************************/


PROCEDURE createBeforeDayTarget(p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE createWithinDayTarget(p_daytime DATE, p_change_reason VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE createNomLocTarget(p_nomloc_id VARCHAR2,p_daytime DATE, p_valid_from DATE);

END ue_Dry_Gas_Target;