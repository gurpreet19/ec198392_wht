CREATE OR REPLACE PACKAGE ue_alloc_method IS

/******************************************************************************
** Package        :  ue_alloc_method, header part
**
** $Revision: 1.1.2.4 $
**
** Purpose        :  Includes user-exit functionality for Meter Allocation Method screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.05.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 06-06-2012  farhaann ECPD-20855: Added checkNomPoint and validateAllocMethod procedure
** 12-07-2012  farhaann ECPD-21466: Added validateMeterLoc and validateOverlappingPeriod
** 25-07-2012  sharawan ECPD-21464: Added getMeterFromCntrInv to get meter id that is connected to the contract inventory
*/

PROCEDURE checkNomPoint(p_alloc_method_seq NUMBER);
PROCEDURE validateAllocMethod(p_alloc_method_seq NUMBER);
PROCEDURE validateMeterLoc(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE);
PROCEDURE validateOverlappingPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_alloc_level VARCHAR2);
FUNCTION getMeterFromCntrInv(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

END ue_alloc_method;