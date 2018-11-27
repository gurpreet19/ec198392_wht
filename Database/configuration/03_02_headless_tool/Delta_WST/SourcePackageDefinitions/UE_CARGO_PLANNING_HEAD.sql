CREATE OR REPLACE PACKAGE ue_cargo_planning IS

/******************************************************************************
** Package        :  ue_cargo_planning, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for cargo planning forecast
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.02.2013 Lee Wei Yap
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 05.03.2013 leeeewei	initial version
*/

PROCEDURE setProcessTrainEvent(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_end_date   DATE,
                               p_event_code VARCHAR2);

PROCEDURE delProcessTrainEvent(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_end_date   DATE);

END ue_cargo_planning;