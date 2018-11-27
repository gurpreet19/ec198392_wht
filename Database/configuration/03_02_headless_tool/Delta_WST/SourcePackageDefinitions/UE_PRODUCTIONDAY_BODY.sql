CREATE OR REPLACE PACKAGE BODY ue_ProductionDay is
/****************************************************************
** Package        :  ue_ProductionDay, body part
**
** Purpose        :  This package is responsible for supporting business functions
**             		 related to Production Day.
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
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findProductionDayDefinition
-- Description    : user exit function
---------------------------------------------------------------------------------------------------
FUNCTION findProductionDayDefinition(
	p_class_name VARCHAR2,
	p_object_id VARCHAR2,
	p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
	RETURN NULL;
END findProductionDayDefinition;

END ue_ProductionDay;