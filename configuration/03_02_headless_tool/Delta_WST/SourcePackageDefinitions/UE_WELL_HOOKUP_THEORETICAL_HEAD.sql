CREATE OR REPLACE PACKAGE Ue_Well_Hookup_Theoretical IS
/****************************************************************
** Package        :  Ue_Well_Hookup_Theoretical
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Hook up theoretical calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.01.2017  Shivam Singhal
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 15.02.2017 singishi ECPD-43210:Initial version.
*****************************************************************/

FUNCTION getWellHookPhaseFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getWellHookPhaseMassFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;

END  Ue_Well_Hookup_Theoretical;