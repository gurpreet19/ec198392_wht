CREATE OR REPLACE PACKAGE ue_Date_Time IS
/******************************************************************************
** Package        :  ue_Date_Time, head part
**
** $Revision: 1.2 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.05.2006 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 10.05.2006  zakiiari	Initial version
********************************************************************/

FUNCTION getProductionDay(pdd_object_id VARCHAR2,
                          p_daytime     DATE,
                          p_summer_time VARCHAR2
                          )
RETURN DATE;

--


FUNCTION getProductionDayStartTimeUTC(pdd_object_id VARCHAR2,
                                      p_day         DATE
                                      )
RETURN DATE;

END ue_Date_Time;