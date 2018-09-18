CREATE OR REPLACE PACKAGE Ue_Defer_Summary IS
/****************************************************************
** Package        :  Ue_Defer_Summary
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment Summary.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.01.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 18.08.2008 aliassit ECPD-9294: Added two new functions getActualMass and getActualEnergy
*****************************************************************/

FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getActualMass(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getActualEnergy(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE) RETURN NUMBER;

END Ue_Defer_Summary;