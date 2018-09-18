CREATE OR REPLACE PACKAGE Ue_Deferment_Event IS
/****************************************************************
** Package        :  Ue_Deferment_Event
**
** $Revision: 1.2.2.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Low and Off Deferments.
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.10.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 24.10.2011 rajarsar ECPD-18545:Initial version.
** 28.06.2012 leongwen ECPD-21351:Added calcDeferments procedure
*****************************************************************/

FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getActualVolumes, WNDS, WNPS, RNPS);

PROCEDURE calcDeferments(p_event_no VARCHAR2, p_asset_id VARCHAR2 DEFAULT NULL, p_from_date DATE DEFAULT NULL, p_to_date DATE DEFAULT NULL);

END Ue_Deferment_Event;