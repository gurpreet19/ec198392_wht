CREATE OR REPLACE PACKAGE ue_ProductionDay IS

/****************************************************************
** Package        :  ue_ProductionDay
**
** Purpose        :  User exit functions should be put here.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.09.2012 Mak Kam Jie
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 05.09.2012  makkkkam Initial version. ECPD-19593: Added findProductionDayDefinition function.
****************************************************************/

FUNCTION findProductionDayDefinition(
	p_class_name VARCHAR2,
	p_object_id VARCHAR2,
	p_daytime DATE)
RETURN VARCHAR2;

END ue_ProductionDay;